import { LightningElement, track, api } from 'lwc';

// * APEX CONTROLLERS
import forgotPassword from '@salesforce/apex/LEXForgotPasswordController.forgotPassword';

// * CUSTOM LABELS
import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import closeButton from '@salesforce/label/c.LEXCommunity_Close_Button';

import { loadStyle } from 'lightning/platformResourceLoader';
import header from '@salesforce/resourceUrl/header';

export default class lexTest extends LightningElement {
	@track isLoading = false;
	@track resultData;
	@api redirectURL;
	@api header;
	@api description;
	@api userNameLabel;
	@api resetbuttonLabel;
	@api errorMessage;
	@api cancelbuttonLabel;
	@api headerColor;
	@api redirectURLCheckPassword;
	@track showerror;
	@api footer;

	// * CALLBACK METHODS
	connectedCallback() {
		Promise.all([loadStyle(this, header)]);
	}

	// * HANDLERS
	handleErrorClose() {
		this.showerror = false;
	}

	handleErrorCancel() {
		window.location.href = this.redirectURL;
	}

	handleResetPassword() {
		let userName = this.template.querySelector('[data-id="input-9"]').value;
		forgotPassword({ username: userName })
			.then((result) => {
				this.resultData = result;
				if (this.resultData == false) {
					this.showerror = true;
				} else if (this.resultData == true) {
					window.location.href = this.redirectURLCheckPassword;
				}
			})
			.catch((error) => {
				this.showerror = true;
				console.log('ERROR:', error.body.message);
			});
	}

	// * GETTERS
	get label() {
		return {
			closeButton,
			errorTitle,
		};
	}

	get headerCSS() {
		return this.headerColor && this.headerColor ? 'color:' + this.headerColor : 'color:rgb(84, 105, 141)';
	}
}