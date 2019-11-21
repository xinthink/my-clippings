import { CollectionReference } from '@google-cloud/firestore';
import { Store } from 'express-session';
import * as admin from 'firebase-admin';
import Firestore = admin.firestore.Firestore;
import * as Q from 'q';
import { compose, filter, is, lensProp, not, over } from 'ramda';
import { inspect } from "util";

const isNotFunc = compose(not, is(Function));
const sanitize = (o: object) => filter(isNotFunc, o);
const sanitizeSessionData: (s: Express.SessionData) => object =
  // @ts-ignore linter failure on Currying
  compose(sanitize, over<object>(lensProp('cookie'), sanitize));

/**
 * An express session store based on Cloud Firestore
 */
export class FireSessionStore extends Store {
  private collection: CollectionReference;

  constructor(db: Firestore, collectionName = 'sessions') {
    super();
    this.collection = db.collection(collectionName);
  }

  /**
   * Fetch a keyed session reference.
   *
   * @override
   * @param {String} sid  The session key
   * @param {Function} cb OnComplete callback function
   */
  get = (sid: string, cb: Callback<Express.SessionData>) => {
    console.log('get session', sid);
    return this.collection.doc(sid)
      .get()
      .then(doc => cb(null, doc.exists ? <Express.SessionData>doc.data() : null))
      .catch(cb);
  };

  /**
   * Save a keyed session reference.
   *
   * @override
   * @param  {String} sid  The session key
   * @param  {Object} session The session data
   * @param  {Function} cb OnComplete callback function
   */
  set = (sid: string, session: Express.SessionData, cb?: VoidCallback) => {
    console.log('set session', sid, inspect(session));
    return this.collection.doc(sid)
      .set(sanitizeSessionData(session))
      .then(() => cb && cb(), cb);
  };

  /**
   * Remove a keyed session reference.
   *
   * @override
   * @param  {String} sid  The session key
   * @param  {Function} cb OnComplete callback function
   */
  destroy = (sid: string, cb?: VoidCallback) => {
    console.log('destroy session', sid);
    return this.collection.doc(sid)
      .delete()
      .then(() => cb && cb(), cb);
  };

  /**
   * Get size of the session store.
   *
   * {Function} cb OnComplete callback function
   */
  length = (cb: Callback<number>) => this.collection.get()
    .then(({size}) => cb(null, size), cb);

  /**
   * Delete all sessions from the store.
   *
   * @param {Function} cb OnComplete callback function
   */
  clear = (cb?: VoidCallback) => this.collection.get()
    .then(snapshot => {
      const deletePromises: Array<Promise<any>> = [];
      snapshot.forEach(doc =>
        deletePromises.push(doc.ref.delete())
      );
      return Q.all(deletePromises);
    })
    .then(() => cb && cb(), cb);
}
