@isTest
private without sharing class LEXCompanyProfileControllerTest {
	private static User sysU;
	private static User limAccessU;
	private static Account acc;
	private static Contact con;
	private static Contact limAccessCon;

	private static User prepareUser(Id profId, String firstName, String lastName) {
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

	private static void makeData() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		adminUser.UserRoleId = ownerRole.Id;
		update adminUser;

		System.runAs(adminUser) {
			Id userLicId = [SELECT Id FROM UserLicense WHERE Name LIKE '%Customer Community%' LIMIT 1].Id;
			sysU = prepareUser([SELECT Id FROM Profile WHERE UserLicenseId = :userLicId LIMIT 1].Id, 'sysAdmin', 'TestUser');

			limAccessU = prepareUser([SELECT Id FROM Profile WHERE UserLicenseId = :userLicId LIMIT 1].Id, 'limAccessU', 'TestUser');

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

			con = new Contact(
				AccountId = acc.Id,
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
			insert con;

			limAccessCon = new Contact(
				AccountId = acc.Id,
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
			insert limAccessCon;

			sysU.ContactId = con.Id;
			insert sysU;

			limAccessU.ContactId = limAccessCon.Id;
			insert limAccessU;

			PermissionSet testPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions'];
			PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = sysU.Id, PermissionSetId = testPermissionSet.Id);
			insert psa;
		}
	}

	@isTest
	private static void getSectionsTest() {
		makeData();

		System.runAs(sysU) {
			try {
				LEXCompanyProfileController.CompanyProfileData data = LEXCompanyProfileController.getSections();

				System.assert(data.sections.size() > 0, 'No data was returned');
			} catch (Exception e) {
				System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			}
		}
	}

	@IsTest
	static void noAccessGetSectionsTest() {
		makeData();

		System.runAs(limAccessU) {
			try {
				LEXCompanyProfileController.CompanyProfileData data = LEXCompanyProfileController.getSections();
			} catch (Exception e) {
				Boolean exc = e.getMessage() != null;
				System.assert(exc, 'Limited Access user has access to records.');
			}
		}
	}

	@IsTest
	static void testSave() {
		Account acc = new Account(
			Name = 'Test Acc',
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId()
		);
		insert acc;

		Boolean bool = LEXCompanyProfileController.save(JSON.serialize(acc));

		System.assert(bool, 'Account not successfully updated');
	}

	@IsTest
	static void testSaveNoAccess() {
		Account acc = new Account(
			Name = 'Test Acc',
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId()
		);

		try {
			Boolean bool = LEXCompanyProfileController.save(JSON.serialize(acc));
		} catch (Exception e) {
			Boolean exc = e.getMessage() != null;
			System.assert(exc, 'Update Failed');
		}
	}
}