List<Account> accounts = [SELECT Id, Name FROM Account];

Map<String, Account> accountMap = new Map<String, Account>();
for (Account account : accounts) {
	accountMap.put(account.Name, account);
}

List<Contact> contacts = [SELECT Id, FirstName, LastName, Name FROM Contact];

Map<String, Contact> contactMap = new Map<String, Contact>();
for (Contact contact : contacts) {
	contactMap.put(contact.LastName, contact);
}

List<Launchpad__Job__c> jobs = new List<Launchpad__Job__c>();

jobs.add(
	new Launchpad__Job__c(
		Name = 'Patient Access Representative',
		Launchpad__Account__c = accountMap.get('Riverview Medical Center').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'After 30 days',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Garrison').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Full Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 21,
		Launchpad__Hourly_Wage_Maximum__c = 23,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '0-2'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'Pediatrician',
		Launchpad__Account__c = accountMap.get('Riverview Medical Center').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'After 30 days',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Garrison').Id,
		Launchpad__Education_Level_Preferred__c = 'Master and above',
		Launchpad__Employment_Type__c = 'Full Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 65,
		Launchpad__Hourly_Wage_Maximum__c = 75,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '6-10'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'Diesel Mechanic',
		Launchpad__Account__c = accountMap.get('J & R Transport').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'After 30 days',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Robinson').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Part Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 65,
		Launchpad__Hourly_Wage_Maximum__c = 65,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '6-10'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'CDL-A Truck Driver',
		Launchpad__Account__c = accountMap.get('J & R Transport').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'After 90 days',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Robinson').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Part Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 36.5,
		Launchpad__Hourly_Wage_Maximum__c = null,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '6-10'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'Senior HVAC technician',
		Launchpad__Account__c = accountMap.get('Pro Heating & Cooling').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'After 90 days',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Prosacco').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Full Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 29.5,
		Launchpad__Hourly_Wage_Maximum__c = 31,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '6-10'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'HVAC Sales Representative',
		Launchpad__Account__c = accountMap.get('Pro Heating & Cooling').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'After 90 days',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Prosacco').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Part Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 17.5,
		Launchpad__Hourly_Wage_Maximum__c = 18,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '3-5'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'Software Developer',
		Launchpad__Account__c = accountMap.get('Centerline Systems').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'Immediately',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Casares').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Part Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 41.75,
		Launchpad__Hourly_Wage_Maximum__c = 43.5,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '3-5'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'DevOps Engineer',
		Launchpad__Account__c = accountMap.get('Centerline Systems').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'Immediately',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Casares').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Part Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 99,
		Launchpad__Hourly_Wage_Maximum__c = 99,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '3-5'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'Service Porter',
		Launchpad__Account__c = accountMap.get('Elite Auto').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'Immediately',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Okuneva').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Part Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 17,
		Launchpad__Hourly_Wage_Maximum__c = null,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '3-5'
	)
);
jobs.add(
	new Launchpad__Job__c(
		Name = 'Automotive Sales Consultant',
		Launchpad__Account__c = accountMap.get('Elite Auto').Id,
		Launchpad__Available_in_Community__c = true,
		Launchpad__Benefits_Offered__c = 'Health;Dental;Vision;Paid Holidays;Sick Days;Personal Days',
		Launchpad__Benefits_Timeframe__c = 'Immediately',
		Launchpad__Community_Featured_Job__c = true,
		Launchpad__Community_Priority_Job__c = true,
		Launchpad__Contact__c = contactMap.get('Okuneva').Id,
		Launchpad__Education_Level_Preferred__c = 'HS Diploma/GED',
		Launchpad__Employment_Type__c = 'Full Time Permanent',
		Launchpad__Hourly_Wage_Minimum__c = 35,
		Launchpad__Hourly_Wage_Maximum__c = 40,
		Launchpad__Job_Category__c = 'Standard Job',
		Launchpad__Openings__c = 10,
		Launchpad__Source__c = 'Direct Employer Contact',
		Launchpad__Stage__c = 'Identified',
		Launchpad__Type_of_Work__c = 'Public-Facing Position',
		Launchpad__Years_Experience__c = '3-5'
	)
);

insert jobs;
