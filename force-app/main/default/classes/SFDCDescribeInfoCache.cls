public class SFDCDescribeInfoCache {
	private static final SFDCDescribeInfoCache INSTANCE = new SFDCDescribeInfoCache();

	final Map<String, Map<String, Schema.SObjectField>> FIELD_CACHE { get; private set; }

	public static SFDCDescribeInfoCache getInstance() {
		return INSTANCE;
	}

	private SFDCDescribeInfoCache() {
		FIELD_CACHE = new Map<String, Map<String, Schema.SObjectField>>();
	}

	/**
	 * @description Returns a field map for a given sobject type.
	 * @param Schema.SObjectType - sobject type for ex. Contact.getSObjectType()
	 * @returns FieldMap [Key:FieldName,Value:Schema.SObjectField]
	 */
	public Map<String, Schema.SObjectField> fieldMapFor(Schema.SObjectType objectType) {
		Map<String, Schema.SObjectField> fieldMap = null;

		Schema.DescribeSObjectResult d = objectType.getDescribe();

		String sobjName = d.getName();

		if (FIELD_CACHE.containsKey(sobjName)) {
			fieldMap = FIELD_CACHE.get(sobjName);
		} else {
			fieldMap = d.fields.getMap();

			FIELD_CACHE.put(sobjName, fieldMap);
		}

		return fieldMap;
	}

	/*
	 * @description Return a String Set of Fields that are viewable by this user
	 * @param Map<String,Schema.SObjectField>
	 * @returns Set<String>
	 */
	public Set<String> getViewableFieldsNames(Map<String, Schema.SObjectField> fieldsMap) {
		Set<String> fields = new Set<String>{};

		for (String key : fieldsMap.keySet()) {
			Schema.DescribeFieldResult fieldRes = fieldsMap.get(key).getDescribe();

			if (fieldRes.isAccessible()) {
				fields.add(fieldRes.getName().toLowerCase());
			}
		}

		return fields;
	}

	/*
	 * @description Return a list of sobject fields that are viewable by this user
	 * @param SObjectType
	 * @returns Set<String>
	 */
	public Set<String> getViewableFieldsNames(SObjectType someType) {
		Map<String, Schema.SObjectField> fieldsMap = fieldMapFor(someType);

		return getViewableFieldsNames(fieldsMap);
	}
}