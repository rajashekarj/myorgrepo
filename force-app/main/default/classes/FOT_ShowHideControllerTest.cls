@istest
public class FOT_ShowHideControllerTest {

    public static Account headquartersAcc, outletacc,headquartersAcc1,acc1;
    public static FS_OD_Show_Hide__c testshowhide = new FS_OD_Show_Hide__c();
    public static FS_Outlet_Dispenser__c od=new FS_Outlet_Dispenser__c();
    
    @testSetup static void testsetupshowhide()
    {
        headquartersAcc = FSTestUtil.createTestAccount('Test',FSConstants.RECORD_TYPE_HQ,true);
        outletacc = FSTestUtil.createAccountOutlet('Test Outlet',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id, false);
        outletacc.RecordTypeId=FSConstants.RECORD_TYPE_OUTLET1;
        outletacc.FS_Is_Address_Validated__c='Yes';
        outletacc.Is_Default_FET_International_Outlet__c=true; 
        insert outletacc;
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        FS_Outlet_Dispenser__c od=new FS_Outlet_Dispenser__c();
        od= FSTestUtil.createOutletDispenserAllTypes(FSConstants.OD_RECORD_TYPE_INT,null,outletacc.id,null,false);
        od.FS_Serial_Number2__c = 'TEST_7687';
        od.FS_IsActive__c = true;
        od.FS_Outlet__c = outletacc.id;
        od.FS_Planned_Install_Date__c =system.now().date();
        od.FS_Status__c = 'Assigned to Outlet'; 
        insert od; 
        
        testshowhide.FS_ODRecID__c = od.id;
        testshowhide.show_hide_setting__c = 'Show';
        testshowhide.beverage_id__c = 'testbevarage';
        testshowhide.Name = 'testbevarage';
        insert testshowhide;
        system.debug('****testshowhide.FS_ODRecID__c1****:' +testshowhide.FS_ODRecID__c);
    }
    
    @isTest static void testuserProfileAccess()
    {
        String usrname = FOT_ShowHideController.userProfileAccess();
    }
    
    @isTest static void testShowHideRecordDetails() 
    {
        system.debug('****od id****:' +od.id);
        system.debug('****testshowhide.FS_ODRecID__c****:' +testshowhide.FS_ODRecID__c);
        FS_Outlet_Dispenser__c odrec = [select id from FS_Outlet_Dispenser__c limit 1];
        
        List<FS_OD_Show_Hide__c> showhidelist = FOT_ShowHideController.ShowHideRecordDetails(odrec.id);
    }
}