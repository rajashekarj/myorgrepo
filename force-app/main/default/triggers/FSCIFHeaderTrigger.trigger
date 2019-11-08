trigger FSCIFHeaderTrigger on CIF_Header__c (before update) {
    
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSCIFHeaderTrigger');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        FsCIFReParentTriggerHelper.getCIFdetails(Trigger.New,Trigger.oldMap);
    }

}