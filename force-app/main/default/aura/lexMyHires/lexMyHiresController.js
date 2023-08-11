({
	doInit: function (component, event, helper) {
		const config = {
			header: component.get('v.header'),
			headerColor: component.get('v.headerColor'),
			tile1Name: component.get('v.tile1Name'),
			tile2Name: component.get('v.tile2Name'),
			tile3Name: component.get('v.tile3Name'),
			tile4Name: component.get('v.tile4Name'),
			showTile1: component.get('v.showTile1'),
			showTile2: component.get('v.showTile2'),
			showTile3: component.get('v.showTile3'),
			showTile4: component.get('v.showTile4'),
			applicationListHeader: component.get('v.applicationListHeader'),
			description: component.get('v.description'),
			showRedirectButton: component.get('v.showRedirectButton'),
			redirectButtonLabel: component.get('v.redirectButtonLabel'),
			redirectButtonRedirectUrl: component.get('v.redirectButtonRedirectUrl'),
			showContactUsButton: component.get('v.showContactUsButton'),
			contactUsButtonLabel: component.get('v.contactUsButtonLabel'),
			contactUsHeader: component.get('v.contactUsHeader'),
			contactUsDescription: component.get('v.contactUsDescription'),
			contactUsPlaceholderText: component.get('v.contactUsPlaceholderText'),
			contactUsSubmitButtonLabel: component.get('v.contactUsSubmitButtonLabel'),
			contactUsCancelButtonLabel: component.get('v.contactUsCancelButtonLabel'),
			contactUsSuccessMessage: component.get('v.contactUsSuccessMessage'),
			noJobApplicationMessage: component.get('v.noJobApplicationMessage'),
		};

		component.set('v.config', config);
	},
	handleApplicationsTileClicked: function (component, event) {
		component.set('v.hiresData', event.getParam('hiresData'));
		component.set('v.hireFields', event.getParam('hireFields'));
	},
});