import * as functions from 'firebase-functions';
import { Attributes } from "@google-cloud/pubsub";

import config from '../local';
import { createNotes } from './importer';

// const env = process.env.NODE_ENV;
// const isProd = 'production' === env; // if it's production env

// Clippings sync task, triggered by PubSub message
export const importClippings = functions
  .runWith({
    timeoutSeconds: 540,
  })
  .region('asia-northeast1')
  .pubsub.topic(config.pubsub.importTopic)
  .onPublish(msg => doImportClippings(msg.json, msg.attributes));

/** Import clippings to user's Evernote account */
async function doImportClippings(payload: ClippingsPayload, attrs: Attributes) {
  // console.log('message received', payload, attrs);
  await createNotes(payload || {}, <NotesCreationAttrs>attrs);
}

// // local test only
// if (!isProd) {
//   // @ts-ignore
//   exports.importClippingsJson = functions
//     .region('asia-northeast1')
//     .https.onCall(doImportClippings);
// }
