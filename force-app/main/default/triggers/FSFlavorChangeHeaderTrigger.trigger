/***************************************************************************
 Name         : FSFlavorChangeHeaderTrigger
 Created By   : Infosys Limited
 Description  : Trigger on FS_Flavor_Change_Head__c
 Created Date : Jan 9th 2017
****************************************************************************/
trigger FSFlavorChangeHeaderTrigger on FS_Flavor_Change_Head__c (before insert,after insert,before update,after update) {
//FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSFlavorChangeHeaderTriggerDispatcher');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
    
        //Parameterize Trigger context variables to Dipatcher
        new FSFlavorChangeHeaderTriggerDispatcher(new FS_Flavor_Change_Head__c(),
                                                    Trigger.IsBefore,
                                                    Trigger.IsDelete,
                                                    Trigger.IsAfter,
                                                    Trigger.IsInsert,
                                                    Trigger.IsUpdate,
                                                    Trigger.IsExecuting,
                                                    Trigger.new,
                                                    Trigger.newmap,
                                                    Trigger.old,
                                                    Trigger.oldmap);
    }
     
}