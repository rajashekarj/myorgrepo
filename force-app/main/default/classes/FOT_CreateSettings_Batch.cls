global class FOT_CreateSettings_Batch implements Database.Batchable<sObject>{

    global String Query;
    
/****************************************************************************
//Intialize the batch
/***************************************************************************/
    
/****************************************************************************
//Start the batch
/***************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc){
        
		Query = 'SELECT id FROM FS_Outlet_Dispenser__c WHERE Id NOT IN (SELECT FS_OD_RecId__c FROM FS_OD_SettingsReadOnly__c)';
        if(test.isRunningTest()){
           Query = 'SELECT id FROM FS_Outlet_Dispenser__c';
        }
        return Database.getQueryLocator(Query);
    }
    
/****************************************************************************
//Execute batch
/***************************************************************************/
    global void execute(Database.BatchableContext bc, List<FS_Outlet_Dispenser__c> ODList ){
        List<FS_OD_Settings__c> editableSettings = new List<FS_OD_Settings__c>();
        List<FS_OD_SettingsReadOnly__c> readonlySettings = new List<FS_OD_SettingsReadOnly__c>();
        
        
        for(FS_Outlet_Dispenser__c OD: ODList)
        {
            FS_OD_Settings__c editableSetting = new FS_OD_Settings__c();
            FS_OD_SettingsReadOnly__c readonlySetting = new FS_OD_SettingsReadOnly__c();
            
            editableSetting.FS_OD_RecId__c = OD.id;
            readonlySetting.FS_OD_RecId__c = OD.id;
            
            editableSettings.add(editableSetting);
            readonlySettings.add(readonlySetting);
        }
        
        insert editableSettings;
        insert readonlySettings;
    }
    
/****************************************************************************
Finish batch
*****************************************************************************/
    global void finish(Database.BatchableContext bc){
        
    }
}