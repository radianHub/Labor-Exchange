public with sharing class LEXHomePageController {
	@AuraEnabled(cacheable=true)
	public static List<LaborExchangeCommunity_HomePage__mdt> getHomePageTileInfo() {
		return [
			SELECT
				Id,
				Active__c,
				Details__c,
				DeveloperName,
				Header__c,
				Image_URL__c,
				Image_Link__c,
				Label,
				Language,
				MasterLabel,
				Order__c,
				QualifiedApiName,
				Redirect_URL__c,
				Row__c,
				Open_in_New_Tab__c
			FROM LaborExchangeCommunity_HomePage__mdt
			WHERE Active__c = 'Yes'
			WITH SECURITY_ENFORCED
			ORDER BY Row__c ASC, Order__c ASC
		];
	}
}