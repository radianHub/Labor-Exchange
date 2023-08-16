import { LightningElement, wire, track, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

import { AgreementEvent } from './event.js';

import header from '@salesforce/resourceUrl/header';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getSections from '@salesforce/apex/LEXSelfRegistrationBodyController.getSections';
import checkForDupeAccounts from '@salesforce/apex/LEXSelfRegistrationBodyController.checkForDupeAccounts';
import checkForDupeContactsUsers from '@salesforce/apex/LEXSelfRegistrationBodyController.checkForDupeContactsUsers';
import registerUser from '@salesforce/apex/LEXSelfRegistrationBodyController.registerUser';

import multiSelectAvailable from '@salesforce/label/c.LEXCommunity_Multi_Select_Available';
import multiSelectSelected from '@salesforce/label/c.LEXCommunity_Multi_Select_Selected';
import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import closeButton from '@salesforce/label/c.LEXCommunity_Close_Button';

export default class LEXSelfRegistrationBody extends LightningElement {
	@api agreed = false;
	@api config;
	@track sections = [];
	@track isLoading = true;
	@track errorMessage;
	@track infoMessage;
	@track showDupeCheck = true;
	@track redirectOnErrorClose = false;
	@track authorizationCheck = false;
	@track disableAuthCheck = true;
	loadPage2 = false;
	form1Data = {};
	form2Data = {};
	@track accountData = {};
	@track contactData = {};

	connectedCallback() {
		Promise.all([loadStyle(this, header)]);
	}

	renderedCallback() {
		if (!this.showDupeCheck && this.form1Data !== {} && this.loadPage2) {
			this.template.querySelectorAll('lightning-input').forEach((inputComponent) => {
				inputComponent.value = this.form1Data[inputComponent.name];
			});

			this.template.querySelectorAll('lightning-textarea').forEach((inputComponent) => {
				inputComponent.value = this.form1Data[inputComponent.name];
			});

			this.template.querySelectorAll('lightning-combobox').forEach((inputComponent) => {
				inputComponent.value = this.form1Data[inputComponent.name];
			});

			if (this.isDesktop) {
				this.template.querySelectorAll('lightning-dual-listbox').forEach((inputComponent) => {
					inputComponent.value = this.form1Data[inputComponent.name];
				});
			} else {
				this.template.querySelectorAll('select').forEach((inputComponent) => {
					inputComponent.value = this.form1Data[inputComponent.name];
				});
			}

			this.loadPage2 = false;
		}
	}

	@wire(getSections, {
		birthdayMessage: '$config.minimumMaximumAgeerrorMessage',
	})
	wiredgetSections({ error, data }) {
		if (data) {
			this.sections = data;
			this.isLoading = false;
		} else if (error) {
			this.errorMessage = error.body.message;
			location.href = '#errorId-1';
			this.isLoading = false;
		}
	}

	handleAuthorizationCheck(event) {
		this.authorizationCheck = event.target.checked;
	}

	handleAuthorizationClick() {
		//this.disableAuthCheck = false;
		this.dispatchEvent(new AgreementEvent());
	}

	handleMultiSelectChange(event) {
		const value = event.detail.value;

		if (this.showDupeCheck && event.currentTarget.dataset.isAccountSection) {
			this.accountData = {
				...this.accountData,
				[event.currentTarget.name]: value.join(';'),
			};
			this.form1Data = {
				...this.form1Data,
				[event.currentTarget.name]: value.join(';'),
			};
		} else if (this.showDupeCheck && !event.currentTarget.dataset.isAccountSection) {
			this.contactData = {
				...this.contactData,
				[event.currentTarget.name]: value.join(';'),
			};
			this.form2Data = {
				...this.form2Data,
				[event.currentTarget.name]: value.join(';'),
			};
		}
	}

	handleDupeCheck(event) {
		event.preventDefault();
		this.errorMessage = undefined;
		let email;
		let accountName;
		try {
			if (this.template.querySelector('lightning-input[data-name=Email]') != null) {
				email = this.template.querySelector('lightning-input[data-name=Email]').value;
			} else if (this.template.querySelector('lightning-input[data-name=Name]') != null) {
				accountName = this.template.querySelector('lightning-input[data-name=Name]').value;
			}
		} catch (error) {
			console.log('ERROR: ' + error.body.message);
		}

		const inputfields = [...this.template.querySelectorAll('lightning-input')];
		const textareafields = [...this.template.querySelectorAll('lightning-textarea')];
		const selectfields = [...this.template.querySelectorAll('lightning-combobox')];
		const multiSelectfields = [...this.template.querySelectorAll('select')];

		const allValidLI = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, inputComponent) => {
			inputComponent.reportValidity();
			let valid = inputComponent.checkValidity();

			if (valid) {
				inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
			} else {
				inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
					? inputComponent.parentElement.className
					: inputComponent.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		const allValidLTA = [...this.template.querySelectorAll('lightning-textarea')].reduce((validSoFar, inputComponent) => {
			inputComponent.reportValidity();
			let valid = inputComponent.checkValidity();

			if (valid) {
				inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
			} else {
				inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
					? inputComponent.parentElement.className
					: inputComponent.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		const allValidLCB = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, inputComponent) => {
			inputComponent.reportValidity();
			let valid = inputComponent.checkValidity();

			if (valid) {
				inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
			} else {
				inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
					? inputComponent.parentElement.className
					: inputComponent.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		let allValidMS = true;

		if (this.isDesktop) {
			allValidMS = [...this.template.querySelectorAll('lightning-dual-listbox')].reduce((validSoFar, inputComponent) => {
				inputComponent.reportValidity();
				let valid = inputComponent.checkValidity();

				if (valid) {
					inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
				} else {
					inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
						? inputComponent.parentElement.className
						: inputComponent.parentElement.className + ' customError';
				}

				return validSoFar && valid;
			}, true);
		} else {
			allValidMS = [...this.template.querySelectorAll('select')].reduce((validSoFar, inputComponent) => {
				inputComponent.reportValidity();
				let valid = inputComponent.checkValidity();

				if (valid) {
					inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
				} else {
					inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
						? inputComponent.parentElement.className
						: inputComponent.parentElement.className + ' customError';
				}

				return validSoFar && valid;
			}, true);
		}

		// Perform account dupe check
		if (allValidLI && allValidLTA && allValidLCB && allValidMS && accountName != null) {
			this.isLoading = true;

			checkForDupeAccounts({
				accountName,
			})
				.then((resp) => {
					if (resp.dupeAccountFound) {
						this.errorMessage = this.config.existingAccountMessage;
						location.href = '#errorId-1';
						setTimeout(function () {
							window.location.href = this.config.redirectURlLogin + '?selectedTile=1';
						}, 20000);
					} else {
						this.showDupeCheck = false;
						this.errorMessage = undefined;
					}

					inputfields.forEach((inputComponent) => {
						let isAccountSection = inputComponent.dataset.isAccountSection;
						if (isAccountSection) {
							this.accountData[inputComponent.name] = inputComponent.value;
						} else if (isAccountSection != null) {
							this.contactData[inputComponent.name] = inputComponent.value;
						}
						this.form1Data[inputComponent.name] = inputComponent.value;
					});

					textareafields.forEach((inputComponent) => {
						if (inputComponent.dataset.isAccountSection) {
							this.accountData[inputComponent.name] = inputComponent.value;
						} else if (!inputComponent.dataset.isAccountSection) {
							this.contactData[inputComponent.name] = inputComponent.value;
						}
						this.form1Data[inputComponent.name] = inputComponent.value;
					});

					selectfields.forEach((inputComponent) => {
						if (inputComponent.dataset.isAccountSection) {
							this.accountData[inputComponent.name] = inputComponent.value;
						} else if (!inputComponent.dataset.isAccountSection) {
							this.contactData[inputComponent.name] = inputComponent.value;
						}
						this.form1Data[inputComponent.name] = inputComponent.value;
					});

					if (!this.isDesktop) {
						multiSelectfields.forEach((inputComponent) => {
							let values = [];
							for (let i = 0; i < inputComponent.selectedOptions.length; i++) {
								values.push(inputComponent.selectedOptions[i].value);
							}
							if (inputComponent.dataset.isAccountSection) {
								this.accountData[inputComponent.name] = values.length > 0 ? values.join(';') : '';
							} else if (!inputComponent.dataset.isAccountSection) {
								this.contactData[inputComponent.name] = values.length > 0 ? values.join(';') : '';
							}
							this.form1Data[inputComponent.name] = values.length > 0 ? values.join(';') : '';
						});
					}

					this.isLoading = false;
					this.loadPage2 = true;
				})
				.catch((error) => {
					this.isLoading = false;
					this.errorMessage = error.body.message;
					location.href = '#errorId-1';
				});

			// Perform contact dupe check
		} else if (allValidLI && allValidLTA && allValidLCB && allValidMS && email != null) {
			this.isLoading = true;

			checkForDupeContactsUsers({
				email,
			})
				.then((resp) => {
					if (resp.dupeContact || resp.dupeActiveUserFound) {
						this.errorMessage = this.config.existingContactMessage;
						location.href = '#errorId-1';
						setTimeout(function () {
							window.location.href = this.config.redirectURlLogin + '?selectedTile=1';
						}, 20000);
					} else {
						this.showDupeCheck = false;
						this.errorMessage = undefined;
					}

					inputfields.forEach((inputComponent) => {
						this.addToContactOrAccountData(inputComponent, null);
					});

					textareafields.forEach((inputComponent) => {
						this.addToContactOrAccountData(inputComponent, null);
					});

					selectfields.forEach((inputComponent) => {
						this.addToContactOrAccountData(inputComponent, null);
					});

					if (!this.isDesktop) {
						multiSelectfields.forEach((inputComponent) => {
							let values = [];
							for (let i = 0; i < inputComponent.selectedOptions.length; i++) {
								values.push(inputComponent.selectedOptions[i].value);
							}
							// if isAccountSection, add to account fields
							if (inputComponent.dataset.isAccountSection) {
								this.accountData[inputComponent.name] = values.length > 0 ? values.join(';') : '';
							} else if (!inputComponent.dataset.isAccountSection) {
								this.contactData[inputComponent.name] = values.length > 0 ? values.join(';') : '';
							}
							this.form1Data[inputComponent.name] = values.length > 0 ? values.join(';') : '';
						});
					}

					this.isLoading = false;
					this.loadPage2 = true;
				})
				.catch((error) => {
					this.isLoading = false;
					if (this.errorMessage === this.config.existingContactMessage) {
						this.showError(this.errorMessage);
					} else {
						this.showError(error.body.message);
					}
					location.href = '#errorId-1';
				});
		} else {
			this.errorMessage = this.config.requiredFieldMessage;
			location.href = '#errorId-1';
		}
	}

	handleSubmit(event) {
		event.preventDefault();
		this.handleDupeCheck(event);
		this.errorMessage = undefined;
		const allValidLI = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, inputComponent) => {
			inputComponent.reportValidity();
			let valid = inputComponent.checkValidity();

			if (valid) {
				inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
			} else {
				inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
					? inputComponent.parentElement.className
					: inputComponent.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		const allValidLTA = [...this.template.querySelectorAll('lightning-textarea')].reduce((validSoFar, inputComponent) => {
			inputComponent.reportValidity();
			let valid = inputComponent.checkValidity();

			if (valid) {
				inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
			} else {
				inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
					? inputComponent.parentElement.className
					: inputComponent.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		const allValidLCB = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, inputComponent) => {
			inputComponent.reportValidity();
			let valid = inputComponent.checkValidity();

			if (valid) {
				inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
			} else {
				inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
					? inputComponent.parentElement.className
					: inputComponent.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		let allValidMS = true;

		if (this.isDesktop) {
			allValidMS = [...this.template.querySelectorAll('lightning-dual-listbox')].reduce((validSoFar, inputComponent) => {
				inputComponent.reportValidity();
				let valid = inputComponent.checkValidity();

				if (valid) {
					inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
				} else {
					inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
						? inputComponent.parentElement.className
						: inputComponent.parentElement.className + ' customError';
				}

				return validSoFar && valid;
			}, true);
		} else {
			allValidMS = [...this.template.querySelectorAll('select')].reduce((validSoFar, inputComponent) => {
				inputComponent.reportValidity();
				let valid = inputComponent.checkValidity();

				if (valid) {
					inputComponent.parentElement.className = inputComponent.parentElement.className.replace('customError', '');
				} else {
					inputComponent.parentElement.className = inputComponent.parentElement.className.includes('customError')
						? inputComponent.parentElement.className
						: inputComponent.parentElement.className + ' customError';
				}

				return validSoFar && valid;
			}, true);
		}

		if (allValidLI && allValidLTA && allValidLCB && allValidMS) {
			const password = this.template.querySelector('lightning-input[data-name=Password]').value;
			const confirmPassword = this.template.querySelector('lightning-input[data-name=ConfirmPassword]').value;

			if (password === confirmPassword) {
				const inputfields = [...this.template.querySelectorAll('lightning-input')];
				const textareafields = [...this.template.querySelectorAll('lightning-textarea')];
				const selectfields = [...this.template.querySelectorAll('lightning-combobox')];
				const multiSelectfields = [...this.template.querySelectorAll('select')];

				for (let i = 0; i < inputfields.length; i++) {
					if (inputfields[i].name !== 'Password' && inputfields[i].name !== 'ConfirmPassword' && inputfields[i].name !== 'authorization') {
						this.addToContactOrAccountData(inputfields, i);
					} else if (inputfields[i].name === 'Password') {
						this.form2Data = { ...this.form2Data, ...inputfields[i].name };
					}
				}

				for (let i = 0; i < textareafields.length; i++) {
					this.addToContactOrAccountData(textareafields, i);
				}

				for (let i = 0; i < selectfields.length; i++) {
					this.addToContactOrAccountData(selectfields, i);
				}

				if (!this.isDesktop) {
					multiSelectfields.forEach((inputComponent) => {
						let values = [];
						for (let i = 0; i < inputComponent.selectedOptions.length; i++) {
							values.push(inputComponent.selectedOptions[i].value);
						}
						if (inputComponent.dataset.isAccountSection) {
							this.accountData[inputComponent.name] = values.length > 0 ? values.join(';') : '';
						} else if (!inputComponent.dataset.isAccountSection) {
							this.contactData[inputComponent.name] = values.length > 0 ? values.join(';') : '';
						}
						this.form2Data[inputComponent.name] = values.length > 0 ? values.join(';') : '';
					});
				}

				this.isLoading = true;
				registerUser({
					contactString: JSON.stringify(this.contactData),
					accountString: JSON.stringify(this.accountData),
					password,
					contactRecordType: this.config.contactrecordtypeassignment,
					accountRecordType: this.config.accountrecordtypeassignment,
					profileId: this.config.userprofileassignment,
				})
					.then((resp) => {
						if (resp) {
							window.location.href = resp;
							this.isLoading = false;
						}
					})
					.catch((error) => {
						console.log('CONTACT ERROR:', error.body.message);
						if (this.errorMessage === this.config.existingContactMessage) {
							this.showError(this.errorMessage);
						} else {
							this.errorMessage = error.body.message;
							this.showError(this.errorMessage);
						}
						location.href = '#errorId-1';
					});
			} else {
				this.errorMessage = this.config.passwordMismatchError;
				location.href = '#errorId-1';
			}
		} else {
			this.errorMessage = this.config.requiredFieldMessage;
			location.href = '#errorId-1';
		}
	}

	handleErrorClose() {
		this.errorMessage = undefined;

		if (this.redirectOnErrorClose) {
			window.location.href = this.config.redirectURlLogin;
		}
	}

	// # HELPERS

	// * Method purpose: general purpose toast for errors
	showError(error) {
		console.log('error message:', error);
		this.showNotification('Error', error, 'error', 'dismissable');
	}

	// * Method purpose: general purpose toast for successes
	showSuccess(message) {
		this.showNotification('Success', message, 'success', 'dismissable');
	}

	// * Method purpose: general purpose toast
	showNotification(title, message, variant, mode = 'dismissable') {
		const event = new ShowToastEvent({
			title,
			message,
			variant,
			mode,
		});
		try {
			this.dispatchEvent(event);
		} catch (error) {
			console.log(error);
		}
	}

	addToContactOrAccountData(inputComponent, iterator) {
		if (iterator == null) {
			let isAccountSection = inputComponent.dataset.isAccountSection;
			if (isAccountSection === 'true') {
				this.accountData[inputComponent.name] = inputComponent.value;
			} else if (isAccountSection === 'false') {
				this.contactData[inputComponent.name] = inputComponent.value;
			}
			this.form1Data[inputComponent.name] = inputComponent.value;
		} else {
			let isAccountSection = inputComponent[iterator].dataset.isAccountSection;
			if (isAccountSection === 'true') {
				this.accountData = {
					...this.accountData,
					[inputComponent[iterator].name]: inputComponent[iterator].value,
				};
			} else if (isAccountSection === 'false') {
				this.contactData = {
					...this.contactData,
					[inputComponent[iterator].name]: inputComponent[iterator].value,
				};
			}
			this.form2Data = {
				...this.form2Data,
				[inputComponent[iterator].name]: inputComponent[iterator].value,
			};
		}
	}

	// # GETTERS

	get passwordSectionCSS() {
		return (this.sections.length - 1) % 2 === 0 ? '' : 'evenBG';
	}

	get authSectionCSS() {
		return (this.sections.length - 1) % 2 === 0 ? 'evenBG' : '';
	}

	get footerCSS() {
		return FORM_FACTOR !== 'Small' ? 'footerCSS' : 'mobileFooterCSS';
	}

	get isDesktop() {
		return FORM_FACTOR === 'Large';
	}

	get headerPadding() {
		return FORM_FACTOR === 'Large' ? 'around-medium' : 'horizontal-medium';
	}

	get notificationCSS() {
		return FORM_FACTOR !== 'Small' ? 'slds-notify_container' : 'slds-notify_container mobileNotification';
	}

	get showauth() {
		return this.config.authorizationChbkLabelshow;
	}

	get registerDisabled() {
		if (this.config.authorizationChbkLabelshow) {
			return !this.agreed;
		}
		return false;
	}

	get contentCSS() {
		return this.showDupeCheck && FORM_FACTOR !== 'Small' ? 'flex-container container' : 'flex-container';
	}

	get headerCSS() {
		return this.config.Headercolor ? 'color:' + this.config.Headercolor : 'color:rgb(84, 105, 141)';
	}

	get subheaderCSS() {
		return this.config.Descriptioncolor ? 'color:' + this.config.Descriptioncolor : 'color:rgb(84, 105, 141)';
	}

	get header() {
		return this.showDupeCheck ? this.config.Page1Header : this.config.Page2Header;
	}

	get description() {
		return this.showDupeCheck ? this.config.Page1Description : this.config.Page2Description;
	}

	get stepText() {
		return this.showDupeCheck ? this.config.step1of2 : this.config.step2of2;
	}

	get label() {
		const label = {
			multiSelectAvailable,
			multiSelectSelected,
			successTitle,
			errorTitle,
			closeButton,
		};
		return {
			...label,
			requiredFieldMsg: this.config.requiredFieldMsg,
			footer: this.config.footer,
			registerBtn: this.config.registerBtn,
			nextStepBtn: this.config.nextStepBtn,
			passwordSectionTitle: this.config.passwordSectionTitle,
			passwordLabel: this.config.passwordLabel,
			confirmPasswordLabel: this.config.confirmPasswordLabel,
			authorizationChbkLabel: this.config.authorizationChbkLabel,
		};
	}
}