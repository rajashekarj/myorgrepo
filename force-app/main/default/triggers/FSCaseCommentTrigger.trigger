/**************************************************************************************
Apex Class Name     : FSCaseCommentTrigger
Function            : This trigger is invoked when there is insert or update on Case Comment records.
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD	          07/25/2017       Primary implementation for creating this trigger.
*************************************************************************************/
trigger FSCaseCommentTrigger on CaseComment (after insert,after update,before insert,before update) {
	Boolean isMigrationInProgress = false;
    //Activate account trigger from custom setting
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSCaseComment');
      if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
      isMigrationInProgress = true;  
    }
    if(!isMigrationInProgress)
    {
        if (Trigger.IsAfter)
        {
            if (Trigger.IsInsert) 
            {
                FSCaseCommentTriggerHandler.afterInsertProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
            }
        }
    }
}