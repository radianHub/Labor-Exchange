@isTest
private class LEXSelfRegistrationBodyControllerTest {
	@isTest
	private static void getAttestationList() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			Test.startTest();
			List<String> attestations = LEXSelfRegistrationBodyController.getAttestationList();
			Test.stopTest();

			Assert.isTrue(attestations.size() > 0, 'No attestation records were returned');
		}
	}

	@isTest
	private static void getAttestationList_NoAttestationAccess() {
		User user = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

		System.runAs(user) {
			Exception thrownException;

			try {
				Test.startTest();
				List<String> attestations = LEXSelfRegistrationBodyController.getAttestationList();
				Test.stopTest();
			} catch (Exception ex) {
				thrownException = ex;
			}

			Assert.isNotNull(thrownException, 'An error was not thrown');
		}
	}

	@isTest
	private static void getStaticResource() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			Test.startTest();
			String staticResource = LEXSelfRegistrationBodyController.getStaticResource('header');
			Test.stopTest();

			Assert.isNotNull(staticResource, 'No static resource was returned');
		}
	}

	@isTest
	private static void getStaticResource_NoResults() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			Test.startTest();
			String staticResource = LEXSelfRegistrationBodyController.getStaticResource('noteststaticresource123');
			Test.stopTest();

			Assert.isNull(staticResource, 'Did not return null');
		}
	}

	@isTest
	private static void getSections() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			String birthdayMessage = '';
			List<LEXSelfRegistrationBodyController.Section> sections = LEXSelfRegistrationBodyController.getSections(birthdayMessage);

			Assert.isTrue(sections.size() > 0, 'Did not return any sections');
		}
	}

	@isTest
	private static void getSections_NoPagePropertyAccess() {
		User user = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

		System.runAs(user) {
			String birthdayMessage = '';
			Exception thrownException;

			try {
				Test.startTest();
				List<LEXSelfRegistrationBodyController.Section> sections = LEXSelfRegistrationBodyController.getSections(birthdayMessage);
				Test.stopTest();
			} catch (Exception ex) {
				thrownException = ex;
			}

			Assert.isNotNull(thrownException, 'An error was not thrown');
		}
	}

	@isTest
	private static void checkForDupeContactsUsers_NoDuplicates() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			String email = 'lexdupecheckemail@test.com';

			Test.startTest();
			LEXSelfRegistrationBodyController.DupeCheck dupeCheck = LEXSelfRegistrationBodyController.checkForDupeContactsUsers(email);
			Test.stopTest();

			Assert.isFalse(dupeCheck.dupeContactFound, 'Duplicate contact was found');
			Assert.isFalse(dupeCheck.dupeActiveUserFound, 'Duplicate active user was found');
			// Assert.isFalse(dupeCheck.dupeInactiveUserFound, 'Duplicate inactive user was found');
			Assert.isFalse(dupeCheck.dupeAccountFound, 'Duplicate account was found');
		}
	}

	@isTest
	private static void checkForDupeContactsUsers_DuplicateActiveUser() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			String email = 'lexdupecheckemail@test.com';
			new SObjectBuilder(Contact.sObjectType).put(Contact.Email, email).create();

			Test.startTest();
			LEXSelfRegistrationBodyController.DupeCheck dupeCheck = LEXSelfRegistrationBodyController.checkForDupeContactsUsers(email);
			Test.stopTest();

			Assert.isTrue(dupeCheck.dupeContactFound, 'No duplicate contact was found');
			Assert.isFalse(dupeCheck.dupeActiveUserFound, 'Duplicate active user was found');
			// Assert.isFalse(dupeCheck.dupeInactiveUserFound, 'Duplicate inactive user was found');
			Assert.isFalse(dupeCheck.dupeAccountFound, 'Duplicate account was found');
		}
	}

	@isTest
	private static void checkForDupeAccounts_NoDuplicates() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			String accountName = 'LEX Test Account 123';

			Test.startTest();
			LEXSelfRegistrationBodyController.DupeCheck dupeCheck = LEXSelfRegistrationBodyController.checkForDupeAccounts(accountName);
			Test.stopTest();

			Assert.isFalse(dupeCheck.dupeContactFound, 'Duplicate contact was found');
			Assert.isFalse(dupeCheck.dupeActiveUserFound, 'Duplicate active user was found');
			// Assert.isFalse(dupeCheck.dupeInactiveUserFound, 'Duplicate inactive user was found');
			Assert.isFalse(dupeCheck.dupeAccountFound, 'Duplicate account was found');
		}
	}

	@isTest
	private static void checkForDupeAccounts_DuplicateAccount() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			String accountName = 'LEX Test Account 123';
			new SObjectBuilder(Account.sObjectType).put(Account.Name, accountName).create();

			Test.startTest();
			LEXSelfRegistrationBodyController.DupeCheck dupeCheck = LEXSelfRegistrationBodyController.checkForDupeAccounts(accountName);
			Test.stopTest();

			Assert.isFalse(dupeCheck.dupeContactFound, 'Duplicate contact was found');
			Assert.isFalse(dupeCheck.dupeActiveUserFound, 'Duplicate active user was found');
			// Assert.isFalse(dupeCheck.dupeInactiveUserFound, 'Duplicate inactive user was found');
			Assert.isTrue(dupeCheck.dupeAccountFound, 'No duplicate account was found');
		}
	}

	@isTest
	private static void registerUser() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			Contact contact = (Contact) new SObjectBuilder(Contact.sObjectType).put(Contact.Email, 'lextestcontact@lex.com').build().getRecord();
			String contactString = JSON.serialize(contact);
			Account account = (Account) new SObjectBuilder(Account.sObjectType).build().getRecord();
			String accountString = JSON.serialize(account);
			String password = 'Salesforce2023!';
			String contactRecordType = 'Employer';
			String accountRecordType = 'Employer';
			String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;

			Test.startTest();
			String user = LEXSelfRegistrationBodyController.registerUser(
				contactString,
				accountString,
				password,
				contactRecordType,
				accountRecordType,
				profileId
			);
			Test.stopTest();

			Assert.isNull(user, 'User was not created');
		}
	}

	@testSetup
	private static void setup() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		adminUser.UserRoleId = ownerRole.Id;
		update adminUser;
	}
}