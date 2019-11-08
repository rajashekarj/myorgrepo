/******************************************** 
Name         : FSExecutionPlanStatusIndicatorTest3
Created By   : Infosys Limited
Created Date : Sep. 19, 2017
Usage        : Unit test coverage of FSExecutionPlanStatusIndicatorExtension
************************************************/

@isTest
public class FSExecutionPlanStatusIndicatorTest3 {
    
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
    
    
    private static testmethod void testMethodScheduled20Red(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser) {          
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-31);    	
            insert exePlan;
            Test.startTest();
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,3);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals(REDCOLR, obj.colorScheduled);
        }
    }
    
    private static testmethod void testMethodScheduled20Green(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser) {
            accountId=FSEPStatusIndicatorTest_TestData.loadTestData();
            List<FS_Installation__c> installList=new List<FS_Installation__c>(); 
            idsList=new List<Id>();
            exePlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accountId[0], false);
            exePlan.FS_Execution_Start_Date__c = System.today().addDays(-23);    	
            insert exePlan;
            Test.startTest(); 
            idsList.add(exePlan.Id);
            idsList.add(accountId[1]);
            installList=FSEPStatusIndicatorTest_TestData.createInstOther(idsList,20,4);         
            insert installList;        
            obj=FSEPStatusIndicatorTest_TestData.executeMethod(exePlan);
            Test.stopTest();
            system.assertEquals(GREEN, obj.colorScheduled);
        }
    }   
}