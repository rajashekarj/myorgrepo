@isTest
public class FOT_UpdateSettings_Batch_Test {
    public static Account headquartersAcc,acc,headquartersAcc1,acc1;
    @testSetup
    static void testSetup1(){ 
        
        headquartersAcc = FSTestUtil.createTestAccount('Test',FSConstants.RECORD_TYPE_HQ,true);
        acc = FSTestUtil.createAccountOutlet('Test Outlet',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id, false);
        acc.RecordTypeId=FSConstants.RECORD_TYPE_OUTLET1;
        acc.FS_Is_Address_Validated__c='Yes';
        acc.Is_Default_FET_International_Outlet__c=true; 
        insert acc;

        FSTestUtil.insertPlatformTypeCustomSettings();

        FS_Outlet_Dispenser__c od=new FS_Outlet_Dispenser__c();
        FS_Outlet_Dispenser__c od1=new FS_Outlet_Dispenser__c();
        od= FSTestUtil.createOutletDispenserAllTypes(FSConstants.OD_RECORD_TYPE_INT,null,acc.id,null,false);
        od.FS_Serial_Number2__c = 'TEST_7687';
        od.FS_IsActive__c = true;
        od.FS_Outlet__c = acc.id;
        od.FS_Planned_Install_Date__c =system.now().date();
        od.FS_Status__c = 'Assigned to Outlet'; 
        insert od; 
        
        FS_OD_Settings__c editableSetting = new FS_OD_Settings__c();
        editableSetting.FS_OD_RecId__c = od.id;
        insert editableSetting;
    }
    
    private static testMethod void test1(){
        Test.startTest();
        //List<FS_Outlet_Dispenser__c > oDList=new List<FS_Outlet_Dispenser__c>(); 
        //oDList = [SELECT id FROM FS_Outlet_Dispenser__c WHERE Id NOT IN (SELECT FS_OD_RecId__c FROM FS_OD_SettingsReadOnly__c) LIMIT 200];
        //system.debug('oDList:-'+oDList);
        try{
            DataBase.executeBatch(new FOT_UpdateSettings_Batch());
        }catch(exception e) {}
        Test.stopTest();
    }
    
}