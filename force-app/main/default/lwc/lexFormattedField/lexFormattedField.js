import { LightningElement, api } from 'lwc';

export default class LEXFormattedField extends LightningElement {
	@api field;
	regex = /^\d{2}[:]\d{2}[:]\d{2}[.]\d{3}[Z]$/;

	get isText() {
		return (
			this.field !== undefined &&
			(this.field.type === 'STRING' || this.field.type === 'PICKLIST' || this.field.type === 'MULTIPICKLIST') &&
			this.time === null
		);
	}

	get isTextArea() {
		return this.field !== undefined && this.field.type === 'TEXTAREA';
	}

	get isDate() {
		return this.field !== undefined && this.field.type === 'DATE';
	}

	get isDateTime() {
		return this.field !== undefined && this.field.type === 'DATETIME';
	}

	get isDecimal() {
		return this.field !== undefined && this.field.type === 'DOUBLE';
	}

	get isCurrency() {
		return this.field !== undefined && this.field.type === 'CURRENCY';
	}

	get isPercent() {
		return this.field !== undefined && this.field.type === 'PERCENT';
	}

	get isTime() {
		return this.field !== undefined && (this.field.type === 'TIME' || (this.field.type === 'STRING' && !!this.field.value.match(this.regex)));
	}

	get time() {
		if (this.field.value !== undefined && this.field.type === 'STRING' && !!this.field.value.match(this.regex)) {
			var thisTime = this.field.value.split(':');
			var suffix = thisTime[0] >= 12 ? 'PM' : 'AM';
			var hour = thisTime[0] > 12 ? parseInt(thisTime[0] - 12) : parseInt(thisTime[0]);
			var min = thisTime[1];
			var newTime = hour + ':' + min + ' ' + suffix;

			return newTime;
		}
		return null;
	}

	get isUrl() {
		return this.field !== undefined && this.field.type === 'URL';
	}

	get isPhone() {
		return this.field !== undefined && this.field.type === 'PHONE';
	}

	get isEmail() {
		return this.field !== undefined && this.field.type === 'EMAIL';
	}

	get isCheckbox() {
		return this.field !== undefined && this.field.type === 'BOOLEAN';
	}
}