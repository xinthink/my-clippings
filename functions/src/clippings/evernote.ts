import * as Evernote from 'evernote';
import { nbind } from 'q';

// type EvernoteAuth = {
//   provider: string,
//   token: string,
// };

export default class EvernoteTool {
  private client: Evernote.Client;
  private noteStore: Evernote.NoteStoreClient;

  constructor(token: string, config: any) {
    const evernoteCfg = {
      ...config,
      token,
    };
    this.client = new Evernote.Client(evernoteCfg);
    this.noteStore = this.client.getNoteStore();
  }

  /** Create a note from the given clipping */
  async createNote(clipping: Clipping) {
    const note = new Evernote.Note({
      tagNames: normalizeTags(['Kindle', clipping.book, clipping.author]),
      content: `<?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
      <en-note>
        <p><![CDATA[${clipping.text}]]></p>
        <br/>
        <p><![CDATA[${clipping.book} ${clipping.author}]]</p>
      </en-note>
      `,
    });

    await nbind(this.noteStore.createNote, this.noteStore)(note);
  }
}

// function normalizeName(name: string): string {
//   return name.replace(/,/g, '﹒');
// }

function normalizeTags(tags: string[]): string[] {
  return tags.map(t => {
    let tag = t.replace(/,/g, ' ');
    tag = tag.replace(/\s+/g, ' ');
    return tag;
  });
}
