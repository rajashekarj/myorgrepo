/*************************************************************************************************** 
Name         : InstallationRelatedContactTest
Created By   : Sunil(Appiro)
Created Date : Dec 16, 2013
Usage        : Unit test coverage of InstallationRelatedContact
***************************************************************************************************/
@isTest 
private class InstallationRelatedContactTest{
    
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
        
        //create Execution Plan Contact
        final Contact testContact=FSTestUtil.createTestContact(accOutlet.id, 'Test Contact1', false);
        testContact.FS_Execution_Plan_Role__c='Primary Contact';
        testContact.Email=null;
       	testContact.Phone=null;
        
        insert testContact;       
        
       
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
        
        Test.startTest();
        // Initialize Page paramteres
        System.currentPageReference().getParameters().put('id', installation.Id);
        final apexpages.Standardcontroller sc = new apexpages.Standardcontroller(installation);
        final InstallationRelatedContact obj = new InstallationRelatedContact(sc);
            system.assertEquals(1, obj.Con.size());

        // Verify Results
        Test.stopTest();
        }
    }
}