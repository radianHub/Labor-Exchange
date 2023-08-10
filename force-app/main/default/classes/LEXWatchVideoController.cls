public with sharing class LEXWatchVideoController {
	@AuraEnabled
	public static PublicData getEventData(String eventId) {
		Map<Id, Id> documentLinkMap = new Map<Id, Id>();
		Set<Id> documentIdSet = new Set<Id>();
		/*CRUD/FLS Security check */
		if (!SobjectHelper.canQueryObj('Launchpad__Event__c')) {
			throw SObjectHelperException.queryPermissionException('Launchpad__Event__c');
		}
		Launchpad__Event__c currentEvent = [
			SELECT Id, Name, Launchpad__Video_Name__c, Launchpad__Video_URL__c
			FROM Launchpad__Event__c
			WHERE Id = :eventId
			WITH SECURITY_ENFORCED
		];

		PublicData pd = new PublicData();
		pd.eventName = currentEvent.Name;
		pd.videoName = currentEvent.Launchpad__Video_Name__c;
		pd.videoURL = currentEvent.Launchpad__Video_URL__c;
		return pd;
	}

	public class PublicData {
		@AuraEnabled
		public String eventName;
		@AuraEnabled
		public String videoName;
		@AuraEnabled
		public String videoURL;
	}
}