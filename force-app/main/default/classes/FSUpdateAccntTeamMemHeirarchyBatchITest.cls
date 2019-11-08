/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class FSUpdateAccntTeamMemHeirarchyBatchITest {
  static User tuser;
  static Account HeadQuarterAcc;
  static Account outletAcc;

  static testMethod void myUnitTest() {  
  
    try{
    tuser = FSTestUtil.createUser(null,0,FSConstants.USER_POFILE_FETADMIN,true);
    }
    catch(Exception Ex){
    }

      HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);

      outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.id, true);
       // Create some test merchandise items to be deleted
       //   by the batch job.
       Temp_Chain_Account__c tempChain =new Temp_Chain_Account__c(Name=String.valueOf(HeadQuarterAcc.Id));
       insert tempChain;
       
       
       List<AccountTeamMember__c> atmList = new List<AccountTeamMember__c>();
       for (Integer i=0;i<10;i++) {
           AccountTeamMember__c member = new AccountTeamMember__c(
               AccountId__c= HeadQuarterAcc.Id,
               TeamMemberRole__c='Test Role',
               UserId__c= tuser.Id);
           atmList.add(member);
       }
       insert atmList;

        atmList = new List<AccountTeamMember__c>();
       for (Integer i=0;i<10;i++) {
           AccountTeamMember__c member = new AccountTeamMember__c(
               AccountId__c= outletAcc.Id,
               TeamMemberRole__c='Test Role',
               UserId__c= tuser.Id);
           atmList.add(member);
       }
       insert atmList;
       Test.startTest();
       FSUpdateAccountTeamMemberHeirarchyBatchI batchHierarchy = new FSUpdateAccountTeamMemberHeirarchyBatchI();
       Database.executeBatch(batchHierarchy);
       Test.stopTest();

  }
  
  static testMethod void FSUpdateAccntTeamMemHeirarchyBatchTest(){
       Test.startTest();
        String CRON_EXP = '0 0 23 * * ?';
            FSAccountTeamMemberHeirarchyScheduler  scheObj = new FSAccountTeamMemberHeirarchyScheduler();
            system.schedule('Account Team Member Sharing', CRON_EXP, scheObj);
       Test.stopTest();
    
  }
}