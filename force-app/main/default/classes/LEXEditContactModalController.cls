/*****************************************************************************
 * @CLASS NAME     : LEXEDITCONTACTMODALCONTROLLER                           *
 * @CLASS PURPOSE  : HANDLES THE LOGIC BEHIND THE LEXEDITCONTACTMODAL LWC    *
 * @DEVELOPER      : RADIANHUB DEVELOPER                                     *
 * @DEVELOPED ON   : 04/07/2023                                              *
 *****************************************************************************/
public without sharing class LEXEditContactModalController {
	public class MyContactData {
		@AuraEnabled
		public List<Section> sections;

		@AuraEnabled
		public Contact myContact;
	}

	public class Section {
		@AuraEnabled
		public String id;

		@AuraEnabled
		public String header;

		@AuraEnabled
		public String subHeader;

		@AuraEnabled
		public String fieldSetName;

		@AuraEnabled
		public List<Field> fields;

		public Section(String id, String header, String subHeader, String fieldSetName, Integer sortOrder) {
			this.id = id;
			this.header = header;
			this.subHeader = subHeader;
			this.fieldSetName = fieldSetName;
			this.fields = new List<Field>();
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
		public Boolean isDisabled;

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
			this.isDisabled = true;
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

	/*****************************************************************************************
	 * @DESCRIPTION : QUERY METADATA FOR FIELD SETS AND RETURN THE FIELDS WITH CONTACT DATA. *
	 * @AUTHOR RADIANHUB DEVELOPER | 04/07/2023                                              *
	 * @RETURN MYCONTACTDATA                                                                 *
	 *****************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static MyContactData fetchContactData(String contactId) {
		try {
			MyContactData data = new MyContactData();
			data.sections = new List<Section>();

			Set<Id> pageSectionIds = new Set<Id>();
			Set<String> fieldSet = new Set<String>();
			Map<String, LaborExchangeCommunity_FieldProperties__mdt> fieldsMap = new Map<String, LaborExchangeCommunity_FieldProperties__mdt>();

			List<LaborExchangeCommunity_PageProperties__mdt> ppList = LEXCommunityHelper.getLEXPageProperties('Company Profile > Edit/New Contact Popup');
			for (LaborExchangeCommunity_PageProperties__mdt pp : ppList) {
				data.sections.add(new Section(pp.Id, pp.Section_Header__c, pp.Sub_Header__c, pp.Field_Set__c, Integer.valueOf(pp.Section_Order__c)));
				pageSectionIds.add(pp.Id);
			}

			List<LaborExchangeCommunity_FieldProperties__mdt> fpList = LEXCommunityHelper.getLEXFieldProperties(pageSectionIds);
			for (LaborExchangeCommunity_FieldProperties__mdt fp : fpList) {
				fieldsMap.put(fp.LaborExchangeCommunity_PageProperties__c + '-' + fp.Field_API_Name__c, fp);
			}

			Schema.DescribeSObjectResult dor = LEXCommunityHelper.getSObjSchema('Contact');

			for (Section s : data.sections) {
        Schema.FieldSet objectFieldSet = LEXCommunityHelper.getFieldSet('Contact', s.fieldSetName);

				if (objectFieldSet == null) {
					continue;
				}

				for (Schema.FieldSetMember fm : objectFieldSet.getFields()) {					LaborExchangeCommunity_FieldProperties__mdt fp = fieldsMap.containsKey(s.Id + '-' + fm.getFieldPath())
						? fieldsMap.get(s.Id + '-' + fm.getFieldPath())
						: null;

					fieldSet.add(fm.getFieldPath());
					Field f = new Field(
						fm.getFieldPath(),
						fp != null && fp.Field_Label__c != null ? fp.Field_Label__c : fm.getLabel(),
						fp != null && fp.Override_Setup_Help_Text__c ? fp.Custom_Help_Text__c : null,
						fp != null && fp.Field_Screen_Size__c != null ? fp.Field_Screen_Size__c : '6',
						String.valueOf(fm.getType()),
						fp != null && fp.Read_Only__c,
						fm.getRequired()
					);

					if (String.valueOf(fm.getType()) == 'PICKLIST' || String.valueOf(fm.getType()) == 'MULTIPICKLIST') {
						Schema.DescribeFieldResult fr = dor.fields.getMap().get(fm.getFieldPath()).getDescribe();
						f.values = new List<LEXCommunityHelper.Option>(LEXCommunityHelper.getPicklistValues(fr));
					}

					s.fields.add(f);
				}
			}

			List<String> fieldList = new List<String>(fieldSet);

			String query = 'SELECT Id';

			if (fieldList.size() > 0) {
				query += ', {0} FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED';
				query = String.format(query, new List<String>{ String.join(fieldList, ',') });
			} else {
				query += ' FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED';
			}

			List<Contact> contactList = Database.query(query);
			if (contactList.size() > 0) {
				data.myContact = contactList[0];
			}
			return data;
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	/*********************************************
	 * @DESCRIPTION : UPDATE A GIVEN CONTACT     *
	 * @AUTHOR RADIANHUB DEVELOPER | 04/07/2023  *
	 * @RETURN Boolean                           *
	 *********************************************/
	@AuraEnabled
	public static Boolean upsertContact(String conString) {
		try {
			Contact con = (Contact) JSON.deserialize(conString, Contact.class);
			// ! User needs system context to Assign a New Contact Owner.
			Database.UpsertResult[] urList = Database.upsert(new List<Contact>{ con });
			for (Database.UpsertResult ur : urList) {
				if (ur.isSuccess()) {
					return true;
				} else {
					for (Database.Error err : ur.getErrors()) {
						throw new CustomException(err.getStatusCode() + ': ' + err.getMessage());
					}
				}
			}
			return true;
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class CustomException extends Exception {
	}
}