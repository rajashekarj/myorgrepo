/**************************************************************************************
Apex Class Name     : FSEPInstallationApprovalTest
Version             : 1.0
Function            : This test class is for FSEPInstallationApproval Class code coverage. 
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata             01/12/2017          Original Version
*************************************************************************************/
/*Due to Organization-Wide Defaults setting for Excecution Plan Object
*we are not using @testSetup 
*since we need to run few methods with different Users*/



@isTest
public class FSEPInstallationApprovalTest {
    public static List<Account> headQuarterList,outletLst;
    public static List<FS_Execution_Plan__c> executionPlanLst;
    public static List<FS_Installation__c> installationLst;   
   
    public static final string ID_VAL = 'Id';    
    public static final string FS_PIC_P='FS PIC_P';
    
    private static void createTestData()  {
        //Create HeadQuarters 
        FSTestFactory.createTestDisableTriggerSetting(); 
        headQuarterList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters')); 
        
        //Creating Execution Plan
        executionPlanLst = FSTestFactory.createTestExecutionPlan(headQuarterList[0].id,true,1,FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,'Execution Plan'));
        
        //creating outlet
        outletLst = FSTestFactory.createTestAccount(false,10,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        for(Account outlet : outletLst) {
            outlet.FS_Headquarters__c =  headQuarterList[0].id;
        }
        insert outletLst;
        
        //Creating Installation
        
        installationLst = new List<FS_Installation__c>();
        
        final id installationType = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,FSConstants.NEWINSTALLATION);
        installationLst = FSTestFactory.createTestInstallationPlan(executionPlanLst[0].id,outletLst[0].id,false,1,installationType); 
        for(FS_Installation__c installation : installationLst)  {
            installation.FS_Execution_Plan__c =executionPlanLst[0].id;
            installation.FS_Execution_Plan_Final_Approval_PM__c ='';
            installation.FS_Ready_For_PM_Approval__c = true;
        }        
        insert installationLst;    
    }
    
    
    public static testmethod void testApprovePM(){        
        //Creating PM User
        final Profile pmProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_PM);
        final User pmUser = FSTestFactory.createUser(pmProfile.id);
        insert pmUser;        
        
        //Creating COM User
        final Profile comProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_COM);
        final User comUser = FSTestFactory.createUser(comProfile.id);
        insert ComUser;
        
        
        system.runAs(pmUser) {
            
            createTestData();
            Test.startTest();
            executionPlanLst[0].FS_PM__c = pmUser.id;
            executionPlanLst[0].FS_Back_up_COM__c = comUser.id;
            update executionPlanLst;
            final PageReference pageRef1=Page.FSEPInstallationApproval;
            Test.setCurrentPage(pageRef1);
            //Add parameters to page URL
            pageRef1.getParameters().put(ID_VAL,executionPlanLst[0].id);
            
            final FSEPInstallationApproval insApp1 = new FSEPInstallationApproval();
            //Selecting Installation
            
            for(FSEPInstallationApproval.InstallWrapper wrap1: insApp1.installWrapperList) {
                wrap1.isChecked = true;                
            }
            
            insApp1.approveInstallationPM(); 
            system.assert(insApp1.installWrapperList[0].isChecked && insApp1.installWrapperList[0].installation.FS_Execution_Plan__r.FS_PIC__c == null, 'PIC should not be blank for approving installation');
            Test.stopTest();
        }
    }
    
    public static testmethod void testApprovePMwithPIC(){   
        //Creating PIC User
        final Profile picProfile = FSTestFactory.getProfileId(FS_PIC_P);
        final User picUser = FSTestFactory.createUser(picProfile.id);
        insert picUser; 
        
        //Creating PM User
        final Profile pmProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_PM);
        final User pmUser = FSTestFactory.createUser(pmProfile.id);
        insert pmUser;        
        
        //Creating COM User
        final Profile comProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_COM);
        final User comUser = FSTestFactory.createUser(comProfile.id);
        insert ComUser;
        
        
        system.runAs(pmUser) {
            
            createTestData();
            Test.startTest();
            executionPlanLst[0].FS_PIC__c = picUser.id;
            executionPlanLst[0].FS_PM__c = pmUser.id;
            executionPlanLst[0].FS_Back_up_COM__c = comUser.id;
            update executionPlanLst;
            
            final PageReference pageRef1=Page.FSEPInstallationApproval;
            Test.setCurrentPage(pageRef1);
            //Add parameters to page URL
            pageRef1.getParameters().put(ID_VAL,executionPlanLst[0].id);
            
            final FSEPInstallationApproval insApp1 = new FSEPInstallationApproval();
            //Click on Approve without selecting Installation
            insApp1.approveInstallationPM();
            //Selecting Installation
            
            for(FSEPInstallationApproval.InstallWrapper wrap1: insApp1.installWrapperList){
                wrap1.isChecked = true;                
            }
            
            insApp1.approveInstallationPM(); 
            system.assertEquals(insApp1.installWrapperList[0].installation.FS_Execution_Plan_Final_Approval_PM__c,'Approved');
            Test.stopTest();
        }
    }
    public static testmethod void testRejectPM(){        
        //Creating PM User
        final Profile pmProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_PM);
        final User pmUser = FSTestFactory.createUser(pmProfile.id);
        insert pmUser;        
        
        system.runAs(pmUser) {
            
            createTestData();
             Test.startTest();
            executionPlanLst[0].FS_PM__c = pmUser.id;
            //executionPlanLst[0].FS_Back_up_COM__c = comUser.id;
            update executionPlanLst;
            final PageReference pageRef1=Page.FSEPInstallationApproval;
            Test.setCurrentPage(pageRef1);
            //Add parameters to page URL
            pageRef1.getParameters().put(ID_VAL,executionPlanLst[0].id);
            
            final FSEPInstallationApproval insApp1 = new FSEPInstallationApproval();
            //Click on Reject without selecting Installation
            insApp1.rejectInstallationPM();
            //Selecting Installation
            
            for(FSEPInstallationApproval.InstallWrapper wrap1: insApp1.installWrapperList) {
                wrap1.isChecked = true;                
            }
           
            insApp1.rejectInstallationPM();
            system.assert(insApp1.installWrapperList[0].isChecked && insApp1.installWrapperList[0].installation.FS_Execution_Plan__r.FS_Back_up_COM__c == null, 'COM should not be blank for rejecting installation');
            Test.stopTest();
        }
    }
    
    public static testmethod void testRejectPMwithBackupCOM(){        
        //Creating PM User
        final Profile pmProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_PM);
        final User pmUser = FSTestFactory.createUser(pmProfile.id);
        insert pmUser;        
        
        //Creating COM User
        final Profile comProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_COM);
        final User comUser = FSTestFactory.createUser(comProfile.id);
        insert ComUser;
        
        
        system.runAs(pmUser) {
            
            createTestData();
            Test.startTest();
            installationLst[0].FS_Approval_request_submitted_by__c=comUser.id;
            update installationLst;
            
            executionPlanLst[0].FS_PM__c = pmUser.id;
            executionPlanLst[0].FS_Back_up_COM__c = comUser.id;
            update executionPlanLst;
            final PageReference pageRef1=Page.FSEPInstallationApproval;
            Test.setCurrentPage(pageRef1);
            //Add parameters to page URL
            pageRef1.getParameters().put(ID_VAL,executionPlanLst[0].id);
            
            final FSEPInstallationApproval insApp1 = new FSEPInstallationApproval();
            //Selecting Installation
            
            for(FSEPInstallationApproval.InstallWrapper wrap1: insApp1.installWrapperList){
                wrap1.isChecked = true;
                wrap1.installation.FS_Reason_for_Installation_Rejection__c = 'Rejected';
                wrap1.installation.FS_Approval_request_submitted_by__c=comUser.id;                
            }
            
            insApp1.rejectInstallationPM();
            system.assertEquals(insApp1.installWrapperList[0].installation.FS_Execution_Plan_Final_Approval_PM__c,'Rejected');
            Test.stopTest();
        }
    }
    
    public static testmethod void testRejectPMwithoutReason(){        
        //Creating PM User
        final Profile pmProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_PM);
        final User pmUser = FSTestFactory.createUser(pmProfile.id);
        insert pmUser;        
        
        //Creating COM User
        final Profile comProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_COM);
        final User comUser = FSTestFactory.createUser(comProfile.id);
        insert ComUser;
        
        
        system.runAs(pmUser) {
            
            createTestData();
            Test.startTest();
            executionPlanLst[0].FS_PM__c = pmUser.id;
            executionPlanLst[0].FS_Back_up_COM__c = comUser.id;
            update executionPlanLst;
            final PageReference pageRef1=Page.FSEPInstallationApproval;
            Test.setCurrentPage(pageRef1);
            //Add parameters to page URL
            pageRef1.getParameters().put(ID_VAL,executionPlanLst[0].id);
            
            final FSEPInstallationApproval insApp1 = new FSEPInstallationApproval();
            //Selecting Installation
            
            for(FSEPInstallationApproval.InstallWrapper wrap1: insApp1.installWrapperList){                
                wrap1.isChecked = true;                
            }
            
            insApp1.rejectInstallationPM();
            system.assert(insApp1.installWrapperList[0].isChecked && insApp1.installWrapperList[0].installation.FS_Reason_for_Installation_Rejection__c == null, 'Reason for rejection should not be blank');            
            Test.stopTest();
        }
    }
}