import LightningModal from 'lightning/modal';
import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { SentEvent } from './event.js';

import emailCandidate from '@salesforce/apex/LEXCandidateSearchController.emailCandidate';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

export default class LEXCandidateEmail extends LightningModal {
	@api candidateId;
	@api config;
	isLoading = false;
	emailBody = '';

	closeModal() {
		this.close();
	}

	sendEmail() {
		this.isLoading = true;
		const value = this.template.querySelectorAll('lightning-textarea')[0].value;
		this.emailBody = value;
		//process email
		emailCandidate({
			candidateId: this.candidateId,
			emailBody: value,
		})
			.then((result) => {
				//show confirmation to user, and notify tile
				this.isLoading = false;
				this.showNotification('Success', 'Your request has been sent!', 'success');
				this.dispatchEvent(new SentEvent());
				this.closeModal();
			})
			.catch((error) => {
				//show error
				this.isLoading = false;
				this.showNotification(this.labels.errorTitle, error.body.message, 'error');
			});
	}

	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	get labels() {
		const label = {
			errorTitle,
		};
		return {
			...label,
			...this.config,
		};
	}

	// * SETS HEADER COLOR IF SET OR SETS DEFAULT COLOR
	get headerCSS() {
		return this.labels && this.labels.headerColor ? 'color: ' + this.labels.headerColor : 'color: rgb(84,105,141)';
	}
}