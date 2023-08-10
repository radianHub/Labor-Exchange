import { LightningElement, api, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import registerForEvent from '@salesforce/apex/LEXEventsController.registerForEvent';

import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

export default class LEXEventConfirmation extends LightningElement {
	@api event;
	@api fields;
	@api eventConfig;
	@track data = [];
	@track isLoading = true;

	connectedCallback() {
		if (this.event !== undefined) {
			this.fields.forEach((field) => {
				var value;
				let fieldVal;
				if (!field.fieldApiName.includes('.')) {
					fieldVal = this.event[field.fieldApiName];
				} else {
					const tempArray = field.fieldApiName.split('.');
					if (this.event[tempArray[0]]) {
						fieldVal = this.event[tempArray[0]][tempArray[1]];
					}
				}

				// Empty Time field returns "Z" instead of blank
				value = fieldVal !== 'Z' ? fieldVal : '';

				this.data.push({
					label: field.fieldLabel,
					type: field.fieldType,
					value,
				});
			});
			this.isLoading = false;
		}
	}

	handleRegister() {
		this.isLoading = true;
		registerForEvent({
			eventId: this.event.Id,
		})
			.then((resp) => {
				if (resp) {
					this.showNotification(this.label.successTitle, this.eventConfig.registerEventSuccessMessage, 'success');
					this.isLoading = false;
					window.location.href = this.eventConfig.registerEventRedirectUrl;
					this.dispatchEvent(new CustomEvent('close', { bubbles: true }));
				}
			})
			.catch((error) => {
				this.isLoading = false;
				this.showNotification(this.label.errorTitle, error.body.message, 'error');
			});
	}

	handleClose() {
		this.dispatchEvent(new CustomEvent('close', { bubbles: true }));
	}

	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	get title() {
		return this.data !== undefined ? this.data[0].value : '';
	}

	get subTitle() {
		return this.data !== undefined ? this.data[1].value : '';
	}

	get details() {
		return this.data !== undefined && this.data.length > 2 ? this.data.slice(2) : [];
	}

	get label() {
		return {
			successTitle,
			errorTitle,
		};
	}

	get isRegisteredView() {
		return window.location.href.includes('my-registered-events');
	}

	get headerCSS() {
		return this.eventConfig && this.eventConfig.headerColor ? 'color:' + this.eventConfig.headerColor : 'color:rgb(84, 105, 141)';
	}
}