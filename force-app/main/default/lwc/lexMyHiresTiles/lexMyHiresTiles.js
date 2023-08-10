import { LightningElement, track, api, wire } from 'lwc';
import getSetupData from '@salesforce/apex/LEXMyHiresController.getSetupData';
import { HiresTileClickedEvent } from './events';

export default class LexMyHiresTiles extends LightningElement {
	@api config;
	@track hiresData;
	@track currentYearHires;
	@track currentYearHiresCount;
	@track lastYearHires;
	@track lastYearHiresCount;
	@track thisMonthHires;
	@track thisMonthHiresCount;
	@track thisQuarterHires;
	@track thisQuarterHiresCount;

	@track dispatchHires;

	@track myHireFields;

	tile1Clicked = false;
	tile2Clicked = false;
	tile3Clicked = false;
	tile4Clicked = false;

	@wire(getSetupData)
	wiredGetSetupData({ data, error }) {
		this.dispatchHires = [];
		if (data) {
			this.hiresData = data.hires.hiresData;
			this.myHiresCount = this.hiresData.length;
			this.myHireFields = data.hireFields;
			const year = new Date();

			this.currentYearHires = this.hiresData.filter((hire) => {
				let hireDate = new Date(hire.Launchpad__Hire_Date__c);
				return hireDate.getFullYear() === year.getFullYear();
			});

			this.currentYearHiresCount = this.currentYearHires.length;

			this.lastYearHires = this.hiresData.filter((hire) => {
				let hireDate = new Date(hire.Launchpad__Hire_Date__c);
				return hireDate.getFullYear() === year.getFullYear() - 1;
			});

			this.lastYearHiresCount = this.lastYearHires.length;

			this.thisMonthHires = this.hiresData.filter((hire) => {
				let hireDate = new Date(hire.Launchpad__Hire_Date__c);
				if (hireDate.getFullYear() !== year.getFullYear()) {
					return false;
				}
				return hireDate.getMonth() === year.getMonth();
			});

			this.thisMonthHiresCount = this.thisMonthHires.length;

			this.thisQuarterHires = this.hiresData.filter((hire) => {
				let hireDate = new Date(hire.Launchpad__Hire_Date__c);
				if (hireDate.getFullYear() !== year.getFullYear()) {
					return false;
				}
				switch (year.getMonth()) {
					case 0:
						return hireDate.getMonth() === 0 || hireDate.getMonth() === 1 || hireDate.getMonth() === 2;
					case 1:
						return hireDate.getMonth() === 0 || hireDate.getMonth() === 1 || hireDate.getMonth() === 2;
					case 2:
						return hireDate.getMonth() === 0 || hireDate.getMonth() === 1 || hireDate.getMonth() === 2;
					case 3:
						return hireDate.getMonth() === 3 || hireDate.getMonth() === 4 || hireDate.getMonth() === 5;
					case 4:
						return hireDate.getMonth() === 3 || hireDate.getMonth() === 4 || hireDate.getMonth() === 5;
					case 5:
						return hireDate.getMonth() === 3 || hireDate.getMonth() === 4 || hireDate.getMonth() === 5;
					case 6:
						return hireDate.getMonth() === 6 || hireDate.getMonth() === 7 || hireDate.getMonth() === 8;
					case 7:
						return hireDate.getMonth() === 6 || hireDate.getMonth() === 7 || hireDate.getMonth() === 8;
					case 8:
						return hireDate.getMonth() === 6 || hireDate.getMonth() === 7 || hireDate.getMonth() === 8;
					case 9:
						return hireDate.getMonth() === 9 || hireDate.getMonth() === 10 || hireDate.getMonth() === 11;
					case 10:
						return hireDate.getMonth() === 9 || hireDate.getMonth() === 10 || hireDate.getMonth() === 11;
					case 11:
						return hireDate.getMonth() === 9 || hireDate.getMonth() === 10 || hireDate.getMonth() === 11;
					default:
						return false;
				}
			});
			this.thisQuarterHiresCount = this.thisQuarterHires.length;

			this.dispatchEvent(
				new CustomEvent('DOMContentLoaded', {
					bubbles: true,
					cancelable: true,
				})
			);

			this.handleClickTile1();
		} else {
			console.log(error);
		}
	}

	// * HANDLERS
	handleErrorClose() {
		this.errorMessage = undefined;
	}

	// Set tile1Clicked to true and all other tileClicked values to false
	// then fire a custom event to pass the application type "newApplications" to the parent component
	handleClickTile1() {
		this.dispatchHires = this.thisMonthHires;
		this.handleClickTile(true, false, false, false, 'thisMonthHires');
	}
	// Set tile2Clicked to true and all other tileClicked values to false
	// then fire a custom event to pass the application type "pendingApplications" to the parent component
	handleClickTile2() {
		this.dispatchHires = this.thisQuarterHires;
		this.handleClickTile(false, true, false, false, 'thisQuarterHires');
	}
	// Set tile3Clicked to true and all other tileClicked values to false
	// then fire a custom event to pass the application type "processedApplications" to the parent component
	handleClickTile3() {
		this.dispatchHires = this.currentYearHires;
		this.handleClickTile(false, false, true, false, 'currentYearHires');
	}

	// Set tile3Clicked to true and all other tileClicked values to false
	// then fire a custom event to pass the application type "processedApplications" to the parent component
	handleClickTile4() {
		this.dispatchHires = this.lastYearHires;
		this.handleClickTile(false, false, false, true, 'lastYearHires');
	}

	get label() {
		return {
			closeButton,
			errorTitle,
		};
	}

	/** HELPER METHODS */
	// A generic method for handling when each of the three on-screen tiles are clicked
	// at time of development, there will only ever be three tiles
	handleClickTile(tile1Clicked, tile2Clicked, tile3Clicked, tile4Clicked, interval) {
		this.tile1Clicked = tile1Clicked;
		this.tile2Clicked = tile2Clicked;
		this.tile3Clicked = tile3Clicked;
		this.tile4Clicked = tile4Clicked;
		this.dispatchHiresEvent();
	}

	// An additional abstraction of dispatching the event ApplicationstileClickedEvent
	dispatchHiresEvent() {
		try {
			let result = this.processHireData();
			let event = new HiresTileClickedEvent(result, this.myHireFields);
			this.dispatchEvent(event);
			this.dispatchHires = [];
		} catch (error) {
			console.log('ERROR: ', error.body.message);
		}
	}

	get label() {
		return {
			errorTitle,
		};
	}
	get isDesktop() {
		return FORM_FACTOR === 'Large';
	}

	get showButtonColumn() {
		return this.config && (this.config.showRedirectButton || this.config.showContactUsButton);
	}

	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}

	get isLoading() {
		if (this.loadingData) {
			return true;
		}
		return false;
	}

	processHireData() {
		let result = [];

		if (this.myHireFields !== undefined && this.dispatchHires !== undefined) {
			this.dispatchHires.forEach((record) => {
				let recordData = [];
				this.myHireFields.forEach((field) => {
					let value;
					if (!field.fieldApiName.includes('.')) {
						value = record[field.fieldApiName];
					} else {
						const tempArray = field.fieldApiName.split('.');
						value = record[tempArray[0]][tempArray[1]];
					}
					recordData.push({
						label: field.fieldLabel,
						type: field.fieldType,
						value,
					});
				});
				result.push({
					key: record.Id,
					details: recordData,
				});
			});
		}

		return result;
	}
}