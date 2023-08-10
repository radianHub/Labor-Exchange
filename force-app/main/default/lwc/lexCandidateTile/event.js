export const VIEW = "view";

export class ViewEvent extends CustomEvent {
	constructor(detail) {
		super(VIEW, {
			detail,
			cancelable: true,
			bubbles: true,
			composed: true
		});
	}
}