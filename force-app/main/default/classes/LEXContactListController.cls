/************************************************************************
 * @CLASS NAME     : LEXCONTACTLISTCONTROLLER                           *
 * @CLASS PURPOSE  : HANDLES THE LOGIC BEHIND THE LEXCONTACTLIST LWC    *
 * @DEVELOPER      : RADIANHUB DEVELOPER                                *
 * @DEVELOPED ON   : 04/07/2023                                         *
 ************************************************************************/
public with sharing class LEXContactListController {
	public class CompanyContactData {
		@AuraEnabled
		public List<Column> columns;

		@AuraEnabled
		public List<PageProp> pageProp;

		@AuraEnabled
		public List<Contact> myContacts;
	}

	public class Column {
		@AuraEnabled
		public String fieldName;

		@AuraEnabled
		public String fieldLabel;

		@AuraEnabled
		public Field field;

		@AuraEnabled
		public Integer index;

		public Column(String fieldName, String fieldLabel, Field field, Integer index) {
			this.fieldName = fieldName;
			this.fieldLabel = fieldLabel;
			this.field = field;
			this.index = index;
		}
	}

	public class PageProp {
		@AuraEnabled
		public String id;

		@AuraEnabled
		public String fieldSetName;

		public PageProp(String id, String fieldSetName) {
			this.id = id;
			this.fieldSetName = fieldSetName;
		}
	}

	public class Field {
		@AuraEnabled
		public String fieldLabel;

		@AuraEnabled
		public String type;

		@AuraEnabled
		public String formatter;

		@AuraEnabled
		public Boolean isReadOnly;

		@AuraEnabled
		public Boolean isDisabled;

		@AuraEnabled
		public Boolean isRequired;

		@AuraEnabled
		public Boolean isText;

		@AuraEnabled
		public Boolean isEmail;

		@AuraEnabled
		public Boolean isDate;

		@AuraEnabled
		public Boolean isDateTime;

		@AuraEnabled
		public Boolean isCheckbox;

		@AuraEnabled
		public Boolean isNumber;

		@AuraEnabled
		public Boolean isCurrency;

		@AuraEnabled
		public Boolean isReference;

		@AuraEnabled
		public Boolean isPercent;

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

		public Field(String fieldLabel, String type, Boolean isReadOnly, Boolean isRequired) {
			this.fieldLabel = fieldLabel;
			this.isReadOnly = isReadOnly;
			this.isDisabled = true;
			this.isRequired = isRequired;
			this.isText = type == 'STRING';
			this.isEmail = type == 'EMAIL';
			this.isDate = type == 'DATE';
			this.isDateTime = type == 'DATETIME';
			this.isCheckbox = type == 'BOOLEAN';
			this.isNumber = type == 'DOUBLE';
			this.isCurrency = type == 'CURRENCY';
			this.isPercent = type == 'PERCENT';
			this.isPhone = type == 'PHONE';
			this.isTextarea = type == 'TEXTAREA';
			this.isPicklist = type == 'PICKLIST';
			this.isMultiPicklist = type == 'MULTIPICKLIST';
			this.isReference = type == 'REFERENCE';
			this.isUrl = type == 'URL';
			if (type == 'DOUBLE') {
				type = 'number';
			} else if (type == 'PERCENT') {
				type = 'number';
				this.formatter = 'percent';
			} else if (type == 'CURRENCY') {
				type = 'number';
				this.formatter = 'currency';
			} else if (type == 'STRING') {
				type = 'text';
			} else if (type == 'PHONE') {
				type = 'tel';
			} else if (type == 'BOOLEAN') {
				type = 'checkbox';
			}
			this.type = type.toLowerCase();
		}
	}

	/***********************************************************************************************
	 * @DESCRIPTION : QUERY METADATA FOR FIELD SETS AND RETURN THE FIELDS WITH A LIST OF CONTACTS. *
	 * @AUTHOR RADIANHUB DEVELOPER | 04/07/2023                                                    *
	 * @RETURN COMPANYCONTACTDATA                                                                  *
	 ***********************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static CompanyContactData getContactTableData(String accountId) {
		try {
			Set<String> fieldSet = new Set<String>();
			Set<Id> pagePropertyIds = new Set<Id>();

			CompanyContactData data = new CompanyContactData();
			data.pageProp = new List<PageProp>();
			data.columns = new List<Column>();

			Map<String, LaborExchangeCommunity_FieldProperties__mdt> fieldsMap = new Map<String, LaborExchangeCommunity_FieldProperties__mdt>();

			List<LaborExchangeCommunity_PageProperties__mdt> ppList = LEXCommunityHelper.getLEXPageProperties('Company Profile > Contact List');
			for (LaborExchangeCommunity_PageProperties__mdt pp : ppList) {
				data.pageProp.add(new PageProp(pp.Id, pp.Field_Set__c));
				pagePropertyIds.add(pp.Id);
			}

			List<LaborExchangeCommunity_FieldProperties__mdt> fpList = LEXCommunityHelper.getLEXFieldProperties(pagePropertyIds);
			for (LaborExchangeCommunity_FieldProperties__mdt fp : fpList) {
				fieldsMap.put(fp.LaborExchangeCommunity_PageProperties__c + '-' + fp.Field_API_Name__c, fp);
			}

			Schema.DescribeSObjectResult dor = LEXCommunityHelper.getSObjSchema('Contact');

			Integer i = 0;
			for (PageProp p : data.pageProp) {
				Schema.FieldSet objectFieldSet = LEXCommunityHelper.getFieldSet('Contact', p.fieldSetName);

				if (objectFieldSet == null) {
					continue;
				}

				for (Schema.FieldSetMember fm : objectFieldSet.getFields()) {
					LaborExchangeCommunity_FieldProperties__mdt fp = fieldsMap.containsKey(p.id + '-' + fm.getFieldPath())
						? fieldsMap.get(p.id + '-' + fm.getFieldPath())
						: null;

					fieldSet.add(fm.getFieldPath());
					Field f = new Field(fm.getFieldPath(), String.valueOf(fm.getType()), fp != null && fp.Read_Only__c, fm.getRequired());

					if (String.valueOf(fm.getType()) == 'PICKLIST' || String.valueOf(fm.getType()) == 'MULTIPICKLIST') {
						Schema.DescribeFieldResult fieldResult = dor.fields.getMap().get(fm.getFieldPath()).getDescribe();
						f.values = new List<LEXCommunityHelper.Option>(LEXCommunityHelper.getPicklistValues(fieldResult));
					}

					Column c = new Column(fp != null && fp.Field_Label__c != null ? fp.Field_Label__c : fm.getLabel(), fm.getFieldPath(), f, i);
					i++;

					data.columns.add(c);
				}
			}

			List<String> fieldList = new List<String>(fieldSet);

			String query = 'SELECT Id';

			if (fieldList.size() > 0) {
				query += ', {0} FROM Contact WHERE AccountId = :accountId AND Launchpad__Active__c = \'Yes\' WITH SECURITY_ENFORCED';
				query = String.format(query, new List<String>{ String.join(fieldList, ',') });
			} else {
				query += ' FROM Contact WHERE AccountId = :accountId AND Launchpad__Active__c = \'Yes\' WITH SECURITY_ENFORCED';
			}

			List<Contact> contactList = Database.query(query);
			if (contactList.size() > 0) {
				data.myContacts = contactList;
			}
			return data;
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void archiveContact(String contactId) {
		try {
			List<Contact> con = [SELECT Id FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED];

			List<User> conUser = [SELECT Id, IsActive FROM User WHERE ContactId = :contactId WITH SECURITY_ENFORCED];

			if (conUser.size() > 0) {
				LEXContactListController.deactivateUser((String) conUser[0].Id);
			}
			if (con.size() > 0) {
				con[0].Launchpad__Active__c = 'No';
				SObjectHelper.updateObj(con);
			}
		} catch (Exception ex) {
			System.debug('Exception: ' + ex.getMessage() + ' @ ' + ex.getStackTraceString());
			throw new AuraHandledException(ex.getMessage());
		}
	}

	@future
	public static void deactivateUser(String userId) {
		User u = [SELECT Id, IsActive FROM User WHERE Id = :userId WITH SECURITY_ENFORCED];
		u.IsActive = false;
		SObjectHelper.updateObj(u);
	}

	public class CustomException extends Exception {
	}
}