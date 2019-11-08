/**************************************************************************************
Apex Class Name     : FSEPSendPMApprovalControllerTest
Version             : 1.0
Function            : This test class is for FSEPSendPMApprovalController Class code coverage. 
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata             06/19/2017          Original Version
*************************************************************************************/
/*Due to Organization-Wide Defaults setting for Excecution Plan Object
*we are not using @testSetup 
*since we need to run few methods with different Users*/




@isTest
public class FSEPSendPMApprovalControllerTest {
    public static List<Account> headQuarterList,outletLst;
    public static List<FS_Execution_Plan__c> executionPlanLst;
    public static List<FS_Installation__c> installationLst;    
    public static final string ID_VAL = 'Id';  
    
    private static void createTestData(){
        //Create HeadQuarters 
        FSTestFactory.createTestDisableTriggerSetting(); 
        headQuarterList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters')); 
        
        //Creating Execution Plan
        executionPlanLst = FSTestFactory.createTestExecutionPlan(headQuarterList[0].id,true,1,FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,'Execution Plan'));
        
        //creating outlet
        outletLst = FSTestFactory.createTestAccount(false,10,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        for(Account outlet : outletLst){
            outlet.FS_Headquarters__c =  headQuarterList[0].id;
        }
        insert outletLst;
        
        //Creating Installation      
        installationLst = new List<FS_Installation__c>();
        
        final id installationType = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,FSConstants.NEWINSTALLATION);
        installationLst = FSTestFactory.createTestInstallationPlan(executionPlanLst[0].id,outletLst[0].id,false,1,installationType); 
        for(FS_Installation__c installation : installationLst){
            installation.FS_Execution_Plan__c =executionPlanLst[0].id;
            installation.FS_Execution_Plan_Final_Approval_PM__c ='';
            installation.FS_Ready_For_PM_Approval__c = false;        
        }        
        insert installationLst;    
    }
    
    public static testmethod void testSendForApprovalCOM(){
        //Creating COM User
        final Profile comProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_COM);
        final User comUser = FSTestFactory.createUser(comProfile.id);
        insert ComUser;
        
        system.runAs(ComUser) {
            
            createTestData();
            test.startTest();
            executionPlanLst[0].FS_Back_up_COM__c = comUser.id;
            update executionPlanLst;
            final PageReference pageRef1=Page.FSEPSendPMApproval;
            Test.setCurrentPage(pageRef1);
            //Add parameters to page URL
            pageRef1.getParameters().put(ID_VAL,executionPlanLst[0].id);
            
            final FSEPSendPMApprovalController insApp1 = new FSEPSendPMApprovalController();
            //Selecting Installation            
            for(FSEPSendPMApprovalController.InstallWrapper wrap1: insApp1.installWrapperList) {
                wrap1.isChecked = true;                               
            }            
            insApp1.sendForApproval();
            system.assertEquals(insApp1.installWrapperList[0].installation.FS_Ready_For_PM_Approval__c,false);
            test.stopTest();       
        }       
    }
    
    public static testmethod void testSendForApprovalCOMwithPM(){
        //Creating PM User
        final Profile pmProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_PM);
        final User pmUser = FSTestFactory.createUser(pmProfile.id);
        insert pmUser;
        
        //Creating COM User
        final Profile comProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_COM);
        final User comUser = FSTestFactory.createUser(comProfile.id);
        insert ComUser;
        
        system.runAs(ComUser) {
            
            createTestData();
            test.startTest();
            executionPlanLst[0].FS_PM__c = pmUser.id;
            executionPlanLst[0].FS_Back_up_COM__c = comUser.id;
            update executionPlanLst;
            final PageReference pageRef1=Page.FSEPSendPMApproval;
            Test.setCurrentPage(pageRef1);
            //Add parameters to page URL
            pageRef1.getParameters().put(ID_VAL,executionPlanLst[0].id);
            
            final FSEPSendPMApprovalController insApp1 = new FSEPSendPMApprovalController();
            //Sending for approval without selecting any Installation
            insApp1.sendForApproval();  
            //Selecting Installation            
            for(FSEPSendPMApprovalController.InstallWrapper wrap1: insApp1.installWrapperList) {
                wrap1.isChecked = true;                
            }
            
            insApp1.sendForApproval();
            system.assertEquals(insApp1.installWrapperList[0].installation.FS_Ready_For_PM_Approval__c,true);
            test.stopTest();  
        }       
    }    
}