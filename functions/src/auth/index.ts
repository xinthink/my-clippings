import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { PubSub } from '@google-cloud/pubsub';

import * as cookieParser from 'cookie-parser';
import * as express from 'express';
import * as session from 'express-session';
import * as morgan from 'morgan';
import * as passport from 'passport';
import { Strategy as EvernoteStrategy } from 'passport-evernote';
import { assoc, partial } from 'ramda';
import * as uuid from 'uuid/v4';

import config from '../local';
import { FireSessionStore } from './FireSessionStore';
import { YinxiangStrategy } from './YinxiangStrategy';

// types
import SessionOptions = session.SessionOptions;

const env = process.env.NODE_ENV;
const isProd = 'production' === env; // if it's production env

/* init firebase, for local debugging:
  export GOOGLE_APPLICATION_CREDENTIALS=<path-to-adminsdk-json>
  export FIREBASE_CONFIG=<path-to-adminsdk-json>
 */
admin.initializeApp();

// init express
const authApp = express();
authApp.use(cookieParser('xinthink-notever'));
authApp.use(morgan('combined'));

const sessionOptions = {
  resave: false,
  saveUninitialized: true,
  secret: 'xinthink-notever',
} as SessionOptions;
sessionOptions.store = new FireSessionStore(
  admin.firestore(),
  isProd ? 'sessions' : 'sessions-dev',
);
authApp.use(session(sessionOptions));

// Evernote auth using passport
authApp.use(passport.initialize());
authApp.use(passport.session());

// callback to finish the Evernote auth
function onVerify(token: string, tokenSecret: string, profile: any, cb: Callback<object>) {
  if (!token || !profile || !profile.id) {
    cb(new Error('invalid token or profile'));
    return;
  }

  const user = {
    ...profile,
    token,
    tokenSecret,
  };
  console.log('Evernote auth done', user);
  const uid = `${profile.provider}:${profile.id}`;
  admin.auth()
    .createCustomToken(uid, user)
    .then(customToken => assoc('customToken', customToken, user))
    .then((u: any) => admin.firestore()
      .collection("users")
      .doc(uid)
      .set(u)
      .then(() => u)
    )
    .then((u: any) => admin.firestore()
      .collection("_t") // cache the token for frontend retrieval
      .doc(uid)
      .set({
        customToken: u.customToken,
        expires: Date.now() + 86400000, // expires at 24hr later
      })
      .then(() => u)
    )
    .then(partial(cb, [null]))
    .catch(cb);
}

passport.use(new EvernoteStrategy(config.evernote, onVerify));
passport.use(new YinxiangStrategy(config.yinxiang, onVerify) as any);
passport.serializeUser((user: any, cb) => {
  console.log('serializeUser', user);
  cachedUser = user;
  cb(null, `${user.provider}:${user.id}`);
});
passport.deserializeUser((id: string, cb) => {
  console.log('deserializeUser', id);
  if (cachedUser) cb(null, cachedUser);
  else admin.firestore()
    .collection("users")
    .doc(id)
    .get()
    .then((d) => {
      cachedUser = d.exists ? d.data() : null;
      return cachedUser;
    })
    .then(partial(cb, [null]))
    .catch(cb);
});

// CORS
authApp.all('*.json', (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Content-Length, Authorization, Accept, X-Requested-With, yourHeaderFeild');
  res.header('Access-Control-Allow-Methods', 'PUT, POST, GET, DELETE, OPTIONS');
  res.header('Cache-Control', 'no-cache');
  next();
});

// routes
authApp.get('/token.json', (req, res) => res.send(req.user));

// handle clippings import requests TODO authentication
authApp.post('/import.json', (req, res) => {
  if (!req.body || req.body.length <= 0) {
    res.send({});
    return;
  }

  const pubsub = new PubSub();
  pubsub.topic(config.pubsub.importTopic)
    .publishJSON(req.body, {
      taskId: uuid(),
      createdAt: `${Date.now()}`,
    })
    .then(mid => {
      console.log('message published', config.pubsub.importTopic, mid);
      res.send({});
    })
    .catch(console.error);
});

// redirect to frontend after oauth complete
authApp.get('/result', (req, res) =>
  res.redirect(`${config.host}/#/auth?uid=${(req.user || {}).provider}:${(req.user || {}).id}`));

authApp.get('/:provider', (req, res, next) => {
  console.log('access', req.url, req.params);
  passport.authenticate(req.params.provider, { session: true })(req, res, next);
});

// access /evernote/callback/?oauth_token=xinthink-9973.x&oauth_verifier=x&sandbox_lnb=false { provider: 'evernote' }
authApp.get('/:provider/callback', (req, res, next) => {
  console.log('access', req.url, req.params, req.user);
  const provider = req.params.provider;
  passport.authenticate(provider, {
    session: true,
    successRedirect: config.oauth_redirect, // wait for oauth complete, req.user is null at this point
    // successRedirect: `${config.host}/#/auth?uid=${provider}:${(req.user || {}).id}`,
    // failureRedirect: `${config.host}/#/auth`,
  })(req, res, next);
});

export const auth = functions
  .region('asia-northeast1')
  .https.onRequest(authApp);

// cache authenticated user in memery
let cachedUser: any;
