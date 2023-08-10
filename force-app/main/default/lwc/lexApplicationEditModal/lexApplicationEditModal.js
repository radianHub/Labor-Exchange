import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// * CONTROLLERS
import getPicklistValues from '@salesforce/apex/LEXCandidateApplicationsController.getPicklistValues';
import getResumes from '@salesforce/apex/LEXCandidateApplicationsController.getResumes';
import updateApplication from '@salesforce/apex/LEXCandidateApplicationsController.updateApplication';

// * CUSTOM MODALS
import LexJobEditModal from 'c/lexJobEditModal';
import LexCandidateEmailModal from 'c/lexCandidateEmail';

// * CUSTOM EVENTS
import { RefreshApexEvent } from './event.js';

export default class LexApplicationEditModal extends LightningModal {
	@api application;
	@api job;
	@api labels;
	@api isDesktop;
	@api config;

	@track data = [];
	@track saveData = {};
	@track saveMode = true;
	@track recordId;
	@track contactId;
	@track picklistData = [];
	@track documentList = [];

	loading = true;
	saving = false;

	// # LIFECYCLE HOOKS

	// * SETUP INCOMING DATA
	connectedCallback() {
		this.recordId = this.application.key;
		this.contactId = this.application.contactId;

		let appData = this.application.details.map((field) => {
			let fieldMap = {};
			if (field.type === 'PICKLIST' || field.type === 'MULTIPICKLIST') {
				this.picklistData.push({ field: field.fieldApiName });
			}
			fieldMap = {
				...field,
				isText: field.type === 'STRING',
				isEmail: field.type === 'EMAIL',
				isDate: field.type === 'DATE' || field.type === 'DATETIME',
				isCheckbox: field.type === 'BOOLEAN',
				isNumber: field.type === 'DOUBLE' || field.type === 'PERCENT' || field.type === 'CURRENCY',
				isPhone: field.type === 'PHONE',
				isTextArea: field.type === 'TEXTAREA',
				isPicklist: field.type === 'PICKLIST',
				isMultiPicklist: field.type === 'MULTIPICKLIST',
				isUrl: field.type === 'URL',
				type: field.type === 'DOUBLE' ? 'decimal' : field.type.toLowerCase(),
			};
			return fieldMap;
		});

		if (this.picklistData.length != 0) {
			this.picklistData.forEach((field) => {
				getPicklistValues({ objName: 'Launchpad__Applicant_Tracking__c', field: field.field })
					.then((result) => {
						appData = appData.map((e) => {
							if (e.fieldApiName === field.field) {
								return {
									...e,
									options: result,
								};
							} else {
								return {
									...e,
								};
							}
						});
					})
					.catch((err) => {
						console.log(JSON.parse(JSON.stringify(err.message)));
						this.showToast(this.labels.errorTitle, err.body.message, 'error');
					});
			});
		}
		setTimeout(() => {
			this.data = appData;
		}, 1500);

		this.getRelatedDocs();
	}

	// # APEX

	// * FETCHES RELATED DOCUMENTS
	getRelatedDocs() {
		getResumes({ applicationId: this.recordId })
			.then((result) => {
				if (result) {
					this.documentList = result;
				}
			})
			.catch((err) => {
				this.showToast(this.labels.errorTitle, err.body.message, 'error');
			})
			.finally(() => {
				this.loading = false;
			});
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

	// * SETS THE VALUE FOR A MULTISELECT PICKLIST
	changeMultiSelectList(e) {
		const value = e.detail.value;

		this.data = this.data.map((field) => {
			return field.fieldApiName === e.detail.name ? { ...field, value: value.join(';') } : { ...field };
		});
	}

	// * ENABLES EDIT MODE
	clickEditBtn() {
		this.saveMode = false;
	}

	// * ENABLES SAVE MODE AND UPDATES THE RECORD
	clickSaveBtn() {
		this.saveMode = true;
		this.saving = true;
		const validLI = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, inp) => {
			inp.reportValidity();
			let valid = inp.checkValidity();

			if (valid) {
				inp.parentElement.className = inp.parentElement.className.replace('customError', '');
			} else {
				inp.parentElement.className = inp.parentElement.className.includes('customError')
					? inp.parent.className
					: inp.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		const validLTA = [...this.template.querySelectorAll('lightning-textarea')].reduce((validSoFar, inp) => {
			inp.reportValidity();
			let valid = inp.checkValidity();

			if (valid) {
				inp.parentElement.className = inp.parentElement.className.replace('customError', '');
			} else {
				inp.parentElement.className = inp.parentElement.className.includes('customError')
					? inp.parent.className
					: inp.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		const validLCB = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, inp) => {
			inp.reportValidity();
			let valid = inp.checkValidity();

			if (valid) {
				inp.parentElement.className = inp.parentElement.className.replace('customError', '');
			} else {
				inp.parentElement.className = inp.parentElement.className.includes('customError')
					? inp.parent.className
					: inp.parentElement.className + ' customError';
			}

			return validSoFar && valid;
		}, true);

		let validMS = true;
		if (this.isDesktop) {
			validMS = [...this.template.querySelectorAll('lightning-dual-listbox')].reduce((validSoFar, inp) => {
				inp.reportValidity();
				let valid = inp.checkValidity();

				if (valid) {
					inp.parentElement.className = inp.parentElement.className.replace('customError', '');
				} else {
					inp.parentElement.className = inp.parentElement.className.includes('customError')
						? inp.parent.className
						: inp.parentElement.className + ' customError';
				}

				return validSoFar && valid;
			}, true);
		} else {
			validMS = [...this.template.querySelectorAll('select')].reduce((validSoFar, inp) => {
				inp.reportValidity();
				let valid = inp.checkValidity();

				if (valid) {
					inp.parentElement.className = inp.parentElement.className.replace('customError', '');
				} else {
					inp.parentElement.className = inp.parentElement.className.includes('customError')
						? inp.parent.className
						: inp.parentElement.className + ' customError';
				}

				return validSoFar && valid;
			}, true);
		}

		if (validLI && validLTA && validLCB && validMS) {
			const inpFields = [...this.template.querySelectorAll('lightning-input')];
			const taFields = [...this.template.querySelectorAll('lightning-textarea')];
			const plFields = [...this.template.querySelectorAll('lightning-combobox')];
			const multiFields = [...this.template.querySelectorAll('select')];

			for (let i = 0; i < inpFields.length; i++) {
				const isBlank = inpFields[i].value === '' || inpFields[i].value === undefined;
				this.data = this.data.map((field) => {
					return inpFields[i].name === field.fieldApiName
						? { ...field, value: isBlank && inp[i].type !== 'checkbox' ? null : inpFields[i].value }
						: { ...field };
				});
			}
			for (let i = 0; i < taFields.length; i++) {
				const isBlank = taFields[i].value === '' || taFields[i].value === undefined;
				this.data = this.data.map((field) => {
					return taFields[i].name === field.fieldApiName
						? { ...field, value: isBlank && inp[i].type !== 'checkbox' ? null : taFields[i].value }
						: { ...field };
				});
			}
			for (let i = 0; i < plFields.length; i++) {
				this.data = this.data.map((field) => {
					return plFields[i].name === field.fieldApiName ? { ...field, value: plFields[i].value } : { ...field };
				});
			}

			if (!this.isDesktop) {
				console.log('this.data:', JSON.parse(JSON.stringify(this.data)));

				console.log('Running Mobile section...');
				this.data = this.data.map((field) => {
					console.log('field', JSON.parse(JSON.stringify(field)));
					if (multiFields.length > 0) {
						multiFields.forEach((inp) => {
							console.log('multiFields:', multiFields);

							console.log('inp.title:', inp.title);
							console.log('field.fieldApiName:', field.fieldApiName);

							if (inp.title === field.fieldApiName) {
								let values = [];
								for (let i = 0; i < inp.selectedOptions.length; i++) {
									values.push(inp.selectedOptions[i].value);
								}
								return { ...field, value: value.length > 0 ? values.join(';') : '' };
							} else {
								return { ...field };
							}
						});
					} else {
						return field;
					}
				});
			}
		}
		console.log('this.data:', JSON.parse(JSON.stringify(this.data)));

		this.data.forEach((field) => {
			this.saveData[field.fieldApiName] = field.value;
		});

		this.saveData = {
			...this.saveData,
			Id: this.recordId,
		};

		updateApplication({ applicationJson: JSON.stringify(this.saveData) })
			.then((result) => {
				this.showToast(this.labels.successTitle, 'Application successfully updated!', 'success');
				this.dispatchEvent(new RefreshApexEvent());
				console.log('refreshapex fired in lexApplicationEditModal');
				this.close();
				this.saving = false;
			})
			.catch((err) => {
				this.showToast(this.labels.errorTitle, err.body.message, 'error');
				this.saving = false;
			});
	}

	// * OPENS THE JOB EDIT MODAL
	async clickPreviewJobBtn() {
		const r = await LexJobEditModal.open({
			size: 'medium',
			accountId: this.job.accountId,
			job: this.job.job,
			jobId: this.job.jobId,
			fields: this.job.jobFields,
			labels: this.labels,
			mode: 'preview',
		}).then((result) => {
			if (result === 'close') {
				this.close();
			}
		});
	}

	// * DOWNLOADS A RESUME IS AVAILABLE
	clickDownloadBtn() {
		const downloadContainer = this.template.querySelector('.download-container');
		const downloadUrl = 'data:application/pdf;base64,' + this.documentList[0].encodedData;
		const fileName = this.documentList[0].documentTitle + '.pdf';

		let a = document.createElement('a');
		a.href = downloadUrl;
		a.target = '_parent';
		a.download = fileName;
		if (downloadContainer) {
			downloadContainer.appendChild(a);
		}
		if (a.click) {
			a.click();
		}
		downloadContainer.removeChild(a);
	}

	// * OPENS THE CONTACT JOB SEEKER MODAL
	handleEmailCandidate() {
		LexCandidateEmailModal.open({
			label: 'Contact Info',
			size: 'small',
			candidateId: this.contactId,
			config: this.config,
		})
			.then((result) => {})
			.catch((error) => {
				console.log('handleEmailCandidate error: ' + error);
			});
	}

	// * CLOSES THE MODAL
	clickCancelBtn() {
		this.close();
	}

	// # GETTERS/SETTERS

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loading || this.saving) {
			return true;
		}
		return false;
	}

	// * RETURNS TRUE IF THERE IS A RELATED DOCUMENT
	get hasDocument() {
		return this.documentList.length > 0;
	}

	// * CHECKS FOR MOBILE AND APPLIES FLOAT-RIGHT
	get floatRight() {
		return this.isDesktop ? 'floatRight' : '';
	}

	// * CHECKS FORM FACTOR AND SETS HEADER PADDING DEPENDING OF MOBILE OR DESKTOP
	get headerPadding() {
		return this.isDesktop ? 'around-medium' : 'horizontal-medium';
	}
}