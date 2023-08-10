import { LightningElement, api, track, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import basepath from '@salesforce/community/basePath';

import header from '@salesforce/resourceUrl/header';
import { loadStyle } from 'lightning/platformResourceLoader';

import getStaticResource from '@salesforce/apex/LEXSelfRegistrationBodyController.getStaticResource';

export default class LEXSelfRegistrationHeader extends LightningElement {
	@api staticResource;
	@api loginButtonLabel;
	@api loginUrl;
	@track logoUrl;

	connectedCallback() {
		Promise.all([loadStyle(this, header)]);
	}

	@wire(getStaticResource, { staticResource: '$staticResource' })
	wiredGetStaticResource({ error, data }) {
		if (data) {
			let str = basepath,
				delimiter = '/';
			let tokens = str.split(delimiter);
			this.logoUrl = (tokens.length === 4 ? tokens.slice(0, 2).join(delimiter) : '') + data;
		} else {
			console.log('ERROR:', error);
		}
	}

	get label() {
		return {
			loginButton: this.loginButtonLabel,
			backToHome: this.backButtonLabel,
		};
	}

	get isDesktop() {
		return FORM_FACTOR === 'Large';
	}

	get size() {
		return this.isDesktop ? '9' : '9';
	}

	get loginButtonCSS() {
		return FORM_FACTOR !== 'Large' ? 'slds-button slds-button_brand' : 'slds-button slds-button_brand';
	}

	get loginCSS() {
		return FORM_FACTOR !== 'Large' ? 'float:right;margin-right: 8%;' : 'float:right;margin-right: 8%;';
	}
}