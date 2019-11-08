/*********************************************************************************************************
Name         : SE_CaseToOutlet
Created By   : Mahender(Infosys)
Created Date : 17 - Nov - 2016
Usage        : Handler class for CaseToOutlet Dispenser trigger.
This trigger is to delete the serial number on the case object to which it is associated with and updates the case list

Name         : CaseToOutletdispenserTrigger
Created By   : Reshma(Infosys)
Modified Date : 28 - Jul - 2017
Usage        : Trigger on Case to Outlet dispenser for insert,update,delete events.
Modified the trigger to populate the static field values created on Case To Outlet dipenser.

Name         : CaseToOutletdispenserTrigger
Created By   : Reshma(Infosys)
Modified Date : 28 - Feb- 2018
Usage        : Trigger on Case to Outlet dispenser for insert,update,delete events.
Modified the trigger to populate the dispenser serial number on Case object.

***********************************************************************************************************/

trigger CaseToOutletdispenserTrigger on CaseToOutletdispenser__c (before insert,before update,after insert, after update,after delete) {
    Boolean isMigrationInProgress = false;
    //Activate account trigger from custom setting
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSCaseToOutletDispenser');
      if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
      isMigrationInProgress = true;  
    }
    if(!isMigrationInProgress){
        /****************************************************************************************************
        FACT & EMT Enhancement : Added below code to populate the static fields on Case To Outlet Dispenser Object
        *******************************************************************************************************/
        if(Trigger.isBefore)
        {
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                SE_CaseToOutletHandler.beforeInsertProcess(Trigger.IsAfter,Trigger.IsInsert,Trigger.IsUpdate,Trigger.new,Trigger.oldmap);
            }
        }
        /****************************************************************************************************
        FACT 2018 R1 Enhancement : Added below code to populate the Dispenser Serial Number field on Case Object
        *******************************************************************************************************/
       
        if(Trigger.isAfter)
        {
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete )
            {
                
                SE_CaseToOutletHandler.afterProcess(Trigger.new,Trigger.old);
            }
        }
        }
        
}