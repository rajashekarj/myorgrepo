/*************************************************************************************
Apex Class Name     : FSCopyEPEPToInstallationsTest
Version             : 1.0
Function            : This test class is for FSCopyEPEPToInstallationsSearchExtension Class code coverage. 
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkat    FET4.0        	11/23/2016          Original Version
* Venkat	FET5.0 			01/05/2018			Updated Version
************************************************************************************/

@isTest
private class FSCopyEPEPToInstallationsTest {    
    
    public static final string IDVAL = 'Id';
    public static final String PLATFORM='7000;8000;9000';
    public static final String APPROVED='Approved';
    public static User adminUser;
    @testSetup
    public  static void loadTestData(){        
        //Create HeadQuarters
        FSTestFactory.createTestDisableTriggerSetting();
        
        final List<Account> headQuarterList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,FSConstants.RECORD_TYPE_NAME_HQ));
        
        //Creating Execution Plan
        final List<FS_Execution_Plan__c> executionPlanLst = FSTestFactory.createTestExecutionPlan(headQuarterList[0].id,false,5,FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,FSConstants.EXECUTIONPLAN));
        for(FS_Execution_Plan__c exePlan :executionPlanLst ){
            exePlan.FS_Platform_Type__c = PLATFORM;
        }
        insert executionPlanLst;
        //creating outlet
        final List<Account> outletLst = FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,FSConstants.RECORD_TYPE_NAME_OUTLET));
        for(Account outlet : outletLst){
            outlet.FS_Headquarters__c =  headQuarterList[0].id;
        }
        insert outletLst;
                                                           
        //FET 5.0 regular Installation default record type "New Install"        
        //creating installation
        final List<FS_Installation__c> installList = FSTestFactory.createTestInstallationPlan(executionPlanLst[0].id,outletLst[0].id,false,1,FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,FSConstants.NEWINSTALLATION)); 
        for(FS_Installation__c install:installList){
            install.Type_of_Dispenser_Platform__c=PLATFORM;
        }      
        insert installList; 
        //FET 5.0 regular Installation default record type "New Install"
    } 
   
    
    private static testmethod void selectOutletTest() { 
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){            
            Test.startTest();
            final List<FS_EP_Equipment_Package__c> executionPkge = [Select id,FS_Platform_Type__c,FS_Execution_Plan__c from FS_EP_Equipment_Package__c Limit 1]; 
            final PageReference pageRef=Page.FSCopyEPEPToInstallationsSearch;
            //Sets the current PageReference for the controller
            Test.setCurrentPage(pageRef);
            //Add parameters to page URL
            pageRef.getParameters().put(IDVAL,executionPkge[0].id);
            final ApexPages.StandardController stdcon = new ApexPages.standardController(executionPkge[0]);            
            final FSCopyEPEPToInstallationsSearchExtension controller= new FSCopyEPEPToInstallationsSearchExtension(stdcon);
            controller.first();
            
            //Searching Outlet
            controller.searchOutletName = 'aaa';
            controller.searchOutlet();
            system.assertEquals(controller.wrapperRecordList.size(),0);
            Test.stopTest();          
        }
           
    }
    private static testmethod void createEPIPCopy() {        
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        
        system.runAs(adminUser){
            Test.startTest();     
            final FS_EP_Equipment_Package__c executionPkge = [Select id,FS_Execution_Plan__c from FS_EP_Equipment_Package__c Limit 1];
            //Sets the current PageReference for the controller
            final PageReference pageRef=Page.FSCopyEPEPToInstallationsSearch;
            Test.setCurrentPage(pageRef);
            //Add parameters to page URL
            pageRef.getParameters().put(IDVAL,executionPkge.id);
            final ApexPages.StandardController stdcon = new ApexPages.standardController(executionPkge);        
            
            final FSCopyEPEPToInstallationsSearchExtension controller = new FSCopyEPEPToInstallationsSearchExtension(stdcon);
            
            controller.next();
            controller.previous();
            controller.first();
            controller.last();
            //Clicking Copy to Installation without selecting installations
            controller.createEPIP();
            
            //Selecting Installtion
            for(FSCopyEPEPToInstallationsSearchExtension.WrapperClass wrap: controller.wrapperRecordList) {
                wrap.isSelected = true;
                wrap.installation.FS_Execution_Plan_Final_Approval_PM__c =APPROVED;
            }
            
            controller.createEPIP();
            
            //Pagination
            final Integer pageNumber = controller.pageNumber;
            system.assertEquals(1,pageNumber);
            final Integer totalPages = controller.getTotalPages();
            system.assertEquals(1,totalPages);
            final Integer noOfRecords = controller.noOfRecords;
            system.assertEquals(1,noOfRecords);        
            final Boolean hasPrevious = controller.hasPrevious;
            system.assertEquals(false,hasPrevious);
            final Boolean hasNext = controller.hasNext;
            system.assertEquals(false,hasNext);
            final Integer pageSize = controller.pageSize;
            system.assertEquals(20,pageSize);       
            
            Test.stopTest();     
        }
    }    
    private static testmethod void cancelEPIPTest() {
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            final FS_EP_Equipment_Package__c executionPkge = [Select id,FS_Execution_Plan__c from FS_EP_Equipment_Package__c Limit 1];
            //Sets the current PageReference for the controller
            final PageReference pageRef=Page.FSCopyEPEPToInstallationsSearch;
            Test.setCurrentPage(pageRef);
            //Add parameters to page URL
            pageRef.getParameters().put(IDVAL,executionPkge.id);
            final ApexPages.StandardController stdcon = new ApexPages.standardController(executionPkge);           
            
            final FSCopyEPEPToInstallationsSearchExtension controller = new FSCopyEPEPToInstallationsSearchExtension(stdcon);
            
            controller.first();
            controller.last(); 
            
            //Selecting Installtion
            for(FSCopyEPEPToInstallationsSearchExtension.WrapperClass wrap: controller.wrapperRecordList) {
                wrap.isSelected = true;
                wrap.installation.FS_Execution_Plan_Final_Approval_PM__c = APPROVED;
            }
            //Cancelling Copy to Installation
            controller.cancelEPIP(); 
            system.assertEquals(controller.wrapperRecordList.size(),1); 
            Test.stopTest();   
        }
    }
}