export const REGISTER = 'register';
export const WATCH = 'watch';

export class RegisterEvent extends CustomEvent {
    constructor(detail) {
        super(REGISTER, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}

export class WatchEvent extends CustomEvent {
    constructor(detail) {
        super(WATCH, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}