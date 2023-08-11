public without sharing class UserService {
	// run all permission set assignments through here
	public static void assignPermissionSets(List<User> listOfUsers) {
		assignLaborExchangePermissionSets(listOfUsers);
	}

	private static void assignLaborExchangePermissionSets(List<User> listOfUsers) {
		if (!SobjectHelper.canQueryObj('User')) {
			throw new SObjectHelperException.queryPermissionException('User');
		}

		// Id lexCommunityProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'Labor Exchange Community User' LIMIT 1].Id;
		Id lexCommunityProfileId = Labor_Exchange_Community_Setup__c.getOrgDefaults().LEX_Community_Profile_Id__c;
		Id lexCommunityPermissionSetId = Labor_Exchange_Community_Setup__c.getOrgDefaults().LEX_Community_Permission_Set_Id__c;

		Set<Id> userIds = new Set<Id>();
		for (User User : listOfUsers) {
			if (user.ProfileId == lexCommunityProfileId && lexCommunityPermissionSetId != null) {
				userIds.add(user.Id);
			}
		}

		if (userIds.size() == 0) {
			return;
		}

		try {
			assignPermissionSetToUsers(userIds, lexCommunityPermissionSetId);
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	// @future
	// // * A method used to assign a permission set to a user
	// public static void assignPermissionSetToUsers(Set<Id> userIds, String permissionSetName) {
	// 	// ! Community user will not be able to query the Permission Set object, so this will have to run in system context
	// 	// if (!SObjectHelper.canQueryObj('PermissionSet')) {
	// 	// 	throw SObjectHelperException.queryPermissionException('PermissionSet');
	// 	// }
	// 	List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
	// 	for (Id userId : userIds) {
	// 		if (!permissionSets.isEmpty()) {
	// 			PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSets[0].Id);
	// 			// ! Community user will not be able to insert the Permission Set Assignment object, so this will have to run in system context
	// 			insert psa;
	// 			System.debug('Permission set ' + permissionSetName + ' assigned to user with ID ' + userId);
	// 		} else {
	// 			System.debug('Permission set ' + permissionSetName + ' not found');
	// 		}
	// 	}
	// }

	@future
	// * A method used to assign a permission set to a user
	public static void assignPermissionSetToUsers(Set<Id> userIds, Id permissionSetId) {
		// ! Community user will not be able to query the Permission Set object, so this will have to run in system context
		// if (!SObjectHelper.canQueryObj('PermissionSet')) {
		// 	throw SObjectHelperException.queryPermissionException('PermissionSet');
		// }
		// List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
		List<PermissionSetAssignment> psaToInsert = new List<PermissionSetAssignment>();

		for (Id userId : userIds) {
			PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSetId);
			psaToInsert.add(psa);
			// ! Community user will not be able to insert the Permission Set Assignment object, so this will have to run in system context
			// if (!permissionSets.isEmpty()) {
			// 	System.debug('Permission set ' + permissionSetName + ' assigned to user with ID ' + userId);
			// } else {
			// 	System.debug('Permission set ' + permissionSetName + ' not found');
			// }
		}
		insert psaToInsert;
	}
}