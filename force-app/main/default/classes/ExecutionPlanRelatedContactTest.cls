/**************************************************************************************************
Name         : ExecutionPlanRelatedContactTest
Created By   : Sunil(Appiro)
Created Date : Dec 16, 2013
Usage        : Unit test coverage of ExecutionPlanRelatedContact
***************************************************************************************************/
@isTest 
private class ExecutionPlanRelatedContactTest{
    //------------------------------------------------------------------------------------------------
    // Unit Test Method 1
    //------------------------------------------------------------------------------------------------
    static testMethod void  testUnit(){
        
        // Create Chain Account
        final Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);   
        
        // Create Headquarter Account
        final Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        // Create Outlets
        final Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet.FS_Approved_For_Execution_Plan__c = true;
        accOutlet.FS_Chain__c = accChain.Id;
        accOutlet.FS_Headquarters__c = accHQ.Id;
        accOutlet.FS_ACN__c = 'outletACN';
        insert accOutlet;
        
        // Create Execution Plan
        final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);
        
        // Create Installation
        final FS_Installation__c installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,excPlan.Id, accOutlet.Id, true);
        
        //create Contact
        final Contact testContact1=FSTestUtil.createTestContact(accHQ.Id, 'TestContact1', false);
        testContact1.FS_Execution_Plan_Role__c='Primary Contact';
        testContact1.Title='Test Title1';
        testContact1.Phone=null;
        testContact1.FS_Alternate_Phone_Cell__c=null;
        
        insert testContact1;        
        
        final Profile adminPm = FSTestFactory.getProfileId(FSConstants.USER_POFILE_ADMINPM);
        final User adminPmUser=FSTestFactory.createUser(AdminPM.Id);
        insert adminPmUser;
        system.runAs(adminPmUser){
            
            // Initialize Page paramteres
            Test.startTest();
            System.currentPageReference().getParameters().put('id', excPlan.Id);
            final apexpages.Standardcontroller sc = new apexpages.Standardcontroller(excPlan);
            final ExecutionPlanRelatedContact obj = new ExecutionPlanRelatedContact(sc);
            
            // Verify Results
            System.assertEquals(1, obj.Contact.size());
            Test.stopTest();
        }
    }
}