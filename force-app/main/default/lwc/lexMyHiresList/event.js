export const UPDATE_REQUEST = 'updaterequest';

export class UpdateRequestEvent extends CustomEvent {
	constructor(detail) {
		super(UPDATE_REQUEST, {
			detail,
			cancelable: true,
			bubbles: true,
			composed: true,
		});
	}
}