public with sharing class LEXCandidateSearchController {
	//public static final String NAMESPACE_PREFIX = SObjectHelper.getNamespace();
	public static final Labor_Exchange_Community_Setup__c lexCS = Labor_Exchange_Community_Setup__c.getOrgDefaults();
	public static final List<String> CONTACT_RECORD_TYPE_API_NAMES = getContactRecordTypes();
	public static final List<String> CONTACT_STAGE_API_NAMES = getContactStages();

	@AuraEnabled(cacheable=true)
	public static CandidateFieldSet getSetupData(
		String viewType,
		String filterField,
		String priorityFilterField,
		//String matchFilterField,
		String searchFilterFields
	) {
		try {
			Boolean isHomePage = viewType == 'Home';
			Boolean isSavedPage = viewType == 'SavedCandidates';
			String objectName = 'Contact';
			Schema.SObjectType objDescribe = Schema.getGlobalDescribe().get(objectName);
			Schema.DescribeSObjectResult objDescribeResult = objDescribe.getDescribe();
			Map<String, Schema.SObjectField> candidateFields = objDescribeResult.fields.getMap();
			CandidateFieldSet data = new CandidateFieldSet();
			Map<String, Map<String, String>> fieldsMap = new Map<String, Map<String, String>>();

			Set<String> uniqueFields = new Set<String>();

			//Labor_Exchange_Community_Setup__c jscs = Labor_Exchange_Community_Setup__c.getOrgDefaults();

			if (!SobjectHelper.canQueryObj('LaborExchangeCommunity_PageProperties__mdt')) {
				throw SObjectHelperException.queryPermissionException('LaborExchangeCommunity_PageProperties__mdt');
			}
			List<LaborExchangeCommunity_PageProperties__mdt> pageList = [
				SELECT Id, MasterLabel, Field_Set__c, Event_Fields_Above_Button__c, Page__c
				FROM LaborExchangeCommunity_PageProperties__mdt
				WHERE Active__c = 'Yes' AND Page__c IN ('Candidate Tile', 'Candidate Details') AND Object_API__c = :objectName
				WITH SECURITY_ENFORCED
			];

			if (!SobjectHelper.canQueryObj('LaborExchangeCommunity_FieldProperties__mdt')) {
				throw SObjectHelperException.queryPermissionException('LaborExchangeCommunity_FieldProperties__mdt');
			}
			for (LaborExchangeCommunity_FieldProperties__mdt fieldList : [
				SELECT Id, Field_API_Name__c, Field_Label__c, LaborExchangeCommunity_PageProperties__c
				FROM LaborExchangeCommunity_FieldProperties__mdt
				WHERE Active__c = 'Yes' AND LaborExchangeCommunity_PageProperties__c IN :pageList
				WITH SECURITY_ENFORCED
			]) {
				if (!fieldsMap.containsKey(fieldList.LaborExchangeCommunity_PageProperties__c)) {
					fieldsMap.put(fieldList.LaborExchangeCommunity_PageProperties__c, new Map<String, String>());
				}

				fieldsMap.get(fieldList.LaborExchangeCommunity_PageProperties__c).put(fieldList.Field_API_Name__c, fieldList.Field_Label__c);
			}

			for (LaborExchangeCommunity_PageProperties__mdt page : pageList) {
				List<LEXCommunityHelper.FieldWrapper> fields = LEXCommunityHelper.getFieldsByObjectAndFieldSet(objectName, page.Field_Set__c);

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

				if (page.Page__c == 'Candidate Tile') {
					data.candidateSearchFields = new List<LEXCommunityHelper.FieldWrapper>(fields);
				} else if (page.Page__c == 'Candidate Detail') {
					data.candidateViewDetailsFields = new List<LEXCommunityHelper.FieldWrapper>(fields);
				}
			}

			if (!SobjectHelper.canQueryObj('User')) {
				throw SObjectHelperException.queryPermissionException('User');
			}
			List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
			Map<Id, Launchpad__Match__c> matchMap = new Map<Id, Launchpad__Match__c>();

			List<Launchpad__Job__c> myJobs = new CandidateSearchPrivileged().getMyJobs(currentUser[0]);
			for (Launchpad__Match__c match : new CandidateSearchPrivileged().getMatchRecords(myJobs)) {
				matchMap.put(match.Launchpad__Client__c, match);
			}

			Set<Id> savedCandidateIds = new Set<Id>();
			Set<Id> appliedCandidateIds = new Set<Id>();

			/*for (Launchpad__Saved_Candidate__c sc : new CandidateSearchPrivileged().getSavedCandidates(currentUser[0])) {
				savedCandidateIds.add(sc.Contact);
			}

			for (Launchpad__Applicant_Tracking__c application : new CandidateSearchPrivileged().getApplications(currentUser[0])) {
				appliedCandidateIds.add(application.Launchpad__Candidate_Order__c);
			}*/

			data.savedCandidateIds = new List<Id>(savedCandidateIds);
			data.appliedCandidateIds = new List<Id>(appliedCandidateIds);
			data.uniqueFields = new List<String>(uniqueFields);
			data.noOfTilesPerPage = Integer.valueOf(lexCS.of_Tiles_Per_Page__c);

			if (!uniqueFields.isEmpty()) {
				if (!isHomePage && !isSavedPage) {
					data.myCandidates = getMyCandidates(
						data.uniqueFields,
						matchMap,
						matchMap.keySet(),
						false,
						false,
						filterField,
						priorityFilterField
						//,matchFilterField
					);
					data.otherCandidates = getMyCandidates(
						data.uniqueFields,
						null,
						matchMap.keySet(),
						false,
						false,
						filterField,
						priorityFilterField
						//, matchFilterField
					);
				} else if (isHomePage) {
					data.otherCandidates = getMyCandidates(data.uniqueFields, null, null, true, false, filterField, priorityFilterField); //, matchFilterField
				} /* is Saved Page?
				 else {
					data.otherCandidates = getMyCandidates(
						data.uniqueFields,
						matchMap,
						savedCandidateIds,
						false,
						true,
						filterField,
						priorityFilterField,
						matchFilterField
					);
				}*/
			}

			if (!isHomePage && !isSavedPage && searchFilterFields != null) {
				data.filters = new List<FilterList>();

				for (String fieldAPIName : searchFilterFields.split(',')) {
					if (candidateFields.containsKey(fieldAPIName.trim())) {
						Schema.DescribeFieldResult fieldResult = candidateFields.get(fieldAPIName.trim()).getDescribe();

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
			throw new AuraHandledException(e.getMessage());
		}
	}

	/*@AuraEnabled(cacheable=true)
	public static List<Skill> getMatchedSkills(String candidateId) {
		try {
			//get candidate's skills
			Set<String> candidateSkills = new Set<String>();
			for (Launchpad__Client_Skill__c cs : new CandidateSearchPrivileged().getMatchedSkills(candidateId)) {
				candidateSkills.add(cs.Launchpad__Skill1__r.Name);
			}

			//get jobs' skills?
			/List<LEXSkillsSelectionController.Skill> matchedSkills = new List<LEXSkillsSelectionController.Skill>();
			for (LEXSkillsSelectionController.Skill s : LEXSkillsSelectionController.getJobSkills()) {
				if (candidateSkills.contains(s.label)) {
					matchedSkills.add(s);
				}
			}/

			return candidateSkills;

		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}*/

	/*@AuraEnabled(cacheable=true)
	public static String getContactId() {
		try {
			if (!SobjectHelper.canQueryObj('User')) {
				throw SObjectHelperException.queryPermissionException('User');
			}
			List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];

			return currentUser[0].ContactId;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}*/

	@AuraEnabled
	public static Candidate getCandidateData(String candidateId, List<String> fields, String filterField) {
		try {
			return new CandidateSearchPrivileged().getCandidateData(candidateId, fields, filterField);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Contact> searchCandidates(
		//Decimal wage,
		//String cityOrZipCode,
		String keyword,
		Map<String, List<String>> filterOptionsMap,
		List<String> uniqueFields,
		String filterField,
		String priorityFilterField,
		String searchFilterFields
	) {
		try {
			return new CandidateSearchPrivileged()
				.searchCandidates(
					//wage,
					//cityOrZipCode,
					keyword,
					filterOptionsMap,
					uniqueFields,
					filterField,
					priorityFilterField,
					searchFilterFields
				);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void emailCandidate(Id candidateId, String emailBody) {
		new CandidateSearchPrivileged().emailCandidate(candidateId, emailBody);
	}

	@AuraEnabled(cacheable=true)
	public static Launchpad__Match__c getMatch(Id matchId) {
		return new CandidateSearchPrivileged().getMatch(matchId);
	}

	private static List<Candidate> getMyCandidates(
		List<String> uniqueFields,
		Map<Id, Launchpad__Match__c> matchMap,
		Set<Id> candidateIds,
		Boolean isHome,
		Boolean isSavedCandidates,
		String filterField,
		String priorityFilterField
	) {
		//,String matchFilterField
		return new CandidateSearchPrivileged()
			.getMyCandidates(uniqueFields, matchMap, candidateIds, isHome, isSavedCandidates, filterField, priorityFilterField); //, matchFilterField
	}

	// * Method purpose: Get the Contact Record Types as defined in the Labor_Exchange_Community_Setup__c custom setting
	@TestVisible
	private static List<String> getContactRecordTypes() {
		// store the values in a list of values
		if (lexCS != null) {
			// Store the comma separated list as provided in the ContactRecordTypes__c field
			String recordTypesString = lexCS.ContactRecordTypes__c;
			// Separate the values into a list
			List<String> recordTypes = recordTypesString.split(',');
			// Initialize an empty list to store the final list
			List<String> finalRecordTypes = new List<String>();
			// Remove white space
			for (String str : recordTypes) {
				String finalStrValue = str.normalizeSpace();
				finalRecordTypes.add(finalStrValue);
			}
			// if we have record types, return record types. Otherwise return null
			return finalRecordTypes.size() > 0 ? finalRecordTypes : null;
		}
		// Otherwise return null
		return null;
	}
	// * Method purpose: Get the Searchable Contact Stages as defined in the Labor_Exchange_Community_Setup__c custom setting
	@TestVisible
	private static List<String> getContactStages() {
		// store the values in a list of values
		if (lexCS != null) {
			// Store the comma separated list as provided in the ContactRecordTypes__c field
			String stagesString = lexCS.Searchable_Contact_Stages__c;

			// Separate the values into a list
			List<String> stages = stagesString.split(',');

			// Initialize an empty list to store the final list
			List<String> finalStages = new List<String>();

			// Remove white space
			Integer counter = 0;
			for (String str : stages) {
				String finalStrValue = str.normalizeSpace();
				finalStages.add(finalStrValue);
			}
			// if we have record types, return record types. Otherwise return null
			return finalStages.size() > 0 ? finalStages : null;
		}
		// Otherwise return null
		return null;
	}

	public without sharing class CandidateSearchPrivileged {
		public Launchpad__Match__c getMatch(Id matchId) {
			if (!SobjectHelper.canQueryObj('Launchpad__Match__c')) {
				throw SObjectHelperException.queryPermissionException('Launchpad__Match__c');
			}

			return [
				SELECT Id, Launchpad__Client__c
				FROM Launchpad__Match__c
				WHERE Id = :matchId
			];
		}

		public List<Candidate> getMyCandidates(
			List<String> uniqueFields,
			Map<Id, Launchpad__Match__c> matchMap,
			Set<Id> candidateIds,
			Boolean isHome,
			Boolean isSavedCandidates,
			String filterField,
			String priorityFilterField
		) {
			//,String matchFilterField
			if (!SobjectHelper.canQueryObj('Contact')) {
				throw SObjectHelperException.queryPermissionException('Contact');
			}

			String initialQuery = 'SELECT Id, {0} , (SELECT Launchpad__Skill1__r.Name FROM Launchpad__Client_Skills__r) FROM Contact WHERE RecordType.DeveloperName IN :CONTACT_RECORD_TYPE_API_NAMES AND Launchpad__Stage__c IN :CONTACT_STAGE_API_NAMES AND {1} WITH SECURITY_ENFORCED ORDER BY {2} ';
			String query = String.format(
				initialQuery,
				new List<String>{
					String.join(uniqueFields, ', '),
					isHome
						? ' ' + filterField + ' = TRUE '
						: isSavedCandidates
								? ' Id IN :candidateIds '
								: (matchMap != null
										? ' Id IN :candidateIds ' // AND ' + matchFilterField + ' = TRUE
										: ' Id NOT IN :candidateIds '), // AND ' + filterField + ' = TRUE
					//matchMap != null ? ' Name ASC' : (priorityFilterField != '' ? ' Community_Priority_Contact DESC, ' : '') + 'Closing_Date__c DESC, Name ASC'
					' Name ASC'
				}
			);

			List<Contact> candidates = new List<Contact>((List<Contact>) Database.query(query));

			List<Candidate> candidatesToReturn = new List<Candidate>();

			if (matchMap != null) {
				for (Contact candidate : candidates) {
					if (matchMap.containsKey(candidate.Id)) {
						candidatesToReturn.add(new Candidate(candidate, matchMap.get(candidate.Id).Launchpad__Match__c));
					} else {
						candidatesToReturn.add(new Candidate(candidate, null));
					}
				}
			} else {
				for (Contact contact : candidates) {
					candidatesToReturn.add(new Candidate(contact, null));
				}
			}

			return candidatesToReturn;
		}

		public List<Launchpad__Match__c> getMatchRecords(List<Launchpad__Job__c> myJobs) {
			if (!SobjectHelper.canQueryObj('Launchpad__Match__c')) {
				throw SObjectHelperException.queryPermissionException('Launchpad__Match__c');
			}
			return [
				SELECT Id, Launchpad__Match__c, Launchpad__Client__c
				FROM Launchpad__Match__c
				WHERE Launchpad__Job__c IN :myJobs //WHERE Launchpad__Client__c = :currentUser.ContactId AND Launchpad__Candidate__r.Launchpad__Available_in_Community__c = true
				WITH SECURITY_ENFORCED
				ORDER BY Launchpad__Match__c DESC
			];
		}

		public List<Launchpad__Job__c> getMyJobs(User currentUser) {
			if (!SobjectHelper.canQueryObj('Launchpad__Job__c')) {
				throw SObjectHelperException.queryPermissionException('Launchpad__Job__c');
			}
			return [
				SELECT Id
				FROM Launchpad__Job__c
				WHERE Launchpad__Contact__c = :currentUser.ContactId
				WITH SECURITY_ENFORCED
			];
		}

		/*public List<Launchpad__Client_Skill__c> getMatchedSkills(String candidateId) {
			if (!SobjectHelper.canQueryObj('Launchpad__Client_Skill__c')) {
				throw SObjectHelperException.queryPermissionException('Launchpad__Client_Skill__c');
			}
			return [
				SELECT Id, Launchpad__Skill1__r.Name
				FROM Launchpad__Client_Skill__c
				WHERE Launchpad__Client__c = :candidateId AND Launchpad__Client__r.RecordType.DeveloperName IN :CONTACT_RECORD_TYPE_API_NAMES
				WITH SECURITY_ENFORCED
				ORDER BY Launchpad__Skill1__r.Name ASC
			];
		}*/

		public Candidate getCandidateData(String candidateId, List<String> fields, String filterField) {
			Candidate myCandidate;
			String initialQuery =
				'SELECT Id, {0} , (SELECT Launchpad__Skill1__r.Name FROM Launchpad__Client_Skills__r) FROM Contact WHERE RecordType.DeveloperName IN :CONTACT_RECORD_TYPE_API_NAMES AND Launchpad__Stage__c IN :CONTACT_STAGE_API_NAMES ' +
				(!String.isEmpty(filterField) ? 'AND ' + filterField + ' = TRUE ' : '') +
				' {1} WITH SECURITY_ENFORCED';
			String query = String.format(initialQuery, new List<String>{ String.join(fields, ', '), ' AND Id = : candidateId ' });

			if (!SobjectHelper.canQueryObj('Contact')) {
				throw SObjectHelperException.queryPermissionException('Contact');
			}

			List<Contact> candidateList = (List<Contact>) Database.query(query);
			if (!candidateList.isEmpty()) {
				myCandidate = new Candidate(candidateList[0], null);
			}
			return myCandidate;
		}

		public List<Contact> searchCandidates(
			//Decimal wage,
			//String cityOrZipCode,
			String keyword,
			Map<String, List<String>> filterOptionsMap,
			List<String> uniqueFields,
			String filterField,
			String priorityFilterField,
			String searchFilterFields
		) {
			Schema.SObjectType objDescribe = Schema.getGlobalDescribe().get('Contact');
			Schema.DescribeSObjectResult objDescribeResult = objDescribe.getDescribe();
			Map<String, Schema.SObjectField> candidateFields = objDescribeResult.fields.getMap();
			Set<String> searchFields = new Set<String>{};
			Set<String> allFields = new Set<String>(uniqueFields);
			List<String> filters = new List<String>();

			// apply custom filters
			if (searchFilterFields != null) {
				for (String fieldAPIName : searchFilterFields.split(',')) {
					if (candidateFields.containsKey(fieldAPIName.trim())) {
						Schema.DescribeFieldResult fieldResult = candidateFields.get(fieldAPIName.trim()).getDescribe();

						if (
							(fieldResult.getType() != Schema.DisplayType.PICKLIST &&
							fieldResult.getType() != Schema.DisplayType.MULTIPICKLIST &&
							fieldResult.getType() != Schema.DisplayType.BOOLEAN) ||
							(fieldResult.getType() == Schema.DisplayType.PICKLIST && !filterOptionsMap.containsKey(fieldResult.getName()))
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

			// Search Skills by keyword
			Set<Id> candidateMatchedBySkillIds = new Set<Id>();

			if (keyword != '') {
				// query skills
				Set<Id> skillIds = new Set<Id>();
				String keywordQuery = '\'%' + keyword + '%\'';

				String skillQuery = 'SELECT Id, Name FROM Launchpad__Skill1__c WHERE Name LIKE ' + keywordQuery;
				//Launchpad__Skill1__c testQuery = [SELECT Id, Name FROM Launchpad__Skill1__c WHERE Name LIKE :keywordQuery];
				List<Launchpad__Skill1__c> matchingSkills = Database.query(skillQuery);

				for (Launchpad__Skill1__c matchingSkill : matchingSkills) {
					skillIds.add(matchingSkill.Id);
				}
				// find candidates with matching skills
				string candidateSkillsQuery =
					'SELECT Launchpad__Client__c FROM Launchpad__Client_Skill__c WHERE Launchpad__Client__r.RecordType.DeveloperName IN :CONTACT_RECORD_TYPE_API_NAMES AND Launchpad__Skill1__c IN :skillIds ' +
					(!String.isEmpty(filterField) ? ' AND Launchpad__Candidate__r.' + filterField + ' = TRUE ' : '') +
					' WITH SECURITY_ENFORCED ';
				if (!SobjectHelper.canQueryObj('Launchpad__Client_Skill__c')) {
					throw SObjectHelperException.queryPermissionException('Launchpad__Client_Skill__c');
				}
				for (Launchpad__Client_Skill__c candidateSkill : Database.query(String.escapeSingleQuotes(candidateSkillsQuery))) {
					//add to candidates list
					candidateMatchedBySkillIds.add(candidateSkill.Launchpad__Client__c);
				}
				//}
			}

			// Search Contacts by keyword
			String initialQuery = 'SELECT Id, {0} , (SELECT Launchpad__Skill1__r.Name FROM Launchpad__Client_Skills__r) FROM Contact WHERE RecordType.DeveloperName IN :CONTACT_RECORD_TYPE_API_NAMES AND Launchpad__Stage__c IN :CONTACT_STAGE_API_NAMES {1} WITH SECURITY_ENFORCED ORDER BY {2} ';
			String whereClause =
				(!String.isEmpty(filterField) ? filterField + ' AND = TRUE ' : '') +
				(!candidateMatchedBySkillIds.isEmpty() ? ' AND Id NOT IN : candidateMatchedBySkillIds ' : '') +
				(!String.isEmpty(filter.trim()) ? ' AND ' + filter : '');

			String contactquery = String.format(
				initialQuery,
				new List<String>{
					String.join(uniqueFields, ', '),
					whereClause + (priorityFilterField != '' ? ' AND ' + priorityFilterField + ' = TRUE ' : ''),
					' Name ASC'
				}
			);

			if (!SobjectHelper.canQueryObj('Contact')) {
				throw SObjectHelperException.queryPermissionException('Contact');
			}
			List<Contact> candidates = new List<Contact>((List<Contact>) Database.query(contactquery));

			if (priorityFilterField != '') {
				contactquery = String.format(
					initialQuery,
					new List<String>{ String.join(uniqueFields, ', '), whereClause + ' AND ' + priorityFilterField + ' = FALSE ', ' Name ASC' }
				);

				candidates.addAll((List<Contact>) Database.query(contactquery));
			}

			if (keyword != '' && !searchFields.isEmpty()) {
				List<Contact> searchedCandidates = new List<Contact>();
				for (Contact candidate : candidates) {
					Boolean found = false;
					for (String field : searchFields) {
						/*String value = field == NAMESPACE_PREFIX + 'Launchpad__Account__r.Name'
							? candidate.Launchpad__Account__r.Name
							: String.valueOf(candidate.get(field));*/
						String value = String.valueOf(candidate.get(field));
						if (value != null && value.containsIgnoreCase(keyword)) {
							found = true;
							break;
						}
					}
					if (found) {
						searchedCandidates.add(candidate);
					}
				}

				candidates = new List<Contact>(searchedCandidates);
			}

			if (!candidateMatchedBySkillIds.isEmpty()) {
				whereClause = ' AND Id IN : candidateMatchedBySkillIds ' + (!String.isEmpty(filter.trim()) ? ' AND ' + filter : '');

				contactquery = String.format(
					initialQuery,
					new List<String>{
						String.join(uniqueFields, ', '),
						whereClause + (priorityFilterField != '' ? ' AND ' + priorityFilterField + ' = TRUE ' : ''),
						' CreatedDate DESC'
					}
				);

				candidates.addAll((List<Contact>) Database.query(contactquery));

				if (priorityFilterField != '') {
					contactquery = String.format(
						initialQuery,
						new List<String>{ String.join(uniqueFields, ', '), whereClause + ' AND ' + priorityFilterField + ' = FALSE ', ' Name ASC' }
					);

					candidates.addAll((List<Contact>) Database.query(contactquery));
				}
			}

			if (!candidates.isEmpty()) {
				contactquery = String.format(
					initialQuery,
					new List<String>{
						String.join(uniqueFields, ', '),
						' AND Id IN : candidates ',
						//(priorityFilterField != '' ? ' Community_Priority_Contact DESC, ' : '') + 'Closing_Date__c DESC, Name ASC'
						'Name ASC'
					}
				);
				List<Contact> searchedCandidates = new List<Contact>((List<Contact>) Database.query(contactquery));

				return searchedCandidates;
			}
			return candidates;
		}

		public void emailCandidate(Id candidateId, String emailBody) {
			if (!SobjectHelper.canQueryObj('Contact')) {
				throw SObjectHelperException.queryPermissionException('Contact');
			}
			try {
				//get personal details for Job Seeker
				Contact toContact = [SELECT Id, Name, Email, Owner.Email FROM Contact WHERE Id = :candidateId WITH SECURITY_ENFORCED LIMIT 1];
				String senderEmail = UserInfo.getUserEmail();

				// reserve email send, will throw System.HandledException if org is over email limit
				Messaging.reserveSingleEmailCapacity(1);
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				List<String> ccAddresses = new List<String>{ toContact.Owner.Email };

				email.setToAddresses(new List<String>{ toContact.Email });
				email.setCcAddresses(ccAddresses);
				email.setReplyTo(senderEmail);
				email.setSenderDisplayName(UserInfo.getName());
				email.setSubject('Contact Request');
				//email.setPlainTextBody(emailBody);
				email.setHtmlBody(emailBody);

				//log email to contact record
				email.setTargetObjectId(candidateId);
				email.setSaveAsActivity(true);

				Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
				return;

				/*} catch (HandledException e){
				result.overLimit = true;
				return result;*/
			} catch (Exception e) {
				throw new AuraHandledException(e.getMessage());
			}
		}

		/* No requirement for Saved Candidates

        public Boolean saveCandidate(String candidateId) {
            if(!SobjectHelper.canQueryObj('User')) {
                throw SObjectHelperException.queryPermissionException('User');
            }
            List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
            
            SObjectHelper.insertObj( new Launchpad__Saved_Candidate__c(Launchpad__Contact__c = currentUser[0].ContactId, Contact = candidateId) );
            return true;
        }

        public Boolean removeSavedCandidate(String candidateId) {
            if(!SobjectHelper.canQueryObj('User')) {
                throw SObjectHelperException.queryPermissionException('User');
            }
            List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
            
            if(!SobjectHelper.canQueryObj('Launchpad__Saved_Candidate__c')) {
                throw SObjectHelperException.queryPermissionException('Launchpad__Saved_Candidate__c');
            }
            SObjectHelper.deleteObj([SELECT Id FROM Launchpad__Saved_Candidate__c WHERE Launchpad__Contact__c = :currentUser[0].ContactId AND Contact = :candidateId WITH SECURITY_ENFORCED]);
            return true;
        }*/
	}

	public class FilterList {
		@AuraEnabled
		public String title;

		@AuraEnabled
		public String fieldName;

		@AuraEnabled
		public List<LEXCommunityHelper.Option> values;
	}

	public class CandidateFieldSet {
		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> candidateSearchFields;

		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> candidateViewDetailsFields;

		@AuraEnabled
		public Integer noOfTilesPerPage;

		@AuraEnabled
		public List<FilterList> filters;

		@AuraEnabled
		public List<String> uniqueFields;

		@AuraEnabled
		public List<Candidate> myCandidates;

		@AuraEnabled
		public List<Candidate> otherCandidates;

		@AuraEnabled
		public List<Id> savedCandidateIds;

		@AuraEnabled
		public List<Id> appliedCandidateIds;
	}

	public class Candidate {
		@AuraEnabled
		public Contact candidate;

		@AuraEnabled
		public Decimal matchPercent;

		public Candidate(Contact candidate, Decimal matchPercent) {
			this.candidate = candidate;
			this.matchPercent = matchPercent;
		}
	}

	public class CustomValueWrapper {
		@AuraEnabled
		public string label { get; set; }
		@AuraEnabled
		public string value { get; set; }
	}

	public class Skill {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;

		public Skill(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}
}