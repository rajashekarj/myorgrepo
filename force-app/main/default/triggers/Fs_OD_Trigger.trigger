trigger Fs_OD_Trigger on FS_Outlet_Dispenser__c (before insert,before update,after insert,after update, before delete) {

    //Whenever data migration is happning then make this value off in Disable trigger custom setting
    Boolean isAnyMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSODBusinessProcess');
      if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isAnyMigrationInProgress = true;  
    } 
system.debug('in OD trigger');
    if(!isAnyMigrationInProgress){
            //Before Insert process
            if(Trigger.isInsert && Trigger.isBefore){
                FsODTriggerBusinessPorcess.OnBeforeInsertProcess();
            }
        	//After insert process
            else if(Trigger.isInsert && Trigger.isAfter){
                FsODTriggerBusinessPorcess.OnAfterInsertProcess();
            }
        	//Before Update Process
            else if(Trigger.isUpdate && Trigger.isBefore){
                FsODTriggerBusinessPorcess.OnBeforeUpdateProcess();
            }
        	//After Update Process
            else if(Trigger.isUpdate && Trigger.isAfter){
                FsODTriggerBusinessPorcess.OnAfterUpdateProcess();
                
            }
            //before Delete Process
            else if(Trigger.isDelete && Trigger.isBefore){
                system.debug('in OD Delete');
                FsODTriggerBusinessPorcess.onBeforeDeleteODs();
            }
    }
}