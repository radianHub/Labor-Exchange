import { LightningElement, api } from 'lwc';

import { loadStyle } from 'lightning/platformResourceLoader';
import header from '@salesforce/resourceUrl/header';

export default class lexCheckPassword extends LightningElement {
	@api header;
	@api returnbuttonLabel;
	@api headerColor;
	@api redirectURL;
	@api footer;
	@api description;

	connectedCallback() {
		Promise.all([loadStyle(this, header)]);
	}

	get headerCSS() {
		return this.headerColor && this.headerColor ? 'color:' + this.headerColor : 'color:rgb(84, 105, 141)';
	}

	handleCheckPassword() {
		window.location.href = this.redirectURL;
	}
}