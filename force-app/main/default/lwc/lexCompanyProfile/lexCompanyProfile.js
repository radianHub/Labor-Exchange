import { LightningElement, wire, track, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getSections from '@salesforce/apex/LEXCompanyProfileController.getSections';
import save from '@salesforce/apex/LEXCompanyProfileController.save';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import multiSelectAvailable from '@salesforce/label/c.LEXCommunity_Multi_Select_Available';
import multiSelectSelected from '@salesforce/label/c.LEXCommunity_Multi_Select_Selected';

export default class LexCompanyProfile extends LightningElement {
	@api config;
	@track sections = [];
	@track wiredSectionResult;
	@track showEditBtn = true;
	@track account;
	accountId;
	formData = {};

	loadingData = true;
	savingData = false;

	// * ASSIGNS VALUES TO INPUT FIELDS
	renderedCallback() {
		if (this.account) {
			[...this.template.querySelectorAll('lightning-input')].forEach((inputCmp) => {
				inputCmp.value = this.account[inputCmp.name];
			});

			[...this.template.querySelectorAll('lightning-textarea')].forEach((inputCmp) => {
				inputCmp.value = this.account[inputCmp.name];
			});

			[...this.template.querySelectorAll('lightning-combobox')].forEach((inputCmp) => {
				if (inputCmp.name !== 'document') {
					inputCmp.value = this.account[inputCmp.name];
				}
			});

			if (this.isDesktop) {
				[...this.template.querySelectorAll('lightning-dual-listbox')].forEach((inputCmp) => {
					const valueStr = this.account[inputCmp.name];
					inputCmp.value = valueStr ? valueStr.split(';') : undefined;
				});
			} else {
				[...this.template.querySelectorAll('select')].forEach((inputCmp) => {
					const valueStr = this.account[inputCmp.name];
					var options = valueStr.split(';');
					for (let i = 0, l = inputCmp.options.length, o; i < l; i++) {
						o = inputCmp.options[i];
						if (options.indexOf(o.text) !== -1) {
							o.selected = true;
						}
					}
				});
			}

			if (!this.showEditBtn) {
				this.clickEditButton();
			}
		}
	}

	// # APEX

	// * GETS ACCOUNT DATA
	@wire(getSections)
	wiredGetSections(result) {
		this.wiredSectionResult = result;
		if (result.data) {
			for (const key in result.data) {
				if (Object.hasOwnProperty.call(result.data, key)) {
					if (key === 'myAccount') {
						this.accountId = result.data[key].Id;
					}
				}
			}
			this.sections = result.data.sections;
			this.account = result.data.myAccount;
			this.loadingData = false;
		} else if (result.error) {
			this.showToast(this.label.errorTitle, result.error.body.message, 'error');
			this.loadingData = false;
		}
	}

	// # PRIVATE METHODS

	// * DISPLAYS A TOAST MESSAGE
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

	// * ENABLES THE USER TO EDIT THEIR PROFILE DATA
	clickEditButton() {
		[...this.template.querySelectorAll('lightning-input')].forEach((inputCmp) => {
			inputCmp.disabled = inputCmp.readOnly ? true : false;
		});

		[...this.template.querySelectorAll('lightning-textarea')].forEach((inputCmp) => {
			inputCmp.disabled = inputCmp.readOnly ? true : false;
		});

		[...this.template.querySelectorAll('lightning-combobox')].forEach((inputCmp) => {
			if (inputCmp.name !== 'document') {
				inputCmp.disabled = inputCmp.className.includes('editable') ? false : true;
			}
		});

		if (this.isDesktop) {
			[...this.template.querySelectorAll('lightning-dual-listbox')].forEach((inputCmp) => {
				inputCmp.disabled = inputCmp.readOnly ? true : false;
			});
		} else {
			[...this.template.querySelectorAll('select')].forEach((inputCmp) => {
				inputCmp.disabled = inputCmp.readOnly ? true : false;
			});
		}

		this.showEditBtn = false;
	}

	// * CANCELS 'EDIT' MODE BY REDIRECTING/REFRESHING TO PAGE
	clickCancelButton() {
		window.location.href = this.config.redirectMyProfileURL;
	}

	// * PREPARES MULTISELECT PICKLIST DATA FOR UPDATE
	changeMultiSelectList(event) {
		const value = event.detail.value;

		this.formData = {
			...this.formData,
			[event.currentTarget.name]: value.join(';'),
		};
	}

	// * DOES A VALIDITY CHECK AND CALLS THE APEX METHOD TO UPDATE THE ACCOUNT RECORD
	clickSaveButton() {
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

		if (allValidLI && allValidLCB && allValidLTA && allValidMS) {
			const inputFields = [...this.template.querySelectorAll('lightning-input')];
			const textAreaFields = [...this.template.querySelectorAll('lightning-textarea')];
			const selectFields = [...this.template.querySelectorAll('lightning-combobox')];
			const multiSelectFields = [...this.template.querySelectorAll('select')];

			for (let i = 0; i < inputFields.length; i++) {
				const isBlank = inputFields[i].value === '' || inputFields[i].value === undefined;
				this.formData = {
					...this.formData,
					[inputFields[i].name]: isBlank && inputFields[i].type !== 'checkbox' ? null : inputFields[i].value,
				};
			}

			for (let i = 0; i < textAreaFields.length; i++) {
				const isBlank = textAreaFields[i].value === '' || textAreaFields[i].value === undefined;
				this.formData = {
					...this.formData,
					[textAreaFields[i].name]: isBlank ? null : textAreaFields[i].value,
				};
			}

			for (let i = 0; i < selectFields.length; i++) {
				this.formData = {
					...this.formData,
					[selectFields[i].name]: selectFields[i].value,
				};
			}

			if (!this.isDesktop) {
				multiSelectFields.forEach((inputCmp) => {
					let values = [];
					for (let i = 0; i < inputCmp.selectedOptions.length; i++) {
						values.push(inputCmp.selectedOptions[i].value);
					}
					this.formData[inputCmp.name] = values.length > 0 ? values.join(';') : '';
				});
			}

			this.formData = {
				...this.formData,
				Id: this.account.Id,
			};

			this.loadingData = true;

			save({ accString: JSON.stringify(this.formData) })
				.then((result) => {
					if (result) {
						this.showEditBtn = true;
						this.loadingData = false;
						this.showToast(this.label.successTitle, this.config.successMessage, 'success');
						refreshApex(this.wiredSectionResult);
					}
				})
				.catch((error) => {
					this.loadingData = false;
					this.showEditBtn = false;
					let errorMessage = error.body.message;
					if (errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') && errorMessage.indexOf(': [')) {
						errorMessage = errorMessage.substring(errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') + 35, errorMessage.indexOf(': ['));
					}
					this.showToast(this.label.errorTitle, errorMessage, 'error');
				});
		} else {
			this.showToast(this.label.errorTitle, this.config.requiredFieldMessage, 'error');
		}
	}

	// # GETTERS/SETTERS

	// * CHECKS IF DATA IS LOADING OR SAVING
	get isLoading() {
		if (this.loadingData || this.savingData) {
			return true;
		}
		return false;
	}

	// * CHECKS FORM FACTOR FOR DESKTOP
	get isDesktop() {
		return FORM_FACTOR === 'Large';
	}

	// * CHECKS FORM FACTOR FOR MOBILE
	get isMobile() {
		return FORM_FACTOR === 'Small';
	}

	// * CHECKS FORM FACTOR AND SETS HEADER PADDING DEPENDING OF MOBILE OR DESKTOP
	get headerPadding() {
		return FORM_FACTOR === 'Large' ? 'around-medium' : 'horizontal-medium';
	}

	// * CHECKS FOR MOBILE AND APPLIES FLOAT-RIGHT
	get floatRight() {
		return this.isMobile ? '' : 'floatRight';
	}

	// * CHECKS IF A HEADER COLOR IS SET, IF NOT SETS A DEFAULT
	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}

	// * CHECKS IF A SUBHEADER COLOR IS SET, IF NOT SETS A DEFAULT
	get subheaderCSS() {
		return this.config && this.config.subheaderColor ? 'color:' + this.config.subheaderColor : 'color:rgb(84, 105, 141)';
	}

	// * RELABELS SELECT CONFIG ITEMS AND ADDS CUSTOM LABELS
	get label() {
		const label = {
			successTitle,
			errorTitle,
			multiSelectAvailable,
			multiSelectSelected,
		};
		return {
			...label,
			header: this.config.header,
			description: this.config.description,
			editButtonLabel: this.config.editButtonLabel,
			saveButtonLabel: this.config.saveButtonLabel,
			cancelButtonLabel: this.config.cancelButtonLabel,
			requiredFieldMsg: this.config.requiredFieldMessage,
		};
	}
}