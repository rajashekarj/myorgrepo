/*********************************************************************************************************
Name         : FSAccountTeamMemberTriggerHandlerTest
Created By   : Mohit Parnami (Appiro)
Created Date : 11 - Nov - 2013
Usage        : Unit test coverage of FSAccountTeamMemberTriggerHandler
***********************************************************************************************************/
@isTest
private class FSAccountTeamMemberTriggerHandlerTest {
    
    private static Account accChain, accHeadQtr1, accHeadQtr2, accOutlet1, accOutlet2;
    private static User user,user2;
    private static string comRole = 'COM';
    private static List<Account> lstHQAccToInsert;
    private static List<Account> lstOutletAccToInsert;
    private static List<AccountTeamMember__c> accTeamList;
    /**
	* @MethodName - testAccountTeamMemberTriggerHandler()
	* @Description - Used to test chain account's share records functionality
	* @Story/Task - S-274864/T-367311
	*/
    private static testMethod void  testAccountTeamMemberTriggerHandler(){
        createTestData();
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        
        system.runAs(sysAdminUser){
            Test.startTest();
            //to Test on Chain Account
            final Integer iPreCount = [select count() from AccountTeamMember__c];
            final AccountTeamMember__c cusChainATM = new AccountTeamMember__c(AccountId__c = accHeadQtr1.Id, UserId__c = user.Id, TeamMemberRole__c = comRole);
            insert cusChainATM;
            System.assertEquals([select Count() From AccountTeamMember__c Where AccountId__c =: accHeadQtr1.Id], iPreCount + 1);
            try{
                delete cusChainATM;
            }
            catch(DMLException e){
                ApexPages.addMessages(e);
                
            }
            Test.stopTest();
        }
    }
    
    private static testMethod void  testAccountTeamMemberTriggerHandlerDelete(){
        createTestData();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
        Test.startTest();
        //to Test on Chain Account
        final AccountTeamMember__c cusChainATM = new AccountTeamMember__c(AccountId__c = accChain.Id, UserId__c = user.Id, TeamMemberRole__c = comRole);
        insert cusChainATM;
        cusChainATM.TeamMemberRole__c  = 'Sales Team Member';
        update cusChainATM;
        try{
            delete cusChainATM;
        }
        catch(DMLException e){
            ApexPages.addMessages(e);
            
        }
        final AccountTeamMember__c checkATM;
            try {
            	checkATM = [select id from AccountTeamMember__c where UserId__c =: user.Id];
            }
            catch (exception e){
                system.assertEquals(checkATM, null);
            }
        Test.stopTest();
        }
    } 
    
    private static void createTestData(){
        FSTestFactory.createTestDisableTriggerSetting();
        final List<User> userList=new List<User>();
        lstHQAccToInsert = new List<Account>();
        lstOutletAccToInsert = new List<Account>();
        
        user = FSTestUtil.createUser(null,0,FSConstants.systemAdmin, false);
        
        user2 = FSTestUtil.createUser(null,1,FSConstants.systemAdmin, false);
        userList.add(user);
        userList.add(user2);
        insert userList;

        //Create Chain Account
        accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        
        //Create Headquarter Account
        accHeadQtr1 = FSTestUtil.createTestAccount('Test Headquarters1',FSConstants.RECORD_TYPE_HQ,false);
        accHeadQtr1.FS_Chain__c = accChain.Id;
        lstHQAccToInsert.add(accHeadQtr1);
        //Create Headquarter Account
        accHeadQtr2 = FSTestUtil.createTestAccount('Test Headquarters2',FSConstants.RECORD_TYPE_HQ,false);
        accHeadQtr2.FS_Chain__c = accChain.Id;
        lstHQAccToInsert.add(accHeadQtr2);
        insert lstHQAccToInsert;
        
        //Create Outlet Account
        accOutlet1 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr1.Id, false);
        lstOutletAccToInsert.add(accOutlet1);
        //Create Outlet Account
        accOutlet2 = FSTestUtil.createAccountOutlet('Test Outlet 2',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr1.Id, false);
        lstOutletAccToInsert.add(accOutlet2);
        insert lstOutletAccToInsert;
        
        
    }
    //Test Method
    private static testMethod void  copyAccountMembersOnOutletLookupsTest(){
        createTestData();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
        Test.startTest();
        //to Test on Chain Account
        final AccountTeamMember__c cusChainATM = new AccountTeamMember__c(AccountId__c = accChain.Id, UserId__c = user.Id, TeamMemberRole__c = comRole);
        insert cusChainATM;
        
        system.assertEquals([SELECT Id, FS_COM__c FROM Account WHERE ID =: accChain.Id].FS_COM__c, user.Id);
        cusChainATM.TeamMemberRole__c = 'PIC';
        FSConstants.BypassupdateAccountTeamMember = false;
        update cusChainATM;
        
        system.assertEquals([SELECT FS_PIC__c FROM Account WHERE ID =: accChain.Id].FS_PIC__c, user.Id);
        test.stopTest();
        }
        
    }
    @testSetup  
    private static void mytestSetup() {
        final Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
        
        disableTriggerSetting.name='FSAccountTeamMemberTriggerHandler';
        disableTriggerSetting.IsActive__c=true;
        disableTriggerSetting.Trigger_Name__c='FSAccountTeamMemberTrigger' ; 
        insert disableTriggerSetting;   
    } 
    
    private static testMethod void  testAccountTeamMemberTriggerHandlerDelete1(){
        createTestData();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        
        system.runAs(sysAdminUser){        
            Test.startTest();
            //to Test on Chain Account
            final Integer iPreCount = [select count() from AccountTeamMember__c];
            final AccountTeamMember__c cusChainATM = new AccountTeamMember__c(AccountId__c = accHeadQtr1.Id, UserId__c = user.Id, TeamMemberRole__c = comRole);
            insert cusChainATM;
            System.assertEquals([select Count() From AccountTeamMember__c Where AccountId__c =: accHeadQtr1.Id], iPreCount + 1);
            try{
                delete cusChainATM;
            }
            catch(DMLException e){
                ApexPages.addMessages(e);
                
            }
            Test.stopTest();
        }
    } 
    
    //Test Method
    private static testMethod void  copyAccountMembersOnHQTest(){
        createTestData();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        
        system.runAs(sysAdminUser){
            Test.startTest();
            accTeamList = new List<AccountTeamMember__c>();
            //to Test on Chain Account
            AccountTeamMember__c cusChainATM = new AccountTeamMember__c(AccountId__c = accChain.Id, UserId__c = user.Id, TeamMemberRole__c = comRole);        
            
            accTeamList.add(cusChainATM);
            cusChainATM = new AccountTeamMember__c(AccountId__c = accHeadQtr1.Id, UserId__c = user.Id, TeamMemberRole__c = comRole);
            accTeamList.add(cusChainATM);
            cusChainATM = new AccountTeamMember__c(AccountId__c = accHeadQtr1.Id, UserId__c = user2.Id, TeamMemberRole__c = comRole);
            accTeamList.add(cusChainATM);
            insert accTeamList;
            
            cusChainATM.TeamMemberRole__c = 'PIC';
            FSConstants.BypassupdateAccountTeamMember = false;
            update cusChainATM;
            
            system.assertEquals([SELECT FS_COM__c FROM Account WHERE ID =: accChain.Id].FS_COM__c, user.Id);
            test.stopTest();
        } 
    }
}