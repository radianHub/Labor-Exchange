({
	doInit: function (component, event, helper) {
		const config = {
			applicationListHeader: component.get('v.applicationListHeader'),
			headerColor: component.get('v.headerColor'),
			description: component.get('v.description'),
			showRedirectButton: component.get('v.showRedirectButton'),
			redirectButtonLabel: component.get('v.redirectButtonLabel'),
			redirectButtonRedirectUrl: component.get('v.redirectButtonRedirectUrl'),
			showContactUsButton: component.get('v.showContactUsButton'),
			contactUsButtonLabel: component.get('v.contactUsButtonLabel'),
			noJobApplicationMessage: component.get('v.noJobApplicationMessage'),
			contactUsHeader: component.get('v.contactUsHeader'),
			contactUsDescription: component.get('v.contactUsDescription'),
		};

		if (!component.set('v.config')) {
			component.set('v.config', config);
		}
	},

	// handleUpdateRequest: function (component, event, helper) {
	// 	const recordId = event.getParam('recordId');
	// 	const config = component.get('v.config');

	// 	var modalBody;
	// 	$A.createComponent(
	// 		'c:lexCompanyUpdateRequestAura',
	// 		{
	// 			recordId,
	// 			config,
	// 		},
	// 		function (content, status) {
	// 			if (status === 'SUCCESS') {
	// 				modalBody = content;
	// 				component.find('overlayLib').showCustomModal({
	// 					body: modalBody,
	// 					showCloseButton: true,
	// 					cssClass: 'updateRequest clexCandidateApplicationsAura',
	// 					closeCallback: function () {},
	// 				});
	// 			}
	// 		}
	// 	);
	// },

	handleRefreshApex: function (cmp, event, helper) {
		const refreshApex = cmp.getEvent('refreshApex');
		refreshApex.fire();
	},
});