({
	doInit: function (component, event, helper) {
		const eventConfig = {
			header: component.get('v.header'),
			headerColor: component.get('v.headerColor'),
			description: component.get('v.description'),
			showRedirectEventButton: component.get('v.showRedirectEventButton'),
			redirectEventButtonLabel: component.get('v.redirectEventButtonLabel'),
			redirectEventButtonDescription: component.get('v.redirectEventButtonDescription'),
			redirectEventButtonRedirectUrl: component.get('v.redirectEventButtonRedirectUrl'),
			eventsHeader: component.get('v.eventsHeader'),
			eventsHeaderColor: component.get('v.eventsHeaderColor'),
			eventTileHeaderColor: component.get('v.eventTileHeaderColor'),
			eventTileFooterColor: component.get('v.eventTileFooterColor'),
			watchVideoEventButtonLabel: component.get('v.watchVideoEventButtonLabel'),
			registerEventButtonLabel: component.get('v.registerEventButtonLabel'),
			registerEventRedirectUrl: component.get('v.registerEventRedirectUrl'),
			registerEventSuccessMessage: component.get('v.registerEventSuccessMessage'),
			alreadyRegisteredEventButtonLabel: component.get('v.alreadyRegisteredEventButtonLabel'),
			filterField: component.get('v.availableinCommunityEventPage'),
			priorityFilterField: component.get('v.communityPriorityEvent'),
			filterHeader: component.get('v.filterHeader'),
			searchFilterFields: component.get('v.searchFilterFields'),
			searchInputLabel: component.get('v.searchInputLabel'),
			startDateInputLabel: component.get('v.startDateInputLabel'),
			filterHelp: component.get('v.filterHelp'),
			filterApplied: component.get('v.filterApplied'),
			searchBtnLabel: component.get('v.searchBtnLabel'),
			clearFilterLabel: component.get('v.clearFilterLabel'),
			noResultMessage: component.get('v.noResultMessage'),
			downloadDocuments: component.get('v.downloadDocuments'),
		};
		if (!component.set('v.eventConfig')) {
			component.set('v.eventConfig', eventConfig);
		}
	},
	handleWatchVideo: function (component, event, helper) {
		var modalBody;
		$A.createComponent(
			'c:lexViewCourse',
			{
				eventId: event.getParam('recordId'),
			},
			function (content, status) {
				if (status === 'SUCCESS') {
					modalBody = content;
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: 'viewCourse clexEventsAura',
						closeCallback: function () {},
					});
				}
			}
		);
	},
	showFilterOptions: function (component, event, helper) {
		var modalBody;
		$A.createComponent(
			'c:lexSelectFilterValuesPopup',
			{
				filter: Object.assign({}, event.getParam('filter')),
				buttonLabel: component.get('v.applyFilter'),
			},
			function (content, status) {
				if (status === 'SUCCESS') {
					modalBody = content;
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: 'filterValues cLexEventsAura',
						closeCallback: function () {},
					});
				}
			}
		);
	},
	handleApplyFilterValues: function (component, event, helper) {
		var appliedFilters = component.get('v.appliedFilters');
		appliedFilters = appliedFilters === null ? {} : Object.assign({}, appliedFilters);
		appliedFilters[event.getParam('fieldName')] = Object.assign({}, event.getParam('selectedValues'));
		component.set('v.appliedFilters', Object.assign({}, appliedFilters));
	},
	handleClearFilters: function (component, event, helper) {
		component.set('v.appliedFilters', undefined);
	},
	handleRegistration: function (component, event, helper) {
		var record = Object.assign({}, event.getParam('record'));
		var fields = Object.assign([], event.getParam('fields'));
		var modalBody;
		$A.createComponent(
			'c:lexEventConfirmationPopup',
			{
				event: record,
				fields: fields,
				eventConfig: component.get('v.eventConfig'),
			},
			function (content, status) {
				if (status === 'SUCCESS') {
					modalBody = content;
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: 'eventRegistration clexEventsAura',
						closeCallback: function () {},
					});
				}
			}
		);
	},
});