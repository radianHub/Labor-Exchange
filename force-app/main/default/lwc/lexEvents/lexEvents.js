import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getSetupData from '@salesforce/apex/LEXEventsController.getSetupData';
import getEventData from '@salesforce/apex/LEXEventsController.getEventData';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

import { RegistrationEvent, ClearFiltersEvent } from './event.js';

export default class LEXEvents extends LightningElement {
	@api viewType;
	@api appliedFilters;
	@api eventConfig;

	@track defaultEvents;
	@track searchedEvents;
	@track fieldsConfigMap;
	@track filterOptions;
	@track uniqueFields;
	@track currentPage = 1;
	@track registeredEventIds;
	@track noOfTilesPerPage = 6;
	@track isLoading = true;

	objectApiName = 'Launchpad__Event__c';

	renderedCallback() {
		if (this.registeredEventIds && this.fieldsConfigMap && this.uniqueFields) {
			let url_string = window.location.href;
			const url = new URL(url_string);
			const eventId = url.searchParams.get('eventId');
			if (eventId) {
				this.isLoading = true;

				getEventData({
					eventId: eventId,
					fields: this.uniqueFields,
					filterField: this.eventConfig.filterField,
				})
					.then((record) => {
						if (record) {
							this.isLoading = false;

							const key = record.RecordType.Name + (record.Launchpad__Event_Type__c === 'On Demand Video' ? 'On Demand Video' : 'Live');
							const eventData = {
								record,
								isOnDemand: record.Launchpad__Event_Type__c === 'On Demand Video',
								isRegistered: this.registeredEventIds.find((value) => value === record.Id) !== undefined,
								fields: this.fieldsConfigMap && this.fieldsConfigMap[key] ? this.fieldsConfigMap[key].tileFields : [],
								noOfFields: this.fieldsConfigMap && this.fieldsConfigMap[key] ? this.fieldsConfigMap[key].noOfFields : [],
							};
							this.dispatchEvent(
								new RegistrationEvent({
									record: record,
									fields: this.fieldsConfigMap && this.fieldsConfigMap[key] ? this.fieldsConfigMap[key].confirmationFields : [],
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
		filterField: '$eventConfig.filterField',
		priorityFilterField: '$eventConfig.priorityFilterField',
		searchFilterFields: '$eventConfig.searchFilterFields',
	})
	wiredGetSetupData({ error, data }) {
		if (data) {
			this.registeredEventIds = data.registeredEventIds;
			this.noOfTilesPerPage = data.noOfTilesPerPage;
			this.uniqueFields = data.uniqueFields;
			this.filterOptions = data.filters;
			this.fieldsConfigMap = data.fieldsConfigMap;

			this.defaultEvents = data.events.map((event) => {
				const key = event.RecordType.Name + (event.Launchpad__Event_Type__c === 'On Demand Video' ? 'On Demand Video' : 'Live');

				return {
					record: event,
					isOnDemand: event.Launchpad__Event_Type__c === 'On Demand Video',
					isRegistered: data.registeredEventIds.find((value) => value === event.Id) !== undefined,
					fields: this.fieldsConfigMap && this.fieldsConfigMap[key] ? this.fieldsConfigMap[key].tileFields : [],
					noOfFields: this.fieldsConfigMap && this.fieldsConfigMap[key] ? this.fieldsConfigMap[key].noOfFields : [],
				};
			});

			this.isLoading = false;
			this.dispatchEvent(
				new Event('domcontentloaded', {
					bubbles: true,
					cancelable: true,
				})
			);
		} else if (error) {
			this.showNotification(this.label.errorTitle, error.body.message, 'error');
			this.isLoading = false;
		}
	}

	handlePageChange(event) {
		this.currentPage = event.detail.page;
	}

	handleRegister(event) {
		const record = { ...event.detail.eventData.record };
		const key = record.RecordType.Name + (record.Launchpad__Event_Type__c === 'On Demand Video' ? 'On Demand Video' : 'Live');
		this.dispatchEvent(
			new RegistrationEvent({
				record,
				fields: this.fieldsConfigMap && this.fieldsConfigMap[key] ? this.fieldsConfigMap[key].confirmationFields : [],
			})
		);
	}

	handleSearchedResult(event) {
		this.searchedEvents = event.detail.searchedEvents.map((event) => {
			const key = event.RecordType.Name + (event.Launchpad__Event_Type__c === 'On Demand Video' ? 'On Demand Video' : 'Live');

			return {
				record: event,
				isOnDemand: event.Launchpad__Event_Type__c === 'On Demand Video',
				isRegistered: this.registeredEventIds.find((value) => value === event.Id) !== undefined,
				fields: this.fieldsConfigMap && this.fieldsConfigMap[key] ? this.fieldsConfigMap[key].tileFields : [],
				noOfFields: this.fieldsConfigMap && this.fieldsConfigMap[key] ? this.fieldsConfigMap[key].noOfFields : [],
			};
		});
		this.currentPage = 1;
	}

	handleClearFilters() {
		this.searchedEvents = undefined;
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
			errorTitle,
		};
	}

	get totalRecords() {
		return this.currentEvents !== undefined ? this.currentEvents.length : undefined;
	}

	get currentEvents() {
		return this.viewType == 'events' || this.viewType === 'Home' ? this.skillBuildingEvents : this.registeredEvents;
	}

	get skillBuildingEvents() {
		return this.searchedEvents ? this.searchedEvents : this.defaultEvents;
	}

	get registeredEvents() {
		return this.defaultEvents ? this.defaultEvents.filter((event) => this.registeredEventIds.find((value) => event.record.Id === value) !== undefined) : [];
	}

	get events() {
		var currentEvents = this.currentEvents;

		currentEvents.forEach((event) => {
			if (event.fields === undefined) {
				event.show = false;
			} else {
				event.show = true;
			}
		});
		return currentEvents.slice((this.currentPage - 1) * this.noOfTilesPerPage, this.currentPage * this.noOfTilesPerPage);
	}

	get showFilter() {
		return this.viewType === 'events';
	}

	get headerCSS() {
		return this.eventConfig && this.eventConfig.headerColor ? 'color:' + this.eventConfig.headerColor : 'color:rgb(84, 105, 141)';
	}
}