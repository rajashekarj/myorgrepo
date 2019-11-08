/******************************************** 
Name         : FSExecutionPlanStatusIndicatorTest
Created By   : Sunil (Appiro)
Created Date : Dec. 16, 2013
Usage        : Unit test coverage of FSExecutionPlanStatusIndicatorExtension
*************************************************/
@isTest 
private class FSExecutionPlanStatusIndicatorTest {
    public static final String APPROVED='Approved';
    public static final String STORE='Store Opening';
    public static final String BLUE='blue';
    public static final String GREEN='green';
    public static final String REDCOLR='red';
    public static final String YELLOW='yellow';
    public static final String GRAY='gray';
    public static List<Id> idsList;
    public static List<Id> accountId;
   	public static FS_Execution_Plan__c exePlan;
    public static List<FS_Installation__c> installList;
    public static FSExecutionPlanStatusIndicatorExtension obj;
 
    
    private static testmethod void testMethodSAScheduledBlue(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        installList=new List<FS_Installation__c>();
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(-1);   
        Test.startTest();
        insert exePlan;    
         
        final FS_Installation__c installation3 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,exePlan.Id,accountId[1], false);
        installation3.FS_SA_Scheduled_On_Date__c = System.today().addDays(-30);
        installation3.FS_SA_Completed_Date__c = System.today().addDays(-30);
        installation3.FS_Original_Install_Date__c = System.today().addDays(-30);
        installation3.FS_Execution_Plan_Final_Approval_PM__c=APPROVED;
        installation3.FS_Rush_Install_Reason__c=STORE;
        installation3.FS_Trainer__c='Not Needed / 2nd Install';
        installList.add(installation3); 
        
        final FS_Installation__c installation4 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,exePlan.Id, accountId[1], false);
        installation4.FS_SA_Completed_Date__c = System.today().addDays(-50);
        installation4.FS_Original_Install_Date__c = System.today().addDays(-50);
        installation4.FS_Execution_Plan_Final_Approval_PM__c=APPROVED;
        installation4.FS_Rush_Install_Reason__c=STORE;
        installList.add(installation4);        
        
        final FS_Installation__c installation5 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,exePlan.Id,accountId[1], false);
        installation5.FS_SA_Scheduled_On_Date__c = System.today().addDays(-60);
        installation5.FS_Original_Install_Date__c = System.today().addDays(-60);
        installation5.FS_Execution_Plan_Final_Approval_PM__c=APPROVED;
        installation5.FS_Rush_Install_Reason__c=STORE;
        installList.add(installation5);
        
        final FS_Installation__c installation6 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,exePlan.Id,accountId[1], false);
        installation6.FS_SA_Scheduled_On_Date__c = System.today().addDays(-60);
        //installation6.FS_ReschedInstallDate7__c = System.today();
        //installation6.FS_Reason_for_Reschedule_7__c = 'HFCS not on-site';
        installation6.FS_Execution_Plan_Final_Approval_PM__c=APPROVED;
        installation6.FS_Rush_Install_Reason__c=STORE;
        installList.add(installation6);         
        
        final FS_Installation__c installation10 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,exePlan.Id,accountId[1], false);
        installation10.FS_SA_Scheduled_On_Date__c = System.today().addDays(-60);
        installation10.FS_Mail_to_Outlet_Address__c = 'Test';
        installation10.Overall_Status2__c = FSConstants.IPCOMPLETE ;
        installation10.FS_Execution_Plan_Final_Approval_PM__c=APPROVED;
        installList.add(installation10);
 		        
        insert installList;        
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        Test.stopTest();
        system.assertEquals(BLUE, obj.colorSAScheduled);
        }
    }
    
    private static testmethod void testMethodSAScheduled2Blue(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(1);    	
        Test.startTest();
        insert exePlan; 
        
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInst(idsList,2);        
        insert installList;        
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        Test.stopTest();
        system.assertEquals(BLUE, obj.colorSAScheduled);
        }
    }
    
    private static testmethod void testMethodSAScheduled20Blue(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(1); 
        Test.startTest();
        insert exePlan; 
         
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInst(idsList,20);        
        insert installList;        
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        Test.stopTest();
        system.assertEquals(BLUE, obj.colorSAScheduled);
        }
    }
    
    private static testmethod void testMethodSAScheduled2Red(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        List<FS_Installation__c> installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(-10);    
        Test.startTest();
        insert exePlan;
        
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInst(idsList,2);        
        insert installList;       
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        Test.stopTest();
        system.assertEquals(REDCOLR, obj.colorSAScheduled);
        }
    }
    
    private static testmethod void testMethodSAScheduled20Red(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        List<FS_Installation__c> installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(-10);  
        Test.startTest();
        insert exePlan;
        
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInst(idsList,20);        
        insert installList;        
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        Test.stopTest();
        system.assertEquals(REDCOLR, obj.colorSAScheduled);
        }
    } 
    
    private static testmethod void testMethodSAScheduled2Yellow(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        List<FS_Installation__c> installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(-3);    
        Test.startTest();
        insert exePlan;
        
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInst(idsList,2);        
        insert installList;        
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        Test.stopTest();
        system.assertEquals(YELLOW, obj.colorSAScheduled);
        }
    }
    
    private static testmethod void testMethodSAScheduled20Yellow(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        List<FS_Installation__c> installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(-3);    
        Test.startTest();
        insert exePlan;
        
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInst(idsList,20);        
        insert installList;        
        FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        system.assertEquals(20, [select id,name from FS_Installation__c where FS_Execution_Plan__c=:exePlan.Id].size());
        Test.stopTest();
        }
    }  
    
    private static testmethod void testMethodSAComplete20Yellow(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        List<FS_Installation__c> installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(-18);  
        Test.startTest();
        insert exePlan;
        
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInst(idsList,20);        
        insert installList;
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        Test.stopTest();
        system.assertEquals(YELLOW, obj.colorSAComplete);
        }
    }
    
    private static testmethod void testMethodSAComplete20Red(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        List<FS_Installation__c> installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(-21);    	
        insert exePlan;
        
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,0);        
        insert installList;
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        system.assertEquals(REDCOLR, obj.colorSAComplete); 
        }
    }
    
    private static testmethod void testMethodSAComplete2Yellow(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
        idsList=new List<Id>();
        List<FS_Installation__c> installList=new List<FS_Installation__c>();        
        exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
        exePlan.FS_Execution_Start_Date__c = System.today().addDays(-9);    	
        insert exePlan;
        
        idsList.add(exePlan.Id);
        idsList.add(accountId[1]);
        installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,2,0);        
        insert installList;
        obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
        system.assertEquals(YELLOW, obj.colorSAComplete);
        }
    }
    
    
}