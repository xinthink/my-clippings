import * as admin from 'firebase-admin';

import EvernoteTool from './evernote';
import config from '../local';

/**
 * Create Evernote notes for the given `Clippings`
 */
export async function createNotes({uid, clippings}: ClippingsPayload, attrs: NotesCreationAttrs) {
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
  const total = clippings.length;
  let succeed = 0;
  let failed = 0;

  console.log(`start creating ${total} notes... taskId=${attrs.taskId}`);
  await reportProgress(uid, total, attrs);
  for (const c of clippings) {
    try {
      await tool.createNote(c);
      succeed += 1;
    } catch (e) {
      failed += 1;
      console.error('failed to create note', c, e);
    } finally {
      await reportProgress(uid, total, attrs, succeed, failed);
    }
  }
  console.log(`creation finished with ${succeed} succeed, ${failed} failed of total ${total} notes.`);
}

async function loadAuthInfo(uid: string): Promise<NullableAuthInfo> {
  const doc = await admin.firestore()
    .collection('users')
    .doc(uid)
    .get();

  return doc.exists ? doc.data() as AuthInfo : null;
}

async function reportProgress(
  uid: string,
  total: number,
  attrs: NotesCreationAttrs,
  succeed: number = 0,
  failed: number = 0,
) {
  const key = `${uid}:${attrs.taskId}`;

  if (succeed === 0 && failed === 0 && total > 0) {
    await admin.firestore()
      .collection('_jobs')
      .doc(key)
      .set({
        uid,
        total,
        succeed,
        failed,
        createdAt: Date.now(),
      })
      .catch(console.error);
    return;
  }

  const updates: { [key: string]: any } = {
    'total': total,
    'succeed': succeed,
    'failed': failed,
  };

  if ((succeed + failed) === total && total > 0) {
    updates['finishedAt'] = Date.now();
  }

  await admin.firestore()
    .collection('_jobs')
    .doc(key)
    .update(updates)
    .catch(console.error);
}
