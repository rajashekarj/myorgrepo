/**************************************************************************************
Apex Class Name     : FSFlavorChangeODTest
Version             : 1.0
Function            : This test class is for  FSFlavorChangeOD Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             09/28/2016          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
public class FSFlavorChangeODTest{
    private static final string SERIES_7K='7000';
    private static final string SERIES_8K='8000';
    private static final string SERIES_9K='9000';
    
    @testSetup
    public static void loadTestData(){
       
        List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSAccountBusinessProcess','FSInstallationBusinessProcess','FSExecutionPlanTriggerHandler'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
        //Create Single HeadQuarter
        final List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                                     FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        //Create Single Outlet
        final List<Account> outletCustomerList=new List<Account>();
        for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'))){
            acc.FS_Headquarters__c=headQuarterCustomerList.get(0).Id;
            outletCustomerList.add(acc);
        }
        insert outletCustomerList;
        
        //Create Execution Plan
        
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
        final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,fsconstants.EXECUTIONPLAN);
        final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(headQuarterCustomerList.get(0).Id,false,1,epRecordTypeId);
        executionPlanList.addAll(epList);                                                                     
        
        //Verify that four Execution Plan got created
        system.assertEquals(1,executionPlanList.size());
        insert executionPlanList;
        
        //Create Installation Plan 
        final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >(); 
        //Create one Installatuion for each Execution Plan according to recordtype
        
        for(FS_Execution_Plan__c executionPlan : executionPlanList){
            final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,fsconstants.NEWINSTALLATION ); 
            final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlan.Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
            installationPlanList.addAll(installList);
        } 
        
        //Verify that four Installation Plan got created
        system.assertEquals(1,installationPlanList.size()); 
        insert installationPlanList;  
        FSTestFactory.lstPlatform();
        
        //Test Mock Setup
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        //Create Outlet Dispensers 
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        for(FS_Installation__c installPlan : installationPlanList){
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
            odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
            outletDispenserList.addAll(odList);
        }   
        
        //Verify that four Outlet Dispenser got created
        system.assertEquals(1,outletDispenserList.size()); 
        insert outletDispenserList;                                                     
    }
    
    public static testmethod void flavorChangeODTest(){
        final List<FS_Outlet_Dispenser__c> outletDispenser= [Select  ID FROM FS_Outlet_Dispenser__c Limit 10];
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.startTest();
            final ApexPages.StandardController con = new ApexPages.StandardController(outletDispenser.get(0));
            final FSFlavorChangeOD fsController=new FSFlavorChangeOD(con);
            
            List<FS_Flavor_Change_New__c> fcList= fsController.getFlavorChanges();
            //verify file merge happened
            //system.assertEquals(2,[SELECT COUNT() from Attachment where parentId=:holder.Id AND Name IN (:FINALSUCESFILENAM,:FINALFAILRFILENAM)]);
            Test.stopTest();
            system.assert(fcList.size()==0);
        }
        
    }
    
}