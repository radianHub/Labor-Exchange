@isTest
public with sharing class LEXMyHiresControllerTest {
	User testUser;

	@TestSetup
	static void makeData() {
		Account account = new Account();
		account.Name = 'TEST ACCOUNT';
		account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Employer').getRecordTypeId();
		insert account;

		List<Contact> contacts = (List<Contact>) new SObjectBuilder(Contact.sObjectType).count(2).create().getRecords();

		Launchpad__Job__c job = new Launchpad__Job__c();
		job.Name = 'Test Job';
		job.Launchpad__Account__c = account.Id;
		job.Launchpad__Openings__c = 1;
		job.Launchpad__Available_in_Community__c = true;
		job.Launchpad__Source__c = 'Inbound Marketing';
		job.Launchpad__Closing_Date__c = Date.today();

		insert job;

		Launchpad__Applicant_Tracking__c app = new Launchpad__Applicant_Tracking__c();
		app.Launchpad__Participant__c = contacts[0].Id;
		app.Launchpad__Job_Order__c = job.Id;
		app.Launchpad__Stage__c = 'Applied';
		insert app;

		Launchpad__Hire__c hire = new Launchpad__Hire__c();
		hire.Name = 'Test';
		hire.Launchpad__Applicant_Tracking__c = contacts[0].Id;
		hire.Launchpad__Employer__c = account.Id;
		hire.Launchpad__Job__c = job.Id;
		hire.Launchpad__Job_Application__c = app.Id;
		hire.Launchpad__Hire_Date__c = Date.today();
		hire.Launchpad__Annual_Compensation__c = 5;
		hire.Launchpad__Hourly_Wage__c = 10;
		hire.Launchpad__Type__c = 'Full Time';
		hire.Launchpad__Hire_Date__c = Date.today();
		insert hire;
	}

	@isTest
	static void testGetSetupData() {
		Test.startTest();
		LexMyHiresController.HireFieldSet hires = LexMyHiresController.getSetupData();
		Test.stopTest();

		System.assertNotEquals(null, hires, 'Hires were returned');
	}
}