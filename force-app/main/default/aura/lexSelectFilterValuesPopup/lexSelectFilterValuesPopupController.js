({
	handleClose : function(component, event, helper) {
		component.find("overlayLib").notifyClose();
	},
    
    handleApplyFilter: function(component, event, helper) {
        var lexApplySelectedValues = $A.get("e.c:lexApplySelectedValues");
        lexApplySelectedValues.setParams({
            fieldName: event.getParam('fieldName'),
            selectedValues: Object.assign({}, event.getParam('selectedValues'))
        });
        lexApplySelectedValues.fire();
        component.find("overlayLib").notifyClose();
    },
})