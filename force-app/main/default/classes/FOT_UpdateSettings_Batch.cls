global class FOT_UpdateSettings_Batch implements Database.Batchable<sObject>{
/****************************************************************************
//Intialize the batch
/***************************************************************************/
	  global String query;
    
/****************************************************************************
//Start the batch
/***************************************************************************/
    
    global Database.QueryLocator Start(Database.BatchableContext bc) {
        query = 'SELECT  id, name, Revoke_Artifacts__c FROM FS_OD_Settings__c';
        return Database.getQueryLocator(query); 
    }

/****************************************************************************
//Execute batch
/***************************************************************************/
    
    global void execute(Database.BatchableContext bc, List<FS_OD_Settings__c> odSettingList) {
        for(FS_OD_Settings__c editableSetting: odSettingList)
        {
            editableSetting.Revoke_Artifacts__c = 'No';
        }
        update odSettingList;
    }
    
/****************************************************************************
Finish batch
*****************************************************************************/
    
    global void finish(Database.BatchableContext bc) {
        
        
    }
}