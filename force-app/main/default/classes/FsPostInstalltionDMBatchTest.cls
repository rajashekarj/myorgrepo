@isTest
private class FsPostInstalltionDMBatchTest {

    private static Account headquartersAcc,outletAcc,serviceProvider,serviceProvider1;
    private static FS_Execution_Plan__c executionPlan;
    private static FS_Installation__c installation;
    private static Contact spContact;
    
    private static String recTypeNewInstall=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(FSConstants.NEWINSTALLATION).getRecordTypeId() ;
   private static String recServcProvider=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Service Provider').getRecordTypeId();
    private static String recServcProvdCnt=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Service Provider').getRecordTypeId();
   
    private static Profile fetSysAdmin;
    
    private static final String TESTCONTACT ='Test Contact';
    private static final String SPNAME ='Service Provider';
    private static final String PHONENO='1023456789';
    private static final String PRIMARY='Primary';
    private static final String EMAILADDR='email@email.com';
   
    
    private static FS_Installation__c createTestData(){
        
        List<Account> insertAccounts = new List<Account>();
        //HQ Record
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        //Outlet Records
        outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
        outletAcc.ShippingPostalCode='1234';
        
        //Inserting Account Records
        serviceProvider=new Account(Name=SPNAME,RecordtypeId=recServcProvider);        
        serviceProvider1=new Account(Name=SPNAME,RecordtypeId=recServcProvider);        
        insertAccounts.add(headquartersAcc);
        insertAccounts.add(outletAcc);
        insertAccounts.add(serviceProvider);
        insertAccounts.add(serviceProvider1);
        insert insertAccounts;
        final CIF_Header__c cifHead=new CIF_Header__c(FS_HQ__c=headquartersAcc.Id);
        insert cifHead;
        insert new Disable_Trigger__c(name='FSCOMNotifications',IsActive__c=false);
        final FS_CIF__c cifRec=new FS_CIF__c(CIF_Head__c=cifHead.Id,FS_Account__c=outletAcc.Id,FS_Platform1__c='7000',FS_Platform2__c='8000',FS_Platform3__c='8000');
        insert cifRec;        
        //FET 7.0 FNF-823
        insert new Disable_Trigger__c(name='FSContactTriggerHandler',IsActive__c=false);
        //FET 7.0 FNF-823
        List<Contact> conList=new List<Contact>();
        conList.add(new Contact(AccountId=serviceProvider.Id,LastName=TESTCONTACT,RecordtypeId=recServcProvdCnt,FS_SP_Contact_Active__c=true,FS_SP_Role__c=PRIMARY,Phone=PHONENO,Email=EMAILADDR));
        conList.add(new Contact(AccountId=serviceProvider1.Id,LastName=TESTCONTACT,RecordtypeId=recServcProvdCnt,FS_SP_Contact_Active__c=true,FS_SP_Role__c=PRIMARY,Phone=PHONENO,Email=EMAILADDR));
        insert conList;
        final List<FS_SP_Aligned_Zip__c> spAlignedList=new List<FS_SP_Aligned_Zip__c>();
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=outletAcc.ShippingPostalCode,FS_Service_Provider__c=serviceProvider.id,FS_Platform_Type__c='7000'));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=outletAcc.ShippingPostalCode,FS_Service_Provider__c=serviceProvider.id,FS_Platform_Type__c='8000' ));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=outletAcc.ShippingPostalCode,FS_Service_Provider__c=serviceProvider.id,FS_Platform_Type__c='9000'));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=outletAcc.ShippingPostalCode,FS_Service_Provider__c=serviceProvider.id,FS_Platform_Type__c='9100'));
        insert spAlignedList;
       
       
        //Creating Execution Plan Record
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);
        executionPlan.FS_Platform_Type__c='7000;8000;9000;9100';
        insert executionPlan;
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        FSTestFactory.createTestDisableTriggerSetting();
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id,false);      
        installation.FS_CIF__c= cifRec.Id;
        return installation;
    }
    
     //New Relocation record with Platform Type/s Changes
    private static testmethod void testNewRemovalPlatformRec(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installation.FS_Type_of_Dispenser_Platform__c='8000;9000';
            installation.RecordTypeId=recTypeNewInstall;
            insert installation; 
            Test.startTest();
        	Database.executeBatch(new FsPostInstalltionDMBatch(),200);
        	Test.stopTest();           
        }
        system.assertEquals('8000;9000', installation.FS_Type_of_Dispenser_Platform__c);
	        
    }
}