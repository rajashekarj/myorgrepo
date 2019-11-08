/***************************************************************************
 Name         : AccountTrigger
 Created By   : Mohit Parnami
 Description  : Trigger on FS_Market_ID__c
 Created Date : Oct 16, 2013         
****************************************************************************/
trigger FSMarketIdTrigger on FS_Market_ID__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
 Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSMarketIdHandler');
        if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    
    
    
    if (Trigger.isAfter && !Trigger.isDelete && !isMigrationInProgress ) {
        FSMarketTriggerHandler.afterUpdate();
    }
}