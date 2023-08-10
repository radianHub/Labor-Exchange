@isTest
private class LEXWatchVideoControllerTest {
	@isTest
	private static void getEventData() {
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		System.runAs(adminUser) {
			Launchpad__Event__c event = (Launchpad__Event__c) new SObjectBuilder(Launchpad__Event__c.sObjectType)
				.put(Launchpad__Event__c.Name, 'Test Event')
				.create()
				.getRecord();

			Test.startTest();
			LEXWatchVideoController.PublicData publicData = LEXWatchVideoController.getEventData(event.Id);
			Test.stopTest();

			Assert.areEqual(event.Name, publicData.eventName, 'The correct event data was not returned');
		}
	}

	@isTest
	private static void getEventData_NoEventAccess() {
		User user = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

		System.runAs(user) {
			Id eventId;
			Exception thrownException;

			try {
				Test.startTest();
				LEXWatchVideoController.PublicData publicData = LEXWatchVideoController.getEventData(eventId);
				Test.stopTest();
			} catch (Exception ex) {
				thrownException = ex;
			}

			Assert.isNotNull(thrownException, 'An error was not thrown');
		}
	}
}