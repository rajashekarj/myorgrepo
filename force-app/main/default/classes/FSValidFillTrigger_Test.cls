/**************************************************************************************
Apex Class Name     : FSValidFillTrigger_Test
Version             : 1.0
Function            : This test class is for FSValidFillTrigger Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
public Class FSValidFillTrigger_Test{
    public Static Account accchain,accHQ,accOutlet;
    public Static FS_Execution_Plan__c executionPlan;
    public Static FS_Installation__c installtion;
    public Static FS_Outlet_Dispenser__c  odRec;   
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN); 
    
    private Static void createtestData(){
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        accchain = new Account();
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        accHQ    = new Account();
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);    
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        accOutlet = new Account();
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,true);
        executionPlan = new FS_Execution_Plan__c();
        executionPlan =FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id,true);
        installtion = new FS_Installation__c();
        installtion =FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id,true);
        
        odRec = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,accOutlet.id,null,true);   
        
    }
    private static testMethod void  testTriggerValidFill(){
        createtestData();       
        Test.startTest();
        final List<FS_Valid_Fill__c> validFillList=new List<FS_Valid_Fill__c>();
         FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill =FSTestUtil.createValidFill('7000',true);
        validFill.FS_Outlet__c=accOutlet.id;      
        validFillList.add(validFill);  
        
        FS_Valid_Fill__c validFill1 = new FS_Valid_Fill__c();
        validFill1 =FSTestUtil.createValidFill('8000',true);
        validFill1.object_id__c=installtion.id;      
        validFillList.add(validFill1);        
        
        FS_Valid_Fill__c validFill2 = new FS_Valid_Fill__c();
        validFill2 =FSTestUtil.createValidFill('9000',true);
        validFill2.object_id__c=odRec.id;      
        validFillList.add(validFill2);        
        
        FS_Valid_Fill__c validFill3= new FS_Valid_Fill__c();
        validFill3 =FSTestUtil.createValidFill('9000',true);
        validFill3.object_id__c='01pe0000000CWVS';
        validFillList.add(validFill3);
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            update validFillList;
        }
        Test.stopTest();
    }
    
    @testSetup  
    private static void mytestSetup() {
        final Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
        
        disableTriggerSetting.name='FSVlaidFillTriggerHandler';
        disableTriggerSetting.IsActive__c=true;
        disableTriggerSetting.Trigger_Name__c='FSValidFillTrigger' ; 
        insert disableTriggerSetting;   
    }    
    
    private static testmethod void testDisableTrigger(){
        final Disable_Trigger__c disableTriggerSetting = [select IsActive__c from Disable_Trigger__c where name='FSVlaidFillTriggerHandler'];
        disableTriggerSetting.IsActive__c=false;
        update disableTriggerSetting;   
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
            validFill =FSTestUtil.createValidFill('7000',true);
        }
    }
}