({
	doInit: function(component, event, helper) {
        
        const config = {
            header: component.get("v.header"),
            headerColor: component.get("v.headerColor"),
            description: component.get("v.description"),
            showRedirectEventButton: component.get("v.showRedirectEventButton"),
            redirectEventButtonLabel: component.get("v.redirectEventButtonLabel"),
            redirectEventButtonRedirectUrl: component.get("v.redirectEventButtonRedirectUrl"),
            eventTileHeaderColor: component.get("v.eventTileHeaderColor"),
            eventTileFooterColor: component.get("v.eventTileFooterColor"),
            watchVideoEventButtonLabel: component.get("v.watchVideoEventButtonLabel"),
            cancelRegistrationButtonLabel: component.get("v.cancelRegistrationButtonLabel"),
            cancelRegistrationRedirectUrl: component.get("v.cancelRegistrationRedirectUrl"),
            cancellationMessage: component.get("v.cancellationMessage"),
            viewDetailEventButtonLabel: component.get("v.viewDetailEventButtonLabel"),
            closeButtonLabel: component.get("v.closeButtonLabel"),
            noResultMessage: component.get("v.noeventsmessage"),
            filterField: component.get("v.availableinCommunityEventPage"),
            priorityFilterField: component.get("v.communityPriorityEvent"),
            downloadDocuments: component.get("v.downloadDocuments"),
            searchFilterFields: null
        };
        
        component.set("v.config", config);
    }
})