/**************************************************************************************
Apex Class Name     : FS_CaseUpdateBatchTest
Version             : 1.0
Function            : This is the test class for FS_CaseUpdateBatch class. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  06/18/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest 
public class FS_CaseUpdateBatchTest
{
   public static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Connectivity Solution').getRecordTypeId();
   public static Id outletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId();
   public static Id outletDispenserRecordTypeId = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(FSConstants.RT_NAME_CCNA_OD).getRecordTypeId();
   //public static Id dispenerIssueRecordTypeId = Schema.SObjectType.FACT_Dispenser_Connectivity_IssueTracker__c.getRecordTypeInfosByName().get('Dispenser Issues').getRecordTypeId();
      
   @testSetup
    public static void dataSetup()
    {
        Account accRecord = insertoutletRecord();
        FS_Outlet_Dispenser__c odRecord = insertOutletDispenser();
        Case caseRecord = insertCaseRecord(odRecord);
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
        accountRecord.FS_ACN__c = '1001001010';
        insert accountRecord;
        }
        
            catch(Exception e)
       {
         system.debug('Exception'+e.getMessage());
       }
        
        return accountRecord;
    }
    
    /*****************************************************************************************
        Method : insertOutletDispenser
        Description : Method for inserting Outlet Dispenser records.
    ******************************************************************************************/
    public static FS_Outlet_Dispenser__c insertOutletDispenser()
    {
        FS_Outlet_Dispenser__c odRecord = new FS_Outlet_Dispenser__c();
        try
        {
        Account accountRecord = [select Id from Account where Name = 'TestOutlet'];
        
        odRecord.RecordTypeId = outletDispenserRecordTypeId;
        odRecord.FS_Outlet__c = accountRecord.Id;
        odRecord.FS_Serial_Number2__c = 'ZPL123456';
        
            
        insert odRecord;
        } 
        catch(Exception e)
        {
             system.debug('Exception'+e.getMessage());
        }
        return odRecord;
    }
    
     /*****************************************************************************************
        Method : insertConnectivitySummary
        Description : Method for inserting Connectivity Summary records.
    ******************************************************************************************/
    /*public static FACT_Dispenser_Connectivity_IssueTracker__c insertConnSummary()
    {
         FACT_Dispenser_Connectivity_IssueTracker__c issueInstance=new FACT_Dispenser_Connectivity_IssueTracker__c ();
        
        Try
        {            
        Account accountRecord = [select Id from Account where Name = 'TestOutlet'];
       
        DateTime dt = system.now();
          issueInstance.FACT_Dispenser_Serial_Number__c='ZPL123456';
          issueInstance.FACT_ACN__c='1001001010';
          issueInstance.FACT_Build_ID__c= '111';
          issueInstance.FACT_Airwatch_Dispenser_Status__c = 'Active';
          issueInstance.FACT_JDEInstBase_Status__c = 'Active';
          issueInstance.FACT_Active_Inactive_Status__c = 'Active';
          issueInstance.FACT_IP_Address__c = '10.12.121';
          issueInstance.FACT_Airwatch_Enrollment_Date__c= datetime.newInstance(2016, 9, 15, 12, 30, 0);
          issueInstance.FACT_Last_Pour_Time__c= datetime.newInstance(2016, 9, 15, 12, 30, 0);
          issueInstance.FACT_Modem__c = 'Internal';
          issueInstance.FACT_SAP_Ship_to_ID__c = '1212123';
          issueInstance.FACT_Last_Seen_Date__c = datetime.newInstance(2016, 9, 15, 12, 30, 0);
          insert issueInstance;
        }
        catch(Exception e)
        {
         system.debug('CaseupdateBatcTestException'+e.getMessage());
        }
          return issueInstance;
    }    */
     /*****************************************************************************************
        Method : insertCaseRecord
        Description : Method for inserting Case records.
    ******************************************************************************************/
    public static Case insertCaseRecord(FS_Outlet_Dispenser__c outletDispenser)
    {
        Case caseInstance = new Case();
        try
        {
        caseInstance.Status = 'New';
        //FACT_Dispenser_Connectivity_IssueTracker__c fact = insertConnSummary();
        //caseInstance.FACT_Select_Dispenser__c = fact.id;
        caseInstance.FACT_Active_Inactive_Status__c = 'Inactive';
        caseInstance.recordtypeId = caseRecordTypeId;
        caseInstance.Issue_Name__c = 'TestIssue';
        caseInstance.FACT_Airwatch_Enrollment_Date__c = datetime.newInstance(2016, 9, 15, 12, 30, 0);
        caseInstance.FACT_Last_Pour_Time__c = datetime.newInstance(2016, 9, 15, 12, 30, 0);
        caseInstance.FACT_Last_Seen_Date__c = datetime.newInstance(2016, 9, 15, 12, 30, 0);
        insert caseInstance;
        }
        catch(Exception e)
        {
            system.debug('CaseupdateBatcTestException'+e.getMessage());
        }
        return caseInstance;
    }
    public static Case insertCaseRecord2(FS_Outlet_Dispenser__c outletDispenser)
    {
        Case caseInstance = new Case();
        try
        {
        caseInstance.Status = 'New';
        //FACT_Dispenser_Connectivity_IssueTracker__c fact = insertConnSummary();
        //caseInstance.FACT_Select_Dispenser__c = fact.id;
        caseInstance.FACT_Active_Inactive_Status__c = 'Active';
        caseInstance.recordtypeId = caseRecordTypeId;
        caseInstance.Issue_Name__c = 'TestIssue';
        caseInstance.FACT_Airwatch_Enrollment_Date__c = datetime.newInstance(2016, 9, 15, 12, 30, 0);
        caseInstance.FACT_Last_Pour_Time__c = datetime.newInstance(2016, 9, 15, 12, 30, 0);
        caseInstance.FACT_Last_Seen_Date__c = datetime.newInstance(2016, 9, 15, 12, 30, 0);
        insert caseInstance; 
        }
        catch(Exception e)
        {
            system.debug('CaseupdateBatcTestException'+e.getMessage());
        }
        return caseInstance;
    }
    
    /*****************************************************************************************
        Method : insertUser
        Description : Method for inserting System User records.
    ******************************************************************************************/
    public static ID insertUser()
    {
        User userRecord = new User();
        try
        {
        userRecord.LastName='Vishnu';
        userRecord.Alias='Vishnu';
        userRecord.Email='abcd@def.com';
        userRecord.Username='abcd@def.com.fet';
        userRecord.TimeZoneSidKey='America/Los_Angeles';
        profile id1=[select id from profile where name='FET SE Dispenser Coordinator Profile'];
        userRecord.ProfileId=id1.id;
        userRecord.LocaleSidKey='en_US';
        userRecord.EmailEncodingKey='ISO-8859-1';
        userRecord.LanguageLocaleKey='en_US';
        insert userRecord;
        }
        catch(Exception e)
        {
            system.debug('CaseupdateBatcTestException'+e.getMessage());
        }
        return userRecord.id;
    }
        
     public static testMethod void caseUpdateBatch()
     {   
        //List<FACT_Dispenser_Connectivity_IssueTracker__c> issueTrackerList=FACT_TestFactory.createConnectivityIssueRecords(1,true);
        List<Case> caseList=FACT_TestFactory.createFACTCaseRecords(1,false);
      
        Test.startTest();
        FS_CaseUpdateBatch obj = new FS_CaseUpdateBatch();
        DataBase.executeBatch(obj);     
        Test.stopTest();
      }
        
    
}