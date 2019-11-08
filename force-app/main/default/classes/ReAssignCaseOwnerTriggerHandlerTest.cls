/**************************************************************************************
Apex Class Name     : ReAssignCaseOwnerTriggerHandlerTest
Version             : 1.0
Function            : This is the test class for ReAssignCaseOwnerTriggerHandler. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  06/18/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class ReAssignCaseOwnerTriggerHandlerTest{
    public static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Connectivity Solution').getRecordTypeId();
    public static Id emtCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North American Case').getRecordTypeId();
    public static Id outletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId();
    public static Id hqRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Headquarters').getRecordTypeId();
    public static Id outletDispenserRecordTypeId = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(FSConstants.RT_NAME_CCNA_OD).getRecordTypeId();
    
    /****************************************************************************************
Method : dataSetup
Description : Method for setting up the data required in this unit test class.
*****************************************************************************************/
    @testSetup
    public static void dataSetup()
    {
        Account hqAccount = insertHeadQuarters();
        Account accRecord = insertoutletRecord('TestOutlet',hqAccount,'123456');
        Account accRecordDuplicate = insertoutletRecord('TestOutlet1',hqAccount,'987654');
        FS_Outlet_Dispenser__c odRecord = insertOutletDispenser('ZPL123456',accRecord);
        insertOutletDispenser('ZPL987654',accRecord);
        //insertOutletDispenser('ZPL123987',accRecordDuplicate);
        insertEMTCaseRecord('TestEMTissue',odRecord);
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
Method : insertHeadQuarters
Description : Method for inserting Head Quarters records.
******************************************************************************************/
    public static Account insertHeadQuarters()
    {
        Account accountRecord = new Account();
        try
        {
            accountRecord.Name = 'HeadQuarters';
            accountRecord.RecordTypeId = hqRecordTypeId;
            insert accountRecord;
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
    public static Account insertoutletRecord(String outletName,Account hqRecord,String acnNumber)
    {
        Account accountRecord = new Account();
        try
        {
            accountRecord.Name = outletName;
            accountRecord.RecordTypeId = outletRecordTypeId;
            accountRecord.FS_Headquarters__c = hqRecord.Id;
            accountRecord.FS_ACN__c = acnNumber;
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
    Updated Date : Feb 2018
    ******************************************************************************************/
    public static FS_Outlet_Dispenser__c insertOutletDispenser(String serial,Account accountRecord)
    {
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
    
    public static void insertEMTCaseRecord(String issueName,FS_Outlet_Dispenser__c outletDispenser)
    {
        try
        {
            Case caseInstance = new Case();
            caseInstance.Status = 'New';
            //caseInstance.FACT_Select_Dispenser__c = null; //FACT R1 2018 : Deleted Connectivity Summary object
            caseInstance.recordtypeId = emtCaseRecordTypeId;
            caseInstance.Issue_Name__c = issueName;
            caseInstance.FS_Dispenser_Type__c = '7000 Series';
            caseInstance.Categories__c = 'Agitation';
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
    Method : createhistorydetails
    Description : Method to create Case record history details.
    ******************************************************************************************/
    Static testmethod void createhistorydetails()
    {
        try
        {
            Case caseRecord = [Select ID,RecordTypeId,FS_Outlet_Dispenser__c,Status from Case Limit 1];
            List<case> Newcaselist =new List<case>();
            
            Newcaselist.add(caseRecord);
            ReAssignCaseOwnerTriggerHandler.insertValues(Newcaselist,null,null,null, true, false);
        }
        catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
    Method : updatehistorydeatils
    Description : Method to update Case record history details.
    ******************************************************************************************/
    static testmethod void updatehistorydeatils()
    {
        try
        {
            Case caseRecord = [Select ID from Case Limit 1];
            List<case> oldlist=New List<case>();
            oldlist.add(caseRecord);
            caseRecord.Status='Assigned';
            
            update caseRecord;
            List<case> Newlist=New List<case>();  
            Newlist.add(caseRecord);
            
            ReAssignCaseOwnerTriggerHandler.updateValues(Newlist,oldlist ,null,null,false,true);
        }
        catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
    Method : updateOD
    Description : Method to update Case Outlet Dispenser record of same Outlet and to test the insertion.
    ******************************************************************************************/
    public static testMethod void updateOD()
    {
        try
        {
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
            FS_Outlet_Dispenser__c outletDispenserRecord = [Select Id from FS_Outlet_Dispenser__c where FS_Serial_Number2__c = 'ZPL987654'];
            List<Case> newList = new List<Case>();
            List<Case> caseList = [Select Id,RecordTypeId,FS_Outlet_Dispenser__c from Case where recordTypeID =: emtCaseRecordTypeId];
            if(!caseList.isEmpty())
            {
                for(Case cs : caseList)
                {
                    cs.FS_Outlet_Dispenser__c = outletDispenserRecord.Id;
                    newList.add(cs);
                }
            }
            if(!newList.isEmpty())
            {
                update newList;
            }
            List<CaseToOutletdispenser__c> caseToOutlet = [select Id from CaseToOutletdispenser__c];
            system.assertEquals(2,caseToOutlet.size());
        }
        catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
    Method : updateOtherOD
    Description : Method to update Case Outlet Dispenser record of different Outlet and to test the insertion.
    ******************************************************************************************/
    public static testMethod void updateOtherOD()
    {
        try
        {
            FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
            FS_Outlet_Dispenser__c outletDispenserRecord = [Select Id from FS_Outlet_Dispenser__c where FS_Serial_Number2__c = 'ZPL123987'];
            List<Case> newList = new List<Case>();
            List<Case> caseList = [Select Id,RecordTypeId,FS_Outlet_Dispenser__c from Case where recordTypeID =: emtCaseRecordTypeId];
            if(!caseList.isEmpty())
            {
                for(Case cs : caseList)
                {
                    cs.FS_Outlet_Dispenser__c = outletDispenserRecord.Id;
                    newList.add(cs);
                }
            }
            if(!newList.isEmpty())
            {
                update newList;
            }
            List<CaseToOutletdispenser__c> caseToOutlet = [select Id from CaseToOutletdispenser__c];
            system.assertEquals(1,caseToOutlet.size());
        }
        catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
    Method : insertCaseToOD
    Description : Method to check the insertion of Case To Outlet Dispenser record.
    ******************************************************************************************/
    public static testMethod void insertCaseToOD()
    {
        try
        {
            Test.startTest();
            List<CaseToOutletdispenser__c> caseToOutlet = [select Id from CaseToOutletdispenser__c];           
            Test.stopTest();
        }
        catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
}