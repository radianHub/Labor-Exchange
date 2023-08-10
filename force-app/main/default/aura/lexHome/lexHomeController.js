({
	doInit: function (component, event, helper) {
		const config = {
			header: component.get('v.header'),
			headerColor: component.get('v.headerColor'),
			description: component.get('v.description'),
		};

		component.set('v.config', config);

		const eventConfig = {
			headerColor: component.get('v.headerColor'),
			eventTileHeaderColor: component.get('v.eventTileHeaderColor'),
			eventTileFooterColor: component.get('v.eventTileFooterColor'),
			watchVideoEventButtonLabel: component.get('v.watchVideoEventButtonLabel'),
			registerEventButtonLabel: component.get('v.registerEventButtonLabel'),
			registerEventRedirectUrl: component.get('v.registerEventRedirectUrl'),
			registerEventSuccessMessage: component.get('v.registerEventSuccessMessage'),
			alreadyRegisteredEventButtonLabel: component.get('v.alreadyRegisteredEventButtonLabel'),
			filterField: component.get('v.availableinCommunityEventPage'),
			priorityFilterField: component.get('v.communityPriorityEvent'),
			downloadDocuments: component.get('v.downloadDocuments'),
			searchFilterFields: null,
		};

		component.set('v.eventConfig', eventConfig);
	},
});