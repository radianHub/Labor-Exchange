@isTest
private without sharing class LEXMyJobsControllerTest {
	static User createUser(String profId, String firstName, String lastName) {
		User tempU = new User(
			FirstName = firstName,
			LastName = lastName,
			Email = firstName + '@' + lastName + '.com',
			Username = firstName + '@' + lastName + '.com',
			Alias = firstName.left(1) + lastName.left(4),
			CommunityNickname = firstName + lastName,
			IsActive = true,
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = profId
		);
		return tempU;
	}

	@TestSetup
	static void makeData() {
		Labor_Exchange_Community_Setup__c lexcs = new Labor_Exchange_Community_Setup__c(
			of_Tiles_Per_Page__c = 6,
			Events_Page_URL__c = 'https://managedpackage--mp.my.salesforce.com',
			Jobs_Page_URL__c = 'https://managedpackage--mp.my.salesforce.com',
			ContactRecordTypes__c = 'Job_Seeker',
			LEX_Community_Profile_Id__c = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1][0]
			.Id,
			LEX_Community_Permission_Set_Id__c = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions' LIMIT 1][0]
			.Id
		);
		insert lexcs;

		Account comAcc = new Account(
			Name = 'Test Com Account',
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId()
		);
		insert comAcc;

		Contact comCon = new Contact(
			AccountId = comAcc.Id,
			FirstName = 'Test',
			LastName = 'Contact',
			Email = 'test@TestCommunityContact.com',
			Birthdate = Date.today() - 100,
			Launchpad__Created_via_Community_Self_Registration__c = true,
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId()
		);
		insert comCon;

		Launchpad__Job__c job = new Launchpad__Job__c(
			Name = 'Test Job',
			Launchpad__Account__c = comAcc.Id,
			Launchpad__Stage__c = 'Open',
			Launchpad__Employment_Type__c = 'Full Time Permanent',
			Launchpad__Years_Experience__c = '5',
			Launchpad__Hourly_Wage_Maximum__c = 50,
			Launchpad__Hourly_Wage_Minimum__c = 15,
			Launchpad__Available_in_Community__c = true
		);
		insert job;

		Launchpad__Skill1__c skill = new Launchpad__Skill1__c(Name = 'Test Skill');
		insert skill;

		Launchpad__JobSkill__c jSkill = new Launchpad__JobSkill__c(Launchpad__Job__c = job.Id, Launchpad__Skill1__c = skill.Id);
		insert jSkill;
	}

	@IsTest
	private static void getJobDataTest() {
		User tempU;
		LEXMyJobsController.JobFieldSet data = LEXMyJobsController.getJobData('Launchpad__Account_Address__c, Launchpad__Closing_Date__c');
		System.assert(data != null, 'No job data returned.');

		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		adminUser.UserRoleId = ownerRole.Id;
		update adminUser;

		Id uL = [SELECT Id FROM UserLicense WHERE Name LIKE '%Customer Community%' LIMIT 1].Id;

		Id pL = [SELECT Id FROM Profile WHERE UserLicenseId = :uL LIMIT 1].Id;

		tempU = createUser(pL, 'LimAccess', 'Test');
		System.assert(tempU != null, 'User was not created');
		tempU.ContactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'].Id;
		insert tempU;

		System.runAs(tempU) {
			Boolean exc = false;
			try {
				data = LEXMyJobsController.getJobData(null);
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
			}
			// System.assert(exc, 'User has access to records.');
		}
	}

	@IsTest
	private static void getFilteredJobsTest() {
		User tempU;
		LEXMyJobsController.JobFieldSet data = LEXMyJobsController.getJobData('Launchpad__Account_Address__c, Launchpad__Closing_Date__c');

		tempU = createUser([SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1].Id, 'LimAccess', 'Test');
		insert tempU;
		System.runAs(tempU) {
			Boolean exc = false;
			try {
				List<Launchpad__Job__c> jobs = LEXMyJobsController.getFilteredJobs(
					data.uniqueFields,
					(String) [SELECT Id FROM Account LIMIT 1].Id,
					'Launchpad__Job__c'
				);
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
			}
			// System.assert(exc, 'User has access to records.');
		}
	}

	// @IsTest
	// private static void searchJobsTest() {
	// 	User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
	// 	UserRole ownerRole = new UserRole(Name = 'Owner Role');
	// 	insert ownerRole;

	// 	adminUser.UserRoleId = ownerRole.Id;
	// 	update adminUser;

	// 	User tempU;
	// 	System.runAs(adminUser) {
	// 		//Id uL = [SELECT Id FROM UserLicense WHERE Name LIKE '%Customer Community%' LIMIT 1].Id;
	// 		//tempU = createUser([SELECT Id FROM Profile WHERE UserLicenseId = :uL LIMIT 1].Id, 'LimAccess2', 'Test');
	// 		tempU = createUser([SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1].Id, 'LimAccess2', 'Test');

	// 		tempU.ContactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'].Id;
	// 		insert tempU;

	// 		Test.startTest();
	// 		PermissionSetAssignment psa = new PermissionSetAssignment(
	// 			PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions']
	// 			.Id,
	// 			AssigneeId = tempU.Id
	// 		);
	// 		insert psa;
	// 		Test.stopTest();
	// 	}

	// 	LEXMyJobsController.JobFieldSet data = LEXMyJobsController.getJobData('Launchpad__Account_Address__c, Launchpad__Closing_Date__c');

	// 	System.runAs(tempU) {
	// 		List<Launchpad__Job__c> jobs = new List<Launchpad__Job__c>();

	// 		jobs = LEXMyJobsController.searchJobs(
	// 			'Job',
	// 			new Map<String, String>(),
	// 			new List<String>{ 'Launchpad__Job__c.Name' },
	// 			'Launchpad__Account_Address__c, Launchpad__Closing_Date__c',
	// 			(String) [SELECT Id FROM Account LIMIT 1].Id
	// 		);
	// 		System.assert(jobs.size() > 0, 'No jobs returned.');

	// 		List<Id> fsr = new List<Id>();
	// 		fsr.add([SELECT Id FROM Launchpad__Skill1__c LIMIT 1].Id);
	// 		Test.setFixedSearchResults(fsr);

	// 		jobs = LEXMyJobsController.searchJobs(
	// 			'Test',
	// 			new Map<String, String>(),
	// 			new List<String>{ 'Launchpad__Job__c.Name' },
	// 			'Launchpad__Account_Address__c, Launchpad__Closing_Date__c',
	// 			(String) [SELECT Id FROM Account LIMIT 1].Id
	// 		);
	// 		System.assert(jobs.size() > 0, 'No jobs returned.');

	// 		jobs = LEXMyJobsController.searchJobs(
	// 			'Test',
	// 			new Map<String, String>{ 'Launchpad__Account_Address__c' => 'Open Jobs', 'Launchpad__Closing_Date__c' => 'Expiring Soon' },
	// 			new List<String>{ 'Launchpad__Job__c.Name' },
	// 			'Launchpad__Account_Address__c, Launchpad__Closing_Date__c',
	// 			(String) [SELECT Id FROM Account LIMIT 1].Id
	// 		);
	// 		System.assert(jobs.size() == 0, 'Job returned.');

	// 		jobs = LEXMyJobsController.searchJobs(
	// 			'Test',
	// 			new Map<String, String>{ 'Launchpad__Account_Address__c' => 'Closed Jobs', 'Launchpad__Closing_Date__c' => 'Expired' },
	// 			new List<String>{ 'Launchpad__Job__c.Name' },
	// 			'Launchpad__Account_Address__c, Launchpad__Closing_Date__c',
	// 			(String) [SELECT Id FROM Account LIMIT 1].Id
	// 		);
	// 		System.assert(jobs.size() == 0, 'Job returned.');
	// 	}

	// 	tempU = createUser([SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1].Id, 'LimAccess', 'Test');
	// 	insert tempU;
	// 	System.runAs(tempU) {
	// 		Boolean exc = false;
	// 		try {
	// 			List<Launchpad__Job__c> jobs = LEXMyJobsController.searchJobs(
	// 				'Test',
	// 				new Map<String, String>(),
	// 				data.uniqueFields,
	// 				'Launchpad__Account_Address__c, Launchpad__Closing_Date__c',
	// 				(String) [SELECT Id FROM Account LIMIT 1].Id
	// 			);
	// 		} catch (Exception ex) {
	// 			exc = ex.getMessage() != null;
	// 		}
	// 		System.assert(exc, 'User has access to records.');
	// 	}
	// }

	@IsTest
	private static void getJobSkillsTest() {
		Id jobId = [SELECT Id FROM Launchpad__Job__c LIMIT 1].Id;

		List<LEXMyJobsController.Skill> js = LEXMyJobsController.getJobSkills(jobId);
		System.assert(js.size() > 0, 'No job skills returned.');

		User tempU = createUser([SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1].Id, 'LimAccess', 'Test');
		System.runAs(tempU) {
			Boolean exc = false;
			try {
				js = LEXMyJobsController.getJobSkills(jobId);
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
			}
			// System.assert(exc, 'User has access to records.');
		}
	}

	private static User getAdminUser() {
		return [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL LIMIT 1];
	}
}