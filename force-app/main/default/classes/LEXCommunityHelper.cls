public inherited sharing class LEXCommunityHelper {
	/***************************************************
	 * @DESCRIPTION : GETS PICKLIST VALUES FOR A FIELD *
	 * @AUTHOR RADIANHUB DEVELOPER | 04/07/2023        *
	 * @RETURN List<Option>                            *
	 ***************************************************/
	public static List<Option> getPicklistValues(Schema.DescribeFieldResult fieldResult) {
		List<Option> values = new List<Option>();
		for (Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
			values.add(new Option(f.getLabel(), f.getValue()));
		}
		return values;
	}

	/*******************************************************************************
	 * @DESCRIPTION : GETS A LIST OF LEX PAGE PROPERTY METADATA VALUES FOR A FIELD *
	 * @AUTHOR RADIANHUB DEVELOPER | 04/07/2023                                    *
	 * @RETURN List<LaborExchangeCommunity_PageProperties__mdt>                    *
	 *******************************************************************************/
	public static List<LaborExchangeCommunity_PageProperties__mdt> getLEXPageProperties(String page) {
		List<LaborExchangeCommunity_PageProperties__mdt> pp = [
			SELECT Id, Field_Set__c, Section_Header__c, Sub_Header__c, Section_Order__c
			FROM LaborExchangeCommunity_PageProperties__mdt
			WHERE Active__c = 'Yes' AND Page__c = :page
			WITH SECURITY_ENFORCED
			ORDER BY Section_Order__c ASC
		];
		return pp;
	}

	/********************************************************************************
	 * @DESCRIPTION : GETS A LIST OF LEX FIELD PROPERTY METADATA VALUES FOR A FIELD *
	 * @AUTHOR RADIANHUB DEVELOPER | 04/07/2023                                     *
	 * @RETURN List<LaborExchangeCommunity_FieldProperties__mdt>                    *
	 ********************************************************************************/
	public static List<LaborExchangeCommunity_FieldProperties__mdt> getLEXFieldProperties(Set<Id> pagePropertyIds) {
		List<LaborExchangeCommunity_FieldProperties__mdt> fp = [
			SELECT
				LaborExchangeCommunity_PageProperties__c,
				Custom_Help_Text__c,
				Field_Api_Name__c,
				Field_Label__c,
				Field_Screen_Size__c,
				Override_Setup_Help_Text__c,
				Read_Only__c
			FROM LaborExchangeCommunity_FieldProperties__mdt
			WHERE Active__c = 'Yes' AND LaborExchangeCommunity_PageProperties__c IN :pagePropertyIds
			WITH SECURITY_ENFORCED
		];
		return fp;
	}

	public static List<FieldWrapper> getFieldsByObjectAndFieldSet(String objectName, String fieldSetName) {
		List<FieldWrapper> fieldWrapperList = new List<FieldWrapper>();

		Schema.FieldSet fieldSet = getFieldSet(objectName, fieldSetName);

		if (fieldSet == null) {
			return fieldWrapperList;
		}

		for (Schema.FieldSetMember fmo : fieldSet.getFields()) {
			fieldWrapperList.add(new FieldWrapper(fmo.getFieldPath(), fmo.getLabel(), String.valueOf(fmo.getType()), fmo.getRequired()));
		}

		return fieldWrapperList;
	}

	public static Schema.FieldSet getFieldSet(String objectName, String fieldSetName) {
		//Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
		//Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(ObjectName);
		Schema.DescribeSObjectResult describeSObjectResultObj = SObjectHelper.getDescribeSObjectResult(objectName);
		//sObjectTypeObj.getDescribe();

		return describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
	}

	public static List<Option> fetchPicklistValues(Schema.DescribeFieldResult fieldResult) {
		List<Option> values = new List<Option>();
		for (Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
			values.add(new Option(f.getLabel(), f.getValue()));
		}
		return values;
	}

	public static Schema.DescribeSObjectResult getSObjSchema(String sObj) {
		Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(sObj);
		return sObjectTypeObj.getDescribe();
	}

	public class FieldWrapper {
		@AuraEnabled
		public String fieldApiName;
		@AuraEnabled
		public String fieldLabel;
		@AuraEnabled
		public String fieldType;
		@AuraEnabled
		public Boolean required;

		public FieldWrapper(String fieldApiName, String fieldLabel, String fieldType, Boolean required) {
			this.fieldApiName = fieldApiName;
			this.fieldLabel = fieldLabel;
			this.fieldType = fieldType;
			this.required = required;
		}
	}

	public class Option {
		@AuraEnabled
		public String label;

		@AuraEnabled
		public String value;

		public Option(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}
}