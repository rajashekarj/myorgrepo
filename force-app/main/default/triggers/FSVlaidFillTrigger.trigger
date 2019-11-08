trigger FSVlaidFillTrigger on FS_Valid_Fill__c (before insert, before update) {
    //Check the flag to skip in case data migration is in progress.
    Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSVlaidFillTriggerHandler');
    if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    
    if(!isMigrationInProgress){
        for(FS_Valid_Fill__c vf : trigger.new){
            //FNF-116 & 191 Object id value Population
            if(vf.object_id__c == null && vf.FS_Outlet__c!= null ){
                try{
                    vf.object_id__c = vf.FS_Outlet__c;
                }
                catch(Exception ex){        vf.addError(ex);             }
            }
        }    
    }
    
}