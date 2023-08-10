import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LexEditContactModal from 'c/lexEditContactModal';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import multiSelectAvailable from '@salesforce/label/c.LEXCommunity_Multi_Select_Available';
import multiSelectSelected from '@salesforce/label/c.LEXCommunity_Multi_Select_Selected';

import getContactTableData from '@salesforce/apex/LEXContactListController.getContactTableData';
import archiveContact from '@salesforce/apex/LEXContactListController.archiveContact';

export default class LexContactList extends LightningElement {
	@api config;
	@api accountId = null;
	@api account;
	@api editActive;
	@api isDesktop;
	@api isMobile;
	@api headerPadding;
	@api floatRight;
	@api headerCSS;
	@api subheaderCSS;
	@api showNewBtn;
	@track wiredContactResult;
	@track columnsData;
	@track tableData;
	@track pagePropertiesData;

	loadingData = true;
	savingData = false;

	// # APEX

	// * GET TABLE DATA
	@wire(getContactTableData, { accountId: '$accountId' })
	wiredContactData(result) {
		this.wiredContactResult = result;
		if (!result.data) {
			this.loadingData = false;
		}
		if (result.data) {
			this.tableData = [...result.data.myContacts];
			this.pagePropertiesData = result.data.pageProp;
			this.columnsData = result.data.columns;
			this.loadingData = false;
		} else if (result.error) {
			this.showToast(this.label.errorTitle, result.error.body.message, 'error');
			this.loadingData = false;
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

	// * OPENS EDIT CONTACT MODAL
	clickEditBtn(e) {
		LexEditContactModal.open({
			label: 'Contact Info',
			size: 'medium',
			contactId: e.target.value,
			accountId: this.accountId,
			account: this.account,
			config: this.config,
			isDesktop: this.isDesktop,
			isMobile: this.isMobile,
			headerPadding: this.headerPadding,
			floatRight: this.floatRight,
			headerCSS: this.headerCSS,
			subheaderCSS: this.subheaderCSS,
		}).then((result) => {
			refreshApex(this.wiredContactResult);
		});
	}

	clickDeleteBtn(e) {
		this.savingData = true;
		let con = e.target.value;

		archiveContact({ contactId: con })
			.then(() => {
				refreshApex(this.wiredContactResult);
				this.savingData = false;
				this.showToast(this.label.successTitle, 'Successfully deleted contact.', 'success');
			})
			.catch((err) => {
				this.showToast(this.label.errorTitle, err.body.message, 'error');
				this.savingData = false;
			});
	}

	// # GETTERS/SETTERS

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loadingData || this.savingData) {
			return true;
		}
		return false;
	}

	// * RETURNS TRUE IF NO ACCOUNT/CONTACTS ARE FOUND
	get noData() {
		return this.accountId == null || this.tableData == null;
	}

	// * SETS CLASS FOR THE EDIT BUTTON CELLS
	get editBtnClass() {
		return 'editCol';
		// return !this.editActive ? 'editCol' : 'editColHide';
	}

	// * PREPS COLUMN DATA FOR USE
	get columns() {
		return [...this.columnsData].map((i) => {
			let type;
			Object.keys(i.field).forEach((e) => {
				if (e === 'type') {
					type = i.field[e];
				}
			});
			return {
				fieldName: i.fieldLabel,
				label: i.fieldName,
				type: type,
			};
		});
	}

	// * PREPS ROW DATA FOR USE
	get rows() {
		let rowData = [];
		let conId;
		if (this.tableData != null) {
			this.tableData.forEach((tD) => {
				let conData = [];
				let keys = new Set();
				for (const key in tD) {
					if (Object.hasOwnProperty.call(tD, key)) {
						[...this.columnsData].forEach((cD) => {
							if (!keys.has(cD.fieldLabel)) {
								if (key === cD.fieldLabel) {
									conData.push({
										label: cD.fieldLabel,
										name: cD.fieldName,
										fieldInfo: cD.field,
										value: tD[key],
										checked: tD[key],
										index: cD.index,
									});
									keys.add(cD.fieldLabel);
								} else if (key.trim() === 'Account') {
									const tempArray = cD.fieldLabel.split('.');
									conData.push({
										label: cD.fieldLabel,
										name: cD.fieldName,
										fieldInfo: cD.field,
										value: tD[tempArray[0]][tempArray[1]],
										index: cD.index,
									});
									keys.add(cD.fieldLabel);
								} else if (!(cD.fieldLabel in tD)) {
									conData.push({
										label: cD.fieldLabel,
										name: cD.fieldName,
										fieldInfo: cD.field,
										value: '',
										index: cD.index,
									});
									keys.add(cD.fieldLabel);
								}
							}
						});
					}
				}

				let sortedConData = conData.sort((e, i) => e.index - i.index);
				conId = {
					Id: tD.Id,
					con: sortedConData,
				};
				rowData.push(conId);
			});
		}
		return rowData;
	}

	// * COMBINES CUSTOM LABELS AND CONFIG OBJECT INTO ONE
	get label() {
		const label = {
			successTitle,
			errorTitle,
			multiSelectAvailable,
			multiSelectSelected,
		};
		return {
			...label,
			...this.config,
		};
	}
}