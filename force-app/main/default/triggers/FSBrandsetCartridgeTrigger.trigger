/***************************************************************************
 Name         : FSBrandsetCartridgeTrigger
 Created By   : Infosys Limited
 Description  : Trigger on Brandset-Cartridge junction object
 Created Date : Feb 15th 2017 
 
****************************************************************************/
trigger FSBrandsetCartridgeTrigger on FS_Brandsets_Cartridges__c (before insert,after insert) {

    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSBrandsetCartridgeTriggerDispatcher');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        //Parameterize Trigger context variables to Dipatcher
        new FSBrandsetCartridgeTriggerDispatcher(new FS_Brandsets_Cartridges__c(),
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