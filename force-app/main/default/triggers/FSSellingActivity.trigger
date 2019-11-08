//
// (c) 2014 Appirio, Inc.
//
// Trigger to update the created by and created on fields of Selling Activity
//
// January 7th, 2015   Sidhant Agarwal     Ref No. I-144960
//
trigger FSSellingActivity on Selling_Activity__c (before update) {
  
   Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSSellingActivityHandler');
        if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    
    
    if(trigger.isBefore && trigger.isUpdate && !isMigrationInProgress ){
        FSSellingActivityHandler.createdDateAndBy(trigger.oldmap,trigger.newMap);
     }
}