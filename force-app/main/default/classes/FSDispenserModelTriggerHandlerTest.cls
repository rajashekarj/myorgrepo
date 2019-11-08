/**************************************************************************************
Apex Class Name     : FSDispenserModelTriggerHandlerTest
Version             : 1.0
Function            : This test class is for FSDispenserModelTriggerHandler Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
public class FSDispenserModelTriggerHandlerTest {
    
    static User user1;
    static Shipping_Form__c shippingForm1;
    @testSetUp
    private static void loadTestData(){
        //Create AW Setting
        
        //create trigger switch --custom setting
        FSTestFactory.createTestDisableTriggerSetting();
        
    }
    static testMethod  void testDispModel(){
        
        FSTestUtil.insertPlatformTypeCustomSettings();
        user1 = FSTestUtil.createUser(null,1,FSConstants.dispenserManufacturerProfile,true);
        system.runAs(user1){
            shippingForm1 = FSTestUtil.createShippingForm(true);            
        }    
        
        
        
        Account acc=new Account();
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Bottler').getRecordTypeId();
        acc.Name='Test Bottler';
        insert acc;
        Account accChain1=new Account();
        accChain1.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Chain').getRecordTypeId();
        accChain1.ShippingCountry='NZ';    
        accChain1.Name='Test Chain';
        accChain1.FS_ACN__c = '12345ICH';    
        insert accChain1;
        Account accInt=new Account();
        accInt.Name='Test Int';
        accInt.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.INTERNATIONAL_OUTLET_RECORD_TYPE).getRecordTypeId();
        accInt.Bottlers_Name__c=acc.Id;
        accint.FS_ACN__c='12345';
        accInt.FS_Chain__c=accChain1.Id;
        accInt.ShippingCountry='NZ';
        insert accInt;
        Dispenser_Model__c dispMod=new Dispenser_Model__c();
        dispMod.Name='Test DispMod';
        dispMod.Dimensions__c='1234';
        dispMod.Dispenser_Type__c='7000';
        dispMod.Weight__c='23';
        dispMod.Series__c='235';
        dispMod.IC_Code__c='1234';
        dispMod.Dispenser_Type1__c='Self Serve';
        dispMod.Dimension_unit_of_measure__c='Inch';
        dispMod.Weight_unit_of_measure__c='kgs';
        dispMod.IC_Code_Description__c='desc';
        insert dispMod;
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FS_Outlet_Dispenser__c testOD=new FS_Outlet_Dispenser__c();
        testOD.FS_Outlet__c=accInt.Id;
        testOD.Ownership__c='Bottler';
        testOD.Shipping_Form__c= shippingForm1.Id;        
        testOD.RecordTypeId=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(Label.INT_OD_RECORD_TYPE).getRecordTypeId();
        testOD.FSInt_Dispenser_Type__c=dispMod.Id;
        testOD.FS_Serial_Number2__c='123456789';
        testOD.FS_Status__c='Booking Complete';
        testOD.Warehouse_Country__c='New Zealand';
        insert testOD;
        
        Test.startTest();
        
        //dispMod.Dispenser_Type__c='7000';
        dispMod.IC_Code__c='1234';
        dispMod.Dispenser_Type1__c= 'Crew Serve';
        update dispMod;
        
        Test.stopTest();
        
    }
    
    
    static testMethod  void testDispModelnegative(){
        FSTestUtil.insertPlatformTypeCustomSettings();
        Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c ();
        disableTriggerSetting.Name='FSDispenserModelTriggerHandler';
        disableTriggerSetting.IsActive__c=false;
        insert disableTriggerSetting;
        
        user1 = FSTestUtil.createUser(null,1,FSConstants.dispenserManufacturerProfile,true);
        system.runAs(user1){
            shippingForm1 = FSTestUtil.createShippingForm(true);            
        }    
        
        
        
        Account acc=new Account();
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Bottler').getRecordTypeId();
        acc.Name='Test Bottler';
        insert acc;
        Account accChain1=new Account();
        accChain1.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Chain').getRecordTypeId();
        accChain1.ShippingCountry='NZ';    
        accChain1.Name='Test Chain';
        accChain1.FS_ACN__c = '12345ICH';    
        insert accChain1;
        Account accInt=new Account();
        accInt.Name='Test Int';
        accInt.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.INTERNATIONAL_OUTLET_RECORD_TYPE).getRecordTypeId();
        accInt.Bottlers_Name__c=acc.Id;
        accInt.FS_Chain__c=accChain1.Id;
        accInt.FS_ACN__c='123456';
        accInt.ShippingCountry='NZ';
        insert accInt;
        Dispenser_Model__c dispMod=new Dispenser_Model__c();
        dispMod.Name='Test DispMod';
        dispMod.Dimensions__c='1234';
        dispMod.Dispenser_Type__c='7000';
        dispMod.Weight__c='23';
        dispMod.Series__c='235';
        dispMod.IC_Code__c='1234';
        dispMod.Dispenser_Type1__c='Self Serve';
        dispMod.Dimension_unit_of_measure__c='Inch';
        dispMod.Weight_unit_of_measure__c='kgs';
        dispMod.IC_Code_Description__c='desc';
        insert dispMod;
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FS_Outlet_Dispenser__c testOD=new FS_Outlet_Dispenser__c();
        testOD.FS_Outlet__c=accInt.Id;
        testOD.Ownership__c='Bottler';
        testOD.Shipping_Form__c= shippingForm1.Id;        
        testOD.RecordTypeId=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(Label.INT_OD_RECORD_TYPE).getRecordTypeId();
        testOD.FSInt_Dispenser_Type__c=dispMod.Id;
        testOD.FS_Serial_Number2__c='123456789';
        testOD.FS_Status__c='Booking Complete';
        testOD.Warehouse_Country__c='New Zealand';
        insert testOD;
        
        Test.startTest();
        
        dispMod.Dispenser_Type__c='7000';
        dispMod.IC_Code__c='1234';
        update dispMod;
        
        
        Test.stopTest();
        
    }
    
}