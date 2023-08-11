@isTest
private with sharing class MultiSkillSelectionControllerTest {
	static Launchpad__Job__c job;
	static Account acc;
	static List<String> skillsToCreate;
	static List<String> skillsToDelete;
	static User limAccessU;

	static void makeData() {
		skillsToCreate = new List<String>();
		skillsToDelete = new List<String>();

		limAccessU = new User(
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce']
			.Id,
			FirstName = 'Test',
			LastName = 'Limited Access',
			Alias = 'Test',
			Email = 'testLimitedAccess@launchpadTest.com',
			Username = 'testLimitedAccess@launchpadTest.com',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles'
		);
		insert limAccessU;

		acc = new Account(Name = 'Test Account', RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Employer' AND SObjectType = 'Account'].Id);
		insert acc;

		List<Launchpad__Skill1__c> skills = new List<Launchpad__Skill1__c>();
		Integer count = 10;
		for (Integer i = 0; i < count; i++) {
			Launchpad__Skill1__c s = new Launchpad__Skill1__c(Name = 'Test ' + String.valueOf(i), Launchpad__Active__c = 'Yes');
			skills.add(s);
		}
		insert skills;

		job = new Launchpad__Job__c(
			Name = 'Test Job',
			Launchpad__Stage__c = 'Identified',
			Launchpad__Closing_Date__c = date.today().addDays(30),
			Launchpad__Available_in_Community__c = true,
			Launchpad__Hourly_Wage_Minimum__c = 4,
			Launchpad__Hourly_Wage_Maximum__c = 10,
			Launchpad__Account__c = acc.Id
		);
		insert job;

		Launchpad__JobSkill__c jSkill = new Launchpad__JobSkill__c(Launchpad__Job__c = job.Id, Launchpad__Skill1__c = skills[0].Id);
		insert jSkill;

		List<Launchpad__JobSkill__c> jSkills = new List<Launchpad__JobSkill__c>();
		for (Integer i = 0; i < skills.size(); i++) {
			if (i < 5 && i != 0) {
				Launchpad__JobSkill__c jSkill2 = new Launchpad__JobSkill__c(Launchpad__Job__c = job.Id, Launchpad__Skill1__c = skills[i].Id);
				jSkills.add(jSkill2);
				skillsToDelete.add((String) skills[i].Id);
			} else if (i >= 5) {
				skillsToCreate.add((String) skills[i].Id);
			}
		}
		insert jSkills;
	}

	@IsTest
	static void getSkillsByCategoryTest() {
		makeData();

		List<MultiSkillSelectionController.CategoryWrapper> categories = MultiSkillSelectionController.getSkillsByCategory();
		System.assertEquals(true, categories.size() > 0, 'No skills or categories returned.');

		System.runAs(limAccessU) {
			Boolean exc = false;
			try {
				List<MultiSkillSelectionController.CategoryWrapper> categories2 = MultiSkillSelectionController.getSkillsByCategory();
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
			}
			System.assert(exc, 'User has access to the Skills Object.');
		}
	}

	@IsTest
	static void getSkillsTest() {
		makeData();

		List<SObject> jobSkills = new List<SObject>();

		jobSkills = MultiSkillSelectionController.getSkills((String) job.Id);
		System.assert(jobSkills.size() > 0, 'No Job Skills returned.');

		jobSkills = MultiSkillSelectionController.getSkills((String) acc.Id);
		System.assert(jobSkills.isEmpty(), 'Returned a list of job skills.');

		Boolean exc = false;
		try {
			jobSkills = MultiSkillSelectionController.getSkills(null);
		} catch (Exception ex) {
			exc = ex.getMessage() != null;
			System.assert(exc, 'An Id was passed as parameter.');
		}
		exc = false;

		System.runAs(limAccessU) {
			try {
				jobSkills = MultiSkillSelectionController.getSkills((String) job.Id);
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
				System.assert(exc, 'Limited access user can access records.');
			}
		}
	}

	@IsTest
	static void updateSkillsTest() {
		makeData();

		MultiSkillSelectionController.updateSkills((String) job.Id, skillsToCreate, skillsToDelete);

		List<Launchpad__JobSkill__c> jSkills = [SELECT Id FROM Launchpad__JobSkill__c];
		System.assertEquals(6, jSkills.size(), 'Records not created or deleted.');

		Boolean exc = false;
		try {
			MultiSkillSelectionController.updateSkills(null, skillsToCreate, skillsToDelete);
		} catch (Exception ex) {
			exc = ex.getMessage() != null;
			System.assert(exc, 'Id was passed in as parameter.');
		}
		exc = false;

		System.runAs(limAccessU) {
			try {
				MultiSkillSelectionController.updateSkills((String) job.Id, skillsToCreate, skillsToDelete);
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
				System.assert(exc, 'User has read, delete, or create access.');
			}
		}
		exc = false;

		System.runAs(limAccessU) {
			try {
				JobSkillsService.createJobSkills(new Set<String>{ (String) job.Id }, new Set<String>(skillsToCreate));
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
				System.assert(exc, 'User has create access.');
			}
		}
		exc = false;

		System.runAs(limAccessU) {
			try {
				JobSkillsService.deleteJobSkills(new Set<String>{ (String) job.Id }, new Set<String>(skillsToDelete));
			} catch (Exception ex) {
				exc = ex.getMessage() != null;
				System.assert(exc, 'User has delete and/or read access.');
			}
		}
	}
}