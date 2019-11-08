/******************************************************************************* 
Name         : ExecutionPlanAccountTeamTest
Created By   : Shyam (JDC)
Created Date : Dec 17, 2013
Usage        : Unit test coverage of ExecutionPlanAccountTeam
*******************************************************************************/

@isTest 
private class ExecutionPlanAccountTeamTest{
    //--------------------------------------------------------------------------
    // Unit Test Method 
    //--------------------------------------------------------------------------
    static testMethod void  testUnit(){
        
        
        // Create Chain Account
        Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);        
        // Create Headquarter Account
        Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
               
        // Create Outlets
        Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet.FS_Approved_For_Execution_Plan__c = true;
        accOutlet.FS_Chain__c = accChain.Id;
        accOutlet.FS_Headquarters__c = accHQ.Id;
        accOutlet.FS_ACN__c = 'outletACN';
        insert accOutlet;
        
        
        // Create Execution Plan
        FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);
        
        AccountTeamMember__c atm = new AccountTeamMember__c(AccountId__c = accHQ.Id,
                                                            UserID__c = userinfo.getUserId());
        insert atm;
        
        Test.startTest();
        // Initialize Page paramteres
        apexpages.Standardcontroller sc = new apexpages.Standardcontroller(excPlan);
        ExecutionPlanAccountTeam obj = new ExecutionPlanAccountTeam(sc);
        system.assert(!obj.AccountTeamMembers.isEmpty());
        Test.stopTest();
    }
}