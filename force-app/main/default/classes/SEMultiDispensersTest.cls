/*************************************************************************************
Apex Class Name     : SEMultiDispensersTest
Function            : This is a Test class for handling all Unit test methods for SEMultiDispensers class.
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Mahender	          11/17/2016       For handling unit test methods for all methods in FSCaseManagementHelper class.
Infosys			  05/29/2018       Removed usage of OutboundServiceDetails__c customSetting as part of FOT project 
************************************************************************************/
@isTest(seeAllData=false)
private class SEMultiDispensersTest{
    
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
        Catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
Method : checkSEMultiDispensers
Description : Method for testing constructor method in SEMultiDispensers.
******************************************************************************************/
    static testmethod void checkSEMultiDispensers()
    {
        try
        {
            
            createTestData(); //FET 7.0 FNF-823
            Test.startTest();
            outletDispenser1.FS_Outlet__c = outletAcc.Id;
            outletDispenser1.FS_Equip_Type__c  ='8000';
            outletDispenser1.FS_Serial_Number2__c='ZPL12345';
            outletDispenser1.FS_IsActive__c=true;
            outletDispenser1.FS_Date_Status__c=system.Date.today();
            insert outletDispenser1;
            
            
            list<FS_Outlet_Dispenser__c> outletDispenserList=new list<FS_Outlet_Dispenser__c>();
            FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
            outletDispenserList= [select FS_Date_Status__c,FS_Name1__c ,FS_Equip_Type__c,FS_Outlet__c ,FS_Status__c ,FS_Dispenser_Type__c ,Outlet_City__c ,id, name,FS_Serial_Number2__c,FS_IsActive__c from FS_Outlet_Dispenser__c where FS_Outlet__c=:outletAcc.Id AND FS_IsActive__c = true ORDER BY FS_Name1__c ASC NULLS FIRST];
            sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCase;
            
            
            pageRef = Page.SEMulti_Select_Dispenser;
            case sampleCase1=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCase1;
            
            CaseToOutletdispenser__c cToOD = new CaseToOutletdispenser__c();
            cToOD.Case__c = sampleCase1.id;
            cToOD.Outlet_Dispenser__c = outletDispenser1.Id;
            insert cToOD;
            
            pageRef.getParameters().put('dispenserid',odRec.Name );
            pageRef.getParameters().put('id',sampleCase1.Id );
            Test.setCurrentPage(pageRef);
            testSEMultiDispensers = new SEMultiDispensers(new ApexPages.StandardController(sampleCase1));
            system.assertEquals(outletDispenser1.Id,cToOD.Outlet_Dispenser__c);
            Test.stopTest();
        }
        Catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
Method : checkSEMultiDispensers1
Description : Method for testing setSerialNumber method in SEMultiDespenser class.
******************************************************************************************/
    static testmethod void checkSEMultiDispensers1()
    {
        try
        {
            
            createTestData(); //FET 7.0 FNF-823
            Test.startTest();
            outletDispenser1.FS_Outlet__c = outletAcc.Id;
            outletDispenser1.FS_Equip_Type__c  ='8000';
            outletDispenser1.FS_Serial_Number2__c='ZPL12345';
            outletDispenser1.FS_IsActive__c=true;
            outletDispenser1.FS_Date_Status__c=system.Date.today();
            insert outletDispenser1;
            /* 
            outletDispenser2.FS_Outlet__c = outletAcc.Id;
            outletDispenser2.FS_Equip_Type__c  ='8000';
            outletDispenser2.FS_Serial_Number2__c='ZPL12345678';
            outletDispenser2.FS_IsActive__c=true;
            // insert outletDispenser2;*/
            List<Case> caseList = new List<Case>();
            sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            caseList.add(sampleCase);
            
            case sampleCase1=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            caseList.add(sampleCase1);
            insert caseList;
            SEMultiDispensers.setSerialNumber(sampleCase1.id,'ZPL12345',outletAcc.Id);
            system.assertEquals(SERIES_7K,sampleCase.FS_Dispenser_Type__c);
            Test.stopTest();
        }
        Catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
}