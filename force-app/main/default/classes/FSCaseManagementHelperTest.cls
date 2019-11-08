/**************************************************************************************
Apex Class Name     : FSCaseManagementHelperTest
Function            : This is a Test class for handling all Unit test methods for FSCaseManagementHelper class.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD            07/31/2017       First version for handling unit test methods for all methods in 
                                       FSCaseManagementHelper class.
*					  05/29/2018	   Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/

@isTest(SeeAllData=false)
public class FSCaseManagementHelperTest {

    public static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Connectivity Solution').getRecordTypeId();
    public static Id emtCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North American Case').getRecordTypeId();
    public static Id outletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId();
    public static Id hqRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Headquarters').getRecordTypeId();
    public static Id outletDispenserRecordTypeId = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get('CCNA Dispenser').getRecordTypeId();
    public static Id caseLMRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Linkage Management').getRecordTypeId();
    /*****************************************************************************************
        Method : dataSetup
        Description : Method for setting up the data required in this unit test class.
    ******************************************************************************************/
    @testSetup
    public static void dataSetup()
    {
        Account hqAccount = insertHeadQuarters('HeadQuarters');        
        User user1 = insertUser('Sunil','sun@infy.com.fet');
        User user2 = insertUser('Vishnu','vish@infy.com.fet');
        insertAccountTeamMember(hqAccount,user1);
        insertAccountTeamMember(hqAccount,user2);
        Account accRecord = insertoutletRecord('TestOutlet',hqAccount);             
        FS_Outlet_Dispenser__c odRecord = insertOutletDispenser('ZPL123456',accRecord);
         FS_Outlet_Dispenser__c odRecord2 = insertOutletDispenser('ZPL12345655',accRecord);
        FS_Outlet_Dispenser__c odRecor32 = insertOutletDispenser('ZPL555',accRecord);
        insertOutletDispenser('ZPL987654',accRecord);      
        Case caseRecord = insertCaseRecord('Testissue',odRecord);       
        insertCaseComment(caseRecord);  
        insertEmailDetails(true,true,'testRole','test@gmail.com','testUserNAme',caseRecord);
        insertCaseToOD(caseRecord,odRecord);
        
        Case caseLMRecord = insertLMCaseRecord('Testissue',accRecord);
        insertAttachToCase(caseLMRecord);
        FSTestUtil.insertPlatformTypeCustomSettings();  
        //insertTastToCase(caseRecord);
    }
    
    /*****************************************************************************************
        Method : insertCustomSetting
        Description : Method for inserting Custom Setting record.
    ******************************************************************************************/
    public static void insertCustomSetting()
    {
        try
        {
            Fact_EmailRoles__c customSetting = new Fact_EmailRoles__c();
            customSetting.Name = 'COM';
            customSetting.Role_Name__c = 'COM';
            customSetting.Case_Close__c = true;
            customSetting.Case_Comment__c = true;
            customSetting.Case_Create__c = true;
            insert customSetting;
            system.assertNotEquals(null, customSetting.Id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
        Method : insertUser
        Description : Method for inserting System User records.
    ******************************************************************************************/
    public static User insertUser(String userName,String userMail)
    {
        User userRecord = new User();
        try{
            userRecord.LastName=userName;
            userRecord.Alias=userName;
            userRecord.Email='abc@def.com';
            userRecord.Username=userMail;
            userRecord.TimeZoneSidKey='America/Los_Angeles';
            profile id1=[select id from profile where name='System Administrator'];
            userRecord.ProfileId=id1.id;
            userRecord.LocaleSidKey='en_US';
            userRecord.EmailEncodingKey='ISO-8859-1';
            userRecord.LanguageLocaleKey='en_US';
            insert userRecord;
            system.assertNotEquals(null, userRecord.Id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return userRecord;
    }
    
    /*****************************************************************************************
        Method : insertAccountTeamMember
        Description : Method for inserting Account Team Members records in Head Quarters.
    ******************************************************************************************/
    public static void insertAccountTeamMember(Account hqRecord,User userRecord)
    {
        try
        {	
            List<AccountTeamMember__c> accTM = New List<AccountTeamMember__c> ();
            AccountTeamMember__c accTeamMember = new AccountTeamMember__c();
            accTeamMember.TeamMemberRole__c = 'COM';
            accTeamMember.UserId__c = userRecord.Id;
            accTeamMember.AccountId__c = hqRecord.Id;
            //insert accTeamMember;
            accTM.add(accTeamMember);
             AccountTeamMember__c accTeamMember1 = new AccountTeamMember__c();
            accTeamMember1.TeamMemberRole__c = 'COM';
            accTeamMember1.UserId__c =NULL;
            accTeamMember1.AccountId__c = hqRecord.Id;
            accTM.add(accTeamMember1);
            Insert accTM;
            system.assertNotEquals(0, accTM.size());
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
        Method : insertHeadQuarters
        Description : Method for inserting Head Quarters records.
    ******************************************************************************************/
    public static Account insertHeadQuarters(String hqName)
    {
        Account accountRecord = new Account();
        try
        {
            accountRecord.Name = hqName;
            accountRecord.RecordTypeId = hqRecordTypeId;
            insert accountRecord;
            system.assertNotEquals(null, accountRecord.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return accountRecord;
    }
    
    /*****************************************************************************************
        Method : insertoutletRecord
        Description : Method for inserting Outlet records.
    ******************************************************************************************/
    public static Account insertoutletRecord(String outletName,Account hqRecord)
    {
        Account accountRecord = new Account();
        try
        {
            accountRecord.Name = outletName;
            accountRecord.RecordTypeId = outletRecordTypeId;
            accountRecord.FS_Headquarters__c = hqRecord.Id;
            accountRecord.FS_ACN__c='1234321';
            accountRecord.ShippingCountry='US';
            insert accountRecord;
            system.assertNotEquals(null, accountRecord.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return accountRecord;
    }
    
    /*****************************************************************************************
        Method : insertOutletDispenser
        Description : Method for inserting Outlet Dispenser records.
    ******************************************************************************************/
    public static FS_Outlet_Dispenser__c insertOutletDispenser(String serial,Account accountRecord)
    {
        //create platform type custom settings
         FSTestUtil.insertPlatformTypeCustomSettings();
        
         //set mock callout
         Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FS_Outlet_Dispenser__c odRecord = new FS_Outlet_Dispenser__c();
        try
        {
            odRecord.RecordTypeId = outletDispenserRecordTypeId;
            odRecord.FS_Outlet__c = accountRecord.Id;
            odRecord.FS_Serial_Number2__c = serial;
            
            insert odRecord;
            system.assertNotEquals(null, odRecord.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return odRecord;
    }
    
    /*****************************************************************************************
        Method : insertCaseRecord
        Description : Method for inserting Outlet Dispenser records.
    ******************************************************************************************/
    public static Case insertCaseRecord(String issueName,FS_Outlet_Dispenser__c outletDispenser)
    {
        Case caseInstance = new Case();
        try
        {
            caseInstance.Status = 'New';
            //caseInstance.FACT_Select_Dispenser__c = null;
            caseInstance.recordtypeId = caseRecordTypeId;
            caseInstance.Issue_Name__c = issueName;
            if(outletDispenser != null)
            {
                caseInstance.FS_Outlet_Dispenser__c = outletDispenser.id;
            }
            insert caseInstance;
            system.assertNotEquals(null, caseInstance.id); 
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return caseInstance;
    }
        /*****************************************************************************************
        Method : insertCaseRecord
        Description : Method for inserting LM Case records.
    ******************************************************************************************/
    public static Case insertLMCaseRecord(String issueName,Account accRec)
    {
        Case caseInstance = new Case();
        try
        {
            caseInstance.Status = 'New';
            //caseInstance.FACT_Select_Dispenser__c = null;
            caseInstance.recordtypeId = caseLMRecordTypeId;
            caseInstance.Issue_Name__c = issueName;
            caseInstance.FACT_Case_Type__c='Connectivity Issue';
            caseInstance.LM_Sub_Status__c =FSConstants.JDE_AMS_ON_HOLD;
            caseInstance.FS_New_Case_Type__c=FSConstants.JDE_INITIATED_AMOA;
            if(accRec!= null)
            {
                caseInstance.To_Account__c = accRec.id;
            }
            insert caseInstance;
            system.assertNotEquals(null, caseInstance.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return caseInstance;
    }
    /*****************************************************************************************
        Method : insertCaseComment
        Description : Method for inserting Case Comment records.
    ******************************************************************************************/
    public static void insertCaseComment(Case caseInstance)
    {
        try
        {
            CaseComment caseCommentRecord = new CaseComment();
            caseCommentRecord.ParentId = caseInstance.Id;
            caseCommentRecord.CommentBody = 'TestBody';
            insert caseCommentRecord;
            system.assertNotEquals(null, caseCommentRecord.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
        Method : insertEmailDetails
        Description : Method for inserting Case Email Notification records.
    ******************************************************************************************/
    public static void insertEmailDetails(Boolean userPresent,Boolean creationMailFlag,String roleName,String userEmail,String userName,Case caseInstance)
    {
        try
        {
            Email_Details__c emailDetails = new Email_Details__c();
            emailDetails.User_Name__c = userName;
            emailDetails.User_Email__c = userEmail;
            emailDetails.Parent_Case__c = caseInstance.Id;
            emailDetails.Send_Email__c = userPresent;
            emailDetails.User_Role__c = roleName;
            emailDetails.Creation_Mail_Flag__c = creationMailFlag;
            insert emailDetails;
            system.assertNotEquals(null, emailDetails.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
        
    /*****************************************************************************************
        Method : insertEmailDetails
        Description : Method for inserting Case To OD records.
    ******************************************************************************************/
    public static void insertCaseToOD(Case caseInstance,FS_Outlet_Dispenser__c outletDispenser )
    {
        try
        {
            CaseToOutletdispenser__c caseToOD = new CaseToOutletdispenser__c();
            caseToOD.Case__c = caseInstance.Id;
            caseToOD.Outlet_Dispenser__c = outletDispenser.Id;
           
            insert caseToOD;
            system.assertNotEquals(null, caseToOD.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
    
    public static Task insertTask(ID caseId)
    {
        Task taskRecord = new Task();
        try{
           // taskRecord.OwnerId = [select Id from User where LastName = 'Vishnu'].Id;
            taskRecord.Subject = 'Other';
            taskRecord.Status = 'Completed';
           // taskRecord.Priority = 'Normal';
            taskRecord.WhatId = caseId;
            insert taskRecord;
            system.assertNotEquals(null, taskRecord.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return taskRecord;
    }
        /*****************************************************************************************

        Description : Method for attachement  To Case.
    ******************************************************************************************/
    public static void insertAttachToCase(Case caseInstance)
    {
        try
        {
            Attachment att = new Attachment();
            att.ParentId = caseInstance.Id;
           att.Name='Email';
           
           
            insert att;
            system.assertNotEquals(null, att.id);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
    /*****************************************************************************************
        Method : emailRolesTest
        Description : Method for testing getAllEmailRoles method in FSCaseManagementHelper Class.
    ******************************************************************************************/
    public static testMethod void emailRolesTest()
    {
        try
        {
            Test.startTest();
            insertCustomSetting();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId from Case where status='New' Limit 1];
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
            emailRoles = caseManagement.getAllEmailRoles(true,false,false);
            caseManagement.getAllEmailRoles(false,true,false);
            caseManagement.getAllEmailRoles(false,false,true);
            caseManagement.getAllEmailRoles(false,false,false);
            caseManagement.createCaseHistory(emailRoles,caseRecord);
            List<Email_Details__c> emailDetails = [Select Id from Email_Details__c where Parent_Case__c =: caseRecord[0].Id];
            system.assertEquals(5, emailDetails.size());
            Test.stopTest();
        }
        catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
        Method : closureEmailTest
        Description : Method for testing sendMailOnCaseClose and sendMailOnCaseComment method in FSCaseManagementHelper Class.
    ******************************************************************************************/
    public static testMethod void closureEmailTest()
    {
        try
        {
            Test.startTest();
            insertCustomSetting();
            List<Case> caseRecord = [select Id,RecordTypeId from Case where status='New' Limit 1];
            insertEmailDetails(true,true,'COM','abc@def.com','TestUser',caseRecord[0]);
            insertEmailDetails(true,true,'COM','abc1@def.com','TestUser1',caseRecord[0]);
            List<String> emailRoles;
            Case cs = caseRecord[0];
            cs.Status = 'Closed';
            update cs;
            caseRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,
                          FACT_Case_Type__c,Description,Dispenser_serial_number__c from Case where status='Closed' Limit 1];
            CaseComment commentRecord = [select Id,ParentId,CommentBody,createdBy.Name from CaseComment Limit 1];
            Map<Id,caseComment> commentMap = new Map<Id,caseComment>();
            Map<Id,String> commentBy = new Map<Id,String>();
            commentMap.put(commentRecord.ParentId,commentRecord);
            commentBy.put(commentRecord.ParentId,commentRecord.createdBy.Name);
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
            emailRoles = caseManagement.getAllEmailRoles(false,true,false);
            caseManagement.sendMailOnCaseClose(emailRoles,caseRecord);
            caseManagement.sendMailOnCaseComment(emailRoles,caseRecord,commentMap,commentBy);
            List<Email_Details__c> emailDetails = [Select Id from Email_Details__c where Parent_Case__c =: caseRecord[0].Id and Closure_Mail_Flag__c = true];
            system.assertEquals(2, emailDetails.size());
            Test.stopTest();
        }
        catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
        Method : closureEmailTest
        Description : Method for covering exceptions in FSCaseManagementHelper Class.
    ******************************************************************************************/
    public static testMethod void exceptionTest()
    {
       try
        {
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where status='New' Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Closed';
            update cs;
            List<FS_Outlet_Dispenser__c> odRecords = new List<FS_Outlet_Dispenser__c>();
            odRecords = [select Id,FS_Outlet__r.FS_Headquarters__c from FS_Outlet_Dispenser__c where Id=:cs.FS_Outlet_Dispenser__c];
            
            caseRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,
                          FACT_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c  from Case where status='Closed' Limit 1];
            Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            For(Case cs1:caseRecord){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
                caseWithOD.put(cs1.Id, odRecords[0]);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
            caseManagement.sendMailOnCaseClose(null,caseRecord);
            caseManagement.sendMailOnCaseComment(emailRoles,caseRecord,null,null);
            caseManagement.sendMail(null,null);
            caseManagement.caseIdMap(null);
            caseManagement.insertEmailRoles(null,null);
            caseManagement.getAllEmailRoles(null,null,null);
            caseManagement.caseID(null);
            caseManagement.caseIDMapEMT(null);
            caseManagement.checkOpenTask(NULL);
            caseManagement.insertOutletDispenser(null);
            caseManagement.caseMapEMTDetails(null,null);
            caseManagement.updateDeleteList(null,null,null);
            caseManagement.deleteOldDispenserData(null,null);
            caseManagement.updateOutletDispenser(null,null);
          //
           // caseManagement.hqList(Null);
            system.assertNotEquals(0, caseWithOD.size());
            //caseManagement.compareHQ(Null,Null);
        }
        catch(Exception ex)
        {
            system.assertEquals('nullpointer exception',ex.getMessage());
        }        
    }
        /*****************************************************************************************
        Method : closureEmailTest
        Description : Method for covering exceptions in FSCaseManagementHelper Class.
    ******************************************************************************************/
    public static testMethod void TestingAll()
    {
      try
     { 
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where status='New' Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Closed';
            update cs;
            List<FS_Outlet_Dispenser__c> odRecords = new List<FS_Outlet_Dispenser__c>();
            List<Email_Details__c> emailList = [select Id,Parent_Case__c from Email_Details__c 
                                                where Parent_Case__c IN: caseRecord];
            odRecords = [select Id,FS_Outlet__r.FS_Headquarters__c from FS_Outlet_Dispenser__c where Id=:cs.FS_Outlet_Dispenser__c];
            
            caseRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Closed' Limit 1];
            Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
            List<CaseToOutletdispenser__c> caseToODValue =[Select Id,Name,Case__c,Outlet_Dispenser__c,Outlet_Dispenser__r.FS_ACN_NBR__c,Outlet_Dispenser__r.FS_Serial_Number2__c 
                                                           FROM CaseToOutletdispenser__c WHERE Case__c IN: caseRecord];
            For(Case cs1:caseRecord){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
                caseWithOD.put(cs1.Id, odRecords[0]);
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
         system.assertNotEquals(null, cs.id);
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
            
           caseManagement.hqList(outletDispenserRecord);
            //caseManagement.hqList(Null);
           
            caseManagement.compareHQ(Null,Null);
            caseManagement.compareHQ(caseWithOD,caseWithOD);
          caseManagement.deleteNotificationUsers(caseIDMap,caseIDs);
            // caseManagement.deleteNotificationUsers(Null,Null);
            caseManagement.caseMapCreation(caseToODValue);
            caseManagement.caseMapCreation(Null);
        caseManagement.updateDeleteList(cs.Id,caseToODValue,caseIDMap);
         caseManagement.deleteOldDispenserData(caseIDMap,caseIDMap);
          //caseManagement.insertEMTCases(caseIDMap,caseIDMap);
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
    
  
    public static testMethod void TestingLM()
    {
        try
     { 
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.FINANCE_ON_HOLD;
            //cs.FS_New_Case_Type__c=FSConstants.JDE_INITIATED_AMOA;
            update cs;
         system.assertNotEquals(null, cs.id);

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' Limit 1];
           
        /* Attachment att = new Attachment();
         att.ParentId = caseNewRecord[0].Id;
         att.Name='Email';
         Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
         att.Body=bodyBlob;
         insert att;
           List<Attachment> attList=[select Name, Body, BodyLength from Attachment where ParentId IN : caseNewRecord]; */
         
         //insert contentversion
            ContentVersion contentVersion = new ContentVersion(Title = 'AMOA From Penguins',PathOnClient = 'Penguins.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion; 
            id contentVersionId = contentVersion.id;
            //insert content document link
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 10];
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = caseNewRecord[0].Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
           // system.debug('2222'+attList);
            
           For(Case cs1:caseRecord){
              
           
                caseIDMap.put(cs1.Id,cs1);
            
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord,caseIDMap);
          
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
    public static testMethod void TestingLM1()
    {
        try
     { 
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.JDE_INSTALL_BASE_NOTIFIED;
            //cs.FS_New_Case_Type__c=FSConstants.JDE_INITIATED_AMOA;
            update cs;
         system.assertNotEquals(null, cs.id);
     

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' Limit 1];
           
         Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
           For(Case cs1:caseRecord){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
           
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord,caseIDMap);
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
     public static testMethod void TestingLM2()
    {
        try
     { 
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.JDE_AMS_ON_HOLD;
            cs.FS_New_Case_Type__c=FSConstants.JDE_LINKAGE_REQUEST;
            update cs;
         system.assertNotEquals(null, cs.id);

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' Limit 1];
           
         Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
           For(Case cs1:caseRecord){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
           
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord,caseIDMap);
        
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
         public static testMethod void TestingLM3()
    {
        try
     { 
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.PENDING_INSTALL;
            cs.FS_New_Case_Type__c=FSConstants.JDE_INITIATED_AMOA;
            update cs;
         system.assertNotEquals(null, cs.id);

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' Limit 1];
           
         Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
           For(Case cs1:caseRecord){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
           
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord,caseIDMap);
        
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
    public static testMethod void TestingLM4()
    {
        try
     { 
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.PENDING_INSTALL;
            cs.FS_New_Case_Type__c=FSConstants.ACCOUNT_TEAM_INITIATED_AMOA;
            update cs;
         system.assertNotEquals(null, cs.id);

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' Limit 1];
           
         Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
           For(Case cs1:caseRecord){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
           
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord,caseIDMap);
        
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
    
    public static testMethod void TestingLM5()
    {
        try
     { 
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.PENDING_INSTALL;
            cs.FS_New_Case_Type__c=FSConstants.JDE_LINKAGE_REQUEST;
            update cs;
         system.assertNotEquals(null, cs.id);

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' Limit 1];
           
         Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
           For(Case cs1:caseRecord){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
           
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord,caseIDMap);
        
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
    
        public static testMethod void TestingLM6()
    {
        try
     { 
            Test.startTest();
          
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.FINANCE_ON_HOLD;
            cs.FS_New_Case_Type__c=FSConstants.ACCOUNT_TEAM_INITIATED_AMOA;
            update cs;
         system.assertNotEquals(null, cs.id);
      List<Case> caseRecord1 = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,LM_Sub_Status__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId AND LM_Sub_Status__c=: FSConstants.FINANCE_ON_HOLD Limit 1];
		Case csnew = caseRecord[0];
         csnew.Status = 'Assigned';
          csnew.LM_Sub_Status__c =FSConstants.JDE_AMS_ON_HOLD;
            csnew.FS_New_Case_Type__c=FSConstants.JDE_INITIATED_AMOA;
            update csnew;

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' AND LM_Sub_Status__c =: FSConstants.JDE_AMS_ON_HOLD Limit 1];
           
         Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
           For(Case cs1:caseRecord1){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
           
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord1,caseIDMap);
        
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
    
     public static testMethod void TestingLM7()
    {
        try
     { 
            Test.startTest();
          
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.FINANCE_ON_HOLD;
            cs.FS_New_Case_Type__c=FSConstants.ACCOUNT_TEAM_INITIATED_AMOA;
            update cs;
         system.assertNotEquals(null, cs.id);
      List<Case> caseRecord1 = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,LM_Sub_Status__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId AND LM_Sub_Status__c=: FSConstants.FINANCE_ON_HOLD Limit 1];
		Case csnew = caseRecord[0];
         csnew.Status = 'Assigned';
          csnew.LM_Sub_Status__c =FSConstants.JDE_AMS_ON_HOLD;
            csnew.FS_New_Case_Type__c=FSConstants.JDE_LINKAGE_REQUEST;
            update csnew;

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' AND LM_Sub_Status__c =: FSConstants.JDE_AMS_ON_HOLD Limit 1];
           
         Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
           For(Case cs1:caseRecord1){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
           
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord1,caseIDMap);
        
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
    
    public static testMethod void TestingLM8()
    {
        try
     { 
            Test.startTest();
          
            List<Case> caseRecord = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            cs.Status = 'Assigned';
          cs.LM_Sub_Status__c =FSConstants.JDE_AMS_ON_HOLD;
            cs.FS_New_Case_Type__c=FSConstants.JDE_INITIATED_AMOA;
            update cs;
      List<Case> caseRecord1 = [select Id,RecordTypeId,FS_Outlet_Dispenser__c,LM_Sub_Status__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId AND LM_Sub_Status__c=: FSConstants.JDE_AMS_ON_HOLD Limit 1];
		Case csnew = caseRecord1[0];
         csnew.Status = 'Assigned';
          csnew.LM_Sub_Status__c =FSConstants.FINANCE_ON_HOLD;
            csnew.FS_New_Case_Type__c=FSConstants.ACCOUNT_TEAM_INITIATED_AMOA;
            update csnew;

             List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                          FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status='Assigned' AND LM_Sub_Status__c =: FSConstants.FINANCE_ON_HOLD Limit 1];
           
         Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
           For(Case cs1:caseRecord1){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
           
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         caseManagement.sendEmailToExternal(caseNewRecord,caseRecord1,caseIDMap);
         system.assertNotEquals(null, cs.id);
        
       }
        catch(Exception ex)
        {
           system.assertEquals('nullpointer exception',ex.getMessage());
      }        
    }
    static testmethod void Testmethodnew(){
     	test.starttest();
        String timeZone = UserInfo.getTimeZone().getID();
        Datetime dateGMT=System.now();
        Datetime d1=Datetime.valueOf(dateGMT);
        string s1=d1.format();
        String t1 = FSConstants.getLocalTime();
		test.stoptest();
        system.assertEquals(s1, t1);
    }
    
    //Added as part of FET-7.0 FNF-366
    public static testMethod void TestingLM9()
    {
        try
        { 
            Test.startTest();            
            List<Case> caseRecord = [select Id, casenumber,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];            
            List<Account> a = [SELECT Id FROM Account WHERE RecordTypeId =: outletRecordTypeId LIMIT 1];
            List<Account> hq = [SELECT Id FROM Account WHERE RecordTypeId =: hqRecordTypeId LIMIT 1];
            List<User> u = [Select Id FROM User LIMIT 1];            
            FS_Execution_Plan__c e = new FS_Execution_Plan__c();
            e.FS_Platform_Type__c = '7000';
            e.Name = 'test';
            e.FS_Headquarters__c = hq[0].id;
            insert e;            
            FS_Installation__c i = new FS_Installation__c();
            i.RecordTypeId = Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('Relocation (O4W)').getRecordTypeId();
            i.FS_Outlet__c = a[0].Id;
            i.FS_COM_Regular__c = u[0].Id;
            i.FS_Entering_COM__c = u[0].Id;
            i.FS_PM_Execution__c = u[0].Id;
            i.Type_of_Dispenser_Platform__c = '7000';
            i.FS_Reason_Code__c = 'Relocation Outside of 4 Walls';
            i.FS_Sub_Reason_Code__c = 'Old Outlet Going Out of Business';
            i.FS_Scope_of_Work__c = 'Test';
            i.FS_Did_BAST_initiate_this_RO4W__c = 'Yes';
            i.FS_Execution_Plan__c = e.id;
            i.FS_To_Outlet_Name__c = a[0].id;
            i.FS_Freestyle_Support_Tool_Case__c = cs.casenumber;
            insert i;                 
            cs.Status = 'Closed';
            cs.LM_Sub_Status__c =FSConstants.JDE_AMS_ON_HOLD;
            cs.FS_New_Case_Type__c='Account Team Initiated AMOA';
            update cs;
            system.assertNotEquals(null, i.id);
            
        }
        catch(Exception ex)
        {
            system.assertEquals('nullpointer exception',ex.getMessage());
        }        
    }
    
    public static testMethod void TestingLM10()
    {
        try
        { 
            Test.startTest();            
            List<Case> caseRecord = [SELECT Id, casenumber,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c FROM Case WHERE RecordTypeId=:caseLMRecordTypeId LIMIT 1];
            Case cs = caseRecord[0];            
            List<Account> a = [SELECT Id FROM Account WHERE RecordTypeId =: outletRecordTypeId LIMIT 1];
            List<Account> hq = [SELECT Id FROM Account WHERE RecordTypeId =: hqRecordTypeId LIMIT 1];
            List<User> u = [Select Id FROM User LIMIT 1];            
            FS_Execution_Plan__c e = new FS_Execution_Plan__c();
            e.FS_Platform_Type__c = '7000';
            e.Name = 'test';
            e.FS_Headquarters__c = hq[0].id;
            insert e;            
            FS_Installation__c i = new FS_Installation__c();
            i.RecordTypeId = Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('Relocation (O4W)').getRecordTypeId();
            i.FS_Outlet__c = a[0].Id;
            i.FS_COM_Regular__c = u[0].Id;
            i.FS_Entering_COM__c = u[0].Id;
            i.FS_PM_Execution__c = u[0].Id;
            i.Type_of_Dispenser_Platform__c = '7000';
            i.FS_Reason_Code__c = 'Relocation Outside of 4 Walls';
            i.FS_Sub_Reason_Code__c = 'Old Outlet Going Out of Business';
            i.FS_Scope_of_Work__c = 'Test';
            i.FS_Did_BAST_initiate_this_RO4W__c = 'Yes';
            i.FS_Execution_Plan__c = e.id;
            i.FS_Freestyle_Support_Tool_Case__c = cs.casenumber;
            insert i;                 
            cs.Status = 'Closed';
            cs.LM_Sub_Status__c =FSConstants.JDE_AMS_ON_HOLD;
            cs.FS_New_Case_Type__c='Account Team Initiated AMOA';
            update cs;  
            system.assertNotEquals(null, i.id);
        }
        catch(Exception ex)
        {
            system.assertEquals('nullpointer exception',ex.getMessage());
        }        
    }
    
    public static testMethod void TestingLM11()
    {
        try
        { 	
            insert new Disable_Trigger__c(name='FSODBusinessProcess',IsActive__c=false); 
            FS_EmailAddressForRSSJDE__c emailadd = new FS_EmailAddressForRSSJDE__c();
            emailadd.FS_Email_Address__c = 'anirudh.madhusudan@infosys.com';
            emailadd.Name = 'Install Base User Group';
            emailadd.FS_InstallBase__c = true;
            emailadd.FS_RSS__c = true;
            insert emailadd;
            
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,LM_Sub_Status__c, FS_New_Case_Type__c,RecordTypeId,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_Outlet__c from Case where RecordTypeId=:caseLMRecordTypeId Limit 1];
            Case cs = caseRecord[0];
            system.debug('sub status: '+cs.LM_Sub_Status__c);
            cs.Status = FSConstants.STATUS_ASSIGNED;
            cs.LM_Sub_Status__c =FSConstants.FINANCE_ON_HOLD;
            cs.FS_New_Case_Type__c=FSConstants.ACCOUNTTEAMINITIATEDAMOA;
            update cs;

            
            List<Case> caseNewRecord = [select Id,RecordTypeId,status,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c,
                                        FACT_Case_Type__c,LM_Sub_Status__c,FS_New_Case_Type__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c  from Case where status=:FSConstants.STATUS_ASSIGNED Limit 1];
            system.debug('sub status: '+caseNewRecord[0].LM_Sub_Status__c);
            system.debug('case type: '+caseNewRecord[0].FS_New_Case_Type__c);
            system.debug('status: '+caseNewRecord[0].status);

            Map<Id,Id> outletDispenserRecord = New Map<Id,Id> ();
            Map<Id,FS_Outlet_Dispenser__c> caseWithOD = New Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,Case> caseIDMap = New Map<Id,Case> ();
            List<Id> caseIDs = New List<Id>();
            
            For(Case cs1:caseRecord){
                outletDispenserRecord.put(cs1.Id, cs1.FS_Outlet_Dispenser__c); 
                
                caseIDMap.put(cs1.Id,cs1);
                caseIDs.add(cs1.Id);
            }
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
            caseManagement.sendEmailToExternal(caseNewRecord,caseRecord,caseIDMap);
            system.assertNotEquals(null, cs.id);
            
        }
        catch(Exception ex)
        {
            system.assertEquals('nullpointer exception',ex.getMessage());
        }        
    }
}