/*=================================================================================================================
* Date         : 07/31/2019
* Developer    : Infosys
* Purpose      : TriggerHandler for FS_ContentDocument_Trigger when a FILE deleted then send an email notification.
*=================================================================================================================
*                                 Upate History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 07/31/2019 | Infosys |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

public class FS_ContentDocumentTrigger_Handler {

    public static void sendEmailOnDeletionOfAMOAForm(List<ContentDocument> cdList){
        
        List<id> cdId = new List<Id>();
        for(ContentDocument cdrecord : cdList){ 
            cdId.add(cdrecord.id);
        }
        List<ContentDocumentLink> cdlList = [Select id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where contentdocumentid in : cdId];
        FS_ContentDocumentLinkTrigger_Handler.sendEmailToAMSOnDeletionOfAMOA(cdlList);
    }
     public static void sendEmailOnAdditionOfAMOAForm(List<ContentDocument> cdList){
        List<id> cdId = new List<Id>();
        for(ContentDocument cdrecord : cdList){ 
            cdId.add(cdrecord.id);
        }
        List<ContentDocumentLink> cdlList = [Select id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where contentdocumentid in : cdId];
        FS_ContentDocumentLinkTrigger_Handler.sendEmailToAMSUpdateCaseOnAdditionOfAMOA(cdlList,true);
     
       
    }

}