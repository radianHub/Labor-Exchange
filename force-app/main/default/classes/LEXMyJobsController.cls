public with sharing class LEXMyJobsController {
	@AuraEnabled(cacheable=true)
	public static JobFieldSet getJobData(String filterField) {
		try {
			// if (!SObjectHelper.canQueryObj('User')) {
			// 	throw SObjectHelperException.queryPermissionException('User');
			// }
			List<User> currentUser = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :UserInfo.getUserId()
				WITH SECURITY_ENFORCED
			];

			// if (!SObjectHelper.canQueryObj('Contact')) {
			// 	throw SObjectHelperException.queryPermissionException('Contact');
			// }
			String accountId;
			if (currentUser.size() > 0) {
				String contactId = currentUser[0].ContactId;
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

			String objName = 'Launchpad__Job__c';

			JobFieldSet data = new JobFieldSet();
			data.accountId = accountId;
			Map<String, Map<String, String>> fieldsMap = new Map<String, Map<String, String>>();
			Set<String> uniqueFields = new Set<String>();

			Labor_Exchange_Community_Setup__c lexcs = Labor_Exchange_Community_Setup__c.getOrgDefaults();

			// if (!SObjectHelper.canQueryObj('LaborExchangeCommunity_PageProperties__mdt')) {
			// 	throw SObjectHelperException.queryPermissionException('LaborExchangeCommunity_PageProperties__c');
			// }
			List<LaborExchangeCommunity_PageProperties__mdt> ppList = [
				SELECT Id, MasterLabel, Field_Set__c, Page__c
				FROM LaborExchangeCommunity_PageProperties__mdt
				WHERE Active__c = 'Yes' AND Page__c IN ('Job Tile', 'Job Details', 'Job Edit') AND Object_API__c = :objName
				WITH SECURITY_ENFORCED
			];

			// if (!SObjectHelper.canQueryObj('LaborExchangeCommunity_FieldProperties__mdt')) {
			// 	throw SObjectHelperException.queryPermissionException('LaborExchangeCommunity_FieldProperties__mdt');
			// }
			for (LaborExchangeCommunity_FieldProperties__mdt ff : [
				SELECT Id, Field_API_Name__c, Field_Label__c, LaborExchangeCommunity_PageProperties__c
				FROM LaborExchangeCommunity_FieldProperties__mdt
				WHERE Active__c = 'Yes' AND LaborExchangeCommunity_PageProperties__c IN :ppList
				WITH SECURITY_ENFORCED
			]) {
				if (!fieldsMap.containsKey(ff.LaborExchangeCommunity_PageProperties__c)) {
					fieldsMap.put(ff.LaborExchangeCommunity_PageProperties__c, new Map<String, String>());
				}

				fieldsMap.get(ff.LaborExchangeCommunity_PageProperties__c).put(ff.Field_API_Name__c, ff.Field_Label__c);
			}

			for (LaborExchangeCommunity_PageProperties__mdt pp : ppList) {
				List<LEXCommunityHelper.FieldWrapper> fields = LEXCommunityHelper.getFieldsByObjectAndFieldSet(objName, pp.Field_Set__c);

				for (LEXCommunityHelper.FieldWrapper fw : fields) {
					uniqueFields.add(fw.fieldApiName);
				}

				if (fieldsMap.containsKey(pp.Id) && !fieldsMap.get(pp.Id).keySet().isEmpty()) {
					for (LEXCommunityHelper.FieldWrapper fw : fields) {
						if (fieldsMap.get(pp.Id).containsKey(fw.fieldApiName)) {
							fw.fieldLabel = fieldsMap.get(pp.Id).get(fw.fieldApiName);
						}
					}
				}

				if (pp.Page__c == 'Job Tile') {
					data.jobTileFields = new List<LEXCommunityHelper.FieldWrapper>(fields);
				} else if (pp.Page__c == 'Job Details') {
					data.jobViewDetailsFields = new List<LEXCommunityHelper.FieldWrapper>(fields);
				} else if (pp.Page__c == 'Job Edit') {
					data.jobCreateEditFields = new List<LEXCommunityHelper.FieldWrapper>(fields);
				}
			}

			data.noOfTilesPerPage = Integer.valueOf(lexcs.of_Tiles_Per_Page__c);
			data.uniqueFields = new List<String>(uniqueFields);

			if (!uniqueFields.isEmpty()) {
				data.myJobs = getFilteredJobs(data.uniqueFields, accountId, objName);
			}

			Schema.DescribeSObjectResult dor = LEXCommunityHelper.getSObjSchema(objName);
			Map<String, Schema.SObjectField> jobFields = dor.fields.getMap();
			data.filter = new List<FilterList>();

			if (filterField != null) {
				for (String fieldApiName : filterField.split(',')) {
					if (jobFields.containsKey(fieldApiName.trim())) {
						Schema.DescribeFieldResult fr = jobFields.get(fieldApiName.trim()).getDescribe();

						if (fr.isCalculated()) {
							Option open = new Option('Open Jobs');
							Option closed = new Option('Closed Jobs');
							Option all = new Option('All Jobs');

							FilterList filter = new FilterList();
							filter.title = fr.getLabel();
							filter.fieldName = fr.getName();
							filter.values = new List<Option>{ all, open, closed };

							data.filter.add(filter);
						} else if (fr.getType() == Schema.DisplayType.DATE) {
							Option exSoon = new Option('Expiring Soon');
							Option ex = new Option('Expired');

							FilterList filter = new FilterList();
							filter.title = fr.getLabel();
							filter.fieldName = fr.getName();
							filter.values = new List<Option>{ exSoon, ex };

							data.filter.add(filter);
						}
					}
				}
			}
			return data;
		} catch (Exception ex) {
			throw new SObjectHelperException(ex.getMessage());
		}
	}

	public static List<Launchpad__Job__c> getFilteredJobs(List<String> uniqueFields, String accountId, String obj) {
		try {
			return new JobSearch().getFilteredJobs(uniqueFields, accountId, obj);
		} catch (Exception e) {
			throw new SObjectHelperException(e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Launchpad__Job__c> searchJobs(
		String keyword,
		Map<String, String> filterMap,
		List<String> uniqueFields,
		String filterFields,
		String accountId
	) {
		try {
			return new JobSearch().searchJobs(keyword, filterMap, uniqueFields, filterFields, accountId);
		} catch (Exception e) {
			System.debug('EXCEPTION: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new SObjectHelperException(e.getMessage());
		}
	}

	@AuraEnabled
	public static List<Skill> getJobSkills(String jobId) {
		try {
			List<Skill> skills = new List<Skill>();
			for (Launchpad__JobSkill__c js : new JobSearch().getJobSkills(jobId)) {
				skills.add(new Skill(js.Launchpad__Skill1__r.Name, js.Launchpad__Skill1__c));
			}

			return skills;
		} catch (Exception e) {
			throw new SObjectHelperException(e.getMessage());
		}
	}

	// @AuraEnabled
	// public static void deactivateJob(List<String> jobIds) {
	// 	try {
	// 		JobSearch data = new JobSearch();
	// 		data.deactivateJob(jobIds);
	// 	} catch (Exception e) {
	// 		throw new AuraHandledException(e.getMessage());
	// 	}
	// }

	public without sharing class JobSearch {
		public List<Launchpad__Job__c> getFilteredJobs(List<String> uniqueFields, String accountId, String obj) {
			// if (!SObjectHelper.canQueryObj(obj)) {
			// 	throw SObjectHelperException.queryPermissionException(obj);
			// }
			String initialQuery = 'SELECT Id, {0} FROM ' + obj + ' WHERE Launchpad__Available_in_Community__c = TRUE AND {1} ORDER BY CreatedDate DESC';
			String query = String.format(initialQuery, new List<String>{ String.join(uniqueFields, ', '), 'Launchpad__Account__c = :accountId' });

			return new List<Launchpad__Job__c>((List<Launchpad__Job__c>) Database.query(query));
		}

		public List<Launchpad__Job__c> searchJobs(
			String keyword,
			Map<String, String> filterMap,
			List<String> uniqueFields,
			String filterFields,
			String accountId
		) {
			Set<String> searchFields = new Set<String>{ 'Name' };
			Set<String> allFields = new Set<String>(uniqueFields);
			List<String> filters = new List<String>();

			Schema.DescribeSObjectResult dor = LEXCommunityHelper.getSObjSchema('Launchpad__Job__c');
			Map<String, Schema.SObjectField> jobFields = dor.fields.getMap();

			if (!(filterMap == null || filterMap.isEmpty())) {
				for (String fieldApiName : filterMap.keySet()) {
					if (jobFields.containsKey(fieldApiName.trim())) {
						Schema.DescribeFieldResult fr = jobFields.get(fieldApiName.trim()).getDescribe();

						if (fr.isCalculated()) {
							allFields.add(fr.getName());
							searchFields.add(fr.getName());
							if (filterMap.get(fr.getName()) == 'Open Jobs') {
								filters.add(fr.getName() + ' = \'Open Job\'');
							} else if (filterMap.get(fr.getName()) == 'Closed Jobs') {
								filters.add(fr.getName() + ' = \'Closed Job\'');
							}
						} else if (fr.getType() == Schema.DisplayType.DATE) {
							allFields.add(fr.getName());
							searchFields.add(fr.getName());
							if (filterMap.get(fr.getName()) == 'Expiring Soon') {
								Date today = date.today();
								filters.add(fr.getName() + ' > TODAY AND ' + fr.getName() + ' = NEXT_N_DAYS:7');
							} else if (filterMap.get(fr.getName()) == 'Expired') {
								filters.add(fr.getName() + ' < TODAY ');
							}
						}
					}
				}
			}
			uniqueFields = new List<String>(allFields);
			searchFields.addAll(uniqueFields); // ! SEARCH ALL FIELDS OR JUST NAME?
			String filter = String.join(filters, ' AND ');
			Set<Id> jobMatchedBySkillIds = new Set<Id>();

			if (keyword != '') {
				String searchQuery = 'FIND \'*' + keyword + '*\' IN ALL FIELDS RETURNING Launchpad__Skill1__c(Id, Name, Launchpad__ZID__c)';
				List<List<SObject>> sr = Search.query(searchQuery);

				if (sr != null && !sr.isEmpty()) {
					Set<Id> skillIds = new Set<Id>();
					for (Launchpad__Skill1__c matchingSkill : (List<Launchpad__Skill1__c>) sr[0]) {
						skillIds.add(matchingSkill.Id);
					}
					String skillQuery = 'SELECT Launchpad__Job__c FROM Launchpad__JobSkill__c WHERE Launchpad__Job__r.Launchpad__Available_in_Community__c = TRUE and Launchpad__Skill1__c IN :skillIds ';
					// if (!SObjectHelper.canQueryObj('Launchpad__JobSkill__c')) {
					// 	throw SObjectHelperException.queryPermissionException('Launchpad__JobSkill__c');
					// }
					for (Launchpad__JobSkill__c jobSkill : Database.query(String.escapeSingleQuotes(skillQuery))) {
						jobMatchedBySkillIds.add(jobSkill.Launchpad__Job__c);
					}
				}
			}

			String initialQuery = 'SELECT Id';
			Integer uniqueFieldsSize = uniqueFields.size();
			if (uniqueFieldsSize > 0) {
				initialQuery += ', {0} ';
			}
			initialQuery += ' FROM Launchpad__Job__c WHERE Launchpad__Available_in_Community__c = TRUE AND Launchpad__Account__c = :accountId {1} ORDER BY {2}';
			String whereClause =
				(!jobMatchedBySkillIds.isEmpty() ? ' AND Id NOT IN : jobMatchedBySkillIds ' : '') + (!String.isEmpty(filter.trim()) ? ' AND ' + filter : '');

			String query = String.format(initialQuery, new List<String>{ String.join(uniqueFields, ','), whereClause, ' CreatedDate DESC' });

			// if (!SObjectHelper.canQueryObj('Launchpad__Job__c')) {
			// 	throw SObjectHelperException.queryPermissionException('Launchpad__Job__c');
			// }
			List<Launchpad__Job__c> jobs = new List<Launchpad__Job__c>((List<Launchpad__Job__c>) Database.query(query));

			if (keyword != '' && !searchFields.isEmpty()) {
				List<Launchpad__Job__c> searchedJobs = new List<Launchpad__Job__c>();
				for (Launchpad__Job__c job : jobs) {
					Boolean found = false;
					for (String field : searchFields) {
						String value = field == 'Launchpad__Account__r.Name' ? job.Launchpad__Account__r.Name : String.valueOf(job.get(field));
						if (value != null && value.containsIgnoreCase(keyword)) {
							found = true;
							break;
						}
					}
					if (found) {
						searchedJobs.add(job);
					}
				}
				jobs = new List<Launchpad__Job__c>(searchedJobs);
			}

			if (!jobMatchedBySkillIds.isEmpty()) {
				whereClause = ' AND Id IN :jobMatchedBySkillIds' + (!String.isEmpty(filter.trim()) ? ' AND ' + filter : '');

				query = String.format(initialQuery, new List<String>{ String.join(uniqueFields, ', '), whereClause, ' CreatedDate DESC' });

				jobs.addAll((List<Launchpad__Job__c>) Database.query(query));
			}

			if (!jobs.isEmpty()) {
				query = String.format(initialQuery, new List<String>{ String.join(uniqueFields, ', '), ' AND Id IN :jobs ', 'CreatedDate DESC' });

				List<Launchpad__Job__c> searchedJobs = new List<Launchpad__Job__c>((List<Launchpad__Job__c>) Database.query(query));

				return searchedJobs;
			}

			return jobs;
		}

		public List<Launchpad__JobSkill__c> getJobSkills(String jobId) {
			// if (!SObjectHelper.canQueryObj('Launchpad__JobSkill__c')) {
			// 	throw SObjectHelperException.queryPermissionException('Launchpad__JobSkill__c');
			// }
			return [
				SELECT Id, Launchpad__Skill1__c, Launchpad__Skill1__r.Name
				FROM Launchpad__JobSkill__c
				WHERE Launchpad__Job__c = :jobId AND Launchpad__Job__r.Launchpad__Available_in_Community__c = TRUE
				ORDER BY Launchpad__Skill1__r.Name ASC
			];
		}

		// public void deactivateJob(List<String> jobIds) {
		// 	if (!SObjectHelper.canQueryObj('Launchpad__Job__c')) {
		// 		throw SObjectHelperException.queryPermissionException('Launchpad__Job__c');
		// 	}
		// 	List<Launchpad__Job__c> jobList = [
		// 		SELECT Id, Launchpad__Available_in_Community__c
		// 		FROM Launchpad__Job__c
		// 		WHERE Id IN :jobIds
		// 		WITH SECURITY_ENFORCED
		// 	];
		// 	for (Launchpad__Job__c job : jobList) {
		// 		job.Launchpad__Available_in_Community__c = false;
		// 	}
		// 	SObjectHelper.objUpdate(jobList);
		// }
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

	public class Option {
		@AuraEnabled
		public String label;

		@AuraEnabled
		public String value;

		public Option(String input) {
			this.label = input;
			this.value = input;
		}
	}

	public class FilterList {
		@AuraEnabled
		public String title;

		@AuraEnabled
		public String fieldName;

		@AuraEnabled
		public List<Option> values;
	}

	public class JobFieldSet {
		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> jobTileFields;

		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> jobViewDetailsFields;

		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> jobCreateEditFields;

		@AuraEnabled
		public Integer noOfTilesPerPage;

		@AuraEnabled
		public List<FilterList> filter;

		@AuraEnabled
		public List<String> uniqueFields;

		@AuraEnabled
		public List<Launchpad__Job__c> myJobs;

		@AuraEnabled
		public String accountId;
	}
}