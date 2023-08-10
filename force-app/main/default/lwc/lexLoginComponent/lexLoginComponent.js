import { LightningElement, track, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

import loginUser from '@salesforce/apex/LEXCommunityLoginController.loginUser';

import header from '@salesforce/resourceUrl/header';
import { loadStyle } from 'lightning/platformResourceLoader';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import closeButton from '@salesforce/label/c.LEXCommunity_Close_Button';

export default class lexLoginComponent extends LightningElement {
	@track showTiles = true;
	@track showLoginTile = false;
	@track isLoading = false;
	@track errorMessage;
	@api redirectURLtile1;
	@api redirectURLtile2;
	@api redirectURLtile3;
	@api redirectURLForgotPassword;
	@api header;
	@api headerColor;
	@api defaultTilebackgroundColor;
	@api description;
	@api tiletitle1;
	@api tiletitle2;
	@api tiletitle3;
	@api showTile1;
	@api showTile2;
	@api showTile3;
	@api forgotpasswordlabel;
	@api loginButtonLabel;
	@api footer;
	@api showTile3Login;
	@api showTile2Login;
	@api showTile1Login;
	@api usernameLoginLabel;
	@api passwordLoginLabel;
	@api largesize;
	@api tileColor;
	@api selectedtileColor;
	@api selectedTile;
	@api invalidInputErrorMessage;

	connectedCallback() {
		if (window.location.href.includes('selectedTile=1')) {
			this.handleLoginScreen();
		}

		Promise.all([loadStyle(this, header)]);
	}

	get headerCSS() {
		return this.headerColor && this.headerColor ? 'color:' + this.headerColor : 'color:rgb(84, 105, 141)';
	}

	handleLoginScreen(event) {
		let tile = event.currentTarget.id;
		this.selectedTile = tile.substring(0, 5);
		if (tile.substring(0, 5) == 'tile1') {
			if (this.showTile1Login == true) {
				this.showLoginTile = true;
			} else {
				window.location.href = this.redirectURLtile1;
			}
		} else if (tile.substring(0, 5) == 'tile2') {
			if (this.showTile2Login == true) {
				this.showLoginTile = true;
			} else {
				window.location.href = this.redirectURLtile2;
			}
		} else if (tile.substring(0, 5) == 'tile3') {
			if (this.showTile3Login == true) {
				this.showLoginTile = true;
			} else {
				window.location.href = this.redirectURLtile3;
			}
		}
	}
	handleForgotPassword(event) {
		window.location.href = this.redirectURLForgotPassword;
	}

	keyCodeChecker(component, event, helper) {
		if (component.which == 13) {
			this.handleLogin();
		}
	}

	handleLogin() {
		const username = this.template.querySelector('input[name=email]').value;
		const password = this.template.querySelector('input[name=password]').value;
		if (username !== undefined && username !== '' && username !== null && password !== undefined && password !== '' && password !== null) {
			this.isLoading = true;
			loginUser({
				username,
				password,
			})
				.then((resp) => {
					window.location.href = resp;
					this.errorMessage = undefined;
					this.isLoading = false;
				})
				.catch((err) => {
					this.isLoading = false;
					if (err.body.message === 'Your login attempt has failed. Make sure the username and password are correct.') {
						this.errorMessage = this.invalidInputErrorMessage;
					} else {
						this.errorMessage = err.body.message;
					}
				});
		}
	}

	handleErrorClose() {
		this.errorMessage = undefined;
	}

	get tile1CSS() {
		return this.showLoginTile && this.selectedTile == 'tile1' ? this.selectedTileCSS : this.notSelectedTileCSS;
	}

	get tile2CSS() {
		return this.showLoginTile && this.selectedTile == 'tile2' ? this.selectedTileCSS : this.notSelectedTileCSS;
	}

	get tile3CSS() {
		return this.showLoginTile && this.selectedTile == 'tile3' ? this.selectedTileCSS : this.notSelectedTileCSS;
	}

	get tiletextCSS() {
		return this.tileColor ? 'color:' + this.tileColor : 'color:rgb(84, 105, 141)';
	}

	get tileborderCSS1() {
		if (this.showLoginTile && this.selectedTile == 'tile1') {
			return this.selectedtileColor
				? 'border: 1px solid ' + this.selectedtileColor + ';background-color:' + this.selectedtileColor
				: 'border: 1px solid rgb(84, 105, 141);background-color:rgb(84, 105, 141);';
		} else {
			return this.tileColor
				? 'border: 1px solid ' + this.defaultTilebackgroundColor + ';background-color:' + this.defaultTilebackgroundColor
				: 'border: 1px solid rgb(84, 105, 141)';
		}
	}
	get tileborderCSS2() {
		if (this.showLoginTile && this.selectedTile == 'tile2') {
			return this.selectedtileColor
				? 'border: 1px solid ' + this.selectedtileColor + ';background-color:' + this.selectedtileColor
				: 'border: 1px solid rgb(84, 105, 141);background-color:rgb(84, 105, 141);';
		} else {
			return this.tileColor
				? 'border: 1px solid ' + this.defaultTilebackgroundColor + ';background-color:' + this.defaultTilebackgroundColor
				: 'border: 1px solid rgb(84, 105, 141)';
		}
	}
	get tileborderCSS3() {
		if (this.showLoginTile && this.selectedTile == 'tile3') {
			return this.selectedtileColor
				? 'border: 1px solid ' + this.selectedtileColor + ';background-color:' + this.selectedtileColor
				: 'border: 1px solid rgb(84, 105, 141);background-color:rgb(84, 105, 141);';
		} else {
			return this.tileColor
				? 'border: 1px solid ' + this.defaultTilebackgroundColor + ';background-color:' + this.defaultTilebackgroundColor
				: 'border: 1px solid rgb(84, 105, 141)';
		}
	}

	get largeDeviceSize() {
		if (this.showTile1 == true && this.showTile2 == true && this.showTile3 == true) {
			this.largesize = 4;
		} else if (
			(this.showTile1 == true && this.showTile2 == true) ||
			(this.showTile1 == true && this.showTile3 == true) ||
			(this.showTile2 == true && this.showTile3 == true)
		) {
			this.largesize = 6;
		} else {
			this.largesize = 12;
		}
		return this.largesize;
	}

	get notSelectedTileCSS() {
		if (FORM_FACTOR === 'Large') return 'tile fixed-height slds-grid slds-grid_vertical-align-center slds-grid_align-space';
		else return 'tile slds-grid slds-grid_vertical-align-center slds-grid_align-space';
	}

	get selectedTileCSS() {
		if (FORM_FACTOR === 'Large') return 'selected-tile fixed-height slds-grid slds-grid_vertical-align-center slds-grid_align-space';
		else return 'selected-tile slds-grid slds-grid_vertical-align-center slds-grid_align-space';
	}

	get containerCSS() {
		if (FORM_FACTOR === 'Large') return this.showLoginTile ? 'container-width-half' : 'container-width';
		else return 'mobile-container-width';
	}

	get label() {
		return {
			errorTitle,
			closeButton,
		};
	}
}