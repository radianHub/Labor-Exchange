export const PAGE_CHANGE = 'pagechange';

export class PageChangeEvent extends CustomEvent {
	constructor(detail) {
		super(PAGE_CHANGE, {
			detail,
			cancelable: true,
			bubbles: true,
			composed: true,
		});
	}
}