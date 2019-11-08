/**************************
    Name         : FOTArtifactRuleSetTrigger
    Created By   : Infosys
    Created Date : 21/03/2018
    Usage        : This trigger gets fired on any action on FS_Artifact_Ruleset__c record
    ***************************/
trigger FOTArtifactRuleSetTrigger on FS_Artifact_Ruleset__c (before delete,after delete,before update,before insert, after insert, after update) 
{
//FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FOTRuleSetTriggerHandler');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        if(Trigger.isBefore){   
            if(Trigger.isDelete) {
                FOTRuleSetTriggerHandler.beforeDelete(Trigger.old,Trigger.oldMap);
            }
            if(Trigger.isInsert){
                FOTRuleSetTriggerHandler.beforeInsert(Trigger.New,Trigger.newMap);  
            }
            if(Trigger.isUpdate){
                FOTRuleSetTriggerHandler.beforeUpdate(Trigger.New,Trigger.newMap,Trigger.oldMap);   
            }
        }
    } 
}