/*=================================================================================================================
* Date         : 07/31/2019
* Developer    : Infosys
* Purpose      : Trigger on ContentDocument when a file is deleted
*=================================================================================================================
*                                 Update History
*                                 ---------------
*   Date        Developer       Tag   Description 
*============+================+=====+=============================================================================
* 07/31/2019 | Infosys |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

trigger FS_ContentDocument_Trigger on ContentDocument (before delete,before update) {
    Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FS_ContentDocument_Trigger');
    if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    if(!isMigrationInProgress){
        
             if(trigger.isbefore ){ 
                if(trigger.isDelete){                
                    FS_ContentDocumentTrigger_Handler.sendEmailOnDeletionOfAMOAForm(Trigger.old);
                }
                 if(trigger.isUpdate && !FS_ContentDocumentLinkTrigger_Handler.preventUpdate){ 
                    FS_ContentDocumentTrigger_Handler.sendEmailOnAdditionOfAMOAForm(Trigger.new);
                }
            } 
    }
       
        
       
}