@isTest
private without sharing class LEXCandidateApplicationsControllerTest {
	static User createUser(String profId, String firstName, String lastName) {
		User tempU;
		System.runAs(getAdminUser()) {
			String contactId = [SELECT Id FROM Contact WHERE LastName = 'Contact'].Id;
			tempU = (User) new SObjectBuilder(User.sObjectType)
				.put(User.FirstName, firstName)
				.put(User.LastName, lastName)
				.put(User.Email, firstName + '@' + lastName + '.com')
				.put(User.Email, firstName + '@' + lastName + '.com')
				.put(User.Username, firstName + '@' + MATH.random() * 100 + lastName + '.com')
				.put(User.Alias, firstName.left(1) + lastName.left(4))
				.put(User.CommunityNickname, firstName + lastName)
				.put(User.IsActive, true)
				.put(User.TimeZoneSidKey, 'America/Los_Angeles')
				.put(User.LocaleSidKey, 'en_US')
				.put(User.LanguageLocaleKey, 'en_US')
				.put(User.EmailEncodingKey, 'UTF-8')
				.put(User.ProfileId, profId)
				.put(User.ContactId, contactId)
				.create()
				.getRecord();
		}
		return tempU;
	}

	static void makeData() {
		Labor_Exchange_Community_Setup__c lexcs = new Labor_Exchange_Community_Setup__c(
			of_Tiles_Per_Page__c = 6,
			Events_Page_URL__c = 'https://managedpackage--mp.my.salesforce.com',
			Jobs_Page_URL__c = 'https://managedpackage--mp.my.salesforce.com',
			ContactRecordTypes__c = 'Job_Seeker',
			Applications_Tile_1_Stages__c = 'Applied',
			Applications_Tile_2_Stages__c = 'Interviewing',
			Applications_Tile_3_Stages__c = 'Offered'
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

		Contact jobSeeker = new Contact(
			AccountId = comAcc.Id,
			FirstName = 'Test',
			LastName = 'JobSeeker',
			Email = 'test@TestJobSeekerContact.com',
			Birthdate = Date.today() - 100,
			Launchpad__Created_via_Community_Self_Registration__c = true,
			RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId()
		);
		insert jobSeeker;

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

		Launchpad__Applicant_Tracking__c app = new Launchpad__Applicant_Tracking__c(
			Launchpad__Participant__c = jobSeeker.Id,
			Launchpad__Job_Order__c = job.Id,
			Launchpad__Submitted_via_Job_Seeker_Community__c = true,
			Launchpad__Stage__c = 'Applied'
		);
		insert app;

		Launchpad__Applicant_Tracking__c app1 = new Launchpad__Applicant_Tracking__c(
			Launchpad__Participant__c = jobSeeker.Id,
			Launchpad__Job_Order__c = job.Id,
			Launchpad__Submitted_via_Job_Seeker_Community__c = true,
			Launchpad__Stage__c = 'Interviewing'
		);
		insert app1;

		Launchpad__Applicant_Tracking__c app2 = new Launchpad__Applicant_Tracking__c(
			Launchpad__Participant__c = jobSeeker.Id,
			Launchpad__Job_Order__c = job.Id,
			Launchpad__Submitted_via_Job_Seeker_Community__c = true
		);
		insert app2;

		Launchpad__Document__c doc = new Launchpad__Document__c(
			Launchpad__Title__c = 'Test Resume',
			Launchpad__Type__c = 'Resume',
			Available_in_Community__c = true,
			Launchpad__Date__c = Date.today(),
			Launchpad__Contact__c = jobSeeker.Id,
			Launchpad__Job_Application__c = app.Id
		);
		insert doc;

		ContentVersion cv = new ContentVersion(Title = doc.Launchpad__Title__c, PathOnClient = 'test.pdf', VersionData = Blob.valueOf('Test Blob'));
		insert cv;

		ContentDocumentLink cdl = new ContentDocumentLink(
			ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]
			.ContentDocumentId,
			LinkedEntityId = doc.Id,
			Visibility = 'AllUsers'
		);
		insert cdl;
	}

	@IsTest
	private static void getSetupDataTest() {
		System.runAs(getAdminUser()) {
			makeData();
			User tempU;
			LEXCandidateApplicationsController.ApplicationFieldSet data;

			Id uL = [SELECT Id FROM UserLicense WHERE Name LIKE '%Customer Community%' LIMIT 1].Id;

			tempU = (User) new SObjectBuilder(User.sObjectType).build().getRecord();

			User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

			UserRole ownerRole = new UserRole(Name = 'Owner Role');
			insert ownerRole;

			adminUser.UserRoleId = ownerRole.Id;
			update adminUser;

			System.runAs(adminUser) {
				tempU = createUser(
					[SELECT Id FROM Profile WHERE UserLicenseId = :uL AND Name != 'Labor Exchange Community User' LIMIT 1].Id,
					'ComUser',
					'Test'
				);
			}

			PermissionSetAssignment psa = new PermissionSetAssignment(
				PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions']
				.Id,
				AssigneeId = tempU.Id
			);
			insert psa;
			System.runAs(tempU) {
				data = LEXCandidateApplicationsController.getSetupData();
			}

			//tempU = createUser([SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1].Id, 'LimAccess', 'Test');
			String firstName = 'ComUser2';
			String lastName = 'Test2';

			tempU = new User(
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
				ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1]
				.Id
			);
			insert tempU;

			System.runAs(tempU) {
				Boolean exc = false;
				try {
					data = LEXCandidateApplicationsController.getSetupData();
				} catch (Exception ex) {
					exc = ex.getMessage() != null;
				}
				// System.assert(exc, 'User has access to records.');
			}
		}
	}

	@IsTest
	private static void emailCandidate() {
		System.runAs(getAdminUser()) {
			makeData();

			Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Contact'];
			String emailBody = 'Test email';

			Test.startTest();
			LEXCandidateApplicationsController.emailCandidate(contact.Id, emailBody);
			Test.stopTest();

			List<EmailMessage> emails = [SELECT Id FROM EmailMessage];
			Assert.areEqual(1, emails.size(), 'No email was sent');
		}
	}

	// @IsTest
	// private static void createRequestTaskTest() {
	// 	User tempU;

	// 	Launchpad__Applicant_Tracking__c app = [SELECT Id FROM Launchpad__Applicant_Tracking__c LIMIT 1];

	// 	Boolean createTask = LEXCandidateApplicationsController.createUpdateRequestTask(app.Id, 'Test');
	// 	System.assert(createTask, 'No task created.');

	// 	String firstName = 'ComUser2';
	// 	String lastName = 'Test2';

	// 	tempU = new User(
	// 		FirstName = firstName,
	// 		LastName = lastName,
	// 		Email = firstName + '@' + lastName + '.com',
	// 		Username = firstName + '@' + lastName + '.com',
	// 		Alias = firstName.left(1) + lastName.left(4),
	// 		CommunityNickname = firstName + lastName,
	// 		IsActive = true,
	// 		TimeZoneSidKey = 'America/Los_Angeles',
	// 		LocaleSidKey = 'en_US',
	// 		LanguageLocaleKey = 'en_US',
	// 		EmailEncodingKey = 'UTF-8',
	// 		ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1]
	// 		.Id
	// 	);
	// 	insert tempU;
	// 	System.runAs(tempU) {
	// 		Boolean exc = false;
	// 		try {
	// 			createTask = LEXCandidateApplicationsController.createUpdateRequestTask(app.Id, 'Test');
	// 		} catch (Exception ex) {
	// 			exc = ex.getMessage() != null;
	// 		}
	// 		System.assert(exc, 'User has access to records.');
	// 	}
	// }

	@IsTest
	private static void getJobDataTest() {
		System.runAs(getAdminUser()) {
			makeData();

			User tempU;
			LEXCandidateApplicationsController.JobData data;

			Id uL = [SELECT Id FROM UserLicense WHERE Name LIKE '%Customer Community%' LIMIT 1].Id;

			User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

			UserRole ownerRole = new UserRole(Name = 'Owner Role');
			insert ownerRole;

			adminUser.UserRoleId = ownerRole.Id;
			update adminUser;

			// System.runAs(adminUser) {
			tempU = createUser([SELECT Id FROM Profile WHERE UserLicenseId = :uL AND Name != 'Labor Exchange Community User' LIMIT 1].Id, 'ComUser', 'Test');
			// }
			//tempU.ContactId = [SELECT Id FROM Contact WHERE LastName = 'Contact'].Id;
			//insert tempU;
			PermissionSetAssignment psa = new PermissionSetAssignment(
				PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions']
				.Id,
				AssigneeId = tempU.Id
			);
			insert psa;

			Launchpad__Applicant_Tracking__c app = [SELECT Id FROM Launchpad__Applicant_Tracking__c LIMIT 1];
			System.runAs(tempU) {
				data = LEXCandidateApplicationsController.getJobData(app.Id);
				System.assert(data != null, 'No data returned.');
			}

			String firstName = 'ComUser2';
			String lastName = 'Test2';

			tempU = new User(
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
				ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1]
				.Id
			);
			insert tempU;
			System.runAs(tempU) {
				Boolean exc = false;
				try {
					data = LEXCandidateApplicationsController.getJobData(app.Id);
				} catch (Exception ex) {
					exc = ex.getMessage() != null;
				}
				System.assert(exc, 'User has access to records.');
			}
		}
	}

	@IsTest
	private static void getPicklistValuesTest() {
		System.runAs(getAdminUser()) {
			makeData();
			List<LEXCommunityHelper.Option> values = LEXCandidateApplicationsController.getPicklistValues(
				'Launchpad__Applicant_Tracking__c',
				'Launchpad__Stage__c'
			);
			System.assert(values.size() > 0, 'No values returned');
		}
	}

	@IsTest
	private static void getResumesTest() {
		System.runAs(getAdminUser()) {
			makeData();
			Launchpad__Applicant_Tracking__c app = [SELECT Id FROM Launchpad__Applicant_Tracking__c WHERE Launchpad__Stage__c = 'Applied'];
			List<LEXCandidateApplicationsController.DocumentData> data = LEXCandidateApplicationsController.getResumes((String) app.Id);
			System.assert(data.size() > 0, 'No document data returned.');

			app = [SELECT Id FROM Launchpad__Applicant_Tracking__c WHERE Launchpad__Stage__c = 'Interviewing'];
			data = LEXCandidateApplicationsController.getResumes((String) app.Id);
			System.assert(data == null, 'Document data returned');

			User tempU;
			String firstName = 'ComUser2';
			String lastName = 'Test2';

			tempU = new User(
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
				ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1]
				.Id
			);
			insert tempU;
			System.runAs(tempU) {
				Boolean exc = false;
				try {
					data = LEXCandidateApplicationsController.getResumes((String) app.Id);
				} catch (Exception ex) {
					exc = ex.getMessage() != null;
				}
				// System.assert(exc, 'User has access to records.');
			}
		}
	}

	@IsTest
	private static void updateApplicationTest() {
		System.runAs(getAdminUser()) {
			makeData();
			Launchpad__Applicant_Tracking__c app = [
				SELECT Id, Launchpad__Stage__c
				FROM Launchpad__Applicant_Tracking__c
				WHERE Launchpad__Stage__c = 'Applied'
			];
			app.Launchpad__Stage__c = 'Interviewing';
			LEXCandidateApplicationsController.updateApplication(JSON.serialize(app));

			List<Launchpad__Applicant_Tracking__c> appUpdate = [
				SELECT Id
				FROM Launchpad__Applicant_Tracking__c
				WHERE Launchpad__Stage__c = 'Interviewing'
			];
			System.assert(appUpdate.size() == 2, 'Application not updated.');

			Boolean exc = false;
			try {
				LEXCandidateApplicationsController.updateApplication('test');
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
			}
			// System.assert(exc, 'User has access to records.');
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