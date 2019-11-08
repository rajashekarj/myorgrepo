trigger FSPostInstallMarketingTrigger on FS_Post_Install_Marketing__c (before insert, before update,after insert,after update) {
    //Check the flag to skip in case data migration is in progress.
    Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSPostInstallMarketingTriggerHandler');
    if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    if(!isMigrationInProgress){
        for(FS_Post_Install_Marketing__c pm : trigger.new){
            
            if(pm.object_id__c == null && pm.FS_Account__c != null ){
                try{
                    pm.object_id__c= pm.FS_Account__c;
                }
                catch(Exception ex){      pm.addError(ex);             }
            }
        }
        
        if(Trigger.isAfter){
            FSPostInstallMarketingHelper.updateAccountonToday();
        }
    }   
}