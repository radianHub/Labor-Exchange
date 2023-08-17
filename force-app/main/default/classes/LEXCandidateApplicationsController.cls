public with sharing class LEXCandidateApplicationsController {
	@AuraEnabled(cacheable=true)
	public static ApplicationFieldSet getSetupData() {
		try {
			// Get a map of string to field from the Launchpad__Applicant_Tracking__c object
			String objectName = 'Launchpad__Applicant_Tracking__c';
			Schema.SObjectType objDescribe = Schema.getGlobalDescribe().get(objectName);
			Schema.DescribeSObjectResult objDescribeResult = objDescribe.getDescribe();
			Map<String, Schema.SObjectField> jobFields = objDescribeResult.fields.getMap();

			// Initialize an empty list of ApplicationFieldSet
			ApplicationFieldSet data = new ApplicationFieldSet();
			Map<String, Map<String, String>> fieldsMap = new Map<String, Map<String, String>>();
			Set<String> uniqueFields = new Set<String>();

			// Get the org defaults for the Labor_Exchange_Community_Setup__c custom setting
			Labor_Exchange_Community_Setup__c lexConfigDefaults = Labor_Exchange_Community_Setup__c.getOrgDefaults();

			List<LaborExchangeCommunity_PageProperties__mdt> pageList = getCandidateApplicationsPageProperties(objectName);

			for (LaborExchangeCommunity_FieldProperties__mdt ff : getCandidateApplicationsFieldProperties(pageList)) {
				if (!fieldsMap.containsKey(ff.LaborExchangeCommunity_PageProperties__c)) {
					fieldsMap.put(ff.LaborExchangeCommunity_PageProperties__c, new Map<String, String>());
				}
				fieldsMap.get(ff.LaborExchangeCommunity_PageProperties__c).put(ff.Field_API_Name__c, ff.Field_Label__c);
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

				if (page.MasterLabel == 'Candidate Applications') {
					List<LEXCommunityHelper.FieldWrapper> fieldWrapperList = new List<LEXCommunityHelper.FieldWrapper>(fields);
					data.applicationFields = fieldWrapperList;
				}
			}

			if (!uniqueFields.isEmpty()) {
				data.applications = new LEXMyApplicationsControllerPrivileged().getMyApplications(new List<String>(uniqueFields));
			}

			data.noOfTilesPerPage = Integer.valueOf(lexConfigDefaults.of_Tiles_Per_Page__c);

			return data;
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	// @AuraEnabled
	// public static Boolean createUpdateRequestTask(String applicationId, String comments) {
	// 	try {
	// 		return new LEXMyApplicationsControllerPrivileged().createUpdateRequestTask(applicationId, comments);
	// 	} catch (Exception e) {
	// 		throw new AuraHandledException(e.getMessage());
	// 	}
	// }

	@AuraEnabled
	public static JobData getJobData(String appId) {
		try {
			return new LEXMyApplicationsControllerPrivileged().getJobData(appId);
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<DocumentData> getResumes(String applicationId) {
		try {
			return new LEXMyApplicationsControllerPrivileged().getResumes(applicationId);
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static List<LEXCommunityHelper.Option> getPicklistValues(String objName, String field) {
		try {
			Schema.DescribeFieldResult dfr = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(field).getDescribe();
			return LEXCommunityHelper.fetchPicklistValues(dfr);
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void updateApplication(String applicationJson) {
		try {
			LEXMyApplicationsControllerPrivileged appUpdate = new LEXMyApplicationsControllerPrivileged();
			appUpdate.updateApplication(applicationJson);
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void emailCandidate(Id candidateId, String emailBody) {
		new LEXMyApplicationsControllerPrivileged().emailCandidate(candidateId, emailBody);
	}

	// * CHILD CLASSES
	public without sharing class LEXMyApplicationsControllerPrivileged {
		public void emailCandidate(Id candidateId, String emailBody) {
			try {
				//get personal details for Job Seeker
				Contact toContact = [SELECT Id, Name, Email, Owner.Email FROM Contact WHERE Id = :candidateId LIMIT 1];
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
				email.setHtmlBody(emailBody);

				//log email to contact record
				email.setTargetObjectId(candidateId);
				email.setSaveAsActivity(true);

				Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
				return;
			} catch (Exception e) {
				System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
				throw new AuraHandledException(e.getMessage());
			}
		}

		public JobApplicationsData getMyApplications(List<String> uniqueFields) {
			JobApplicationsData jobApplicationData = new JobApplicationsData();

			// We need to get applications where the parent job's Launchpad__Account__c field matches the user's associated account
			// or jobs owned by the user

			List<User> lstUser = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
			String accountId = lstUser[0].Contact.AccountId;

			// ! WITH SECURITY ENFORCED IS NOT USED BECAUSE USER PERMISSION SET CANNOT GIVE READ ACCESS TO THE OBJECT, LAUNCHPAD__APPLICANT_TRACKING__C, DUE TO PACKAGING AN OBJECT WITH A M-D RELATIONSHIP
			String query = 'SELECT Id, Launchpad__Participant__c, {0} FROM Launchpad__Applicant_Tracking__c WHERE Launchpad__Job_Order__r.Launchpad__Available_in_Community__c = TRUE AND {1} ORDER BY {2} ';

			query = String.format(
				query,
				new List<String>{ String.join(uniqueFields, ', '), 'Launchpad__Job_Order__r.Launchpad__Account__c = :accountId', ' CreatedDate DESC' }
			);

			List<List<String>> listOfApplicationsStageLists = getApplicationStageListOfLists();

			for (Launchpad__Applicant_Tracking__c application : Database.query(query)) {
				if (listOfApplicationsStageLists[0].contains(application.Launchpad__Stage__c)) {
					jobApplicationData.newApplicationsData.add(application);
					jobApplicationData.newApplicationsCount++;
				} else if (listOfApplicationsStageLists[1].contains(application.Launchpad__Stage__c)) {
					jobApplicationData.pendingApplicationsData.add(application);
					jobApplicationData.pendingApplicationsCount++;
				} else if (listOfApplicationsStageLists[2].contains(application.Launchpad__Stage__c)) {
					jobApplicationData.processedApplicationsData.add(application);
					jobApplicationData.processedApplicationsCount++;
				} else {
					System.debug('Did not add application to list.');
				}
			}
			return jobApplicationData;
		}

		public JobData getJobData(String appId) {
			try {
				Set<String> uniqueFields = new Set<String>();
				JobData job = new JobData();

				List<User> lstUser = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];

				if (lstUser.size() == 0) {
					return job;
				}

				job.accountId = lstUser[0]?.Contact?.AccountId;

				List<LaborExchangeCommunity_PageProperties__mdt> pageList = getJobEditPageProperties();

				for (LaborExchangeCommunity_PageProperties__mdt page : pageList) {
					List<LEXCommunityHelper.FieldWrapper> fields = LEXCommunityHelper.getFieldsByObjectAndFieldSet('Launchpad__Job__c', page.Field_Set__c);

					for (LEXCommunityHelper.FieldWrapper fw : fields) {
						uniqueFields.add(fw.fieldApiName);
					}
					job.jobFields = new List<LEXCommunityHelper.FieldWrapper>(fields);
				}

				Id jobId = [SELECT Id, Launchpad__Job_Order__c FROM Launchpad__Applicant_Tracking__c WHERE Id = :appId].Launchpad__Job_Order__c;
				job.jobId = jobId;

				String query = 'SELECT Id';

				Integer uniqueFieldsSize = uniqueFields.size();

				if (uniqueFieldsSize > 0) {
					query += ', {0}';
				}

				query += ' FROM Launchpad__Job__c WHERE Id = :jobId ';

				if (uniqueFieldsSize > 0) {
					query = String.format(query, new List<String>{ String.join(new List<String>(uniqueFields), ', ') });
				}

				job.job = Database.query(query);
				return job;
			} catch (Exception e) {
				System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
				throw new AuraHandledException('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			}
		}

		public List<DocumentData> getResumes(String applicationId) {
			List<DocumentData> data = new List<DocumentData>();
			Set<String> docIds = new Set<String>();
			Set<Id> cdlIds = new Set<Id>();

			List<Launchpad__Document__c> docList = [
				SELECT Id, Launchpad__Type__c, Launchpad__Title__c, Name
				FROM Launchpad__Document__c
				WHERE Available_in_Community__c = TRUE AND Launchpad__Type__c = 'Resume' AND Launchpad__Job_Application__c = :applicationId
				WITH SECURITY_ENFORCED
				ORDER BY CreatedDate DESC
			];

			Map<Id, String> docMap = new Map<Id, String>();
			if (docList.size() > 0) {
				for (Launchpad__Document__c doc : docList) {
					docIds.add(doc.Id);
					docMap.put(doc.Id, doc.Launchpad__Title__c);
				}

				List<ContentDocumentLink> cdls = [
					SELECT ContentDocumentId, LinkedEntityId
					FROM ContentDocumentLink
					WHERE LinkedEntityId IN :docIds
					WITH SECURITY_ENFORCED
				];

				Map<Id, String> cdMap = new Map<Id, String>();
				for (ContentDocumentLink cdl : cdls) {
					cdlIds.add(cdl.ContentDocumentId);
					cdMap.put(cdl.ContentDocumentId, docMap.containsKey(cdl.LinkedEntityId) ? docMap.get(cdl.LinkedEntityId) : null);
				}

				List<ContentVersion> cvs = [
					SELECT ContentDocumentId, FileExtension, Title, VersionData
					FROM ContentVersion
					WHERE ContentDocumentId IN :cdlIds AND FileExtension = 'pdf'
					WITH SECURITY_ENFORCED
					ORDER BY CreatedDate DESC
					LIMIT 1
				];
				Map<Id, Map<String, String>> cvMap = new Map<Id, Map<String, String>>();
				for (ContentVersion cv : cvs) {
					cvMap.put(
						cv.ContentDocumentId,
						new Map<String, String>{
							'title' => cdMap.containsKey(cv.ContentDocumentId) ? cdMap.get(cv.ContentDocumentId) : null,
							'fileExtension' => cv.FileExtension,
							'base64' => EncodingUtil.base64encode(cv.VersionData),
							'versionId' => cv.Id
						}
					);
				}

				if (cvMap.keySet().size() > 0) {
					for (String docs : cvMap.keySet()) {
						DocumentData docData = new DocumentData();
						docData.documentId = docs;
						docData.encodedData = cvMap.get(docs).get('base64');
						docData.documentTitle = cvMap.get(docs).get('title');
						docData.fileExtension = cvMap.get(docs).get('fileExtension');
						docData.downloadUrl = '/sfc/servlet.shepherd/document/download/' + cvMap.get(docs).get('versionId');
						data.add(docData);
					}
				}
				return data;
			}
			return null;
		}

		public void updateApplication(String applicationJson) {
			Launchpad__Applicant_Tracking__c app = (Launchpad__Applicant_Tracking__c) JSON.deserialize(applicationJson, Launchpad__Applicant_Tracking__c.class);
			Database.SaveResult[] srL = Database.update(new List<Launchpad__Applicant_Tracking__c>{ app });
			for (Database.SaveResult sr : srL) {
				if (!sr.isSuccess()) {
					for (Database.Error err : sr.getErrors()) {
						throw new AuraHandledException(err.getMessage());
					}
				}
			}
		}
	}

	// * WRAPPER CLASSES
	public class ApplicationFieldSet {
		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> applicationFields;

		@AuraEnabled
		public Integer noOfTilesPerPage;

		@AuraEnabled
		public JobApplicationsData applications;
	}

	// * HELPER METHODS
	private static List<LaborExchangeCommunity_PageProperties__mdt> getCandidateApplicationsPageProperties(String objectName) {
		return [
			SELECT Id, MasterLabel, Field_Set__c
			FROM LaborExchangeCommunity_PageProperties__mdt
			WHERE Active__c = 'Yes' AND Page__c = 'Candidate Applications' AND Object_API__c = :objectName
			WITH SECURITY_ENFORCED
		];
	}
	private static List<LaborExchangeCommunity_FieldProperties__mdt> getCandidateApplicationsFieldProperties(
		List<LaborExchangeCommunity_PageProperties__mdt> pageList
	) {
		return [
			SELECT Id, Field_API_Name__c, Field_Label__c, LaborExchangeCommunity_PageProperties__c
			FROM LaborExchangeCommunity_FieldProperties__mdt
			WHERE Active__c = 'Yes' AND LaborExchangeCommunity_PageProperties__c IN :pageList
			WITH SECURITY_ENFORCED
		];
	}
	private static List<LaborExchangeCommunity_PageProperties__mdt> getJobEditPageProperties() {
		return [
			SELECT Id, MasterLabel, Field_Set__c
			FROM LaborExchangeCommunity_PageProperties__mdt
			WHERE Active__c = 'Yes' AND Page__c = 'Job Edit'
			WITH SECURITY_ENFORCED
		];
	}

	private static List<List<String>> getApplicationStageListOfLists() {
		String applicationTile1StagesString = '';
		String applicationTile2StagesString = '';
		String applicationTile3StagesString = '';

		Labor_Exchange_Community_Setup__c lexCommunitySetup = Labor_Exchange_Community_Setup__c.getInstance();
		// Store the comma separated list as provided by the Community Setup custom setting's Tile 1 Statuses field
		// ! Get default instance of the Tile 1 Status from the custom setting
		if (String.isNotEmpty(lexCommunitySetup.Applications_Tile_1_Stages__c)) {
			applicationTile1StagesString = lexCommunitySetup.Applications_Tile_1_Stages__c;
		}
		if (String.isNotEmpty(lexCommunitySetup.Applications_Tile_2_Stages__c)) {
			// Store the comma separated list as provided by the Community Setup custom setting's Tile 2 Statuses field
			// ! Get default instance of the Tile 2 Status from the custom setting
			applicationTile2StagesString = lexCommunitySetup.Applications_Tile_2_Stages__c;
		}
		if (String.isNotEmpty(lexCommunitySetup.Applications_Tile_3_Stages__c)) {
			// Store the comma separated list as provided by the Community Setup custom setting's Tile 3 Statuses field
			// ! Get default instance of the Tile 3 Status from the custom setting
			applicationTile3StagesString = lexCommunitySetup.Applications_Tile_3_Stages__c;
		}

		List<String> stringsToSplit = new List<String>{ applicationTile1StagesString, applicationTile2StagesString, applicationTile3StagesString };

		return splitStringsToListOfString(stringsToSplit);
	}

	private static List<List<String>> splitStringsToListOfString(List<String> stringsToSplit) {
		// Initialize an empty list of list of strings
		List<List<String>> listOfListOfSplitStrings = new List<List<String>>();
		for (String str : stringsToSplit) {
			// Store the split strings in a list
			List<String> splitStrings = str.split(',');

			// Set a counter
			Integer i = 0;
			// Loop through the splitStrings in each list
			for (String strng : splitStrings) {
				// Remove white space and set the final string value without white space
				splitStrings[i] = strng.normalizeSpace();
				i++;
			}
			listOfListOfSplitStrings.add(splitStrings);
		}
		return listOfListOfSplitStrings;
	}
	public class JobApplicationsData {
		@AuraEnabled
		public Integer newApplicationsCount = 0;
		@AuraEnabled
		public Integer pendingApplicationsCount = 0;
		@AuraEnabled
		public Integer processedApplicationsCount = 0;
		@AuraEnabled
		public List<Launchpad__Applicant_Tracking__c> newApplicationsData = new List<Launchpad__Applicant_Tracking__c>();
		@AuraEnabled
		public List<Launchpad__Applicant_Tracking__c> pendingApplicationsData = new List<Launchpad__Applicant_Tracking__c>();
		@AuraEnabled
		public List<Launchpad__Applicant_Tracking__c> processedApplicationsData = new List<Launchpad__Applicant_Tracking__c>();
	}

	public class JobData {
		@AuraEnabled
		public String jobId;
		@AuraEnabled
		public String accountId;
		@AuraEnabled
		public List<LEXCommunityHelper.FieldWrapper> jobFields;
		@AuraEnabled
		public Launchpad__Job__c job;
	}

	public class DocumentData {
		@AuraEnabled
		public String documentId;
		@AuraEnabled
		public String encodedData;
		@AuraEnabled
		public String documentTitle;
		@AuraEnabled
		public String fileExtension;
		@AuraEnabled
		public String downloadUrl;
	}
}