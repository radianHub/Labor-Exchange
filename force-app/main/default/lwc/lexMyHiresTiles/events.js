export const HIRES_TILE_CLICKED = 'hirestileclicked';

export class HiresTileClickedEvent extends CustomEvent {
	constructor(hiresData, hireFields) {
		super(HIRES_TILE_CLICKED, {
			detail: {
				hiresData,
				hireFields,
			},
			cancelable: true,
			bubbles: true,
			composed: true,
		});
	}
}