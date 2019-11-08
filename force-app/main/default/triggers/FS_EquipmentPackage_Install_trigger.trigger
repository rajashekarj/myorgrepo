/*********************************************************************************************************
Name         : FS_EquipmentPackage_Install_trigger
Created By   : Infosys
Created Date : 19-JAN-2016
Usage        : This trigger gets fired whenever an action is performed on Equipment Package object.
***********************************************************************************************************/
trigger FS_EquipmentPackage_Install_trigger on FS_IP_Equipment_Package__c (before update,after update) {
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FS_EquipPakage_Install_TriggerHandler');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        //Trigger fired for isBefore calls
        if(trigger.isBefore && trigger.isUpdate){           
            FS_EquipPakage_Install_TriggerHandler.isBeforeUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);            
        } 
        //Trigger fired for isAfter calls
        if(trigger.isAfter && trigger.isUpdate){           
            FS_EquipPakage_Install_TriggerHandler.isAfterUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);            
        }
    }
}