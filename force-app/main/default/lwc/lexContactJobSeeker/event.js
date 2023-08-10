export const CLOSE = "close";
export const SENT = "sent";

export class CloseEvent extends CustomEvent {
	constructor() {
		super(CLOSE, {
			cancelable: true,
			bubbles: true,
			composed: true
		});
	}
}

export class SentEvent extends CustomEvent {
	constructor() {
		super(SENT, {
			cancelable: true,
			bubbles: true,
			composed: true
		});
	}
}