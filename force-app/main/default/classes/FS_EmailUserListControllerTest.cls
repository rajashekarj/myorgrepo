/**************************************************************************************
Apex Class Name     : FS_EmailUserListControllerTest
Function            : This is a Test class for handling all Unit test methods for FS_EmailUserListController class.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD            07/31/2017       First version for handling unit test methods for all methods in 
                                       FS_EmailUserListController class.
*					  06/18/2018	   Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/

@isTest(SeeAllData=false)
public class FS_EmailUserListControllerTest {
    
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
        insertCustomSetting();
        Account accRecord = insertoutletRecord();
        FS_Outlet_Dispenser__c odRecord = insertOutletDispenser();
        insertCaseRecord(odRecord);
        insertEmailDetails(false,false,'COM','abc@def.com');
        insertEmailDetails(true,false,'COM','abc@def.com');
        insertEmailDetails(true,true,'COM','abc@def.com');
        insertEmailDetails(true,false,'ABC','abc@def.com');
        insertEmailDetails(true,false,'ABC',null);
    }
    
    /*****************************************************************************************
        Method : insertCustomSetting
        Description : Method for setting up Custom Setting data.
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
            Account accountRecord = [select Id from Account where Name = 'TestOutlet'];
            odRecord.RecordTypeId = outletDispenserRecordTypeId;
            odRecord.FS_Outlet__c = accountRecord.Id;
            odRecord.FS_Serial_Number2__c = 'ZPL123456';
            insert odRecord;
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }        
        return odRecord;
    }
    
    /*****************************************************************************************
        Method : insertEmailDetails
        Description : Method for inserting Case Email Notification records.
    ******************************************************************************************/
    public static void insertEmailDetails(Boolean userPresent,Boolean creationMailFlag,String roleName,String userEmail)
    {
        try
        {
            Case caseInstance = [select Id from Case Limit 1];
            Email_Details__c emailDetails = new Email_Details__c();
            emailDetails.User_Name__c = 'TestUser';
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
        Method : insertCaseRecord
        Description : Method for inserting Case records.
    ******************************************************************************************/
    public static void insertCaseRecord(FS_Outlet_Dispenser__c outletDispenser)
    {
        try
        {
            Case caseInstance = new Case();
            caseInstance.Status = 'New';
            //caseInstance.FACT_Select_Dispenser__c = null; //FACT R1 2018 : Deleted Connectivity summary object
            caseInstance.recordtypeId = caseRecordTypeId;
            caseInstance.Issue_Name__c = 'TestIssue';
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
        Method : caseTest
        Description : Method for testing saveSendEmail method from FS_EmailUserListController class.
    ******************************************************************************************/
    public static testMethod void caseTest()
    {
        try{
            Test.startTest();
            PageReference pageRef;
            Case caseRecord = [select Id from Case Limit 1];
            system.debug(caseRecord);
            pageRef = Page.FS_VF_EmailUserList;
            pageRef.getParameters().put('id',caseRecord.Id);
            Test.setCurrentPage(pageRef);
            FS_EmailUserListController emailUser = new FS_EmailUserListController(new ApexPages.StandardController(caseRecord));
            emailUser.saveSendEmail();
            Test.stopTest();
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        } 
        
    }
    
    /*****************************************************************************************
        Method : exceptionTest
        Description : Method for covering exceptions in FS_EmailUserListController class.
    ******************************************************************************************/
    public static testMethod void exceptionTest()
    {
        Test.startTest();
        PageReference pageRef;
        pageRef = Page.FS_VF_EmailUserList;        
        Case caseRecord = new Case();
        pageRef.getParameters().put('id',caseRecord.Id);
        Test.setCurrentPage(pageRef);
        FS_EmailUserListController emailUser = new FS_EmailUserListController(new ApexPages.StandardController(caseRecord));
        emailUser.checkUserPresent(null,null,null);
        Test.stopTest();
    }
}