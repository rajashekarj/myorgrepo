trigger FSCOMNotifications on FS_CIF__c (before update,after update) {
    
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSCOMNotifications');
    system.debug('ENter CIF trigger');
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
    
        if(trigger.isAfter && trigger.isUpdate){
            FSCOMNotificationhandler.afterUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
        }
        if(trigger.isBefore && trigger.isUpdate){
            FSCOMNotificationhandler.beforeUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
        } 
    
    }
}