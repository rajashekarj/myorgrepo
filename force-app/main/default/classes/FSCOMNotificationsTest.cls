@isTest
public with sharing class FSCOMNotificationsTest{

	private static final String USER_EMAIL = 'amanseth7827@gmail.com';
    private static final String LOCALE = 'en_US';
    public static List<Account> outCustList;
    public static List<Account> outletCustList;
    private static testmethod void testTrigger(){
        outCustList= FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        insert outCustList;   

        	final List<User> userList = new List<User>();
        	final User user1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FS PM_P'].Id,
            LastName = 'TestCodeCOM',
            Email = USER_EMAIL,
            Username = 'test12344444343467@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = LOCALE,
            LocaleSidKey = LOCALE
            
        );
      userList.add(user1);
        final User user2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'TestCodeCOM1',
            Email = USER_EMAIL,
            Username = 'test12344444343467@test1.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title1',
            Alias = 'alias1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = LOCALE,
            LocaleSidKey = LOCALE
            
        );
        Test.startTest();
        userList.add(user2);
        insert userList;
        FS_Rush_Install_Recipient_List__c rushInstallRecipientList = new FS_Rush_Install_Recipient_List__c();
       	rushInstallRecipientList.FS_Email__c = user2.Email;
        rushInstallRecipientList.Name = 'Recipient';
        insert rushInstallRecipientList;
        
        System.runAs(userList[1]) {
            final List<AccountTeamMember__c> accTeamLst= new List<AccountTeamMember__c>();
            final AccountTeamMember__c accName1 = new AccountTeamMember__c(AccountId__c=outCustList[0].id,TeamMemberRole__c= 'COM',UserId__c=userList[1].id, FS_Email__c=USER_EMAIL);
            final AccountTeamMember__c accName2 = new AccountTeamMember__c(AccountId__c=outCustList[0].id,TeamMemberRole__c= 'Sales Team Member',UserId__c=userList[1].id, FS_Email__c=USER_EMAIL);
            accTeamLst.add(accName1);
            accTeamLst.add(accName2);
            insert accTeamLst;
                     
            
            final CIF_Header__c cheader =new CIF_Header__c(Name='FS CIF Header');
            cheader.FS_FPS__c=userList[0].Id;
            cheader.FSCOM__c=accTeamLst[0].Id;
            cheader.FS_Sales_Rep_Name__c=accTeamLst[1].Id;
            cheader.FS_Version__c = 10.02;
            cheader.FS_HQ__c=outCustList[0].id;
            insert cheader;
            
                        
            final FS_CIF__c fscif=new FS_CIF__c(Name='FS CIF'); 
            fscif.CIF_Head__c=cheader.Id;
            fscif.FS_Headquarters__c = outCustList[0].id;
            fscif.FS_Customer_s_disposition_after_review__c='On Hold';            
            fscif.FS_Reason_if_applicable__c='Test';
            fscif.FS_SA_Completed_Date__c=System.TODAY();
            fscif.FS_Second_Site_Assessment_Completed_Date__c=System.TODAY();
            fscif.FS_What_type_of_Site_Assessment__c = 'New Construction SA - Proceed w/Scheduling';
            fscif.FS_Platform1__c = '9000'; 
            insert fscif;
            
            fscif.FS_Customer_s_disposition_after_review__c='Approved by Customer';            
            fscif.FS_SA_Completed_Date__c=System.TODAY()+7;
            fscif.FS_Second_Site_Assessment_Completed_Date__c=System.TODAY()+7; 
            fscif.FS_What_type_of_Site_Assessment__c = 'Rush – New Construction SA – Proceed w/Scheduling';
            fscif.FS_Perf_Site_Assessment__c = 'Yes';
            fscif.FS_Platform1__c = '7000';
            update fscif;            
            Test.stopTest();
            System.assertEquals('Approved by Customer', fscif.FS_Customer_s_disposition_after_review__c);
            System.assertEquals(System.TODAY()+7, fscif.FS_SA_Completed_Date__c);
            System.assertEquals(System.TODAY()+7, fscif.FS_Second_Site_Assessment_Completed_Date__c);
            
        }
    }
    private static testMethod void testPopulateCIFToInstall(){
        final Id recordTypeId=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('New Install').getRecordTypeId();
        outCustList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        outletCustList=FSTestFactory.createTestAccount(false,50,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        for(Account acc:outletCustList){
            acc.FS_Headquarters__c=outCustList[0].id;
        }
        insert outletCustList;        
        final CIF_Header__c cHeader =new CIF_Header__c(Name='FS CIF Header',FS_Version__c = 1.0,FS_HQ__c=outCustList[0].id);            
        insert cHeader;        
         List<FS_CIF__c> cifLinelist=FSTestFactory.createTestCif(outletCustList,cHeader.Id,50,true);        
         List<FS_Execution_Plan__c> executionPlanLst = FSTestFactory.createTestExecutionPlan(outCustList[0].id,true,1,FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,'Execution Plan'));        
         List<FS_Installation__c> installList=FSTestFactory.createTestInstallationPlan(executionPlanLst[0].id,outletCustList[0].Id,false,50,recordTypeId);
        for(Integer i=0;i<50;i++){
            final FS_Installation__c install=installList[i];
        	install.FS_Outlet__c=outCustList[0].id;
            install.FS_CIF__C=cifLinelist[0].id;            
        }
         Test.startTest();
        insert installList;        
        final List<FS_CIF__c> listUpdateCIF=new List<FS_CIF__c>();
        for(Integer i=0;i<50;i++){
            final FS_CIF__c cif=cifLinelist[i];
        	cif.FS_Installation__c=installList[0].id;           
            cif.FS_Second_SA_Incomplete_reason__c='Test Reason';
            listUpdateCIF.add(cif);
        }
		FSCOMNotificationhandler.mapMethodCheck=false;
        update listUpdateCIF;        
         Test.stopTest();
    }
    @testSetup  
     static void mytestSetup() {
       Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
       disableTriggerSetting.name='FSCOMNotifications';
       disableTriggerSetting.IsActive__c=true;
       disableTriggerSetting.Trigger_Name__c='FSCOMNotifications' ; 
       insert disableTriggerSetting;   
      } 
}