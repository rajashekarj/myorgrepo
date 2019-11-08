@isTest
public class FSOutletAddressValidationBatchTest {
    private static Account accchain,accHQ,bottler;
    @testSetup 
    private static void testFSOutletAddressValidationBatch (){
        Test.startTest();
        final List<Account> accounts = new List<Account>();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        final Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        final Schema.RecordTypeInfo rtByName =  rtMapByName.get(Label.INTERNATIONAL_OUTLET_RECORD_TYPE);
        final string outletRecordId = rtByName.getRecordTypeId();
        
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);   
        
        // Create Headquarters
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        
        final Google_Messages__c googleMsg = new Google_Messages__c();
        googleMsg.Error_Message__c='The Outlet Address  has no matches, a minimum of City and Country is required.';
        googleMsg.Error_type__c='ZERO_RESULTS';
        googleMsg.Name='ZERO_RESULTS';
        insert googleMsg;
        
        for (integer i=0; i<50;i++){
            final Account acc = new Account();
            acc.Name='testName'+i;
            acc.FS_Shipping_City_Int__c='city';
            acc.FS_Shipping_Street_Int__c='street';
            acc.FS_Shipping_State_Province_INT__c='state';
            acc.FS_Shipping_Country_Int__c='AU';
            acc.FS_Shipping_Zip_Postal_Code_Int__c='110017';            
            acc.RecordTypeId=outletRecordId;
            acc.Bottlers_Name__c=bottler.Id;
            acc.BOE_Migrated_Outlet__c = true;
            accounts.add(acc);
        }
        
        insert accounts;
        
        
        Test.stopTest();
    }
    private static testmethod void exceptionRecords()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        
        final FSOutletAddressValidationBatch batchObj = new FSOutletAddressValidationBatch();
        Database.executeBatch(batchObj);
        
        Test.stopTest();
    }
    private static testmethod void validRecords()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        final FSOutletAddressValidationBatch batchObj = new FSOutletAddressValidationBatch();
        Database.executeBatch(batchObj);
        
        Test.stopTest();
    }
    private static testmethod void exception()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        
        final FSOutletAddressValidationBatch batchObj = new FSOutletAddressValidationBatch();
        Database.executeBatch(batchObj);
        
        Test.stopTest();
    }
}