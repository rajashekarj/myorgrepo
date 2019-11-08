/**************************************************************************************
Apex Class Name     : FS_SendEmail_HelperTest
Function            : This is a Test class for handling all Unit test methods for FS_SendEmail_Helper class.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD            07/26/2017       First version for handling unit test methods for all methods in 
                                       FS_SendEmail_Helper class.
*					  06/18/2018	   Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/

@isTest(SeeAllData=false)
public class FS_SendEmail_HelperTest {

    public static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Connectivity Solution').getRecordTypeId();
    public static Id outletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId();
    public static Id outletDispenserRecordTypeId = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(FSConstants.RT_NAME_CCNA_OD).getRecordTypeId();
    
    /*****************************************************************************************
        Method : dataSetup
        Description : Method for setting up the data required in this unit test class.
    ******************************************************************************************/
    @testSetup
    public static void dataSetup()
    {
        try
        {
            Account accRecord = insertoutletRecord();
            FS_Outlet_Dispenser__c odRecord = insertOutletDispenser();
            insertCaseRecord('Testissue',odRecord);
            insertCaseRecord('IssueTest',null);
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
        Method : insertoutletRecord
        Description : Method for inserting Outlet records.
    ******************************************************************************************/
    public static Account insertoutletRecord()
    {
        Account accountRecord = new Account();
        try
        {
            accountRecord.Name = 'TestOutlet';
            accountRecord.RecordTypeId = outletRecordTypeId;
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
    public static FS_Outlet_Dispenser__c insertOutletDispenser()
    {
        //create platform type custom settings
         FSTestUtil.insertPlatformTypeCustomSettings();
        
         //set mock callout
         Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FS_Outlet_Dispenser__c odRecord = new FS_Outlet_Dispenser__c();
        try
        {
            system.debug('inside OD ###');
            Account accountRecord = [select Id from Account where Name = 'TestOutlet'];
            odRecord.RecordTypeId = outletDispenserRecordTypeId;
            odRecord.FS_Outlet__c = accountRecord.Id;
            odRecord.FS_Serial_Number2__c = 'ZPL123456';
            insert odRecord;
            system.debug('inside OD $$$$');
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return odRecord;
    }
    
    /*****************************************************************************************
        Method : insertCaseRecord
        Description : Method for inserting Case records.
    Updated Date: Feb 2018
    ******************************************************************************************/
    public static void insertCaseRecord(String issueName,FS_Outlet_Dispenser__c outletDispenser)
    {
        try
        {
            Case caseInstance = new Case();
            caseInstance.Status = 'New';
            //caseInstance.FACT_Select_Dispenser__c = null; //FACT R1 2018: Deleted Connectivity Summary object
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
    }
    
    /*****************************************************************************************
        Method : insertTemplate
        Description : Method for inserting Email Template.
    ******************************************************************************************/
    public static EmailTemplate insertTemplate()
    {
        EmailTemplate validEmailTemplate = new EmailTemplate();
        try
        {
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'Test_Name';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.Subject = 'Test Subject';
            validEmailTemplate.Body = 'Test Body';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
        return validEmailTemplate;
    }
    
    /*****************************************************************************************
        Method : emailTest
        Description : Method for testing replaceMergeFieldValues method in FS_SendEmail_Helper class.
    ******************************************************************************************/
    public static testMethod void emailTest()
    {
        Test.startTest();
        EmailTemplate validEmailTemplate = insertTemplate();
        Case caseRecord = [select Id,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FACT_Case_Type__c,Description,
                           FS_Outlet_Name__c,FS_Address__c,FS_Resolution_Type__c,FS_Resolution_Comments__c,
                           Dispenser_serial_number__c from Case where Issue_Name__c = 'Testissue'];
        FS_SendEmail_Helper.replaceMergeFieldValues('TestName','abc@def.com',validEmailTemplate,caseRecord,false,null,null,false);
        FS_SendEmail_Helper.replaceMergeFieldValues('TestName','abc@def.com',validEmailTemplate,caseRecord,true,'Test','Test',false);
        FS_SendEmail_Helper.replaceMergeFieldValues('TestName','abc@def.com',validEmailTemplate,caseRecord,false,null,null,true);
        Test.stopTest();
    }
    
    /*****************************************************************************************
        Method : exceptionTest
        Description : Method for covering exceptions in FS_SendEmail_Helper class.
    ******************************************************************************************/
    public static testMethod void exceptionTest()
    {
        Test.startTest();
        EmailTemplate validEmailTemplate = new EmailTemplate();
        Case caseRecord = [select Id,CaseNumber,FS_Serial_Number__c,Subject,FS_ACN__c,FS_SAP__c,FACT_Case_Type__c,
                           FS_Outlet_Name__c,FS_Address__c,Dispenser_serial_number__c from Case 
                           where Issue_Name__c = 'IssueTest'];
        FS_SendEmail_Helper.replaceMergeFieldValues('TestName','abc@def.com',validEmailTemplate,caseRecord,false,null,null,false);
        FS_SendEmail_Helper.returnEmailObject(null,null,null,null,null);
        Test.stopTest();
    }
}