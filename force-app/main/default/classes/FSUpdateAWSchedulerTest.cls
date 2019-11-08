/*************************************************************************************************** 
Name         : FSUpdateAWSchedulerTest
Created By   : J-F Ille
Created Date : June 07, 2016
Usage        : Unit test coverage of FSUpdateAWScheduler
***************************************************************************************************/
@isTest 
private class FSUpdateAWSchedulerTest{
    //------------------------------------------------------------------------------------------------
    // Unit Test Method 1
    //------------------------------------------------------------------------------------------------
    static testMethod void  testUnit(){
        // Create Chain Account
        final Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        
        //Create Headquarter Account
        final Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        
        //Create Outlet Account: Type 1
        final Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet.FS_Approved_For_Execution_Plan__c = true;
        accOutlet.FS_Chain__c = accChain.Id;
        
        accOutlet.FS_ACN__c = 'outletACN';
        insert accOutlet;
        
        final FS_Outlet_Dispenser__c outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,accOutlet.id,null,false);
        outletDispenser.FS_Migration_to_AW_Required__c = TRUE;
        outletDispenser.FS_Pending_Migration_to_AW__c= TRUE;
        outletDispenser.FS_Migration_to_AW_Complete__c = FALSE;
        outletDispenser.FS_IsActive__c = TRUE;
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.startTest(); 
            // Schedule the test job
            final String sch = '0 0 0 * * ?';
            final String jobId = System.schedule('FSUpdateAWScheduler', sch, new FSUpdateAWScheduler());
            // Get the information from the CronTrigger API object
            final CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
            // Verify the expressions are the same  
            System.assertEquals(sch,ct.CronExpression);
            
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            
            Test.stopTest();

            System.abortJob(jobId); 
        }
    }
}