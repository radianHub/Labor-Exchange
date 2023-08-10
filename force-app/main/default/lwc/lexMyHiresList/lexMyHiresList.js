// * SALESFORCE IMPORTS
import { LightningElement, track, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// * CONTROLLERS
// import getSetupData from '@salesforce/apex/LEXCandidateApplicationsController.getSetupData';

// * CUSTOM EVENTS
// import { UpdateRequestEvent } from './event.js';

// * CUSTOM LABELS
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';

export default class LexMyHiresList extends LightningElement {
	@api config;

	@api hiresData;
	@api hireFields;

	@track convertedHiresData;

	@track loadingData = false;

	hiresFound = false;

	renderedCallback() {
		if (this.hiresData) {
			this.hiresFound = Object.keys(this.hiresData).length === 0 ? false : true;
		}
	}

	//	 * HANDLERS
	// handleUpdateRequest(event) {
	// 	this.dispatchEvent(new UpdateRequestEvent({ recordId: event.target.name }));
	// }

	// * HELPERS
	showNotification(title, message, variant) {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
		});
		this.dispatchEvent(evt);
	}

	// * GETTERS
	get label() {
		return {
			errorTitle,
		};
	}
	get isDesktop() {
		return FORM_FACTOR === 'Large';
	}

	get showButtonColumn() {
		return this.config && (this.config.showRedirectButton || this.config.showContactUsButton);
	}

	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}

	get isLoading() {
		if (this.loadingData) {
			return true;
		}
		return false;
	}
}