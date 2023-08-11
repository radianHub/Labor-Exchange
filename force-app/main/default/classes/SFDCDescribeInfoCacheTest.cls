@isTest
private class SFDCDescribeInfoCacheTest {
	@isTest
	private static void fieldMapForNewCache() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			SFDCDescribeInfoCache cache = SFDCDescribeInfoCache.getInstance();

			Test.startTest();
			Map<String, Schema.SObjectField> fieldMap = cache.fieldMapFor(Account.sObjectType);
			Test.stopTest();

			Assert.isTrue(fieldMap.size() > 0, 'No fields cache was returned');
		}
	}

	@isTest
	private static void fieldMapForExistingCache() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			SFDCDescribeInfoCache cache = SFDCDescribeInfoCache.getInstance();
			Map<String, Schema.SObjectField> fieldMap = cache.fieldMapFor(Account.sObjectType);

			Test.startTest();
			fieldMap = cache.fieldMapFor(Account.sObjectType);
			Test.stopTest();

			Assert.isTrue(fieldMap.size() > 0, 'No fields cache was returned');
		}
	}

	@isTest
	private static void getViewableFieldsNamesFieldMap() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			SFDCDescribeInfoCache cache = SFDCDescribeInfoCache.getInstance();
			Map<String, Schema.SObjectField> fieldMap = cache.fieldMapFor(Account.sObjectType);

			Test.startTest();
			Set<String> viewableFields = cache.getViewableFieldsNames(fieldMap);
			Test.stopTest();

			Assert.isTrue(viewableFields.size() > 0, 'No fields were returned');
		}
	}

	@isTest
	private static void getViewableFieldsNamesObjectType() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			SFDCDescribeInfoCache cache = SFDCDescribeInfoCache.getInstance();
			Map<String, Schema.SObjectField> fieldMap = cache.fieldMapFor(Account.sObjectType);

			Test.startTest();
			Set<String> viewableFields = cache.getViewableFieldsNames(Account.sObjectType);
			Test.stopTest();

			Assert.isTrue(viewableFields.size() > 0, 'No fields were returned');
		}
	}
}