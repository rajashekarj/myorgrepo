/***************************************************************************
Name         : ExecutionPlanTrigger
Created By   : Mohit Parnami
Description  : Trigger on Execution Plan
Created Date : Nov 11, 2013  

Modified By    :   Dheeraj Kumar
Modified Date: Dec 26, 2014
Related Task : T-346229       
****************************************************************************/
trigger FSExecutionPlanTrigger on FS_Execution_Plan__c (after delete,before update,before insert, after insert, after update) {
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSExecutionPlanTriggerHandler');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        if (Trigger.isAfter) {
            if(Trigger.isUpdate) {
                FSExecutionPlanTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
            if(Trigger.isInsert) {
                FSExecutionPlanTriggerHandler.afterInsert(Trigger.new, Trigger.oldMap);
            }
        }
        
        if(Trigger.isBefore){
            if(Trigger.isUpdate) {
                FSExecutionPlanTriggerHandler.beforeUpdate(Trigger.new,Trigger.newMap,Trigger.oldMap,Trigger.IsUpdate);
            }
            if(Trigger.isInsert) {
                FSExecutionPlanTriggerHandler.beforeInsert(Trigger.new,Trigger.oldMap,Trigger.IsUpdate);
            }
        }  
    }  
}