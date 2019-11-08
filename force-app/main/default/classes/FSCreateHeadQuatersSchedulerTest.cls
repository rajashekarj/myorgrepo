/*************************************************************************************************** 
Name         : FSCreateHeadQuatersSchedulerTest
Created By   : Sunil(Appiro)
Created Date : Dec 16, 2013
Usage        : Unit test coverage of FSCreateHeadQuatersScheduler
***************************************************************************************************/
@isTest 
private class FSCreateHeadQuatersSchedulerTest{
    //------------------------------------------------------------------------------------------------
    // Unit Test Method 1
    //------------------------------------------------------------------------------------------------
    static testMethod void  testUnit(){
        // Create Chain Account
        Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        
        //Create Headquarter Account
        Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        //Create Outlet Account: Type 1
        Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet.FS_Approved_For_Execution_Plan__c = true;
        accOutlet.FS_Chain__c = accChain.Id;
        
        accOutlet.FS_ACN__c = 'outletACN';
        insert accOutlet;
        
        
        //Create Outlet Account: Type 2
        Account accOutlet2 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet2.FS_Approved_For_Execution_Plan__c = true;
        accOutlet2.FS_Chain__c = accChain.Id;
        accOutlet2.FS_Headquarters__c = accHQ.Id;
        accOutlet2.FS_ACN__c = 'outletACN2';
        insert accOutlet2;
        
        
        //Create Outlet Account: Type 3
        Account accOutlet3 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet3.FS_Approved_For_Execution_Plan__c = true;
        accOutlet3.FS_Chain__c = null;
        accOutlet3.FS_Headquarters__c = null;
        accOutlet3.FS_ACN__c = 'outletACN3';
        insert accOutlet3;
        
        Test.startTest(); 
        // Schedule the test job
        String sch = '0 0 0 * * ?';
        String jobId = System.schedule('FSCreateHeadQuatersScheduler', sch, new FSCreateHeadQuatersScheduler());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same  
        System.assertEquals(sch,ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
        System.abortJob(jobId); 
        
    }  
}