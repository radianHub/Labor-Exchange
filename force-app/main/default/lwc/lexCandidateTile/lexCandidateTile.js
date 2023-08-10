import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
import LexCandidateEmailModal from 'c/lexCandidateEmail';

import successTitle from '@salesforce/label/c.LEXCommunity_Success_Title';
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

import { ViewEvent } from './event.js';

export default class lexCandidateTile extends LightningElement {
	@api record;
	@api fields;
	@api viewFields;
	@api viewType;
	@api candidateConfig;
	@track data = [];
	@track isLoading = false;
	@track showEmailModal = false;
	@track isJustContacted = false;

	connectedCallback() {
		this.fields.forEach((field) => {
			var value;
			if (!field.fieldApiName.includes('.')) {s
			} else {
				const tempArray = field.fieldApiName.split('.');
				value = this.record.candidate[tempArray[0]][tempArray[1]];
			}
			this.data.push({
				label: field.fieldLabel,
				type: field.fieldType,
				value,
			});
		});
	}

	handleViewDetails() {
		this.dispatchEvent(
			new ViewEvent({
				candidate: { ...this.record.candidate },
				fields: [...this.viewFields],
				applied: this.record.applied,
			})
		);
	}

	handleEmailCandidate() {
		LexCandidateEmailModal.open({
			label: 'Contact Info',
			size: 'small',
			candidateId: this.record.candidate.Id,
			config: this.candidateConfig,
		})
			.then((result) => {})
			.catch((error) => {
				console.log('handleEmailCandidate error: ' + error);
			});
	}

	handleEmailSent() {
		this.isJustContacted = true;
		this.handleCloseModal();
	}

	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	//no fields seem appropriate for title/subtitle if not displaying Name of Candidate
	get details() {
		return this.data !== undefined ? this.data : [];
	}

	//create String from Client_Skills related to the Contact
	get skillsString() {
		let skills;

		//check for nulls
		if (this.record && this.record.candidate && this.record.candidate.Launchpad__Client_Skills__r) {
			//simplify
			let skillsArray = this.record.candidate.Launchpad__Client_Skills__r;
			//check for records in the array
			if (skillsArray.length > 0) {
				skills = '';
				let isFirst = true; // if First, no leading comma is needed
				skillsArray.forEach((skill) => {
					if (isFirst) {
						skills = skills + skill.Launchpad__Skill1__r.Name;
						isFirst = false;
					} else {
						skills = skills + ', ' + skill.Launchpad__Skill1__r.Name;
					}
				});
			}
		}
		//return String of comma-separated Skills
		return skills;
	}

	get label() {
		return {
			successTitle,
			errorTitle,
			matchScoreLabel: this.candidateConfig.myCandidatesMatchScoreLabel,
			viewDetailsBtnLabel: this.candidateConfig.viewDetailsButtonLabel,
			/*saveBtnLabel: this.candidateConfig.saveCandidateButtonLabel,
            savedBtnLabel: this.candidateConfig.savedCandidateButtonLabel,*/
			imInterestedBtnLabel: this.candidateConfig.applyCandidateButtonLabel,
			alreadyAppliedBtnLabel: this.candidateConfig.appliedCandidateButtonLabel,
			//,removeSavedBtnLabel: this.candidateConfig.removeCandidateButtonLabel
		};
	}

	get isContacted() {
		return this.isJustContacted || this.record.applied;
	}

	get candidateContainerCSS() {
		return FORM_FACTOR !== 'Large'
			? 'desc-container-mobile slds-p-vertical_large slds-p-horizontal_large'
			: 'desc-container slds-p-vertical_large slds-p-horizontal_large';
	}

	get showRemoveCandidateBtn() {
		return this.viewType !== undefined && this.viewType === 'SavedCandidates';
	}

	get headerCSS() {
		return this.candidateConfig && this.candidateConfig.candidateTileHeaderColor
			? 'background-color:' + this.candidateConfig.candidateTileHeaderColor
			: 'background-color:rgb(235, 235, 235)';
	}

	get showFooter() {
		return this.candidateConfig?.showApplyCandidateButton !== undefined ? this.candidateConfig.showApplyCandidateButton : true;
	}

	get footerCSS() {
		return FORM_FACTOR !== 'Large' ? 'footer2-container-mobile' : 'footer2-container';
	}
	get footerStyle() {
		return this.candidateConfig && this.candidateConfig.candidateTileFooterColor
			? 'background-color:' + this.candidateConfig.candidateTileFooterColor
			: 'background-color:rgb(180, 188, 201)';
	}
}