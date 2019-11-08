/**************************************************************************************
Apex Class Name     : FS_Email_Handler
Function            : This class is created for handling inbound email.
Author              : Infosys
Modification Log    : FACT R1 2018
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Denit            2/22/2018         Update Case Records based on the inbound Emails 	
*************************************************************************************/
global class FS_Email_Handler  implements Messaging.InboundEmailHandler
{      
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope)
    {        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		string subStatus,status,customcommentbody;
        String FinanceLable = System.Label.EmailSubjectForFinance;
        String JdeLabel = System.Label.EmailSubjectForJDE;
        if(email.subject.contains(FinanceLable))
		{  
        subStatus= FSConstants.PENDING_INSTALL;
        customcommentbody =FSConstants.RSS_RESPONSE;    
		}
        else if (email.subject.contains(JdeLabel))
        {
            subStatus= '';
            status=FSConstants.STATUS_CLOSED;
            customcommentbody =FSConstants.JDE_RESPONSE; 
        }        
        	String subject = email.subject;
        	String emailbody = email.plainTextBody;
        	String FSkeyword = System.Label.FS_Keyword;
            List <string> subValues=subject.split('#');
            List<String> idvalue =new List<String>();
            string caseNumb=subValues.get(1);
            idvalue.add(caseNumb);           
            case caseRef= [Select id,CaseNumber,status,LM_Sub_Status__c,Priority,FS_Response_Email_Body__c from case where CaseNumber IN :idvalue];
        	caseRef.Status=status;
        	caseRef.LM_Sub_Status__c=subStatus;
       		caseRef.FS_Response_Email_Body__c = emailbody.substringBefore(FSkeyword);
        	try{
            update caseRef; 
            }catch(Exception ex){system.debug('Exception in Update: ' + ex.getMessage());}
        
        //Processing Attachments 
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) 
        try{
            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) 
            {         
                Attachment attachment = new Attachment();         
                attachment.ParentId = caseRef.Id;         
                attachment.Name = email.binaryAttachments[i].filename;         
                attachment.Body = email.binaryAttachments[i].body;         
                insert attachment;     
            }             
        }catch(Exception ex){system.debug('Exception in Binary Attachemnts: ' + ex.getMessage());} 
        
        //Processing Attachments 
        if (email.textAttachments != null && email.textAttachments.size() > 0) 
        try{
            for (integer i = 0 ; i < email.textAttachments.size() ; i++) 
            {
                Attachment attachment = new Attachment();
                attachment.ParentId = caseRef.Id;
                attachment.Body = blob.valueOf(email.textAttachments[i].body);
                attachment.Name = email.textAttachments[i].filename;
                insert attachment;
             }
        }catch(Exception ex){system.debug('Exception in Text Attachemnts: ' + ex.getMessage());} 
        
         //Processing Case Commnets
         if(email.plainTextBody != null)
         try{
            String USER_POFILE_FS_ADMIN = System.label.USER_NAME; 
            Id commentby =[select id,name from User where name=:USER_POFILE_FS_ADMIN].Id;
            CaseComment CC = new CaseComment();
            CC.ParentID = caseRef.Id;  
            cc.CreatedById =commentby;
            CC.CommentBody = customcommentbody;
            insert CC;
          }catch(Exception ex){system.debug('Exception in Comments: ' + ex.getMessage());}           
		
        result.success = true;
        return result;                        
    }  
}