public with sharing class LEXEventsController {
	@AuraEnabled(cacheable=true)
	public static EventsSetupData getSetupData(String viewType, String filterField, String priorityFilterField, String searchFilterFields) {
		try {
			Boolean isHomePage = viewType == 'Home';
			Schema.SObjectType objDescribe = Schema.getGlobalDescribe().get('Launchpad__Event__c');
			Schema.DescribeSObjectResult objDescribeResult = objDescribe.getDescribe();
			Map<String, Schema.SObjectField> eventFields = objDescribeResult.fields.getMap();
			EventsSetupData data = new EventsSetupData();
			Map<String, Map<String, String>> fieldsMap = new Map<String, Map<String, String>>();
			Map<String, Set<String>> eventTypeRecordTypeMap = new Map<String, Set<String>>();

			Set<String> uniqueFields = new Set<String>{ 'RecordType.Name' };

			Labor_Exchange_Community_Setup__c lexCommunitySetup = Labor_Exchange_Community_Setup__c.getOrgDefaults();

			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('LaborExchangeCommunity_PageProperties__mdt')) {
				throw new SObjectHelperException.queryPermissionException('LaborExchangeCommunity_PageProperties__mdt');
			}

			List<LaborExchangeCommunity_PageProperties__mdt> pageList = [
				SELECT Id, MasterLabel, Field_Set__c, Event_Fields_Above_Button__c, Page__c, Event_Type__c, Record_Type__c
				FROM LaborExchangeCommunity_PageProperties__mdt
				WHERE Active__c = 'Yes' AND Page__c IN ('Event Tile', 'Event Details') AND Object_API__c = 'Launchpad__Event__c'
				WITH SECURITY_ENFORCED
			];
			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('LaborExchangeCommunity_FieldProperties__mdt')) {
				throw new SObjectHelperException.queryPermissionException('LaborExchangeCommunity_FieldProperties__mdt');
			}
			for (LaborExchangeCommunity_FieldProperties__mdt ff : [
				SELECT Id, Field_API_Name__c, Field_Label__c, LaborExchangeCommunity_PageProperties__c
				FROM LaborExchangeCommunity_FieldProperties__mdt
				WHERE Active__c = 'Yes' AND LaborExchangeCommunity_PageProperties__c IN :pageList
				WITH SECURITY_ENFORCED
			]) {
				if (!fieldsMap.containsKey(ff.LaborExchangeCommunity_PageProperties__c)) {
					fieldsMap.put(ff.LaborExchangeCommunity_PageProperties__c, new Map<String, String>());
				}

				fieldsMap.get(ff.LaborExchangeCommunity_PageProperties__c).put(ff.Field_API_Name__c, ff.Field_Label__c);
			}

			for (LaborExchangeCommunity_PageProperties__mdt page : pageList) {
				if (!eventTypeRecordTypeMap.containsKey(page.Event_Type__c)) {
					eventTypeRecordTypeMap.put(page.Event_Type__c, new Set<String>());
				}

				eventTypeRecordTypeMap.get(page.Event_Type__c).add(page.Record_Type__c);

				List<LEXCommunityHelper.FieldWrapper> fields = LEXCommunityHelper.getFieldsByObjectAndFieldSet('Launchpad__Event__c', page.Field_Set__c);

				for (LEXCommunityHelper.FieldWrapper fw : fields) {
					uniqueFields.add(fw.fieldApiName);
				}

				if (fieldsMap.containsKey(page.Id) && !fieldsMap.get(page.Id).keySet().isEmpty()) {
					for (LEXCommunityHelper.FieldWrapper fw : fields) {
						if (fieldsMap.get(page.Id).containsKey(fw.fieldApiName)) {
							fw.fieldLabel = fieldsMap.get(page.Id).get(fw.fieldApiName);
						}
					}
				}

				String key = page.Record_Type__c + page.Event_Type__c;

				if (!data.fieldsConfigMap.containsKey(key)) {
					FieldsConfig config = new FieldsConfig();
					data.fieldsConfigMap.put(key, config);
				}

				if (page.Page__c == 'Event Tile') {
					data.fieldsConfigMap.get(key).tileFields = new List<LEXCommunityHelper.FieldWrapper>(fields);

					if (page.Event_Fields_Above_Button__c != null) {
						data.fieldsConfigMap.get(key).noOfFields = Integer.valueOf(page.Event_Fields_Above_Button__c);
					}
				} else if (page.Page__c == 'Event Details') {
					data.fieldsConfigMap.get(key).confirmationFields = new List<LEXCommunityHelper.FieldWrapper>(fields);
				}
			}

			if (!uniqueFields.isEmpty()) {
				data.events = getDefaultEvents(
					new List<String>(uniqueFields),
					isHomePage,
					eventTypeRecordTypeMap,
					viewType != 'myRegisteredWorkshops' ? filterField : null,
					priorityFilterField
				);
			}

			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('User')) {
				throw new SObjectHelperException.queryPermissionException('User');
			}

			User currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];

			Set<Id> registeredEventIds = new Set<Id>();

			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('Launchpad__Event_Attendee_Enrollment__c')) {
				throw new SObjectHelperException.queryPermissionException('Launchpad__Event_Attendee_Enrollment__c');
			}

			String companyId = currentUser.Contact.AccountId;
			String eaeQuery;
			switch on companyId {
				when null {
					eaeQuery =
						'SELECT Id, Launchpad__Event__c FROM Launchpad__Event_Attendee_Enrollment__c ' +
						'WHERE ( (Launchpad__Status__c IN (\'Registered\', \'Attended\')) OR (Launchpad__Cancelled_via_Community__c = FALSE AND Launchpad__Enrolled_via_Community__c = TRUE))' +
						(viewType == 'myRegisteredWorkshops' && filterField != null && filterField != '' ? ' AND ' + filterField + ' = TRUE ' : '') +
						' WITH SECURITY_ENFORCED';
				}
				when else {
					eaeQuery =
						'SELECT Id, Launchpad__Event__c FROM Launchpad__Event_Attendee_Enrollment__c ' +
						'WHERE ( (Launchpad__Status__c IN (\'Registered\', \'Attended\')) OR (Launchpad__Cancelled_via_Community__c = FALSE AND Launchpad__Enrolled_via_Community__c = TRUE)) AND Company__c = \'' +
						companyId +
						'\'' +
						(viewType == 'myRegisteredWorkshops' && filterField != null && filterField != '' ? ' AND ' + filterField + ' = TRUE ' : '') +
						' WITH SECURITY_ENFORCED';
				}
			}

			for (Launchpad__Event_Attendee_Enrollment__c eae : Database.query(eaeQuery)) {
				registeredEventIds.add(eae.Launchpad__Event__c);
			}

			data.registeredEventIds = new List<Id>(registeredEventIds);
			data.noOfTilesPerPage = Integer.valueOf(lexCommunitySetup.of_Tiles_Per_Page__c);
			data.uniqueFields = new List<String>(uniqueFields);

			if (!isHomePage && searchFilterFields != null) {
				data.filters = new List<FilterList>();

				for (String fieldAPIName : searchFilterFields.split(',')) {
					if (eventFields.containsKey(fieldAPIName.trim())) {
						Schema.DescribeFieldResult fieldResult = eventFields.get(fieldAPIName.trim()).getDescribe();

						if (fieldResult.getType() == Schema.DisplayType.PICKLIST || fieldResult.getType() == Schema.DisplayType.MULTIPICKLIST) {
							FilterList filter = new FilterList();
							filter.title = fieldResult.getLabel();
							filter.fieldName = fieldResult.getName();
							filter.values = LEXCommunityHelper.fetchPicklistValues(fieldResult);

							data.filters.add(filter);
						} else if (fieldResult.getType() == Schema.DisplayType.BOOLEAN) {
							FilterList filter = new FilterList();
							filter.title = fieldResult.getLabel();
							filter.fieldName = fieldResult.getName();
							filter.values = new List<LEXCommunityHelper.Option>{
								new LEXCommunityHelper.Option(Label.LEXCommunity_Picklist_Yes_Value, Label.LEXCommunity_Picklist_Yes_Value),
								new LEXCommunityHelper.Option(Label.LEXCommunity_Picklist_No_Value, Label.LEXCommunity_Picklist_No_Value)
							};

							data.filters.add(filter);
						}
					}
				}
			}

			return data;
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Launchpad__Event__c getEventData(String eventId, List<String> fields, String filterField) {
		try {
			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('Launchpad__Event__c')) {
				throw new SObjectHelperException.queryPermissionException('Launchpad__Event__c');
			}
			String initialQuery =
				'SELECT Id, {0} FROM Launchpad__Event__c WHERE Launchpad__Available_in_Community__c = TRUE AND ' +
				filterField +
				' = true AND' +
				' {1} WITH SECURITY_ENFORCED ORDER BY {2}';

			String query = String.format(initialQuery, new List<String>{ String.join(fields, ', '), ' Id = :eventId ', ' Name ASC' });

			List<Launchpad__Event__c> events = Database.query(query);
			if (!events.isEmpty()) {
				return events[0];
			}
			return null;
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static List<String> getDownloadLink(String eventId) {
		Set<Id> documentIdSet = new Set<Id>();
		Set<Id> contentDocumentIdSet = new Set<Id>();

		/*CRUD/FLS Security check */
		if (!SobjectHelper.canQueryObj('Launchpad__Document__c')) {
			throw new SObjectHelperException.queryPermissionException('Launchpad__Document__c');
		}
		for (Launchpad__Document__c document : [
			SELECT Id, Launchpad__Title__c
			FROM Launchpad__Document__c
			WHERE Launchpad__Event__c = :eventId AND Launchpad__Type__c = 'Event Documentation'
			WITH SECURITY_ENFORCED
		]) {
			documentIdSet.add(document.Id);
		}

		if (!documentIdSet.isEmpty()) {
			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('ContentDocumentLink')) {
				throw new SObjectHelperException.queryPermissionException('ContentDocumentLink');
			}
			List<ContentDocumentLink> documentLinks = [
				SELECT Id, ContentDocumentId
				FROM ContentDocumentLink
				WHERE LinkedEntityId IN :documentIdSet
				WITH SECURITY_ENFORCED
			];
			Set<Id> contentDocIds = new Set<Id>();
			for (ContentDocumentLink cdl : documentLinks) {
				contentDocIds.add(cdl.ContentDocumentId);
			}
			if (!contentDocIds.isEmpty()) {
				/*CRUD/FLS Security check */
				if (!SobjectHelper.canQueryObj('ContentVersion')) {
					throw new SObjectHelperException.queryPermissionException('ContentVersion');
				}
				List<ContentVersion> cvList = [
					SELECT Id, ContentDocumentID, Title, FileType
					FROM ContentVersion
					WHERE ContentDocumentID IN :contentDocIds
					WITH SECURITY_ENFORCED
				];

				/*CRUD/FLS Security check */
				if (!SobjectHelper.canQueryObj('ContentDistribution')) {
					throw new SObjectHelperException.queryPermissionException('ContentDistribution');
				}
				List<ContentDistribution> cdList = [
					SELECT ContentDownloadURL, ContentDocumentId
					FROM ContentDistribution
					WHERE ContentDocumentId = :contentDocIds
					WITH SECURITY_ENFORCED
				];
				Map<Id, String> downloadUrls = new Map<Id, String>();

				for (ContentDistribution cd : cdList) {
					downloadUrls.put(cd.ContentDocumentId, cd.ContentDownloadURL);
				}
				List<ContentDistribution> cdInsertList = new List<ContentDistribution>();
				for (ContentVersion cv : cvList) {
					if (!downloadUrls.containsKey(cv.ContentDocumentId)) {
						ContentDistribution newItem = new ContentDistribution();
						newItem.Name = cv.Title + '.' + cv.FileType;
						newItem.ContentVersionId = cv.Id;
						newItem.PreferencesAllowViewInBrowser = true;
						newItem.PreferencesLinkLatestVersion = true;
						newItem.PreferencesNotifyOnVisit = false;
						newItem.PreferencesPasswordRequired = false;
						newItem.PreferencesAllowOriginalDownload = true;

						cdInsertList.add(newItem);
					}
				}

				SObjectHelper.insertObj(cdInsertList);

				Set<Id> newItemIds = new Set<Id>();

				for (ContentDistribution cd : cdInsertList) {
					newItemIds.add(cd.Id);
				}

				for (ContentDistribution cd : [SELECT ContentDownloadUrl FROM ContentDistribution WHERE Id IN :newItemIds WITH SECURITY_ENFORCED]) {
					downloadUrls.put(cd.Id, cd.ContentDownloadUrl);
				}

				return downloadUrls.values();
			}
		}
		return null;
	}

	@AuraEnabled
	public static Boolean registerForEvent(String eventId) {
		try {
			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('User')) {
				throw new SObjectHelperException.queryPermissionException('User');
			}
			User currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];

			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('Launchpad__Event__c')) {
				throw new SObjectHelperException.queryPermissionException('Launchpad__Event__c');
			}
			Launchpad__Event__c eventToRegisterFor = [
				SELECT Id, Launchpad__Event_Type__c
				FROM Launchpad__Event__c
				WHERE Id = :eventId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('Launchpad__Event_Attendee_Enrollment__c')) {
				throw new SObjectHelperException.queryPermissionException('Launchpad__Event_Attendee_Enrollment__c');
			}
			List<Launchpad__Event_Attendee_Enrollment__c> eaeList = [
				SELECT Id, Launchpad__Cancelled_via_Community__c
				FROM Launchpad__Event_Attendee_Enrollment__c
				WHERE Company__c = :currentUser.Contact.AccountId AND Launchpad__Event__c = :eventId
				WITH SECURITY_ENFORCED
			];

			Launchpad__Event_Attendee_Enrollment__c eventAttendeeEnrollment = new Launchpad__Event_Attendee_Enrollment__c(
				Launchpad__Contact__c = currentUser.ContactId,
				Company__c = currentUser.Contact.AccountId,
				Launchpad__Enrolled_via_Community__c = true,
				Launchpad__Event__c = eventId
			);

			if (eventToRegisterFor != null && eventToRegisterFor.Launchpad__Event_Type__c == 'On Demand Video') {
				eventAttendeeEnrollment.Launchpad__Watched_On_Demand_Video__c = true;
				eventAttendeeEnrollment.Launchpad__Status__c = 'Completed';
			} else {
				eventAttendeeEnrollment.Launchpad__Status__c = 'Registered';
			}

			if (eaeList.size() > 0) {
				eventAttendeeEnrollment.Id = eaeList[0].Id;

				if (eaeList[0].Launchpad__Cancelled_via_Community__c) {
					eventAttendeeEnrollment.Launchpad__Cancelled_via_Community__c = false;
				}
			}

			SobjectHelper.upsertObj(new List<Launchpad__Event_Attendee_Enrollment__c>{ eventAttendeeEnrollment });

			return true;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean cancelRegisterForEvent(String eventId) {
		try {
			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('User')) {
				throw new SObjectHelperException.queryPermissionException('User');
			}
			User currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('Launchpad__Event__c')) {
				throw new SObjectHelperException.queryPermissionException('Launchpad__Event__c');
			}
			Launchpad__Event__c eventToRegisterFor = [
				SELECT Id, Launchpad__Event_Type__c
				FROM Launchpad__Event__c
				WHERE Id = :eventId
				WITH SECURITY_ENFORCED
				LIMIT 1
			];

			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('Launchpad__Event_Attendee_Enrollment__c')) {
				throw new SObjectHelperException.queryPermissionException('Launchpad__Event_Attendee_Enrollment__c');
			}
			List<Launchpad__Event_Attendee_Enrollment__c> eaeList = [
				SELECT Id, Launchpad__Cancelled_via_Community__c
				FROM Launchpad__Event_Attendee_Enrollment__c
				WHERE Launchpad__Status__c != 'Cancelled Registration' AND Company__c = :currentUser.Contact.AccountId AND Launchpad__Event__c = :eventId
				WITH SECURITY_ENFORCED
			];

			if (eaeList.size() > 0 && eventToRegisterFor.Launchpad__Event_Type__c != 'On Demand Video') {
				for (Launchpad__Event_Attendee_Enrollment__c eae : eaeList) {
					eae.Launchpad__Cancelled_via_Community__c = true;
					eae.Launchpad__Status__c = 'Cancelled Registration';
				}

				SObjectHelper.updateObj(eaeList);
			}

			return true;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Launchpad__Event__c> searchEvents(
		String keyword,
		Date startDate,
		Map<String, List<String>> filterOptionsMap,
		List<String> uniqueFields,
		String filterField,
		String priorityFilterField,
		String searchFilterFields
	) {
		try {
			Schema.SObjectType objDescribe = Schema.getGlobalDescribe().get('Launchpad__Event__c');
			Schema.DescribeSObjectResult objDescribeResult = objDescribe.getDescribe();
			Map<String, Schema.SObjectField> eventFields = objDescribeResult.fields.getMap();
			Set<String> searchFields = new Set<String>();
			Set<String> allFields = new Set<String>(uniqueFields);
			List<String> filters = new List<String>();
			Map<String, Set<String>> eventTypeRecordTypeMap = new Map<String, Set<String>>();

			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('LaborExchangeCommunity_PageProperties__mdt')) {
				throw new SObjectHelperException.queryPermissionException('LaborExchangeCommunity_PageProperties__mdt');
			}
			List<LaborExchangeCommunity_PageProperties__mdt> pageList = [
				SELECT Id, MasterLabel, Field_Set__c, Event_Fields_Above_Button__c, Page__c, Event_Type__c, Record_Type__c
				FROM LaborExchangeCommunity_PageProperties__mdt
				WHERE Active__c = 'Yes' AND Page__c IN ('Event Tile', 'Event Details') AND Object_API__c = 'Launchpad__Event__c'
				WITH SECURITY_ENFORCED
			];

			for (LaborExchangeCommunity_PageProperties__mdt page : pageList) {
				if (!eventTypeRecordTypeMap.containsKey(page.Event_Type__c)) {
					eventTypeRecordTypeMap.put(page.Event_Type__c, new Set<String>());
				}
				eventTypeRecordTypeMap.get(page.Event_Type__c).add(page.Record_Type__c);
			}

			if (startDate != null) {
				filters.add('Launchpad__Start_Date__c = :startDate');
			}

			if (searchFilterFields != null) {
				for (String fieldAPIName : searchFilterFields.split(',')) {
					if (eventFields.containsKey(fieldAPIName.trim())) {
						Schema.DescribeFieldResult fieldResult = eventFields.get(fieldAPIName.trim()).getDescribe();

						if (
							fieldResult.getType() != Schema.DisplayType.PICKLIST &&
							fieldResult.getType() != Schema.DisplayType.MULTIPICKLIST &&
							fieldResult.getType() != Schema.DisplayType.BOOLEAN
						) {
							allFields.add(fieldResult.getName());
							searchFields.add(fieldResult.getName());
						} else if (fieldResult.getType() == Schema.DisplayType.PICKLIST) {
							if (
								filterOptionsMap != null &&
								filterOptionsMap.containsKey(fieldResult.getName()) &&
								!filterOptionsMap.get(fieldResult.getName()).isEmpty()
							) {
								filters.add(fieldResult.getName() + ' IN (\'' + String.join(filterOptionsMap.get(fieldResult.getName()), '\',\'') + '\')');
							}
						} else if (fieldResult.getType() == Schema.DisplayType.MULTIPICKLIST) {
							if (
								filterOptionsMap != null &&
								filterOptionsMap.containsKey(fieldResult.getName()) &&
								!filterOptionsMap.get(fieldResult.getName()).isEmpty()
							) {
								filters.add(
									fieldResult.getName() + ' INCLUDES (\'' + String.join(filterOptionsMap.get(fieldResult.getName()), '\',\'') + '\')'
								);
							}
						} else if (fieldResult.getType() == Schema.DisplayType.BOOLEAN) {
							if (
								filterOptionsMap != null &&
								filterOptionsMap.containsKey(fieldResult.getName()) &&
								!filterOptionsMap.get(fieldResult.getName()).isEmpty()
							) {
								String filter = '';
								for (String value : filterOptionsMap.get(fieldResult.getName())) {
									if (value == Label.LEXCommunity_Picklist_Yes_Value) {
										filter = filter != '' ? '' : fieldResult.getName() + ' = TRUE';
									} else if (value == Label.LEXCommunity_Picklist_No_Value) {
										filter = filter != '' ? '' : fieldResult.getName() + ' = FALSE';
									}

									if (filter != '') {
										filters.add(filter);
									}
								}
							}
						}
					}
				}
			}
			uniqueFields = new List<String>(allFields);

			String filter = String.join(filters, ' AND ');

			List<Launchpad__Event__c> events = getEvents(uniqueFields, false, eventTypeRecordTypeMap, filter, startDate, filterField, priorityFilterField);

			if (keyword != '' && !searchFields.isEmpty()) {
				List<Launchpad__Event__c> searchedEvents = new List<Launchpad__Event__c>();
				for (Launchpad__Event__c event : events) {
					Boolean found = false;
					for (String field : searchFields) {
						String value = String.valueOf(event.get(field));
						if (value != null && value.containsIgnoreCase(keyword)) {
							found = true;
							break;
						}
					}
					if (found) {
						searchedEvents.add(event);
					}
				}

				return searchedEvents;
			} else {
				return events;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	private static List<Launchpad__Event__c> getDefaultEvents(
		List<String> uniqueFields,
		Boolean isHomePage,
		Map<String, Set<String>> eventTypeRecordTypeMap,
		String filterField,
		String priorityFilterField
	) {
		return getEvents(uniqueFields, isHomePage, eventTypeRecordTypeMap, '', null, filterField, priorityFilterField);
	}

	private static List<Launchpad__Event__c> getEvents(
		List<String> uniqueFields,
		Boolean isHomePage,
		Map<String, Set<String>> eventTypeRecordTypeMap,
		String filter,
		Date startDate,
		String filterField,
		String priorityFilterField
	) {
		String initialQuery =
			'SELECT Id, {0} FROM Launchpad__Event__c WHERE Launchpad__Available_in_Community__c = TRUE' +
			(filterField != null && filterField != '' ? ' AND ' + filterField + ' = TRUE ' : '') +
			(filter != '' ? ' AND ' + filter : '') +
			' {1} WITH SECURITY_ENFORCED ORDER BY {2}';
		List<Launchpad__Event__c> events = new List<Launchpad__Event__c>();
		List<Launchpad__Event__c> otherEvents = new List<Launchpad__Event__c>();

		if (eventTypeRecordTypeMap.containsKey('On Demand Video')) {
			Set<String> recordTypeNames = eventTypeRecordTypeMap.get('On Demand Video');

			String query = String.format(
				initialQuery,
				new List<String>{
					String.join(uniqueFields, ', '),
					' AND Launchpad__Event_Type__c = \'On Demand Video\' AND RecordType.Name IN : recordTypeNames AND ' +
					(priorityFilterField != '' ? priorityFilterField + ' = TRUE ' : ''),
					' Name ASC'
				}
			);

			/*CRUD/FLS Security check */
			if (!SobjectHelper.canQueryObj('Launchpad__Event__c')) {
				throw new SObjectHelperException.queryPermissionException('Launchpad__Event__c');
			}
			events = Database.query(query);

			if (priorityFilterField != '') {
				String otherQuery = String.format(
					initialQuery,
					new List<String>{
						String.join(uniqueFields, ', '),
						' AND Launchpad__Event_Type__c = \'On Demand Video\' AND RecordType.Name IN : recordTypeNames AND ' +
						priorityFilterField +
						' = FALSE ',
						' Name ASC'
					}
				);

				otherEvents = Database.query(otherQuery);
			}
		}

		if (eventTypeRecordTypeMap.containsKey('Live')) {
			Set<String> recordTypeNames = eventTypeRecordTypeMap.get('Live');

			String query = String.format(
				initialQuery,
				new List<String>{
					String.join(uniqueFields, ', '),
					' AND Launchpad__Event_Type__c != \'On Demand Video\' AND RecordType.Name IN : recordTypeNames AND ' +
					(priorityFilterField != '' ? priorityFilterField + ' = TRUE ' : ''),
					' Launchpad__Start_Date__c ASC, Launchpad__Start_Time__c ASC '
				}
			);

			events.addAll((List<Launchpad__Event__c>) Database.query(query));

			if (priorityFilterField != '') {
				String otherQuery = String.format(
					initialQuery,
					new List<String>{
						String.join(uniqueFields, ', '),
						' AND Launchpad__Event_Type__c != \'On Demand Video\' AND RecordType.Name IN : recordTypeNames AND ' +
						priorityFilterField +
						' = FALSE ',
						' Launchpad__Start_Date__c ASC, Launchpad__Start_Time__c ASC '
					}
				);

				otherEvents.addAll((List<Launchpad__Event__c>) Database.query(otherQuery));
			}
		}

		if (!otherEvents.isEmpty()) {
			events.addAll(otherEvents);
		}

		return events;
	}

	public class FilterList {
		@AuraEnabled
		public String title;

		@AuraEnabled
		public String fieldName;

		@AuraEnabled
		public List<LEXCommunityHelper.Option> values;
	}

	public class FieldsConfig {
		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> tileFields;

		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> confirmationFields;

		@AuraEnabled
		public Integer noOfFields;
	}

	public class EventsSetupData {
		@AuraEnabled
		public Map<String, FieldsConfig> fieldsConfigMap;

		@AuraEnabled
		public List<FilterList> filters;

		@AuraEnabled
		public List<String> uniqueFields;

		@AuraEnabled
		public List<Launchpad__Event__c> events;

		@AuraEnabled
		public List<Id> registeredEventIds;

		@AuraEnabled
		public Integer noOfTilesPerPage;

		public EventsSetupData() {
			fieldsConfigMap = new Map<String, FieldsConfig>();
		}
	}
}