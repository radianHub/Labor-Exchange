public without sharing class LEXForgotPasswordController {
	@AuraEnabled(cacheable=true)
	public static Boolean forgotPassword(string username) {
		String returnMessage;
		Boolean success = false;

		List<User> users = [SELECT Id, Username, Email FROM User WHERE Username = :username WITH SECURITY_ENFORCED LIMIT 1];
		if (users.size() == 1) {
			Site.forgotPassword(username);
			success = true;
		}
		return success;
	}
}