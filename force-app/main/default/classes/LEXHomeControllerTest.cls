@isTest
private class LEXHomeControllerTest {
    @isTest
    private static void laborExchangeCommunitySetupTest() {
        Labor_Exchange_Community_Setup__c setup;

        Test.startTest();
        setup = LexHomeController.laborExchangeCommunitySetup();
        Test.stopTest();

        Assert.isNotNull(setup, 'No community setup was returned.');
    }
}