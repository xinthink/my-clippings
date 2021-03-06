declare module "*.json" {
  const value: any;
  export default value;
}

type Callback<T> = (err: any, value?: T | null) => void;
type VoidCallback = (err?: any) => void;

type Clipping = {
  text: string,
  timestamp: string,
  book: string,
  author: string,
  meta: string,
};

type ClippingsPayload = {
  taskId: string,
  batch: number,
  uid: string,
  clippings: Array<Clipping>,
};

type AuthInfo = {
  id: string,
  provider: string,
  token: string,
};

type NullableAuthInfo = AuthInfo | undefined | null;

type NotesCreationAttrs = {
  taskId: string,
  batch: string,
  createdAt?: string,
};
