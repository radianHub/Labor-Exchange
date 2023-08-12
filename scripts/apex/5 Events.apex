List<Account> accounts = [SELECT Id, Name FROM Account];

Map<String, Account> accountMap = new Map<String, Account>();
for (Account account : accounts) {
	accountMap.put(account.Name, account);
}

List<Launchpad__Event__c> events = new List<Launchpad__Event__c>();

events.add(
	new Launchpad__Event__c(
		Name = 'Fireside Chat with IT professionals',
		Launchpad__Type__c = 'Recruiting Event',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.1,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Recruiting_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Excel Basics for Beginners',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.25,
		Launchpad__Event_Type__c = 'On Demand Video',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = 0.25,
		Launchpad__Video_Name__c = 'Microsoft Excel: Basics for Beginners',
		Launchpad__Video_URL__c = 'https://www.youtube.com/watch?v=2OH2G6B5v-s',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Job Fair (In Person)',
		Launchpad__Type__c = 'Job Fair',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.1,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Tacoma',
		Launchpad__Location_Street__c = '670 Fort Street',
		Launchpad__Location_Zip_Code__c = '98402',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Fair').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Pierce Worksource',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = 'test.com',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Job Fair (In Person) 2',
		Launchpad__Type__c = 'Job Fair',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.05,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Tacoma',
		Launchpad__Location_Street__c = '670 Fort Street',
		Launchpad__Location_Zip_Code__c = '98402',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Fair').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Test Community College',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'ACG Importance of Diversity and Inclusion ',
		Launchpad__Type__c = 'Recruiting Event',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.05,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Seattle',
		Launchpad__Location_Street__c = '974 Terra Street',
		Launchpad__Location_Zip_Code__c = '98161',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Recruiting_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'SMART Goal Writing Workshop',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = 100,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.1,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = 'test.com',
		Launchpad__Workshop_Topics__c = 'Employability Skills'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Networking on Purpose!',
		Launchpad__Type__c = 'Recruiting Event',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.1,
		Launchpad__Event_Type__c = 'Live Virtual ',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Recruiting_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = 'Employability Skills'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Im Too Busy! How to Manage Your Time',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.03,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = 'Job Search'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Riverview Medical Recruitment',
		Launchpad__Type__c = 'Recruiting Event',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.1,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Seattle',
		Launchpad__Location_Street__c = '1301 6th Ave',
		Launchpad__Location_Zip_Code__c = '98101',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Recruiting_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Hilton Hotel, TAKU-CHINOOK Room',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Managing Your Money',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = 50,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = 'Friday',
		Launchpad__Duration_Hours__c = 0.05,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Seattle',
		Launchpad__Location_Street__c = '123 Main Street',
		Launchpad__Location_Zip_Code__c = '98118',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Winward Suite',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = 'Financial Literacy'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Job Fair (Virtual)',
		Launchpad__Type__c = 'Job Fair',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.1,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Fair').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Certified Nursing Assistant',
		Launchpad__Type__c = 'Training Event',
		Launchpad__Account__c = accountMap.get('American Healthcare Services').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = 20,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = 'Monday;Thursday;Friday',
		Launchpad__Duration_Hours__c = 0.1,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Seattle',
		Launchpad__Location_Street__c = '6951 Martin Luther King Jr. Way South Ste 201.',
		Launchpad__Location_Zip_Code__c = '98118',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Classroom D',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Mathmatics (BS) ',
		Launchpad__Type__c = 'Training Event',
		Launchpad__Account__c = accountMap.get('Eastern Washington University').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = 100,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = 'Tuesday;Friday',
		Launchpad__Duration_Hours__c = 0.05,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Classroom 401',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Job Fair (In Person) 3',
		Launchpad__Type__c = 'Job Fair',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.08,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Spokane',
		Launchpad__Location_Street__c = '303 W North River Dr',
		Launchpad__Location_Zip_Code__c = '99201',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Fair').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Centennial Hotel',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Job Fair (Virtual) 2',
		Launchpad__Type__c = 'Job Fair',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.1,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Fair').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'The benefits of social media',
		Launchpad__Type__c = 'Recruiting Event',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.05,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Recruiting_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Class A CDL',
		Launchpad__Type__c = 'Training Event',
		Launchpad__Account__c = accountMap.get('Skyline CDL School').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = 10,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = 'Wednesday',
		Launchpad__Duration_Hours__c = 0.06,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Auburn',
		Launchpad__Location_Street__c = '1302 26th St NW',
		Launchpad__Location_Zip_Code__c = '98001',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Skyline School Campus',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Interview Tips to Get the Job',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.25,
		Launchpad__Event_Type__c = 'On Demand Video',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = 0.28,
		Launchpad__Video_Name__c = 'Interview Tips to Get the Job',
		Launchpad__Video_URL__c = 'https://www.youtube.com/watch?v=QkPRpz56aEg',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = 'Career Navigation'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'What’s Your Learning Preference?',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.05,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = 'Job Search'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Lets Get Digital: Tips for Online Learning',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.05,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = 'Interviewing'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'HVAC Service Technician Apprenticeship ',
		Launchpad__Type__c = 'Training Event',
		Launchpad__Account__c = accountMap.get('Construction Industry Training Council of Washington - HVAC').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = 10,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = 'Monday;Tuesday;Wednesday;Thursday;Friday',
		Launchpad__Duration_Hours__c = 0.06,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Bellevue',
		Launchpad__Location_Street__c = '1930 116th Ave',
		Launchpad__Location_Zip_Code__c = '98004',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Suite 201',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Assembly Mechanic',
		Launchpad__Type__c = 'Training Event',
		Launchpad__Account__c = accountMap.get('Dimensional Journeyship').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = 25,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = 'Monday;Tuesday;Wednesday;Thursday;Friday',
		Launchpad__Duration_Hours__c = 0.06,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Mount Vernon',
		Launchpad__Location_Street__c = '1220 Anderson Road',
		Launchpad__Location_Zip_Code__c = '98273',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Shop G',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Job Fair (Virtual) 3',
		Launchpad__Type__c = 'Job Fair',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.13,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Fair').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Test Venue',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'How to Write an Incredible Resume',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 0.25,
		Launchpad__Event_Type__c = 'On Demand Video',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = '',
		Launchpad__Video_Duration_Hours__c = 0.28,
		Launchpad__Video_Name__c = 'How to Write an Incredible Resume',
		Launchpad__Video_URL__c = 'https://www.youtube.com/watch?v=Q_jbVpzCvBU',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = 'Career Navigation'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Workshop (Live In Person)',
		Launchpad__Type__c = 'Workshop',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 3,
		Launchpad__Event_Type__c = 'Live In Person',
		Launchpad__Location_City__c = 'Spokane',
		Launchpad__Location_Street__c = '2509 Goodwin Avenue',
		Launchpad__Location_Zip_Code__c = '99201',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Workshop').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Test Venue',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = 'Interviewing'
	)
);
events.add(
	new Launchpad__Event__c(
		Name = 'Knowledge Transfer - Gender Diversity In STEAM Industry',
		Launchpad__Type__c = 'Recruiting Event',
		Launchpad__Account__c = null,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Capacity__c = null,
		Launchpad__Cohort_Required__c = 'No',
		Launchpad__Community_Featured_Event__c = true,
		Launchpad__Community_Priority_Event__c = true,
		Launchpad__Days_of_Week__c = '',
		Launchpad__Duration_Hours__c = 3,
		Launchpad__Event_Type__c = 'Live Virtual',
		Launchpad__Location_City__c = 'Online',
		Launchpad__Location_Street__c = '',
		Launchpad__Location_Zip_Code__c = '',
		RecordTypeId = Schema.Launchpad__Event__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Recruiting_Event').getRecordTypeId(),
		Launchpad__Status__c = 'Active',
		Launchpad__Venue__c = 'Test Venue',
		Launchpad__Video_Duration_Hours__c = null,
		Launchpad__Video_Name__c = '',
		Launchpad__Video_URL__c = '',
		Launchpad__Virtual_Event_URL__c = '',
		Launchpad__Workshop_Topics__c = ''
	)
);

insert events;
