public with sharing class LEXCommunityLoginController {
	@AuraEnabled
	public static String loginUser(String username, String password, String redirectUrl) {
		String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
		String startUrl = sfdcBaseURL + '/s/';

		try {
			ApexPages.PageReference lgn = Site.login(username, password, startUrl);
			return lgn.getUrl();
		} catch (Exception e) {
			System.debug('EXCEPTION: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}
}