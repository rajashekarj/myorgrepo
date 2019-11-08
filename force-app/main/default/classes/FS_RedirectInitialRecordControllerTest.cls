//
// (c) 2014 Appirio, Inc.
//
// Controller class for FS_RedirectInitialRecordController
//
// Feb 05,2015    Samarth Sikand
//
@isTest
private class FS_RedirectInitialRecordControllerTest {
    public static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    private static testMethod void myUnitTest() {
        createTestData();      
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            
            final List<FS_Installation__c> lstFCInstallation = [Select Id from FS_Installation__c];
            final PageReference pageRef = Page.FS_RedirectInitialRecord;
            Test.setCurrentPage(pageRef);
            
            for(FS_Installation__c fcInstall : lstFCInstallation) {
                ApexPages.currentPage().getParameters().put('recordId', fcInstall.Id);           
                final FS_RedirectInitialRecordController testRedirectIO = new FS_RedirectInitialRecordController();
                testRedirectIO.redirectInitalOrder();
            }
        }
    }
    
    private static testMethod void myUnitTest2() {
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            
            final PageReference pageRef = Page.FS_RedirectInitialRecord;
            Test.setCurrentPage(pageRef);      
            
            final FS_RedirectInitialRecordController testRedirectIO = new FS_RedirectInitialRecordController();
            testRedirectIO.redirectInitalOrder();
        }
    }
    
    private static void createTestData() {     
        
        final List<FS_Installation__c> lstFCInstallation = new List<FS_Installation__c>();
        
        // Create Chain Account
        final Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
       
        final Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        // Create Outlets
        final Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false);
        accOutlet.FS_Approved_For_Execution_Plan__c = true;
        accOutlet.FS_Chain__c = accChain.Id;
        accOutlet.FS_Headquarters__c = accHQ.Id;   
        accOutlet.FS_ACN__c = 'outletACN';
        insert accOutlet;
        
        
        // Create Execution Plan
        final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);
        
        // Create Installation
       	final FS_Installation__c installation1 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,excPlan.Id, accOutlet.Id, false);
        installation1.FS_7000S_Dispenser_QTY__c = 0;
        installation1.FS_Eq_CS_Dispenser_QTY__c = 1;
        installation1.FS_7000_Series_Agitated_Brands_Selection__c = 'N/A to 8000/9000 Series';
        installation1.FS_7000_Series_Brands_Option_Selections__c = 'N/A to 8000/9000 Series';
        installation1.FS_7000_Series_Statics_Brands_Selection__c = 'N/A to 8000/9000 Series';
        
        
        lstFCInstallation.add(installation1);
        
        final FS_Installation__c installation2 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,excPlan.Id, accOutlet.Id, false);
        installation2.FS_7000S_Dispenser_QTY__c = 1;
        installation2.FS_Eq_CS_Dispenser_QTY__c = 0;
        lstFCInstallation.add(installation2);
        
        final FS_Installation__c installation3 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,excPlan.Id, accOutlet.Id, false);
        installation3.FS_7000S_Dispenser_QTY__c = 0;
        installation3.FS_Eq_CS_Dispenser_QTY__c = 0;
        lstFCInstallation.add(installation3);
        
        insert lstFCInstallation;
        
        final FS_Initial_Order_Setting__c testIOSetting = new FS_Initial_Order_Setting__c();
        testIOSetting.FS_Record_Id__c = 'a0C';
        testIOSetting.FS_X7000_Series_Record_Type_Id__c = '012f0000000D6sk';
        testIOSetting.FS_X8000_9000_Series_Record_Type_Id__c = '012f0000000D6sl';
        testIOSetting.FS_New_Install_Record_Type_Id__c = '012f0000000D6sm';
        testIOSetting.Installation_Id__c = 'CF00Ni000000CLN5D_lkid';
        testIOSetting.Installation_Name__c = 'CF00Ni000000CLN5D';
        insert testIOSetting;
    }
}