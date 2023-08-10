import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

import getMatch from '@salesforce/apex/LEXCandidateSearchController.getMatch';
import contactJobSeekerModal from 'c/lexContactJobSeeker';

export default class LexMatchTile extends LightningElement {
	@api record;
	@api fields;
	@track data = [];
	isJustContacted = false;

	@api config;

	// # LIFECYCLE METHODS

	connectedCallback() {
		this.fields.forEach((field) => {
			let value;
			let apiName = field.fieldApiName;

			if (!apiName.includes('.')) {
				value = this.record[apiName];
			} else {
				let tempArray = field.fieldApiName.split('.');
				value = this.record[tempArray[0]][tempArray[1]];
			}

			value = field.fieldType === 'PERCENT' ? value / 100 : value;

			this.data.push({
				label: field.fieldLabel,
				type: field.fieldType,
				value,
			});
		});
	}

	// # APEX

	// * GET MATCH CLIENT ID
	@wire(getMatch, { matchId: '$record.Id' })
	wiredMatch({ data, error }) {
		if (data) {
			this.candidateId = data.Launchpad__Client__c;
		} else if (error) {
			console.log(error);
			this.showNotification(errorTitle, error.body.message, 'error');
		}
	}

	// # HANDLERS
	// * OPENS SEND EMAIL MODAL
	handleEmailCandidate() {
		contactJobSeekerModal.open({
			candidateId: this.candidateId,
			size: 'small',
			config: {
				modalHeader: this.config.contactCandidateModalHeader,
				messageLabel: this.config.contactCandidateMessageLabel,
				sendButtonLabel: this.config.contactCandidateSendButtonLabel,
				closeButtonLabel: this.config.contactCandidateCloseButtonLabel,
			},
			onsent: (e) => {
				e.stopPropagation();
				this.handleEmailSent();
			},
		});
	}

	// * HANDLES EVENT AFTER EMAIL IS SENT
	handleEmailSent() {
		// this.isJustContacted = true;
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

	// # GETTERS

	// * TILE TITLE
	get title() {
		return this.data !== undefined ? this.data[0].value : '';
	}

	// * TILE SUBTITLE
	get subTitle() {
		return this.data !== undefined ? this.data[1].value : '';
	}

	// * TILE BODY DETAILS
	get details() {
		return this.data !== undefined && this.data.length > 2 ? this.data.slice(2) : [];
	}

	// * MARKS IF A MATCH HAS BEEN CONTACTED
	get isContacted() {
		return this.isJustContacted;
	}

	// * LABEL FOR ENABLED CONTACT BUTTON
	get contactButtonLabel() {
		return this.isContacted ? this.config.alreadyContactedMatchButtonLabel : this.config.contactMatchButtonLabel;
	}

	// * LABEL FOR DISABLED CONTACT BUTTON
	get contactButtonDisabled() {
		return this.isContacted ? true : false;
	}

	// * CUSTOM HEADER STYLING
	get headerCSS() {
		return this.config && this.config.matchTileHeaderColor ? 'background-color:' + this.config.matchTileHeaderColor : 'background-color:rgb(235, 235, 235)';
	}

	// * DETERMINES IF TILE FOOTER IS DISPLAYED
	get showFooter() {
		return this.config?.showContactCandidateFooter !== undefined ? this.config.showContactCandidateFooter : true;
	}

	// * CUSTOM FOOTER STYLING
	get footerCSS() {
		return FORM_FACTOR !== 'Large' ? 'footer2-container-mobile' : 'footer2-container';
	}

	// * CUSTOM FOOTER STYLING
	get footerStyle() {
		return this.config && this.config.matchTileFooterColor ? 'background-color:' + this.config.matchTileFooterColor : 'background-color:rgb(180, 188, 201)';
	}

	// * CUSTOM CONTAINER STYLING
	get candidateContainerCSS() {
		return FORM_FACTOR !== 'Large'
			? 'desc-container-mobile slds-p-vertical_large slds-p-horizontal_large'
			: 'desc-container slds-p-vertical_large slds-p-horizontal_large';
	}
}