import { LightningElement, api, track } from 'lwc';

// * CUSTOM EVENTS
import { /*UpdateRequestEvent,*/ RefreshApexEvent } from './event.js';

// * CUSTOM LABELS
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// * CONTROLLERS
import getJobData from '@salesforce/apex/LEXCandidateApplicationsController.getJobData';

// * CUSTOM MODALS
import LexJobEditModal from 'c/lexJobEditModal';
import LexApplicationEditModal from 'c/lexApplicationEditModal';
import LexCandidateEmailModal from 'c/lexCandidateEmail';

export default class pcApplicationTile extends LightningElement {
	@api record;
	@api config;
	@api fields;
	@api isDesktop;
	@api contactId;

	recordId;

	@track data = [];
	@track isLoading = false;

	// # LIFECYCLE HOOKS

	// * SETUP INCOME DATA
	connectedCallback() {
		if (!this.isDesktop) {
			this.recordId = this.record.key;
			this.data = this.record.details.map((field) => {
				return {
					label: field.label,
					name: field.fieldApiName,
					type: field.type,
					value: field.value,
					isStandardField: field.isStandardField,
					isAppNumber: field.isAppNumber,
					isJobName: field.isJobName,
				};
			});
		} else {
			// Loop through the fields array
			this.fields.forEach((field) => {
				let value;
				// If the field is not cross object, set the value directly
				if (!field.fieldApiName.includes('.')) {
					value = this.record[field.fieldApiName];
				} else {
					const tempArray = field.fieldApiName.split('.');
					value = this.record[tempArray[0]][tempArray[1]];
				}
				this.data.push({
					label: field.fieldLabel,
					type: field.fieldType,
					value,
					isStandardField: true,
					isJobName: false,
					isAppNumber: false,
				});
			});
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

	// * FIRES THE CUSTOM UPDATE REQUEST EVENT
	// handleUpdateRequest() {
	// 	this.dispatchEvent(new UpdateRequestEvent({ recordId: this.record.Id }));
	// }
	handleEmailCandidate() {
		LexCandidateEmailModal.open({
			label: 'Contact Info',
			size: 'small',
			candidateId: this.contactId,
			config: this.config,
		})
			.then((result) => {})
			.catch((error) => {
				console.log('handleEmailCandidate error: ' + error);
			});
	}

	// * GET JOB DATA AND PASSES ALONG DATA TO APPLICATION EDIT MODAL
	clickAppNumberLink() {
		getJobData({ appId: this.recordId })
			.then((result) => {
				this.applicationModal(this.record, result);
			})
			.catch((err) => {
				this.applicationModal(this.record, null);
			});
	}

	// * GETS JOB DATA AND PASSES ALONG DATA TO JOB EDIT MODAL
	clickJobNameLink() {
		getJobData({ appId: this.recordId })
			.then((result) => {
				this.jobEdit(result, 'edit');
			})
			.catch((err) => {
				console.log(err);
			});
	}

	// # GETTERS/SETTERS

	// * GETS THE FIRST ITEM OF THE DATA ARRAY TO USE A TITLE
	get title() {
		return this.data !== undefined ? this.data[0] : undefined;
	}

	// * GETS ALL DATA MINUS THE FIRST ITEM TO USE ON A TILE
	get details() {
		return this.data !== undefined && this.data.length > 1 ? this.data.slice(1) : [];
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
			successTitle: 'Success',
			errorTitle: 'Error',
			editSaveMsg: 'Job successfully updated!',
		};
	}
}