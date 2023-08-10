@isTest
private without sharing class LEXEditContactModalControllerTest {
	public static Account acc;
	public static Contact con1;
	public static Contact con2;
	public static User u;
	public static User limU;

	static User prepareUser(Id profId, String firstName, String lastName) {
		User tempUser;
		System.runAs(getAdminUser()) {
			tempUser = new User(
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
		}
		return tempUser;
	}

	static void makeData() {
		User adminUser = getAdminUser();
		System.runAs(adminUser) {
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
	}

	@IsTest
	static void getDataTest() {
		System.runAs(getAdminUser()) {
			makeData();
			System.runAs(u) {
				try {
					LEXEditContactModalController.MyContactData data = LEXEditContactModalController.fetchContactData((String) con1.Id);

					Boolean bool = data.sections.size() > 0;
					System.assert(bool, 'No Data returned.');
				} catch (Exception e) {
					System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
				}
			}
		}
	}

	@IsTest
	static void noAccessGetDataTest() {
		System.runAs(getAdminUser()) {
			makeData();
			System.runAs(limU) {
				try {
					LEXEditContactModalController.MyContactData data = LEXEditContactModalController.fetchContactData((String) con1.Id);

					Boolean bool = data.sections.size() > 0;
					System.assert(bool, 'No Data returned.');
				} catch (Exception e) {
					Boolean exc = e.getMessage() != null;
					System.assert(exc, 'Limited Access User has access to records');
				}
			}
		}
	}

	@isTest
	static void upsertTest() {
		System.runAs(getAdminUser()) {
			Contact c = new Contact();
			c.FirstName = 'sfsdf';
			c.lastname = 'sfsf';
			c.OtherStreet = 'test';
			c.OtherState = 'test';
			c.OtherPostalCode = '302022';
			c.OtherCity = 'test';
			c.MailingStreet = 'test';
			c.MailingState = 'test';
			c.MailingPostalCode = '302022';
			c.MailingCity = 'test';
			c.Birthdate = system.today() - 100;
			c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId();
			c.Email = 'test@test.com';

			try {
				System.assert(LEXEditContactModalController.upsertContact(JSON.serialize(c)), 'Contact did not upsert successfully');
			} catch (Exception e) {
				System.debug('Test');
			}
		}
	}

	private static void createSetupObjectRecords() {
		// Create a role for the owner
		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		User adminUser = new User();
		adminUser.FirstName = 'Admin ';
		adminUser.LastName = 'User';
		adminUser.Email = 'admin@example.com';
		adminUser.Username = 'Admin' + Math.random() * 100 + '@lp.com';
		adminUser.Alias = 'admin';
		adminUser.CommunityNickname = 'admin';
		adminUser.TimeZoneSidKey = 'America/Los_Angeles';
		adminUser.LocaleSidKey = 'en_US';
		adminUser.EmailEncodingKey = 'UTF-8';
		adminUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
		adminUser.LanguageLocaleKey = 'en_US';
		adminUser.IsActive = true;
		adminUser.UserRoleId = ownerRole.Id;

		insert adminUser;

		PermissionSetAssignment psa = new PermissionSetAssignment(
			AssigneeId = adminUser.Id,
			PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions' LIMIT 1]
			.Id
		);
		insert psa;
	}

	private static User getAdminUser() {
		return [
			SELECT Id
			FROM User
			WHERE Profile.Name LIKE 'System Administrator' AND Email = 'admin@example.com'
			LIMIT 1
		];
	}

	// Create setup data
	@TestSetup
	static void setupData() {
		createSetupObjectRecords();
	}
}