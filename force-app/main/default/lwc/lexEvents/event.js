export const REGISTRATION = 'registration';
export const CLEAR_FILTERS = 'clearfilters';

export class RegistrationEvent extends CustomEvent {
	constructor(detail) {
		super(REGISTRATION, {
			detail,
			cancelable: true,
			bubbles: true,
			composed: true,
		});
	}
}

export class ClearFiltersEvent extends CustomEvent {
	constructor() {
		super(CLEAR_FILTERS, {
			cancelable: true,
			bubbles: true,
			composed: true,
		});
	}
}