@isTest
public with sharing class LEXEventsControllerTest {
	// ! Exact code from existing test class in the LP base package
	// ! Needs to be modified after any necessary changes are made to the LEXEventsController
	// ! & will use SObjectFactory testing framework instead

	//private static String NAMESPACE_PREFIX = SObjectHelper.getNamespace();
	private static String NAMESPACE_PREFIX = 'Launchpad__';

	@testSetup
	private static void setup() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		adminUser.UserRoleId = ownerRole.Id;
		update adminUser;
	}

	@isTest
	static void getSetupDataReturnHomeData() {
		if (NAMESPACE_PREFIX == null) {
			NAMESPACE_PREFIX = '';
		}

		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		User tempUser;
		Launchpad__Skill1__c lSK;
		System.runAs(adminUser) {
			Account acct = new Account(
				ownerId = adminUser.Id,
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
			insert acct;

			Contact con = new Contact(
				AccountId = acct.Id,
				firstname = 'test',
				lastname = 'test',
				email = 'test@test.com',
				BirthDate = system.today() - 100,
				OtherStreet = 'test',
				OtherState = 'test',
				OtherPostalCode = '302022',
				OtherCity = 'test',
				MailingStreet = 'test',
				MailingState = 'test',
				MailingPostalCode = '302022',
				MailingCity = 'test',
				Launchpad__Created_via_Community_Self_Registration__c = true,
				Launchpad__Wage_Desired__c = 20,
				RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId()
			);
			insert con;

			Id userLicenseId = [SELECT Id FROM UserLicense WHERE name LIKE '%Customer Community%' LIMIT 1].id;
			tempUser = prepareUser([SELECT Id FROM Profile WHERE UserLicenseId = :userLicenseId LIMIT 1].Id, 'test12ni', 'test12ni');
			tempUser.ContactId = con.Id;
			insert tempUser;
			PermissionSet testPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions'];
			PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = tempUser.Id, PermissionSetId = testPermissionSet.Id);
			insert psa;
		}
		Labor_Exchange_Community_Setup__c lexCommunitySetup = Labor_Exchange_Community_Setup__c.getOrgDefaults();

		Launchpad__Event__c e = new Launchpad__Event__c();
		e.Launchpad__Status__c = 'Active';
		e.Name = 'Test';
		e.RecordTypeId = Schema.SObjectType.Launchpad__Event__c.getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId();
		e.Launchpad__Start_Date__c = system.today();
		e.Launchpad__Event_Type__c = 'On Demand Video';
		e.Launchpad__Long_Description_for_Community__c = 'Test';
		e.Launchpad__Capacity__c = 100;
		e.Launchpad__Available_in_Community__c = true;
		insert e;
		Map<String, List<String>> filterOptionsMap = new Map<String, List<String>>();
		List<String> typeList = new List<String>();
		typeList.add('On Demand Video');
		typeList.add('Live Virtual');
		List<String> topicList = new List<String>();
		List<String> aviaList = new List<String>();
		topicList.add('Career Navigation');
		topicList.add('Computers');
		aviaList.add('Yes');
		aviaList.add('No');
		filterOptionsMap.put(NAMESPACE_PREFIX + 'Event_Type__c', typeList);
		filterOptionsMap.put(NAMESPACE_PREFIX + 'Workshop_Topics__c', topicList);
		filterOptionsMap.put(NAMESPACE_PREFIX + 'Available_in_Community__c', aviaList);
		List<String> uniqueFields = new List<String>();
		uniqueFields.add(NAMESPACE_PREFIX + 'Short_Description_for_Community__c');
		uniqueFields.add(NAMESPACE_PREFIX + 'Type__c');
		System.runAs(tempUser) {
			LEXEventsController.getEventData(e.Id, uniqueFields, NAMESPACE_PREFIX + 'Available_in_Community__c');
			LEXEventsController.searchEvents(
				'test',
				system.today(),
				filterOptionsMap,
				uniqueFields,
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Event_Type__c,Type__c,Workshop_Topics__c,Available_in_Community__c,Long_Description_for_Community__c'
			);
			LEXEventsController.EventsSetupData result = LEXEventsController.getSetupData(
				'Home',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Event_Type__c,Type__c,Workshop_Topics__c,Available_in_Community__c'
			);
			system.assert(result != null, 'Result is null');
		}

		System.runAs(tempUser) {
			LEXEventsController.getEventData(e.Id, uniqueFields, NAMESPACE_PREFIX + 'Available_in_Community__c');
			LEXEventsController.searchEvents(
				'test',
				system.today(),
				filterOptionsMap,
				uniqueFields,
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				'Launchpad__Event_Type__c,Launchpad__Type__c,Launchpad__Workshop_Topics__c,Launchpad__Available_in_Community__c,Launchpad__Long_Description_for_Community__c,'
			);
			LEXEventsController.EventsSetupData result = LEXEventsController.getSetupData(
				'Home',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Event_Type__c,Type__c,Workshop_Topics__c,Available_in_Community__c'
			);
			system.assert(result != null, 'Result is null');
		}

	}

	@isTest
	static void getSetupDataReturnHomeDataNoAccess() {
		if (NAMESPACE_PREFIX == null) {
			NAMESPACE_PREFIX = '';
		}

		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		User tempUser;
		Launchpad__Skill1__c lSK;
		System.runAs(adminUser) {
			Account acct = new Account(
				ownerId = adminUser.Id,
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
			insert acct;

			Contact con = new Contact(
				AccountId = acct.Id,
				firstname = 'test',
				lastname = 'test',
				email = 'test@test.com',
				BirthDate = system.today() - 100,
				OtherStreet = 'test',
				OtherState = 'test',
				OtherPostalCode = '302022',
				OtherCity = 'test',
				MailingStreet = 'test',
				MailingState = 'test',
				MailingPostalCode = '302022',
				MailingCity = 'test',
				Launchpad__Created_via_Community_Self_Registration__c = true,
				Launchpad__Wage_Desired__c = 20,
				RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId()
			);
			insert con;
			tempUser = (User) new SObjectBuilder(User.sObjectType).create().getRecord();
			Id userLicenseId = [SELECT Id FROM UserLicense WHERE name LIKE '%Customer Community%' LIMIT 1].id;
			/**tempUser = prepareUser([SELECT Id FROM Profile WHERE UserLicenseId = :userLicenseId LIMIT 1].Id, 'test12ni', 'test12ni');
			tempUser.ContactId = con.Id;
			insert tempUser;
			/**PermissionSet testPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'LaborExchange_Community_Permission_Set'];
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = tempUser.Id, PermissionSetId = testPermissionSet.Id);
            insert psa;**/
		}
		Labor_Exchange_Community_Setup__c lexCommunitySetup = Labor_Exchange_Community_Setup__c.getOrgDefaults();

		Launchpad__Event__c e = new Launchpad__Event__c();
		e.Launchpad__Status__c = 'Active';
		e.Name = 'Test';
		e.RecordTypeId = Schema.SObjectType.Launchpad__Event__c.getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId();
		e.Launchpad__Start_Date__c = system.today();
		e.Launchpad__Event_Type__c = 'On Demand Video';
		e.Launchpad__Long_Description_for_Community__c = 'Test';
		e.Launchpad__Capacity__c = 100;
		e.Launchpad__Available_in_Community__c = true;
		insert e;
		Map<String, List<String>> filterOptionsMap = new Map<String, List<String>>();
		List<String> typeList = new List<String>();
		typeList.add('On Demand Video');
		typeList.add('Live Virtual');
		List<String> topicList = new List<String>();
		List<String> aviaList = new List<String>();
		topicList.add('Career Navigation');
		topicList.add('Computers');
		aviaList.add('Yes');
		aviaList.add('No');
		filterOptionsMap.put(NAMESPACE_PREFIX + 'Event_Type__c', typeList);
		filterOptionsMap.put(NAMESPACE_PREFIX + 'Workshop_Topics__c', topicList);
		filterOptionsMap.put(NAMESPACE_PREFIX + 'Available_in_Community__c', aviaList);
		List<String> uniqueFields = new List<String>();
		uniqueFields.add(NAMESPACE_PREFIX + 'Short_Description_for_Community__c');
		uniqueFields.add(NAMESPACE_PREFIX + 'Type__c');
		System.runAs(tempUser) {
			Exception thrownException;

			try {
				Test.startTest();
				LEXEventsController.getEventData(e.Id, uniqueFields, NAMESPACE_PREFIX + 'Available_in_Community__c');
				LEXEventsController.searchEvents(
					'test',
					system.today(),
					filterOptionsMap,
					uniqueFields,
					NAMESPACE_PREFIX + 'Available_in_Community__c',
					NAMESPACE_PREFIX + 'Available_in_Community__c',
					NAMESPACE_PREFIX + 'Event_Type__c,Type__c,Workshop_Topics__c,Available_in_Community__c,Long_Description_for_Community__c'
				);
				LEXEventsController.EventsSetupData result = LEXEventsController.getSetupData(
					'Home',
					NAMESPACE_PREFIX + 'Available_in_Community__c',
					NAMESPACE_PREFIX + 'Available_in_Community__c',
					NAMESPACE_PREFIX + 'Event_Type__c,Type__c,Workshop_Topics__c,Available_in_Community__c'
				);
				Test.stopTest();
			} catch (Exception ex) {
				thrownException = ex;
			}

			Assert.isNotNull(thrownException, 'An error was not thrown');
		}
	}

	@isTest
	static void getSetupDataReturnSkillBuildingData() {
		if (NAMESPACE_PREFIX == null) {
			NAMESPACE_PREFIX = '';
		}
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		User tempUser;
		Launchpad__Skill1__c lSK;
		System.runAs(adminUser) {
			Account acct = new Account(
				ownerId = adminUser.Id,
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
			insert acct;

			Contact con = new Contact(
				AccountId = acct.Id,
				firstname = 'test',
				lastname = 'test',
				email = 'test@test.com',
				BirthDate = system.today() - 100,
				OtherStreet = 'test',
				OtherState = 'test',
				OtherPostalCode = '302022',
				OtherCity = 'test',
				MailingStreet = 'test',
				MailingState = 'test',
				MailingPostalCode = '302022',
				MailingCity = 'test',
				Launchpad__Created_via_Community_Self_Registration__c = true,
				Launchpad__Wage_Desired__c = 20,
				RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId()
			);
			insert con;

			Id userLicenseId = [SELECT Id FROM UserLicense WHERE name LIKE '%Customer Community%' LIMIT 1].id;
			Id profId = [SELECT Id FROM Profile WHERE UserLicenseId = :userLicenseId LIMIT 1].Id;
			tempUser = prepareUser([SELECT Id FROM Profile WHERE UserLicenseId = :userLicenseId LIMIT 1].Id, 'test12ni', 'test12ni');
			tempUser.ContactId = con.Id;
			insert tempUser;
			PermissionSet testPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions'];
			PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = tempUser.Id, PermissionSetId = testPermissionSet.Id);
			insert psa;

			/**tempU = createUser([SELECT Id FROM Profile WHERE Name = 'Labor Exchange Community User' LIMIT 1].Id, 'LimAccess2', 'Test');

		    tempU.ContactId = [SELECT Id FROM Contact WHERE FirstName = 'Test'].Id;

            Test.startTest();
		    insert tempU;
		    Test.stopTest();**/
		}

		Labor_Exchange_Community_Setup__c lexCommunitySetup = Labor_Exchange_Community_Setup__c.getOrgDefaults();

		Launchpad__Event__c e = new Launchpad__Event__c();
		e.Launchpad__Status__c = 'Active';
		e.Name = 'Test';
		e.RecordTypeId = Schema.SObjectType.Launchpad__Event__c.getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId();
		e.Launchpad__Start_Date__c = System.today();
		e.Launchpad__Event_Type__c = 'On Demand Video';
		e.Launchpad__Long_Description_for_Community__c = 'Test';
		e.Launchpad__Capacity__c = 100;
		e.Launchpad__Available_in_Community__c = true;
		insert e;
		Map<String, List<String>> filterOptionsMap = new Map<String, List<String>>();
		List<String> typeList = new List<String>();
		typeList.add('On Demand Video');
		typeList.add('Live Virtual');
		filterOptionsMap.put(NAMESPACE_PREFIX + 'Event_Type__c', typeList);
		List<String> uniqueFields = new List<String>();
		uniqueFields.add(NAMESPACE_PREFIX + 'Short_Description_for_Community__c');
		uniqueFields.add(NAMESPACE_PREFIX + 'Type__c');
		System.runAs(tempUser) {
			LEXEventsController.searchEvents(
				'test',
				System.today(),
				filterOptionsMap,
				uniqueFields,
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Event_Type__c,Type__c,Workshop_Topics__c,Available_in_Community__c'
			);
			LEXEventsController.EventsSetupData result = LEXEventsController.getSetupData(
				'SkillBuilding',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Available_in_Community__c',
				NAMESPACE_PREFIX + 'Event_Type__c,Type__c,Workshop_Topics__c,Available_in_Community__c'
			);
			System.assert(result != null, 'Result is null');
		}
	}

	@isTest
	static void getDownloadLinkReturnDownloadLink() {
		if (NAMESPACE_PREFIX == null) {
			NAMESPACE_PREFIX = '';
		}
		Account acc = new Account(
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

		Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId();

		Contact c = new Contact();
		c.FirstName = 'testcc';
		c.lastname = 'testcc';
		c.Email = 'testcc@ghjkmail.com';
		c.OtherStreet = 'testcc';
		c.OtherState = 'testcc';
		c.OtherPostalCode = '552022';
		c.OtherCity = 'testcc';
		c.Launchpad__Stage__c = 'Enrollment';
		c.RecordTypeId = recordTypeIdContact;
		insert c;

		Launchpad__Event__c e = new Launchpad__Event__c();
		insert e;

		Launchpad__Document__c newDocument = new Launchpad__Document__c();
		newDocument.Launchpad__Title__c = String.valueOf('TestDocument.pdf');
		newDocument.Launchpad__Type__c = 'Event Documentation';
		newDocument.Launchpad__Contact__c = c.Id;
		newDocument.Launchpad__Event__c = e.Id;
		insert newDocument;

		Contentversion cv = new Contentversion();
		cv.Title = 'ABC';
		cv.PathOnClient = 'test';
		cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8'));
		insert cv;

		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
		cdl.LinkedEntityId = newDocument.Id;
		cdl.ShareType = 'V';
		insert cdl;

		Test.startTest();
		List<String> links = LEXEventsController.getDownloadLink(e.Id);
		Test.stopTest();

		System.assertEquals(1, links.size(), 'No link returned');
	}

	@isTest
	static void getDownloadLinkReturnDownloadLinkNoAccess() {
		if (NAMESPACE_PREFIX == null) {
			NAMESPACE_PREFIX = '';
		}
		Account acc = new Account(
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

		Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Job Seeker').getRecordTypeId();

		Contact c = new Contact();
		c.FirstName = 'testcc';
		c.lastname = 'testcc';
		c.Email = 'testcc@ghjkmail.com';
		c.OtherStreet = 'testcc';
		c.OtherState = 'testcc';
		c.OtherPostalCode = '552022';
		c.OtherCity = 'testcc';
		c.Launchpad__Stage__c = 'Enrollment';
		c.RecordTypeId = recordTypeIdContact;
		insert c;

		Launchpad__Event__c e = new Launchpad__Event__c();
		insert e;

		Launchpad__Document__c newDocument = new Launchpad__Document__c();
		newDocument.Launchpad__Title__c = String.valueOf('TestDocument.pdf');
		newDocument.Launchpad__Type__c = 'Event Documentation';
		newDocument.Launchpad__Contact__c = c.Id;
		newDocument.Launchpad__Event__c = e.Id;
		insert newDocument;

		Contentversion cv = new Contentversion();
		cv.Title = 'ABC';
		cv.PathOnClient = 'test';
		cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8'));
		insert cv;

		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
		cdl.LinkedEntityId = newDocument.Id;
		cdl.ShareType = 'V';
		insert cdl;

		try {
			Profile readOnlyProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Read Only%' LIMIT 1];
			// Generate a unique username
			String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
			// Create an active read only user, representing a user without access
			User readOnlyUser = new User(
				Alias = 'u',
				Email = 'user@testingreadonlyuser.com',
				LastName = 'Testing',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				ProfileId = readOnlyProfile.Id,
				TimeZoneSidKey = 'America/Los_Angeles',
				UserName = uniqueUserName,
				IsActive = true,
				EmailEncodingKey = 'UTF-8'
			);
			insert readOnlyUser;
			System.runAs(readOnlyUser) {
				LEXEventsController.getDownloadLink(e.Id);
			}
		} catch (Exception e2) {
			Boolean expectedExceptionThrown = e2.getMessage().contains('exception') ? true : false;
			System.assertEquals(false, expectedExceptionThrown, 'The expected exception was not thrown.');
		}
	}

	@isTest
	static void registerForEventReturnEventRegistrationSuccessful() {
		if (NAMESPACE_PREFIX == null) {
			NAMESPACE_PREFIX = '';
		}
		Account acc = new Account(
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

		Contact c = new Contact();
		c.FirstName = 'sfsdf';
		c.lastname = 'sfsf';
		c.Launchpad__Stage__c = 'Enrollment';
		c.OtherStreet = 'test';
		c.OtherState = 'test';
		c.OtherPostalCode = '302022';
		c.OtherCity = 'test';
		c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId();
		c.Email = 'test@test.com';
		insert c;

		Launchpad__Event__c e = new Launchpad__Event__c();
		e.RecordTypeId = Schema.SObjectType.Launchpad__Event__c.getRecordTypeInfosByName().get('Workshop').getRecordTypeId();
		insert e;

		Launchpad__Event__c e2 = new Launchpad__Event__c();
		e2.Launchpad__Event_Type__c = 'On Demand Video';
		e2.RecordTypeId = Schema.SObjectType.Launchpad__Event__c.getRecordTypeInfosByName().get('Workshop').getRecordTypeId();
		insert e2;

		Launchpad__Document__c newDocument = new Launchpad__Document__c();
		newDocument.Launchpad__Title__c = String.valueOf('TestDocument.pdf');
		newDocument.Launchpad__Type__c = 'Event Documentation';
		newDocument.Launchpad__Contact__c = c.Id;
		newDocument.Launchpad__Event__c = e.Id;
		insert newDocument;

		Contentversion cv = new Contentversion();
		cv.Title = 'ABC';
		cv.PathOnClient = 'test';
		cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8'));
		insert cv;

		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
		cdl.LinkedEntityId = newDocument.Id;
		cdl.ShareType = 'V';
		insert cdl;

		// List<User> currentUser = [SELECT Id, ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			Boolean success = LEXEventsController.registerForEvent(e.Id);

			System.assert(success, 'Did not register for event');

			success = LEXEventsController.cancelRegisterForEvent(e.Id);

			System.assert(success, 'Did not cancel event registration');

			success = LEXEventsController.registerForEvent(e.Id);
			LEXEventsController.registerForEvent(e2.Id);

			System.assert(success, 'Did not register for event');
		}
	}

	@isTest
	static void registerForEventReturnEventRegistrationSuccessfulNoAccess() {
		if (NAMESPACE_PREFIX == null) {
			NAMESPACE_PREFIX = '';
		}
		Account acc = new Account(
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

		Contact c = new Contact();
		c.FirstName = 'sfsdf';
		c.lastname = 'sfsf';
		c.Launchpad__Stage__c = 'Enrollment';
		c.OtherStreet = 'test';
		c.OtherState = 'test';
		c.OtherPostalCode = '302022';
		c.OtherCity = 'test';
		c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId();
		c.Email = 'test@test.com';
		insert c;

		Launchpad__Event__c e = new Launchpad__Event__c();
		e.RecordTypeId = Schema.SObjectType.Launchpad__Event__c.getRecordTypeInfosByName().get('Workshop').getRecordTypeId();
		insert e;

		Launchpad__Event__c e2 = new Launchpad__Event__c();
		e2.Launchpad__Event_Type__c = 'On Demand Video';
		e2.RecordTypeId = Schema.SObjectType.Launchpad__Event__c.getRecordTypeInfosByName().get('Workshop').getRecordTypeId();
		insert e2;

		Launchpad__Document__c newDocument = new Launchpad__Document__c();
		newDocument.Launchpad__Title__c = String.valueOf('TestDocument.pdf');
		newDocument.Launchpad__Type__c = 'Event Documentation';
		newDocument.Launchpad__Contact__c = c.Id;
		newDocument.Launchpad__Event__c = e.Id;
		insert newDocument;

		Contentversion cv = new Contentversion();
		cv.Title = 'ABC';
		cv.PathOnClient = 'test';
		cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8'));
		insert cv;

		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
		cdl.LinkedEntityId = newDocument.Id;
		cdl.ShareType = 'V';
		insert cdl;

		//List<User> currentUser = [SELECT Id, ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
		User currentUser = (User) new SObjectBuilder(User.sObjectType).create().getRecord();
		System.runAs(currentUser) {
			Exception thrownException;

			try {
				Test.startTest();
				Boolean success = LEXEventsController.registerForEvent(e.Id);
				Test.stopTest();
			} catch (Exception ex) {
				thrownException = ex;
			}

			Assert.isNotNull(thrownException, 'An error was not thrown');
		}
	}

	private static User prepareUser(String profId, String firstName, String lastName) {
		User tempUser = new User(
			FirstName = firstName,
			LastName = lastName,
			email = firstName + '@' + lastName + '.com',
			Username = firstName + '@' + lastName + '.com',
			EmailEncodingKey = 'ISO-8859-1',
			Alias = 'test@12',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			ProfileId = profId,
			CommunityNickname = firstName,
			IsActive = true
		);
		return tempUser;
	}
}