@isTest 
public Class FSMarketIDBatch_Test{    
    private static testMethod void testFSMarketIDBatch(){
        
        final Id recId =Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.CHAIN_RECORD_TYPE).getRecordTypeId();         
        
        final User testUser=FSTestUtil.createUser(null,1,FSConstants.systemAdmin,false);
        testUser.FirstName='Anthony';
        testUser.LastName ='Marcello';
        insert testUser;
        
        final FS_Market_ID__c testMarketId = new FS_Market_ID__c();
        testMarketId.FS_KO_ID__c = 'E62216';
        testMarketId.FS_Market_ID_Value__c = '400001';
        testMarketId.FS_User__c = testUser.Id;
        insert testMarketId;
        
        final Account acc = new Account();
        acc.Name = 'Test Account';
        acc.FS_Market_ID__c= '400001';
        acc.RecordTypeId=recId;
        insert acc;
        
        final Map<String, FS_Market_ID__c> testMarketIdToMarket = new Map<String, FS_Market_ID__c>();
        testMarketIdToMarket.put(testMarketId.FS_Market_ID_Value__c, testMarketId);
        system.runAs(testUser){
            Test.startTest();
            final FSMarketIDBatch controller = new FSMarketIDBatch(testMarketIdToMarket);
            Database.executeBatch(controller);
            Test.stopTest();
        }
    }    
}