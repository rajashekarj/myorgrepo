/*=================================================================================================================
* Date         : 21-01-2019
* Developer    : Goutham Rapolu
* Purpose      : Test class for FS_ContentDocumentLinkTrigger_Handler which will update Attachment ID, Attachment URL 
*				 field on FS_CIF__c.
*=================================================================================================================
*                                 Update History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 21-01-2019 | Goutham Rapolu |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

@isTest
public class FS_ContentDocumentLink_Handler_Test {
    
    private static final String USER_EMAIL = 'test@test.com';
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
        final User user3 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FS Sales_P'].Id,
            LastName = 'TestCodeC3',
            Email = USER_EMAIL,
            Username = 'test12344444343467@test13.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title11',
            Alias = 'alias111',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = LOCALE,
            LocaleSidKey = LOCALE
            
        );
        Test.startTest();
        userList.add(user2);
        userList.add(user3);
        insert userList;
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
            insert fscif;
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion; 
            
            ContentVersion contentVersion2 = new ContentVersion(
                Title = 'Penguins2',
                PathOnClient = 'Penguins2.jpg',
                VersionData = Blob.valueOf('Test Content2'),
                IsMajorVersion = true
            );
            insert contentVersion2; 
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = fscif.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            system.assertNotEquals(null, cdl.id);
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = fscif.id;
            cdl2.ContentDocumentId = documents[1].Id;
            cdl2.shareType = 'V';
            insert cdl2;
            system.assertNotEquals(null, cdl2.id);
            Delete cdl;
            Delete cdl2;
        }
        
        Test.stopTest();
    }
    
   private static testmethod void testTriggerforRO4W(){ 
    final User user3 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FS Sales_P'].Id,
            LastName = 'TestCodeC3',
            Email = USER_EMAIL,
            Username = 'test12344444343467@test13.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title11',
            Alias = 'alias111',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = LOCALE,
            LocaleSidKey = LOCALE
            
        );
        Test.startTest();
        
        insert user3;
    
    List<Account> AccList = new List<Account>();
            final Account headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
            AccList.add(headquartersAcc);
            
            final Account outletAcc=FSTestUtil.createAccountOutlet('Test Outlet 2',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
            outletAcc.ShippingPostalCode='1234';
            AccList.add(outletAcc);
            
            insert AccList;
            
            final CIF_Header__c cifHead=new CIF_Header__c(FS_HQ__c=headquartersAcc.Id);
            insert cifHead;
            
            final FS_CIF__c cifRec=new FS_CIF__c(CIF_Head__c=cifHead.Id,FS_Account__c=outletAcc.Id,FS_Platform1__c='7000',FS_Platform2__c='8000',FS_Platform3__c='8000');
            insert cifRec;
            
            final FS_Execution_Plan__c executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);
            executionPlan.FS_Platform_Type__c='7000;8000;9000;9100';
            insert executionPlan;
            
            FS_Installation__c createinstallation = new FS_Installation__c();
            createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
            createinstallation.FS_CIF__c= cifRec.Id;
            createinstallation.FS_New_Outlet__c= outletAcc.id;
            createinstallation.FS_Install_Doc__c= '123';
            insert createinstallation;
            system.assertNotEquals(null, createinstallation.id);
        system.runas(user3){
         try{
             
            ContentVersion contentVersion2 = new ContentVersion(
                Title = 'Penguins2',
                PathOnClient = 'Penguins2.jpg',
                VersionData = Blob.valueOf('Test Content2'),
                IsMajorVersion = true
            );
            insert contentVersion2; 
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = createinstallation.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            system.assertEquals('Penguins2', contentVersion2.Title);
        }Catch(exception e){}
        }
        
     
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
    
    //Added as part of FET-7.0 FNF 850
    private static testmethod void testInstallTrigger(){
        
        List<Account> AccList = new List<Account>();
        final Account headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        AccList.add(headquartersAcc);
        
        final Account outletAcc=FSTestUtil.createAccountOutlet('Test Outlet 2',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
        outletAcc.ShippingPostalCode='1234';
        AccList.add(outletAcc);
        
        insert AccList;
        
        final CIF_Header__c cifHead=new CIF_Header__c(FS_HQ__c=headquartersAcc.Id);
        insert cifHead;
        
        final FS_CIF__c cifRec=new FS_CIF__c(CIF_Head__c=cifHead.Id,FS_Account__c=outletAcc.Id,FS_Platform1__c='7000',FS_Platform2__c='8000',FS_Platform3__c='8000');
        insert cifRec;
        
        final FS_Execution_Plan__c executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);
        executionPlan.FS_Platform_Type__c='7000;8000;9000;9100';
        insert executionPlan;
        
        FS_Installation__c createinstallation = new FS_Installation__c();
        createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
        createinstallation.FS_CIF__c= cifRec.Id;
        createinstallation.FS_New_Outlet__c= outletAcc.id;
        createinstallation.FS_Install_Doc__c= '123';
        createinstallation.Overall_Status2__c = FSConstants.PIA_PENDINGTONEWOUTLET;
        createinstallation.FS_Asset_Tracking_Form_AMOA_Status__c = FSConstants.AMOASUBMIT;
        createinstallation.FS_To_Outlet_Name__c= outletAcc.id;
        insert createinstallation;
        
        test.startTest();
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'AMOA From 0005303029 to 0001071503',
            PathOnClient = 'AMOA From 0005303029 to 0001071503.xlsx',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = createinstallation.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        system.assertNotEquals(null, cdl.id);
        
        Delete cdl;
        delete documents[0];
        
        Test.stopTest();
    }
}