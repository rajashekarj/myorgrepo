@isTest
public class FSInstallRescheduleAuraControllerTest {
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    private static Account headquartersAcc,outletAcc,outletAccHavingNoDispensers;
    private static FS_Execution_Plan__c executionPlan;
    private static FS_Installation__c installation;
    private static String recTypeNewInstall=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(FSConstants.NEWINSTALLATION).getRecordTypeId() ;
    private static String recTypeRemoval=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Removal_Rec_Type).getRecordTypeId() ;
    
    private static void createTestData(){
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,null,true);
        outletAccHavingNoDispensers= FSTestUtil.createAccountOutlet('Test Outlet 2',FSConstants.RECORD_TYPE_OUTLET,null,true);
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, true);
        List<Platform_Type_ctrl__c> pTypes = new List<Platform_Type_ctrl__c>();
        Platform_Type_ctrl__c platType1= new Platform_Type_ctrl__c(Name='all_Platform',Platforms__c='6000,6050,7000,8000,9000,9100',Method__c='OD trigger handler',AutorabitExtId__c= 'a141g0000008fLhAAI');
        pTypes.add(platType1);
        Platform_Type_ctrl__c platType2= new Platform_Type_ctrl__c(Name='updateBrands',Platforms__c='7000',Method__c='OD trigger handler',AutorabitExtId__c= 'a141g0000008fLfAAI');
        pTypes.add(platType2);
        Platform_Type_ctrl__c platType3= new Platform_Type_ctrl__c(Name='updatecrewServeDasani',Platforms__c='8000',Method__c='OD trigger handler',AutorabitExtId__c= 'a141g0000008fLeAAI');
        pTypes.add(platType3);
        Platform_Type_ctrl__c platType4= new Platform_Type_ctrl__c(Name='updateSelfServeDasani',Platforms__c='9000',Method__c='OD trigger handler',AutorabitExtId__c= 'a141g0000008fLeAAI');
        pTypes.add(platType4);
        Platform_Type_ctrl__c platType5= new Platform_Type_ctrl__c(Name='WaterHideCheck',Platforms__c='7000',Method__c='airWatchSynchronousCall',AutorabitExtId__c= 'a141g0000008fLjAAI',Class_Name__c = 'FS FET NMS CONNECTOR');
        pTypes.add(platType5);
        Platform_Type_ctrl__c platType6= new Platform_Type_ctrl__c(Name='EquipmentTypeCheckForNMSUpdateCall',Platforms__c='6000,6050,7000,8000,9000,9100',Method__c='airWatchSynchronousCall',AutorabitExtId__c= 'a141g0000008fLiAAI',Class_Name__c = 'FS FET NMS CONNECTOR');
        pTypes.add(platType6);
        insert pTypes;
        
    }
    
    @isTest
    private static void disableAccessCheckTest(){ 
        //Insert User
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
		test.startTest();
        system.runAs(fetSysAdminUser){
            boolean checkDisableAccess=FSInstallRescheduleAuraController.disableAccessCheck();
            system.assertEquals(false, checkDisableAccess);
        }
		test.stopTest();        
    }
    
    
    @isTest
    private static void installScheduleCheckTest(){      
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        Disable_Trigger__c installCustomSetRec = new Disable_Trigger__c(Name='FSInstallationBusinessProcess',ISACTIVE__C=false);
        insert installCustomSetRec;
		createTestData();
        List<FS_Installation__c> installList = new List<FS_Installation__c>();
        installList.add(new FS_Installation__c(recordtypeid=recTypeNewInstall,Type_of_Dispenser_Platform__c='7000',FS_Execution_plan__c=executionPlan.id,FS_outlet__c=outletAcc.Id,FS_Original_Install_Date__c=system.today()));
        installList.add(new FS_Installation__c(recordtypeid=recTypeRemoval,Type_of_Dispenser_Platform__c='8000;9000',FS_Execution_plan__c=executionPlan.id,FS_outlet__c=outletAcc.Id));
        insert installList;
        test.startTest();
        FS_Installation__c ipRec = new FS_Installation__c(recordtypeid=recTypeNewInstall,Type_of_Dispenser_Platform__c='7000',FS_Execution_plan__c=executionPlan.id,FS_outlet__c=outletAcc.Id,FS_Original_Install_Date__c=system.today()); 
        
        system.runAs(fetSysAdminUser){
            FSInstallRescheduleAuraController.installScheduleDateCheck(ipRec.Id);
            system.assert([select id from Apex_Error_Log__c limit 10].size()>0);
            FSInstallRescheduleAuraController ipScheduleValidCheck=FSInstallRescheduleAuraController.installScheduleDateCheck(installList[0].Id);
            system.assertEquals(false, ipScheduleValidCheck.ipScheduleCheck);
            FSInstallRescheduleAuraController ipScheduleInValidCheck=FSInstallRescheduleAuraController.installScheduleDateCheck(installList[1].Id);
            system.assertEquals(true, ipScheduleInValidCheck.ipScheduleCheck);     
        }
		test.stopTest();        
    }
   /* Checking for No dispenser selected error, empty dispenser section, platform mismatch error 
        and Checking if the Platform Types that are selected under IP contains the OD selected of that Platform Type.
   as part of FNF-747*/
    @isTest
    private static void installReScheduleCheck(){   
        List<FS_Installation__c> ins = new List<FS_Installation__c>();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        Disable_Trigger__c installCustomSetRec = new Disable_Trigger__c(Name='FSInstallationBusinessProcess',ISACTIVE__C=false);
        insert installCustomSetRec;
		createTestData();

        test.startTest();
        FS_Installation__c ipRec = new FS_Installation__c(recordtypeid=recTypeRemoval,Type_of_Dispenser_Platform__c='8000',FS_Execution_plan__c=executionPlan.id,FS_outlet__c=outletAcc.Id,Overall_Status2__c='Scheduled'); 
        ins.add(ipRec);
        FS_Installation__c noDispenserInstallation = new FS_Installation__c(recordtypeid=recTypeRemoval,Type_of_Dispenser_Platform__c='8000',FS_Execution_plan__c=executionPlan.id,FS_outlet__c=outletAccHavingNoDispensers.Id,Overall_Status2__c='Scheduled'); 
         ins.add(noDispenserInstallation);
        FS_Installation__c platformMismatchIns = new FS_Installation__c(recordtypeid=recTypeRemoval,Type_of_Dispenser_Platform__c='8000',FS_Execution_plan__c=executionPlan.id,FS_outlet__c=outletAccHavingNoDispensers.Id,Overall_Status2__c='Scheduled'); 
        ins.add(platformMismatchIns);
        FS_Installation__c platformMismatchIns1 = new FS_Installation__c(recordtypeid=recTypeRemoval,Type_of_Dispenser_Platform__c='8000;9000',FS_Execution_plan__c=executionPlan.id,FS_outlet__c=outletAccHavingNoDispensers.Id,Overall_Status2__c='Scheduled'); 
        ins.add(platformMismatchIns1);
        if(ins.size()>0){
            insert ins;
        }
        FS_Outlet_Dispenser__c outDisp = FSTestUtil.createOutletDispenserAllTypes('BoE Dispenser','7000',outletAcc.id,null,true);
        outDisp.FS_Other_PIA_Installation__c = ins[2].id;
        update outDisp;
        FS_Outlet_Dispenser__c outDisp1 = FSTestUtil.createOutletDispenserAllTypes('BoE Dispenser','8000',outletAcc.id,null,true);
        outDisp1.FS_Other_PIA_Installation__c = ins[3].id;
        update outDisp1;
        
        system.runAs(fetSysAdminUser){
            FSInstallRescheduleAuraController noDispSelected=FSInstallRescheduleAuraController.installScheduleDateCheck(ins[0].id);
            system.assertEquals(true, noDispSelected.outletDispensersNotSelectedError);  
             FSInstallRescheduleAuraController emptyDispSection=FSInstallRescheduleAuraController.installScheduleDateCheck(ins[1].id);
            system.assertEquals(true, emptyDispSection.dispenserSectionEmptyError); 
            FSInstallRescheduleAuraController platFormMisMatch=FSInstallRescheduleAuraController.installScheduleDateCheck(ins[2].id);
            system.assertEquals(true, platFormMisMatch.plattformMismatchError); 
             FSInstallRescheduleAuraController platFormMisMatch1=FSInstallRescheduleAuraController.installScheduleDateCheck(ins[3].id);
            system.assertEquals(true, platFormMisMatch1.plattformMismatchError); 
        }
		test.stopTest();        
    }

}