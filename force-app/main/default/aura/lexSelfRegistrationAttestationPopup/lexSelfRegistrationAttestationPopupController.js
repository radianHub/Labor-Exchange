({
    handleClose : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    
    handleAgree: function(component, event, helper) {
        var jsArgeementEvent = $A.get("e.c:lexSelfRegistrationAttestationEvent");
        jsArgeementEvent.setParams({
            agreed: component.get("v.agreed")
        });
        jsArgeementEvent.fire();
        component.find("overlayLib").notifyClose();
    }
})