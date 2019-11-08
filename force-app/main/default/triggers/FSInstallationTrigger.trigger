/*********************************************************************************************************
Name         : FSInstallationTrigger
Created By   : Infosys
Created Date : 02-Nov-2016
Usage        : This trigger gets fired whenever an action is performed on installation object.
***********************************************************************************************************/
trigger FSInstallationTrigger on FS_Installation__c (before insert, before update,before delete,after insert, after update,after delete,after undelete) {
    
    Map<Id, Sobject> sobjectsToUpdate = new Map<Id, Sobject>();// for updating sobjects that were modified in the trigger context 
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSInstallationBusinessProcess');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        if (Trigger.IsBefore) { 
            if (Trigger.IsInsert){
                FSInstallationBusinessProcess.beforeInsertProcess(Trigger.new,Trigger.old,
                                                                  Trigger.newMap,Trigger.oldMap,Trigger.IsInsert,Trigger.IsUpdate, sobjectsToUpdate);
            }
            if (Trigger.IsUpdate){
                FSInstallationBusinessProcess.beforeUpdateProcess(Trigger.new,Trigger.old,
                                                                  Trigger.newMap,Trigger.oldMap,Trigger.IsInsert,Trigger.IsUpdate, sobjectsToUpdate);                                                                                   
            }
        }  
        //Trigger fired for isafter calls    
        else if(Trigger.IsAfter){ 
            if (Trigger.IsInsert){
                FSInstallationBusinessProcess.afterInsertProcess(Trigger.new,Trigger.old,
                                                                 Trigger.newMap,Trigger.oldMap,Trigger.IsInsert,Trigger.IsUpdate, sobjectsToUpdate);
                
            }
            if (Trigger.IsUpdate){
                FSInstallationBusinessProcess.afterUpdateProcess(Trigger.new,Trigger.old,
                                                                 Trigger.newMap,Trigger.oldMap,Trigger.IsInsert,Trigger.IsUpdate, sobjectsToUpdate);
                
            }           
            if(Trigger.isDelete){
                FSInstallationBusinessProcess.afterDeleteProcess(Trigger.new,Trigger.old,
                                                                 Trigger.newMap,Trigger.oldMap,Trigger.IsInsert,Trigger.IsUpdate, sobjectsToUpdate);
            }            
            updateSobjectValues();
        }  
    }
    
    /**
* @MethodName - updateSobjectValues()
* @Description - This is the method updates the sobjects that were modified in the trigger context.
* @Return - void
*/
    private void updateSobjectValues(){
        if(FSInstallationBusinessProcess.checkCreateVFClass){
            try{
                if(!sobjectsToUpdate.isEmpty()){                 update sobjectsToUpdate.values();         }
            }
            catch(Exception e){
                ApexErrorLogger.addApexErrorLog(FSconstants.FET,'FSInstallationTrigger','updateSobjectValues','sobjectsToUpdate',FSConstants.MediumPriority,e,FSConstants.NA);
            }
        }
        else{
            if(!sobjectsToUpdate.isEmpty()){             update sobjectsToUpdate.values();                }
        }
    } 
}