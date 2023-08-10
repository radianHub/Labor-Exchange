({
	doInit: function (component, event, helper) {
		const config = {
			header: component.get('v.header'),
			headerColor: component.get('v.headerColor'),
			description: component.get('v.description'),
			subheaderColor: component.get('v.subheaderColor'),
			editButtonLabel: component.get('v.editButtonLabel'),
			saveButtonLabel: component.get('v.saveButtonLabel'),
			cancelButtonLabel: component.get('v.cancelButtonLabel'),
			requiredFieldMessage: component.get('v.requiredFieldMessage'),
			successMessage: component.get('v.successMessage'),
			redirectMyProfileURL: component.get('v.redirectMyProfileURL'),
			showContact: component.get('v.showContact'),
			contactListHeader: component.get('v.contactListHeader'),
			contactListSubheader: component.get('v.contactListSubheader'),
			noContactMessage: component.get('v.noContactMessage'),
			newContactButtonLabel: component.get('v.newContactButtonLabel'),
			editContactBtn: component.get('v.editContactButtonLabel'),
			deleteContactBtn: component.get('v.deleteContactButtonLabel'),
			popupHeader: component.get('v.newContactPopupHeader'),
			popupSubheader: component.get('v.newContactPopupSubHeader'),
			popupSaveButtonLabel: component.get('v.newContactPopupSaveButtonLabel'),
			popupCancelButtonLabel: component.get('v.newContactPopupCancelButtonLabel'),
			popupSuccessMessage: component.get('v.contactSuccessMessage'),
		};

		component.set('v.config', config);
	},
});