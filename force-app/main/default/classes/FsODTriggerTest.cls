/**************************************************************************************
Apex Class Name     : FsODTriggerTest
Version             : 1.0
Function            : This test class is for OD Trigger related Classes code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FsODTriggerTest {
    //Variables
	private static final string SERIES_7K='7000';
    private static final string SERIES_8K='8000';
    private static final string SERIES_9K='9000';
    public static User tuser,apiUser, coordinatorUser;
    public static FS_Integration_NMS_User__c integrationUser;
    public static Account chainAcc,hQAcc,outletAcc,bottler,intoutletAcc,hqInt,chainInt;
    public static FS_IP_Technician_Instructions__c  ipTechInstruction;
    public static Shipping_Form__c shippingForm;
    public static Dispenser_Model__c dispenserModel;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation,replaceInstall,relocInstall;
    public static FS_Outlet_Dispenser__c outletDispenser,intOutletDispenser;
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5;
    private static final string POWER_RAS='Powerade;raspberry';
    private static final string PIBB='Pibb';    
    private static final string MODEL_2K='2000';
    private static final string LT01='LTO1';
    private static final string SHOW='Show';
    private static final string YES='Yes';
    private static final string PIBB1='Pibb;';
    private static final string BRAND_SELECTION='2 Static/1 Agitated';
    private static final string HIDE='Hide';
    private static final string NO_VAL='No';
    private static final string BRAND_SELECTION1='0 Static/2 Agitated';   
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    //Create Test Data
    private static void createTestData(){    
        
        tuser = FSTestUtil.createUser(null,0,FSConstants.USER_POFILE_FETADMIN,true);
        apiUser=FSTestUtil.createUser(null,null,'API User',false);
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
        final List<Account> listAcc = new LIst<Account>();
        //Chain Account
        chainAcc = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAcc.FS_ACN__c = '76876876';
        listAcc.add(chainAcc);
        chainInt=FSTestUtil.createTestAccount('Test Chain 2',FSConstants.RECORD_TYPE_CHAIN,false);
        chainInt.FS_ACN__c = '7687687ICH';
        listAcc.add(chainInt);
        //HQ Account
        hQAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        hQAcc.FS_ACN__c = '7658765876';
        hQAcc.FS_Payment_Method__c = 'Credit Card';
        hQAcc.Cokesmart_Payment_Method__c='Credit Card';
        hQAcc.FS_Payment_Type__c='No';
        hQAcc.Invoice_Customer__c= 'No';
        listAcc.add(hQAcc);
        hqInt= FSTestUtil.createTestAccount('Test Headquarters Int',FSConstants.RECORD_TYPE_HQ,false);
        hqInt.FS_ACN__c = '7658765800';
        listAcc.add(hqInt);
        //Creates Outlet Accounts 
        outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,hQAcc.Id, false);
        outletAcc.FS_ACN__c='9874562100';
       	listAcc.add(outletAcc);
        //Bottler for international
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,false);
        listAcc.add(bottler);
       
        insert listAcc;
        
        intoutletAcc= new Account(Name='TEst Int Outlet',RecordTypeId= FSConstants.RECORD_TYPE_OUTLET_INT,ShippingCountry='UK',
                                 FS_Chain__c=chainInt.Id,fs_acn__C='1234567890',FS_Is_Address_Validated__c='yes');
        insert intoutletAcc;
        system.runAs(coordinatorUser){
            shippingForm = FSTestUtil.createShippingForm(true);
        }
        //Create Dispenser Model
        dispenserModel = FSTestUtil.createDispenserModel(true, SERIES_7K);
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN ,hQAcc.Id, true);
        
        //create trigger switch --custom setting
        FSTestFactory.createTestDisableTriggerSetting();
        
        //creates installation
        final List<Fs_Installation__C> listInstallation = new List<Fs_Installation__C>();
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.Id,false);
        installation.Overall_Status2__c=FSConstants.x4InstallSchedule;        
        installation.Type_of_Dispenser_Platform__c='7000;8000';
        listInstallation.add(installation) ;
        replaceInstall=FSTestUtil.createInstallationAcc(Label.IP_Replacement_Rec_Type,executionPlan.Id,outletAcc.Id,false);
        replaceInstall.Overall_Status2__c = 'Scheduled';
        replaceInstall.Type_of_Dispenser_Platform__c='9000';
      //replaceInstall.FS_Reason_Code__c='Unit Damaged at Arrival';
        replaceInstall.FS_Reason_Code__c='Damaged at Arrival';
        replaceInstall.FS_Same_incoming_platform__c = FSConstants.YES;
        listInstallation.add(replaceInstall) ;
        relocInstall=FSTestUtil.createInstallationAcc(Label.IP_Relocation_I4W_Rec_Type,executionPlan.Id,outletAcc.Id,false);
        relocInstall.Overall_Status2__c = 'On Hold';
        relocInstall.Type_of_Dispenser_Platform__c='7000;8000';
        relocInstall.FS_Reason_Code__c='Customer Request';
        listInstallation.add(relocInstall) ;
        insert listInstallation;
        //Create IPTECH INstruction
        ipTechInstruction=FSTestUtil.createTechnicianInstructions(FSConstants.TECHINSTRECTYPE,false);
        
		FSTestFactory.lstPlatform();
		
        //creates OD
        outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);
    }
    //Select domestic outlet and Insert OD - Update Equipment type based on Record type
    //Check Brands update from Installation    
    private static testMethod void insert7000OD(){        
        createTestData();        
        test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){        
            outletDispenser.FS_Equip_Type__c = SERIES_7K; 
            insert outletDispenser;
            System.assertEquals(outletDispenser.FS_Equip_Type__c,SERIES_7K);
        }
    	test.stopTest();
    }
    
    //Update OD brands active date as today,OD UPdate call to AW 
 	private static testMethod void updatetODDomestic(){
        createTestData();
         test.startTest();
        outletDispenser.FS_Equip_Type__c = SERIES_7K;
        //outletDispenser.FS_Dasani__c=SHOW;
        outletDispenser.Installation__c=installation.id;
        insert outletDispenser;
        System.assertEquals(outletDispenser.FS_Equip_Type__c,SERIES_7K);
        
        outletDispenser.FS_Dasani_New__c = HIDE;
        outletDispenser.FS_Dasani_Settings_Effective_Date__c=Date.today();
       // outletDispenser.FS_FAV_MIX__c=YES;
       // outletDispenser.FS_FAV_MIX_New__c=NO_VAL;
       // outletDispenser.FS_FAV_MIX_Effective_Date__c=Date.today();
        outletDispenser.FS_Spicy_Cherry__c=YES;
        outletDispenser.FS_Spicy_Cherry_New__c = NO_VAL;
        outletDispenser.FS_Spicy_Cherry_Effective_Date__c=Date.today();
        outletDispenser.FS_Promo_Enabled__c=YES;
        outletDispenser.FS_Promo_Enabled_Effective_Date__c =Date.today();
        outletDispenser.FS_Promo_Enabled_New__c = NO_VAL;
        outletDispenser.FS_Valid_Fill__c=YES;
        outletDispenser.FS_Valid_Fill_Settings_Effective_Date__c=Date.today();
        outletDispenser.FS_Valid_Fill_New__c = NO_VAL; 
        outletDispenser.FS_7000_Series_Agitated_Brands_Selection__c =PIBB1;
        outletDispenser.FS_7000_Series_Static_Brands_Selections__c =POWER_RAS;
        outletDispenser.FS_7000_Series_Brands_Option_Selections__c=BRAND_SELECTION;
        outletDispenser.FS_7000_Series_Brands_Selection_New__c = BRAND_SELECTION1;
        outletDispenser.FS_Brand_Selection_Value_Effective_Date__c =Date.today();
        outletDispenser.FS_7000_Series_Hide_Water_Effective_Date__c=Date.today();
        outletDispenser.Brand_Set_Effective_Date__c=Date.today();
        outletDispenser.FS_LTO_New__c='No LTO';
        outletDispenser.FS_LTO_Effective_Date__c=Date.today();
        outletDispenser.FS_7000_Series_Hide_Water_Button_New__c='Hide';
        outletDispenser.FS_Water_Button_New__c='Show';
        outletDispenser.FS_Water_Hide_Show_Effective_Date__c=Date.today();
        outletDispenser.FS_CE_Enabled_New__c=YES;
        outletDispenser.FS_CE_Enabled_Effective_Date__c=Date.today();
        outletDispenser.FS_Serial_Number2__c='zpl0987652';
        outletDispenser.FS_Brandset_Effective_Date__c=Date.today();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock()); 
            update outletDispenser;
            system.assertEquals('Hide', outletDispenser.FS_Dasani_New__c);
        }
		test.stopTest();
    }
    //When ever send create request is becaming true AW call should happned
    private static testMEthod Void insertODInt(){
        createTestData();
        test.startTest();        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final FS_Outlet_Dispenser__c outletDispenser=new FS_Outlet_Dispenser__c();
		outletDispenser.FS_Outlet__c=intoutletACC.id; 
		outletDispenser.recordtypeId=FSConstants.RECORD_TYPE_ODINT;
		outletDispenser.Shipping_Form__c=shippingForm.id;
		outletDispenser.FSInt_Dispenser_Type__c=dispenserModel.id;
		outletDispenser.FS_Serial_Number2__c='122334';
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            insert outletDispenser;
            //Check OD record type from FSTESTUTILL class
            system.assertEquals(FSConstants.RECORD_TYPE_ODINT, outletDispenser.recordtypeId);
        }
        test.stopTest();
    }
	
    private static testMethod void sendUpdateCalltoAW(){
        createTestData();
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        outletDispenser.FS_Equip_Type__c = SERIES_7K;
        test.startTest();
        insert outletDispenser;
        System.assertNotEquals(Null, outletDispenser.Id);

        outletDispenser.FS_Outlet__c=outletAcc.Id;
        outletDispenser.FS_LTO__c=LT01;
        outletDispenser.FS_7000_Series_Hide_Water_Button__c=SHOW;
        outletDispenser.FS_Water_Button__c=SHOW;
        outletDispenser.FS_CE_Enabled__c=YES;
        //outletDispenser.FS_Dasani__c=SHOW;
       // outletDispenser.FS_FAV_MIX__c=YES;
        outletDispenser.FS_Spicy_Cherry__c=YES;
        outletDispenser.FS_Promo_Enabled__c=YES;
        outletDispenser.FS_Valid_Fill__c=YES;
        outletDispenser.FS_7000_Series_Brands_Selection_New__c = BRAND_SELECTION;
        outletDispenser.FS_7000_Series_Static_Selection_New__c   = POWER_RAS;
        outletDispenser.FS_7000_Series_Agitated_Selections_New__c  = PIBB;
        outletDispenser.FS_Brand_Selection_Value_Effective_Date__c=Date.today();
        outletDispenser.FS_Planned_Install_Date__c = Date.today()+30;
        outletDispenser.Planned_Remove_Date__c = Date.today();
        outletDispenser.Ownership_Type__c = 'Bottler';
        outletDispenser.FS_Code__c = '46100 : Freestyle GS1 Red';
        outletDispenser.FS_Equip_type__c = MODEL_2K;
        //outletDispenser.FS_Color__c = 'Red';
        outletDispenser.FS_Dispenser_Location__c = 'abs';
        outletDispenser.FS_Dispenser_Type2__c = 'Self Serve';
        //outletDispenser.FS_Model__c = MODEL_2K;
        outletDispenser.Country__c = 'Canada';
        outletDispenser.Item_code__c = 'Test Code';
        outletDispenser.Brand_Set_Effective_Date__c = Date.today();
        outletDispenser.FS_Serial_Number2__c = 'test321';
        outletDispenser.Send_Create_Request__c=true;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            update outletDispenser;
        }
       
        test.stopTest();
    }
    
    private static testMethod void deleteCallDomestic(){
        createTestData();
     	outletDispenser.FS_Equip_Type__c= SERIES_7K;
        outletDispenser.FS_IsActive__c=true;
        outletDispenser.FS_Serial_Number2__c='zpl548756';
        outletDispenser.FS_Equip_Type__c=SERIES_7K;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            insert outletDispenser; 
            outletDispenser.FS_IsActive__c=false;
            
            update outletDispenser;
        }
        //Add System.assert
        test.stopTest();
    }
    //This method will cover shipping form update scenario for International OD
    private static testMethod void updateShippingFormStatus(){
        createTestData();
        test.startTest();
       
        final Warehouse_Details__c whDetail=new Warehouse_Details__c();
        whDetail.Brand_Set__c='Test Value';
        whDetail.Name='Test UK';
        insert whDetail;
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final FS_Outlet_Dispenser__c outletDispenser=new FS_Outlet_Dispenser__c();
		outletDispenser.FS_Outlet__c=intoutletACC.id;
        outletDispenser.FS_Serial_Number2__c='Zpl3333333';
		outletDispenser.recordtypeId=FSConstants.RECORD_TYPE_ODINT;
		outletDispenser.Shipping_Form__c=shippingForm.id;
		outletDispenser.FSInt_Dispenser_Type__c=dispenserModel.id;
        outletDispenser.Warehouse_Details__c=whDetail.id;
        outletDispenser.FS_Loc_Finder_Longitude__c=50.55;
        outletDispenser.FS_Loc_Finder_Latitude__c=53.55;
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            insert outletDispenser;
            outletDispenser.FS_Status__c= 'Dispenser Delivered';
            outletDispenser.FS_Loc_Finder_Longitude__c=72.25;
        	outletDispenser.FS_Loc_Finder_Latitude__c=72.55;
            update outletDispenser;
        }
        
        test.stopTest();        
    }
    //Update Int OD - Update call to AW
    private static testMEthod Void updateODInt(){
        createTestData();
        final FS_Outlet_Dispenser__c outletDispenser=new FS_Outlet_Dispenser__c();
        test.startTest();        
        
        final Warehouse_Details__c whDetail=new Warehouse_Details__c();
        whDetail.Brand_Set__c='Test Value';
        whDetail.Name='Test UK';
        insert whDetail;
        
		Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        outletDispenser.FS_Outlet__c=intoutletACC.id; 
		outletDispenser.recordtypeId=FSConstants.RECORD_TYPE_ODINT;
		outletDispenser.Shipping_Form__c=shippingForm.id;
		outletDispenser.FS_Status__c='Dispenser Delivered';
        outletDispenser.FSInt_Dispenser_Type__c=dispenserModel.id;
        outletDispenser.FS_Serial_Number2__c='Zpl3333444';
        outletDispenser.Warehouse_Details__c=whDetail.id;
		insert outletDispenser;
        system.assertEquals(FSConstants.RECORD_TYPE_ODINT, outletDispenser.recordtypeId);
        outletDispenser.FS_Status__c='Removed from Outlet';
        outletDispenser.FS_IsActive__c=False;
        outletDispenser.FS_Planned_Install_Date__c=date.today();
        outletDispenser.Planned_Remove_Date__c=date.today();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            update outletDispenser;
        }
        
        test.stopTest();
    }
    //Equipment type 8000 - To cover 8000 series OD field update
    private static testMEthod Void insert8000SeriesOD(){
        createTestData();
        test.startTest();
        outletDispenser.FS_Equip_Type__c = SERIES_8K;
        outletDispenser.recordtypeId=FsUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FSConstants.RT_NAME_CCNA_OD);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            insert outletDispenser;
            System.assertEquals(outletDispenser.FS_Equip_Type__c,SERIES_8K);
        }
    	test.stopTest();
    }
   //Equipment type 9000 - To cover 9000 series OD field update
    private static testMEthod Void insert9000SeriesOD(){
        createTestData();
        test.startTest();
        outletDispenser.FS_Equip_Type__c = SERIES_9K;
        outletDispenser.recordtypeId=FsUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FSConstants.RT_NAME_CCNA_OD);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            insert outletDispenser;
            System.assertEquals(outletDispenser.FS_Equip_Type__c,SERIES_9K);
        }
    	test.stopTest();    
    }
}