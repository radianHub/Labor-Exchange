// * SALESFORCE IMPORTS
import { LightningElement, track, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// * CONTROLLERS
// import getSetupData from '@salesforce/apex/LEXCandidateApplicationsController.getSetupData';
import getJobData from '@salesforce/apex/LEXCandidateApplicationsController.getJobData';

// * CUSTOM EVENTS
import { /*UpdateRequestEvent,*/ RefreshApexEvent } from './event.js';

// * CUSTOM LABELS
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

// * CUSTOM MODALS
import LexJobEditModal from 'c/lexJobEditModal';
import LexApplicationEditModal from 'c/lexApplicationEditModal';
import LexCandidateEmailModal from 'c/lexCandidateEmail';

export default class LEXCandidateApplications extends LightningElement {
	@api config;
	@api applicationType;
	@api applicationData;
	@api myApplicationFields;

	@track newApplications;
	@track pendingApplications;
	@track processedApplications;
	@track loadingData = false;

	newApplicationsCount;
	pendingApplicationsCount;
	processedApplicationsCount;

	applicationsFound = false;

	renderedCallback() {
		if (this.applicationData) {
			this.applicationsFound = Object.keys(this.applicationData).length === 0 ? false : true;
		}
	}

	// # PRIVATE METHODS

	// * DISPLAYS A TOAST NOTIFICATION
	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	// * OPENS THE JOB EDIT MODAL
	async jobEdit(jobData, modalType) {
		const r = await LexJobEditModal.open({
			size: 'medium',
			accountId: jobData.accountId,
			job: jobData.job,
			jobId: jobData.jobId,
			fields: jobData.jobFields,
			labels: this.modalLabels,
			createOrEdit: modalType,
		});
	}

	// * OPENS THE APPLICATION EDIT MODAL
	async applicationModal(appData, jobData) {
		const r = await LexApplicationEditModal.open({
			size: 'medium',
			application: appData,
			job: jobData,
			labels: this.modalLabels,
			isDesktop: this.isDesktop,
			config: this.config,
			// onupdaterequest: (e) => {
			// 	this.dispatchEvent(new UpdateRequestEvent({ recordId: e.detail }));
			// },
			onrefreshapex: () => {
				this.dispatchEvent(new RefreshApexEvent());
			},
		});
	}

	// # HANDLERS

	// * OPENS THE CONTACT JOB SEEKER MODAL
	handleEmailCandidate(event) {
		LexCandidateEmailModal.open({
			label: 'Contact Info',
			size: 'small',
			candidateId: event.target.dataset.contactId,
			config: this.config,
		})
			.then((result) => {})
			.catch((error) => {
				console.log('handleEmailCandidate error: ' + error);
			});
	}

	// * FIRES THE CUSTOM REFRESH APEX EVENT
	handleRefreshApex() {
		this.dispatchEvent(new RefreshApexEvent());
	}

	// * ON CLICK OF THE JOB NAME FIRES THE jobEdit METHOD
	clickJobNameBtn(e) {
		getJobData({ appId: e.target.value })
			.then((result) => {
				this.jobEdit(result, 'edit');
			})
			.catch((err) => {
				console.log(err);
			});
	}

	// * ON CLICK OF THE APP NUMBER FIRES THE applicationModal METHOD
	clickAppNumberBtn(e) {
		let key = e.target.value;
		let app = [...this.applicationData].filter((data) => data.key === key);
		getJobData({ appId: e.target.value })
			.then((result) => {
				this.applicationModal(app[0], result);
			})
			.catch((err) => {
				this.applicationModal(app[0], null);
			});
	}

	// # GETTERS

	// * GETS LABELS
	get label() {
		return {
			errorTitle,
		};
	}

	// * GETS DEVICE TYPE
	get isDesktop() {
		return FORM_FACTOR === 'Large';
	}

	// * DISPLAYS THE BUTTON COLUMN IS SETUP IN THE COMPONENT PROPERTIES
	get showButtonColumn() {
		return this.config && (this.config.showRedirectButton || this.config.showContactUsButton);
	}

	// * SETS THE HEADER COLOR IF NO COLOR HAS BEEN SET IN THE COMPONENT PROPERTIES
	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}

	// * RETURNS TRUE IF LOAD OR SAVING
	get isLoading() {
		if (this.loadingData) {
			return true;
		}
		return false;
	}

	// * GETS FIELD TYPE FOR APPLICATION DATA
	get applicationFields() {
		let rowData;
		if (this.applicationData != null) {
			rowData = this.applicationData.map((row) => {
				let tempArray = row.details.map((field) => {
					let isJobName = false;
					let isAppNumber = false;
					let isStandardField = false;
					// ! HARDCODED FOR TESTING, DYNAMICALLY FETCH FRM CONFIG
					if (field.fieldApiName === 'Launchpad__Job_Order__r.Name') {
						isJobName = true;
					} else if (field.fieldApiName === 'Name') {
						isAppNumber = true;
					} else {
						isStandardField = true;
					}
					return {
						...field,
						isJobName,
						isAppNumber,
						isStandardField,
					};
				});
				return {
					...row,
					details: tempArray,
				};
			});
			return rowData;
		}
	}

	// * GETS CONFIG DETAILS FOR MODALS
	get modalLabels() {
		return {
			...this.config,
			editJobHeader: 'Edit Job',
			editJobObjName: 'Launchpad__Job__c',
			appObjName: 'Launchpad__Applicant_Tracking__c',
			cancelBtnLabel: 'Close',
			saveBtnLabel: 'Save',
			editBtnLabel: 'Edit',
			successTitle: 'Success',
			errorTitle: 'Error',
			editSaveMsg: 'Job successfully updated!',
		};
	}
}