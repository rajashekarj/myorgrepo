/********************************************************************************************************* 
Name         : FSCopyToHeadquarter
Created By   : Pallavi Sharma (Appiro)
Created Date : 25 - Sep - 2013
Usage        : Trigger for Feed Item
***********************************************************************************************************/
trigger FSCopyToHeadquarter on FeedItem (after delete, after insert) {
 Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSFeedItemHandler');
        if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    
    
    if(Trigger.isInsert &&   !isMigrationInProgress){
        FSFeedItemHandler.afterInsert();
    }
    if(Trigger.isDelete &&  !isMigrationInProgress){
         FSFeedItemHandler.beforeDelete();
    }
}