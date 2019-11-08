/**************************************************************************************
Apex Class Name     : FACT_CaseTrigger
Function            : This trigger is invoked when there is insert or update on Case records.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD            07/25/2017       Updating existing trigger to accomodate Static fields population, 
display an error message to users who try to close the Case with open task 
and insert Case Email Notification records and send email on Case Closure.
*************************************************************************************/
trigger FACT_CaseTrigger on Case (after insert,after update,before insert,before update) {
    List<Case> caseRecs = new List<Case>();
    caseRecs = trigger.new;
    ID lmRecTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get(FSConstants.RECORD_TYPE_NAME_LMCASE).getRecordTypeId();
    Boolean LMCheck;
    if(lmRecTypeId == caseRecs[0].recordtypeId){
        LMCheck = false;
    }else{
        LMCheck = true;
    }
    Boolean isMigrationInProgress = false;
    //Activate account trigger from custom setting
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSCase');
    if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;  
    }
    if(FSConstants.SET_CASEASSIGNMENTRULES){
        if(LMCheck){
            if(!isMigrationInProgress)
            {
                if (Trigger.IsAfter)
                {
                    if (Trigger.IsInsert) 
                    {
                        ReAssignCaseOwnerTriggerHandler.insertValues(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
                        FACT_CaseTriggerHandler.afterInsertProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
                    }
                    if(Trigger.isUpdate)
                    {
                        ReAssignCaseOwnerTriggerHandler.updateValues(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
                        FACT_CaseTriggerHandler.afterUpdateProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
                    }
                }
                else
                {
                    FACT_CaseTriggerHandler.beforeInsertUpdateProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
                    if(Trigger.isUpdate)
                    {   
                        FACT_CaseTriggerHandler.beforeUpdateProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
                    }
                }
            }
        }
        //FACT 2018 R1 Enhancements 
        else
        {
            if (Trigger.IsAfter)
            {
                if (Trigger.isUpdate) 
                {   
                    ReAssignCaseOwnerTriggerHandler.updateValues(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
                    FACT_CaseTriggerHandler.updateLMcase(Trigger.new,Trigger.old,Trigger.oldMap);   
                }
                else if(Trigger.isInsert)
                {
                    ReAssignCaseOwnerTriggerHandler.insertValues(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);  
                }
            }
        }}
}