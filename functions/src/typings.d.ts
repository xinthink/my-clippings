import { Client } from "@grpc/grpc-js";

type Callback<T> = (err: any, value?: T | null) => void;
type VoidCallback = (err?: any) => void;

declare module "*.json" {
  const value: any;
  export default value;
}

declare module "passport-evernote";

declare module "evernote" {
  export default Evernote;
  export type Client = any;
  export type NoteStore = any;
}

type Clipping = {
  text: string,
  timestamp: string,
  book: string,
  author: string,
};

type ClippingsPayload = {
  uid: string,
  clippings: Array<Clipping>,
};

type AuthInfo = {
  id: string,
  provider: string,
  token: string,
};

type NullableAuthInfo = AuthInfo | undefined | null;
