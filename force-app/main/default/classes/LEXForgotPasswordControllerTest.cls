@isTest
private class LEXForgotPasswordControllerTest {
	@TestSetup
	static void makeData() {
		createSetupObjectRecords();
	}

	@isTest
	private static void loginMethod() {
		System.runAs(getAdminUser()) {
			try {
				User user = (User) new SObjectBuilder(User.sObjectType).put(User.Username, 'test+lex@test.com').create().getRecord();

				Boolean success = LEXForgotPasswordController.forgotPassword(user.Username);
				System.assert(success, 'Password not reset');
			} catch (Exception e) {
				System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			}
		}
	}

	@isTest
	private static void loginMethodNoUser() {
		System.runAs(getAdminUser()) {
			try {
				Boolean success = LEXForgotPasswordController.forgotPassword('test@test.com');
				System.assert(!success, 'No user should have been found');
			} catch (Exception e) {
				System.debug('Exception: ' + e.getMessage() + ' @ ' + e.getStackTraceString());
			}
		}
	}

	private static void createSetupObjectRecords() {
		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		User adminUser = new User();
		adminUser.FirstName = 'Admin ';
		adminUser.LastName = 'User';
		adminUser.Email = 'admin@example.com';
		adminUser.Username = 'Admin' + Math.random() * 100 + '@lp.com';
		adminUser.Alias = 'admin';
		adminUser.CommunityNickname = 'admin';
		adminUser.TimeZoneSidKey = 'America/Los_Angeles';
		adminUser.LocaleSidKey = 'en_US';
		adminUser.EmailEncodingKey = 'UTF-8';
		adminUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
		adminUser.LanguageLocaleKey = 'en_US';
		adminUser.IsActive = true;
		adminUser.UserRoleId = ownerRole.Id;

		insert adminUser;
	}

	private static User getAdminUser() {
		return [
			SELECT Id
			FROM User
			WHERE Profile.Name LIKE 'System Administrator' AND Email = 'admin@example.com'
			LIMIT 1
		];
	}
}