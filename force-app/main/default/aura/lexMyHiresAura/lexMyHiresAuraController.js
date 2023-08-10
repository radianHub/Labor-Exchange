({
	doInit: function (component, event, helper) {
		const eventConfig = {
			applicationListHeader: component.get('v.applicationListHeader'),
			headerColor: component.get('v.headerColor'),
			description: component.get('v.description'),
			showRedirectButton: component.get('v.showRedirectButton'),
			redirectButtonLabel: component.get('v.redirectButtonLabel'),
			redirectButtonRedirectUrl: component.get('v.redirectButtonRedirectUrl'),
			showContactUsButton: component.get('v.showContactUsButton'),
			contactUsButtonLabel: component.get('v.contactUsButtonLabel'),
			noJobApplicationMessage: component.get('v.noJobApplicationMessage'),
		};

		if (!component.set('v.eventConfig')) {
			component.set('v.eventConfig', eventConfig);
		}
	},

	// handleUpdateRequest: function (component, event, helper) {
	// 	const recordId = event.getParam('recordId');
	// 	const eventConfig = {
	// 		applicationListHeader: component.get('v.contactUsHeader'),
	// 		headerColor: component.get('v.headerColor'),
	// 		contactUsDescription: component.get('v.contactUsDescription'),
	// 		placeholderText: component.get('v.contactUsPlaceholderText'),
	// 		submitButtonLabel: component.get('v.contactUsSubmitButtonLabel'),
	// 		cancelButtonLabel: component.get('v.contactUsCancelButtonLabel'),
	// 		successMessage: component.get('v.contactUsSuccessMessage'),
	// 	};

	// 	var modalBody;
	// 	$A.createComponent(
	// 		'c:lexCompanyUpdateRequestAura',
	// 		{
	// 			recordId,
	// 			eventConfig,
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
});