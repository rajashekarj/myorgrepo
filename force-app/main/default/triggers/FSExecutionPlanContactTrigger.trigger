/**
 * Created By   : Satyanarayan Choudhary(JDC Developer)
 * Related Task : T-217390
 * Decscription :   Tirgger to Copy Execution Plan Contacts to Outlet Lookup Fields 
 */
trigger FSExecutionPlanContactTrigger on FS_Execution_Plan_Contact__c (after insert, after update) {
     Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSExecutionPlanContactTriggerHandler');
        if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    if(Trigger.isInsert && Trigger.isAfter && !isMigrationInProgress ){
        FSExecutionPlanContactTriggerHandler.afterInsertAndUpdate();    
    }
    if(Trigger.isUpdate && Trigger.isAfter && !isMigrationInProgress ){
        FSExecutionPlanContactTriggerHandler.afterInsertAndUpdate();
    } 
}