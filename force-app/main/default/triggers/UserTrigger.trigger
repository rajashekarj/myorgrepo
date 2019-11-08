trigger UserTrigger on User (after insert, after update) {

    Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('UserTriggerHandler');
        if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }

    if(Trigger.isInsert && !isMigrationInProgress ){
        UserTriggerHandler.afterInsert();
    }
    if(Trigger.isAfter && Trigger.isUpdate && !isMigrationInProgress ){
        UserTriggerHandler.afterUpdate();
    }
}