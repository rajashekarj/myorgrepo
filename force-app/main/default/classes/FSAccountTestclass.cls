/**************************************************************************************
Apex Class Name     : FSAccountTestclass
Version             : 1.0
Function            : This test class is to test Account related classes. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
    * Infosys             		          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSAccountTestclass{
    
    static Account accchain,accchainNew,accHQ,accOutlet,accDist,bottler,intOutlet,intChain,intHQ,odOutlet,headQuarterAcc ;
    static User user;
    static FS_Execution_Plan__c executionPlan;
    static FS_Installation__c installation;
    static FS_Outlet_Dispenser__c outletDispenser,intOD,outletDispenserNegativePath;
    static Map<Id, Boolean> mapFSSAPID = new Map<Id, Boolean>();
    static Set<Id> lstAllOTAccIds = new set<Id>();
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5; 
    
    //--------------------------------------------------------------------------------------
    //Create Test Data For Account Update
    //--------------------------------------------------------------------------------------
    static void createTestData(){
        //Create chain
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        //Create Headquarters
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        //Create Outlet
        accOutlet = FSTestUtil.createAccountOutlet('Firehouse',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false);
        accOutlet.FS_SAP_ID__c = '1234';
        insert accOutlet;
        
        //Enable custom setting for Account Trigger from FSTestUtil
        //For Account Trigger 
        
        List<Platform_Type_ctrl__c> listplatform = new List<Platform_Type_ctrl__c>();
		platformTypes=new Platform_Type_ctrl__c();
		platformTypes.Name='updateBrands';
        platformTypes.Platforms__c='7000';
        listplatform.add(platformTypes);
		platformTypes1=new Platform_Type_ctrl__c();
		platformTypes1.Name='EquipmentTypeCheckForNMSUpdateCall';
        platformTypes1.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes1);
        platformTypes2=new Platform_Type_ctrl__c();
		platformTypes2.Name='WaterHideCheck';
        platformTypes2.Platforms__c='8000,9000';
        listplatform.add(platformTypes2);
        platformTypes3=new Platform_Type_ctrl__c();
		platformTypes3.Name='all_Platform';
        platformTypes3.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes3);
        platformTypes4=new Platform_Type_ctrl__c();
		platformTypes4.Name='updatecrewServeDasani';
        platformTypes4.Platforms__c='8000';
        listplatform.add(platformTypes4);
        platformTypes5=new Platform_Type_ctrl__c();
		platformTypes5.Name='updateSelfServeDasani';
        platformTypes5.Platforms__c='9000';
        listplatform.add(platformTypes5);
        insert listplatform; 
        
        //Create Outlet Dispenser and assign it to OD.
        //HQ for Execution plan
        headQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headQuarterAcc.Id, true);
        //creates installation
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,accOutlet.Id,false);      
        
        //Create Outlet for OD
        odOutlet=FSTestUtil.createAccountOutlet('Firehouse',FSConstants.RECORD_TYPE_OUTLET,headQuarterAcc.Id, false);
        odOutlet.FS_SAP_ID__c = '1234';
        insert odOutlet;
        FSTestFactory.createTestDisableTriggerSetting();
    }
    //--------------------------------------------------------------------------------------     
    //insertion of Outlet record
    //-------------------------------------------------------------------------------------- 
    static testmethod void beforeInsertCalls(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
      
        system.runAs(sysAdminUser){
        createTestData();
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.id,false);
        insert accOutlet;
        System.assertEquals(accHQ.Name,'Test Headquarters');
        System.assertEquals(accOutlet .Name,'Test Outlet 1');
        }
    }
    
    //-------------------------------------------------------------------------------------- 
    //update the outlet record
    //-------------------------------------------------------------------------------------- 
    static testmethod void beforeUpdateCalls(){
        createTestData();
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.id,false);
        accOutlet.shippingcountry='US';
        accOutlet.ShippingCity='Test City';
        accOutlet.ShippingState='Test State';
        accOutlet.ShippingStreet='Test Street';
        insert accOutlet;
        Test.startTest();
        
        //update Outlet fields
        accOutlet.ShippingPostalCode = '99999';
        accOutlet.ShippingCity='Test City1';
        accOutlet.ShippingState='Test State1';
        accOutlet.ShippingStreet='Test Street1';
        outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,accOutlet.id,null,true);

        outletDispenserList.add(outletDispenser);
        //outletDispenserList.add(outletDispenserNegativePath);
        //update HQ fields
        accHQ.name='Test Hq';
        //Update Chain fields
        accchain.name='Test CH';
        //Start Test
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){

        update outletDispenserList;
        update accOutlet;
        update accHQ;
        update accchain;
        System.assertEquals(accHQ.Name,'Test Hq');
        System.assertEquals(accOutlet .Name,'Test Outlet 1');

        Test.stopTest();
            
        }
    }
    
    static testmethod void testAccountAfterUpdateBulk(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
        
        createTestData();
        //Test on Changing Chain for a HQ
        final Account accchain1= FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        accchain1.Invoice_Customer__c = 'No';
        accchain1.FS_Payment_Type__c = 'No';
        insert accchain1;
        
        final Account accHQSingle=FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQSingle.FS_Chain__c =accchain1.id;
        accHQSingle.FS_Payment_Type__c = 'Yes';
        accHQSingle.FS_Payment_Method__c= 'Credit Card';
        accHQSingle.Invoice_Delivery_Method__c= 'Email';
        accHQSingle.Secondary_Email_1__c= 'e1@email.com';
        accHQSingle.Secondary_Email_2__c= 'e2@email.com';
        accHQSingle.Secondary_Email_3__c= 'e3@email.com';
        accHQSingle.Secondary_Email_4__c= 'e4@email.com';
        accHQSingle.Secondary_Email_5__c= 'e5@email.com';
        insert accHQSingle;
        Test.startTest();
        final List<Account> accHQList=new List<Account>();
        for(Integer i=1;i<=30;i++){
            final Account accHQ1= FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
            accHQ1.Name='Test HQ'+i;
            accHQ1.FS_Chain__c = accchain.Id;
            accHQList.add(accHQ1);
        }
        insert accHQList;
        system.assert(accHQList.size()>0);
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        
        final List<Account> accOutletList=new List<Account>();
        for(Account acc : accHQList){
            accOutlet= FSTestUtil.createAccountOutlet('Test Outlet'+acc.Name,FSConstants.RECORD_TYPE_OUTLET,acc.Id,false);            
            accOutlet.Bottler_Name__c='Coca-Cola Amatil Limited';
            accOutlet.Bottlers_Name__c = bottler.id;
            accOutletList.add(accOutlet);
        }
        insert accOutletList;
        final List<Account> accHQListUpdated=new List<Account>();
        for(Account acc: accHQList){
            acc.FS_Chain__c =accchain1.id;
            acc.FS_Payment_Type__c = 'Yes';
            acc.FS_Payment_Method__c= 'Credit Card';
            acc.Invoice_Delivery_Method__c= 'Email';
            acc.Secondary_Email_1__c= 'e11@email.com';
            acc.Secondary_Email_2__c= 'e22@email.com';
            acc.Secondary_Email_3__c= 'e33@email.com';
            acc.Secondary_Email_4__c= 'e44@email.com';
            acc.Secondary_Email_5__c= 'e55@email.com';
            accHQListUpdated.add(acc);
        }
            Test.stopTest();
        update accHQListUpdated;
        System.assertNotEquals(accOutletList, null);
        }
    }
    //-------------------------------------------------------------------------------------- 
    //Checking shipping Address updatation   
    //-------------------------------------------------------------------------------------- 
    static testmethod void testIntShippingAdd(){
        createTestData();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
        //Create international Chain
        intChain=FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        intchain.shippingcountry='GB';
        insert intChain;
        //Crate International HQ
        intHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        intHQ.FS_Chain__c = accchain.Id;
        insert intHQ;
        //Bottler for international outlet
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        //Create International outlet
        intOutlet= FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET_INT,intHQ.Id,false);
        intOutlet.FS_Shipping_Country_Int__c='GB';
        intOutlet.FS_Shipping_State_Province_INT__c='T State';
        intOutlet.FS_Shipping_City_Int__c='T City';
        intOutlet.FS_Shipping_Street_Int__c='T Street';
        insert intOutlet;
        System.assertNotEquals(intOutlet, null);
        }
    }
    
    //--------------------------------------------------------------------------------------
    //Validation 7000 fields
    //-------------------------------------------------------------------------------------- 
    static testmethod void checkValidationFor7000(){
        
        Test.startTest();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
        createTestData();
        final List<Account> lstHQAccounts = [Select FS_Payment_Type__c,
                                       FS_X7000_Series_Brands_Option_Selections__c,
                                       FS_7000_Series_Agitated_Brands_Selection__c,
                                       FS_7000_Series_Statics_Brands_Selection__c
                                       From Account
                                       Where FS_Chain__c =: accchain.Id
                                       And RecordTypeId =: FSConstants.RECORD_TYPE_HQ ];
        
        lstHQAccounts[0].FS_X7000_Series_Brands_Option_Selections__c = '2 Static/1 Agitated';
        lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c   = 'Powerade;raspberry';
        lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c  = 'Pibb';
        update lstHQAccounts[0];
        
        try{
            lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c   = '';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c   = 'Powerade;';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = '';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = 'barqs;pibb;Dr.pepper';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = 'N/A to 8000/9000 Series';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        lstHQAccounts[0].FS_X7000_Series_Brands_Option_Selections__c = '0 Static/2 Agitated';
        lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c   = '';
        lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c  = Label.Agitated_Brand_1 + ';' + Label.Agitated_Brand_2;
        update lstHQAccounts[0];
        
        try{
            lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c   = 'N/A to 8000/9000 Series';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c   = '';
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = 'N/A to 8000/9000 Series';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = 'Pibb;Barqs';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = 'Pibb;Dr. Pepper;Barqs';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c   = 'Pibb;';
            update lstHQAccounts[0];
        }catch(exception e){}
        Test.stopTest();
        }
        System.assertNotEquals(accchain, null);
    }
    
    //-------------------------------------------------------------------------------------- 
    //validation 8000 fields
    //-------------------------------------------------------------------------------------- 
    static testmethod void checkValidationFor8000(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
        Test.startTest();
        createTestData();
        final List<Account> lstHQAccounts = [Select FS_Payment_Type__c,
                                       FS_X7000_Series_Brands_Option_Selections__c,
                                       FS_7000_Series_Agitated_Brands_Selection__c,
                                       FS_7000_Series_Statics_Brands_Selection__c
                                       From Account
                                       Where FS_Chain__c =: accchain.Id
                                       And RecordTypeId =: FSConstants.RECORD_TYPE_HQ ];
        try{
            lstHQAccounts[0].FS_X7000_Series_Brands_Option_Selections__c = 'N/A to 8000/9000 Series';
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = 'N/A to 8000/9000 Series';
            lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c  = 'N/A to 8000/9000 Series';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = 'Pibb';
            update lstHQAccounts[0];
        }catch(exception e){}
        
        try{
            lstHQAccounts[0].FS_7000_Series_Agitated_Brands_Selection__c   = 'N/A to 8000/9000 Series';
            lstHQAccounts[0].FS_7000_Series_Statics_Brands_Selection__c  = 'POWERade';
            update lstHQAccounts[0];
        }catch(exception e){}
        Test.stopTest();
        }
        System.assertNotEquals(accchain, null);
    }
    
    //-------------------------------------------------------------------------------------- 
    //Invoice for Chain Update
    //--------------------------------------------------------------------------------------
    static testmethod void testChainAccountforInvoice(){
        createTestData();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
        Test.startTest();
        accchain.CS_Payment_Invoice_Eligible__c = true;
        accchain.FS_Payment_Type__c = 'Yes';
        update accchain;
        accchain.CS_Payment_Invoice_Eligible__c = false;
        accchain.FS_Payment_Type__c = 'No';
        update accchain;
        System.assertNotEquals(accchain, null);
        Test.stopTest();
        }
        
    }

    static testmethod void testChainAccountforInvoice2(){
        createTestData();
        final List<Account> accUpdate = new list<Account>{};
        final Account accchain2 = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
            Test.startTest();
            
            accchain.CS_Payment_Invoice_Eligible__c = true;
            accchain.FS_Payment_Type__c = 'Yes';
            accchain2.CS_Payment_Invoice_Eligible__c = true;
            accchain2.FS_Payment_Type__c = 'Yes';
            accUpdate.add(accchain);
            accUpdate.add(accchain2);
            update accUpdate;
            
            accchain.CS_Payment_Invoice_Eligible__c = false;
            accchain.FS_Payment_Type__c = 'No';
            accchain2.CS_Payment_Invoice_Eligible__c = false;
            accchain2.FS_Payment_Type__c = 'No';
            accHQ.Invoice_Delivery_Method__c='Mail';
            accUpdate.add(accHQ);
            update accUpdate;
            system.debug('---------Queries after testChainAccountforInvoice2---- '+Limits.getQueries());
        System.assertNotEquals(accUpdate, null);
        Test.stopTest();
        }
        
    }
    

    //-------------------------------------------------------------------------------------- 
    //Invoice for Chain Update
    //--------------------------------------------------------------------------------------
    static testmethod void testChainAccountforInvoicePath1(){
        createTestData();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        system.runAs(sysAdminUser){
            Test.startTest();
            accchain.CS_Payment_Invoice_Eligible__c = true;
            accchain.FS_Payment_Type__c = 'Yes';
            accchain.Invoice_Customer__c='No';
            accHQ.Invoice_Customer__c='No';
            update accchain;
            update accHQ;
            accchain.CS_Payment_Invoice_Eligible__c = false;
            accchain.FS_Payment_Type__c = 'No';
            accchain.Invoice_Customer__c='Yes';
            accHQ.Invoice_Customer__c='Yes';
            update accHQ;
            update accchain;
            
            final Account checkHQ = [SELECT Id, FS_Payment_Type__c FROM Account
                               WHERE RecordTypeId =: FSConstants.RECORD_TYPE_HQ
                               AND FS_Chain__c = :accchain.id];
            
        System.assertNotEquals(accchain, null);
            Test.stopTest();
        }
    }
    
    //--------------------------------------------------------------------------------------
    //Update HQ on Outlet
    //-------------------------------------------------------------------------------------- 
    static testmethod void testAccountAfterUpdateInstallationCount(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        System.runAs(sysAdminUser){
        Test.startTest();
        createTestData();
        final List<Account> accOutletList=new List<Account>();
        for(Integer i=1;i<=50;i++){
            final Account accOutlet1= FSTestUtil.createAccountOutlet('Test Outlet '+i,FSConstants.RECORD_TYPE_OUTLET1,accHQ.id,false);
            accOutlet1.FS_Installs_Complete__c=1;
            accOutlet1.FS_SAP_ID__c='1234';
            accOutletList.add(accOutlet1);
        }
        insert accOutletList;            
        
        final Account accHQChange=FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        for(Account acc: accOutletList){
            acc.FS_Headquarters__c=accHQChange.id;
        }
        update accOutletList;
        System.assertNotEquals(odOutlet, null);
        Test.stopTest();
        }
    }
   // ------------------------------------------------------------------------------------------
    //Update OD if Change on Outlet
    //--------------------------------------------------------------------------------------
    static testmethod void testOdUpdateOnOutlet(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        System.runAs(sysAdminUser){
        Test.startTest();
        createTestData();
        //Create OD
        outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,'8000',odOutlet.Id,installation.Id,true);
        //Update Outlet
        odOutlet.FS_SAP_ID__c = '4321';
        update odOutlet;
        System.assertNotEquals(odOutlet, null);
        Test.stopTest();
        }
    }
    //--------------------------------------------------------------------------------------
    //Update Empty fields with previous values
    //--------------------------------------------------------------------------------------
    static testMethod void testEmptyFieldsWithOldValues(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        System.runAs(sysAdminUser){
        Test.startTest();
        createTestData();
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.id,false);
        accOutlet.FS_CS_Sub_Trade_Channel__c='014 - QSR-Pizza';
        accOutlet.FS_CS_Bill_To_Address__c='Test Address';
        accOutlet.FS_CS_Bill_To_City__c='Test City';
        accOutlet.FS_CS_State__c='Test State';
        accOutlet.FS_CS_Bill_To_Zip__c='12345';
        accOutlet.FS_CS_All_Ftn_Removed__c='Yes';
        accOutlet.Invoice_Customer__c='No';
        accOutlet.FS_Payment_Type__c='Yes';
        accOutlet.FS_Payment_Method__c='Bank Draft';
        accOutlet.Invoice_Customer__c='Yes';
        accOutlet.Cokesmart_Payment_Method__c='Bank Draft';
        insert accOutlet;
        
        accOutlet.FS_CS_Sub_Trade_Channel__c=FSConstants.STR_NULL;
        accOutlet.FS_CS_Bill_To_Address__c=FSConstants.STR_NULL;
        accOutlet.FS_CS_Bill_To_City__c=FSConstants.STR_NULL;
        accOutlet.FS_CS_State__c=FSConstants.STR_NULL;
        accOutlet.FS_CS_Bill_To_Zip__c=FSConstants.STR_NULL;
        accOutlet.FS_CS_All_Ftn_Removed__c=FSConstants.STR_NULL;
        accOutlet.Invoice_Customer__c=FSConstants.STR_NULL;
        accOutlet.FS_Payment_Type__c='No';
        accOutlet.FS_Payment_Method__c='Payment Term';
        accOutlet.Invoice_Customer__c='No';
        accOutlet.Cokesmart_Payment_Method__c='Payment Term';
        update accOutlet;
        
        System.assertNotEquals(accOutlet, null);
        Test.stopTest();
        }
        
    }
    //--------------------------------------------------------------------------------------
    // Test Data For Account Update -- Share Record 
    //--------------------------------------------------------------------------------------
    static testmethod void testATMAndShareRecordFunctionality(){
        createTestData();
        final User u = FSTestUtil.createUser(null,0,FSConstants.systemAdmin, true);
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        System.runAs(sysAdminUser){
        Test.startTest();
        accOutlet.ShippingPostalCode = '55555';
        update accOutlet;
        accchainNew = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        accchainNew.OwnerId=u.id;
        insert accchainNew;
        accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,true);
        executionPlan=FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id,true);
        installation=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id,false);        
        installation.Overall_Status2__c= FSConstants.x4InstallSchedule;
        insert installation;
        accOutlet.OwnerId=u.id;
        accOutlet.ShippingPostalCode = '99999';
        update accOutlet;
        System.assertNotEquals(accOutlet, null);
        Test.stopTest();
        }
    }
  
}