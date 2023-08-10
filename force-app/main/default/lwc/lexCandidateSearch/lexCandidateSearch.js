import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getSetupData from '@salesforce/apex/LEXCandidateSearchController.getSetupData';
import getCandidateData from '@salesforce/apex/LEXCandidateSearchController.getCandidateData';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

import { ViewEvent, ClearFiltersEvent } from './event.js';

export default class lexMyCandidates extends LightningElement {
	@api viewType;
	@api appliedFilters;
	@api candidateConfig;

	@track defaultMyCandidates;
	@track defaultOtherCandidates;
	@track searchedCandidates;
	@track candidateSearchFields;
	@track candidateViewDetailsFields;
	@track filterOptions;
	@track uniqueFields;
	@track savedCandidateIds;
	@track appliedCandidateIds;
	@track myCurrentPage = 1;
	@track otherCurrentPage = 1;
	@track noOfTilesPerPage = 6;
	@track isLoading = true;
	@track showPopup = true;
	isOnLoad = true;

	renderedCallback() {
		if (this.appliedCandidateIds && this.candidateViewDetailsFields && this.uniqueFields && this.showPopup) {
			let url_string = window.location.href;
			const url = new URL(url_string);
			const candidateId = url.searchParams.get('candidateId');
			if (candidateId) {
				this.isLoading = true;
				this.showPopup = false;
				getCandidateData({
					candidateId: candidateId,
					fields: this.uniqueFields,
					filterField: this.candidateConfig.filterField,
				})
					.then((record) => {
						if (record) {
							this.isLoading = false;
							this.dispatchEvent(
								new ViewEvent({
									candidate: record.candidate,
									fields: [...this.candidateViewDetailsFields],
									applied: this.appliedCandidateIds.find((value) => value === record.Id) !== undefined,
								})
							);
						} else {
							this.isLoading = false;
						}
					})
					.catch((error) => {
						this.isLoading = false;
						this.showNotification(this.label.errorTitle, error.body.message, 'error');
					});
			}
		}
	}

	@wire(getSetupData, {
		viewType: '$viewType',
		filterField: '$candidateConfig.filterField',
		priorityFilterField: '$candidateConfig.priorityFilterField',
		//matchFilterField: '$candidateConfig.matchFilterField',
		searchFilterFields: '$candidateConfig.searchFilterFields',
	})
	wiredGetSetupData({ error, data }) {
		if (data) {
			/* Page should display no results until Search is performed
			if (this.isMyCandidatesPage) {
				this.defaultMyCandidates = data.myCandidates.map((record) => {
					return {
						...record,
						saved: data.savedCandidateIds.find((value) => value === record.candidate.Id) !== undefined,
						applied: data.appliedCandidateIds.find((value) => value === record.candidate.Id) !== undefined
					};
				});
			}

			this.defaultOtherCandidates = data.otherCandidates.map((record) => {
				return {
					...record,
					saved: data.savedCandidateIds.find((value) => value === record.candidate.Id) !== undefined,
					applied: data.appliedCandidateIds.find((value) => value === record.candidate.Id) !== undefined,
				};
			});*/
			this.candidateSearchFields = data.candidateSearchFields;
			this.candidateViewDetailsFields = data.candidateViewDetailsFields;
			this.noOfTilesPerPage = data.noOfTilesPerPage;
			this.uniqueFields = data.uniqueFields;
			this.savedCandidateIds = data.savedCandidateIds;
			this.appliedCandidateIds = data.appliedCandidateIds;
			this.filterOptions = data.filters;
			this.isLoading = false;
			this.dispatchEvent(
				new Event('domcontentloaded', {
					bubbles: true,
					cancelable: true,
				})
			);
			this.isLoading = false;
		} else if (error) {
			this.showNotification(this.label.errorTitle, error.body.message, 'error');
			this.isLoading = false;
		}
	}

	handleMyPageChange(event) {
		this.myCurrentPage = event.detail.page;
		this.template.querySelector(`[data-id="candidateMatches"]`).scrollIntoView();
	}

	handleOtherPageChange(event) {
		this.otherCurrentPage = event.detail.page;
		this.template.querySelector(`[data-id="otherCandidates"]`).scrollIntoView();
	}

	handleSearchedResult(event) {
		let searchedCandidates = event.detail.searchedCandidates;
		let parsedCandidates = [];
		for (let i = 0; i < searchedCandidates.length; i++) {
			const candidate = searchedCandidates[i];
			let hasValue = false;
			/*for (const field in candidate) {
				if (candidate[field]) {
					hasValue = true;
					break;
				}
			}*/

			//* Confirm we have data to display for this Candidate
			for (const field of this.candidateSearchFields) {
				if (!field.fieldApiName.includes('.')) {
					if (candidate[field.fieldApiName]) {
						hasValue = true;
						break;
					}
				} else {
					const tempArray = field.fieldApiName.split('.');
					if (candidate[tempArray[0]][tempArray[1]]) {
						hasValue = true;
						break;
					}
				}
			}

			if (hasValue) {
				parsedCandidates.push({
					candidate,
					saved: this.savedCandidateIds.find((value) => value === candidate.Id) !== undefined,
					applied: this.appliedCandidateIds.find((value) => value === candidate.Id) !== undefined,
				});
			}
		}
		this.searchedCandidates = [...parsedCandidates];

		this.otherCurrentPage = 1;
		this.isOnLoad = false;
	}

	handleClearFilters() {
		this.searchedCandidates = undefined;
		this.dispatchEvent(new ClearFiltersEvent());
		this.myCurrentPage = 1;
		this.otherCurrentPage = 1;
		this.isOnLoad = true;
	}

	/*handleEmailSent(event) {
		//mirror get currentCandidates to update the correct array
		//or add to appliedCandidateIds? doesn't seem it would update the arrays immediately
		if (this.searchedCandidates) {
			this.searchedCandidates.get(event.detail.candidateId).applied = true;
		}
	}*/

	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	get label() {
		return {
			errorTitle,
		};
	}

	get totalOtherRecords() {
		return this.currentCandidates !== undefined ? this.currentCandidates.length : undefined;
	}

	get showNoResultsMessage() {
		return !this.totalOtherRecords && !this.isOnLoad;
	}

	get totalMatchedRecords() {
		return this.matchedCandidates !== undefined ? this.matchedCandidates.length : undefined;
	}

	get currentCandidates() {
		return this.searchedCandidates ? this.searchedCandidates : this.defaultOtherCandidates;
	}

	get matchedCandidates() {
		return this.searchedCandidates ? [] : this.defaultMyCandidates;
	}

	get otherCandidates() {
		var currentCandidates = this.currentCandidates;
		return currentCandidates.slice((this.otherCurrentPage - 1) * this.noOfTilesPerPage, this.otherCurrentPage * this.noOfTilesPerPage);
	}

	get myCandidates() {
		var matchedCandidates = this.matchedCandidates;
		return matchedCandidates.slice((this.myCurrentPage - 1) * this.noOfTilesPerPage, this.myCurrentPage * this.noOfTilesPerPage);
	}

	get candidatesTitle() {
		return this.matchedCandidates !== undefined && this.matchedCandidates.length !== 0
			? this.candidateConfig.otherCandidatesHeader
			: this.candidateConfig.candidatesHeader;
	}

	get candidatesSubTitle() {
		return this.matchedCandidates !== undefined && this.matchedCandidates.length !== 0
			? this.candidateConfig.otherCandidatesSubHeader
			: this.candidateConfig.candidatesSubHeader;
	}

	get isMyCandidatesPage() {
		return this.viewType === 'myCandidates';
	}

	get headerCSS() {
		return this.candidateConfig && this.candidateConfig.headerColor ? 'color:' + this.candidateConfig.headerColor : 'color:rgb(84, 105, 141)';
	}

	get enableSearch() {
		return this.isMyCandidatesPage && this.candidateConfig.enableSearch;
	}
}