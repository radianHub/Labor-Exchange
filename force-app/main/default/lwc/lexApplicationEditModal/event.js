export const UPDATE_REQUEST = 'updaterequest';
export const REFRESH_APEX = 'refreshapex';

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

export class RefreshApexEvent extends CustomEvent {
	constructor(detail) {
		super(REFRESH_APEX, {
			detail,
			cancelable: true,
			bubbles: true,
			composed: true,
		});
	}
}