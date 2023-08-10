({
	doInit: function (component, event, helper) {
		const config = {
			// * MATCHES TO MY JOBS CONFIG
			header: component.get('v.header'),
			headerColor: component.get('v.headerColor'),
			description: component.get('v.description'),
			noUserErrorMessage: component.get('v.noUserErrorMessage'),
			noContactErrorMessage: component.get('v.noContactErrorMessage'),

			// * FOUND MATCHES CONFIG
			matchesHeader: component.get('v.matchesHeader'),
			matchesSubheader: component.get('v.matchesSubheader'),
			matchTileHeaderColor: component.get('v.matchTileHeaderColor'),
			matchTileFooterColor: component.get('v.matchTileFooterColor'),
			jobFilterLabel: component.get('v.jobFilterLabel'),
			jobFilterPlaceholder: component.get('v.jobFilterPlaceholder'),
			contactMatchButtonLabel: component.get('v.contactMatchButtonLabel'),
			alreadyContactedMatchButtonLabel: component.get('v.alreadyContactedMatchButtonLabel'),
			noMatchesMessage: component.get('v.noMatchesMessage'),

			// * CONTACT CANDIDATE CONFIG
			contactCandidateModalHeader: component.get('v.contactCandidateModalHeader'),
			contactCandidateMessageLabel: component.get('v.contactCandidateMessageLabel'),
			showContactCandidateFooter: component.get('v.showContactCandidateFooter'),
			contactCandidateSendButtonLabel: component.get('v.contactCandidateSendButtonLabel'),
			contactCandidateCloseButtonLabel: component.get('v.contactCandidateCloseButtonLabel'),
		};

		component.set('v.config', config);
	},
});