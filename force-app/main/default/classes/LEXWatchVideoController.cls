public with sharing class LEXWatchVideoController {
	@AuraEnabled
	public static PublicData getEventData(String eventId) {
		try {
			Map<Id, Id> documentLinkMap = new Map<Id, Id>();
			Set<Id> documentIdSet = new Set<Id>();

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
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new SObjectHelperException(e.getMessage());
		}
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