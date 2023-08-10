@isTest
private class LEXForgotPasswordControllerTest {
	@isTest
	private static void loginMethodTest() {
		try {
			LEXForgotPasswordController.forgotPassword('test@test.com');
		} catch (Exception e) {
			System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
		}
	}
}