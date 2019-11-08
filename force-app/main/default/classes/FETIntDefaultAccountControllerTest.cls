/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class FETIntDefaultAccountControllerTest {
    public static Shipping_Form__c shippingForm;
    public static Dispenser_Model__c dispenserModel;
    public static User coordinatorUser;
    public static Account headquartersAcc, acc, normalAcc;
    public static final string ONE='1';
    private static testMethod void myUnitTest() {
        Test.startTest();
        
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,false);
        coordinatorUser.Dispenser_Country__c = 'GB';
        insert coordinatorUser;          
        system.runAs(coordinatorUser){  
            shippingForm = FSTestUtil.createShippingForm(true);
            headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
            acc = FSTestUtil.createAccountOutlet(FSConstants.defaultOutletName,FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);                
            acc.Is_Default_FET_International_Outlet__c=true;
            insert acc;
            system.debug('hq acc : ' + headquartersAcc +  ' acc : ' + acc); 
            normalAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id, true);
        }
        dispenserModel = FSTestUtil.createDispenserModel(true, '2000');
        ApexPages.currentPage().getParameters().put('sfdc.override',ONE);
        ApexPages.currentPage().getParameters().put('scontrolCaching',ONE);
        ApexPages.currentPage().getParameters().put('save_new',ONE);
        
        system.runAs(coordinatorUser){                 
            final FS_Outlet_Dispenser__c outletDispenserInt1 = FSTestUtil.createOutletDispenserAllTypes(Label.INT_OD_RECORD_TYPE,null,acc.id,null,false);
            //outletDispenserInt1.FS_Model__c = '7000';        
            outletDispenserInt1.Shipping_Form__c = shippingForm.id;
            outletDispenserInt1.FSInt_Dispenser_Type__c = dispenserModel.id;
            outletDispenserInt1.FS_Serial_Number2__c = 'TEST_7687';
            outletDispenserInt1.Warehouse_Country__c = 'New Zealand';
            outletDispenserInt1.Warehouse_Name__c = 'New Zealand #1';
            outletDispenserInt1.Brand_Set__c = 'NZ Default Collection';
            outletDispenserInt1.FS_IsActive__c = true;
            
            
            final ApexPages.StandardController stdCont = new ApexPages.StandardController(outletDispenserInt1);
            final FETIntDefaultAccountController defaultController = new FETIntDefaultAccountController(stdCont);
            defaultController.setOutletAccountDefault();
            ApexPages.currentPage().getParameters().put('sfdc.override',ONE);
            ApexPages.currentPage().getParameters().put('scontrolCaching',ONE);
            ApexPages.currentPage().getParameters().put('save_new',ONE);
            
            final FS_Outlet_Dispenser__c outletDispenserInt = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,normalAcc.id,null,false);
            final ApexPages.StandardController stdCont1 = new ApexPages.StandardController(outletDispenserInt);
            final FETIntDefaultAccountController defaultController1 = new FETIntDefaultAccountController(stdCont1);
            defaultController1.setOutletAccountDefault();
            //insert outletDispenserInt1;
            //system.assertNotEquals(outletDispenserInt1.Id, null);
        }
        
        Test.stopTest();
    }
}