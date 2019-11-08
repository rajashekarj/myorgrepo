trigger FS_SellingActivityMarket_trigger on Selling_Activity_Market__c (After update) {
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FS_SellingActivityMarket_Trigger');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        if(trigger.isAfter){
            if(trigger.isUpdate){
                FS_SellingActivityMarket_TriggerHandler.afterUpdate(Trigger.new,Trigger.newMap,Trigger.oldMap);
                
            }
        }
    }
}