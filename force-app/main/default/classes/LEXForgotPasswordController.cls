public without sharing class LEXForgotPasswordController {
	@AuraEnabled(cacheable=true)
	public static Boolean forgotPassword(string username) {
		String returnMessage;
		Boolean success = false;

		flsQueryCheck('User');
		List<User> users = [SELECT Id, Username, Email FROM User WHERE Username = :username WITH SECURITY_ENFORCED LIMIT 1];
		if (users.size() == 1) {
			Site.forgotPassword(username);
			success = true;
		}
		return success;
	}

	// Further abstraction of CRUD/FLS check
	private static void flsQueryCheck(String objectApiName) {
		if (!SobjectHelper.canQueryObj(objectApiName)) {
			throw SObjectHelperException.queryPermissionException(objectApiName);
		}
	}
}