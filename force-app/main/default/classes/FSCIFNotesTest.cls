/**************************************************************************************
Apex Class Name     : FSCIFNotesController
Version             : 1.0
Function            : This is a test class for FSCIFNotesController Apex class code coverage
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata             02/02/2017          Original Version
*************************************************************************************/

@isTest
public class FSCIFNotesTest {
    
    @testSetup
    private  static void loadData(){
        //Creating Chain Account
        FSTestFactory.createTestDisableTriggerSetting();
        final List<Account> chainList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Chain'));
        //Create HeadQuarters  
        final List<Account> headQuarterList= FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        headQuarterList[0].FS_Chain__c = chainList[0].id;
        insert headQuarterList;
        
        //creating outlet
        final List<Account> outletLst = FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        for(Account outlet : outletLst){
            outlet.FS_Headquarters__c =  headQuarterList[0].id;
        }
        insert outletLst;
        
        //Creating Execution Plan
        final List<FS_Execution_Plan__c> executionPlanLst = FSTestFactory.createTestExecutionPlan(headQuarterList[0].id,true,1,FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,'Execution Plan'));
        
        //Creating Installation for each record types        
        final List<FS_Installation__c> installationLst = new List<FS_Installation__c>();
        
        final List<String> recordTypes = new List<String>{fsconstants.NEWINSTALLATION};
            for(String recordType : recordTypes){
                final id installationType = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,recordType);
                final List<FS_Installation__c> install = FSTestFactory.createTestInstallationPlan(executionPlanLst[0].id,outletLst[0].id,false,1,installationType); 
                installationLst.addAll(install);
            }        
        insert installationLst;  
    }
    
    private static testmethod void testInstallation(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            final FS_Execution_Plan__c executionPlan = [select id,FS_Headquarters__c from FS_Execution_Plan__c where RecordTypeId=: FSExecutionPlanValidateAndSet.epRecTypeExecutionPlan Limit 1];
            final FS_Installation__c installationPlan=[select id,FS_Execution_Plan__c,FS_Product_Information_Comments__c,FS_Outlet__c from FS_Installation__c where FS_Execution_Plan__c=:executionPlan.id Limit 1];
            installationPlan.FS_Product_Information_Comments__c = 'Test Information';
            ////Sets the current PageReference for the controller
            final Pagereference pageRef = Page.FSCIFNotes;
            Test.setCurrentPage(pageRef);
            //Add parameters to page URL
            pageRef.getParameters().put('Id', executionPlan.id);        
            
            final FSCIFNotesController cifNotes=new FSCIFNotesController();
            //Cancelling Helpful Notes Page       
            system.assertEquals(executionPlan.id, cifNotes.executionPlanId); 
            cifNotes.cancel();  
            cifNotes.edit();
            cifNotes.cancelSave();
            cifNotes.Save();
            Test.stopTest();       
        }
    }
}