export const SUBMIT_SUCCESS = 'submitsuccess';

export class SubmitSuccessEvent extends CustomEvent {
    constructor(detail) {
        super(SUBMIT_SUCCESS, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}