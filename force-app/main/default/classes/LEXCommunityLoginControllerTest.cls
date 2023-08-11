@isTest
private class LEXCommunityLoginControllerTest {
	@isTest
	public static void loginMethodTest() {
		try {
			String url = LEXCommunityLoginController.loginUser('test@test.com', 'test@123', null);
			System.debug(url);
		} catch (Exception e) {
			System.debug('Error occurred');
		}
	}

	@isTest
	public static void loginMethodTestWithRedirectUrl() {
		try {
			LEXCommunityLoginController.loginUser('test@test.com', 'test@123', '/launchpad/s/');
		} catch (Exception e) {
			System.debug('Error occurred');
		}
	}
}