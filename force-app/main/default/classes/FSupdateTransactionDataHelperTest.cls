@isTest
private class FSupdateTransactionDataHelperTest{
    
    private static testMethod void testMethod1() {
        
        final list<Account> lstLead= new list<Account>();
        
        system.debug('commit');
        for(Integer i=0 ;i <200;i++)        {
            final Account acc = new Account();
            acc.Name ='Name'+i;
            lstLead.add(acc);
        }        
        insert lstLead;
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.systemAdmin);
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSupdateTransactionDataHelper helper= new FSupdateTransactionDataHelper();
            final FSupdateTransactionDataHelperBatch lis=new FSupdateTransactionDataHelperBatch();
            lis.start(null);
            lis.execute(null,lstLead);
            lis.finish(null);
        }        
        Test.stopTest();
    }
    
     private static testMethod void testMethod2() {
        
        final list<Account> lstLead= new list<Account>();
        for(Integer i=0 ;i <200;i++)        {
            final Account acc = new Account();
            acc.Name ='Name'+i;
            lstLead.add(acc);
        }        
        insert lstLead;
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.systemAdmin);
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSupdateTransactionDataBatch7000Series lis=new FSupdateTransactionDataBatch7000Series();
            lis.start(null);
            lis.execute(null,lstLead);
            lis.finish(null);
        }        
        Test.stopTest();
    }
    
    
    
    
    
    /*Commenting Initial Order SAP Data Object related lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0
    static Account headQuarterAcc, outletAcc;
    static List<FS_Initial_Order__c> initialOrder;
    static FS_Execution_Plan__c executionPlan;
    static FS_Installation__c installation,installation8k9k;
    static final Id initialOrder7000RecordType=FSUtil.getObjectRecordTypeId(FS_Initial_Order__c.SObjectType,'7000 Series');
    static final Id initialOrder8K9KRecordType=FSUtil.getObjectRecordTypeId(FS_Initial_Order__c.SObjectType,'8000 OR 9000 Series');
    static FS_Initial_Order_SAP_Data__c sapData8k9kStatic,sapData8k9kAgitated,sapData8k9kCore;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    static testmethod void testupdateMasterData7k(){ 
        createTestData();     
        Test.startTest();
        initialOrder=new List<FS_Initial_Order__c>();
        initialOrder= FSTestFactory.createTestInitialOrder(outletAcc.Id, installation.Id, false,2,initialOrder7000RecordType);
        for(FS_Initial_Order__c initial:initialOrder){
            initial.FS_Order_Processed_DataTime__c=datetime.now();
        }        
        insert initialOrder;
        List<FSSAPMaterialNameAndOverrideField__c> customSettingList=[select SAP_Material_Name__c,Cartridge_Name__c,OverrideField__c from FSSAPMaterialNameAndOverrideField__c];
        List<String>  sapNameAndCartridge = new List<String>();
        for(FSSAPMaterialNameAndOverrideField__c csList: customSettingList){
            sapNameAndCartridge.add(csList.SAP_Material_Name__c+ ':' + csList.Cartridge_Name__c);
        } 
        
        
        List<FS_Initial_Order_SAP_Data__c> masterDataList = [SELECT Name,Cartridge_Name__c,Cost_per_Unit__c,FS_7000_Package_Days_Capacity_1000__c,Days_In_Stock__c  
                                                             FROM FS_Initial_Order_SAP_Data__c WHERE Master_Data__c =: true AND FS_Type__c='7000 Series' limit 1];
        for(FS_Initial_Order_SAP_Data__c masterData :masterDataList){
            masterData.Cost_per_Unit__c=20;
            masterData.FS_7000_Package_Days_Capacity_1000__c=20;
            masterData.Days_In_Stock__c=20;
        }     
final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
        update masterDataList;
}
        Test.stopTest(); 
    }
    static testmethod void testupdateMasterData8k9k(){
        createTestData();    
        Test.startTest();
         
        initialOrder=new List<FS_Initial_Order__c>();
        initialOrder= FSTestFactory.createTestInitialOrder(outletAcc.Id, installation8k9k.Id, false,2,initialOrder8K9KRecordType);
        for(FS_Initial_Order__c initial:initialOrder){
            initial.FS_Order_Processed__c=false;
            initial.FS_Order_Processed_DataTime__c=datetime.now();
            initial.FS_X7_Slots_to_Add2__c = 1;
        	initial.FS_X2_Slots_to_Add2__c = 1;
        	initial.FS_X4_Slots_to_Add2__c = 1;
        	initial.FS_X3_Slots_to_Add2__c = 1;
        	initial.FS_X18_Slots_to_Add2__c = 1;
        	initial.FS_X16_Slots_to_Add2__c = 1;
        	initial.FS_X22_Slots_to_Add2__c=  1;
        }        
        insert initialOrder;
       
        sapData8k9kCore=FSTestUtil.createSAPData('Core','Core Cartridge',false);
        sapData8k9kCore.FS_Type__c='8000 OR 9000 Series';
        insert sapData8k9kCore;
        
        sapData8k9kAgitated=FSTestUtil.createSAPData('Agitated', 'Agitated Cartridge', false);
        sapData8k9kAgitated.FS_Type__c='8000 OR 9000 Series';
        insert sapData8k9kAgitated;
        
        sapData8k9kStatic=FSTestUtil.createSAPData('Static','Static Cartridge',false);
        sapData8k9kStatic.FS_Type__c='8000 OR 9000 Series';
        insert sapData8k9kStatic;
        
        List<FSSAPMaterialNameAndOverrideField__c> customSettingList=[select SAP_Material_Name__c,Cartridge_Name__c,OverrideField__c from FSSAPMaterialNameAndOverrideField__c];
        List<String>  sapNameAndCartridge = new List<String>();
        for(FSSAPMaterialNameAndOverrideField__c csList: customSettingList){
            sapNameAndCartridge.add(csList.SAP_Material_Name__c+ ':' + csList.Cartridge_Name__c);
        } 
        List<FS_Initial_Order_SAP_Data__c> masterDataList = [SELECT Name,Cartridge_Name__c,Cost_per_Unit__c,FS_7000_Package_Days_Capacity_1000__c,FS_Package_Days_Capacity_Pepper_1000__c,Days_In_Stock__c,  
                                                             Slots_8k9k__c FROM FS_Initial_Order_SAP_Data__c WHERE Master_Data__c =: true AND FS_Type__c='8000 OR 9000 Series' limit 1];
        for(FS_Initial_Order_SAP_Data__c masterData :masterDataList){
            masterData.Cost_per_Unit__c=20;
            masterData.FS_7000_Package_Days_Capacity_1000__c=20;
            masterData.Days_In_Stock__c=20;
            masterData.FS_Package_Days_Capacity_Pepper_1000__c=20;
            masterData.Slots_8k9k__c=4;
        } 
final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
        update masterDataList;
}
        Test.stopTest();  
    }
    
    //-------------------------------------------------------------------------------------
    //Create Test Data 
    //-------------------------------------------------------------------------------------
    
    private static void createTestData(){
        
        HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        //Creates Outlet Accounts
        outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, true);
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.x7000SeriesRecType,HeadQuarterAcc.Id, true);
        //creates installation
        installation = FSTestUtil.createInstallationAcc(FSConstants.x7000SeriesRecType,executionPlan.Id,outletAcc.Id,true);
        installation8k9k = FSTestUtil.createInstallationAcc(FSConstants.x8K9KSeriesRecType,executionPlan.Id,outletAcc.Id,true);
    }
    
    @testSetup
    static void testLoadData() 
    {
        system.debug('FSupdateTransactionDataHelperTest2');
        List<sObject> sapData= Test.loadData(FS_Initial_Order_SAP_Data__c.sObjectType,'TestDataIOSAPData');         
        //Verify that all test SAP Data were created
        System.assert(sapData.size() == 55);
        
        List<sObject> customSetting= Test.loadData(FSSAPMaterialNameAndOverrideField__c.sObjectType,'TestDataCustomSetting');
        //Verify that all test SAP Data were created
        System.assert(customSetting.size() == 31);
        
    }
    @testSetup  
    static void mytestSetup() {
        Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
        
        disableTriggerSetting.name='FSupdateTransactionDataHelper';
        disableTriggerSetting.IsActive__c=true;
        disableTriggerSetting.Trigger_Name__c='FSupdateTransactionDataForInitialOrder' ; 
        insert disableTriggerSetting;   
    }  */  
}