@isTest
private with sharing class LEXContactListControllerTest {
	static Account acc;
	static Contact con1;
	static Contact con2;
	static User u;
	static User limU;

	static User prepareUser(Id profId, String firstName, String lastName) {
		User tempUser = new User(
			FirstName = firstName,
			LastName = lastName,
			email = firstName + '@' + lastName + '.com',
			Username = firstName + '@' + lastName + '.com',
			EmailEncodingKey = 'UTF-8',
			Alias = 'testUser',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			ProfileId = profId,
			CommunityNickname = firstName,
			IsActive = true
		);
		return tempUser;
	}

	@testSetup
	static void makeData() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		adminUser.UserRoleId = ownerRole.Id;
		update adminUser;

		System.runAs(adminUser) {
			Id userLicId = [SELECT Id FROM UserLicense WHERE Name LIKE '%Customer Community%' LIMIT 1].Id;
			u = prepareUser([SELECT Id FROM Profile WHERE UserLicenseId = :userLicId LIMIT 1].Id, 'StandardU', 'TestUser');

			limU = prepareUser([SELECT Id FROM Profile WHERE UserLicenseId = :userLicId LIMIT 1].Id, 'limAccessU', 'TestUser');

			acc = new Account(
				OwnerId = adminUser.Id,
				Name = 'Test',
				ShippingCity = 'sdw',
				ShippingState = 'sdds',
				ShippingCountry = 'sdfsd',
				ShippingPostalCode = '12321',
				website = 'www://test.com',
				BillingCity = 'sdw',
				BillingState = 'sdds',
				BillingCountry = 'sdfsd',
				BillingPostalCode = '12321',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId()
			);
			insert acc;

			con1 = new Contact(
				AccountId = acc.Id,
				Launchpad__Active__c = 'Yes',
				firstname = 'test',
				lastname = 'test',
				email = 'test@test.com',
				OtherStreet = 'test',
				OtherState = 'test',
				OtherPostalCode = '302022',
				OtherCity = 'test',
				MailingStreet = 'test',
				MailingState = 'test',
				MailingPostalCode = '302022',
				MailingCity = 'test',
				RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId()
			);
			insert con1;

			con2 = new Contact(
				AccountId = acc.Id,
				Launchpad__Active__c = 'Yes',
				firstname = 'testconnoaccess',
				lastname = 'testconnoaccess',
				email = 'testconnoaccess@test.com',
				OtherStreet = 'test',
				OtherState = 'test',
				OtherPostalCode = '302022',
				OtherCity = 'test',
				MailingStreet = 'test',
				MailingState = 'test',
				MailingPostalCode = '302022',
				MailingCity = 'test',
				RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId()
			);
			insert con2;

			u.ContactId = con1.Id;
			insert u;

			limU.ContactId = con2.Id;
			insert limU;

			PermissionSet testPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions'];
			PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = testPermissionSet.Id);
			insert psa;
		}
	}

	@IsTest
	static void getDataTest() {
		//makeData();
		User u = [SELECT Id FROM User WHERE Name = 'StandardU TestUser' LIMIT 1];
		Account acc = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];

		System.runAs(u) {
			try {
				LEXContactListController.CompanyContactData data = LEXContactListController.getContactTableData((String) acc.Id);

				Boolean bool = data.myContacts.size() > 0;
				System.assert(bool, 'No Contacts returned.');
			} catch (Exception e) {
				System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			}
		}
	}

	@IsTest
	static void noAccessGetDataTest() {
		//makeData();
		User limU = [SELECT Id FROM User WHERE Name = 'limAccessU TestUser' LIMIT 1];
		Account acc = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
		System.runAs(limU) {
			try {
				LEXContactListController.CompanyContactData data = LEXContactListController.getContactTableData((String) acc.Id);

				Boolean bool = data.myContacts.size() > 0;
				System.assert(bool, 'No Contacts returned.');
			} catch (Exception e) {
				Boolean exc = e.getMessage() != null;
				System.assert(exc, 'Limited Access User has access to records');
			}
		}
	}

	@IsTest
	static void archiveContactTest() {
		//makeData();
		Contact con2 = [SELECT Id FROM Contact WHERE Name = 'testconnoaccess testconnoaccess' LIMIT 1];
		Test.startTest();
		LEXContactListController.archiveContact((String) con2.Id);
		Test.stopTest();

		List<Contact> conList = [SELECT Id FROM Contact WHERE Launchpad__Active__c = 'No'];
		List<User> uList = [SELECT Id, IsActive FROM User WHERE IsActive = FALSE];

		system.assertEquals(1, conList.size(), 'Contact not de-activated.');
		system.assertEquals(uList.size() > 0, true, 'User not de-activated');
	}
}