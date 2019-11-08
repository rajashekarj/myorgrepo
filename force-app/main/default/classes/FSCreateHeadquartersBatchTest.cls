/*************************************************************************************************** 
Name         : FSCreateHeadquartersBatch
Usage        : Unit test coverage of FSCreateHeadquartersBatch
***************************************************************************************************/
@isTest 
private class FSCreateHeadquartersBatchTest{ 
    
    static testMethod void  Type4OutletsTest(){
        
        Account accHQ=FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_ACN__c='1111111111';
        accHQ.CCR_ACN_RecordType_Id__c='1111111111'+FSConstants.RECORD_TYPE_HQ;
        accHQ.FS_SAP_ID__c='2222222222';
        
        insert accHQ;
        
        Account accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,false);
        accOutlet.CCR_KO_Record_Type__c=55;
        accOutlet.FS_ACN__c='4444444444';
        accOutlet.FS_SAP_ID__c='5555555555';
        accOutlet.ShippingCountry = 'US';
        insert accOutlet;
        
        Test.startTest();
        Database.executeBatch(new FSCreateHeadquartersBatch());
        Test.stopTest();
    }
    
    static testMethod void  Type3OutletsTest(){
        Account accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,null,false);
        accOutlet.CCR_KO_Record_Type__c=55;
        accOutlet.FS_ACN__c='4444444444';
        accOutlet.CCR_ACN_RecordType_Id__c='4444444444'+FSConstants.RECORD_TYPE_NAME_OUTLET;
        accOutlet.FS_SAP_ID__c='5555555555';
        accOutlet.ShippingCountry = 'US';
        insert accOutlet;
        
        Test.startTest();
        Database.executeBatch(new FSCreateHeadquartersBatch());
        Test.stopTest();
    }
    
    
    static testMethod void  Type2OutletsTest(){
        Account accChain=FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        accChain.FS_ACN__c='1111111111';
        accChain.CCR_ACN_RecordType_Id__c='1111111111'+FSConstants.RECORD_TYPE_CHAIN;
        accChain.FS_SAP_ID__c='2222222222';        
        insert accChain;
        
        Account accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,null,false);
        accOutlet.CCR_KO_Record_Type__c=55;
        accOutlet.FS_Chain__c=accChain.Id;
        accOutlet.FS_ACN__c='4444444444';
        accOutlet.CCR_ACN_RecordType_Id__c='4444444444'+FSConstants.RECORD_TYPE_NAME_OUTLET;
        accOutlet.FS_SAP_ID__c='5555555555';
        accOutlet.ShippingCountry = 'US';
        insert accOutlet;
        
        Test.startTest();
        Database.executeBatch(new FSCreateHeadquartersBatch());
        Test.stopTest();
    }
    
    static testMethod void  Type1OutletsTest(){
        Account accHQ=FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_ACN__c='1111111111';
        accHQ.CCR_ACN_RecordType_Id__c='1111111111'+FSConstants.RECORD_TYPE_HQ;
        accHQ.FS_SAP_ID__c='2222222222';
        
        insert accHQ;  
        
        Account accChain=FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        accChain.FS_ACN__c='1111111111';
        accChain.CCR_ACN_RecordType_Id__c='1111111111'+FSConstants.RECORD_TYPE_CHAIN;
        accChain.FS_SAP_ID__c='2222222222';
        
        insert accChain;
        
        Account accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,false);
        accOutlet.CCR_KO_Record_Type__c=55;
        accOutlet.FS_Chain__c=accChain.Id;    
        accOutlet.FS_ACN__c='4444444444';
        accOutlet.FS_SAP_ID__c='5555555555';
        accOutlet.ShippingCountry = 'US';
        insert accOutlet;
        
        Test.startTest();
        Database.executeBatch(new FSCreateHeadquartersBatch());
        Test.stopTest();
    }   
    
}