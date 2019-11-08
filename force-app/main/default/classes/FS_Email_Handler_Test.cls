/**************************************************************************************
Apex Class Name     : FS_Email_Handler_Test
Function            : This is the test class for FS_Email_Handler.
Author              : Infosys
Modification Log    : FACT R1 2018
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Denit            3/07/2018         This is the test class for FS_Email_Handler.	
*************************************************************************************/
@isTest
public class FS_Email_Handler_Test
{
    static testMethod void TestinBoundEmail()
    {
      //Inserting a cse Record  
      Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(FSConstants.RECORD_TYPE_NAME_LMCASE).getRecordTypeId();
      Case caseInstance=new Case();
      caseInstance.Status=FSConstants.STATUS_ASSIGNED;           
      caseInstance.recordtypeId=caseRecordTypeId;  
      caseInstance.Issue_Name__c='Testissue';
      caseInstance.LM_Sub_Status__c=FSConstants.FINANCE_ON_HOLD;
      caseInstance.FS_New_Case_Type__c=FSConstants.JDE_INITIATED_AMOA;    
      caseInstance.Priority='High';      
      insert caseInstance;
      
       // create a new email and envelope object  	 
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      Case casenumber =[select casenumber from case where id =: caseInstance.id];
      // setup the data for the email
      email.subject = 'Finance On Hold #'+casenumber.CaseNumber+'# has been assigned to Revenue Shared Services for JDEEQUIP processing';
      email.fromAddress ='someaddress@email.com';
      email.plainTextBody = 'email body\n2225256325\nTitle';
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
      
      // add an Text atatchment  
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
      // call the email service class and test it with the data in the testMethod
      FS_Email_Handler  testInbound=new FS_Email_Handler ();
      testInbound.handleInboundEmail(email, env);        
      Messaging.InboundEmailResult result = testInbound.handleInboundEmail(email, env);
      System.assertEquals( result.success  ,true);   
    
    }    
}