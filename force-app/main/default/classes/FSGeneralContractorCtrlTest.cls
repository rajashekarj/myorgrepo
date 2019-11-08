//*********************************************************** 
//Name         : FSGeneralContractorCtrlTest
//Created By   : Shyam (JDC)
//Created Date : Dec 17, 2013
//Usage        : Unit test coverage of FSGeneralContractorCtrl
// ************************************************************

@isTest 
private class FSGeneralContractorCtrlTest{
    //--------------------------------------------------------------------------
    // Unit Test Method 
    //--------------------------------------------------------------------------
    private static testMethod void  testUnit(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            FSTestFactory.createTestDisableTriggerSetting();
            // Create Chain Account 
            final Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
            
            // Create Headquarter Account
            final Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
            
            // Create Outlets
            final Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
            accOutlet.FS_Approved_For_Execution_Plan__c = true;
            accOutlet.FS_Chain__c = accChain.Id;
            accOutlet.FS_Headquarters__c = accHQ.Id;
            accOutlet.FS_ACN__c = 'outletACN';
            insert accOutlet;
            
            
            // Create Execution Plan
            final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);
            Test.startTest();
            // Create Installation
            FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,excPlan.Id, accOutlet.Id, true);         
            
            // Initialize Page paramteres
            final apexpages.Standardcontroller standControl = new apexpages.Standardcontroller(excPlan);
            final FSGeneralContractorCtrl obj = new FSGeneralContractorCtrl(standControl);
            obj.saveOutletInfo();
            obj.selectedFillDown='All';
            obj.fillDown();
            obj.selectedFillDown='Coordination';
            obj.fillDown();
            obj.selectedFillDown='RelatedVendor';
            obj.fillDown();
            system.assertEquals(obj.lstInstallations.size(), 1);
            Test.stopTest();
        }
    }
    // Test Method for Cancel
    private static testMethod void  testCancelMethod(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            FSTestFactory.createTestDisableTriggerSetting();
            // Create Chain Account 
            final Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
            
            // Create Headquarter Account
            final Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
            
            // Create Outlets
            final Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
            accOutlet.FS_Approved_For_Execution_Plan__c = true;
            accOutlet.FS_Chain__c = accChain.Id;
            accOutlet.FS_Headquarters__c = accHQ.Id;
            accOutlet.FS_ACN__c = 'outletACN';
            insert accOutlet;
            
            
            // Create Execution Plan
            final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);
            Test.startTest();
            // Create Installation
            FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,excPlan.Id, accOutlet.Id, true);         
            
            // Initialize Page paramteres
            final apexpages.Standardcontroller standControl = new apexpages.Standardcontroller(excPlan);
            final FSGeneralContractorCtrl obj = new FSGeneralContractorCtrl(standControl);
            
            //testing cancel method
            obj.cancel();
            System.assertEquals(obj.executionPlan.Id, excPlan.Id); 
            Test.stopTest();
        }
    }
}