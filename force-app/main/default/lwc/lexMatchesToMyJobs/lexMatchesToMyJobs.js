import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';

import getJobData from '@salesforce/apex/LEXMatchesToMyJobsController.getJobData';
import getJobMatches from '@salesforce/apex/LEXMatchesToMyJobsController.getJobMatches';

export default class LexMatchesToMyJobs extends LightningElement {
	@api config;

	wiredMatches;
	selectedJobFilter = 'All';
	@track jobFilterOptions = [
		{
			label: 'All',
			value: 'All',
		},
	];

	@track matches = [];
	currentPage = 1;
	noOfTiles = 6;

	@track matchTileFields;

	loadingJobs = true;
	loadingMatches = true;

	// * GETS ALL OPEN JOBS FROM THE CURRENT EMPLOYER
	@wire(getJobData)
	wiredJobData({ data, error }) {
		if (data) {
			let jobs = data.map((job) => {
				return {
					label: job.Name,
					value: job.Id,
				};
			});

			this.jobFilterOptions = [...this.jobFilterOptions, ...jobs];
		} else if (error) {
			console.log('error', error);
			let message = error.body.message;

			if (message === 'No user found') {
				this.showToast(errorTitle, this.config.noUserErrorMessage, 'error');
			} else if (message === 'No user contact found') {
				this.showToast(errorTitle, this.config.noContactErrorMessage, 'error');
			} else {
				this.showToast(errorTitle, message, 'error');
			}
		}
		this.loadingJobs = false;
	}

	// * GETS ALL MATCHES FOR THE EMPLOYER OR MATCHES FROM THE SELECTED JOB
	@wire(getJobMatches, { jobFilter: '$selectedJobFilter' })
	wiredJobMatches(result) {
		this.wiredMatches = result;

		let { data, error } = result;

		if (data) {
			this.matches = [...data.myMatches];
			this.matchTileFields = [...data.matchTileFields];
			this.noOfTiles = data.noOfTilesPerPage;
		} else if (error) {
			console.log('error', error);
			let message = error.body.message;

			if (message === 'No user found') {
				this.showToast(errorTitle, this.config.noUserErrorMessage, 'error');
			} else if (message === 'No user contact found') {
				this.showToast(errorTitle, this.config.noContactErrorMessage, 'error');
			} else {
				this.showToast(errorTitle, message, 'error');
			}
		}

		this.loadingMatches = false;
	}

	// * HANDLES SELECTED A JOB TO FILTER BY
	handleChangeJobFilter(event) {
		this.loadingMatches = true;

		this.selectedJobFilter = event.detail.value;
		refreshApex(this.wiredMatches);
	}

	// * SETS THE CURRENT PAGE ON A CUSTOM PAGE CHANGE EVENT
	customPageChange(e) {
		this.currentPage = e.detail.page;
	}

	// # PRIVATE FUNCTIONS

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

	// # GETTERS

	// * CHECKS IF THERE ARE CURRENT MATCHES
	get hasMatches() {
		if (this.matches.length > 0) {
			return true;
		}
		return false;
	}

	// * GETS THE TOTAL NUMBER OF MATCHES
	get totalMatches() {
		return this.matches !== undefined ? this.matches.length : undefined;
	}

	// * RETURNS THE AN ARRAY OF MATCHES FOR A PAGE
	get currentMatches() {
		const matches = this.matches;
		let matchPage = matches.slice((this.currentPage - 1) * this.noOfTiles, this.currentPage * this.noOfTiles);
		return matchPage;
	}

	// * EXTENDS THE CONFIG CLASS
	get matchConfig() {
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

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loadingJobs || this.loadingMatches) {
			return true;
		}
		return false;
	}
}