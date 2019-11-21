import { Strategy } from 'passport-evernote';
import { assoc } from 'ramda';

export type Options = {
  consumerKey: string,
  consumerSecret: string,
  callbackURL: string,
}

export type Verifier = (token: string, tokenSecret: string, profile: any, cb: Callback<any>) => void;

/**
 * Passport strategy for Yinxiang Note.
 */
export class YinxiangStrategy extends Strategy {
  /**
   * `Strategy` constructor.
   */
  constructor(options: Options, verify: Verifier) {
    super(options, verify);
    this.name = 'yinxiang';
  }

  /**
   * Retrieve user profile from Evernote.
   * @override
   * @protected
   */
  userProfile(token: string, tokenSecret: string, params: any, cb: Callback<any>) {
    return super.userProfile(token, tokenSecret, params, (err: any, profile: any) =>
      cb(err, assoc('provider', this.name, profile))
    );
  }
}
