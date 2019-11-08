/******************************************************************************* 
Name         : InstallationAccountTeamTest
Created By   : Shyam (JDC)
Created Date : Dec 17, 2013
Usage        : Unit test coverage of InstallationAccountTeam
*******************************************************************************/

@isTest 
private class InstallationAccountTeamTest{
    //--------------------------------------------------------------------------
    // Unit Test Method 
    //--------------------------------------------------------------------------
    static testMethod void  testUnit(){
        
        // Create Chain Account
        final Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        
        // Create Headquarter Account
        final Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        // Create Outlets
        final  Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet.FS_Approved_For_Execution_Plan__c = true;
        accOutlet.FS_Chain__c = accChain.Id;
        accOutlet.FS_Headquarters__c = accHQ.Id;
        accOutlet.FS_ACN__c = 'outletACN';
        insert accOutlet;
        
        
        // Create Execution Plan
        final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);
        
        // Create Installation
        final FS_Installation__c installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,excPlan.Id, accOutlet.Id, true);
        
        final AccountTeamMember__c atm = new AccountTeamMember__c(AccountId__c = accHQ.Id,
                                                                  UserID__c = userinfo.getUserId());
        insert atm;
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.startTest();
            // Initialize Page paramteres
            final apexpages.Standardcontroller sc = new apexpages.Standardcontroller(installation);
            final InstallationAccountTeam obj = new InstallationAccountTeam(sc);
            system.assertEquals(1, obj.AccountTeamMembers.size());
            Test.stopTest();
        }
    }
}