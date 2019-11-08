/**************************************************************************************
Apex Class Name     : FS_SendEmail_Helper
Function            : This is a helper class for replacing merge field values with 
					  actual case values and create single emails based on the recieved parameters.
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD	          07/26/2017       Original Version for implementing a helper class for creating single mails.
*************************************************************************************/

public class FS_SendEmail_Helper {
        
    public static final String Project_Name = 'Freestyle Support 2017';
    public static final String FS_SendEmail_Helper = 'FS_SendEmail_Helper';
    public static final String NA = 'NA';
    public static final String Medium = 'Medium';
    public static final String replaceMergeFieldValues = 'replaceMergeFieldValues';
    public static final String returnEmailObject = 'returnEmailObject';
    public static final String caseNumberStr = '{!Case.CaseNumber}';
    public static final String outletName = '{!Case.FS_Outlet_Name__c}';
    public static final String serialNumberStr = '{!Case.FS_Serial_Number__c}';
    public static final String dispenserSerialNumber = '{!Case.Dispenser_serial_number__c}';
    public static final String createdByStr = '{!Case.CreatedBy}';
    public static final String acnStr = '{!Case.FS_ACN__c}';
    public static final String sapStr = '{!Case.FS_SAP__c}';
    public static final String outletAdress = '{!Case.FS_Address__c}';
    public static final String caseTypeStr = '{!Case.FACT_Case_Type__c}';
    public static final String subjectStr = '{!Case.Subject}';
    public static final String descriptionStr = '{!Case.Description}';
    public static final String linkStr = '{!Case.Link}';
    public static final String commentBodyStr = '{!Case.FS_LatestCommentBody__c}';
    public static final String commentCreatedBy = '{!Case.FS_Comment_Created_By_Username__c}';
    public static final String resolutionType = '{!Case.FS_Resolution_Type__c}';
    public static final String resolutionComment = '{!Case.FS_Resolution_Comments__c}';
    
    /*****************************************************************************************
    	Method : replaceMergeFieldValues
    	Description : Method for replacing merge field values with actual case record values.
    ******************************************************************************************/
	public static Messaging.SingleEmailMessage replaceMergeFieldValues(String userName,String email,EmailTemplate template,Case caseRecord,Boolean commentFlag,String commentBody,String commentCreator,Boolean closeFlag)
    {
        String subject = template.Subject;
        String plainTextBody = template.Body;
        try
        {
            subject = subject.replace(caseNumberStr,caseRecord.CaseNumber);
            subject = subject.replace(serialNumberStr,caseRecord.FS_Serial_Number__c);
            
            plainTextBody = plainTextBody.replace('\n','<br/>');
            plainTextBody = (userName != null ? plainTextBody.replace(createdByStr,userName) : 
                             plainTextBody.replace(createdByStr,NA));
            plainTextBody = (caseRecord.CaseNumber != null ? plainTextBody.replace(caseNumberStr,caseRecord.CaseNumber) 
                             : plainTextBody.replace(caseNumberStr,NA));
            plainTextBody = (caseRecord.FS_Outlet_Name__c != null ? plainTextBody.replace(outletName,caseRecord.FS_Outlet_Name__c) 
                             : plainTextBody.replace(outletName,NA));
            plainTextBody = (caseRecord.FS_ACN__c != null ? plainTextBody.replace(acnStr,caseRecord.FS_ACN__c) 
                             : plainTextBody.replace(acnStr,NA));
            plainTextBody = (caseRecord.FS_SAP__c != null ? plainTextBody.replace(sapStr,caseRecord.FS_SAP__c) 
                             : plainTextBody.replace(sapStr,NA));
            plainTextBody = (caseRecord.FS_Address__c != null ? plainTextBody.replace(outletAdress,caseRecord.FS_Address__c) 
                             : plainTextBody.replace(outletAdress,NA));
            plainTextBody = (caseRecord.FS_Serial_Number__c != null ? plainTextBody.replace(serialNumberStr,caseRecord.FS_Serial_Number__c) 
                             : plainTextBody.replace(serialNumberStr,NA));
            plainTextBody = (caseRecord.Dispenser_serial_number__c != null ? plainTextBody.replace(dispenserSerialNumber,caseRecord.Dispenser_serial_number__c) 
                             : plainTextBody.replace(dispenserSerialNumber,NA));
            plainTextBody = (caseRecord.FACT_Case_Type__c != null ? plainTextBody.replace(caseTypeStr,caseRecord.FACT_Case_Type__c) 
                             : plainTextBody.replace(caseTypeStr,NA));
            plainTextBody = (caseRecord.Subject != null ? plainTextBody.replace(subjectStr,caseRecord.Subject) 
                             : plainTextBody.replace(subjectStr,NA));
            plainTextBody = (caseRecord.Description != null ? plainTextBody.replace(descriptionStr,caseRecord.Description) 
                             : plainTextBody.replace(descriptionStr,NA));
            plainTextBody = plainTextBody.replace(linkStr,System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + caseRecord.Id);
            if(commentFlag)
            {
                plainTextBody = plainTextBody.replace(commentBodyStr,commentBody);
                plainTextBody = plainTextBody.replace(commentCreatedBy,commentCreator);
            }
            if(closeFlag)
            {
                plainTextBody = (caseRecord.FS_Resolution_Type__c != null ? plainTextBody.replace(resolutionType,caseRecord.FS_Resolution_Type__c) 
                             : plainTextBody.replace(resolutionType,NA));
                plainTextBody = (caseRecord.FS_Resolution_Comments__c != null ? plainTextBody.replace(resolutionComment,caseRecord.FS_Resolution_Comments__c) 
                             : plainTextBody.replace(resolutionComment,NA));
            }
        }
        catch(NullPointerException ex)
        {
            system.debug('NullPointerException : ' + ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_SendEmail_Helper,replaceMergeFieldValues,NA,Medium,ex,NA);
        }
        return returnEmailObject(email,null,subject,true,plainTextBody);
    }
    
    /*****************************************************************************************
    	Method : returnEmailObject
    	Description : Method to create single email based on recieved parameter values.
    ******************************************************************************************/
    public static Messaging.SingleEmailMessage returnEmailObject(String email, ID userID,String subject,Boolean body,string mailBody)
    { 
        final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        try
        {
            final List<String> sendTo = new List<String>();
            sendTo.add(email); 
            mail.setToAddresses(sendTo); 
            mail.setTargetObjectId(userID);
            mail.SetSubject(subject);
            if(body)
            {
                mail.setHtmlBody(mailBody);
            }
            
            mail.setSaveAsActivity(false);
        }
        catch(NullPointerException ex)
        {
            system.debug('NullPointerException : ' + ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_SendEmail_Helper,returnEmailObject,NA,Medium,ex,NA);
        }
        return mail;
    }
}