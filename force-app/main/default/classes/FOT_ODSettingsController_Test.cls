@isTest
public class FOT_ODSettingsController_Test {
	private static Account accchain,bottler,outlet,accHQ;
    @TestSetUp
    Static void RecordCreate(){
        
        FSTestFactory.lstPlatform(); 
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        //Create Headquarters
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        outlet = FSTestUtil.createAccountOutlet('Test Outlet',FSConstants.RECORD_TYPE_OUTLET,accHQ.id, true);
        FS_Outlet_Dispenser__c outletDispenser1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outlet.id,null,true);
        
        List<FS_OD_Settings__c> lstODSetting = New List<FS_OD_Settings__c> ();
        FS_OD_Settings__c ODSet1 = New FS_OD_Settings__c();
        
        ODSet1.FS_OD_RecId__c=outletDispenser1.id;
        lstODSetting.add(ODSet1);
        
        List<FS_OD_SettingsReadOnly__c> lstODsetReadOnly = New List<FS_OD_SettingsReadOnly__c> ();
        FS_OD_SettingsReadOnly__c setReadOnly = New FS_OD_SettingsReadOnly__c();
        setReadOnly.FS_OD_RecId__c =outletDispenser1.id;
        lstODsetReadOnly.add(setReadOnly);
        
    }
    
     @istest
    static void testMethod1()
    {
        
        FS_Outlet_Dispenser__c Od = [Select Id FROM FS_Outlet_Dispenser__c];
        //final Profile fotOPAmin=FSTestFactory.getProfileId(FSConstants.USER_PROFILE_OP_ADMIN);
        //final User fotOPAminUser=FSTestFactory.createUser(fotOPAmin.id);
        //insert fotOPAminUser;
        String proName;
         //system.runAs(fotOPAminUser){ 
         test.startTest();
        FOT_ODSettingsController.ODSettingsRecordDetails(Od.Id);
        FOT_ODSettingsController.ODEDitableSettingsRecordDetails(Od.Id);
        proName = FOT_ODSettingsController.userProfileAccess();
        //system.assertEquals('Ops Admin', proName);
        system.assertEquals('System Administrator', proName);
        test.stopTest();
         //}
    }
}