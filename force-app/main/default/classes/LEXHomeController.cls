public with sharing class LEXHomeController {
	@AuraEnabled(cacheable=true)
	public static Labor_Exchange_Community_Setup__c laborExchangeCommunitySetup() {
		return Labor_Exchange_Community_Setup__c.getOrgDefaults();
	}
}