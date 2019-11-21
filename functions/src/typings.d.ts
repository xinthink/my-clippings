type Callback<T> = (err: any, value?: T | null) => void;
type VoidCallback = (err?: any) => void;

declare module "*.json" {
  const value: any;
  export default value;
}

declare module "passport-evernote";
