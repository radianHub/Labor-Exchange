/************************************************************************
 * @CLASS NAME     : LEXCOMPANYPROFILECONTROLLER                        *
 * @CLASS PURPOSE  : HANDLES THE LOGIC BEHIND THE LEXCOMPANYPROFILE LWC *
 * @DEVELOPER      : RADIANHUB DEVELOPER                                *
 * @DEVELOPED ON   : 04/07/2023                                         *
 ************************************************************************/
public with sharing class LEXCompanyProfileController {
	public class CompanyProfileData {
		@AuraEnabled
		public List<Section> sections;

		@AuraEnabled
		public Account myAccount;
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
		public Boolean isTextArea;

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
			this.isTextArea = type == 'TEXTAREA';
			this.isPicklist = type == 'PICKLIST';
			this.isMultiPicklist = type == 'MULTIPICKLIST';
			this.isUrl = type == 'URL';
			this.type = type == 'DOUBLE' ? 'decimal' : type.toLowerCase();
		}
	}

	/*****************************************************************************************
	 * @DESCRIPTION : QUERY METADATA FOR FIELD SETS AND RETURN THE FIELDS WITH ACCOUNT DATA. *
	 * @AUTHOR RADIANHUB DEVELOPER | 04/07/2023                                              *
	 * @RETURN COMPANYPROFILEDATA                                                            *
	 *****************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static CompanyProfileData getSections() {
		try {
			if (!SObjectHelper.canQueryObj('User')) {
				throw SobjectHelperException.queryPermissionException('User');
			}
			List<User> currentUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :UserInfo.getUserId()
				WITH SECURITY_ENFORCED
			];
			if (!SObjectHelper.canQueryObj('Contact')) {
				throw SObjectHelperException.queryPermissionException('Contact');
			}
			String contactId;
			String accountId;
			if (currentUser.size() > 0) {
				contactId = currentUser[0].ContactId;
				List<Contact> userContact = [
					SELECT Id, AccountId
					FROM Contact
					WHERE Id = :contactId
					WITH SECURITY_ENFORCED
				];
				if (userContact.size() > 0) {
					accountId = userContact[0].AccountId;
				}
			}
			Set<String> fieldSet = new Set<String>();
			Set<Id> pageSectionIds = new Set<Id>();

			CompanyProfileData data = new CompanyProfileData();
			data.sections = new List<Section>();

			Map<String, LaborExchangeCommunity_FieldProperties__mdt> fieldsMap = new Map<String, LaborExchangeCommunity_FieldProperties__mdt>();

			List<LaborExchangeCommunity_PageProperties__mdt> ppList = LEXCommunityHelper.getLEXPageProperties('Company Profile');
			for (LaborExchangeCommunity_PageProperties__mdt pp : ppList) {
				data.sections.add(new Section(pp.Id, pp.Section_Header__c, pp.Sub_Header__c, pp.Field_Set__c, Integer.valueOf(pp.Section_Order__c)));
				pageSectionIds.add(pp.Id);
			}

			List<LaborExchangeCommunity_FieldProperties__mdt> fpList = LEXCommunityHelper.getLEXFieldProperties(pageSectionIds);
			for (LaborExchangeCommunity_FieldProperties__mdt fp : fpList) {
				fieldsMap.put(fp.LaborExchangeCommunity_PageProperties__c + '-' + fp.Field_API_Name__c, fp);
			}

			Schema.DescribeSObjectResult dor = LEXCommunityHelper.getSObjSchema('Account');

			for (Section s : data.sections) {
				for (Schema.FieldSetMember fm : dor.FieldSets.getMap().get(s.fieldSetName).getFields()) {
					LaborExchangeCommunity_FieldProperties__mdt fp = fieldsMap.containsKey(s.Id + '-' + fm.getFieldPath())
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
						Schema.DescribeFieldResult fieldResult = dor.fields.getMap().get(fm.getFieldPath()).getDescribe();
						f.values = new List<LEXCommunityHelper.Option>(LEXCommunityHelper.getPicklistValues(fieldResult));
					}

					s.fields.add(f);
				}
			}

			List<String> fieldList = new List<String>(fieldSet);

			String query = 'SELECT Id, OwnerId';

			if (fieldList.size() > 0) {
				query += ', {0} FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED';
				query = String.format(query, new List<String>{ String.join(fieldList, ',') });
			} else {
				query += ' FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED';
			}

			if (!SObjectHelper.canQueryObj('Account')) {
				throw SObjectHelperException.queryPermissionException('Account');
			}
			List<Account> accountList = Database.query(query);
			if (accountList.size() > 0) {
				data.myAccount = accountList[0];
			}
			return data;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/*********************************************
	 * @DESCRIPTION : UPDATE A GIVEN ACCOUNT.    *
	 * @AUTHOR RADIANHUB DEVELOPER | 04/07/2023  *
	 * @RETURN Boolean                           *
	 *********************************************/
	@AuraEnabled
	public static Boolean save(String accString) {
		try {
			Account acc = (Account) JSON.deserialize(accString, Account.class);
			SObjectHelper.updateObj(acc);
			return true;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}