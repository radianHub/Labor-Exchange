@isTest
private class LEXCandidateSearchControllerTest {
	private static final String NAMESPACE_PREFIX = SObjectHelper.getNamespace();
	private static final List<String> FIELDS = new List<String>{
		'Title',
		'Launchpad__Wage_Desired__c',
		'Launchpad__Years_Experience__c',
		'Launchpad__of_Client_Skills__c',
		'Launchpad__Working_Environment__c',
		'Launchpad__Eligibility_to_Work_in_the_U_S__c',
		'Launchpad__CIF_Date_Attained_Degree_or_Certificate__c',
		'Launchpad__Certifications__c',
		'Launchpad__Underemployed__c',
		'Launchpad__Active__c',
		'Launchpad__Industries__c'
	};

	@TestSetup
	public static void setupData() {
		Labor_Exchange_Community_Setup__c lexCS = (Labor_Exchange_Community_Setup__c) new SObjectBuilder(Labor_Exchange_Community_Setup__c.SObjectType)
			.put(Labor_Exchange_Community_Setup__c.of_Tiles_Per_Page__c, 6)
			.put(Labor_Exchange_Community_Setup__c.ContactRecordTypes__c, 'Job_Seeker')
			.put(
				Labor_Exchange_Community_Setup__c.Events_Page_URL__c,
				'https://launchpad-laborexchange--lexdeves.sandbox.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Flaunchpad-laborexchange--lexdeves.sandbox.salesforce-experience.com%2FLaborExchange%2Fs%2F&'
			)
			.put(
				Labor_Exchange_Community_Setup__c.Jobs_Page_URL__c,
				'https://launchpad-laborexchange--lexdeves.sandbox.my.salesforce.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Flaunchpad-laborexchange--lexdeves.sandbox.salesforce-experience.com%2FLaborExchange%2Fs%2F&'
			)
			.create()
			.getRecord();

		//Verify we have at least one Record Type listed in settings
		String contactRecordTypeName = LEXCandidateSearchController.CONTACT_RECORD_TYPE_API_NAMES[0];

		Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecordTypeName).getRecordTypeId();
		System.assert(contactRecordTypeId != null, 'LEX Community Setup Custom Settings is missing Record Types, or are not in proper comma-separated format.');

		Contact contact = (Contact) new SObjectBuilder(Contact.sObjectType)
			.put(Contact.RecordTypeId, contactRecordTypeId)
			.put(Contact.Title, 'Salesforce Developer')
			.put(Contact.Launchpad__Certifications__c, 'A')
			.put(Contact.Launchpad__Underemployed__c, true)
			.put(Contact.Launchpad__Active__c, 'Yes')
			.put(Contact.Launchpad__Industries__c, 'Healthcare')
			.put(Contact.Email, 'testemail@email.com')
			.create()
			.getRecord();

		Launchpad__Skill1__c skill = (Launchpad__Skill1__c) new SObjectBuilder(Launchpad__Skill1__c.SObjectType)
			.put(Launchpad__Skill1__c.Name, 'Excel')
			.create()
			.getRecord();

		Launchpad__Client_Skill__c clientSkill = (Launchpad__Client_Skill__c) new SObjectBuilder(Launchpad__Client_Skill__c.SObjectType)
			.put(Launchpad__Client_Skill__c.Launchpad__Client__c, contact.Id)
			.put(Launchpad__Client_Skill__c.Launchpad__Skill1__c, skill.Id)
			.create()
			.getRecord();

		System.assertEquals(
			1,
			[SELECT COUNT() FROM Contact WHERE RecordType.DeveloperName = :contactRecordTypeName],
			'setupData Contact did not create as expected'
		);
		System.assertEquals(1, [SELECT COUNT() FROM Launchpad__Client_Skill__c], 'setupData Client Skill did not create as expected');
	}

	@isTest
	private static void searchByTitle() {
		LEXCandidateSearchController.CandidateFieldSet candidateFieldSet = defaultCandidateFieldSet();

		List<Contact> contacts = LEXCandidateSearchController.searchCandidates(
			'Salesforce',
			new Map<String, List<String>>{},
			candidateFieldSet.uniqueFields,
			'',
			'',
			String.join(FIELDS, ', ')
		);

		System.assert(contacts != null && contacts.size() > 0, 'searchCandidates returned no Contacts');

		//test get Candidate Data
		LEXCandidateSearchController.Candidate candidate = LEXCandidateSearchController.getCandidateData(contacts[0].Id, FIELDS, '');
	}

	@isTest
	private static void searchBySkill() {
		LEXCandidateSearchController.CandidateFieldSet candidateFieldSet = defaultCandidateFieldSet();

		List<Contact> contacts = LEXCandidateSearchController.searchCandidates(
			'Excel',
			new Map<String, List<String>>{},
			candidateFieldSet.uniqueFields,
			'',
			'',
			String.join(FIELDS, ', ')
		);

		System.assert(contacts != null && contacts.size() > 0, 'searchCandidates returned no Contacts');
	}

	@isTest
	private static void filterOptions() {
		LEXCandidateSearchController.CandidateFieldSet candidateFieldSet = defaultCandidateFieldSet();

		List<Contact> contacts = LEXCandidateSearchController.searchCandidates(
			'Excel',
			new Map<String, List<String>>{
				'Launchpad__Underemployed__c' => new List<String>{ 'True' },
				'Launchpad__Active__c' => new List<String>{ 'Yes' },
				'Launchpad__Industries__c' => new List<String>{ 'Healthcare' }
			},
			candidateFieldSet.uniqueFields,
			'',
			'',
			String.join(FIELDS, ', ')
		);

		System.assert(contacts != null && contacts.size() > 0, 'searchCandidates returned no Contacts');
	}
    
    @isTest
    private static void candidateSearchPrivilegedTest() {
        LEXCandidateSearchController.CandidateSearchPrivileged privilegedSearch = new LEXCandidateSearchController.CandidateSearchPrivileged();
        Launchpad__Match__c match;
        Exception exc;
        Test.startTest();
        try{
           match = privilegedSearch.getMatch(null); 
        } catch(Exception e) {
            exc = e;
        }
        
        Test.stopTest();
        
        System.assert(match == null, 'match is not null');
        System.assert(exc != null, 'Exception was not thrown');
    }

	@isTest
	private static void emailCandidate() {
		String contactRecordTypeName = LEXCandidateSearchController.CONTACT_RECORD_TYPE_API_NAMES[0];
		Contact c = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = :contactRecordTypeName LIMIT 1];

		Test.startTest();
		System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should\'ve been sent yet');

		LEXCandidateSearchController.emailCandidate(c.Id, 'Email body');

		System.assertEquals(1, Limits.getEmailInvocations(), 'Expected email did not send');
		Test.stopTest();
	}

	private static LEXCandidateSearchController.CandidateFieldSet defaultCandidateFieldSet() {
		return LEXCandidateSearchController.getSetupData('myCandidates', '', '', String.join(FIELDS, ', '));
	}

	/*@isTest
	private static void getSetupData() {
        LEXCandidateSearchController.getSetupData('myCandidates', '', '', '');
	}*/

	/*private static User prepareUser(String profId, String firstName, String lastName) {
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
	}*/
}