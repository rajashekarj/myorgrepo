/*********************************************************************************************************
Name         : FSInstallRescheduleTrigger
Created By   : Infosys
Created Date : 19/03/2018
Usage        : This trigger gets fired whenever an action is performed on installation Reschedule object.
***********************************************************************************************************/
trigger FSInstallRescheduleTrigger on FS_Installation_Reschedule__c (before insert,after insert) {
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSInstallRescheduleTriggerhandler');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //Before Insert process
        if(Trigger.isInsert && Trigger.isBefore){
            FSInstallRescheduleTriggerhandler.isBeforeInsert(Trigger.new,Trigger.NewMap,Trigger.OldMap);
        }
        //After insert process
        else if(Trigger.isInsert && Trigger.isAfter){            
            FSInstallRescheduleTriggerhandler.isAfterInsert(Trigger.new,Trigger.NewMap,Trigger.OldMap);
        }
    }
}