import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LexJobEditModal from 'c/lexJobEditModal';

import getJobSkills from '@salesforce/apex/LEXMyJobsController.getJobSkills';
// import deactivateJob from '@salesforce/apex/LEXMyJobsController.deactivateJob';

export default class LexJobDetails extends LightningModal {
	@api accountId;
	@api job;
	@api jobId;
	@api fields;
	@api labels;
	@api editFields;

	@track data = [];
	@track jobSkills;

	loading = true;
	saving = false;

	// * BUILDS THE DATA ARRAY PROPERTY. CALLS THE getJobSkills METHOD TO FETCH RELATED JOB SKILLS
	connectedCallback() {
		if (this.job !== undefined) {
			[...this.fields].forEach((field) => {
				let value;
				if (!field.fieldApiName.includes('.')) {
					value = this.job[field.fieldApiName];
				} else {
					const tempArray = field.fieldApiName.split('.');
					value = this.job[tempArray[0]][tempArray[1]];
				}
				this.data.push({
					name: field.fieldApiName,
					label: field.fieldLabel,
					type: field.fieldType,
					required: field.required,
					value,
				});
			});
		}
		this.getJobSkills();
	}

	// # APEX

	// * CALL APEX TO GET RELATED JOB SKILLS DATA
	getJobSkills() {
		getJobSkills({ jobId: this.jobId })
			.then((result) => {
				this.jobSkills = result.length > 0 ? result : null;
				this.loading = false;
			})
			.catch((err) => {
				// console.error('Error:', err);
				this.showToast(this.labels.errorTitle, err.body.message, 'error');
				this.loading = false;
			});
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

	// archiveJob() {
	// 	deactivateJob({ jobIds: [this.jobId] })
	// 		.then((result) => {
	// 			this.showToast(this.labels.successTitle, 'Job Archived.', 'success');
	// 			this.dispatchEvent(new CustomEvent('refreshapex'));
	// 			this.close();
	// 		})
	// 		.catch((err) => {
	// 			this.showToast(this.labels.errorTitle, err.body.message, 'error');
	// 		});
	// }

	// # HANDLERS

	// * CLOSES THE MODAL AND RETURNS JOB AND SKILL DATA
	clickBackBtn() {
		this.close({
			job: this.data,
			jobId: this.jobId,
			skill: this.jobSkills,
		});
	}

	// // * CALLS THE archiveJob METHOD
	// clickArchiveBtn() {
	// 	this.archiveJob();
	// }

	// * CALLS THE EDIT/CREATE MODAL LWC IN EDIT MODE. ON CUSTOM REFRESH APEX EVENT CALLS THE getJobSkills METHOD TO FETCH UPDATED JOB SKILLS.
	async clickEditBtn() {
		const r = await LexJobEditModal.open({
			size: 'medium',
			accountId: this.accountId,
			job: this.job,
			jobId: this.jobId,
			fields: this.editFields,
			labels: this.labels,
			mode: 'edit',
			onrefreshapex: () => {
				this.dispatchEvent(new CustomEvent('refreshapex'));
				this.clickBackBtn();
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

	// * RETURNS THE FIRST ITEM IN THE SET OF DATA TO USE AS A TITLE
	get title() {
		return this.data !== undefined ? this.data[0].value : '';
	}

	// * RETURNS THE SECOND ITEM IN THE SET OF DATA TO USE A SUBTITLE
	get subTitle() {
		return this.data !== undefined ? this.data[1].value : '';
	}

	// * RETURNS THE DATA SET WITHOUT THE FIRST 2 ITEMS
	get details() {
		return this.data !== undefined && this.data.length > 2 ? this.data.slice(2) : [];
	}

	// * CHECKS FOR A MOBILE DEVICE
	get isMobile() {
		return FORM_FACTOR === 'Small';
	}

	// * SETS SKILL SIZE BASED ON DEVICE
	get selectedSkillsSize() {
		return this.isMobile ? '12' : '3';
	}

	// * SETS HEADER COLOR IF SET OR SETS DEFAULT COLOR
	get headerCSS() {
		return this.labels && this.labels.headerColor ? 'color: ' + this.labels.headerColor : 'color: rgb(84,105,141)';
	}

	// * SETS SKILL PILL CSS COLOR IF SET OR SETS DEFAULT COLOR
	get skillPillCSS() {
		return this.labels && this.labels.skillPillColor
			? 'background-color: ' + this.labels.skillPillColor + '!important'
			: 'background-color: rgb(84,105,141) !important';
	}
}