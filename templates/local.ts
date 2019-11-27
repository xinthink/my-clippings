const config = {
  host: <site-url>,
  oauth_redirect: '<functions-domain>/auth/result',
  func_host: '<functions-domain>',
  evernote_host: 'www.evernote.com',
  yinxiang_host: 'app.yinxiang.com',
};

const evernoteConfig = {
  sandbox: false,
  oauthURL: `https://${config.evernote_host}/oauth`,
  requestTokenURL: `https://${config.evernote_host}/oauth`,
  accessTokenURL: `https://${config.evernote_host}/oauth`,
  userAuthorizationURL: `https://${config.evernote_host}/OAuth.action`,
  consumerKey: <evernote-consumer-key>,
  consumerSecret: <evernote-consumer-secret>,
  callbackURL: `${config.func_host}/auth/evernote/callback/`,
};

// YXBJ (Chinese version of Evernote)
const yinxiangConfig = {
  china: true,
  sandbox: false,
  oauthURL: `https://${config.yinxiang_host}/oauth`,
  requestTokenURL: `https://${config.yinxiang_host}/oauth`,
  accessTokenURL: `https://${config.yinxiang_host}/oauth`,
  userAuthorizationURL: `https://${config.yinxiang_host}/OAuth.action`,
  consumerKey: <yxbj-consumer-key>,
  consumerSecret: <yxbj-consumer-secret>,
  callbackURL: `${config.func_host}/auth/yinxiang/callback/`,
};

const PubSubConfig = {
  importTopic: 'import-clippings',
};

export default {
  ...config,
  evernote: evernoteConfig,
  yinxiang: yinxiangConfig,
  pubsub: PubSubConfig,
};
