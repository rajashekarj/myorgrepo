/***************************************************************************
Name         : InitialOrderTrigger
Created By   : Mohit Parnami
Description  : Trigger on Initial Order
Created Date : Oct 22, 2013

15th Jan 2014      Modified By : Deepti Maheshwari       Ref :    I-145254
// Description       Moved initial order SAP material logic to trigger
****************************************************************************/
trigger FSInitialOrderTrigger on FS_Initial_Order__c (after delete, after insert, after undelete,after update,before delete, before insert, before update) {
    
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSInitialOrderHandler');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        if (Trigger.isBefore) {
            //FSInstallationTriggerHandler.byPass7000_8000Validations = true;
            if(Trigger.isInsert) {
                FSInitialOrderHandler.beforeInsert();
            } else if(Trigger.isUpdate) {
                FSInitialOrderHandler.beforeUpdate();
            }
        }
        if(Trigger.isAfter && Trigger.isInsert) {
            //FSInitialOrderHandler.beforeInsert();
            FSInitialOrderHandler.afterInsert();
            // FSInitialOrderHandler.createSAPMaterialData();
        }
        if(Trigger.isAfter && Trigger.isUpdate) {       
            FSInitialOrderHandler.afterUpdate();
        }
    } 
}