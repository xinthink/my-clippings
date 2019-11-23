import * as admin from 'firebase-admin';

import EvernoteTool from './evernote';
import config from '../local';

/**
 * Create Evernote notes for the given `Clippings`
 */
export async function createNotes({uid, clippings}: ClippingsPayload) {
  if (!uid || !clippings || clippings.length <= 0) {
    console.log('abort notes creation with invalid input:', uid, clippings && clippings.length);
    return;
  }

  const auth = await loadAuthInfo(uid);
  if (!auth || !auth.token) {
    console.log('abort notes creation: token not found for', uid);
    return;
  }

  const cfg = (<any>config)[auth.provider];
  const tool = new EvernoteTool(auth.token, cfg);

  console.log(`start creating ${clippings.length} notes ...`);
  for (const c of clippings) {
    try {
      await tool.createNote(c);
    } catch (e) {
      console.error('failed to create note', e);
    }
  }
  console.log(`${clippings.length} notes created.`);
}

async function loadAuthInfo(uid: string): Promise<NullableAuthInfo> {
  const doc = await admin.firestore()
    .collection('users')
    .doc(uid)
    .get();

  return doc.exists ? doc.data() as AuthInfo : null;
}
