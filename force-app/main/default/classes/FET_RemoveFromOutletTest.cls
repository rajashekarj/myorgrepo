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
Apex Class Name     : FET_RemoveFromOutletTest
Version             : 1.0
Function            : This test class is for FET_RemoveFromOutlet Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FET_RemoveFromOutletTest {
    public static Shipping_Form__c shippingForm;
    public static Dispenser_Model__c dispenserModel;
    public static User coordinatorUser;
    public static FS_Outlet_Dispenser__c dispenser;
    public static Account headquartersAcc,normalAcc,bottlerAcc,chainAccount;
    public static FS_Outlet_Dispenser__c outletDispenserInt1;
    public static Warehouse_Details__c war1;
    public static ApexPages.StandardController stdCont;
    public static Fet_RemoveFromOutlet outletRemoval;
    public static final string IDS='id';
    //test method for enrolled status
    
    private static void createTestData(){
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);        
        normalAcc = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id, false);        
        //Bottler
        bottlerAcc=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        normalAcc.Bottlers_Name__c = bottlerAcc.id;   
        //system.debug('hq acc : ' + headquartersAcc +  ' acc : ' + acc); 
        normalAcc.RecordTypeId=FSConstants.RECORD_TYPE_OUTLET1;
        normalAcc.FS_Is_Address_Validated__c='Yes';
        normalAcc.FS_ACN__c='123456789';
        normalAcc.Is_Default_FET_International_Outlet__c=true;         
        insert normalAcc;
        
        shippingForm = FSTestUtil.createShippingForm(true);
        dispenserModel = FSTestUtil.createDispenserModel(true, '2000');
        outletDispenserInt1= FSTestUtil.createOutletDispenserAllTypes(FSConstants.OD_RECORD_TYPE_INT,null,normalAcc.id,null,false);
        //outletDispenserInt1.FS_Model__c = '7000';        
        outletDispenserInt1.Shipping_Form__c = shippingForm.id;
        outletDispenserInt1.FSInt_Dispenser_Type__c = dispenserModel.id;
        outletDispenserInt1.FS_Serial_Number2__c = 'TEST_7687';
        outletDispenserInt1.Warehouse_Country__c = 'New Zealand';
        outletDispenserInt1.Warehouse_Name__c = 'New Zealand #1';
        outletDispenserInt1.Brand_Set__c = 'NZ Default Collection';
        outletDispenserInt1.FS_Planned_Install_Date__c =system.now().date();
        outletDispenserInt1.Planned_Remove_Date__c =system.now().date()+1;
        outletDispenserInt1.FS_IsActive__c = true;
        outletDispenserInt1.FS_Outlet__c = normalAcc.id;
    } 
    
    private static testMethod void myUnitTest() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        // TO DO: implement unit test
        Test.startTest();
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);      
        
        system.runAs(coordinatorUser){ 
            createTestData();            
            outletDispenserInt1.FS_Status__c='Enrolled';            
            insert outletDispenserInt1;
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont = new ApexPages.StandardController(outletDispenserInt1);          
            
            system.assertNotEquals(outletDispenserInt1.Id, null);
            
            outletRemoval = new Fet_RemoveFromOutlet(stdCont);
            outletRemoval.remove();
            outletRemoval.closePopup(); 
            outletRemoval.closePopup1();
            outletRemoval.closePopup2();
            outletRemoval.redirectPopup();
        }        
    }
    //test method for new status
    
    private static testMethod void myUnitTest1() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        // TO DO: implement unit test
        Test.startTest();
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);       
        
        system.runAs(coordinatorUser){  
            createTestData();            
            outletDispenserInt1.FS_Status__c='New';            
            insert outletDispenserInt1;
            
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont = new ApexPages.StandardController(outletDispenserInt1);            
            
            system.assertNotEquals(outletDispenserInt1.Id, null);
            
            outletRemoval = new Fet_RemoveFromOutlet(stdCont);
            outletRemoval.remove();
            outletRemoval.closePopup(); 
            outletRemoval.closePopup1();
            outletRemoval.closePopup2();
            outletRemoval.redirectPopup();
        }
    }
    
    //test method for dispenser delivered status
    private static testMethod void myUnitTest2() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        // TO DO: implement unit test
        Test.startTest();
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
       
        system.runAs(coordinatorUser){ 
            createTestData();
            war1 = new Warehouse_Details__c();
            war1.Brand_Set__c = 'sample1';
            war1.Name = 'sample2';
            war1.Warehouse_Country__c = 'CA';  
            insert war1;            
           
            outletDispenserInt1.FS_Status__c='Dispenser Delivered';            
            outletDispenserInt1.Warehouse_Details__c = war1.Id ;            
            insert outletDispenserInt1;
            
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont = new ApexPages.StandardController(outletDispenserInt1);        
            
            system.assertNotEquals(outletDispenserInt1.Id, null);
            
            outletRemoval = new Fet_RemoveFromOutlet(stdCont);
            outletRemoval.remove();
            outletRemoval.closePopup(); 
            outletRemoval.closePopup1();
            outletRemoval.closePopup2();
            outletRemoval.redirectPopup();
        }        
        
    }
    //test method for removed from outlet status
    private static testMethod void myUnitTest4() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        // TO DO: implement unit test
        Test.startTest();
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
        
        
        system.runAs(coordinatorUser){ 
            createTestData();
            
            outletDispenserInt1.FS_Status__c='Removed From Outlet';            
            insert outletDispenserInt1;
            
            ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
            stdCont = new ApexPages.StandardController(outletDispenserInt1);            
            
            system.assertNotEquals(outletDispenserInt1.Id, null);
            
            outletRemoval = new Fet_RemoveFromOutlet(stdCont);
            outletRemoval.remove();            
            outletRemoval.closePopup(); 
            outletRemoval.closePopup3();            
            outletRemoval.redirectPopup();
        }
        
    }
    //test method for assigned to outlet status
    
    private static testMethod void myUnitTest5() {
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        // TO DO: implement unit test
        Test.startTest();
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
        
        chainAccount = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAccount.FS_ACN__c = '76876876ICH';
        insert chainAccount;
        system.runAs(coordinatorUser){ 
        createTestData();
        }
        normalAcc.fs_Chain__C=chainAccount.id;
        update normalAcc;
        war1 = new Warehouse_Details__c();
        war1.Brand_Set__c = 'sample1';
        war1.Name = 'sample2';
        war1.Warehouse_Country__c = 'CA';  
        insert war1;     
                
        outletDispenserInt1.FS_Status__c='Assigned To Outlet';
        outletDispenserInt1.Warehouse_Details__c = war1.Id;       
        insert outletDispenserInt1;
        
        ApexPages.currentPage().getParameters().put(IDS, outletDispenserInt1.id);
        stdCont = new ApexPages.StandardController(outletDispenserInt1);      
        
        system.assertNotEquals(outletDispenserInt1.Id, null);
        
        outletRemoval = new Fet_RemoveFromOutlet(stdCont);
        outletRemoval.remove();
        // system.assertNotEquals(outletDispenserInt1.fs_isActive__C, false);
        
        outletRemoval.closePopup(); 
        outletRemoval.closePopup1();
        outletRemoval.closePopup4();
        outletRemoval.redirectPopup();       
    }  
}