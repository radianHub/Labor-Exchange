import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { SentEvent } from './event.js';

import emailCandidate from '@salesforce/apex/LEXCandidateSearchController.emailCandidate';
import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

export default class LexContactJobSeeker extends LightningModal {
	@api config;
	@api candidateId;

	messageBody;

	isLoading = false;

	// # APEX

	// * SEND EMAIL BODY TO CANDIDATE
	emailCandidate() {
		this.isLoading = true;

		emailCandidate({ candidateId: this.candidateId, emailBody: this.messageBody })
			.then(() => {
				this.showNotification(successTitle, 'Your request has been sent!', 'success');
				this.dispatchEvent(new SentEvent());
				this.close();
			})
			.catch((error) => {
				this.showNotification(errorTitle, error.body.message, 'error');
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	// # HANDLERS

	// * SETS MESSAGE
	handleChangeMessageBody(event) {
		this.messageBody = event.detail.value;
	}

	// * SENDS MESSAGE TO PASSED IN RECORD
	handleClickSend() {
		this.emailCandidate();
	}

	// # PRIVATE FUNCTIONS

	// * SHOW TOAST NOTIFICATION
	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	// * CLOSES MODAL
	handleClickClose() {
		this.close();
	}

	// # GETTERS

	// * MODAL HEADER TEXT
	get modalHeader() {
		return this.config?.modalHeader ? this.config.modalHeader : 'Send Email';
	}

	// * MODAL MESSAGE LABEL
	get messageLabel() {
		return this.config?.messageLabel ? this.config.messageLabel : 'Please add a message to send';
	}

	// * SEND BUTTON LABEL
	get sendButtonLabel() {
		return this.config?.sendButtonLabel ? this.config.sendButtonLabel : 'Send';
	}

	// * CLOSE BUTTON LABEL
	get closeButtonLabel() {
		return this.config?.closeButtonLabel ? this.config.closeButtonLabel : 'Close';
	}

	// * SETS HEADER COLOR IF SET OR SETS DEFAULT COLOR
	get headerCSS() {
		return this.labels && this.labels.headerColor ? 'color: ' + this.labels.headerColor : 'color: rgb(84,105,141)';
	}
}