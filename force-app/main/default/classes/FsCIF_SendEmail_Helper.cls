/*********************************************************************************
AUTHOR             :            INFOSYS
Apex CLASS NAME    : 			FsCIF_SendEmail_Helper
Version 		   :			1.0
CREATED DATE       :            30 Jun 2017
Function           :            This is a send Email Helper class
Modification Log   :
 Developer           		   Date             Description
 ________________________________________________________________ 
 Anwesh Kalakonda              30 Jun 2017      Original Version
*********************************************************************************/

public  class FsCIF_SendEmail_Helper {
    
    public static string fsSendEmail ='FsCIF_SendEmail_Helper';
    public static CIF_Header__c cifHead;
	/*********************************************************************************
	Method          :           


	Description     :           This is used to send a single Email from Apex code with
							    5 Parameters.This is used to return a mail object
	**********************************************************************************/
    public static void sendEmailWithAttachment(string errorOutput,String fileName,List<String> sendToAddress,String subject,String mailBody ) 
    {   
   		List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        
        // Step 1: Create a new Email
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if(errorOutput!= null && errorOutput != ''){
			blob attchBody = blob.valueof(errorOutput);
			Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
			attach.setContentType('text/csv');
            if(fileName != null && fileName != '')
				attach.setFileName(fileName);
            else{
                attach.setFileName('CIF-Upload-Records-Status.csv');
            }
			attach.setInline(false);
			attach.Body = attchBody ;
			mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach} );
        }
        if(sendToAddress != null && !sendToAddress.isEmpty()){
            
            // Step 2: Setting sendTo email addresses 
			mail.setToAddresses(sendToAddress);
            // Step 3. Set subject    
            mail.setSubject(subject); 
            // Step 4. Set Body    
			mail.setHtmlBody(mailBody);
            // Step 5. Add your email to the master list
			mails.add(mail);
            // Step 6: Send all emails in the master list
			Messaging.sendEmail(mails);        
		}
    }
	
	/*********************************************************************************
	Method          :           sendEmail
	Description     :           This is used to send a single Email from Apex code with
							    4 Parameters.This is used to return a mail object
	**********************************************************************************/
	
	//FET 4.0 send email - returns the mail object
    public static Messaging.SingleEmailMessage sendEmail(String email, ID userID,String subject,string mailBody){ 
        
        final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        final List<String> sendTo = new List<String>();
        sendTo.add(email); 
        mail.setToAddresses(sendTo); 
        mail.setTargetObjectId(userID);
        mail.SetSubject(subject);
        mail.setHtmlBody(mailBody); 
		
        mail.setSaveAsActivity(false);
        return mail;
    }     
    
    // OCR Changes Defect# : 4034 Send Email Notification for Rush Install 
    public static void rushInstNotify(String cifNumber,Id cifId) 
    {	
        String loggedInUser = UserInfo.getUserEmail();               
        string[] toMail = new string[] {} ;
		List<FS_Rush_Install_Recipient_List__c> rushInstUsr = new List<FS_Rush_Install_Recipient_List__c>();
		rushInstUsr = FS_Rush_Install_Recipient_List__c.getall().values();
		for(FS_Rush_Install_Recipient_List__c recp : rushInstUsr){
			toMail.add(recp.FS_Email__c);
		}
     	string subject = System.Label.RushInstNotifySubject +' '+cifNumber;	
        String mailBody = System.Label.RushInstNotifyMailBody +cifNumber+' '+System.Label.RushInstNotifyMailBodyHrs+' '+
            System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/FSCustomerInputForm?id=' + cifId;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setToAddresses(toMail);
        mail.setPlainTextBody(mailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } 

    public static void sendReparentNotif(CIF_Header__c CIFHeader,String cifHeadNumstr,Map<String,String> notifiBody,String subject){
      	String loggedInUser = UserInfo.getUserEmail();
        cifHead = [select Id,name,FS_HQ__c,FS_HQ__r.Name,FS_Status__c,FSCOM__r.FS_Email__c,FS_FPS__r.Email,FS_CIF_Number__c from CIF_Header__c where id = :CIFHeader.Id];
        set<string> toMail = new set<string>();
        List<string> toMailList = new List<string>();
        If(String.isNotBlank(cifHead.FSCOM__r.FS_Email__c))
        {
            toMail.add(cifHead.FSCOM__r.FS_Email__c);
        }
        If(String.isNotBlank(cifHead.FS_FPS__r.Email))
        {
            toMail.add(cifHead.FS_FPS__r.Email);
        }
        If(String.isNotBlank(loggedInUser))
        {
            toMail.add(loggedInUser);
        }
        
        String mailBody = '';
        toMailList.addAll(toMail);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setToAddresses(toMailList);
        
        for(String acnNum :notifiBody.keySet())
        {
            mailBody  = mailBody + acnNum + '\n\n' + notifiBody.get(acnNum) + '\n\n';
        }
        mail.setPlainTextBody(mailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}