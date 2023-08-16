import { wire, api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import multiSelectAvailable from '@salesforce/label/c.LEXCommunity_Multi_Select_Available';
import multiSelectSelected from '@salesforce/label/c.LEXCommunity_Multi_Select_Selected';

import fetchContactData from '@salesforce/apex/LEXEditContactModalController.fetchContactData';
import upsertContact from '@salesforce/apex/LEXEditContactModalController.upsertContact';

export default class LexEditContactModal extends LightningModal {
	@api config;
	@api contactId;
	@api accountId;
	@api account;
	@api isDesktop;
	@api isMobile;
	@api headerPadding;
	@api floatRight;
	@api headerCSS;
	@api subheaderCSS;
	@track sections;
	@track contact;
	wiredSectionResult;
	formData;

	loading = true;
	saving = false;

	renderedCallback() {
		if (this.contact) {
			[...this.template.querySelectorAll('lightning-input')].forEach((inputCmp) => {
				if (inputCmp.type === 'checkbox') {
					inputCmp.checked = this.contact[inputCmp.name];
				} else {
					inputCmp.value = this.contact[inputCmp.name];
				}
			});

			[...this.template.querySelectorAll('lightning-textarea')].forEach((inputCmp) => {
				inputCmp.value = this.contact[inputCmp.name];
			});

			[...this.template.querySelectorAll('lightning-combobox')].forEach((inputCmp) => {
				if (inputCmp.name !== 'document') {
					inputCmp.value = this.contact[inputCmp.name];
				}
			});

			if (this.isDesktop) {
				[...this.template.querySelectorAll('lightning-dual-listbox')].forEach((inputCmp) => {
					const valueStr = this.contact[inputCmp.name];
					inputCmp.value = valueStr ? valueStr.split(';') : undefined;
				});
			} else {
				[...this.template.querySelectorAll('select')].forEach((inputCmp) => {
					const valueStr = this.contact[inputCmp.name];
					var options = valueStr.split(';');
					for (let i = 0, l = inputCmp.options.length, o; i < l; i++) {
						o = inputCmp.options[i];
						if (options.indexOf(o.text) !== -1) {
							o.selected = true;
						}
					}
				});
			}
		}
	}

	// # APEX

	// * GETS SECTIONS, FIELDS, AND CONTACT DATA
	@wire(fetchContactData, { contactId: '$contactId' })
	wiredGetSections(result) {
		this.wiredSectionResult = result;
		if (result.data) {
			this.sections = result.data.sections;
			this.contact = result.data.myContact ? result.data.myContact : null;
			this.loading = false;
		} else if (result.error) {
			this.showToast(this.Label.errorTitle, result.error.body.message, 'error');
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

	// * CLOSES MODAL
	clickCancelBtn() {
		this.close();
	}

	// * PREPARES MULTISELECT PICKLIST DATA FOR UPDATE
	changeMultiSelectList(event) {
		const value = event.detail.value;

		this.formData = {
			...this.formData,
			[event.currentTarget.name]: value.join(';'),
		};
	}

	// * CALLS SAVE APEX METHOD
	clickSaveBtn() {
		const allValidLI = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			let valid = inputCmp.checkValidity();

			if (valid) {
				inputCmp.parentElement.className = inputCmp.parentElement.className.replace('customError', '');
			} else {
				inputCmp.parentElement.className = inputCmp.parentElement.className.includes('customError')
					? inputCmp.parentElement.className
					: inputCmp.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		const allValidLTA = [...this.template.querySelectorAll('lightning-textarea')].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			let valid = inputCmp.checkValidity();

			if (valid) {
				inputCmp.parentElement.className = inputCmp.parentElement.className.replace('customError', '');
			} else {
				inputCmp.parentElement.className = inputCmp.parentElement.className.includes('customError')
					? inputCmp.parentElement.className
					: inputCmp.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		const allValidLCB = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, inputCmp) => {
			let valid = true;
			if (inputCmp.name !== 'document') {
				inputCmp.reportValidity();
				valid = inputCmp.checkValidity();

				if (valid) {
					inputCmp.parentElement.className = inputCmp.parentElement.className.replace('customError', '');
				} else {
					inputCmp.parentElement.className = inputCmp.parentElement.className.includes('customError')
						? inputCmp.parentElement.className
						: inputCmp.parentElement.className + ' customError';
				}
			}
			return validSoFar && valid;
		}, true);

		let allValidMS = true;

		if (this.isDesktop) {
			allValidMS = [...this.template.querySelectorAll('lightning-dual-listbox')].reduce((validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				let valid = inputCmp.checkValidity();

				if (valid) {
					inputCmp.parentElement.className = inputCmp.parentElement.className.replace('customError', '');
				} else {
					inputCmp.parentElement.className = inputCmp.parentElement.className.includes('customError')
						? inputCmp.parentElement.className
						: inputCmp.parentElement.className + ' customError';
				}

				return validSoFar && valid;
			}, true);
		} else {
			allValidMS = [...this.template.querySelectorAll('select')].reduce((validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				let valid = inputCmp.checkValidity();

				if (valid) {
					inputCmp.parentElement.className = inputCmp.parentElement.className.replace('customError', '');
				} else {
					inputCmp.parentElement.className = inputCmp.parentElement.className.includes('customError')
						? inputCmp.parentElement.className
						: inputCmp.parentElement.className + ' customError';
				}

				return validSoFar && valid;
			}, true);
		}

		if (allValidLI && allValidLTA && allValidLCB && allValidMS) {
			const inputfields = [...this.template.querySelectorAll('lightning-input')];
			const textareafields = [...this.template.querySelectorAll('lightning-textarea')];
			const selectfields = [...this.template.querySelectorAll('lightning-combobox')];
			const multiSelectfields = [...this.template.querySelectorAll('select')];

			for (let i = 0; i < inputfields.length; i++) {
				let value = '';
				if (inputfields[i].type === 'checkbox') {
					value = inputfields[i].checked;
				} else {
					value = inputfields[i].value === '' || inputfields[i].value === undefined ? null : inputfields[i].value;
				}

				this.formData = {
					...this.formData,
					[inputfields[i].name]: value,
				};
			}

			for (let i = 0; i < textareafields.length; i++) {
				const isBlank = textareafields[i].value === '' || textareafields[i].value === undefined;
				this.formData = {
					...this.formData,
					[textareafields[i].name]: isBlank ? null : textareafields[i].value,
				};
			}

			for (let i = 0; i < selectfields.length; i++) {
				if (selectfields[i].name !== 'document') {
					this.formData = {
						...this.formData,
						[selectfields[i].name]: selectfields[i].value,
					};
				}
			}

			if (!this.isDesktop) {
				multiSelectfields.forEach((inputCmp) => {
					let values = [];
					for (let i = 0; i < inputCmp.selectedOptions.length; i++) {
						values.push(inputCmp.selectedOptions[i].value);
					}
					this.formData[inputCmp.name] = values.length > 0 ? values.join(';') : '';
				});
			}

			if (this.contactId) {
				this.formData = {
					...this.formData,
					Id: this.contactId,
				};
			}

			this.formData = {
				...this.formData,
				AccountId: this.accountId,
				OwnerId: this.account.OwnerId,
			};

			this.saving = true;

			upsertContact({ conString: JSON.stringify(this.formData) })
				.then((resp) => {
					if (resp) {
						this.saving = false;
						this.showToast(this.labels.successTitle, this.config.popupSuccessMessage, 'success');
						refreshApex(this.wiredSectionResult);
						this.close();
					}
				})
				.catch((error) => {
					this.saving = false;
					let errorMessage = error.body.message;
					if (errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') && errorMessage.indexOf(': [')) {
						errorMessage = errorMessage.substring(errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') + 35, errorMessage.indexOf(': ['));
					}
					this.showNotification(this.labels.errorTitle, errorMessage, 'error');
				});
		}
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
			multiSelectAvailable,
			multiSelectSelected,
		};
		return {
			...label,
			...this.config,
		};
	}
}