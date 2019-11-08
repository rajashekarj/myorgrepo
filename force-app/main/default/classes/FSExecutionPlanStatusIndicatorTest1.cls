/******************************************** 
Name         : FSExecutionPlanStatusIndicatorTest1https://freestyle--fet7dev.cs21.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
Created By   : Infosys Limited
Created Date : Sep. 19, 2017
Usage        : Unit test coverage of FSExecutionPlanStatusIndicatorExtension
************************************************/

@isTest
public class FSExecutionPlanStatusIndicatorTest1 {
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
    
    private static testmethod void testMethodSAComplete2Blue(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser) {
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData(); 
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(3);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,2,0);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals(BLUE, obj.colorSAComplete);
        }
    }
    
    private static testmethod void testMethodComplete2Red(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData(); 
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-13);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,2,0);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals(REDCOLR, obj.colorSAComplete);
        }
    }
    
    private static testmethod void testMethodComplete2Gray(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData(); 
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-3);    	
            insert exePlan;
            
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,2,1);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals('gray', obj.colorSAComplete);
        }
    }
    
    private static testmethod void testMethodSAComplete20Gray(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(3);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,0);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals('gray', obj.colorSAComplete);
        }
    }
    
    private static testmethod void testMethodComplete2Green(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-6);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,2,2);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals(GREEN, obj.colorSAComplete);
        }
    }
    
    private static testmethod void testMethodComplete20Green(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-6);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,2);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals(GREEN, obj.colorSAComplete);
        }
    }
    
    private static testmethod void testMethodComplete20Red(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-21);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,0);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals(REDCOLR, obj.colorSAComplete);
        }
    }
    
    private static testmethod void testMethodApproved20Blue(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-20);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,2);         
            insert installList;        
            FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            system.assertEquals(20, [select id,name from FS_Installation__c where FS_Execution_Plan__c=:exePlan.Id].size());
            Test.stopTest();
        } 
    }
    
    private static testmethod void testMethodApproved20Yellow(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-25);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,2);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals(YELLOW, obj.colorEPApproved);
        }
    }
    
    private static testmethod void testMethodApproved20RED(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-24);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,2);         
            insert installList;        
            FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            system.assertEquals(20, [select id,name from FS_Installation__c where FS_Execution_Plan__c=:exePlan.Id].size());
            Test.stopTest();
        }
    }
    
}