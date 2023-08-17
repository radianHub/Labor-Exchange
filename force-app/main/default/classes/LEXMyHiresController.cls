public with sharing class LEXMyHiresController {
	@AuraEnabled(cacheable=true)
	public static HireFieldSet getSetupData() {
		try {
			// Get a map of string to field from the Launchpad__Hire__c object
			String objectName = 'Launchpad__Hire__c';
			Schema.SObjectType objDescribe = Schema.getGlobalDescribe().get(objectName);
			Schema.DescribeSObjectResult objDescribeResult = objDescribe.getDescribe();
			Map<String, Schema.SObjectField> hireFields = objDescribeResult.fields.getMap();

			// Initialize an empty list of ApplicationFieldSet
			HireFieldSet data = new HireFieldSet();
			Map<String, Map<String, String>> fieldsMap = new Map<String, Map<String, String>>();
			Set<String> uniqueFields = new Set<String>();

			// Get the org defaults for the Labor_Exchange_Community_Setup__c custom setting
			Labor_Exchange_Community_Setup__c lexConfigDefaults = Labor_Exchange_Community_Setup__c.getOrgDefaults();

			List<LaborExchangeCommunity_PageProperties__mdt> pageList = getHiresPageProperties(objectName);

			for (LaborExchangeCommunity_FieldProperties__mdt ff : getCandidateApplicationsFieldProperties(pageList)) {
				if (!fieldsMap.containsKey(ff.LaborExchangeCommunity_PageProperties__c)) {
					fieldsMap.put(ff.LaborExchangeCommunity_PageProperties__c, new Map<String, String>());
				}
				fieldsMap.get(ff.LaborExchangeCommunity_PageProperties__c).put(ff.Field_API_Name__c, ff.Field_Label__c);
			}

			for (LaborExchangeCommunity_PageProperties__mdt page : pageList) {
				List<LEXCommunityHelper.FieldWrapper> fields = LEXCommunityHelper.getFieldsByObjectAndFieldSet(objectName, page.Field_Set__c);

				for (LEXCommunityHelper.FieldWrapper fw : fields) {
					uniqueFields.add(fw.fieldApiName);
				}

				if (fieldsMap.containsKey(page.Id) && !fieldsMap.get(page.Id).keySet().isEmpty()) {
					for (LEXCommunityHelper.FieldWrapper fw : fields) {
						if (fieldsMap.get(page.Id).containsKey(fw.fieldApiName)) {
							fw.fieldLabel = fieldsMap.get(page.Id).get(fw.fieldApiName);
						}
					}
				}

				if (page.MasterLabel == 'My Hires') {
					List<LEXCommunityHelper.FieldWrapper> fieldWrapperList = new List<LEXCommunityHelper.FieldWrapper>(fields);
					data.hireFields = fieldWrapperList;
				}
			}

			if (!uniqueFields.isEmpty()) {
				data.hires = new LEXMyApplicationsControllerPrivileged().getMyHires(new List<String>(uniqueFields));
			}

			data.noOfTilesPerPage = Integer.valueOf(lexConfigDefaults.of_Tiles_Per_Page__c);
			return data;
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	// * CHILD CLASSES
	public without sharing class LEXMyApplicationsControllerPrivileged {
		public HiresData getMyHires(List<String> uniqueFields) {
			HiresData hiresData = new HiresData();

			// We need to get applications where the parent job's Launchpad__Account__c field matches the user's associated account
			// or jobs owned by the user

			List<User> lstUser = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
			String accountId = lstUser[0].Contact.AccountId;

			String query = 'SELECT Id, {0} FROM Launchpad__Hire__c WHERE Launchpad__Job__r.Launchpad__Available_in_Community__c = TRUE AND {1} ORDER BY {2} ';
			query = String.format(
				query,
				new List<String>{ String.join(uniqueFields, ', '), 'Launchpad__Job__r.Launchpad__Account__c = :accountId', ' CreatedDate DESC' }
			);

			Date today = Date.today();

			List<Launchpad__Hire__c> hires = Database.query(query);
			hiresData.hiresData = hires;

			return hiresData;
		}
	}

	// * WRAPPER CLASSES
	public class HireFieldSet {
		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> hireFields;

		@AuraEnabled
		public Integer noOfTilesPerPage;

		@AuraEnabled
		public HiresData hires;
	}

	// * HELPER METHODS
	private static List<LaborExchangeCommunity_PageProperties__mdt> getHiresPageProperties(String objectName) {
		return [
			SELECT Id, MasterLabel, Field_Set__c
			FROM LaborExchangeCommunity_PageProperties__mdt
			WHERE Active__c = 'Yes' AND Page__c = 'My Hires' AND Object_API__c = :objectName
			WITH SECURITY_ENFORCED
		];
	}

	private static List<LaborExchangeCommunity_FieldProperties__mdt> getCandidateApplicationsFieldProperties(
		List<LaborExchangeCommunity_PageProperties__mdt> pageList
	) {
		return [
			SELECT Id, Field_API_Name__c, Field_Label__c, LaborExchangeCommunity_PageProperties__c
			FROM LaborExchangeCommunity_FieldProperties__mdt
			WHERE Active__c = 'Yes' AND LaborExchangeCommunity_PageProperties__c IN :pageList
			WITH SECURITY_ENFORCED
		];
	}

	public class HiresData {
		@AuraEnabled
		public List<Launchpad__Hire__c> hiresData = new List<Launchpad__Hire__c>();
	}
}