/* eslint-disable no-unused-vars */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

import { SubmitSuccessEvent } from './event.js';

import LexJobDetails from 'c/lexJobDetails';
import LexJobEditModal from 'c/lexJobEditModal';

export default class LexJobTile extends LightningElement {
	@api accountId;
	@api record;
	@api fields;
	@api viewFields;
	@api editFields;
	@api labels;

	@track data = [];

	loading = true;
	saving = false;

	// * BUILDS DATA ARRAY PROPERTY ON COMPONENT LOAD
	connectedCallback() {
		this.fields.forEach((field) => {
			let value;
			if (!field.fieldApiName.includes('.')) {
				value = this.record[field.fieldApiName];
			} else {
				const tempArray = field.fieldApiName.split('.');
				value = this.record[tempArray[0]][tempArray[1]];
			}
			this.data.push({
				name: field.fieldApiName,
				label: field.fieldLabel,
				type: field.fieldType,
				required: field.required,
				value,
			});
		});
		this.loading = false;
	}

	// # PRIVATE METHODS

	// * DISPLAY A TOAST MESSAGE
	showToast(title, msg, variant, mode = 'dismissible') {
		const event = new ShowToastEvent({
			title: title,
			message: msg,
			variant: variant,
			mode: mode,
		});
		this.dispatchEvent(event);
	}

	// # HANDLERS

	// * OPENS THE VIEW DETAILS MODAL AND CLICK OF VIEW DETAILS BUTTON
	async clickViewDetailsBtn() {
		const r = await LexJobDetails.open({
			size: 'medium',
			accountId: this.accountId,
			job: this.record,
			jobId: this.record.Id,
			fields: this.viewFields,
			editFields: this.editFields,
			labels: this.labels,
			onrefreshapex: () => {
				this.dispatchEvent(new SubmitSuccessEvent());
			},
		});
	}

	// * OPENS THE EDIT JOB MODAL IN "EDIT" MODE ON CLICK OF THE EDIT JOB BUTTON. ON SUCCESSFUL RECORD SUBMISSION DISPATCHES A CUSTOM SUBMIT SUCCESS EVENT
	async clickEditJobBtn() {
		const r = await LexJobEditModal.open({
			size: 'medium',
			accountId: this.accountId,
			job: this.record,
			jobId: this.record.Id,
			fields: this.editFields,
			labels: this.labels,
			mode: 'edit',
			onsuccess: (e) => {
				e.stopPropagation();
				this.dispatchEvent(new SubmitSuccessEvent());
			},
		});
	}

	// # GETTERS/SETTERS

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loading || this.saving) {
			return true;
		}
		return false;
	}

	// * SETS THE TITLE OF THE TILE TO THE FIRST ITEM IN THE DATA ARRAY PROPERTY
	get title() {
		return this.data !== undefined ? this.data[0].value : '';
	}

	// * SETS THE SUBHEADER OF THE TILE TO THE SECOND ITEM IN THE DATA ARRAY PROPERTY
	get subTitle() {
		return this.data !== undefined ? this.data[1].value : '';
	}

	// * SETS THE DETAILS FIELDS OF THE TILE TO THE REMAINING ITEMS OF THE DATA ARRAY PROPERTY
	get details() {
		return this.data !== undefined && this.data.length > 2 ? this.data.slice(2) : [];
	}

	// * SETS THE TILE CSS CLASSES BASED ON DEVICE SIZE
	get jobContainerCSS() {
		return FORM_FACTOR !== 'Large'
			? 'desc-container-mobile slds-var-p-vertical_large slds-var-p-horizontal_large'
			: 'desc-container slds-p-vertical_large slds-p-horizontal_large';
	}

	// * SETS THE HEADER COLOR IF SUPPLIED OTHERWISE SETS DEFAULT COLOR
	get headerCSS() {
		return this.labels && this.labels.jobTileHeaderColor ? 'background-color:' + this.labels.jobTileHeaderColor : 'background-color:rgb(235, 235, 235)';
	}

	// * SETS THE FOOTER COLOR IF SUPPLIED OTHERWISE SETS THE DEFAULT COLOR
	get footerCSS() {
		return this.labels && this.labels.jobTileFooterColor ? 'background-color:' + this.labels.jobTileFooterColor : 'background-color:rgb(180, 188, 201)';
	}
}