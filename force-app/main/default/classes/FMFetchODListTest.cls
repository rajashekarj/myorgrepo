/**************************************************************************************
Apex Class Name     : FMFetchODListTest
Version             : 1.0
Function            : This test class is for FMFetchODList Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
/*
To run test please make sure Context User has some value in IC_Code__c field in User object
*/
@isTest
public class FMFetchODListTest {
    static Account chainAccount,headQuarterAcc,outletAcc,bottler;
    static FS_Execution_Plan__c executionPlan;
    static FS_Installation__c installation;
    static FS_IP_Technician_Instructions__c  ipTechInstruction;
    static Shipping_Form__c shippingForm;
    static Dispenser_Model__c dispenserModel;
    static FS_Outlet_Dispenser__c outletDispenser;
    //---------------------------------- 
    //Create Test Data For Account Update
    //-----------------------------------
    static void createTestData(){
        //create an user with 'FET SE Manufacturer Profile' profile
        final Profile manufacturerProfile = FSTestFactory.getProfileId(FSConstants.USER_PROFILE_FETSEMANUFACTURER);
		final User manufacturerUser = FSTestFactory.createUser(manufacturerProfile.id);
        manufacturerUser.IC_Code__c = '1700715';
		insert manufacturerUser;
        
        chainAccount = FSTestUtil.createTestAccount('Test Chain',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAccount.FS_ACN__c = '76876876ICH';
        insert chainAccount;
        HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        HeadQuarterAcc.FS_ACN__c = '7658765876';
        insert HeadQuarterAcc;
        //Creates Outlet Accounts
        outletAcc = FSTestUtil.createAccountOutlet('test',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, true);
        system.runAs(manufacturerUser){
        	shippingForm = FSTestUtil.createShippingForm(true);
        }
        dispenserModel = FSTestUtil.createDispenserModel(true, '7000');
        
         //create platform type custom settings
         FSTestUtil.insertPlatformTypeCustomSettings();
        
         //set mock callout
         Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());

       	FS_Outlet_Dispenser__c outletDispenser = new FS_Outlet_Dispenser__c();
        outletDispenser.FS_Equip_Type__c = '7000';
        outletDispenser.FS_Outlet__c=outletAcc.Id;
        outletDispenser.FS_Serial_Number2__c = '12345676';
        outletDispenser.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType, FSConstants.RT_NAME_CCNA_OD);
        insert outletDispenser;
    }
    
	//Controller will return list of OD with serial number
     private static testmethod void testListOD(){
        createTestData();
        //final User testUser=[select id from user where id=:Userinfo.getUserId()];
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        adminUser.IC_Code__c='1700710';
       	insert adminUser;
       
         system.runAs(adminUser){

             FMFetchODList res =FMFetchODList.BarcodeMatchODList('12345676');
             FetchODList.BarcodeMatchODList('12345676');
             system.assert(!res.listOutlets.isEmpty());
         }
         
    }
    
    //For null serial number no result
    private static testmethod void testListODNull(){
        createTestData();
        final User testUser=[select id from user where id=:Userinfo.getUserId()];
        system.runAs(testUser){
            
            string barc = 'NULL' ;
            FMFetchODList res=FMFetchODList.BarcodeMatchODList(barc);
            FetchODList.BarcodeMatchODList(barc);
            system.assertEquals(Label.UnableToReadBarcode,res.errString);
        }
    }
    
    private static testmethod void testListODDiffSeri(){

        createTestData();
        
        final User testUser=[select id from user where id=:Userinfo.getUserId()];
        system.runAs(testUser){
            
            string barc = '112233' ;
            FMFetchODList res=FMFetchODList.BarcodeMatchODList(barc);
            FetchODList.BarcodeMatchODList(barc);
            system.assertEquals(Label.NoMatchingDispensers,res.errString);
        }
    }
}