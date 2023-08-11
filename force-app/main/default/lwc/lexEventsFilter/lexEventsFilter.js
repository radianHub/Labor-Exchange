import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

import searchEvents from '@salesforce/apex/LEXEventsController.searchEvents';

import { ChangeFiltersEvent, SearchEvent, ClearFiltersEvent } from './event.js';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

export default class LEXEventsFilter extends LightningElement {
    @api filterOptions;
    @api uniqueFields;
    @api appliedFilters;
    @api eventConfig;
    @track isLoading = false;
    @track doAutoSearch = false;

    renderedCallback() {
        let url_string = window.location.href;
        const url = new URL(decodeURIComponent(url_string));
        const keyword = url.searchParams.get("keyword");
        const startDate = url.searchParams.get("startDate");

        var inputs = this.template.querySelectorAll('lightning-input');

        if( inputs !== undefined && this.uniqueFields && !this.doAutoSearch && 
            (keyword !== null || startDate !== null)) {
            inputs[0].value = keyword;
            inputs[1].value = startDate;
            this.doAutoSearch = true;

            if(this.doAutoSearch) {
                this.handleSearch();
            }
        }
        
    }
    
    handleSearch() {
        this.isLoading = true;
        const inputs = this.template.querySelectorAll('lightning-input');
        let filterOptionsMap = {};
        
        if(this.appliedFilters && Object.keys(this.appliedFilters).length) {
            Object.keys(this.appliedFilters).forEach(key => {
                filterOptionsMap[key] = Object.values({...this.appliedFilters[key]})
            });
        }

        searchEvents({ 
            keyword: inputs[0].value, 
            startDate: inputs[1].value ? inputs[1].value : null,
            filterOptionsMap,
            filterField: this.eventConfig.filterField, 
            priorityFilterField: this.eventConfig.priorityFilterField,
            uniqueFields: this.uniqueFields,
            searchFilterFields: this.eventConfig.searchFilterFields
        })
        .then((resp) => {
            if(resp) {
                this.isLoading = false;
                this.dispatchEvent(new SearchEvent({searchedEvents : resp}));
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.showNotification(this.label.errorTitle, error.body.message, 'error');
        });
    }

    handleSelectFilterValues(event) {
        event.preventDefault();
        const filter = this.filterOptions.find(filter => filter.fieldName === event.target.name)
        const selectedValues = this.appliedFilters ? Object.values({...this.appliedFilters[event.target.name]}) : []
        this.dispatchEvent(
            new ChangeFiltersEvent({
                filter: {
                    ...filter,
                    values: [...filter.values],
                    selectedValues
                }
            })
        );
    }

    handleClearFilters() {
        [...this.template.querySelectorAll('lightning-input')].forEach(input => {
            input.value = '';
        });
        this.dispatchEvent(new ClearFiltersEvent());
    }

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
            errorTitle
        };
    }

    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    get filterCSS() {
        return this.isMobile ? 'slds-col slds-size_1-of-1 slds-p-around_medium mobile' : 'slds-col slds-size_1-of-5 slds-p-around_medium';
    }

    get moreFilters() {
        return this.filterOptions
            ? this.filterOptions.map(filter => {
                return {
                    ...filter,
                    isFilterApplied: this.appliedFilters && this.appliedFilters[filter.fieldName] !== undefined && Object.values({...this.appliedFilters[filter.fieldName]}).length
                };
            }) : []
    }
}