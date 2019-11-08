/**************************************************************************************
Apex Class Name     : FACT_CaseTriggerHandlerTest
Function            : This is a Test class for handling all Unit test methods for FACT_CaseTriggerHandler class.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Vishnu M            08/10/2017       First version for handling unit test methods for all methods in 
                                       FACT_CaseTriggerHandler class.
* Sunil TD            08/17/2017       Updated to cover Case Email Notification delete scenario on OD change.
*					  06/18/2018	   Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest(SeeAllData=false)
public class FACT_CaseTriggerHandlerTest {
    
    public static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Connectivity Solution').getRecordTypeId();
    public static Id outletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId();
    public static Id outletDispenserRecordTypeId = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(FSConstants.RT_NAME_CCNA_OD).getRecordTypeId();
    public static Id hqRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Headquarters').getRecordTypeId();
     public static Id caseLMRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Linkage Management').getRecordTypeId();
    @testSetup
    public static void dataSetup()
    {
        Account hqAccount = insertHeadQuarters('HeadQuarters');
        Account hqAccount1 = insertHeadQuarters('HeadQuarters1');
        User user1 = insertUser('Sunil','sun@infy.com.fet','System Administrator');
        User user2 = insertUser('Vishnu','vish@infy.com.fet','System Administrator');
        insertAccountTeamMember(hqAccount,user1);
        insertAccountTeamMember(hqAccount,user2);
        Account accRecord = insertoutletRecord('TestOutlet',hqAccount);
        Account accRecordDuplicate = insertoutletRecord('TestOutlet1',hqAccount1);
        FS_Outlet_Dispenser__c odRecord = insertOutletDispenser('ZPL123456',accRecord);
       // insertOutletDispenser('ZPL123987',accRecord);
        insertOutletDispenser('ZPL123321',accRecordDuplicate);
        Case caseRecord = insertCaseRecord('Testissue',odRecord);
        insertEmailDetails(true,true,'COM','abc@def.com','TestUser',caseRecord);
        insertEmailDetails(true,true,'COM','abc1@def.com','TestUser1',caseRecord);
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
    public static User insertUser(String userName,String UserMail,String profileName)
    {
        User userRecord = new User();
        try{
            userRecord.LastName=userName;
            userRecord.Alias=userName;
            userRecord.Email='abc@def.com';
            userRecord.Username=UserMail;
            userRecord.TimeZoneSidKey='America/Los_Angeles';
            profile id1=[select id from profile where name=:profileName];
            userRecord.ProfileId=id1.id;
            userRecord.LocaleSidKey='en_US';
            userRecord.EmailEncodingKey='ISO-8859-1';
            userRecord.LanguageLocaleKey='en_US';
            insert userRecord;
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
            AccountTeamMember__c accTeamMember = new AccountTeamMember__c();
            accTeamMember.TeamMemberRole__c = 'COM';
            accTeamMember.UserId__c = userRecord.Id;
            accTeamMember.AccountId__c = hqRecord.Id;
            insert accTeamMember;
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
            //insert accountRecord;
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
            insert accountRecord;
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
            //caseInstance.FACT_Select_Dispenser__c = null; //FACT R1 2018 : Deleted Connectivity summary object
            caseInstance.recordtypeId = caseRecordTypeId;
            caseInstance.Issue_Name__c = issueName;
            if(outletDispenser != null)
            {
                caseInstance.FS_Outlet_Dispenser__c = outletDispenser.id;
            }
            insert caseInstance; 
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
    public static Case insertLMCaseRecord(String issueName,FS_Outlet_Dispenser__c outletDispenser)
    {
        Case caseInstance = new Case();
        try
        {
            caseInstance.Status = 'New';
            //caseInstance.FACT_Select_Dispenser__c = null; //FACT R1 2018 : Deleted Connectivity summary object
            caseInstance.recordtypeId = caseLMRecordTypeId;
            caseInstance.Issue_Name__c = issueName;
            if(outletDispenser != null)
            {
                caseInstance.FS_Outlet_Dispenser__c = outletDispenser.id;
            }
            insert caseInstance; 
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return caseInstance;
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
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
        Method : insertTask
        Description : Method for inserting Task records.
    ******************************************************************************************/
    public static Task insertTask(ID caseId)
    {
        Task taskRecord = new Task();
        try{
            taskRecord.OwnerId = [select Id from User where LastName = 'Vishnu'].Id;
            taskRecord.Subject = 'Other';
            taskRecord.Status = 'In Progress';
            taskRecord.Priority = 'Normal';
            taskRecord.WhatId = caseId;
            insert taskRecord;
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return taskRecord;
    }      
    
    public static testMethod void caseUpdate1()
    {
        Test.startTest();
        try
        {
          
            Case caseRecord1 = [select Id,RecordTypeId from Case Limit 1];
            caseRecord1.Status = 'Closed';
            Task taskRecord = insertTask(caseRecord1.id);
            update caseRecord1;
              system.debug('Inside CaseUpdate1 @@@@@'+caseRecord1);
            system.debug('Inside CaseUpdate1 RecordTypeId'+caseRecord1.RecordTypeId);
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('All tasks must be closed before closing the case') ? true : false;
          System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
     public static testMethod void caseUpdate2()
    {
        Test.startTest();
        try
        {
            Case caseRecord = [select Id from Case Limit 1];
            caseRecord.Status = 'Closed';
            //Task taskRecord = insertTask(caseRecord.id);
            update caseRecord;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('All tasks must be closed before closing the case') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    
    public static testMethod void outletDispenserUpdateTest()
    {
        try
        {
            Test.startTest();
            List<String> emailRoles;
            List<Case> caseRecord = [select Id,RecordTypeId from Case where status='New' Limit 1];
            FS_Outlet_Dispenser__c odRecord = [select Id from FS_Outlet_Dispenser__c where FS_Serial_Number2__c = 'ZPL123321'];
            Case cs = caseRecord[0];
            cs.FS_Outlet_Dispenser__c = odRecord.Id;
            update cs;
            List<Email_Details__c> emailList = [Select Id,Parent_Case__c from Email_Details__c where Parent_Case__c =: cs.id];
            //system.assertEquals(0,emailList.size());
            Test.stopTest();
        }
        catch(Exception ex)
        {            
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
  
}