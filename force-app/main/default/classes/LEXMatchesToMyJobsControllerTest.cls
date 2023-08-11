@isTest
private without sharing class LEXMatchesToMyJobsControllerTest {
	@TestSetup
	static void makeData() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		adminUser.UserRoleId = ownerRole.Id;
		update adminUser;

		System.runAs(adminUser) {
			Labor_Exchange_Community_Setup__c lexCommunitySetup = new Labor_Exchange_Community_Setup__c(
				Events_Page_URL__c = 'www.google.com',
				Jobs_Page_URL__c = 'www.google.com',
				of_Tiles_Per_Page__c = 6,
				ContactRecordTypes__c = 'Employer',
				Eligible_Open_Job_Stages__c = 'Open',
				LEX_Community_Profile_Id__c = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1][0]
				.Id,
				LEX_Community_Permission_Set_Id__c = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions' LIMIT 1][0]
				.Id
			);
			insert lexCommunitySetup;

			Account account = (Account) new SObjectBuilder(Account.sObjectType)
				.put(Account.Name, 'Test Com Account')
				.put(Account.RecordTypeId, Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId())
				.put(Account.OwnerId, getAdminUser().Id)
				.create()
				.getRecord();

			Contact contact = (Contact) new SObjectBuilder(Contact.sObjectType)
				.put(Contact.AccountId, account.Id)
				.put(Contact.FirstName, 'Test')
				.put(Contact.LastName, 'Contact')
				.put(Contact.Launchpad__Created_via_Community_Self_Registration__c, true)
				.put(Contact.RecordTypeId, Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId())
				.create()
				.getRecord();

			new SObjectBuilder(User.sObjectType)
				.put(User.FirstName, 'Privileged')
				.put(User.LastName, 'User')
				// .put(User.ProfileId, [SELECT Id FROM Profile WHERE Name = 'Labor Exchange Community User'][0].Id)
				.put(User.ProfileId, [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1][0].Id)
				.put(User.ContactId, contact.Id)
				.create()
				.getRecord();

			new SObjectBuilder(Launchpad__Job__c.sObjectType)
				.put(Launchpad__Job__c.Launchpad__Stage__c, 'Open')
				.put(Launchpad__Job__c.Launchpad__Account__c, account.Id)
				.create();

			new SObjectBuilder(Launchpad__Job__c.sObjectType)
				.put(Launchpad__Job__c.Launchpad__Stage__c, 'Offered')
				.put(Launchpad__Job__c.Launchpad__Account__c, account.Id)
				.create();
		}
	}

	// @isTest
	// private static void getJobData() {
	// 	User communityUser = [SELECT Id FROM User WHERE firstName = 'Privileged' LIMIT 1];

	// 	System.runAs(communityUser) {
	// 		Test.startTest();
	// 		List<Launchpad__Job__C> jobs = LEXMatchesToMyJobsController.getJobData();
	// 		Test.stopTest();

	// 		Assert.areEqual(1, jobs.size(), 'No jobs returned');
	// 	}
	// }

	@isTest
	private static void getJobDataNoContact() {
		User user = (User) new SObjectBuilder(User.sObjectType)
			.put(User.CommunityNickname, 'standarduser' + DateTime.now().getTime())
			.put(User.Username, 'standarduser' + DateTime.now().getTime() + '@' + Math.random() + '.com')
			.create()
			.getRecord();

		System.runAs(user) {
			Exception thrownException;

			try {
				Test.startTest();
				List<Launchpad__Job__c> jobs = LEXMatchesToMyJobsController.getJobData();
				Test.stopTest();
			} catch (Exception ex) {
				thrownException = ex;
			}

			Assert.isNotNull(thrownException, 'No exception thrown');
		}
	}

	@isTest
	private static void getJobMatchesAll() {
		User communityUser = [SELECT Id FROM User WHERE firstName = 'Privileged' LIMIT 1];

		System.runAs(communityUser) {
			String jobFilter = 'All';

			LEXMatchesToMyJobsController.MatchFieldSet matchFieldSet;

			Test.startTest();
			matchFieldSet = LEXMatchesToMyJobsController.getJobMatches(jobFilter);
			Test.stopTest();

			Assert.isNotNull(matchFieldSet, 'No matches');
		}
	}

	@isTest
	private static void getJobMatchesNoContact() {
		User user = (User) new SObjectBuilder(User.sObjectType)
			.put(User.CommunityNickname, 'standarduser' + DateTime.now().getTime())
			.put(User.Username, 'standarduser' + DateTime.now().getTime() + '@' + Math.random() + '.com')
			.create()
			.getRecord();

		System.runAs(user) {
			String jobFilter = 'All';
			Exception thrownException;

			try {
				Test.startTest();
				LEXMatchesToMyJobsController.MatchFieldSet matchFieldSet = LEXMatchesToMyJobsController.getJobMatches(jobFilter);
				Test.stopTest();
			} catch (Exception ex) {
				thrownException = ex;
			}

			Assert.isNotNull(thrownException, 'An error was not thrown');
		}
	}

	private static User getAdminUser() {
		return [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL LIMIT 1];
	}
}