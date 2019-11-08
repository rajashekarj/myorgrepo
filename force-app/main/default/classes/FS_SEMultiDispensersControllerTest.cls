/*********************************************************************************************************
Apex Class Name     : FS_SEMultiDispensersControllerTest
Function            : This test class is created for class FS_SEMultiDispensersController
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* BhargavD	          09/10/2019       This class is a test class for FS_SEMultiDispensersController
									   
***********************************************************************************************************/

@isTest(SeeAllData=false)
private class FS_SEMultiDispensersControllerTest {
    
    static Account headQuarterAcc,outletAcc, defaultAccount, internationalOutlet, chainAccount,bottler;
    static FS_Execution_Plan__c executionPlan;
    static FS_Installation__c installation;
    static User apiUser, coordinatorUser;
    static FS_Outlet_Dispenser__c outletDispenser;
    static FS_Outlet_Dispenser__c outletDispenser1,outletDispenser2;
    static FS_Outlet_Dispenser__c outletDispenserInt,outletDispenserInt1;
    static final string SERIES_7K='7000 Series';
    static FS_Integration_NMS_User__c integrationUser;
    static FS_IP_Technician_Instructions__c  ipTechInstruction;
    static Shipping_Form__c shippingForm;
    static Dispenser_Model__c dispenserModel;
    static SEMultiDispensers testSEMultiDispensers;
    static case sampleCase;
    static PageReference pageRef;
    
/*****************************************************************************************
Method : createTestData
Description : Method for setting up the data required in this unit test class.
******************************************************************************************/
    static void createTestData(){
        try{

            User userRecord = new User();
            userRecord.LastName='Testuser';
            userRecord.Alias='testuser';
            userRecord.Email='abc@defq.com';
            userRecord.Username='hkrishna@test.com';
            userRecord.TimeZoneSidKey='America/Los_Angeles';
            profile id1=[select id from profile where name='FS_FACT_BAST_P'];
            userRecord.ProfileId=id1.id;
            userRecord.LocaleSidKey='en_US';
            userRecord.EmailEncodingKey='ISO-8859-1';
            userRecord.LanguageLocaleKey='en_US';
            insert userRecord; 
            User testuser = [select id from User where Email='abc@defq.com'];
            system.runAs(testuser)
            {  
            FSTestFactory.lstPlatform();
            Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
            apiUser=FSTestUtil.createUser(null,null,'API User',false);
            coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
            chainAccount = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);        
            chainAccount.FS_ACN__c = '76876876';
            insert chainAccount;
            HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false); 
            HeadQuarterAcc.FS_ACN__c = '7658765876';
            insert HeadQuarterAcc;
            
            //Creates Outlet Accounts
            outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, true);
            bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
            defaultAccount = FSTestUtil.createAccountOutlet(FSConstants.defaultOutletName,FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, false);
            internationalOutlet = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET_INT,HeadQuarterAcc.Id,false);
            system.runAs(coordinatorUser){
                shippingForm = FSTestUtil.createShippingForm(true);
            }
            dispenserModel = FSTestUtil.createDispenserModel(true, '7000');
            //Creates execution plan
            executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,HeadQuarterAcc.Id, true);
            //creates installation
            installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.Id,true);                 
            
            ipTechInstruction=FSTestUtil.createTechnicianInstructions(FSConstants.TECHINSTRECTYPE,false);
            
            //creates initial order
            
            outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);
            outletDispenser1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);
            outletDispenser2= FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);        
            outletDispenserInt = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,internationalOutlet.id,null,false);
            outletDispenserInt1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,internationalOutlet.id,null,false);
            }
        }
        Catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
Method : getDispensersList
Description : Method for testing to get OD list.
******************************************************************************************/   
     
    static testmethod void getDispensersTest(){
        
        string dispenser;
        Id caseIn;
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
         system.runAs(testuser)
        {  
        createTestData();
        Test.startTest();
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c='ZPL12345';
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Date_Status__c=system.Date.today();
        insert outletDispenser1;
        FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
        dispenser = odRec.Name; 
        system.debug('dispenserid : ' + dispenser);
        
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
        CaseIn = IdCase.Id;
        system.debug('Casseid : ' + CaseIn);
        
        CaseToOutletdispenser__c cToOD = new CaseToOutletdispenser__c();
        cToOD.Case__c = IdCase.id;
        cToOD.Outlet_Dispenser__c = odRec.Id;
        insert cToOD;
       
       
        FS_SEMultiDispensersController.getDispensersList(dispenser,CaseIn);
        Test.stopTest(); 
        FS_Outlet_Dispenser__c dis = [SELECT FS_Outlet__c,FS_Serial_Number2__c FROM FS_Outlet_Dispenser__c WHERE name =:dispenser];
        system.assert(dis!=NULL);
        }
    }
    
        /*****************************************************************************************
Method : deleteJunctionRecords
Description : Method for testing to delete junction records.
******************************************************************************************/  
    
    static testmethod void deleteJunRecordsTest(){
        Id caseIn;
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
       
        Test.startTest();
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c='ZPL12345';
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Date_Status__c=system.Date.today();
        insert outletDispenser1;
        FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
         
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
        CaseIn = IdCase.Id;
       
        FS_SEMultiDispensersController.deleteJunctionRecords(CaseIn);
        Test.stopTest();
        case caseR;
        caseR=new case(Issue_Name__c='test case1',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert caseR;
         system.assert(caseR!=NULL); 
        }
    }
    
 
           /*****************************************************************************************
Method : updateDispenserSerialNumber
Description : Method for testing to update DispenserSerialNumber.
******************************************************************************************/  
    
     static testmethod void updateODSerialNumTest(){
        Id caseIn;
        string serialNumber;
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
       {  
        
        Test.startTest();
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c='ZPL12345';
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Date_Status__c=system.Date.today();
        insert outletDispenser1;
        FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
         
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
        CaseIn = IdCase.Id;
        SerialNumber = 'ZPL12345,';
        FS_SEMultiDispensersController.updateDispenserSerialNumber(CaseIn,SerialNumber);
        Test.stopTest();
        case caseR=[select AccountId,Dispenser_serial_number__c from case where id=:CaseIn];
        system.assert(caseR!=NULL);
        
        }
    }
    
      /*****************************************************************************************
Method : setSerialNumber
Description : Method for testing to setSerialNumber.
******************************************************************************************/  
     static testmethod void setSerialNumTest(){
        Id caseIn;
        string serialNumber = 'ZPL12345,';
        string dispenser;
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
         system.runAs(testuser)
       {  
        Test.startTest();
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c='ZPL12345';
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Date_Status__c=system.Date.today();
        insert outletDispenser1;
        FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
        dispenser = odRec.Name;
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
        CaseIn = IdCase.Id;
        SerialNumber = 'ZPL12345,';
        FS_SEMultiDispensersController.setSerialNumber(CaseIn,SerialNumber,dispenser);
        Test.stopTest();
        case caseR = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
        system.assert(caseR!=NULL);
        }
    }
}