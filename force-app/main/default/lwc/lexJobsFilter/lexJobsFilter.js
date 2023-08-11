import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

import { SearchJob } from './event.js';

import searchJobs from '@salesforce/apex/LEXMyJobsController.searchJobs';

export default class LexJobsFilter extends LightningElement {
	@api filterOptions;
	@api uniqueFields;
	@api labels;
	@api accountId;
	selectedFilter = 'All Jobs';
	appliedFilterMap = {};
	keyword = '';

	loading = true;
	saving = false;

	// * SETS PROPERTIES ON COMPONENT LOAD
	connectedCallback() {
		this.loading = true;
		searchJobs({
			keyword: '',
			filterMap: this.appliedFilterMap,
			uniqueFields: this.uniqueFields,
			filterFields: this.labels.filterField,
			accountId: this.accountId,
		})
			.then((r) => {
				this.dispatchEvent(new SearchJob({ searchedJobs: r }));
				this.loading = false;
			})
			.catch((e) => {
				this.loading = false;
				this.showToast(this.labels.errorTitle, e.body.message, 'error');
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

	// # HANDLERS

	// * SETS THE SEARCH KEYWORD ON INPUT CHANGE
	changeKeywordInput(e) {
		let value = e.target.value;
		this.keyword = value;
	}

	// * CALLS THE CLICK SEARCH BTN METHOD WHEN ENTER IS PRESSED
	pressEnterKey(e) {
		if (e.keyCode === 13) {
			this.clickSearchBtn();
		}
	}

	// * HANDLE SEARCHING FOR JOBS
	@api clickSearchBtn() {
		this.loading = true;
		searchJobs({
			keyword: this.keyword,
			filterMap: this.appliedFilterMap,
			uniqueFields: this.uniqueFields,
			filterFields: this.labels.filterField,
			accountId: this.accountId,
		})
			.then((r) => {
				this.dispatchEvent(new SearchJob({ searchedJobs: r }));
				this.loading = false;
			})
			.catch((e) => {
				this.loading = false;
				this.showToast(this.labels.errorTitle, e.body.message, 'error');
			});
	}

	// * HANDLE CLEARING FILTERS
	clickClearBtn() {
		[...this.template.querySelectorAll('lightning-combobox')].forEach((lcb) => {
			lcb.value = null;
		});
		[...this.template.querySelectorAll('lightning-input')].forEach((li) => {
			li.value = '';
		});
		this.appliedFilterMap = null;
		this.keyword = '';
		this.clickSearchBtn();
	}

	// * HANDLE FILTER APPLICATIONS
	changeFilterValue(e) {
		this.appliedFilterMap = {
			...this.appliedFilterMap,
			[e.target.name]: e.target.value,
		};
	}

	// # GETTERS/SETTERS

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loading || this.saving) {
			return true;
		}
		return false;
	}

	// * GET FILTER BUTTONS
	get filters() {
		return this.filterOptions;
	}

	// * RETURNS TRUE FOR MOBILE DEVICE TYPES
	get isMobile() {
		return FORM_FACTOR === 'Small';
	}
}