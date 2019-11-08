/***************************************************************************
 Name         : FSAccountTeamMemberOutletsBatchTest
 Created By   : Infosys
 Description  : Test class for FSAccountTeamMemberOutletsBatch
 Created Date : May 24, 2017 
****************************************************************************/

@isTest
public class FSAccountTeamMemberOutletsBatchTest {
    private static Account accChain, accHeadQtr1, accOutlet1;
    private static User user;
    
    private static void createTestData(){
        FSTestFactory.createTestDisableTriggerSetting();
        final List<Account> lstHQAccToInsert = new List<Account>();
        final List<Account> lstOAccToInsert = new List<Account>();
        
        user = FSTestUtil.createUser(null,0,FSConstants.systemAdmin, true);
        
        //Create Chain Account
        accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        
        //Create Headquarter Account
        accHeadQtr1 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHeadQtr1.FS_Chain__c = accChain.Id;
        lstHQAccToInsert.add(accHeadQtr1);
        
        insert lstHQAccToInsert;
        
        //Create Outlet Account
        accOutlet1 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr1.Id, false);
        lstOAccToInsert.add(accOutlet1);        
        
        insert lstOAccToInsert;      
    }
    //Test Method
    private static testMethod void  copyAccountMembersOnOutletLookupsTest(){
        createTestData();
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest(); 
            //To Test on HQ Account Team member
            final AccountTeamMember__c hqATM = new AccountTeamMember__c(AccountId__c = accHeadQtr1.Id, UserId__c = user.Id, TeamMemberRole__c = 'COM');
            insert hqATM;
            final List<AccountTeamMember__c> listteam = new List<AccountTeamMember__c>();
            listteam.add(hqATM);
            final ID jobId = Database.executeBatch(new FSAccountTeamMemberOutletsBatch(listteam), 2000); 
            
            test.stopTest();
            final List<AccountTeamMember__c> teamMembers = [SELECT Id from AccountTeamMember__c];
            System.assert(teamMembers.size()>1);
        }
    }
    
}