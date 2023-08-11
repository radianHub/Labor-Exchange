import { LightningElement, api } from 'lwc';

export default class lexHomePageTile extends LightningElement {
	@api tile;

	get imageStyle() {
		// return 'background-image: url("' + this.tile.Image_Link__c + '");';
		return 'background-image: url("' + this.tile.LaunchpadCo__Image_Link__c + '");';
	}

	get target() {
		// return this.tile.Open_in_New_Tab__c ? '_blank' : '_self';
		return this.tile.LaunchpadCo__Open_in_New_Tab__c ? '_blank' : '_self';
	}
}