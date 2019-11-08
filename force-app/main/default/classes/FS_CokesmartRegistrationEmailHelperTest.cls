@isTest
private class FS_CokesmartRegistrationEmailHelperTest{
    public static Account accHeadQtr,accOutlet;
    public static Task taskObj;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN); 
    public static string emailTest='Email Test';
    
    private static void createTestData(){
        accHeadQtr = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.id,false);
    }
    
    private static testMethod void  testMethod1(){
        createTestData();
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            accOutlet.FS_Cokesmart_Registration_Email_Sent__c='';
            insert accOutlet;
            taskObj=new Task(Subject=emailTest,WhatId=accOutlet.Id);
            insert taskObj;
        }
        Test.stopTest();
        
    }
    
    private static testMethod void  testMethod2(){
        createTestData();
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            accOutlet.FS_Cokesmart_Registration_Email_Sent__c='Notification #1 sent';
            insert accOutlet;
            taskObj=new Task(Subject=emailTest,WhatId=accOutlet.Id);
            insert taskObj;
        }
        Test.stopTest();
    }
    
    private static testMethod void  testMethod3(){
        createTestData();
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            accOutlet.FS_Cokesmart_Registration_Email_Sent__c='Notification #1 and 2 sent';
            insert accOutlet;
            taskObj=new Task(Subject=emailTest,WhatId=accOutlet.Id);
            insert taskObj;
        }
        Test.stopTest();
    }
    
    private static testMethod void testDisableTrigger(){
        createTestData();
        insert new Disable_Trigger__c(name='FS_CokesmartRegistrationEmail',IsActive__c=false);
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            accOutlet.FS_Cokesmart_Registration_Email_Sent__c='';
            insert accOutlet;
            taskObj=new Task(Subject=emailTest,WhatId=accOutlet.Id);
            insert taskObj;
        }
        Test.stopTest();
    }
}