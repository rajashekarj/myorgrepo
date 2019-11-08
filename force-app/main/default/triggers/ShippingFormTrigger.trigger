/***************************************************************************
 Name         : ShippingFormTrigger
 Created By   : Deepti Maheshwari
 Description  : Trigger on Shipping Form
 Created Date : May 15, 2015
****************************************************************************/
trigger ShippingFormTrigger on Shipping_Form__c (before insert, before update, after insert, after update) {
 Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('ShippingFormTriggerHandler');
        if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
       

   if(Trigger.isUpdate && !isMigrationInProgress){
        if(Trigger.isBefore){
            ShippingFormTriggerHandler.beforeUpdate();
        }else{
            ShippingFormTriggerHandler.afterUpdate();
        }
    }
    
    if(Trigger.isInsert && !isMigrationInProgress){
        if(Trigger.isBefore){
            ShippingFormTriggerHandler.beforeInsert();
        }
        if(Trigger.isAfter){
            ShippingFormTriggerHandler.afterInsert();
        }
    }
}