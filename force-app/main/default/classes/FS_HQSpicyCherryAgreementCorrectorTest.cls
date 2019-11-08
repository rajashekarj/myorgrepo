@isTest
private class FS_HQSpicyCherryAgreementCorrectorTest{
    static testmethod void testBatchProcess(){
        Account headQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        headQuarterAcc.FS_Spicy_Cherry_Agreement_for_this_HQ__c='Dr. Pepper/Diet Dr. Pepper';
        insert headQuarterAcc;
        
        String query='test';
        FS_HQSpicyCherryAgreementBatchCorrector c = new FS_HQSpicyCherryAgreementBatchCorrector (query);
        Database.executeBatch(c);
    }
}