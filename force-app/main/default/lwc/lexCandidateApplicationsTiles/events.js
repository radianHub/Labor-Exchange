export const APPLICATIONS_TILE_CLICKED = 'applicationstileclicked';

export class ApplicationsTileClickedEvent extends CustomEvent {
	constructor(applicationType, applicationData, myApplicationFields) {
		super(APPLICATIONS_TILE_CLICKED, {
			detail: {
				applicationType,
				applicationData,
				myApplicationFields,
			},
			cancelable: true,
			bubbles: true,
			composed: true,
		});
	}
}