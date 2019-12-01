import * as Evernote from 'evernote';
import xcape = require("xml-escape");

const { Limits, Types } = Evernote;

// type EvernoteAuth = {
//   provider: string,
//   token: string,
// };

export default class EvernoteTool {
  private readonly client: Evernote.Client;
  private readonly noteStore: Evernote.NoteStoreClient;

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
    const note = new Types.Note({
      title: normalizeNoteTitle(clipping.book),
      tagNames: normalizeTags(['Kindle', clipping.book, clipping.author]),
      content: `<?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
      <en-note>
        <p>${xcape(clipping.meta)}</p>
        <br/>
        <p>${normalizeNoteText(xcape(clipping.text))}</p>
        <br/>
        <p>${xcape(clipping.book)} ${xcape(clipping.author)}</p>
      </en-note>
      `,
    });

    await this.noteStore.createNote(note);
  }
}

// function normalizeName(name: string): string {
//   return name.replace(/,/g, '﹒');
// }

function normalizeTags(tags: string[]): string[] {
  return tags
    .filter(t => t.match(Limits.EDAM_TAG_NAME_REGEX))
    .map(t => {
      let tag = t.replace(/,/g, ' ');
      tag = tag.replace(/\s+/g, ' ');
      if (tag.length > Limits.EDAM_TAG_NAME_LEN_MAX) {
        tag = tag.slice(0, Limits.EDAM_TAG_NAME_LEN_MAX - 1) + '…';
      }
      return tag;
    });
}

function normalizeNoteText(text: string): string {
  return text.replace(/(\r?\n)/g, '<br/>');
}

function normalizeNoteTitle(title: string): string {
  if (!title.match(Limits.EDAM_NOTE_TITLE_REGEX)) return "Untitled";
  else return title.length <= Limits.EDAM_NOTE_TITLE_LEN_MAX ? title
    : title.slice(0, Limits.EDAM_NOTE_TITLE_LEN_MAX - 1) + '…';
}
