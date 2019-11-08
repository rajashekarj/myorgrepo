@isTest
private class FSRevenueCentersForCustomersBatchTest{
    
    @testSetUp
    static void createTestData(){
        final User marketUser=FSTestUtil.createUser(null,1,FSConstants.systemAdmin, true);
        final FS_Market_ID__c  marketIdObject=FSTestUtil.createMarketId(marketUser,false);
        marketIdObject.FS_Market_ID_Value__c='999999';
        insert marketIdObject;
        
        //Create Account Chain,HQ and Outlet
        final Account accChain= FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        accChain.FS_Market_ID__c=marketIdObject.FS_Market_ID_Value__c;
        accChain.FS_Revenue_Center__c='no match';
        insert accChain;
        
        final Account accHQ= FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c=accChain.Id;
        accHQ.FS_Market_ID__c=marketIdObject.FS_Market_ID_Value__c;
        accHQ.FS_Revenue_Center__c='no match';
        insert accHQ;
        
        final Account accOutlet= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,false);
        accOutlet.FS_Chain__c=accChain.Id;
        accOutlet.FS_Market_ID__c=marketIdObject.FS_Market_ID_Value__c;
        accOutlet.FS_Revenue_Center__c='no match';
        insert accOutlet;
        
    }
    static testmethod void FSRevenueCentersForCustomersBatchTest(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.startTest();
            Database.executeBatch(new FSRevenueCentersForCustomersBatch(),200);
            Test.stopTest();
        }
        system.assertEquals('no match',[SELECT FS_Revenue_Center__c from Account where RecordTypeId=:FSConstants.RECORD_TYPE_CHAIN limit 1].FS_Revenue_Center__c);
        system.assertEquals('no match',[SELECT FS_Revenue_Center__c from Account where RecordTypeId=:FSConstants.RECORD_TYPE_HQ limit 1].FS_Revenue_Center__c );
        system.assertEquals('no match',[SELECT FS_Revenue_Center__c from Account where RecordTypeId=:FSConstants.RECORD_TYPE_OUTLET limit 1].FS_Revenue_Center__c );
    }
}