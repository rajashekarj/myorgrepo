/**************************************************************************************
Apex Class Name     : FSHomePageAlertsTest
Version             : 1.0
Function            : This test class is for  FSHomePageAlerts Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSHomePageAlertsTest {
    
    public static Map<Id,String> epRecTypMap;
    public static List<FS_Execution_Plan__c> executionPlanList;
    public static List<FS_Installation__c > ipList;
    
    public static List<FS_CIF__c> newCifApprovalLst,cifApprovalLst;
    public static FSHomePageAlerts homePage;
    @testSetup
    public static void loadTestData(){
        
        //Custom Setting for Trigger switch
        FSTestFactory.createTestDisableTriggerSetting();
        Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
        disableTriggerSetting.name='FSCOMNotifications';
        disableTriggerSetting.IsActive__c=true;
        disableTriggerSetting.Trigger_Name__c='FSCOMNotifications' ; 
        insert disableTriggerSetting;
        
        //Create Single HeadQuarter
        final List<Account> hqCustList= FSTestFactory.createTestAccount(true,1,
                                                                        FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        
        //Create Single Outlet
        final List<Account> oCustList=new List<Account>();
        for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'))){
            acc.FS_Headquarters__c=hqCustList.get(0).Id;
            oCustList.add(acc);
        }
        insert oCustList;
        
        //Create Execution Plan
        //Collection to hold all recordtype names of Execution plan                                                                       
        final Set<String> epRecTypSet=new Set<String>{'Execution Plan'};
            //Collection to hold all recordtype values of Execution plan
            epRecTypMap=new Map<Id,String>();
        
        executionPlanList=new List<FS_Execution_Plan__c>();
        //Create One executionPlan records for each record type
        for(String epRecType : epRecTypSet){
            final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,epRecType);
            epRecTypMap.put(epRecordTypeId,epRecType);
            final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(hqCustList.get(0).Id,false,1,epRecordTypeId);
            executionPlanList.addAll(epList);                                                                     
        }
        //Verify that four Execution Plan got created
        system.assertEquals(1,executionPlanList.size());      
        insert executionPlanList;
        
        final Set<String> ipRecTypSet=new Set<String>{fsconstants.NEWINSTALLATION};
        ipList=new List<FS_Installation__c >(); 
        //Create Installation for each Execution Plan according to recordtype
        final Id instRecTypId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,fsconstants.NEWINSTALLATION); 
        final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,oCustList.get(0).Id,false,1,instRecTypId);
        ipList.addAll(installList);
         
        for(FS_Installation__c installation : ipList){
            installation.FS_Ready_For_PM_Approval__c = true;
            installation.FS_Execution_Plan_Final_Approval_PM__c='Approved';
        }         
        insert ipList; 
        
        //Verify that Installation Plan got created
        system.assertEquals(1,ipList.size());   
        
        // create test outlet dispenser
        List<FS_Outlet_Dispenser__c> fsOutletDispensers = new List<FS_Outlet_Dispenser__c>();
        
        for(String  installationRecordType : ipRecTypSet){
            fsOutletDispensers = FSTestFactory.createTestOutletDispenser(ipList.get(0).Id,oCustList.get(0).Id,instRecTypId,false,4,'');
        }
        system.assertEquals(4,fsOutletDispensers.size());           
        //create test cif data
        final CIF_Header__c cifHead = new CIF_Header__c();
        insert cifHead;
        cifApprovalLst = FSTestFactory.createTestCif(oCustList,cifHead.Id,oCustList.size(),false);
        newCifApprovalLst = new List<FS_CIF__c>(); 
        for(FS_CIF__c cifIndividual : cifApprovalLst){
            cifIndividual.FS_Customer_s_disposition_after_review__c = 'Approved by Customer';
            newCifApprovalLst.add(cifIndividual);
        }        
        insert newCifApprovalLst;
        //create test task
        final List<Task> insertTaskList=new List<Task>();
        final List<Task> tasks = FSTestFactory.createTestTasks(executionPlanList.get(0).Id,false,1);        
        tasks.get(0).subject = 'EP Created';
        insertTaskList.add(tasks[0]);
        final List<Task> tasks1 = FSTestFactory.createTestTasks(ipList.get(0).Id,false,1);
        tasks1.get(0).subject = 'IP Ready for Schd';
        insertTaskList.add(tasks1[0]);
        final List<Task> tasks2 = FSTestFactory.createTestTasks(cifApprovalLst.get(0).Id,false,1);
        tasks2.get(0).subject = 'Survey Approved';
        insertTaskList.add(tasks2[0]);
        insert insertTaskList;
    }
    
    
    private static testMethod void testTasksList() {
        // TO DO: implement unit test
        final PageReference pageRef = Page.FSHomepageApprovalAlert;
        
        final User testUser = [select id from user where id=:userinfo.getUserId()];
        
        Test.setCurrentPage(pageRef);
        Test.startTest();
        System.runas(testUser) {
            homePage = new FSHomePageAlerts();
            homePage.sortDirection=' ASC';
            homePage.PageSize=10;
            homePage.PageCountPN = 10;
            homepage.PageNumberPN = 10;
            homepage.LNumberPN = 10;
            homepage.UNumberPN = 10;
            homepage.RecordCount = 10;
            homepage.RecordCountPN = 10;
            //homePage.strSRB = 'EP Created';
            homePage.tasksList();
            final Integer value=homePage.PageSize+homePage.PageCountPN+homepage.PageNumberPN+homepage.LNumberPN+homepage.UNumberPN+homepage.RecordCountPN;
            
            
            system.assertNotEquals(homepage.setlstTask.size(), 0);
        }
        Test.stopTest();
    }
    
    
    private static testMethod void testSortByCreatedDate() {
        final PageReference pageRef = Page.FSHomepageApprovalAlert;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        final User testUser = [select id from user where id=:userinfo.getUserId()];
        System.runas(testUser) {
            homePage = new FSHomePageAlerts();
            homePage.sortByCreatedDate();
        } 
        
        system.assertNotEquals(homepage.setlstTask.size(), 0);
        Test.stopTest();
    }
    private static testMethod void testSortByName() {
        final PageReference pageRef = Page.FSHomepageApprovalAlert;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        final User testUser = [select id from user where id=:userinfo.getUserId()];
        System.runas(testUser) {
            homePage = new FSHomePageAlerts();
            homePage.sortByName();
        }
        system.assertNotEquals(homepage.setlstTask.size(), 0);
        Test.stopTest();
    }
    private static testMethod void testNextPN() {
        final PageReference pageRef = Page.FSHomepageApprovalAlert;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        final User testUser = [select id from user where id=:userinfo.getUserId()];
        System.runas(testUser) {
            homePage = new FSHomePageAlerts();
            homePage.hasNextPN = true;
            homePage.pageNat = new FSPaginationCustomIterableAlerts(new List<Task>());
            if(!homePage.hasNextPN){
                homePage.nextPN();
            }
        }
        system.assertEquals(homepage.setlstTask.size(), 0);
        Test.stopTest();
    }
    private static testMethod void testFirstPN() {
        final PageReference pageRef = Page.FSHomepageApprovalAlert;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        final User testUser = [select id from user where id=:userinfo.getUserId()];
        System.runas(testUser) {
            homePage = new FSHomePageAlerts();
            homePage.hasFirstPN = true;
            homePage.pageNat = new FSPaginationCustomIterableAlerts(new List<Task>());
            if(!homePage.hasFirstPN){
                homePage.firstPN();
            }
        }
        system.assertEquals(homepage.setlstTask.size(), 0);
        Test.stopTest();
    }
    
    private static testMethod void testLastPN() {
        final PageReference pageRef = Page.FSHomepageApprovalAlert;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        final User testUser = [select id from user where id=:userinfo.getUserId()];
        System.runas(testUser) {
            homePage = new FSHomePageAlerts();
            homePage.hasPreviousPN = true;
            homePage.pageNat = new FSPaginationCustomIterableAlerts(new List<Task>());
            
            if(!homePage.hasPreviousPN){
                homePage.lastPN();
            }
        }
        system.assertEquals(homepage.setlstTask.size(), 0);
        Test.stopTest();
    } 
    
    private static testMethod void testLastPN1() {
        final PageReference pageRef = Page.FSHomepageApprovalAlert;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        final User testUser = [select id from user where id=:userinfo.getUserId()];
        System.runas(testUser) {
            homePage = new FSHomePageAlerts();
            homePage.hasLastPN = false;
            homePage.pageNat = new FSPaginationCustomIterableAlerts(new List<Task>());
            
            if(!homePage.hasLastPN){
                homePage.lastPN();
            }
        }
        system.assertEquals(homepage.setlstTask.size(), 0);
        Test.stopTest();
    }  
}