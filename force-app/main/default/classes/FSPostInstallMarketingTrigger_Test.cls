/**************************************************************************************
Apex Class Name     : FSPostInstallMarketingTrigger_Test
Version             : 1.0
Function            : This test class is for FSPostInstallMarketingTrigger Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
public Class FSPostInstallMarketingTrigger_Test{
    public static Account accchain,accHQ,accOutlet;    
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installtion;
    public static FS_Outlet_Dispenser__c  odRec;
    private static Profile fetSysAdmin;    
    
    private static void createtestData(){
        
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
        odRec = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,accOutlet.id,installtion.id,true);     
    }
    
    private static testMethod void  testTriggerPostInsMrkt(){
        createtestData();
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        Test.startTest();
        system.runAs(fetSysAdminUser){
            final List<FS_Post_Install_Marketing__c> listPIMUpdate=new List<FS_Post_Install_Marketing__c>();
            
            FS_Post_Install_Marketing__c marketingField = new FS_Post_Install_Marketing__c();
            marketingField =FSTestUtil.createMarketingField(true);       
            marketingField.FS_Account__c=accOutlet.id;      
            listPIMUpdate.add(marketingField); 
            
            FS_Post_Install_Marketing__c marketingField1 = new FS_Post_Install_Marketing__c();
            marketingField1 =FSTestUtil.createMarketingField(true);       
            marketingField1.object_id__c=installtion.id;      
            listPIMUpdate.add(marketingField1);
            
            FS_Post_Install_Marketing__c marketingField2 = new FS_Post_Install_Marketing__c();
            marketingField2 =FSTestUtil.createMarketingField(true);       
            marketingField2.object_id__c=odRec.id; 
            listPIMUpdate.add(marketingField2);
            
            update listPIMUpdate;
        }
        Test.stopTest();
        
    	system.assertEquals(accOutlet.id, [select id,object_id__c from FS_Post_Install_Marketing__c where FS_Account__c=:accOutlet.id].object_id__c);
    }
    
    private static testMethod void  testDisabletriggerSetting(){
        Test.startTest();
        
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){
            final Disable_Trigger__c disableTriggerSetting = [select name,IsActive__c,Trigger_Name__c from Disable_Trigger__c where name='FSPostInstallMarketingTriggerHandler'];
            disableTriggerSetting.IsActive__c=false;
            update disableTriggerSetting;   
            
            FSTestUtil.createMarketingField(true);
        }
        
        Test.stopTest();
    }
    
    @testSetup  
    private static void mytestSetup() {
        final Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
        
        disableTriggerSetting.name='FSPostInstallMarketingTriggerHandler';
        disableTriggerSetting.IsActive__c=true;
        disableTriggerSetting.Trigger_Name__c='FSPostInstallMarketingTrigger' ; 
        insert disableTriggerSetting;   
    }    
    
}