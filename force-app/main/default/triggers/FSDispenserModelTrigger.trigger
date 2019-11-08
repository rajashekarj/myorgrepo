trigger FSDispenserModelTrigger on Dispenser_Model__c (after update) {
    
    Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSDispenserModelTriggerHandler');
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c){
        isMigrationInProgress = true;
    }
    
    if(!isMigrationInProgress){
        //After Update Process
        if(Trigger.isUpdate && Trigger.isAfter){
            FSDispenserModelTriggerHandler.updateOD(trigger.oldMap,trigger.newMap);
        }
        
    }
}