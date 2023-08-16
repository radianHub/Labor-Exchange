import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import updateSkills from '@salesforce/apex/MultiSkillSelectionController.updateSkills';

export default class LexJobEditModal extends LightningModal {
	@api accountId;
	@api job;
	@api jobId;
	@api fields;
	@api labels;
	@api mode;

	@track data = [];
	@track skillData;
	@track activeSkills = [];

	loading = true;
	saving = false;

	showEditField = false;

	// * BUILDS A DATA ARRAY ON LOAD
	connectedCallback() {
		if (this.job !== undefined) {
			[...this.fields].forEach((field) => {
				let value;
				if (!field.fieldApiName.includes('.')) {
					value = this.job[field.fieldApiName];
				} else {
					const tempArray = field.fieldApiName.split('.');
					value = this.job[tempArray[0]][tempArray[1]];
				}
				this.data.push({
					name: field.fieldApiName,
					label: field.fieldLabel,
					type: field.fieldType,
					required: field.required,
					value,
				});
			});
		} else {
			[...this.fields].forEach((field) => {
				this.data.push({
					name: field.fieldApiName,
					label: field.fieldLabel,
					type: field.fieldType,
					required: field.required,
				});
			});
		}

		if (this.mode === 'create' || this.mode === 'edit') {
			this.showEditField = true;
		}

		this.loading = false;
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

	clickEditBtn() {
		this.mode = 'edit';
		this.showEditField = true;
		// this.showEditField = !this.showEditField;
	}

	clickBackBtn() {
		this.close('back');
	}

	// * CLOSES THE MODAL ON CLICK OF CLOSE/BACK
	clickCancelBtn() {
		this.close('close');
	}

	// * SAVES/DELETES RELATED JOB SKILLS WHEN A RECORD IS UPDATED OR CREATED SUCCESSFULLY
	successfulRecordSave(e) {
		let recId = e.detail.id;

		let skillsToCreate = [],
			skillsToDelete = [];
		if (this.skillData) {
			for (const selected of this.skillData.selected) {
				if (!this.activeSkills.includes(selected)) {
					skillsToCreate.push(selected);
				}
			}
			for (const unselected of this.skillData.unselected) {
				if (this.activeSkills.includes(unselected)) {
					skillsToDelete.push(unselected);
				}
			}
		}

		if (skillsToCreate.length > 0 || skillsToDelete.length > 0) {
			updateSkills({ recordId: recId, skillsToCreate: skillsToCreate, skillsToDelete: skillsToDelete })
				.then((result) => {
					if (this.isCreate) {
						this.showToast(this.labels.successTitle, this.labels.createSaveMsg, 'success');
					} else if (this.isEdit) {
						this.showToast(this.labels.successTitle, this.labels.editSaveMsg, 'success');
					}
					this.dispatchEvent(new CustomEvent('refreshapex'));
					this.close(recId);
				})
				.catch((err) => {
					this.showToast(this.labels.errorTitle, err.body.message, 'error');
					this.saving = false;
				})
				.finally(() => {
					this.saving = false;
				});
		} else {
			this.showToast(this.labels.successTitle, this.labels.editSaveMsg, 'success');
			this.dispatchEvent(new CustomEvent('refreshapex'));
			this.close(recId);
			this.saving = false;
		}
	}

	handleError() {
		this.saving = false;
	}

	// * SUBMITS A RECORD FOR UPDATE/CREATION ON CLICK OF SAVE BUTTON
	saveRecordForm(e) {
		e.preventDefault();
		this.saving = true;
		let fields = e.detail.fields;
		if (this.isCreate) {
			fields.Launchpad__Account__c = this.accountId;
		}
		this.template.querySelector('lightning-record-edit-form').submit(fields);
	}

	// * SETS THE SKILL DATA PROPERTY ON ACTIVATION/DEACTIVATION OF A SKILL
	selectSkillEvent(e) {
		this.skillData = e.detail;
	}

	// * SETS THE ACTIVE SKILLS PROPERTY WHEN SKILLS ARE LOADED
	loadSkillEvent(e) {
		this.activeSkills = e.detail;
	}

	// # GETTERS/SETTERS

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loading || this.saving) {
			return true;
		}
		return false;
	}

	// * RETURNS TRUE IF THE MODAL IS IN A "CREATE" MODE
	get isCreate() {
		return this.mode === 'create';
	}

	// * RETURNS TRUE IF THE MODAL IS IN AN "EDIT" MODE
	get isEdit() {
		return this.mode === 'edit';
	}

	// * RETURNS TRUE IF THE MODAL IS IN AN "PREVIEW" MODE
	get isPreview() {
		return this.mode === 'preview';
	}

	get isSave() {
		return this.isCreate || this.isEdit;
	}

	// * RETURNS TRUE IS THE USER IS ON A MOBILE DEVICE
	get isMobile() {
		return FORM_FACTOR === 'Small';
	}

	get bodyStyling() {
		return this.isMobile ? '' : 'modal-body slds-grid slds-wrap slds-gutters';
	}

	// * SETS THE FIELD COLUMN SIZE BASED ON THE USERS DEVICE SIZE
	get fieldCSS() {
		return this.isMobile ? 'slds-col slds-size_1-of-1 field' : 'slds-col slds-size_1-of-2 field';
	}

	// * SETS AND RETURNS THE MODAL HEADER
	get headerLabel() {
		if (this.isCreate) {
			return 'Create Job';
		} else if (this.isEdit) {
			return 'Edit Job';
		} else if (this.isPreview) {
			return 'Preview Job';
		}
		return 'Job';
	}

	// * SETS THE HEADER COLOR IF NO COLOR HAS BEEN SET IN THE COMPONENT PROPERTIES
	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}
}