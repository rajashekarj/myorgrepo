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
/**************************************************************************************
Apex Class Name     : FET_OutletAssignmentCtrlTest
Version             : 1.0
Function            : This test class is for FET_OutletAssignmentCtrl Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FET_OutletAssignmentCtrlTest {
    public static Shipping_Form__c shippingForm;
    public static Dispenser_Model__c dispenserModel;
    public static User coordinatorUser;
    public static FS_Outlet_Dispenser__c dispenser;
    public static Account headquartersAcc,normalAcc,bottler,bottlerAcc,chainAccount,outlet2;
    public static FET_OutletAssignmentCtrl outletAssgnmntCtrl1;
    public static FS_Outlet_Dispenser__c outletDispenserInt1;
    public static ApexPages.StandardController stdCont1;
    public static Warehouse_Details__c war1;
    public static final string IDS='id';
    public static final string ACN='7687687678';
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    private static void createTestData(){
        
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        chainAccount = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAccount.FS_ACN__c = '76876876ICH';
        insert chainAccount; 
        normalAcc = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id, false);
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        normalAcc.Bottlers_Name__c = bottler.id;       
        normalAcc.RecordTypeId=FSConstants.RECORD_TYPE_OUTLET1;
        normalAcc.FS_Is_Address_Validated__c='Yes';
        normalAcc.Is_Default_FET_International_Outlet__c=true; 
        insert normalAcc;
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
        system.runAs(coordinatorUser){
            shippingForm = FSTestUtil.createShippingForm(true);
            dispenserModel = FSTestUtil.createDispenserModel(true, '2000');
        }
        war1 = new Warehouse_Details__c();
        war1.Brand_Set__c = 'sample1';
        war1.Name = 'sample2';
        war1.Warehouse_Country__c = 'CA';  
        insert war1;
        outletDispenserInt1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.OD_RECORD_TYPE_INT,null,normalAcc.id,null,false);
        
        outletDispenserInt1.Shipping_Form__c = shippingForm.id;
        outletDispenserInt1.FSInt_Dispenser_Type__c = dispenserModel.id;
        outletDispenserInt1.FS_Serial_Number2__c = 'TEST_7687';
        outletDispenserInt1.Warehouse_Country__c = 'New Zealand';
        outletDispenserInt1.Warehouse_Name__c = 'New Zealand #1';
        outletDispenserInt1.Brand_Set__c = 'NZ Default Collection';
        outletDispenserInt1.FS_IsActive__c = true;
        outletDispenserInt1.FS_Outlet__c = normalAcc.id;
        outletDispenserInt1.FS_Planned_Install_Date__c =system.now().date();
        outletDispenserInt1.Planned_Remove_Date__c =system.now().date()+1;
    }
    
    private static testMethod void myUnitTest() {
        FSTestUtil.insertPlatformTypeCustomSettings();     
        // TO DO: implement unit test
        Test.startTest();    
        
        createTestData(); 
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            outletDispenserInt1.FS_Status__c = 'Enrolled';
            insert outletDispenserInt1; 
            
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont1 = new ApexPages.StandardController(outletDispenserInt1);
            system.assertNotEquals(outletDispenserInt1.Id, null);
            outletAssgnmntCtrl1 = new FET_OutletAssignmentCtrl(stdCont1);
            outletAssgnmntCtrl1.save();
            outletAssgnmntCtrl1.redirectPopup();
            outletAssgnmntCtrl1.closePopup1();
            outletAssgnmntCtrl1.closePopup();
        }
        Test.stopTest();
    }
    
    
    private static testMethod void myUnitTest1() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        // TO DO: implement unit test
        Test.startTest();
        
        createTestData();              
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            outletDispenserInt1.FS_Status__c = 'Dispenser Delivered';
            outletDispenserInt1.Warehouse_Details__c = war1.Id;  
            insert outletDispenserInt1;            
            
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont1 = new ApexPages.StandardController(outletDispenserInt1);
            system.assertNotEquals(outletDispenserInt1.Id, null);
            outletAssgnmntCtrl1 = new FET_OutletAssignmentCtrl(stdCont1);
            outletAssgnmntCtrl1.save();
            outletAssgnmntCtrl1.redirectPopup();
            outletAssgnmntCtrl1.closePopup1();
            outletAssgnmntCtrl1.closePopup();
        }
        Test.stopTest();
    }
    
    //test method assigned to outlet
    private static testMethod void myUnitTest3() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        // TO DO: implement unit test            
        
        createTestData();            
        normalAcc.fs_Chain__C=chainAccount.id;
        normalAcc.FS_ACN__c = ACN;       
        update normalAcc;
        
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            
            outletDispenserInt1.FS_Status__c = 'Assigned to Outlet';       
            outletDispenserInt1.Warehouse_Details__c = war1.Id;
            insert outletDispenserInt1;         
            
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont1 = new ApexPages.StandardController(outletDispenserInt1);
            system.assertNotEquals(outletDispenserInt1.Id, null);
            outletAssgnmntCtrl1 = new FET_OutletAssignmentCtrl(stdCont1);
            outletAssgnmntCtrl1.save();
            outletAssgnmntCtrl1.removeAssignToOutlet();
            outletAssgnmntCtrl1.redirectPopup();
            outletAssgnmntCtrl1.closePopup1();
            outletAssgnmntCtrl1.closePopup2();
            outletAssgnmntCtrl1.closePopup();
        }
        Test.stopTest(); 
    }
    
    //test method assigned to outlet
    private static testMethod void myUnitTest6() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        // TO DO: implement unit test
       
        createTestData();
        normalAcc.fs_Chain__C=chainAccount.id;
        normalAcc.FS_ACN__c = ACN;        
        update normalAcc; 
        
        Test.startTest();
        outletDispenserInt1.FS_Status__c = 'Assigned to Outlet';       
        outletDispenserInt1.Warehouse_Details__c = war1.Id;
        insert outletDispenserInt1;        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont1 = new ApexPages.StandardController(outletDispenserInt1);
            system.assertNotEquals(outletDispenserInt1.Id, null);
            outletAssgnmntCtrl1 = new FET_OutletAssignmentCtrl(stdCont1);
            outletAssgnmntCtrl1.save();
            outletAssgnmntCtrl1.removeAssignToOutlet();
            outletAssgnmntCtrl1.redirectPopup();
            outletAssgnmntCtrl1.closePopup1();
            outletAssgnmntCtrl1.closePopup2();
            outletAssgnmntCtrl1.closePopup();
        }
        Test.stopTest();        
    }
    
    
    private static testMethod void testAssignNewOutletDispenser() {
        FSTestUtil.insertPlatformTypeCustomSettings();    
        // TO DO: implement unit test
             
        final List<Account> outletsToInsert = new List<Account>();       
        
        createTestData();
        normalAcc.fs_Chain__C=chainAccount.id;
        normalAcc.FS_ACN__c = ACN;     
        outletsToInsert.add(normalAcc) ;
        bottlerAcc=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        outlet2 = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id, false);
        outlet2.fs_Chain__C=chainAccount.id;
        outlet2.FS_ACN__c = '7687687699';
        outlet2.ShippingStreet='test street';
        outlet2.ShippingPostalCode='654321';
        outlet2.Bottlers_Name__c = bottlerAcc.id;   
        outlet2.RecordTypeId=FSConstants.RECORD_TYPE_OUTLET1;
        outlet2.FS_Is_Address_Validated__c='Yes';
        outlet2.Is_Default_FET_International_Outlet__c=true; 
        outlet2.FS_SAP_ID__c='12334577';
        outletsToInsert.add(outlet2) ;            
        upsert outletsToInsert;
        
        outletDispenserInt1.FS_Status__c = 'New';       
        outletDispenserInt1.Warehouse_Details__c = war1.Id;
        insert outletDispenserInt1;            
        
        Test.startTest(); 
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont1 = new ApexPages.StandardController(outletDispenserInt1);
            system.assertNotEquals(outletDispenserInt1.Id, null);
            outletAssgnmntCtrl1 = new FET_OutletAssignmentCtrl(stdCont1);
            outletAssgnmntCtrl1.outletRef.FS_Outlet__c=outlet2.id;
            outletAssgnmntCtrl1.save();
            outletAssgnmntCtrl1.removeAssignToOutlet();
        }
        Test.stopTest();        
    }    
    
    //test method for removed from outlet
    private static testMethod void myUnitTest4() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        // TO DO: implement unit test
        Test.startTest();              
        
        createTestData();
        normalAcc.fs_Chain__C=chainAccount.id;
        normalAcc.FS_ACN__c = ACN;      
        update normalAcc;          
        
        outletDispenserInt1.FS_Status__c='Removed From Outlet';        
        insert outletDispenserInt1;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont1 = new ApexPages.StandardController(outletDispenserInt1);
            system.assertNotEquals(outletDispenserInt1.Id, null);
            outletAssgnmntCtrl1 = new FET_OutletAssignmentCtrl(stdCont1);
            outletAssgnmntCtrl1.save();
            outletAssgnmntCtrl1.redirectPopup1();
            outletAssgnmntCtrl1.closePopup1();
            outletAssgnmntCtrl1.closePopup2();
            outletAssgnmntCtrl1.closePopup3();
            outletAssgnmntCtrl1.closePopup();  
        }
        Test.stopTest();
    }
}