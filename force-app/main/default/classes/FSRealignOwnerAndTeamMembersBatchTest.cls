/*************************************************************************************************** 
Name         : FSRealignOwnerAndTeamMembersBatchTest
Created By   : Sunil(Appiro)
Created Date : Dec 17, 2013
Usage        : Unit test coverage of FSRealignOwnerAndTeamMembersBatch 
***************************************************************************************************/
@isTest 
private class FSRealignOwnerAndTeamMembersBatchTest{
  //------------------------------------------------------------------------------------------------
  // Unit Test Method 1
  //------------------------------------------------------------------------------------------------
  static testMethod void  testUnit(){
    // Create Chain Account
    Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
    
    //Create Headquarter Account
    Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
    
    
    //Create Outlet Account
    Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
    accOutlet.FS_Approved_For_Execution_Plan__c = true;
    accOutlet.FS_Chain__c = accChain.Id;
    accOutlet.FS_Headquarters__c = accHQ.Id;
    accOutlet.FS_ACN__c = 'outletACN';
    accOutlet.FS_Market_ID__c = 'test';
    insert accOutlet;
    
    AccountTeamMember teamMember = new AccountTeamMember();
    teamMember.UserId = UserInfo.getUserId(); 
    teamMember.AccountId = accChain.Id;
    teamMember.TeamMemberRole = 'Sales Leadership';
    insert teamMember;
    
    AccountTeamMember teamMember2 = new AccountTeamMember();
    teamMember2.UserId = UserInfo.getUserId(); 
    teamMember2.AccountId = accHQ.Id;
    teamMember2.TeamMemberRole = 'COM';
    insert teamMember2;
    
    AccountTeamMember teamMember3 = new AccountTeamMember();
    teamMember3.UserId = UserInfo.getUserId(); 
    teamMember3.AccountId = accOutlet.Id;
    teamMember3.TeamMemberRole = 'COM';
    insert teamMember3;
    
    Test.startTest();
    
    Id batchprocessid = Database.executeBatch(new FSRealignOwnerAndTeamMembersBatch(), 3);
    AsyncApexJob aaj;
    try{
      aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob 
             WHERE ID =: batchprocessid];
    }
    catch(Exception e){
      // DO Nothing
    }
    
    // Verify the Job submission
    System.assert(aaj != null);             
    Test.stopTest();
    
  }
}