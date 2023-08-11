public with sharing class LEXMatchesToMyJobsController {
	@AuraEnabled(cacheable=true)
	public static List<Launchpad__Job__c> getJobData() {
		try {
			if (!SObjectHelper.canQueryObj('User')) {
				throw SObjectHelperException.queryPermissionException('User');
			}

			List<User> currentUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :UserInfo.getUserId()
				WITH SECURITY_ENFORCED
			];

			if (currentUser.size() == 0) {
				// * THIS SPECIFIC ERROR MESSAGE IS REFERENCED IN MATCHES TO MY JOBS LWC
				throw new CustomException('No user found');
			}

			if (!SObjectHelper.canQueryObj('Contact')) {
				throw SObjectHelperException.queryPermissionException('Contact');
			}

			String contactId = currentUser[0].ContactId;

			List<Contact> userContact = [
				SELECT Id, AccountId
				FROM Contact
				WHERE Id = :contactId
				WITH SECURITY_ENFORCED
			];

			if (userContact.size() == 0) {
				// * THIS SPECIFIC ERROR MESSAGE IS REFERENCED IN MATCHES TO MY JOBS LWC
				throw new CustomException('No user contact found');
			}

			String accountId = userContact[0].AccountId;

			// if (!SObjectHelper.canQueryObj('launchpad__Job__c')) {
			// 	throw SObjectHelperException.queryPermissionException('launchpad__Job__c');
			// }

			String query = 'SELECT Id, Name FROM Launchpad__Job__c WHERE Launchpad__Account__c = :accountId';

			Labor_Exchange_Community_Setup__c lexCommunitySetup = Labor_Exchange_Community_Setup__c.getOrgDefaults();

			if (lexCommunitySetup != null && lexCommunitySetup.Eligible_Open_Job_Stages__c != null) {
				Set<String> openStages = new Set<String>();

				List<String> stages = lexCommunitySetup.Eligible_Open_Job_Stages__c.split(',');

				for (String stage : stages) {
					openStages.add(stage.normalizeSpace());
				}
				query += ' AND launchpad__Stage__c IN :openStages';
			}

			// query += ' WITH SECURITY_ENFORCED ORDER BY Name';
			query += ' ORDER BY Name';

			return Database.query(query);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static MatchFieldSet getJobMatches(String jobFilter) {
		String accountId;

		if (jobFilter == 'All') {
			if (!SObjectHelper.canQueryObj('User')) {
				throw SObjectHelperException.queryPermissionException('User');
			}

			List<launchpad__Match__c> matches = new List<launchpad__Match__c>();

			List<User> currentUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :UserInfo.getUserId()
				WITH SECURITY_ENFORCED
			];

			if (currentUser.size() == 0) {
				// * THIS SPECIFIC ERROR MESSAGE IS REFERENCED IN MATCHES TO MY JOBS LWC
				throw new CustomException('No user found');
			}

			if (!SObjectHelper.canQueryObj('Contact')) {
				throw SObjectHelperException.queryPermissionException('Contact');
			}

			String contactId = currentUser[0].ContactId;

			List<Contact> userContact = [
				SELECT Id, AccountId
				FROM Contact
				WHERE Id = :contactId
				WITH SECURITY_ENFORCED
			];

			if (userContact.size() == 0) {
				// * THIS SPECIFIC ERROR MESSAGE IS REFERENCED IN MATCHES TO MY JOBS LWC
				throw new CustomException('No user contact found');
			}

			accountId = userContact[0].AccountId;

			// if (!SObjectHelper.canQueryObj('launchpad__Match__c')) {
			// 	throw SObjectHelperException.queryPermissionException('launchpad__Match__c');
			// }
		}

		MatchFieldSet data = new MatchFieldSet();
		data.accountId = accountId;

		Map<String, Map<String, String>> fieldMap = new Map<String, Map<String, String>>();
		Set<String> uniqueFields = new Set<String>();

		if (!SObjectHelper.canQueryObj('LaborExchangeCommunity_PageProperties__mdt')) {
			throw SObjectHelperException.queryPermissionException('LaborExchangeCommunity_PageProperties__mdt');
		}

		String objectName = 'launchpad__Match__c';
		Set<String> pages = new Set<String>{ 'Matches to My Jobs' };
		Map<String, Map<String, String>> fieldsMap = new Map<String, Map<String, String>>();

		List<LaborExchangeCommunity_PageProperties__mdt> pageProperties = [
			SELECT Id, MasterLabel, Field_Set__c, Page__c
			FROM LaborExchangeCommunity_PageProperties__mdt
			WHERE Active__c = 'Yes' AND Page__c IN :pages AND Object_API__c = :objectName
			WITH SECURITY_ENFORCED
		];

		Labor_Exchange_Community_Setup__c lexcs = Labor_Exchange_Community_Setup__c.getOrgDefaults();

		LaborExchangeCommunity_PageProperties__mdt pageProperty = LaborExchangeCommunity_PageProperties__mdt.getInstance('Matches_to_My_Jobs');
		String fieldSet = pageProperty != null ? pageProperty.Field_Set__c : 'LaunchpadCo__LaborExchange_Match_Details';

		if (!SObjectHelper.canQueryObj('LaborExchangeCommunity_FieldProperties__mdt')) {
			throw SObjectHelperException.queryPermissionException('LaborExchangeCommunity_FieldProperties__mdt');
		}
		for (LaborExchangeCommunity_FieldProperties__mdt ff : [
			SELECT Id, Field_API_Name__c, Field_Label__c, LaborExchangeCommunity_PageProperties__c
			FROM LaborExchangeCommunity_FieldProperties__mdt
			WHERE Active__c = 'Yes' AND LaborExchangeCommunity_PageProperties__c = :pageProperty.Id
			WITH SECURITY_ENFORCED
		]) {
			if (!fieldsMap.containsKey(ff.LaborExchangeCommunity_PageProperties__c)) {
				fieldsMap.put(ff.LaborExchangeCommunity_PageProperties__c, new Map<String, String>());
			}

			fieldsMap.get(ff.LaborExchangeCommunity_PageProperties__c).put(ff.Field_API_Name__c, ff.Field_Label__c);
		}

		List<LEXCommunityHelper.FieldWrapper> fields = LEXCommunityHelper.getFieldsByObjectAndFieldSet(objectName, fieldSet);

		if (fieldsMap.containsKey(pageProperty.Id) && !fieldsMap.get(pageProperty.Id).keySet().isEmpty()) {
			for (LEXCommunityHelper.FieldWrapper fw : fields) {
				if (fieldsMap.get(pageProperty.Id).containsKey(fw.fieldApiName)) {
					fw.fieldLabel = fieldsMap.get(pageProperty.Id).get(fw.fieldApiName);
				}
			}
		}

		data.matchTileFields = fields;
		data.myMatches = new MatchesSearch().getMatches(fields, accountId, jobFilter);

		Labor_Exchange_Community_Setup__c laborExchangeCommunitySetup = Labor_Exchange_Community_Setup__c.getOrgDefaults();
		data.noOfTilesPerPage = Integer.valueOf(laborExchangeCommunitySetup.of_Tiles_Per_Page__c);

		return data;
	}

	public without sharing class MatchesSearch {
		public List<Launchpad__Match__c> getMatches(List<LEXCommunityHelper.FieldWrapper> fields, String accountId, String jobFilter) {
			String initialQuery = 'SELECT Id';

			Set<String> uniqueFields = new Set<String>();
			for (LEXCommunityHelper.FieldWrapper fw : fields) {
				uniqueFields.add(fw.fieldApiName);
			}
			Integer uniqueFieldsSize = uniqueFields.size();
			if (uniqueFieldsSize > 0) {
				initialQuery += ', {0} ';
			}
			// ! WITH SECURITY ENFORCED IS NOT USED BECAUSE USER PERMISSION SET CANNOT GIVE READ ACCESS TO THE OBJECT, LAUNCHPAD__MATCH__C, DUE TO PACKAGING AN OBJECT WITH A M-D RELATIONSHIP
			initialQuery += ' FROM {1} WHERE {2}';

			String whereStages = '';
			Labor_Exchange_Community_Setup__c lexCommunitySetup = Labor_Exchange_Community_Setup__c.getInstance();

			if (lexCommunitySetup.Eligible_Open_Job_Stages__c != null) {
				Set<String> openStages = new Set<String>();

				List<String> stages = lexCommunitySetup.Eligible_Open_Job_Stages__c.split(',');

				for (String stage : stages) {
					openStages.add(stage.normalizeSpace());
				}

				whereStages = ' AND Launchpad__Job__r.Launchpad__Stage__c IN :openStages';
			}

			String query = String.format(
				initialQuery,
				new List<String>{
					String.join(new List<String>(uniqueFields), ', '),
					'launchpad__Match__c',
					accountId == null ? 'Launchpad__Job__c = :jobFilter' : 'Launchpad__Job__r.Launchpad__Account__c = :accountId' + whereStages
				}
			);

			return Database.query(query);
		}
	}

	public class MatchFieldSet {
		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> matchTileFields;

		@AuraEnabled
		public Integer noOfTilesPerPage;

		@AuraEnabled
		public List<String> uniqueFields;

		@AuraEnabled
		public List<Launchpad__Match__c> myMatches;

		@AuraEnabled
		public String accountId;
	}

	public class CustomException extends Exception {
	}
}