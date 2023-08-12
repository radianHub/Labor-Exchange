List<Account> accounts = [SELECT Id, Name FROM Account];

Map<String, Account> accountMap = new Map<String, Account>();
for (Account account : accounts) {
	accountMap.put(account.Name, account);
}

List<Contact> contacts = new List<Contact>();

contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Mabel',
		LastName = 'Garcia',
		Email = 'mabel.Garcia@testemail.com',
		MailingStreet = '225 Logan Ave S',
		MailingCity = 'Los Angeles',
		MailingState = 'CA',
		MailingPostalCode = '90024',
		MailingCountry = 'United States',
		Phone = '(425) 214-9087',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Alina',
		LastName = 'Kertzmann',
		Email = 'Alina.Kertzmann@testemail.com',
		MailingStreet = '325 152nd St E',
		MailingCity = 'Pasadena',
		MailingState = 'CA',
		MailingPostalCode = '91110',
		MailingCountry = 'United States',
		Phone = '(253) 272-2336',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Lenny',
		LastName = 'Hagenes',
		Email = 'Lenny.Hagenes@testemail.com',
		MailingStreet = '2516 E Sprague Ave',
		MailingCity = 'Burbank',
		MailingState = 'CA',
		MailingPostalCode = '91523',
		MailingCountry = 'United States',
		Phone = '(509) 535-5375',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Rebecca',
		LastName = 'Lebsack',
		Email = 'Rebecca.Lebsack@testemail.com',
		MailingStreet = '200 Lake Washington Blvd',
		MailingCity = 'Oakland',
		MailingState = 'CA',
		MailingPostalCode = '94607',
		MailingCountry = 'United States',
		Phone = '(206) 324-1111',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Camylle',
		LastName = 'Rutherford',
		Email = 'Camylle.Rutherford@testemail.com',
		MailingStreet = '212 E Central Ave',
		MailingCity = 'San Jose',
		MailingState = 'CA',
		MailingPostalCode = '95133',
		MailingCountry = 'United States',
		Phone = '(509) 326-6401',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Demarcus',
		LastName = 'Carr',
		Email = 'Demarcus.Carr@testemail.com',
		MailingStreet = '1920 S 3rd St',
		MailingCity = 'Pasadena',
		MailingState = 'CA',
		MailingPostalCode = '91110',
		MailingCountry = 'United States',
		Phone = '(360) 416-7563',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Aida',
		LastName = 'Kerluke',
		Email = 'Aida.Kerluke@testemail.com',
		MailingStreet = '5200 Paradise Way',
		MailingCity = 'Burbank',
		MailingState = 'CA',
		MailingPostalCode = '91523',
		MailingCountry = 'United States',
		Phone = '(509) 967-6200',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Ethan',
		LastName = 'Bailey',
		Email = 'Ethan.Bailey@testemail.com',
		MailingStreet = '2420 Western Ave',
		MailingCity = 'Oakland',
		MailingState = 'CA',
		MailingPostalCode = '94607',
		MailingCountry = 'United States',
		Phone = '(206) 728-4311',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Job_Seeker').getRecordTypeId(),
		AccountId = accountMap.get('Default ESD Job Seeker Account').Id,
		FirstName = 'Cristiano',
		LastName = 'Cristiano',
		Email = 'cristiano.rojas@testemail.com',
		MailingStreet = '2820 Rucker Ave',
		MailingCity = 'San Jose',
		MailingState = 'CA',
		MailingPostalCode = '95133',
		MailingCountry = 'United States',
		Phone = '(425) 258-3431',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId(),
		AccountId = accountMap.get('Riverview Medical Center').Id,
		FirstName = 'Michael',
		LastName = 'Garrison',
		Email = 'Michael.Garrison@Riverviewmed.org ',
		MailingStreet = '2762 4th Ave S',
		MailingCity = 'Los Angeles',
		MailingState = 'CA',
		MailingPostalCode = '90024',
		MailingCountry = 'United States',
		Phone = '(310) 623-8375',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId(),
		AccountId = accountMap.get('J & R Transport').Id,
		FirstName = 'Charles',
		LastName = 'Robinson',
		Email = 'crobinson@JandRTransport.com ',
		MailingStreet = '6320 N Cedar Rd',
		MailingCity = 'Pasadena',
		MailingState = 'CA',
		MailingPostalCode = '91110',
		MailingCountry = 'United States',
		Phone = '(626) 323-2033',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId(),
		AccountId = accountMap.get('Pro Heating & Cooling').Id,
		FirstName = 'Gina',
		LastName = 'Prosacco',
		Email = 'info@ProHeatingandCooling.com',
		MailingStreet = '215 SW Everett Mall Way',
		MailingCity = 'Burbank',
		MailingState = 'CA',
		MailingPostalCode = '91523',
		MailingCountry = 'United States',
		Phone = '(818) 347-4545',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId(),
		AccountId = accountMap.get('Centerline Systems').Id,
		FirstName = 'Justina Abreu',
		LastName = 'Casares',
		Email = 'JACesares@CenterlineSystems.net',
		MailingStreet = '533 Custer Way SE',
		MailingCity = 'Oakland',
		MailingState = 'CA',
		MailingPostalCode = '94607',
		MailingCountry = 'United States',
		Phone = '(559) 352-4240',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Employer').getRecordTypeId(),
		AccountId = accountMap.get('Elite Auto').Id,
		FirstName = 'Lin',
		LastName = 'Okuneva',
		Email = 'Lin.Okuneva@eliteauto.com',
		MailingStreet = '1123 Hoffman St',
		MailingCity = 'San Jose',
		MailingState = 'CA',
		MailingPostalCode = '95133',
		MailingCountry = 'United States',
		Phone = '(408) 225-8006',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Provider').getRecordTypeId(),
		AccountId = accountMap.get('American Healthcare Services').Id,
		FirstName = 'Emma',
		LastName = 'Johnson',
		Email = 'americanhcs@gmail.com',
		MailingStreet = '6951 Marting Luther Kiing Jr. Way South Suite 201',
		MailingCity = 'Los Angeles',
		MailingState = 'CA',
		MailingPostalCode = '90024',
		MailingCountry = 'United States',
		Phone = '(310) 838 4094',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Provider').getRecordTypeId(),
		AccountId = accountMap.get('Skyline CDL School').Id,
		FirstName = 'Gennadiy',
		LastName = 'Kovalev',
		Email = 'admin@skylinecdlschool.com',
		MailingStreet = '1302 26th St NW',
		MailingCity = 'Pasadena',
		MailingState = 'CA',
		MailingPostalCode = '91110',
		MailingCountry = 'United States',
		Phone = '(626) 623-8375',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Provider').getRecordTypeId(),
		AccountId = accountMap.get('Construction Industry Training Council of Washington - HVAC').Id,
		FirstName = 'Milo',
		LastName = 'Houston',
		Email = 'milo.houston@CITC.edu',
		MailingStreet = '1930 116th Avenue NE, Suite 201',
		MailingCity = 'Burbank',
		MailingState = 'CA',
		MailingPostalCode = '91523',
		MailingCountry = 'United States',
		Phone = '(818) 454-2482',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Provider').getRecordTypeId(),
		AccountId = accountMap.get('Eastern Washington University').Id,
		FirstName = 'Clint',
		LastName = 'Hanson',
		Email = 'chansen@ewuu.edu',
		MailingStreet = '202 Sutton Hall',
		MailingCity = 'Oakland',
		MailingState = 'CA',
		MailingPostalCode = '94607',
		MailingCountry = 'United States',
		Phone = '(559) 359-2397',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Training_Provider').getRecordTypeId(),
		AccountId = accountMap.get('Dimensional Journeyship').Id,
		FirstName = 'Ray',
		LastName = 'Moulder',
		Email = 'apprenticeship@dimensional.org',
		MailingStreet = '1220 Anderson Road',
		MailingCity = 'San Jose',
		MailingState = 'CA',
		MailingPostalCode = '95133',
		MailingCountry = 'United States',
		Phone = '(408) 588-5503',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Partners').getRecordTypeId(),
		AccountId = accountMap.get('Child Care Aware').Id,
		FirstName = 'LaToya',
		LastName = 'Davis',
		Email = 'familycenter@childcare.org',
		MailingStreet = '1001 Pacific Avenue, Suite 400',
		MailingCity = 'Los Angeles',
		MailingState = 'CA',
		MailingPostalCode = '90024',
		MailingCountry = 'United States',
		Phone = '(310) 383-1735',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Partners').getRecordTypeId(),
		AccountId = accountMap.get('Reach Center').Id,
		FirstName = 'Lou',
		LastName = 'Wilson',
		Email = 'info@reachtacoma.org',
		MailingStreet = '1314 South L St ',
		MailingCity = 'Pasadena',
		MailingState = 'CA',
		MailingPostalCode = '91110',
		MailingCountry = 'United States',
		Phone = '(626) 383-3951',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Partners').getRecordTypeId(),
		AccountId = accountMap.get('Together California').Id,
		FirstName = 'Joanne',
		LastName = 'Grissemer',
		Email = 'outreach@togethercalifornia.org ',
		MailingStreet = '766 John St',
		MailingCity = 'Burbank',
		MailingState = 'CA',
		MailingPostalCode = '91523',
		MailingCountry = 'United States',
		Phone = '(818) 660-0678',
		Launchpad__Gender__c = 'Female'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Partners').getRecordTypeId(),
		AccountId = accountMap.get('Wise').Id,
		FirstName = 'Liam',
		LastName = 'Williams',
		Email = 'support@gowise.org',
		MailingStreet = '203 N. Washington, Suite 200',
		MailingCity = 'Oakland',
		MailingState = 'CA',
		MailingPostalCode = '94607',
		MailingCountry = 'United States',
		Phone = '(559) 343-0881',
		Launchpad__Gender__c = 'Male'
	)
);
contacts.add(
	new Contact(
		RecordTypeId = Schema.Contact.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Partners').getRecordTypeId(),
		AccountId = accountMap.get('California ADA Center').Id,
		FirstName = 'Rebecca',
		LastName = 'Knapp',
		Email = 'caliadactr@ca.edu',
		MailingStreet = '6912 220th St. SW, Suite 105',
		MailingCity = 'San Jose',
		MailingState = 'CA',
		MailingPostalCode = '95133',
		MailingCountry = 'United States',
		Phone = '(310) 248-2480',
		Launchpad__Gender__c = 'Female'
	)
);

insert contacts;
