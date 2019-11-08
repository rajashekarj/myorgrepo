/***************************************************************************
 Name         : FSAccountTeamMemberTrigger
 Created By   : Mohit Parnami
 Description  : Trigger on AccountTeamMember
 Created Date : Nov 7, 2013
****************************************************************************/
trigger FSAccountTeamMemberTrigger on AccountTeamMember__c (after delete, after insert, after update, before insert) {
 Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountTeamMemberTriggerHandler');
        if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    if(Trigger.isAfter && !isMigrationInProgress  ){
        if(Trigger.isInsert && !FSAccountTeamMemberTriggerHandler.insertFlag){
          FSAccountTeamMemberTriggerHandler.afterInsert(Trigger.new);
          FSAccountTeamMemberTriggerHandler.insertFlag = true;
        }
        if(Trigger.isDelete && !FSAccountTeamMemberTriggerHandler.deleteFlag){
          FSAccountTeamMemberTriggerHandler.afterDelete(Trigger.old);
          FSAccountTeamMemberTriggerHandler.deleteFlag = true;
        }
        if(Trigger.isUpdate){
          FSAccountTeamMemberTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.New);
        }

    }

    else if(Trigger.isBefore && !isMigrationInProgress  ){
       if(Trigger.isInsert){
         FSAccountTeamMemberTriggerHandler.beforeInsert(Trigger.new);
       }
    }
}