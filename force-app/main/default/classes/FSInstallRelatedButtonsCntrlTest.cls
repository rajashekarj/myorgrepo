/******************************************************************************* 
Name         : FSInstallationRelatedButtonsController
Created By   : Infosys Limited
Created Date : Feb 05, 2019
Usage        : Unit test coverage of FSInstallationRelatedButtonsController
*******************************************************************************/

@isTest 
private class FSInstallRelatedButtonsCntrlTest{
    //--------------------------------------------------------------------------
    // Unit Test Method 
    //--------------------------------------------------------------------------
    static testMethod void  testUnit(){
          
        // Create Headquarter Account
        Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        //Create Custom Setting
        Dummy_Execution_Plan_del__c expname=new Dummy_Execution_Plan_del__c();
        expname.ExecutionPlan_Name__c='abcd';
        insert expname;
        // Create Execution Plan
        FS_Execution_Plan__c excPlan =  FSTestUtil.createExecutionPlan('Execution Plan',accHQ.Id, false);
        excPlan.FS_Platform_Type__c='7000;8000';  
        excPlan.Name='abcd';     
        insert excPlan;
        Test.startTest();
        FSInstallationRelatedButtonsController.getEpId();
        System.assertEquals(expname.ExecutionPlan_Name__c, excPlan.Name);
        FSInstallationRelatedButtonsController.getProfileAccess();
        Test.stopTest();
    }
}