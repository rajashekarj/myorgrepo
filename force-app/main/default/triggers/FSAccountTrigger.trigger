/*********************************************************************************************************
Name         : FSAccountTrigger 
Created By   : Infosys
Created Date : 02-Nov-2016
Usage        : This trigger gets fired whenever an action is performed on Account object.
***********************************************************************************************************/
trigger FSAccountTrigger on Account (after insert, after update, before insert, before update) {
    Boolean isMigrationInProgress = false;
    private static final Id id1 = userinfo.getProfileId();
    private static final Profile pFile=[select Name from profile where id = :id1];
    //private static final Id CPO_PROFILE_ID1=[select ProfileId from User where Profile.Name = 'FS FPS_P'].ProfileId;
    
    Map<Id, Sobject> sobjectsToUpdate = new Map<Id, Sobject>();//to update sobjects that were modified in the trigger context
    //Activate account trigger from custom setting
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
      if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
      isMigrationInProgress = true;  
    }   
    if(!isMigrationInProgress){
        //Trigger fired isbefore calls
         if (Trigger.IsBefore) {
             FSAccountAuthorizationAndPopulateFields.skipAuthorizationForBottler(Trigger.oldMap, Trigger.new, Trigger.isUpdate, Trigger.isInsert);
                 if (Trigger.IsInsert) {
                    FSAccountBusinessProcess.beforeInsertProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
                 }
                 if (Trigger.IsUpdate) {
                    FSAccountBusinessProcess.beforeUpdateProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate,sObjectsToUpdate); 
                 }
             
        }  
        //Trigger fired isafter calls
        else {
                if (Trigger.IsInsert){
                    FSAccountBusinessProcess.afterInsertProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, System.IsBatch());
                }
                if (Trigger.IsUpdate) {
                    FSAccountBusinessProcess.afterUpdateProcess(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, System.IsBatch(),sObjectsToUpdate);
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
        try{
            if(!sobjectsToUpdate.isEmpty()){
                update sobjectsToUpdate.values();
            }
        }
        catch(Exception e){
             ApexErrorLogger.addApexErrorLog('FET','FSAccountTrigger ','updateSobjectValues','sobjectsToUpdate','Medium',e,'NA');
        }
    }
 if(Trigger.isBefore)
{
    if(Trigger.isUpdate){
//ist<Account> accList1=new List<Account>;
    List<Account> accList1=new List<Account>();
        if(pFile.Name=='FS CPO_P'|| pFile.Name=='FET System Admin' || pFile.Name=='System Administrator' ){
            for(Account obj1:Trigger.New)
            {
                if(obj1.FS_VMS_Customer__c!=Null && obj1.FS_VMS_Customer__c!= trigger.oldMap.get(obj1.id).FS_VMS_Customer__c){
                    
                    obj1.FS_Requested_Order_Method__c=obj1.FS_VMS_Customer__c;
                    accList1.add(obj1);
                }
            }
         }
        //update accList1;
    }
}
}