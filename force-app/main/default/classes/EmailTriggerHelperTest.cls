/**************************************************************************************
Apex Class Name     : EmailTriggerHelperTest
Version             : 1.0
Function            : This test class is for EmailTriggerHelper Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class EmailTriggerHelperTest {
    //FET-International Delete requirement (Req No:B-14997) To Send notifiaction to Bottler -- 'callUpdateEmailService'
    
    static Account headQuarterAcc, outletAcc, defaultAccount, internationalOutlet, chainAccount,bottler;
    static FS_Execution_Plan__c executionPlan;
    static FS_Installation__c installation;
    static RecordType recordType9000;
    static RecordType recType8000;
    static User apiUser, coordinatorUser;
    static FS_Outlet_Dispenser__c outletDispenser;
    static FS_Outlet_Dispenser__c outletDispenser1,outletDispenser2;
    static FS_Outlet_Dispenser__c outletDispenserInt,outletDispenserInt1;
    static FS_Integration_NMS_User__c integrationUser;
    static FS_IP_Technician_Instructions__c  ipTechInstruction;
    static Shipping_Form__c shippingForm;
    static Dispenser_Model__c dispenserModel;
    static final string SERIES_7K=FSConstants.RECTYPE_7k;
    static List<id> odId= new List<id>();
    //--------------------------------------------------------------------------------------
    //Create Test Data For Account Update
    //--------------------------------------------------------------------------------------
    static void createTestData(){        
        
        apiUser=FSTestUtil.createUser(null,null,'API User',false);
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
        chainAccount = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false); 
        chainAccount.FS_ACN__c = '76876876ICH';
        insert chainAccount; 
        HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        HeadQuarterAcc.FS_ACN__c = '7658765876';
        insert HeadQuarterAcc;
        //Creates Outlet Accounts
        outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, true);
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        //create platform type custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        //set mock callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());        
        defaultAccount = FSTestUtil.createAccountOutlet(FSConstants.defaultOutletName,FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, false);
        internationalOutlet = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET_INT,HeadQuarterAcc.Id,false);
        system.runAs(coordinatorUser){
            shippingForm = FSTestUtil.createShippingForm(true);
        }
        dispenserModel = FSTestUtil.createDispenserModel(true, SERIES_7K);
        system.debug('DM created');
        
        outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);
        
        outletDispenser1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);
        outletDispenser2= FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);        
        outletDispenserInt = FSTestUtil.createOutletDispenserAllTypes(FSConstants.OD_RECORD_TYPE_INT,null,internationalOutlet.id,null,false);
        outletDispenserInt1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);
        system.debug('OD created');
    }
    
    
    static testMethod void myUnitTestInternationalDispenserDelivered() {
        
        createTestData();
        //Account bottler;
        //Query for the Account record types
        List<RecordType> rtypes = [Select Name, Id From RecordType where isActive=true];
        
        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> allRecordTypes = new Map<String,String>{};
            for(RecordType rt: rtypes)
        {
            system.debug('re-------name;' +rt.Name);  
            allRecordTypes.put(rt.Name,rt.Id);
        }
        
        Account normalAcc;
        Account headquartersAcc;
        Contact bottlerContact;
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        normalAcc = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET_INT,HeadQuarterAcc.Id,false);
        bottler=FSTestUtil.createTestAccount('Test Bottlerc1',FSConstants.RECORD_TYPE_BOTLLER,true);
        
        //normalAcc.Bottlers_Name__c = bottler.id;
        normalAcc.ShippingCountry='NZ';
        insert normalAcc;
        
        system.debug('testmethod acc created');
        bottlerContact=FSTestUtil.createTestContact(bottler.id, 'TestContact', false);
        bottlerContact.MailingCountry='NZ';
        bottlerContact.warehouse_Country__c='NZ';
        bottlerContact.Email='neelkumar.patel@infosys.com';
        bottlerContact.AccountId=bottler.id;
        
        insert bottlerContact;
        system.debug('botContact created--'+bottlerContact);
        defaultAccount.FS_Chain__c = chainAccount.id;
        internationalOutlet.FS_Chain__c = chainAccount.id;
        
        insert defaultAccount; 
        Warehouse_Details__c wh=new Warehouse_Details__c();
        wh.Warehouse_Country__c='NZ';
        insert wh;
        
        internationalOutlet.FS_ACN__c = '76876987698';        
        internationalOutlet.shippingCountry = 'NZ';
        internationalOutlet.shippingCity = 'Test City';
        internationalOutlet.shippingState = 'Test State';
        internationalOutlet.shippingStreet = 'Test Street';
        internationalOutlet.shippingPostalCode = '12345';
        internationalOutlet.Bottlers_Name__c = bottler.id;
        internationalOutlet.Bottler_Name__c = 'Coca-Cola Amatil Limited';
        internationalOutlet.RecordTypeId = allRecordTypes.get(FSConstants.RECORD_TYPE_NAME_OUTLET_INT);
        system.debug('internationalOutlet-RecordTypeId' +internationalOutlet.RecordTypeId);  
        system.debug('internationalOutlet-RecordTypeId' +internationalOutlet.RecordType.name);    
        system.debug('internationalOutlet-RecordTypeId' +internationalOutlet.RecordType.developername);  
        internationalOutlet.FS_Is_Address_Validated__c = 'Yes';
        internationalOutlet.Is_Default_FET_International_Outlet__c = true ;
        
        insert internationalOutlet;
        system.debug('int out--'+internationalOutlet);
        
        //System.runAs(coordinatorUser){
        Test.startTest();
        
        //outletDispenserInt1.FS_Model__c = '7000';
        outletDispenserInt1.FS_Outlet__c = internationalOutlet.id;
        outletDispenserInt1.Shipping_Form__c = shippingForm.id;
        outletDispenserInt1.FSInt_Dispenser_Type__c = dispenserModel.id;
        outletDispenserInt1.FS_Serial_Number2__c = 'TEST_7687';
        outletDispenserInt1.Warehouse_Country__c = 'NZ';
        outletDispenserInt1.Warehouse_Name__c = 'NZ #1';
        outletDispenserInt1.Brand_Set__c = 'NZ Default Collection';
        outletDispenserInt1.FS_Planned_Install_Date__c = system.today(); 
        outletDispenserInt1.FS_IsActive__c = true;
        outletDispenserInt1.FS_Status__c = 'New';
        outletDispenserInt1.FS_Equip_Type__c = null;
        outletDispenserInt1.Warehouse_Details__c=wh.id;
        outletDispenserInt1.RecordTypeId = allRecordTypes.get(FSConstants.OD_RECORD_TYPE_INT);
        //outletDispenserInt1.RecordType.name = 'International';  
        system.debug('outletDispenserInt1-RecordTypeId' +outletDispenserInt1.RecordTypeId);
        system.debug('outletDispenserInt1-RecordTypeId' +outletDispenserInt1.RecordType.Id); 
        system.debug('outletDispenserInt1-RecordTypeName' +outletDispenserInt1.RecordType.Name);      
        
        insert outletDispenserInt1;
        system.debug('outletDispenserInt1int out--'+outletDispenserInt1);
        System.assertNotEquals(outletDispenserInt1.Id,null);
        //outletDispenserInt1.FS_Status__c = 'Dispenser Delivered'; 
        outletDispenserInt1.FS_Status__c = 'Enrolled';      
        outletDispenserInt1.FS_Outlet__c = internationalOutlet.id;
        outletDispenserInt1.FS_Equip_Type__c = null;
        //update outletDispenserInt1;
        
        System.assertEquals(bottlerContact.warehouse_Country__c,internationalOutlet.shippingCountry );
        System.assertEquals(outletDispenserInt1.FS_Outlet__c,internationalOutlet.Id);
        System.assert(true,outletDispenserInt1.FS_IsActive__c);
        system.assertEquals(outletDispenserInt1.FS_Equip_Type__c, null);
        odId.add(outletDispenserInt1.id);
        EmailTriggerHelper.sendEmailContact(odId);
        System.assertEquals(bottlerContact.warehouse_Country__c,internationalOutlet.shippingCountry );
        System.assertEquals(outletDispenserInt1.FS_Outlet__c,internationalOutlet.Id);
        System.assert(true,outletDispenserInt1.FS_IsActive__c);
        system.assertEquals(outletDispenserInt1.FS_Equip_Type__c, null);
        Test.stopTest();
        //}
    }
    
    
}