@isTest
Private class FS_ShippingForm_Manufacturer_Test {
    
    public static Account hQAcc,outletAcc,chainAcc,chainInt,hqInt,bottler;
    public static FS_Outlet_Dispenser__c outletDispenser;   
    private static final string SERIES_7K='7000';
    private static Contact cont;    
    private static FS_Execution_Plan__c executionPlan;
    
    public static FS_Installation__c installation;
    public static Profile fetSysAdmin;
    static Shipping_Form__c shippingForm1,shippingForm2,shippingForm3;
    static User user1;
    static User user2;
    
    private static void createTestData(){   
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final List<Account> listAcc = new LIst<Account>();
        //Chain Account
        chainAcc = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAcc.FS_ACN__c = '76876876';
        listAcc.add(chainAcc);
        
        //HQ Account
        hQAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        hQAcc.FS_ACN__c = '7658765876';
        listAcc.add(hQAcc);
        
        //Creates Outlet Accounts 
        outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,hQAcc.Id, false);
        outletAcc.FS_ACN__c='9874562100';
        listAcc.add(outletAcc);
        //Bottler for international
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,false);
        listAcc.add(bottler);
        insert listAcc;
        
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,hQAcc.Id, true);
        
        //creates installation
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.Id,false);
        installation.Overall_Status2__c=FSConstants.x4InstallSchedule;
        installation.FS_Valid_Fill_Approved__c=false;     
        insert installation;
        FSTestFactory.createTestDisableTriggerSetting();
        
        //Platform typpes custom settings
        FSTestFactory.lstPlatform();
        //creates OD  
        outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);        
    } 
    
    private static testmethod void testNotifyCoordinator(){
        createTestData();
        Test.startTest();
        outletDispenser.FS_Equip_Type__c = SERIES_7K;
        outletDispenser.FS_Outlet__c=outletAcc.id;        
        
        insert outletDispenser;        
        
        cont=FSTestUtil.createTestContact(outletAcc.id, 'TestContact', false);
        cont.Email='test@contact.com';
        insert cont;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FS_ShippingForm_ManufacturerController.Notify_Coordinator(outletDispenser.id, False);
            String msg = FS_ShippingForm_ManufacturerController.Notify_Coordinator(outletDispenser.id, True);
            system.assertEquals('Error', msg);
        }
        
        Test.stopTest();
    }
   
    static testmethod void testSendforPreBook(){
        user1 =FSTestUtil.createUser(null,1,FSConstants.dispenserManufacturerProfile,true);
        system.runAs(user1){
            shippingForm1 = FSTestUtil.createShippingForm(true);
            shippingForm2 = FSTestUtil.createShippingForm(false);
            shippingForm2.Name = 'Test Shipping Form2';
            shippingForm2.FS_PO_Number__c = '123';
            insert shippingForm2;
            FS_ShippingForm_ManufacturerController.SendforPreBook(shippingForm1.id);
            String msg = FS_ShippingForm_ManufacturerController.SendforPreBook(shippingForm2.id);
            system.assertEquals('Success', msg);
        }
    }  
    
}