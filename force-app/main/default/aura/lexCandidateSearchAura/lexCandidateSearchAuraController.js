({
	doInit: function (component, event, helper) {
		const candidateConfig = {
			header: component.get('v.header'),
			headerColor: component.get('v.headerColor'),
			description: component.get('v.description'),
			showRedirectCandidateButton: component.get('v.showRedirectCandidateButton'),
			redirectCandidateButtonLabel: component.get('v.redirectCandidateButtonLabel'),
			redirectCandidateButtonDescription: component.get('v.redirectCandidateButtonDescription'),
			redirectCandidateButtonRedirectUrl: component.get('v.redirectCandidateButtonRedirectUrl'),
			filterHeader: component.get('v.filterHeader'),
			searchFilterFields: component.get('v.searchFilterFields'),
			//wageInputLabel: component.get('v.wageInputLabel'),
			searchInputLabel: component.get('v.searchInputLabel'),
			/*cityZipCodeInputLabel: component.get('v.cityZipCodeInputLabel'),
			applyFilter: component.get('v.applyFilter'),
			filterApplied: component.get('v.filterApplied'),
			filterSectionHelpText: component.get('v.filterSectionHelpText'),*/
			searchBtnLabel: component.get('v.searchBtnLabel'),
			clearFilterLabel: component.get('v.clearFilterLabel'),
			candidateMatchesHeader: component.get('v.candidateMatchesHeader'),
			candidateMatchesSubHeader: component.get('v.candidateMatchesSubHeader'),
			candidatesHeader: component.get('v.candidatesHeader'),
			candidatesSubHeader: component.get('v.candidatesSubHeader'),
			otherCandidatesHeader: component.get('v.otherCandidatesHeader'),
			otherCandidatesSubHeader: component.get('v.otherCandidatesSubHeader'),
			candidateTileHeaderColor: component.get('v.candidateTileHeaderColor'),
			candidateTileFooterColor: component.get('v.candidateTileFooterColor'),
			viewDetailsButtonLabel: component.get('v.viewDetailsButtonLabel'),
			/*saveCandidateButtonLabel: component.get('v.saveCandidateButtonLabel'),
			savedCandidateButtonLabel: component.get('v.savedCandidateButtonLabel'),
			savedCandidateReturnUrl: component.get('v.savedCandidateReturnUrl'),*/
			showApplyCandidateButton: component.get('v.showApplyCandidateButton'),
			applyCandidateButtonLabel: component.get('v.applyCandidateButtonLabel'),
			appliedCandidateButtonLabel: component.get('v.appliedCandidateButtonLabel'),
			contactCandidateHeader: component.get('v.contactCandidateHeader'),
			contactCandidateSubtext: component.get('v.contactCandidateSubtext'),
			contactCandidatePlaceholderText: component.get('v.contactCandidatePlaceholderText'),
			submitCandidateButtonLabel: component.get('v.submitCandidateButtonLabel'),
			submitCandidateAppReturnUrl: component.get('v.submitCandidateAppReturnUrl'),
			backToCandidateSearchButtonLabel: component.get('v.backToCandidateSearchButtonLabel'),
			skillPillColor: component.get('v.skillPillColor'),
			successMessageHeader: component.get('v.successMessageHeader'),
			successMessage: component.get('v.successMessage'),
			filterField: component.get('v.availableinCommunityCandidateSearchPage'),
			priorityFilterField: component.get('v.communityPriorityCandidate'),
			matchFilterField: component.get('v.availableinCommunityMatches'),
			noResultsMessage: component.get('v.noResultsMessage'),
			myCandidatesMatchScoreLabel: component.get('v.myCandidatesMatchScoreLabel'),
			enableSearch: component.get('v.enableSearch'),
			minimumSearchCharacters: component.get('v.minimumSearchCharacters'),
			minimumSearchCharactersErrorHeader: component.get('v.minimumSearchCharactersErrorHeader'),
			minimumSearchCharactersErrorMessage: component.get('v.minimumSearchCharactersErrorMessage'),
		};

		if (!component.set('v.candidateConfig')) {
			component.set('v.candidateConfig', candidateConfig);
		}
	},

	handleContactNow: function (component, event, helper) {
		var record = Object.assign({}, event.getParam('record'));
	},

	handleViewDetails: function (component, event, helper) {
		var record = Object.assign({}, event.getParam('candidate'));
		var fields = Object.assign([], event.getParam('fields'));
		var applied = event.getParam('applied') === true;
		var modalBody;
	},

	showFilterOptions: function (component, event, helper) {
		var modalBody;
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
});