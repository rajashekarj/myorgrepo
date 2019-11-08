/**************************************************************************************
// (c) 2015 Appirio, Inc.
Apex Class Name     : ChangeSAPNumberControllerTest
Version             : 1.0
Function            : This test class is for ChangeSAPNumberController Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             05/21/2015          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private Class ChangeSAPNumberControllerTest{
    
    static Shipping_Form__c shippingForm;
    static Dispenser_Model__c dispenerModel;
    static FS_Outlet_Dispenser__c dispenser = FSTestUtil.createOutletDispenserAllTypes(null,null,null,null,false);
    static Account hqAccount = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);  
    static Account outletAccount = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,hqAccount.id, false);
    static User manufacturerUser = FSTestUtil.createUser(null,1,'FET SE Manufacturer Profile',true);
    
    static testMethod void test1(){
        //create platform type custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        //set mock callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        System.debug('>>>>>>>>1  '+hqAccount.Id);
        System.debug('>>>>>>>>1  '+hqAccount.Name);
        outletAccount.FS_SAP_ID__c = '87687687968';
        insert outletAccount;

        shippingForm = new Shipping_Form__c();
        shippingForm.Name='Test Shipping Form 07-07-2015';
        shippingForm.FS_PO_Number__c='12345';
        system.runAs(manufacturerUser){
            insert shippingForm;
       }
        
        dispenser.Shipping_Form__c=shippingForm.Id;
        dispenser.Ownership_Type__c='Coca-Cola Business Unit';
        dispenser.FS_Serial_Number2__c='Asset Tag 123';
        //dispenser.FS_Model__c='2000';
        dispenerModel = new Dispenser_Model__c();
        dispenerModel.Name='Test Dispenser Model 07-07-2015';
        dispenerModel.Dimensions__c='Test Dimensions';
        dispenerModel.Dimension_unit_of_measure__c='Inch';
        dispenerModel.Dispenser_Type__c='2000';
        dispenerModel.IC_Code__c='Test IC Code';
        dispenerModel.IC_Code_Description__c='Test Description';
        dispenerModel.Series__c='Test Series';
        dispenerModel.Weight__c='Test Weight';
        dispenerModel.Weight_unit_of_measure__c='lbs';
        insert dispenerModel;
        dispenser.FSInt_Dispenser_Type__c=dispenerModel.Id;
        dispenser.FS_IsActive__c = true;
        dispenser.FS_Outlet__c = outletAccount.Id;
        insert dispenser;
        System.debug('>>>>>>>>>>>>>>>>>>Outlet Dispenser Inserted' + dispenser);
        ApexPages.StandardController stdCont = new ApexPages.StandardController(dispenser);
        Test.startTest();
        ChangeSAPNumberController ctrlObj = new ChangeSAPNumberController(stdCont);
        // system.assert(null,ctrlObj.newdisp.id);
        ctrlObj.cloneDispenser();
        
        system.assert(true, ctrlObj.newdisp.FS_IsActive__c);
        Test.stopTest();
    }
}