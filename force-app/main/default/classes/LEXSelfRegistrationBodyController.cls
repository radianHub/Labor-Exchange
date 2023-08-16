public without sharing class LEXSelfRegistrationBodyController {
	@AuraEnabled(cacheable=true)
	public static list<String> getAttestationList() {
		List<String> attestationList = new List<String>();

		for (LEXRegistration_AttestationSetup__mdt attestation : [
			SELECT Id, Attestation_Text__c, Paragraph_Order__c
			FROM LEXRegistration_AttestationSetup__mdt
			WHERE Active__c = 'Yes'
			WITH SECURITY_ENFORCED
			ORDER BY Paragraph_Order__c ASC
		]) {
			attestationList.add(attestation.Attestation_Text__c);
		}

		return attestationList;
	}

	@AuraEnabled(cacheable=true)
	public static String getStaticResource(String staticResource) {
		List<StaticResource> sr = [SELECT Id, NamespacePrefix, SystemModstamp FROM StaticResource WHERE Name = :staticResource WITH SECURITY_ENFORCED LIMIT 1];
		if (!sr.isEmpty()) {
			String prefix = sr[0].NamespacePrefix;
			prefix = String.isEmpty(prefix) ? '' : prefix + '__';

			return '/resource/' + sr[0].SystemModstamp.getTime() + '/' + prefix + staticResource;
		} else {
			return null;
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<Section> getSections(String birthdayMessage) {
		try {
			Schema.SObjectType accObjDescribe = Schema.getGlobalDescribe().get('Account');
			Schema.DescribeSObjectResult accountObjDescribeResult = accObjDescribe.getDescribe();
			Map<String, Schema.SObjectField> accountFields = accountObjDescribeResult.fields.getMap();

			Schema.SObjectType contactObjDescribe = Schema.getGlobalDescribe().get('Contact');
			Schema.DescribeSObjectResult contactObjDescribeResult = contactObjDescribe.getDescribe();
			Map<String, Schema.SObjectField> contactFields = contactObjDescribeResult.fields.getMap();

			List<Section> sections = createInitialSections();

			Map<String, LEXRegistration_FieldProperties__mdt> fieldsMap = createFieldsMap();

			List<Section> updatedSections = updateSections(sections, accountObjDescribeResult, contactObjDescribeResult, fieldsMap, birthdayMessage);
			return updatedSections;
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static DupeCheck checkForDupeContactsUsers(String email) {
		DupeCheck contactUserDupeCheck = new DupeCheck();
		contactUserDupeCheck.dupeContactFound = false;
		contactUserDupeCheck.dupeActiveUserFound = false;
		contactUserDupeCheck.dupeInactiveUserFound = false;
		contactUserDupeCheck.dupeAccountFound = false;

		List<Contact> conList = [SELECT Id FROM Contact WHERE Email = :email WITH SECURITY_ENFORCED LIMIT 1];
		List<User> dupeCheckedUser;

		if (!conList.isEmpty()) {
			contactUserDupeCheck.dupeContactFound = true;
			dupeCheckedUser = [SELECT Id, IsActive FROM User WHERE ContactId = :conList[0].Id OR Username = :email WITH SECURITY_ENFORCED LIMIT 1];
		} else {
			dupeCheckedUser = [SELECT Id, IsActive FROM User WHERE Username = :email WITH SECURITY_ENFORCED LIMIT 1];
		}

		if (!dupeCheckedUser.isEmpty() && dupeCheckedUser[0].IsActive) {
			contactUserDupeCheck.dupeActiveUserFound = true;
		} else {
			contactUserDupeCheck.dupeInactiveUserFound = true;
		}

		return contactUserDupeCheck;
	}
	@AuraEnabled(cacheable=true)
	public static DupeCheck checkForDupeAccounts(String accountName) {
		DupeCheck accountDupeCheck = new DupeCheck();
		accountDupeCheck.dupeContactFound = false;
		accountDupeCheck.dupeActiveUserFound = false;
		accountDupeCheck.dupeInactiveUserFound = false;
		accountDupeCheck.dupeAccountFound = false;

		List<Account> dupeAccountList = [SELECT Id FROM Account WHERE Name = :accountName WITH SECURITY_ENFORCED LIMIT 1];
		if (!dupeAccountList.isEmpty()) {
			accountDupeCheck.dupeAccountFound = true;
		}

		return accountDupeCheck;
	}

	@AuraEnabled
	public static String registerUser(
		String contactString,
		String accountString,
		String password,
		String contactRecordType,
		String accountRecordType,
		String profileId
	) {
		try {
			Savepoint sp = Database.setSavepoint();

			// ! This will not be able to be queried by a guest user, so this must be queried in system context
			List<UserRole> portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];

			if (portalRole.isEmpty()) {
				throw new PortalRoleException(
					'A role must be set up in the role heirarchy and the default Account Owner must be assigned to that role before self registration can be used.'
				);
			}

			// ! This will not be able to be queried by a guest user, so this must be queried in system context
			// Query for the System Administrator profile to query for a user to use as an owner
			Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

			// Query for a user that can be used as a portal user owner
			List<User> portalAccountOwner = [
				SELECT Id
				FROM User
				WHERE ProfileId = :systemAdminProfile.Id AND UserRoleId = :portalRole[0].Id
				WITH SECURITY_ENFORCED
			];

			if (portalAccountOwner.isEmpty()) {
				throw new PortalRoleException('A system administrator must be assigned to a role in the role heirarchy before self registration can be used.');
			}

			Account acc = (Account) JSON.deserialize(accountString, Account.class);
			acc.Created_via_Community_Self_Registration__c = true;
			acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(accountRecordType).getRecordTypeId();

			SObjectHelper.insertObj(acc);

			String userId;
			Contact con = (Contact) JSON.deserialize(contactString, Contact.class);

			if (con.email == null || con.email == '') {
				throw new RegistrationException('Email is required.');
			}

			con.Launchpad__Created_via_Community_Self_Registration__c = true;
			con.Launchpad__Attestation_Acknowledged__c = 'Yes';
			con.Launchpad__Attestation_Acknowledgement_Date__c = System.Today();
			con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(contactRecordType).getRecordTypeId();
			con.AccountId = acc.Id;
			con.Launchpad__Stage__c = 'Assessment';

			// ! This will not be insertable by a guest user within the package,
			// ! so we are running in system context
			insert con;

			User u = new User(
				Username = con.Email,
				Email = con.Email,
				FirstName = con.FirstName,
				LastName = con.LastName,
				TimeZoneSidKey = 'America/New_York',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US'
			);

			if (String.isNotEmpty(profileId)) {
				u.ProfileId = profileId;
			}

			String nickname = ((u.FirstName != null && u.FirstName.length() > 0) ? u.FirstName.substring(0, 1) : '') + u.LastName.substring(0, 1);
			nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
			u.CommunityNickname = nickname;

			if (!Test.isRunningTest()) {
				Site.validatePassword(u, password, password);
			}

			try {
				userId = Site.createExternalUser(u, String.valueOf(acc.Id), password);
			} catch (Site.ExternalUserCreateException e) {
				Database.rollback(sp);
				System.debug('ExternalUserCreate EXCEPTION:: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
				throw new AuraHandledException(e.getMessage());
			}
			if (userId != null) {
				return LEXCommunityLoginController.loginUser(u.username, password, null);
			}
		} catch (Exception e) {
			System.debug('GENERAL EXCEPTION: ' + e.getMessage() + '@' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	public class Section {
		@AuraEnabled
		public String header;

		@AuraEnabled
		public String subHeader;

		@AuraEnabled
		public String accountFieldSetName;

		@AuraEnabled
		public String contactFieldSetName;

		@AuraEnabled
		public Boolean showStep;

		@AuraEnabled
		public Boolean showDupeCheck;

		@AuraEnabled
		public List<Field> fields;

		@AuraEnabled
		public String bgCSS;

		@AuraEnabled
		public Boolean isAccountSection;

		public Section(String header, String subHeader, String accountFieldSetName, String contactFieldSetName, Integer sortOrder) {
			this.header = header;
			this.subHeader = subHeader;
			this.accountFieldSetName = accountFieldSetName;
			this.contactFieldSetName = contactFieldSetName;
			this.showStep = sortOrder == 0 || sortOrder == 1;
			this.showDupeCheck = sortOrder == 0;
			this.fields = new List<Field>();
			this.bgCSS = Math.mod(sortOrder, 2) == 0 ? 'evenBG' : 'oddBG';
			this.isAccountSection = accountFieldSetName != null ? true : false;
		}
	}

	public class Field {
		@AuraEnabled
		public String fieldName;

		@AuraEnabled
		public String fieldLabel;

		@AuraEnabled
		public String helpText;

		@AuraEnabled
		public String screenSize;

		@AuraEnabled
		public String type;

		@AuraEnabled
		public Boolean isReadOnly;

		@AuraEnabled
		public Boolean isRequired;

		@AuraEnabled
		public String min;

		@AuraEnabled
		public string max;

		@AuraEnabled
		public String minMsg;

		@AuraEnabled
		public string maxMsg;

		@AuraEnabled
		public Boolean isText;

		@AuraEnabled
		public Boolean isEmail;

		@AuraEnabled
		public Boolean isDate;

		@AuraEnabled
		public Boolean isCheckbox;

		@AuraEnabled
		public Boolean isNumber;

		@AuraEnabled
		public Boolean isPhone;

		@AuraEnabled
		public Boolean isTextarea;

		@AuraEnabled
		public Boolean isPicklist;

		@AuraEnabled
		public Boolean isMultiPicklist;

		@AuraEnabled
		public Boolean isUrl;

		@AuraEnabled
		public List<LEXCommunityHelper.Option> values;

		public Field(String fieldName, String fieldLabel, String helpText, String screenSize, String type, Boolean isReadOnly, Boolean isRequired) {
			this.fieldName = fieldName;
			this.fieldLabel = fieldLabel;
			this.helpText = helpText;
			this.screenSize = screenSize;
			this.isReadOnly = isReadOnly;
			this.isRequired = isRequired;
			this.isText = type == 'STRING';
			this.isEmail = type == 'EMAIL';
			this.isDate = type == 'DATE' || type == 'DATETIME';
			this.isCheckbox = type == 'BOOLEAN';
			this.isNumber = type == 'CURRENCY' || type == 'PERCENT' || type == 'DOUBLE';
			this.isPhone = type == 'PHONE';
			this.isTextarea = type == 'TEXTAREA';
			this.isPicklist = type == 'PICKLIST';
			this.isMultiPicklist = type == 'MULTIPICKLIST';
			this.isUrl = type == 'URL';
			this.type = type == 'DOUBLE' ? 'decimal' : type.toLowerCase();
		}
	}

	public class DupeCheck {
		@AuraEnabled
		public Boolean dupeContactFound;

		@AuraEnabled
		public Boolean dupeActiveUserFound;

		@AuraEnabled
		public Boolean dupeInactiveUserFound;

		@AuraEnabled
		public Boolean dupeAccountFound;
	}

	// HELPER METHODS

	// Helper method to create sections
	private static List<Section> createInitialSections() {
		// Initialize an empty list of Sections
		List<Section> sections = new List<Section>();

		// Query for the LexRegistration_PageProperties metadata records
		List<LEXRegistration_PageProperties__mdt> lexRegistrationPageProperties = [
			SELECT Account_Field_Set__c, Contact_Field_Set__c, Section_Header__c, Sub_Header__c, Section_Order__c
			FROM LEXRegistration_PageProperties__mdt
			WHERE Active__c = 'Yes'
			WITH SECURITY_ENFORCED
			ORDER BY Section_Order__c ASC
		];

		// Loop through the page properties, creating a section for each iteration
		for (LEXRegistration_PageProperties__mdt pageProperty : lexRegistrationPageProperties) {
			Section singleSection = new Section(
				pageProperty.Section_Header__c,
				pageProperty.Sub_Header__c,
				pageProperty.Account_Field_Set__c,
				pageProperty.Contact_Field_Set__c,
				Integer.valueOf(pageProperty.Section_Order__c)
			);
			sections.add(singleSection);
		}
		// Return the generated sections
		return sections;
	}
	private static Map<String, LEXRegistration_FieldProperties__mdt> createFieldsMap() {
		//Create dynamic query for lexRegistrationfieldProperties
		List<LEXRegistration_FieldProperties__mdt> lexRegistrationFieldProperties = [
			SELECT
				Custom_Help_Text__c,
				Field_API_Name__c,
				Field_Label__c,
				Field_Screen_Size__c,
				Override_Setup_Help_Text__c,
				Read_Only__c,
				LEXRegistration_PageProperty__r.Contact_Field_Set__c,
				LEXRegistration_PageProperty__r.Account_Field_Set__c
			FROM LEXRegistration_FieldProperties__mdt
			WHERE Active__c = 'Yes'
			WITH SECURITY_ENFORCED
		];

		// Initialize an empty map of String to LEXRegistration_FieldProperties__mdt custom metadata
		Map<String, LEXRegistration_FieldProperties__mdt> fieldsMap = new Map<String, LEXRegistration_FieldProperties__mdt>();
		// Loop through a queried list of Active LEXRegistration_FieldProperties__mdt
		for (LEXRegistration_FieldProperties__mdt fieldProperty : lexRegistrationFieldProperties) {
			// Populate the map
			if (fieldProperty.LEXRegistration_PageProperty__r.Account_Field_Set__c != null) {
				fieldsMap.put(fieldProperty.Field_API_Name__c + '' + fieldProperty.LEXRegistration_PageProperty__r.Account_Field_Set__c, fieldProperty);
			} else if (fieldProperty.LEXRegistration_PageProperty__r.Contact_Field_Set__c != null) {
				fieldsMap.put(fieldProperty.Field_API_Name__c + '' + fieldProperty.LEXRegistration_PageProperty__r.Contact_Field_Set__c, fieldProperty);
			}
		}
		return fieldsMap;
	}

	private static List<Section> updateSections(
		List<Section> sections,
		Schema.DescribeSObjectResult accountObjDescribeResult,
		Schema.DescribeSObjectResult contactObjDescribeResult,
		Map<String, LEXRegistration_FieldProperties__mdt> fieldsMap,
		String birthdayMessage
	) {
		Labor_Exchange_Community_Setup__c lexCommunitySetup = Labor_Exchange_Community_Setup__c.getOrgDefaults();
		Map<String, Schema.SObjectField> accountFields = accountObjDescribeResult.fields.getMap();
		Map<String, Schema.SObjectField> contactFields = contactObjDescribeResult.fields.getMap();

		Schema.DescribeSObjectResult genericObjDescribeResult;

		// Loop through sections
		for (Section section : sections) {
			// Instantiate a string variable to hold the field set's name
			String fieldSetName;
			Map<String, Schema.SObjectField> fields;
			// If the section references an account field set, set fieldSetName to the section's account field set name
			// and set the genericObjDescribeResult variable to the accountObjDescribe Result for reference in the loop below.
			// Finally, set the fields variable Map to the accountFields map initialized above.
			if (section.accountFieldSetName != null) {
				fieldSetName = section.accountFieldSetName;
				genericObjDescribeResult = accountObjDescribeResult;
				fields = accountFields;
				// If the section references a contact field set, set fieldSetName to the section's contact field set name
				// and set the genericObjDescribeResult variable to the contatObjDescribe Result for reference in the loop below.
				// Finally, set the fields variable Map to the contactFields map initialized above.
			} else if (section.contactFieldSetName != null) {
				fieldSetName = section.contactFieldSetName;
				genericObjDescribeResult = contactObjDescribeResult;
				fields = contactFields;
			}

			if (fieldSetName == null) {
				continue;
			}

			FieldSet fieldSet = genericObjDescribeResult.FieldSets.getMap().get(fieldSetName);

			if (fieldSet == null) {
				fieldSet = genericObjDescribeResult.FieldSets.getMap().get(SObjectHelper.getNameSpace() + fieldSetName);
			}

			if (fieldSet == null) {
				continue;
			}

			// Loop through fields in the field set
			for (Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
				String fieldPropertyName = fieldSetMember.getFieldPath() + '' + fieldSetName;
				LEXRegistration_FieldProperties__mdt fieldProperties = fieldsMap.containsKey(fieldPropertyName) ? fieldsMap.get(fieldPropertyName) : null;

				// Store field data in a Field wrapper
				Field field = new Field(
					fieldSetMember.getFieldPath(),
					fieldProperties != null && fieldProperties.Field_Label__c != null ? fieldProperties.Field_Label__c : fieldSetMember.getLabel(),
					fieldProperties != null && fieldProperties.Override_Setup_Help_Text__c ? fieldProperties.Custom_Help_Text__c : null,
					fieldProperties != null && fieldProperties.Field_Screen_Size__c != null ? fieldProperties.Field_Screen_Size__c : '6',
					String.valueOf(fieldSetMember.getType()),
					fieldProperties != null && fieldProperties.Read_Only__c && !section.showDupeCheck,
					fieldSetMember.getRequired()
				);

				if (String.valueOf(fieldSetMember.getType()) == 'PICKLIST' || String.valueOf(fieldSetMember.getType()) == 'MULTIPICKLIST') {
					Schema.DescribeFieldResult fieldResult = fields.get(fieldSetMember.getFieldPath()).getDescribe();
					field.values = new List<LEXCommunityHelper.Option>(LEXCommunityHelper.fetchPicklistValues(fieldResult));
				}
				section.fields.add(field);
			}
		}
		return sections;
	}
	public class PortalRoleException extends Exception {
	}
	public class RegistrationException extends Exception {
	}
}