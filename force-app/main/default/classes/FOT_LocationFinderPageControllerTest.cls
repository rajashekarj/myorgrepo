/*********************************************************************************************************
Name         : FOT_LocationFinderPageControllerTest
Created By   : Infosys Limited 
Created Date : 11-Jan-2019
Usage        : Test Class for FOT_LocationFinderPageController

***********************************************************************************************************/
@istest
public class FOT_LocationFinderPageControllerTest{
    
    public static Account headquartersAcc,acc,headquartersAcc1,acc1;
    
    @istest static void LocationFinder()
    {
    
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
         Test.startTest();  
            ApexPages.StandardController sc = new ApexPages.standardController(od);
            FOT_LocationFinderPageController loc=new FOT_LocationFinderPageController(sc);
            loc.saveDispenserLocation();
         Test.stopTest();  
        } 
        
   @isTest static void testMyUpdate_Error()
    {
       	 FS_Outlet_Dispenser__c record = new FS_Outlet_Dispenser__c(); 
       	 ApexPages.StandardController controller = new ApexPages.StandardController(record);
         FOT_LocationFinderPageController extension = new FOT_LocationFinderPageController(controller);

         Test.startTest();
           PageReference redirect = extension.saveDispenserLocation();
         Test.stopTest();

         system.assert(ApexPages.hasMessages(), 'There should be an error');
         system.assertEquals(null, redirect, 'Redirect should be cancelled');
	}
}