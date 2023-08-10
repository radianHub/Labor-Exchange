({
	doInit: function (component, event, helper) {
		component.set('v.isLoading', true);

		var action = component.get('c.getEventData');
		action.setParams({ eventId: component.get('v.eventId') });
		action.setCallback(this, function (response) {
			var state = response.getState();
			// This callback doesn’t reference component. If it did,
			// you should run an isValid() check
			//if (component.isValid() && state === "SUCCESS") {
			if (state === 'SUCCESS') {
				// Alert the user with the value returned
				// from the server
				var data = response.getReturnValue();
				component.set('v.eventName', data.eventName);
				component.set('v.videoURL', data.videoURL);
				component.set('v.videoName', data.videoName);
				component.set('v.videoDownloadURL', data.videoURL.replace('youtube', 'ssyoutube'));
				if (data.videoURL != undefined) {
					component.set('v.showVideo', true);
				} else {
					component.set('v.showVideo', false);
				}
				component.set('v.isLoading', false);
			}
		});
		$A.enqueueAction(action);
	},
});