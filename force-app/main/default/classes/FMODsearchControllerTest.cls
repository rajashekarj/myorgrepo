/**************************************************************************************
Apex Class Name     : FMODsearchControllerTest
Version             : 1.0
Function            : This test class is for FMODsearchController Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FMODsearchControllerTest {
    public static Account chainAccount,headQuarterAcc,outletAcc,bottler;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;
    public static FS_IP_Technician_Instructions__c  ipTechInstruction;
    public static Shipping_Form__c shippingForm;
    public static Dispenser_Model__c dispenserModel;
    public static FS_Outlet_Dispenser__c outletDispenser;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    //--------------------------------------------------------------------------------------
    //Create Test Data For Account Update
    //--------------------------------------------------------------------------------------
    private static void createTestData(){
        final Profile manufacturerProfile = FSTestFactory.getProfileId(FSConstants.USER_PROFILE_FETSEMANUFACTURER);
        final User manufacturerUser = FSTestFactory.createUser(manufacturerProfile.id);
        manufacturerUser.IC_Code__c = '1700715';
        insert manufacturerUser;
        
        chainAccount = FSTestUtil.createTestAccount('Test Chain',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAccount.FS_ACN__c = '76876876ICH';
        insert chainAccount;
        HeadQuarterAcc =FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
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
        
        final FS_Outlet_Dispenser__c outletDispenser = new FS_Outlet_Dispenser__c();
        outletDispenser.FS_Equip_Type__c = '7000';
        outletDispenser.FS_Outlet__c=outletAcc.Id;
        outletDispenser.FS_Serial_Number2__c = 'ABCDEF1234';
        outletDispenser.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType, FSConstants.RT_NAME_CCNA_OD);
        insert outletDispenser;
    }
    //Controller will retrun List of OD with given Serial Number
    private static testmethod void testSearchDisp(){
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            createTestData();
            final List<FS_Outlet_Dispenser__c> result=FMODsearchController.searchDisp('ABCDEF1234');
            ODsearchController.searchDisp('ABCDEF1234');
            system.assert(!result.isEmpty());
        }
    }
    //Controller will return NULL LIST if passing Null String
    private static testmethod void testSearchDispNegative(){
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            createTestData();
            final List<FS_Outlet_Dispenser__c> result=FMODsearchController.searchDisp('');
            ODsearchController.searchDisp('');
            system.assertEquals(null,result);
        }
    }
    
}