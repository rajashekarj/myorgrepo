/***************************************************************************
 Name         : FSListHeadquarterAccountsExtTest
 Created By   : Mohit Parnami
 Description  : Test class of FSListHeadquarterAccountsExt
 Created Date : Oct 18, 2013         
****************************************************************************/
@isTest 
private class FSListHeadquarterAccountsExtTest {
    
    static Account accChain;
    static testmethod void testFSListHeadquarterAccountsExt(){
        createTestData();
        Test.startTest();
            //Defining standardcontroller
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(accChain);
            FSListHeadquarterAccountsExt lstHeadQuarter = new FSListHeadquarterAccountsExt(sc);
            system.assertEquals(lstHeadQuarter.lstHeadquarterAccounts.size(), 1);
        Test.stopTest();
    }
    
    
    //--------------------------------------------------------------------------------------
    //Create Test Data For Account Update
    //--------------------------------------------------------------------------------------
    static void createTestData(){
        //Create chain
        accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        //Create Headquarter
        Account hqAcc =FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        hqAcc.FS_Chain__c = accChain.Id;
        insert hqAcc;
    }
}