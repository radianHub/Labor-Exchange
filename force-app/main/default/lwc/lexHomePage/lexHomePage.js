import { LightningElement, track, wire, api } from 'lwc';

import getHomePageTileInfo from '@salesforce/apex/LEXHomePageController.getHomePageTileInfo';

import errorTitle from '@salesforce/label/c.LEXCommunity_Error_Title';
import closeButton from '@salesforce/label/c.LEXCommunity_Close_Button';

export default class LEXHomePage extends LightningElement {
	@api config;
	@track homeTiles;
	@track isLoading = true;
	@track errorMessage;

	@wire(getHomePageTileInfo)
	wiredGetHomePageTileInfo({ error, data }) {
		if (data) {
			this.homeTiles = data;
			this.isLoading = false;
		} else if (error) {
			console.log(error);
			this.errorMessage = error.body.message;
			this.isLoading = false;
		}
	}

	handleErrorClose() {
		this.errorMessage = undefined;
	}

	get label() {
		return {
			closeButton,
			errorTitle,
		};
	}

	get headerCSS() {
		return this.config && this.config.headerColor ? 'color:' + this.config.headerColor : 'color:rgb(84, 105, 141)';
	}
}