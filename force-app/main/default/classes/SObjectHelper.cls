public with sharing class SObjectHelper {
	public static boolean canQueryObj(String sSObject) {
		if (string.isBlank(sSObject)) {
			throw new SObjectHelperException.InvalidParameterException(string.format('No SObject provided.', new List<string>{ 'sSObject' }));
		}

		if (isObjectAccessible(sSObject) && isObjectQueryable(sSObject)) {
			return true;
		} else {
			return false;
		}
	}

	public static void checkErrors(Database.UpsertResult[] results) {
		for (Integer index = 0, size = results.size(); index < size; index++) {
			if (results[index].isSuccess()) {
			} else {
				throw new SobjectHelperException.DMLException('An error occurred while upserting records: ' + results[index].getErrors());
			}
		}
	}

	public static void checkErrors(Database.SaveResult[] results) {
		for (Integer index = 0, size = results.size(); index < size; index++) {
			if (results[index].isSuccess()) {
				System.debug(results[index].getId() + ' was created');
			} else {
				throw new SobjectHelperException.DMLException('An error occurred while inserting records: ' + results[index].getErrors());
			}
		}
	}

	public static boolean isObjectAccessible(String sSObject) {
		Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(sSObject);
		return oDescribeSObjectResult.isAccessible();
	}

	public static boolean isObjectCreateable(String sSObject) {
		Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(sSObject);
		return oDescribeSObjectResult.isCreateable();
	}

	public static boolean isObjectQueryable(String sSObject) {
		Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(sSObject);
		return oDescribeSObjectResult.isQueryable();
	}

	public static boolean isObjectDeletable(String sSObject) {
		Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(sSObject);
		return oDescribeSObjectResult.isDeletable();
	}

	public static List<Sobject> objInsert(List<SObject> records) {
		if (records.size() == 0) {
			return records;
		}

		String objName = records[0].getSObjectType().getDescribe().getName();
		if (objName != null) {
			boolean isCreatable = isObjectCreateable(objName);
			if (!isCreatable) {
				throw new SObjectHelperException.InsertPermissionException(objName + ' is not createable.');
			}
		}

		List<Sobject> cleansedRecords = stripInaccessible(records, 'Insert');
		Database.SaveResult[] results = database.insert(cleansedRecords, false);
		checkErrors(results);

		return cleansedRecords;
	}

	public static List<Sobject> objUpdate(List<SObject> records) {
		List<Sobject> cleansedRecords = stripInaccessible(records, 'Update');
		Database.SaveResult[] results = database.update(cleansedRecords, false);
		checkErrors(results);

		return cleansedRecords;
	}

	public static List<Sobject> objUpsert(List<SObject> records) {
		List<Sobject> cleansedRecords = stripInaccessible(records, 'Upsert');
		Database.UpsertResult[] results = database.upsert(cleansedRecords, false);
		checkErrors(results);

		return cleansedRecords;
	}

	public static Sobject objInsert(SObject records) {
		String objName = records.getSObjectType().getDescribe().getName();
		if (objName != null) {
			boolean isCreatable = isObjectCreateable(objName);
			if (!isCreatable) {
				throw new SObjectHelperException.InsertPermissionException(objName + ' is not createable.');
			}
		}

		Sobject cleansedRecords = stripInaccessible(records, 'Insert');
		Database.SaveResult results = database.insert(cleansedRecords, false);
		checkErrors(new List<Database.SaveResult>{ results });

		return cleansedRecords;
	}

	public static Sobject objUpdate(SObject records) {
		Sobject cleansedRecords = stripInaccessible(records, 'Update');
		Database.SaveResult results = database.update(cleansedRecords, false);
		checkErrors(new List<Database.SaveResult>{ results });

		return cleansedRecords;
	}

	public static Sobject objUpsert(SObject records) {
		Sobject cleansedRecords = stripInaccessible(records, 'Upsert');
		Database.UpsertResult results = database.upsert(cleansedRecords, false);
		checkErrors(new List<Database.UpsertResult>{ results });

		return cleansedRecords;
	}

	public static SObject stripInaccessible(SObject record, String CRUD) {
		List<SObject> records = new List<SObject>();
		records.add(record);
		return stripInaccessible(records, CRUD)[0];
	}

	public static List<SObject> stripInaccessible(List<SObject> records, String CRUD) {
		SObjectAccessDecision decision;
		if (CRUD == 'Insert') {
			decision = Security.stripInaccessible(AccessType.CREATABLE, records);
		}

		if (CRUD == 'Update') {
			decision = Security.stripInaccessible(AccessType.UPDATABLE, records);
		}

		if (CRUD == 'Upsert') {
			decision = Security.stripInaccessible(AccessType.UPSERTABLE, records);
		}

		if (CRUD == 'Query') {
			decision = Security.stripInaccessible(AccessType.READABLE, records);
		}

		return decision.getRecords();
	}

	public static boolean isInsertable(SObject rec, String sSobject) {
		Schema.DescribeSObjectResult r1 = getDescribeSObjectResult(sSObject);
		Map<String, Schema.SObjectField> mapFieldList = r1.fields.getMap();

		String namespace = getNameSpace();

		for (Schema.SObjectField field : mapFieldList.values()) {
			Schema.DescribeFieldResult fieldResult = field.getDescribe();
			if (rec.get(fieldResult.getName()) != null || rec.get(fieldResult.getName().removeStart(namespace)) != null) {
				if (!fieldResult.isAccessible()) {
					return false;
				}
			}
		}

		return true;
	}

	public static Schema.DescribeSObjectResult getDescribeSObjectResult(String sSObject) {
		if (string.isBlank(sSObject)) {
			throw new SObjectHelperException.InvalidParameterException(string.format('No SObject provided.', new List<string>{ 'sSObject' }));
		}

		Schema.SObjectType oObjectToken = Schema.getGlobalDescribe().get(sSObject);
		if (oObjectToken == null) {
			oObjectToken = Schema.getGlobalDescribe().get(getNameSpace() + sSObject);
		}
		Schema.DescribeSObjectResult oDescribeSObjectResult = oObjectToken.getDescribe();

		return oDescribeSObjectResult;
	}
	/**
	 * @description Returns DescribeSObjectResult for the sObject
	 * @param SObject - sObject to retrieve DescribeSObjectResult for
	 * @return Schema.DescribeSObjectResult
	 */
	private static Schema.DescribeSObjectResult getDescribeSObjectResult(SObject oSObject) {
		Schema.SObjectType oObjectToken = oSObject.getSObjectType();
		Schema.DescribeSObjectResult oDescribeSObjectResult = oObjectToken.getDescribe();

		return oDescribeSObjectResult;
	}

	public static String getNameSpace() {
		//String sNameSpace = (SobjectHelper.canQueryObj('Organization')) ? [SELECT NamespacePrefix FROM Organization].NamespacePrefix : '';
		// return sNameSpace + '__';
		return 'LaunchpadCo__';
	}
	/**
	 * @description Check permission of running user before inserting object
	 * @param SObjects - sObject to be inserted
	 * @return Database.SaveResult[]
	 */
	public static Database.SaveResult[] insertObj(SObject oSObject) {
		if (oSObject == null)
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' })
			);

		Database.SaveResult[] lSaveResult;

		try {
			lSaveResult = insertObj(new List<SObject>{ oSObject });
		} catch (Exception oException) {
			throw oException;
		}

		return lSaveResult;
	}

	/**
	 * @description Check permission of running user before inserting objects
	 * @param SObjects - List of sObjects to be inserted
	 * @return Database.SaveResult[]
	 */
	public static Database.SaveResult[] insertObj(List<SObject> oSObjects) {
		if (oSObjects == null || oSObjects.isEmpty())
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'oSObjects' })
			);

		Database.SaveResult[] lSaveResult;

		try {
			for (SObject oSObject : oSObjects) {
				Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(oSObject);

				if (!oDescribeSObjectResult.isCreateable())
					throw new SObjectHelperException.InsertPermissionException(
						SObjectHelperException.INSERT_PERMISSION_EXCEPTION_MSG +
							' ' +
							oDescribeSObjectResult.getName() +
							' ' +
							SObjectHelperException.OBJECT_STR
					);
			}

			lSaveResult = Database.insert(oSObjects, true);
		} catch (Exception oException) {
			throw oException;
		}
		return lSaveResult;
	}
	/**
	 * @description Check permission of running user before updating object
	 * @param SObject - sObject to be updated
	 * @return Database.SaveResult[]
	 */
	public static Database.SaveResult[] updateObj(SObject oSObject) {
		if (oSObject == null)
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' })
			);

		Database.SaveResult[] lSaveResult;

		try {
			lSaveResult = updateObj(new List<SObject>{ oSObject });
		} catch (Exception oException) {
			throw oException;
		}

		return lSaveResult;
	}

	/**
	 * @description Check permission of running user before updating objects
	 * @param SObjects - sObjects to be updated
	 * @return Database.SaveResult[]
	 */
	public static Database.SaveResult[] updateObj(List<SObject> oSObjects) {
		if (oSObjects == null || oSObjects.isEmpty())
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'oSObjects' })
			);

		Database.SaveResult[] lSaveResult;

		try {
			for (SObject oSObject : oSObjects) {
				Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(oSObject);

				if (!oDescribeSObjectResult.isUpdateable())
					throw new SObjectHelperException.UpdatePermissionException(
						SObjectHelperException.UPDATE_PERMISSION_EXCEPTION_MSG +
							' ' +
							oDescribeSObjectResult.getName() +
							' ' +
							SObjectHelperException.OBJECT_STR
					);
			}

			lSaveResult = Database.update(oSObjects, true);
		} catch (Exception oException) {
			throw oException;
		}

		return lSaveResult;
	}
	/**
	 * @description Check permission of running user before deleting object
	 * @param SObject - sObject to be deleted
	 * @return Database.DeleteResult[]
	 */
	public static Database.DeleteResult[] deleteObj(SObject oSObject) {
		if (oSObject == null)
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' })
			);

		Database.DeleteResult[] lDeleteResult;

		try {
			lDeleteResult = deleteObj(new List<SObject>{ oSObject });
		} catch (Exception oException) {
			throw oException;
		}

		return lDeleteResult;
	}

	/**
	 * @description Check permission of running user before deleting objects
	 * @param SObjects - Objects to be deleted
	 * @return Database.DeleteResult[]
	 */
	public static Database.DeleteResult[] deleteObj(List<SObject> oSObjects) {
		if (oSObjects == null || oSObjects.isEmpty())
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'oSObjects' })
			);

		Database.DeleteResult[] lDeleteResults;

		try {
			for (SObject oSObject : oSObjects) {
				Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(oSObject);

				if (!oDescribeSObjectResult.isDeletable())
					throw new SObjectHelperException.DeletePermissionException(
						SObjectHelperException.DELETE_PERMISSION_EXCEPTION_MSG +
							' ' +
							oDescribeSObjectResult.getName() +
							' ' +
							SObjectHelperException.OBJECT_STR
					);
			}

			lDeleteResults = Database.delete(oSObjects, true);
		} catch (Exception oException) {
			throw oException;
		}

		return lDeleteResults;
	}
	public static Database.UpsertResult[] upsertObj(Contact oSObject) {
		if (oSObject == null)
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' })
			);

		Database.UpsertResult[] lUpsertResult;
		try {
			lUpsertResult = upsertObj(new List<Contact>{ oSObject });
		} catch (Exception oException) {
			system.debug('***** ERROR WHILE UPSERTING: ' + oException.getMessage() + ': ' + oException.getStackTraceString());
			throw oException;
		}

		return lUpsertResult;
	}

	public static Database.UpsertResult[] upsertObj(List<SObject> oSObjects) {
		if (oSObjects == null)
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' })
			);
		Database.UpsertResult[] lUpsertResult;
		try {
			for (SObject oSObject : oSObjects) {
				Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(oSObject);
				if (!oDescribeSObjectResult.isUpdateable() && !oDescribeSObjectResult.isCreateable())
					throw new SObjectHelperException.UpsertPermissionException(
						SObjectHelperException.UPSERT_PERMISSION_EXCEPTION_MSG +
							' ' +
							oDescribeSObjectResult.getName() +
							' ' +
							SObjectHelperException.OBJECT_STR
					);
			}
			lUpsertResult = Database.upsert(oSObjects, true);
		} catch (Exception oException) {
			system.debug('***** Error in upsertObj LIST method: ' + oException.getMessage() + ': ' + oException.getStackTraceString());
			throw oException;
		}

		return lUpsertResult;
	}
	public static Database.UpsertResult[] upsertObj(Launchpad__Enrollment__c oSObject) {
		if (oSObject == null)
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' })
			);
		Database.UpsertResult[] lUpsertResult;
		try {
			lUpsertResult = upsertObj(new List<Launchpad__Enrollment__c>{ oSObject });
		} catch (Exception oException) {
			throw oException;
		}
		return lUpsertResult;
	}

	public static Database.UpsertResult[] upsertObj(List<Launchpad__Enrollment__c> oSObjects) {
		if (oSObjects == null)
			throw new SObjectHelperException.InvalidParameterException(
				string.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' })
			);
		Database.UpsertResult[] lUpsertResult;
		try {
			for (SObject oSObject : oSObjects) {
				Schema.DescribeSObjectResult oDescribeSObjectResult = getDescribeSObjectResult(oSObject);
				if (!oDescribeSObjectResult.isUpdateable() && !oDescribeSObjectResult.isCreateable())
					throw new SObjectHelperException.UpsertPermissionException(
						SObjectHelperException.UPSERT_PERMISSION_EXCEPTION_MSG +
							' ' +
							oDescribeSObjectResult.getName() +
							' ' +
							SObjectHelperException.OBJECT_STR
					);
			}
			lUpsertResult = Database.upsert(oSObjects, true);
		} catch (Exception oException) {
			throw oException;
		}
		return lUpsertResult;
	}
}