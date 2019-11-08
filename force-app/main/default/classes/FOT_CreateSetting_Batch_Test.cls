@isTest
public class FOT_CreateSetting_Batch_Test {
    
    @testSetup
    static void testSetup(){
        //create platform type custom settings
        FSTestUtil.insertPlatformTypeCustomSettings(); 
        //Mock HTTP Callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSAccountBusinessProcess','FSInstallationBusinessProcess','FSExecutionPlanTriggerHandler'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
            //Create Chain	
        Account accChain=FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        //Create HQ
        Account accHQ=FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c=accChain.Id;
        insert accHQ;
        //Create Outlet
        Account accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,false);
        accOutlet.FS_Chain__c=accChain.Id;
        insert accOutlet;
        //Create Execution Plan
        FS_Execution_Plan__c executionPlan=FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id,true);
        //Create Instalaltion
        FS_Installation__c  installation=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,accOutlet.Id,true);      
        //Create Outlet DIspenser
        
        Id odRecType=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get('CCNA Dispenser').getRecordTypeId();
        FS_Outlet_Dispenser__c od=new FS_Outlet_Dispenser__c();
        od.FS_Outlet__c=accOutlet.Id;
        od.Installation__c=installation.Id;
        od.FS_Serial_Number2__c='ZPL9090909';
        od.FS_Equip_Type__c	='9000';
        od.RecordTypeId=odRecType;
        od.FS_IsActive__c=true;
        insert od;
    }
    
    private static testMethod void createSettingforODtest(){
        List<FS_Outlet_Dispenser__c> odList=[select id from FS_Outlet_Dispenser__c ];
        
        Test.startTest();
            try{
                DataBase.executeBatch(new FOT_CreateSettings_Batch());
            }catch(exception e) {}
            
        //Get the list of OD Setting list
            List <FS_OD_Settings__c> editableSettingList=[select id from FS_OD_Settings__c];
            system.assertEquals(odList.size(), editableSettingList.size());
            
        //Get the list of OD setting Read Only 
            List <FS_OD_SettingsReadOnly__c> readonlySettingList=[select id from FS_OD_SettingsReadOnly__c];
            system.assertEquals(odList.size(), readonlySettingList.size());
        Test.stopTest();
    }
}