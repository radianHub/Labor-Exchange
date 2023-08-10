import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';

import LexJobEditModal from 'c/lexJobEditModal';

import getJobData from '@salesforce/apex/LEXMyJobsController.getJobData';

export default class LexMyJobs extends LightningElement {
	@api config;

	@track searchedJobs;

	wiredDataResult;
	accountId;
	myJobs;
	jobTileFields;
	jobViewDetailsFields;
	jobEditFields;
	filterOptions;
	uniqueFields;
	currentPage = 1;
	noOfTiles = 6;

	loading = true;
	saving = false;

	// # APEX

	// * GETS DATA FOR LWC
	@wire(getJobData, { filterField: '$config.filterField' })
	wiredData(r) {
		this.wiredDataResult = r;
		if (r.data) {
			this.myJobs = r.data.myJobs;
			this.jobTileFields = r.data.jobTileFields;
			this.jobViewDetailsFields = r.data.jobViewDetailsFields;
			this.jobEditFields = r.data.jobCreateEditFields;
			this.noOfTiles = r.data.noOfTilesPerPage;
			this.uniqueFields = r.data.uniqueFields;
			this.filterOptions = r.data.filter;
			this.accountId = r.data.accountId;
			this.loading = false;
		} else if (r.error) {
			this.showToast(this.labels.errorTitle, r.error.body.message, 'error');
			this.loading = false;
		}
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

	// * SETS THE SEARCHED JOBS PROPERTY ON A CUSTOM SEARCH EVENT
	customSearchEvent(e) {
		this.searchedJobs = e.detail.searchedJobs.length > 0 ? e.detail.searchedJobs : false;
	}

	// * SETS THE CURRENT PAGE ON A CUSTOM PAGE CHANGE EVENT
	customPageChange(e) {
		this.currentPage = e.detail.page;
		this.template.querySelector(`[data-id="jobs]`).scrollIntoView();
	}

	// * OPENS THE JOB EDIT MODAL IN "CREATE" MODE. CALLS THE successfulJobEdit METHOD ON SUCCESSFUL RECORD SUBMISSION
	async clickNewJobBtn() {
		const r = await LexJobEditModal.open({
			size: 'medium',
			accountId: this.accountId,
			job: undefined,
			jobId: undefined,
			fields: this.jobEditFields,
			labels: this.labels,
			mode: 'create',
			onsuccess: () => {
				this.successfulJobEdit();
			},
		});
	}

	// * REFRESHES JOB DATA CALLS THE CLICK SEARCH BUTTON METHOD FROM THE JOBS FILTER COMPONENT
	successfulJobEdit() {
		refreshApex(this.wiredDataResult);
		this.template.querySelector('c-lex-jobs-filter').clickSearchBtn();
		this.dispatchEvent(new CustomEvent('refreshcomponent'));
	}

	// # GETTERS/SETTERS

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loading || this.saving) {
			return true;
		}
		return false;
	}

	// * EXTENDS THE CONFIG CLASS
	get labels() {
		const label = {
			successTitle,
			errorTitle,
		};
		return {
			...label,
			...this.config,
		};
	}

	// * SETS DEFAULT STYLING IF NOT SET IN COMMUNITY SETUP
	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}

	// * GETS THE TOTAL NUMBER OF JOBS RELATED TO THE ACCOUNT
	get totalJobs() {
		return this.searchedJobs !== undefined ? this.searchedJobs.length : undefined;
	}

	// * RETURNS THE AN ARRAY OF JOBS FOR A PAGE
	get jobs() {
		const jobs = this.searchedJobs;
		let jobPage = jobs.slice((this.currentPage - 1) * this.noOfTiles, this.currentPage * this.noOfTiles);
		return jobPage;
	}
}