/*********************************************************************************************************
Name         : FSEnterEditViewFlavorChangeWiredSolTest
Created By   : Pallavi Sharma (Appiro)
Created Date : 18 - Sep - 2013
Usage        : Unit test coverage of FSEnterEditViewFlavorChangeWiredSolCtrl
Modified By : Venkata 13-02-2017	reg FET 4.0 Project for covering the new code
***********************************************************************************************************/
/**************************************************************************************
Apex Class Name     : FSEnterEditViewFlavorChangeWiredSolTest
Version             : 1.0
Function            : This test class is for  FSEnterEditViewFlavorChangeWiredSolctrl Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSEnterEditViewFlavorChangeWiredSolTest {
    
    public static string emptyVal = '';  
    public static string fName1 = 'fName1';     
    public static string lName1 = 'lName1';   
    public static string barqs = 'Barqs';
    public static final string PLAT7K='7000';
    public static string excutionPlanParam = 'executionplanid';
    public static Id executionPlanId;
    public static List<FS_Brandset__c> brandsets;
    public static FS_Installation__c installation;
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5; 
    //Create Test Data
    private static void createTestData(){
        FSTestFactory.createTestDisableTriggerSetting();        
        
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
        final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,FSConstants.EXECUTIONPLAN);                    
        FS_Execution_Plan__c executionPlan = FSTestFactory.createTestExecutionPlan(headQuarterCustomerList.get(0).Id,false,1,epRecordTypeId)[0];
        executionPlan.FS_Platform_Type__c=PLAT7K;
        insert executionPlan;    
        
        //Create Installation         
        final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,FSConstants.NEWINSTALLATION); 
        final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlan.id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
        installList[0].Type_of_Dispenser_Platform__c=PLAT7K;
        insert installList;

        brandsets=FSTestFactory.createTestBrandset();
        executionPlan=[select id from FS_Execution_Plan__c limit 1];
        
        executionPlanId=executionPlan.id;
        final List<Platform_Type_ctrl__c> listplatform = new List<Platform_Type_ctrl__c>();
        platformTypes=new Platform_Type_ctrl__c(Name='updateBrands',Platforms__c=PLAT7K);
        listplatform.add(platformTypes);
        platformTypes1=new Platform_Type_ctrl__c(Name='EquipmentTypeCheckForNMSUpdateCall',Platforms__c='7000,8000,9000');       
        listplatform.add(platformTypes1);
        platformTypes2=new Platform_Type_ctrl__c(Name='WaterHideCheck',Platforms__c='8000,9000');        
        listplatform.add(platformTypes2);
        platformTypes3=new Platform_Type_ctrl__c(Name='all_Platform',Platforms__c='7000,8000,9000');        
        listplatform.add(platformTypes3);
        platformTypes4=new Platform_Type_ctrl__c(Name='updatecrewServeDasani',Platforms__c='8000');
        listplatform.add(platformTypes4);
        platformTypes5=new Platform_Type_ctrl__c(Name='updateSelfServeDasani',Platforms__c='9000');        
        listplatform.add(platformTypes5);
        insert listplatform; 
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final Disable_Trigger__c disableODTrigger = new Disable_Trigger__c(Name='FSODBusinessProcess',IsActive__c=false,Trigger_Name__c='Fs_OD_Trigger');
        insert disableODTrigger;
        final FS_Outlet_Dispenser__c outletDispenser=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletCustomerList.get(0).Id,FS_Serial_Number2__c='SNO001',FS_Dispenser_Location__c='Location',
                                                   FS_User_Defined_Location__c='Location2',FS_Valid_Fill__c='No', 
                                                   FS_Equip_Type__c=PLAT7K,FS_IsActive__c=true,Installation__c =  installList[0].Id );        
       
        insert outletDispenser;
    }   
    
    private static testMethod void testUpdateAB(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createTestData(); 
            system.debug('-----------------Queries after createTestData----'+Limits.getQueries());
            
            Test.startTest();
            
            final Pagereference pgRefer = Page.FSEnterEditView_Flavor_ChangeWired_Sol;
            Test.setCurrentPage(pgRefer);
            //Initialize Page paramteres
            pgRefer.getParameters().put(excutionPlanParam, executionPlanId);
            //Initialize controller
            final FSEnterEditViewFlavorChangeWiredSolCtrl flavorChange = new FSEnterEditViewFlavorChangeWiredSolCtrl();
            
            for (FS_Installation__c ip : flavorChange.lstInstallation){
                system.debug(ip.Account_Brandsets__r);
                for (FS_Association_Brandset__c assBrand : ip.Account_Brandsets__r) {
                    system.debug(ip.Account_Brandsets__r);
                    assBrand.FS_Brandset__c=brandsets[0].id;
                    assBrand.FS_NonBranded_Water__c='Show';
                }
            }            
            flavorChange.saveInstallation();            
             System.assertEquals(flavorChange.executionPlan, executionPlanId);
            Test.stopTest();
        }
    }
    
    private static testMethod void testErrorMessage(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createTestData(); 
            system.debug('-----------------Queries after createTestData----'+Limits.getQueries());
            
            Test.startTest();
            
            final Pagereference pgRefer = Page.FSEnterEditView_Flavor_ChangeWired_Sol;
            Test.setCurrentPage(pgRefer);
            //Initialize Page paramteres
            pgRefer.getParameters().put(excutionPlanParam, executionPlanId);
            //Initialize controller
            final FSEnterEditViewFlavorChangeWiredSolCtrl flavorChange = new FSEnterEditViewFlavorChangeWiredSolCtrl();
            
            for (FS_Installation__c ip : flavorChange.lstInstallation){
                system.debug(ip.Account_Brandsets__r);
                for (FS_Association_Brandset__c assBrand : ip.Account_Brandsets__r) {
                    system.debug(ip.Account_Brandsets__r);
                    //assBrand.FS_Brandset__c=brandsets[0].id;
                    assBrand.FS_NonBranded_Water__c='Show';
                }
            }            
            flavorChange.saveInstallation();
            
            Test.stopTest();
        }
    }
    // Test method for Cancel
    private static testMethod void testCancelMethod(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createTestData(); 
            system.debug('-----------------Queries after createTestData----'+Limits.getQueries());
            
            Test.startTest();
            
            final Pagereference pgRefer = Page.FSEnterEditView_Flavor_ChangeWired_Sol;
            Test.setCurrentPage(pgRefer);
            //Initialize Page paramteres
            pgRefer.getParameters().put(excutionPlanParam, executionPlanId);
            //Initialize controller
            final FSEnterEditViewFlavorChangeWiredSolCtrl flavorChange = new FSEnterEditViewFlavorChangeWiredSolCtrl();    
            //testing cancel method
            flavorChange.cancel();            
            System.assertEquals(flavorChange.executionPlan, executionPlanId);
            Test.stopTest();
        }
    }
}