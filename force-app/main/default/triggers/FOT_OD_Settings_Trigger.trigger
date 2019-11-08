trigger FOT_OD_Settings_Trigger on FS_OD_Settings__c (before insert, before update) 
{
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSODSetting');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823        
        //Before Insert process
        if(Trigger.isInsert && Trigger.isBefore){
            FsODTriggerSettingBusinessProcess.OnBeforeInsertProcess(Trigger.new);
        }
        
        //Before Update Process
        else if(Trigger.isUpdate && Trigger.isBefore){            
            FsODTriggerSettingBusinessProcess.OnBeforeUpdateProcess(Trigger.new, Trigger.oldmap);
        }
    }
}