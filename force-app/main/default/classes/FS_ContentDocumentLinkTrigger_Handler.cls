/*=================================================================================================================
* Date         : 01/18/2019
* Developer    : Goutham Rapolu
* Purpose      : TriggerHandler for FS_ContentDocumentLinkTrigger when a FILE is upated with FS_CIF__c ID then
*				 upate Attachment_ID__c, Attachment_URL__c fields with the File ID, URL.
*=================================================================================================================
*                                 Upate History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 01/18/2019 | Goutham Rapolu |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

public without sharing class FS_ContentDocumentLinkTrigger_Handler {
    public static Boolean preventUpdate = false;
    public static void FS_CDL_UploadURL(List<ContentDocumentLink> CDLlist){
        Map<String,String> cifAttchmentIdMap=new Map<String,String>();
        SET<id> CIFid = new SET<id>();
        List<ContentDocumentLink> CDList = new List<ContentDocumentLink> ();
        List<FS_CIF__c> cifList=new List<FS_CIF__c>();
        //Get CIF ID from Trigger.new List
        
        for(ContentDocumentLink con:CDLlist){
            ID attachmentId = con.ContentDocumentId;
            System.debug('J-F: attachmentId: ' + attachmentId);
            if(attachmentId !=null) {
                // Get content document object for current set of files
        		ContentDocument contentDocument = [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :attachmentId];
                System.debug('J-F: FileExtension: ' + contentDocument.FileType + ' , label: ' + Label.ForbiddenFiles);
                if(Label.ForbiddenFiles.contains(contentDocument.FileType) ) {
                    con.addError(contentDocument.FileType + ' file type is not allowed');
                }
                
                if(con.LinkedEntityId!=null){
                    Id objId = (Id) con.LinkedEntityId;
                    Schema.SObjectType objType = objId.getSObjectType();
                    String objName = objType.getDescribe().getName();
                    if(objName=='FS_CIF__c'){
                        //Get Record ID, Content ID if related to CIF record.
                        CIFid.add(con.LinkedEntityId);
                    }
                }
                
            }
        }
        if(!CIFid.ISEMPTY()){
            CDList = [Select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink Where LinkedEntityId IN:CIFid];
            if(CDList.ISEMPTY()){
                for(FS_CIF__c cif:[select id,Attachment_URL__c,Attachment_ID__c from FS_CIF__c where id IN:CIFid]){
                    cif.Attachment_URL__c = '';
                    cif.Attachment_ID__c = '';
                    cifList.add(cif);
                }
                if(!cifList.isEmpty() ){
                    update cifList;
                }
            }
            for(ContentDocumentLink con:CDlist){
                cifAttchmentIdMap.put(con.LinkedEntityId, con.ContentDocumentId);
            }
        }
        if(cifAttchmentIdMap!=null){
            for(FS_CIF__c cif:[select id,Attachment_URL__c,Attachment_ID__c from FS_CIF__c where id IN :cifAttchmentIdMap.keySet()]){
                cif.Attachment_ID__c = '';
                cif.Attachment_URL__c = '';
                if(!CDlist.ISEMPTY()){
                    for(ContentDocumentLink CD: CDlist){
                        if(CD.LinkedEntityId == cif.id){
                            if(cif.Attachment_ID__c == '' ){
                                cif.Attachment_ID__c = CD.ContentDocumentId;
                            }else{
                                cif.Attachment_ID__c = cif.Attachment_ID__c + ' ; ' + CD.ContentDocumentId; 
                            }
                            if(cif.Attachment_URL__c == '' ){
                                cif.Attachment_URL__c = System.URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + CD.ContentDocumentId + '?operationContext=S1';
                            }else{
                                cif.Attachment_URL__c = cif.Attachment_URL__c + ' ; <br/>'+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + CD.ContentDocumentId + '?operationContext=S1'; 
                            }
                        }
                    }
                }
                cifList.add(cif);
            }        
            if(!cifList.isEmpty() ){
                update cifList;
            }
        }
    }
     
     /*****************************************************************
Method: ro4wInstallFileUploadCheck
Description: ro4wInstallFileUploadCheck method is Validate User access for File Creation under RO4W  
Added as part of FET 7.0 FNF-462
*******************************************************************/  
    public static void ro4wInstallFileUploadCheck(List<ContentDocumentLink> CDLlist){
        Set<id> installationIdSet = new Set<id>();
        Set<id> installRO4WIdSet = new Set<id>();
        List<String> profileListCheckRO4W = new List<String>{FSConstants.USER_POFILE_PM,FSConstants.USER_POFILE_ADMINPM,
            FSConstants.USER_PROFILE_PC,FSConstants.USER_POFILE_AC,FSConstants.USER_POFILE_FETADMIN,FSConstants.USER_POFILE_SYSADMIN};
        String currentUserProfile = FSUtil.getProfileName();
        if(!profileListCheckRO4W.contains(currentUserProfile)){
            for(ContentDocumentLink con:CDLlist){
                if(con.ContentDocumentId!=FSConstants.NULLVALUE && con.LinkedEntityId!=FSConstants.NULLVALUE){
                    Id objId = (Id) con.LinkedEntityId;
                    Schema.SObjectType objType = objId.getSObjectType();
                    String objName = objType.getDescribe().getName();
                    if(objName == FSConstants.INSTALLATIONOBJECTNAME){
                        installationIdSet.add(con.LinkedEntityId);
                    }
                }
            }
            for(FS_Installation__c install:[select id,recordtypeid from FS_Installation__c where ID IN :installationIdSet and recordtypeId=:FSInstallationValidateAndSet.ipRecTypeRelocationO4W]){
                installRO4WIdSet.add(install.Id);
            }
            
            for(ContentDocumentLink con:CDLlist){
                if(con.ContentDocumentId!=null && con.LinkedEntityId!=null && installRO4WIdSet.Contains(con.LinkedEntityId)){
                    con.addError(Label.FS_File_Upload_Error_Under_RO4W);
                }
            }
        }
    }
     //FET 7.0 FNF-462
    
/*****************************************************************
Method: sendEmailToAMSOnDeletionOfAMOA
Description: sendEmailToAMSOnDeletionOfAMOA method sends a notification mail to AMS team when AMOA form linked to RO4W is deleted  
Added as part of FET-7.0 FNF 850
*******************************************************************/  
    public static void sendEmailToAMSOnDeletionOfAMOA(List<ContentDocumentLink> CDLlist){
        try{ Set<string> casenoset = new Set<string>();
            Set<id> installIdSet = new Set<id>();
            List<ContentDocumentLink> CDList = new List<ContentDocumentLink> ();
            Id installationId = FSInstallationValidateAndSet.ipRecTypeRelocationO4W;
            Id grpid;
            List<String> caseId = new List<String>();
            for(ContentDocumentLink con:CDLlist){
                if(con.ContentDocumentId != null && con.LinkedEntityId != null){
                    Id objId = (Id) con.LinkedEntityId;
                    Schema.SObjectType objType = objId.getSObjectType();
                    String objName = objType.getDescribe().getName();
                    if(objName == FSConstants.INSTALLATIONOBJECTNAME){
                       
                        installIdSet.add(con.LinkedEntityId);
                    }
                }
            }
            List<FS_Installation__c> installList = [SELECT ID, Overall_Status2__c,FS_Freestyle_Support_Tool_Case__c, FS_Asset_Tracking_Form_AMOA_Status__c, FS_related_case_id__c 
                                                    FROM FS_Installation__c 
                                                    WHERE Id IN : installIdSet
                                                    AND RecordTypeId =: installationId];
            for(FS_Installation__c i : installList){
                if((i.Overall_Status2__c == FSConstants.PIA_PENDINGTONEWOUTLET || i.Overall_Status2__c == FSConstants.onHolds) &&
                   (i.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOASUBMIT || i.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOACOMPLETE)){
                       caseId.add(i.FS_related_case_id__c);
                   }
            }
            sendEmailToRO4WAMOAGROUP(FSConstants.emailNotificationOnDeletionOfAMOAForm,caseId);
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog(FSConstants.PROJECTNAME1, FSConstants.FS_ContentDocumentLinkTrigger_Handler, FSConstants.sendEmailToAMSOnDeletionOfAMOA, FSConstants.NA, FSConstants.MediumPriority, e, FSConstants.NA);
        }
    }
    
              /*****************************************************************
Method: sendEmailToAMSUpdateCaseOnAdditionOfAMOA
Description: sendEmailToAMSUpdateCaseOnAdditionOfAMOA method will attach the latest form from RO4W 
record to case and will send an email if Ro4w  status is 'Pending to New Outlet' or 'On Hold' AND Asset Tracking Form (AMOA) Status is 
'Submitted' or 'Complete'
Added as part of FET 7.0 FNF-850
*******************************************************************/  
    public static void sendEmailToAMSUpdateCaseOnAdditionOfAMOA(List<ContentDocumentLink> CDLlist,Boolean isUpdate){
       
        Set<string> casenoset = new Set<string>();
        MAP<string, Case> caseMAP = new MAP<string, Case>();
        List<String> caseId = new List<String>();
        List<ContentDocumentLink> cdlListtoInsert = new List<ContentDocumentLink>();
        List<Case> caseList = new List<Case>();
        Set<id> installationIdSet = new Set<id>();
        Set<id> newDocumentIds = new Set<id>();
        Set<id> installRO4WIdSet = new Set<id>();
        List<ContentDocumentLink> contentDocumentlList = new List<ContentDocumentLink>();
        Map<id,List<ContentDocumentLink>> installCDmap = new Map<id,List<ContentDocumentLink>>();
        Map<id,FS_Installation__c> installationDetails = new Map<id,FS_Installation__c>();
        for(ContentDocumentLink con:CDLlist){
                if(con.ContentDocumentId!=FSConstants.NULLVALUE && con.LinkedEntityId!=FSConstants.NULLVALUE){
                    Id objId = (Id) con.LinkedEntityId;
                    Schema.SObjectType objType = objId.getSObjectType();
                    String objName = objType.getDescribe().getName();
                    if(objName == FSConstants.INSTALLATIONOBJECTNAME){
                        newDocumentIds.add(con.id);
                        installationIdSet.add(con.LinkedEntityId);
                    }
                }
        }
        for(FS_Installation__c install:[select id,recordtypeid,FS_related_case_id__c,FS_Freestyle_Support_Tool_Case__c,Overall_Status2__c,FS_Asset_Tracking_Form_AMOA_Status__c from FS_Installation__c where ID IN :installationIdSet and recordtypeId=:FSInstallationValidateAndSet.ipRecTypeRelocationO4W]){
                 if((install.Overall_Status2__c == FSConstants.PIA_PENDINGTONEWOUTLET || install.Overall_Status2__c == FSConstants.onHolds) &&
                   (install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOASUBMIT || install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOACOMPLETE)){
                       installRO4WIdSet.add(install.Id);
                       installationDetails.put(install.Id,install);
                       casenoset.add(install.FS_Freestyle_Support_Tool_Case__c);
                   }
		}
		if(!casenoset.ISEMPTY()){
                for(case caserec:[select id,status,CaseNumber,FS_Related_Installation__c FROM Case WHERE CaseNumber IN:casenoset]){
                    caseId.add(caserec.id);
                }
        }
        if(!installRO4WIdSet.isEmpty()){
           
            for(ContentDocumentLink cd:[select id,LinkedEntityId,ContentDocumentId,ContentDocument.title,ContentDocument.CreatedDate,ContentDocument.LatestPublishedVersion.VersionData,
                                    ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId IN:installRO4WIdSet ORDER BY ContentDocument.CreatedDate asc]){
                    if(newDocumentIds.contains(cd.id)){
                            if(installCDmap.containsKey(cd.LinkedEntityId)){
                                List<ContentDocumentLink> cdList = installCDmap.get(cd.LinkedEntityId);
                                cdList.add(cd);
                                installCDmap.put(cd.LinkedEntityId,cdlist);                
                            }
                            else{
                                installCDmap.put(cd.LinkedEntityId,new List<ContentDocumentLink>{cd});
                            } 
                    }
            }
            if(!installCDmap.isEmpty()){
                    for(Id ipId  : installCDmap.keySet()){
                        caseList.add(new case(id=installationDetails.get(ipId).FS_related_case_id__c,FS_Related_Installation__c=ipId ));
                    }
                    if(!caseList.isEmpty()){
                        contentDocumentlList = cloneContentDocumentLink(installCDmap,caseList,caseId);
                    }
                    if(!contentDocumentlList.isEmpty()){
                       try{
                             FS_ContentDocumentLinkTrigger_Handler.preventUpdate = true;
                             if(!isUpdate){
                                 upsert contentDocumentlList;
                             
                             }
                             sendEmailToRO4WAMOAGROUP(FSConstants.EmailnotificationonAdditionofAMOAFormToCase,caseId);
                             
                             
                        }
                        catch(System.DmlException e){
                                
                                for (Integer i = 0; i < e.getNumDml(); i++) {
                                    System.debug(e.getDmlMessage(i)); 
                                }
                        } 
                    }
            }
            
        }
     
    }
/****************************** FNF-850 sendEmailToAMSUpdateCaseOnAdditionOfAMOA Ends*************************************/   
     
/*****************************************************************
Method: cloneContentDocumentLink
Description: cloneContentDocumentLink method clone file frmo related RO4W record to Case record 
Added as part of  FNF-850
*******************************************************************/   
     public static List<ContentDocumentLink> cloneContentDocumentLink (Map<id,List<ContentDocumentLink>> cdlMap, final List<Case> CaseRecList, final List<String> caseId){
        List<ContentDocumentLink> cdlListtoInsert = new List<ContentDocumentLink>();
        List<ContentDocumentLink> cdlink;
        for(Case caseRec: CaseRecList){
            if(cdlMap.containskey(caseRec.FS_Related_Installation__c) && caseId.contains(caseRec.id)){
                 cdlink = cdlMap.get(caseRec.FS_Related_Installation__c);
                for(ContentDocumentLink cd:cdlink){
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl = cd.clone();
                        cdl.LinkedEntityId = caseRec.id;
                        cdl.ShareType = FSConstants.CONTDOC_SHARETYPE;
                        cdlListtoInsert.add(cdl);
                }
            }
        }
        return cdlListtoInsert;
    } 
/****************************** FNF-850 cloneContentDocumentLink Ends*************************************/  

/*****************************************************************
Method: sendEmailToRO4WAMOAGROUP
Description: sendEmailToRO4WAMOAGROUP method will
Added as part of  FNF-850
*******************************************************************/   
    public static void sendEmailToRO4WAMOAGROUP(final string emailTemplateName,List<String> caseId){
        
        Id grpid;
        Id templateId = [SELECT Id FROM EmailTemplate WHERE name =:emailTemplateName].Id;
        for(Group grp : [SELECT Id FROM Group WHERE Name = :FSConstants.RO4W_AMOA_GROUP LIMIT 1]){
            grpid = grp.Id;
        }
        List<String> uid = new List<String>();
        for(GroupMember gm:[SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId =: grpid]){
            uid.add(gm.UserOrGroupId);
        }
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
        for(String cid : caseId){
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, null, cid);
            mail.setToAddresses(uid);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            messages.add(mail);
        }
        if(!messages.ISEMPTY()){
            Messaging.sendEmail(messages);
        }                       
    }
  
}