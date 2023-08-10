import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import closeButton from '@salesforce/label/c.LEXCommunity_Close_Button';

import { ApplicationsTileClickedEvent } from './events.js';
import getSetupData from '@salesforce/apex/LEXCandidateApplicationsController.getSetupData';

export default class lexCandidateApplicationsPage extends LightningElement {
	@api config;
	applicationType = 'newApplications';

	@track isLoading = false;
	@track errorMessage;

	@track newApplications;
	@track pendingApplications;
	@track processedApplications;
	@track myApplicationFields;

	newApplicationsCount;
	pendingApplicationsCount;
	processedApplicationsCount;

	wiredSetupData;

	tile1Clicked = false;
	tile2Clicked = false;
	tile3Clicked = false;

	@track applicationData = this.getApplicationsOfType(this.applicationType);

	//* APEX

	@wire(getSetupData)
	wiredGetSetupData(result) {
		this.wiredSetupData = result;
		const { data, error } = result;
		if (data) {
			this.newApplications = data.applications.newApplicationsData;
			this.pendingApplications = data.applications.pendingApplicationsData;
			this.processedApplications = data.applications.processedApplicationsData;
			console.log('this.newApplications in lexCandidateApplicationsTiles:', JSON.parse(JSON.stringify(this.newApplications)));

			this.newApplicationsCount = data.applications.newApplicationsCount;
			this.pendingApplicationsCount = data.applications.pendingApplicationsCount;
			this.processedApplicationsCount = data.applications.processedApplicationsCount;

			this.applicationData = this.newApplications;

			this.myApplicationFields = data.applicationFields;
			this.loadingData = false;

			// Set the data to show on load
			this.handleClickTile1();

			this.dispatchEvent(
				new CustomEvent('DOMContentLoaded', {
					bubbles: true,
					cancelable: true,
				})
			);
		} else if (error) {
			console.log('ERROR FIRED AT LINE 54 of lexCandidateApplications');
			this.showNotification(this.label.errorTitle, error.body.message, 'error');
			this.loadingData = false;
		}
	}

	// * HANDLERS
	handleErrorClose() {
		this.errorMessage = undefined;
	}

	// Set tile1Clicked to true and all other tileClicked values to false
	// then fire a custom event to pass the application type "newApplications" to the parent component
	handleClickTile1() {
		this.applicationData = this.newApplications;
		console.log('Submitted (new) applicationData:', JSON.parse(JSON.stringify(this.applicationData)));
		this.handleClickTile(true, false, false, 'newApplications');
	}
	// Set tile2Clicked to true and all other tileClicked values to false
	// then fire a custom event to pass the application type "pendingApplications" to the parent component
	handleClickTile2() {
		this.applicationData = this.pendingApplications;
		this.handleClickTile(false, true, false, 'pendingApplications');
	}
	// Set tile3Clicked to true and all other tileClicked values to false
	// then fire a custom event to pass the application type "processedApplications" to the parent component
	handleClickTile3() {
		this.applicationData = this.processedApplications;
		this.handleClickTile(false, false, true, 'processedApplications');
	}

	get label() {
		return {
			closeButton,
			errorTitle,
		};
	}

	// * HELPER METHODS

	// A generic method for handling when each of the three on-screen tiles are clicked
	// at time of development, there will only ever be three tiles
	handleClickTile(tile1Clicked, tile2Clicked, tile3Clicked, applicationType) {
		this.tile1Clicked = tile1Clicked;
		this.tile2Clicked = tile2Clicked;
		this.tile3Clicked = tile3Clicked;
		this.applicationType = applicationType;
		this.applicationData = this.getApplicationsOfType(applicationType);
		this.dispatchApplicationClickedEvent();
	}

	// An additional abstraction of dispatching the event ApplicationstileClickedEvent
	dispatchApplicationClickedEvent() {
		try {
			this.dispatchEvent(new ApplicationsTileClickedEvent(this.applicationType, this.applicationData, this.myApplicationFields));
		} catch (error) {
			console.log('ERROR: ', error.body.message);
		}
	}

	// * GETTERS

	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}

	// * HELPER METHODS

	@api refresh() {
		refreshApex(this.wiredSetupData);
	}

	getApplicationsOfType(applicationType) {
		let result = [];
		switch (applicationType) {
			case 'processedApplications':
				if (this.myApplicationFields !== undefined && this.processedApplications !== undefined) {
					this.processedApplications.forEach((record) => {
						// result = { ...result, ...record };
						result = this.processApplicationData();
					});
				}
				return result;
			case 'pendingApplications':
				if (this.myApplicationFields !== undefined && this.pendingApplications !== undefined) {
					this.pendingApplications.forEach((record) => {
						// result = { ...result, ...record };
						result = this.processApplicationData();
					});
				}
				return result;

			case 'newApplications':
				if (this.myApplicationFields !== undefined && this.newApplications !== undefined) {
					this.newApplications.forEach((record) => {
						// result = { ...result, ...record };
						result = this.processApplicationData();
					});
				}
				return result;
			default:
				console.log('NO APPLICATIONS RETURNED.');
				return result;
		}
	}

	processApplicationData() {
		let result = [];

		if (this.myApplicationFields !== undefined && this.applicationData !== undefined) {
			this.applicationData.forEach((record) => {
				let recordData = [];
				console.log('record:', record);
				this.myApplicationFields.forEach((field) => {
					let value;
					if (!field.fieldApiName.includes('.')) {
						value = record[field.fieldApiName];
					} else {
						const tempArray = field.fieldApiName.split('.');
						value = record[tempArray[0]][tempArray[1]];
					}
					recordData.push({
						fieldApiName: field.fieldApiName,
						label: field.fieldLabel,
						type: field.fieldType,
						isRequired: field.required,
						value,
					});
				});
				result.push({
					key: record.Id,
					details: recordData,
					contactId: record.Launchpad__Participant__c,
				});
			});
		}
		console.log('result:', JSON.parse(JSON.stringify(result)));
		return result;
	}
}