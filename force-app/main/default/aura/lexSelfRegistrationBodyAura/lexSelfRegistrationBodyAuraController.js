({
	doInit: function (component, event, helper) {
		var action = component.get('c.getAttestationList');

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state == 'SUCCESS') {
				component.set('v.attList', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);

		const config = {
			existingContactMessage: component.get('v.existingContactMessage'),
			existingActiveUserMessage: component.get('v.existingActiveUserMessage'),
			existingAccountMessage: component.get('v.existingAccountMessage'),
			requiredFieldMessage: component.get('v.requiredFieldMessage'),
			passwordMismatchError: component.get('v.passwordMismatchError'),
			requiredFieldMsg: component.get('v.requiredFieldMsg'),
			nextStepBtn: component.get('v.nextStepBtn'),
			registerBtn: component.get('v.registerBtn'),
			passwordSectionTitle: component.get('v.passwordSectionTitle'),
			passwordLabel: component.get('v.passwordLabel'),
			confirmPasswordLabel: component.get('v.confirmPasswordLabel'),
			pattern: component.get('v.pattern'),
			patternMessage: component.get('v.patternMessage'),
			authorizationChbkLabel: component.get('v.authorizationChbkLabel'),
			footer: component.get('v.footer'),
			redirectURlLogin: component.get('v.redirectURlLogin'),
			Page1Header: component.get('v.Page1Header'),
			Page1Description: component.get('v.Page1Description'),
			Page2Header: component.get('v.Page2Header'),
			Page2Description: component.get('v.Page2Description'),
			Headercolor: component.get('v.Headercolor'),
			Descriptioncolor: component.get('v.Descriptioncolor'),
			authorizationChbkLabelshow: component.get('v.authorizationChbkLabelshow'),
			contactrecordtypeassignment: component.get('v.contactrecordtypeassignment'),
			accountrecordtypeassignment: component.get('v.accountrecordtypeassignment'),
			userprofileassignment: component.get('v.userprofileassignment'),
			step1of2: component.get('v.step1of2'),
			step2of2: component.get('v.step2of2'),
			minimumMaximumAgeerrorMessage: component.get('v.minimumMaximumAgeerrorMessage'),
		};

		component.set('v.config', config);
	},
	handleAgreement: function (component, event, helper) {
		const config = {
			attList: component.get('v.attList'),
			attestationheader: component.get('v.attestationheader'),
			authorizationcheckboxlabel: component.get('v.authorizationcheckboxlabel'),
			authorizationiagreebuttonlabel: component.get('v.authorizationiagreebuttonlabel'),
		};
		var modalBody;
		$A.createComponent(
			'c:lexSelfRegistrationAttestationPopup',
			{
				config,
			},
			function (content, status) {
				if (status === 'SUCCESS') {
					modalBody = content;
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: 'agreement cJsSelfRegistrationBodyAura',
						closeCallback: function () {},
					});
				}
			}
		);
	},

	handleAgreementCheck: function (component, event, helper) {
		component.set('v.agreed', event.getParam('agreed'));
	},
});