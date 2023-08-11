// STANDARD IMPORTS
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// CONTROLLERS
// import createUpdateRequestTask from '@salesforce/apex/LEXCandidateApplicationsController.createUpdateRequestTask';

// CUSTOM LABELS
import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

export default class LEXParticipantUpdateRequest extends LightningElement {
	@api recordId;
	@api config;
	@track isLoading = false;
	@track value;

	handleCommentChange(event) {
		this.value = event.detail.value;
	}

	// handleSendRequest() {
	// 	this.isLoading = true;

	// 	createUpdateRequestTask({
	// 		applicationId: this.recordId,
	// 		comments: this.value,
	// 	})
	// 		.then((resp) => {
	// 			if (resp) {
	// 				this.showNotification(this.label.successTitle, this.config.successMessage, 'success');
	// 				this.isLoading = false;
	// 				this.handleCancel();
	// 			}
	// 		})
	// 		.catch((error) => {
	// 			this.isLoading = false;
	// 			this.showNotification(this.label.errorTitle, error.body.message, 'error');
	// 		});
	// }

	handleCancel() {
		this.dispatchEvent(new CustomEvent('close', { bubbles: true }));
	}

	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	get disableUpdate() {
		return this.value === undefined || this.value === '' || this.value === null;
	}

	get label() {
		return {
			successTitle,
			errorTitle,
		};
	}

	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}
}