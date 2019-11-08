trigger FS_CokesmartRegistrationEmail  on Task (after insert) {
 Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FS_CokesmartRegistrationEmail');
        if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    
if(Trigger.isInsert && Trigger.isAfter && !isMigrationInProgress ){
  FS_CokesmartRegistrationEmailHelper.afterInsert();
}

}