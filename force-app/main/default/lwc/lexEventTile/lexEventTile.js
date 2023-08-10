import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getDownloadLink from '@salesforce/apex/LEXEventsController.getDownloadLink';
import cancelRegisterForEvent from '@salesforce/apex/LEXEventsController.cancelRegisterForEvent';
import registerForEvent from '@salesforce/apex/LEXEventsController.registerForEvent';

import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

import { RegisterEvent, WatchEvent } from './event.js';

export default class LexEventTile extends LightningElement {
	@api event;
	@api fields;
	@api noOfFieldsAboveButton = 2;
	@api eventConfig;
	@track data = [];
	@track documents;
	@track record;
	@track isLoading = true;
	@track showTile = true;

	connectedCallback() {
		if (this.event.record !== undefined && this.fields !== undefined) {
			this.record = { ...this.event.record };
			this.fields.forEach((field) => {
				var value;
				let fieldVal;

				if (!field.fieldApiName.includes('.')) {
					if (field.fieldApiName === 'Launchpad__Workshop_Topics__c') {
						fieldVal = this.record[field.fieldApiName].replaceAll(';', '; ');
					} else {
						fieldVal = this.record[field.fieldApiName];
					}
				} else {
					const tempArray = field.fieldApiName.split('.');
					if (this.record[tempArray[0]]) {
						fieldVal = this.record[tempArray[0]][tempArray[1]];
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

			this.data = [...this.data];

			getDownloadLink({ eventId: this.event.record.Id })
				.then((resp) => {
					if (resp) {
						this.documents = resp;
						this.isLoading = false;
					}
					this.isLoading = false;
				})
				.catch((error) => {
					this.isLoading = false;
					this.showNotification(this.label.errorTitle, error.body.message, 'error');
				});
		} else {
			this.isLoading = false;
			this.showTile = false;
		}
	}

	handleDownloadDocuments() {
		for (let i = 0; i < this.documents.length; i++) {
			window.open(this.documents[i], '_blank');
		}
	}

	handleRegister() {
		this.dispatchEvent(new RegisterEvent({ eventData: this.event }));
	}

	handleViewDetail() {
		this.dispatchEvent(new RegisterEvent({ eventData: this.event }));
	}

	handleWatchVideo() {
		this.isLoading = true;
		registerForEvent({ eventId: this.event.record.Id })
			.then((resp) => {
				if (resp) {
					this.isLoading = false;
					this.dispatchEvent(new WatchEvent({ recordId: this.event.record.Id }));
				}
			})
			.catch((error) => {
				this.isLoading = false;
				this.showNotification(this.label.errorTitle, error.body.message, 'error');
			});
	}

	handleCancelRegister() {
		this.isLoading = true;
		cancelRegisterForEvent({ eventId: this.event.record.Id })
			.then((resp) => {
				if (resp) {
					this.showNotification(this.label.successTitle, this.eventConfig.cancellationMessage, 'success');
					window.location.href = this.eventConfig.cancelRegistrationRedirectUrl;
					this.isLoading = false;
				}
			})
			.catch((error) => {
				this.isLoading = false;
				this.showNotification(this.label.errorTitle, error.body.message, 'error');
			});
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
		return this.data.length ? this.data[0].value : '';
	}

	get subTitle() {
		return this.data.length ? this.data[1].value : '';
	}

	get details() {
		return this.data && this.data.length > 2 ? this.data.slice(2, this.noOfFieldsAboveButton) : [];
	}

	get footerDetails() {
		return this.data && this.data.length > this.noOfFieldsAboveButton ? this.data.slice(this.noOfFieldsAboveButton) : [];
	}

	get isRegisteredView() {
		return window.location.href.includes('my-registered-events');
	}

	get label() {
		return {
			successTitle,
			errorTitle,
		};
	}

	get headerCSS() {
		return this.eventConfig && this.eventConfig.eventTileHeaderColor
			? 'background-color:' + this.eventConfig.eventTileHeaderColor
			: 'background-color:rgb(235, 235, 235)';
	}

	get footerCSS() {
		return this.eventConfig && this.eventConfig.eventTileFooterColor
			? 'background-color:' + this.eventConfig.eventTileFooterColor
			: 'background-color:rgb(180, 188, 201)';
	}
}