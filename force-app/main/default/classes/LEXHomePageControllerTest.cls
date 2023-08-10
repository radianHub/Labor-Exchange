@isTest
private class LEXHomePageControllerTest {
	@isTest
	private static void testHomePageTileInfoReturnJobSeekerCommunityData() {
		List<LaborExchangeCommunity_HomePage__mdt> metaList = LEXHomePageController.getHomePageTileInfo();
		system.assert(metaList.size() > 0, 'Home tiles missing');
	}
    
    @isTest
	private static void testHomePageTileInfoReturnJobSeekerCommunityData_NoHomePageAccess() {
		User user = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

		System.runAs(user) {
			Exception thrownException;

			try {
				Test.startTest();
				List<LaborExchangeCommunity_HomePage__mdt> homePage = LEXHomePageController.getHomePageTileInfo();
				Test.stopTest();
			} catch (Exception ex) {
				thrownException = ex;
			}

			Assert.isNotNull(thrownException, 'An error was not thrown');
		}
	}
}