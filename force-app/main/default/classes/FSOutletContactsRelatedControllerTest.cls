/*********************************************************************************************************
Name         : FSOutletContactsRelatedControllerTest
Created By   : Infosys Limited 
Created Date : 4-feb-2019
Usage        : Test Class for FSOutletContactsRelatedController

***********************************************************************************************************/
@isTest
private class FSOutletContactsRelatedControllerTest
{
    @isTest
      static void testUnit(){
        
        
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
        test.startTest();
        FSOutletContactsRelatedController.getPhone(accOutlet.id);
        FSOutletContactsRelatedController.getHqId(accHQ.id);
        FSOutletContactsRelatedController.getProfileAccess();
        test.stopTest();
  }      
}