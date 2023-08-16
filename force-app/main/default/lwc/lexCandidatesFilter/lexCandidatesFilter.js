import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

import searchCandidates from '@salesforce/apex/LEXCandidateSearchController.searchCandidates';
//import getwagePicklist from '@salesforce/apex/LEXCandidateSearchController.getwagePicklist';

import { ChangeFiltersEvent, SearchCandidate, ClearFiltersEvent } from './event.js';
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

export default class lexCandidatesFilter extends LightningElement {
	@api filterOptions;
	@api uniqueFields;
	@api appliedFilters;
	@track isLoading = false;
	@track selectedWage;
	@api candidateConfig;

	@track hourlyWageOptions;

	@track doAutoSearch = false;

	renderedCallback() {
		let url_string = window.location.href;
		const url = new URL(decodeURIComponent(url_string));
		const wage = url.searchParams.get('wage');
		const keyword = url.searchParams.get('keyword');
		//const cityZip = url.searchParams.get("cityZip");

		var inputs = this.template.querySelectorAll('lightning-input');

		/*if( inputs !== undefined && this.uniqueFields && !this.doAutoSearch && 
            (   wage !== null || keyword !== null || cityZip !== null )
        ) {
            //inputs[0].value = cityZip;
            //inputs[1].value = keyword;*/
		if (inputs !== undefined && this.uniqueFields && !this.doAutoSearch && keyword !== null) {
			inputs[0].value = keyword;
			this.selectedWage = parseInt(wage);
			this.doAutoSearch = true;

			if (this.doAutoSearch) {
				this.handleSearch();
			}
		}
	}

	handleSearch() {
		this.isLoading = true;
		// *Get the text input from the component
		const inputs = this.template.querySelectorAll('lightning-input');
		const keyword = inputs[0].value;
		let filterOptionsMap = {};

		//
		if (this.appliedFilters && Object.keys(this.appliedFilters).length) {
			Object.keys(this.appliedFilters).forEach((key) => {
				filterOptionsMap[key] = Object.values({ ...this.appliedFilters[key] });
			});
		}

		//  *Check if the minimum number of search characters has been provided
		const minimumCharacters = this.candidateConfig.minimumSearchCharacters;
		if (minimumCharacters && keyword.length < minimumCharacters) {
			this.showNotification(this.candidateConfig.minimumSearchCharactersErrorHeader, this.candidateConfig.minimumSearchCharactersErrorMessage, 'warning');
			this.isLoading = false;
			return;
		}

		searchCandidates({
			/*wage: this.selectedWage,
            cityOrZipCode: inputs[0].value ? inputs[0].value : null,
            keyword: inputs[1].value, */
			keyword: keyword,
			filterOptionsMap,
			uniqueFields: this.uniqueFields,
			filterField: this.candidateConfig.filterField,
			priorityFilterField: this.candidateConfig.priorityFilterField,
			matchFilterField: this.candidateConfig.matchFilterField,
			//useBilling: this.candidateConfig.useBillingAddressAccountRelatedtoCandidate,
			searchFilterFields: this.candidateConfig.searchFilterFields,
		})
			.then((resp) => {
				if (resp) {
					this.isLoading = false;
					this.dispatchEvent(new SearchCandidate({ searchedCandidates: resp }));
				}
			})
			.catch((error) => {
				this.isLoading = false;
				this.showNotification(this.label.errorTitle, error.body.message, 'error');
			});
	}

	handleSelectFilterValues(event) {
		event.preventDefault();
		const filter = this.filterOptions.find((filter) => filter.fieldName === event.target.name);
		const selectedValues = this.appliedFilters ? Object.values({ ...this.appliedFilters[event.target.name] }) : [];
		this.dispatchEvent(
			new ChangeFiltersEvent({
				filter: {
					...filter,
					values: [...filter.values],
					selectedValues,
				},
			})
		);
	}

	handleClearFilters() {
		[...this.template.querySelectorAll('lightning-input')].forEach((input) => {
			input.value = '';
		});
		this.selectedWage = undefined;
		this.dispatchEvent(new ClearFiltersEvent());
	}

	handleWageChange(event) {
		this.selectedWage = parseInt(event.detail.value);
	}

	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	get selectedWageOption() {
		return this.selectedWage ? this.selectedWage.toString() : '';
	}

	get label() {
		return {
			errorTitle,
		};
	}

	get isMobile() {
		return FORM_FACTOR === 'Small';
	}

	get filterCSS() {
		return this.isMobile ? 'slds-col slds-size_1-of-1 slds-p-around_medium mobile' : 'slds-col slds-size_1-of-6 slds-p-around_medium';
	}

	get moreFilters() {
		return this.filterOptions
			? this.filterOptions.map((filter) => {
					return {
						...filter,
						isFilterApplied:
							this.appliedFilters &&
							this.appliedFilters[filter.fieldName] !== undefined &&
							Object.values({ ...this.appliedFilters[filter.fieldName] }).length,
					};
			  })
			: [];
	}
}