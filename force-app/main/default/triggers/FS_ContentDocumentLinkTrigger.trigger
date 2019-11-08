/*=================================================================================================================
* Date         : 01/18/2019
* Developer    : Goutham Rapolu
* Purpose      : Trigger on ContentDocumentLink when a FILE is upated with Parent ID
*=================================================================================================================
*                                 Upate History
*                                 ---------------
*   Date        Developer       Tag   Description 
*============+================+=====+=============================================================================
* 01/18/2019 | Goutham Rapolu |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

trigger FS_ContentDocumentLinkTrigger on ContentDocumentLink (before insert,after insert, after delete) {
    Boolean isMigrationInProgress = false;
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FS_ContentDocumentLinkTrigger');
    if(disableTriggerSetting != null && disableTriggerSetting.IsActive__c == false){
        isMigrationInProgress = true;
    }
    if(!isMigrationInProgress){
        //FET 7.0 FNF-462
        if (trigger.isbefore ){
            if(trigger.isInsert){                
                FS_ContentDocumentLinkTrigger_Handler.ro4wInstallFileUploadCheck(Trigger.new);
               
            }
          
        }
         //FET 7.0 FNF-462
        if (trigger.isafter ){
            if(trigger.isInsert){          
                
                FS_ContentDocumentLinkTrigger_Handler.FS_CDL_UploadURL(Trigger.new);
                FS_ContentDocumentLinkTrigger_Handler.sendEmailToAMSUpdateCaseOnAdditionOfAMOA(Trigger.new,false);
            }
            if(trigger.isDelete){
                FS_ContentDocumentLinkTrigger_Handler.FS_CDL_UploadURL(Trigger.old);
                FS_ContentDocumentLinkTrigger_Handler.sendEmailToAMSOnDeletionOfAMOA(Trigger.old);
            }
          
        }
    }
}