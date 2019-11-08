/*****************************
Name         : FSInstallationTestclass
Created By   : Infosys
Created Date : 19/12/2016
Usage        : Test class for Installation object Trigger handler.
*****************************/

@isTest
private class FSInstallationTestclass{
    private static Account headquartersAcc,outletAcc,outletAccReloc,serviceProvider,serviceProvider1;
    private static FS_Execution_Plan__c executionPlan;
    private static FS_Installation__c installation;
    private static Contact spContact;
    private static List<FS_Brandset__c> branset7000List,branset8000List,branset9000List;
    private static final string fsserviceproviderString = 'FS Service Provider';
    private static final string serviceproviderString = 'Service Provider';
    private static String recTypeNewInstall=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(FSConstants.NEWINSTALLATION).getRecordTypeId() ;
    private static String recTypeRemoval=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Removal_Rec_Type).getRecordTypeId() ;
    private static String recTypeRelocation=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Relocation_I4W_Rec_Type).getRecordTypeId() ;
    private static String recTypeReplace=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Replacement_Rec_Type).getRecordTypeId();
    private static String recServcProvider=Schema.SObjectType.Account.getRecordTypeInfosByName().get(fsserviceproviderString).getRecordTypeId();
    private static String recServcProvdCnt=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(serviceproviderString).getRecordTypeId();
    private static String ipRecTypeRelocationO4W=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Relocation_O4W_Rec_Type).getRecordTypeId();
    private static Id fsaccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId();
    private static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Linkage Management').getRecordTypeId();    
    
    private static Profile fetSysAdmin;
    private static Profile systemAdmin;
    private static final String SCHEDULE_CONFIRM = 'Schedule Confirmed';
    private static final String FOOTPRINT = 'EcoSure';
    private static final String COM = 'COM';
    private static final String REMODEL ='Remodel';
    private static final String TESTCONTACT ='Test Contact';
    private static final String SPNAME ='Service Provider';
    private static final String PHONENO='1023456789';
    private static final String PRIMARY='Primary';
    private static final String EMAILADDR='email@email.com';
    public static final String POSTINSTACT ='Post Install Activity Complete';
    private static final String APPROVED='Approved';
    private static final String NOSITEASSESMNT ='SA Not Required - OSM approval required for local market';
    
    private static FS_Installation__c createTestData(){
        List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSODBusinessProcess','FSAccountBusinessProcess'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
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
        List<Account> insertAccounts = new List<Account>();
        //HQ Record
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        //Outlet Records
        outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
        outletAcc.ShippingPostalCode='1234';
        outletAccReloc=FSTestUtil.createAccountOutlet('Test Outlet 2',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
        outletAccReloc.ShippingPostalCode='123456';
        //Inserting Account Records
        serviceProvider=new Account(Name=SPNAME,RecordtypeId=recServcProvider);        
        serviceProvider1=new Account(Name=SPNAME,RecordtypeId=recServcProvider); 
        //Insert to Accoutn & From Account.
        Account fsaccount1 = new Account();
        fsaccount1.RecordTypeId=fsaccountRecordTypeId;
        fsaccount1.ShippingCountry='US';
        fsaccount1.name='FS Outlet To Account';
        Account fsaccount2 = new Account();
        fsaccount2.RecordTypeId=fsaccountRecordTypeId;
        fsaccount2.name='FS Outlet From Account';
        fsaccount2.ShippingCountry='US';
        insertAccounts.add(fsaccount1);
        insertAccounts.add(fsaccount2);
        insertAccounts.add(headquartersAcc);
        insertAccounts.add(outletAcc);
        insertAccounts.add(outletAccReloc);
        insertAccounts.add(serviceProvider);
        insertAccounts.add(serviceProvider1);
        insert insertAccounts;
        
        Case caseInstance = new Case();
        caseInstance.Status = 'New';
        caseInstance.recordtypeId = caseRecordTypeId;
        caseInstance.Issue_Name__c ='Sample_Test';
        caseInstance.type ='JDE Linkage Request';
        caseInstance.To_Account__c = fsaccount1.Id;
        caseInstance.From_Account__c = fsaccount2.Id;
        insert caseInstance;
        
        final CIF_Header__c cifHead=new CIF_Header__c(FS_HQ__c=headquartersAcc.Id);
        insert cifHead;
        insert new Disable_Trigger__c(name='FSCOMNotifications',IsActive__c=false);
        final FS_CIF__c cifRec=new FS_CIF__c(CIF_Head__c=cifHead.Id,FS_Account__c=outletAcc.Id,FS_Platform1__c='7000',FS_Platform2__c='8000',FS_Platform3__c='8000');
        insert cifRec;
        //FET 7.0 FNF-823
        insert new Disable_Trigger__c(name='FSContactTriggerHandler',IsActive__c=false);
        //FET 7.0 FNF-823
        List<Contact> conList=new List<Contact>();
        conList.add(new Contact(AccountId=serviceProvider.Id,LastName=TESTCONTACT,RecordtypeId=recServcProvdCnt,FS_SP_Contact_Active__c=true,FS_SP_Role__c=PRIMARY,Phone=PHONENO,Email=EMAILADDR));
        conList.add(new Contact(AccountId=serviceProvider1.Id,LastName=TESTCONTACT,RecordtypeId=recServcProvdCnt,FS_SP_Contact_Active__c=true,FS_SP_Role__c=PRIMARY,Phone=PHONENO,Email=EMAILADDR));
        insert conList;
        final List<FS_SP_Aligned_Zip__c> spAlignedList=new List<FS_SP_Aligned_Zip__c>();
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=outletAcc.ShippingPostalCode,FS_Service_Provider__c=serviceProvider.id,FS_Platform_Type__c='7000'));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=outletAcc.ShippingPostalCode,FS_Service_Provider__c=serviceProvider.id,FS_Platform_Type__c='8000' ));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=outletAcc.ShippingPostalCode,FS_Service_Provider__c=serviceProvider.id,FS_Platform_Type__c='9000'));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=outletAcc.ShippingPostalCode,FS_Service_Provider__c=serviceProvider.id,FS_Platform_Type__c='9100'));
        insert spAlignedList;
        //create Brandset records
        final List<FS_Brandset__c> brandsetRecordList=FSTestFactory.createTestBrandset();  
        //Separate Brandset based on platform 
        branset7000List=new List<FS_Brandset__c>();
        branset8000List=new List<FS_Brandset__c>();
        branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecordList){
            if(branset.FS_Platform__c.contains('7000')){      branset7000List.add(branset);          }
            if(branset.FS_Platform__c.contains('8000')){      branset8000List.add(branset);          }           
            if(branset.FS_Platform__c.contains('9000')){      branset9000List.add(branset);          }
        }
        
        //Creating Execution Plan Record
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);
        executionPlan.FS_Platform_Type__c='7000;8000;9000;9100';
        insert executionPlan;
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        systemAdmin=FSTestFactory.getProfileId(FSConstants.systemAdmin);
        FSTestFactory.createTestDisableTriggerSetting();
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id,false);      
        installation.FS_CIF__c= cifRec.Id;
        installation.FS_New_Outlet__c=outletAccReloc.id;
        installation.FS_Install_Doc__c='123';
        return installation;
    }
    //New Install record with Platform Type/s Changes
    private static testmethod void testNewInstallPlatformRec(){   
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        final Disable_Trigger__c disableABTrigger = new Disable_Trigger__c(Name='FSODBusinessProcess',IsActive__c=false,Trigger_Name__c='FSODBusinessProcess');
        insert disableABTrigger;
        //FET 7.0 FNF-823
        insert new Disable_Trigger__c(Name='FSExecutionPlanTriggerHandler',IsActive__c=false,Trigger_Name__c='FSExecutionPlanTrigger');
        //FET 7.0 FNF-823
        system.runAs(fetSysAdminUser){            
            installation.Type_of_Dispenser_Platform__c='7000;8000;9000';            
            installation.FS_Promo_Enabled__c='Yes';
            
            insert installation; //Creating New Install
            Test.startTest();
            insert new FS_Initial_Order__c(FS_Outlet__c=outletAcc.Id,FS_Installation__c=installation.Id);
            //insert new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,Installation__c=installation.Id,FS_Serial_Number2__c='ZPL0989898',FS_Equip_Type__c='7000');
            
            installation.Type_of_Dispenser_Platform__c='7000;8000;9100';
            installation.Platform_change_approved__c =true;
            installation.FS_Promo_Enabled__c='No';
            installation.FS_DispOrder1__c=1;
            installation.Overall_Status2__c = FSConstants.x3PendingSchedu;
            update installation; //Updating New Install with Modified Platform Values
            Test.stopTest();  
            system.assertEquals(3, [select id from FS_IP_Equipment_Package__c where FS_Installation__c=:installation.Id].size());
            //delete installation;  //Deleting New Install record          
            
        }
    }
    
    //New Replacment record with Platform Type/s Changes
    private static testmethod void testNewReplacementPlatformRec(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installation.Type_of_Dispenser_Platform__c='7000;8000;9000';
            installation.RecordTypeId=recTypeReplace;
            installation.FS_Install_Reconnect_Date__c=system.today()+30;            
            insert installation;  
            Test.startTest();
            FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
            installation.Type_of_Dispenser_Platform__c='7000;8000;9100';
            update installation; 
            system.assertEquals(3, [select id from FS_IP_Equipment_Package__c where FS_Installation__c=:installation.Id].size());			       
            Test.stopTest();            
        }        
    }
    
    //New Relocation record with Platform Type/s Changes
    private static testmethod void testNewRelocationPlatformRec(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installation.Type_of_Dispenser_Platform__c='8000;9000';
            installation.RecordTypeId=recTypeRelocation;
            installation.FS_Remove_Disconnect_Date__c=system.today()+30;
            installation.Overall_Status2__c = 'Scheduled';
            insert installation; 
            //FET 7.0 FNF-747 starts   
            FS_Outlet_Dispenser__c outDisp = FSTestUtil.createOutletDispenserAllTypes('BoE Dispenser','7000',outletAcc.id,null,true);
            outDisp.Relocated_Installation__c = installation.id;
            update outDisp;
        //FET 7.0 FNF-747   ends
            Test.startTest();
            FSInstallationCreateEPIPAndMails.relocationOnce=true;
            installation.Type_of_Dispenser_Platform__c='7000';
            installation.FS_New_Outlet__c=outletAcc.Id;
            installation.FS_Relocation_from_old_outlet_to_SP_is__c=true;
            installation.FS_Install_Reconnect_Date__c=system.today()+40;
            installation.FS_Disposition_of_Dispenser_Upon_Removal__c='Disconnected and placed in backroom';
            update installation;
            system.assertEquals(1, [select id from FS_Association_Brandset__c where FS_Installation__c!=null and FS_Installation__c=:installation.Id].size());			       
            
            Test.stopTest();            
        }        
    }
    
    //New Relocation record with Platform Type/s Changes
    private static testmethod void testNewRemovalPlatformRec(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installation.Type_of_Dispenser_Platform__c='8000;9000';
            installation.RecordTypeId=recTypeRemoval;
            insert installation; 
            Test.startTest();
            
            installation.Type_of_Dispenser_Platform__c='7000';			
            update installation;         
            Test.stopTest(); 
            system.assertEquals('7000', installation.Type_of_Dispenser_Platform__c);
        }        
    }
    
    //New Relocation record with Platform Type/s Changes
    private static testmethod void testNewRelocationSPOverrideRec(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installation.Type_of_Dispenser_Platform__c='8000;9000';
            installation.RecordTypeId=recTypeRelocation;
            installation.SP_Override__c=true;
            insert installation; 
            Test.startTest();
            FSInstallationCreateEPIPAndMails.relocationOnce=true;
            installation.Type_of_Dispenser_Platform__c='7000';
            installation.FS_New_Outlet__c=outletAcc.Id;
            update installation;
            system.assertEquals(1, [select id from FS_Association_Brandset__c where FS_Installation__c!=null and FS_Installation__c=:installation.Id].size());			       
            
            Test.stopTest();            
        }        
    }
    
    //New Relocation record with Platform Type/s Changes
    private static testmethod void testNewRemovalSPOverrideRec(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installation.Type_of_Dispenser_Platform__c='8000;9000';
            installation.RecordTypeId=recTypeRemoval;
            installation.SP_Override__c=true;
            installation.FS_Entering_COM__c=fetSysAdminUser.Id;
            installation.FS_PM_Execution__c=fetSysAdminUser.Id;
            //installation.FS_Reason_Code__c='Removal - Other';
            installation.FS_Reason_Code__c='Return to Legacy - Commercial Terms (Cost)';
            Installation.FS_Sub_Reason_Code__c='NA';
            installation.FS_Scope_of_Work__c='Test';
            insert installation; 
            Test.startTest();
            
            installation.Type_of_Dispenser_Platform__c='7000';			
            update installation;         
            Test.stopTest();  
            system.assertEquals(FSConstants.x1ReadySchedule,[select id,Overall_Status2__c from FS_Installation__C where id=:installation.Id].Overall_Status2__c);
        }        
    }
    
    //New Install record with Platform Type/s Changes
    private static testmethod void testNewInstallFootPrint(){   
        createTestData();
        
        final List<FS_Installation__c> installList=new List<FS_Installation__c>();
        final List<FS_Installation__c> installListUpdate=new List<FS_Installation__c>();
        
        installList.add(new FS_Installation__c(Type_of_Dispenser_Platform__c='7000;8000', FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_SA_Scheduled_On_Date__c =date.today(),FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,Overall_Status2__c=FSConstants.STATUS_COMPLETE,FS_SA_Completed_Date__c=date.today(),FS_Trainer__c=COM,FS_OB_Status__c=SCHEDULE_CONFIRM));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_SA_Scheduled_On_Date__c =date.today(),FS_Trainer__c=FOOTPRINT,FS_Pending_for_Reschedule__c=true));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_SA_Scheduled_On_Date__c =date.today(),FS_OB_Status__c='New Order'));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_SA_Scheduled_On_Date__c =date.today(),Overall_Status2__c=FSConstants.x4InstallSchedule,FS_OB_Status__c=SCHEDULE_CONFIRM));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,Overall_Status2__c=FSConstants.SAPending ));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_Survey_Install_On_Hold__c=true));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAccReloc.Id,RecordTypeId=recTypeNewInstall,FS_Survey_Install_On_Hold__c=true,FS_Original_Install_Date__c=Date.today()+40));
         Test.startTest();
        insert installList; 
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
       
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){
            
            installListUpdate.add(new FS_Installation__c(Id=installList[0].id,FS_Trainer__c=FOOTPRINT,Type_of_Dispenser_Platform__c='9000;9100',Platform_change_approved__c=true));
            installListUpdate.add(new FS_Installation__c(Id=installList[1].id,FS_Pending_for_Reschedule__c=true,FS_Trainer__c=COM));
            installListUpdate.add(new FS_Installation__c(Id=installList[2].id,FS_Scheduled_Install_Date__c =date.today().adddays(2),FS_Original_Install_Date__c=Date.today()+40,Overall_Status2__c=FSConstants.STATUS_COMPLETE,FS_Rush_Install_Reason__c=REMODEL,FS_OB_Status__c = 'Cancelled'));
            installListUpdate.add(new FS_Installation__c(Id=installList[3].id,FS_Scheduled_Install_Date__c =date.today().adddays(2),FS_OB_Status__c = 'New Order'));
            installListUpdate.add(new FS_Installation__c(Id=installList[4].id,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_SA_Scheduled_On_Date__c =date.today(),Overall_Status2__c=FSConstants.x4InstallSchedule,FS_OB_Status__c=SCHEDULE_CONFIRM,FS_Trainer__c=FOOTPRINT));
            installListUpdate.add(new FS_Installation__c(Id=installList[5].id,FS_Trainer__c=FOOTPRINT,FS_Survey_Install_Cancelled__c=true));
            
            Test.stopTest();
            update installListUpdate;
            
            system.assertEquals(FSConstants.x4InstallSchedule ,[select Overall_Status2__c from FS_Installation__c  where Id=:installList[4].id].Overall_Status2__c );
            
        }
    }
    
    private static testmethod void testNewInstallSPEmailNotification() {
        List<FS_Installation__c> installList;
        
        final FS_Installation__c  inst=createTestData();        
        
        inst.FS_SP__c=serviceProvider.id;
        inst.SP_Override__c=true;        
        inst.Overall_Status2__c = FSConstants.x4InstallSchedule;  
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installList=new List<FS_Installation__c>();
            installList.add(new FS_Installation__c(Type_of_Dispenser_Platform__c='7000;8000',FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_SP__c=serviceProvider.id,
                                                   SP_Override__c=true,FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall));
            installList.add(inst);
            insert installList;
            Test.startTest();
            FSInstallationCreateEPIPAndMails.spEmailrunonce=false;
            final FS_Installation__c inst1=installList[0];
            inst1.FS_Scheduled_Install_Date__c=system.today()+2;            
            inst1.Overall_Status2__c=FSConstants.x4InstallSchedule;
            update inst1;
            Test.stopTest();
            System.assertEquals(inst1.Overall_Status2__c,FSConstants.x4InstallSchedule);
        }
    }
    
    //New Replacment record with Platform Type/s Changes
    private static testmethod void testReplacementSPEmailNotification(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installation.Type_of_Dispenser_Platform__c='7000;8000;9000';
            installation.RecordTypeId=recTypeReplace;
            installation.FS_Install_Reconnect_Date__c=system.today();
            installation.FS_Rush_Install_Reason__c=REMODEL;
            installation.FS_SP__c=serviceProvider.Id;
            installation.SP_Override__c=true;
            
            insert installation;  
            Test.startTest();
            FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
            installation.Type_of_Dispenser_Platform__c='7000;8000;9100';
             //installation.FS_ReschedInstallDate1__c=system.today()+2;
            //installation.FS_Reason_for_Resched_1__c=REMODEL;
            installation.FS_Remove_Disconnect_Date__c=system.today()+3;
            update installation; 
            system.assertEquals(3, [select id from FS_IP_Equipment_Package__c where FS_Installation__c=:installation.Id].size());			       
            Test.stopTest();            
        }        
    }
    //fet4.0 replacement
    private static testmethod void replacementInstallation(){       
        createTestData(); 
       
        Account outletAcc = [select id from Account where Name = 'Test Outlet 1'];
        installation.RecordTypeId=recTypeReplace;                
        installation.Type_of_Dispenser_Platform__c='8000;9000';
        installation.FS_SP__c=serviceProvider.Id;
        installation.Overall_Status2__c='Scheduled';
        installation.SP_Override__c=true;
        insert installation;      
        //FET 7.0 FNF-747 starts   
        FS_Outlet_Dispenser__c outDisp = FSTestUtil.createOutletDispenserAllTypes('BoE Dispenser','8000',outletAcc.id,null,true);
        outDisp.Relocated_Installation__c = installation.id;
        update outDisp;
        //FET 7.0 FNF-747   ends
        final List<FS_Association_Brandset__c> associate=[select id,FS_Brandset__c,FS_Installation__c,FS_Platform__c from FS_Association_Brandset__c where id=:installation.Id];
        for(FS_Association_Brandset__c abRec:associate){
            if(abRec.FS_Platform__c=='8000' &&  !branset8000List.isEmpty() ){  abRec.FS_Brandset__c=branset8000List[0].Id;   }
            if(abRec.FS_Platform__c=='9000' &&  !branset9000List.isEmpty() ){  abRec.FS_Brandset__c=branset9000List[0].Id;   }
            abRec.FS_NonBranded_Water__c='Hide';
        }
        update associate;
        Test.startTest();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){
            FSInstallationValidateAndSet.brandsetDateCheck=true;        
            installation.Overall_Status2__c='Scheduled';
            installation.FS_Install_Reconnect_Date__c=system.today().addDays(-120); 
            installation.FS_Rush_Install_Reason__c=REMODEL;
            installation.FS_Confirm_Install_Date__c=true;
            installation.FS_SP__c=serviceProvider1.Id;
            update installation;
            system.assertNotEquals(null, installation.id);
            Test.stopTest(); 
        }
        system.assertEquals(serviceProvider1.Id, installation.FS_SP__c);
    }
    //EP overall status updates
    private  static testmethod void testupdateOverallStatusAllConditionsNew(){
        createTestData();
        final List<FS_Installation__c> installList=new List<FS_Installation__c>();
        final List<FS_Installation__c> installListUpdate=new List<FS_Installation__c>();
        
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_SA_Scheduled_On_Date__c =date.today(),FS_SA_Completed_Date__c=date.today(),FS_Survey_Complete__c =false));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_SA_Scheduled_On_Date__c =date.today(),FS_SA_Completed_Date__c=date.today(),FS_Survey_Complete__c =false,FS_Davaco_Requirements__c=NOSITEASSESMNT,FS_Execution_Plan_Final_Approval_PM__c=APPROVED,FS_BrandStatus__c='Complete'));       
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_SA_Scheduled_On_Date__c =date.today(),FS_SA_Completed_Date__c=date.today(),FS_Survey_Complete__c =false,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_Execution_Plan_Final_Approval_PM__c=APPROVED,FS_Davaco_Requirements__c=NOSITEASSESMNT,FS_BrandStatus__c='Complete'));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_SA_Scheduled_On_Date__c =date.today(),FS_SA_Completed_Date__c=date.today(),FS_Survey_Complete__c =false,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_Execution_Plan_Final_Approval_PM__c=APPROVED,FS_Davaco_Requirements__c=NOSITEASSESMNT,FS_BrandStatus__c='Complete'));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_SA_Scheduled_On_Date__c =date.today(),FS_SA_Completed_Date__c=date.today(),FS_Survey_Complete__c =false,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_Install_Complete__c=true,FS_Execution_Plan_Final_Approval_PM__c=APPROVED,FS_BrandStatus__c='Complete'));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_SA_Scheduled_On_Date__c =date.today(),FS_SA_Completed_Date__c=date.today(),FS_Survey_Complete__c =false,FS_Davaco_Requirements__c=NOSITEASSESMNT,FS_Survey_Date__c=date.today(),FS_Execution_Plan_Final_Approval_PM__c=APPROVED,FS_BrandStatus__c='Complete'));
        installList.add(new FS_Installation__c(FS_Execution_Plan__c=executionPlan.id,FS_Outlet__c=outletAcc.Id,RecordTypeId=recTypeNewInstall,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c=REMODEL,FS_SA_Scheduled_On_Date__c =date.today(),FS_SA_Completed_Date__c=date.today(),FS_Survey_Complete__c =true,FS_Davaco_Requirements__c=NOSITEASSESMNT,FS_Survey_Date__c=date.today(),FS_Execution_Plan_Final_Approval_PM__c=APPROVED,FS_BrandStatus__c='Complete'));
        
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){
            insert installList; 
            Test.startTest();
            installListUpdate.add(new FS_Installation__c(Id=installList[1].id));
            installListUpdate.add(new FS_Installation__c(Id=installList[2].id,FS_Scheduled_Install_Date__c =date.today().adddays(2)));
            
            update installListUpdate;
            
            Test.stopTest();
            if(!installListUpdate.isEmpty()){
                delete installListUpdate[0];
            }
            system.assertEquals(installList.size()-1,[select id,FS_outlet__c from FS_Installation__c where FS_outlet__c=:outletAcc.Id].size());
        }
    }
    
    //New Replacment record with Platform Type/s Changes
    private static testmethod void testPIACancelled(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){   
            List<FS_Outlet_Dispenser__c> outDispToBeUpdated = new List<FS_Outlet_Dispenser__c>();
          	 
            installation.Type_of_Dispenser_Platform__c='7000;8000;9000';
            installation.RecordTypeId=recTypeReplace;
            installation.FS_Install_Reconnect_Date__c=system.today();
            installation.FS_Rush_Install_Reason__c=REMODEL;
            installation.FS_SP__c=serviceProvider.Id;
            installation.SP_Override__c=true;
            
            insert installation;  
            
           
          	Test.startTest();
            FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
            installation.Type_of_Dispenser_Platform__c='7000;8000;9100';
            //installation.FS_ReschedInstallDate1__c=system.today()+2;
            //installation.FS_Reason_for_Resched_1__c=REMODEL;
            installation.FS_Remove_Disconnect_Date__c=system.today()+3;
            installation.FS_Cancelled_oH__c=FSConstants.IPCANCELLED;
            
            update installation; 
            Test.stopTest();
           
            
            system.assertEquals(3, [select id from FS_IP_Equipment_Package__c where FS_Installation__c=:installation.Id].size());			       
         //   installation.FS_Cancelled_oH__c=FSConstants.onHolds;
         //   update installation; 
           
        
             
                    
        }        
    }
    
    
    //New Replacment record with Platform Type/s Changes
    private static testmethod void testPIAComplete(){   
        createTestData();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){            
            installation.Type_of_Dispenser_Platform__c='7000;8000;9000';
            installation.RecordTypeId=recTypeReplace;
            installation.FS_Install_Reconnect_Date__c=system.today();
            installation.FS_Rush_Install_Reason__c=REMODEL;
            installation.FS_SP__c=serviceProvider.Id;
            installation.SP_Override__c=true;
            installation.Overall_Status2__c='Scheduled';
            Test.startTest();
            insert installation;  
             
            FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
            installation.Type_of_Dispenser_Platform__c='7000;8000;9100';
            //installation.FS_ReschedInstallDate1__c=system.today()+2;
            //installation.FS_Reason_for_Resched_1__c=REMODEL;
            installation.FS_Remove_Disconnect_Date__c=system.today()+3;
            installation.FS_Scheduled_Install_Date__c= System.today()+5;
          
            update installation; 
            Test.stopTest();
            system.assertEquals(3, [select id from FS_IP_Equipment_Package__c where FS_Installation__c=:installation.Id].size());			       
            
            
          
            delete installation;            
        }        
    }
    
    //check if the  FS_Freestyle_Support_Tool_Case__c is valid case#
    private static testmethod void testRO4WComplete(){ 
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.assertnotEquals(null, fetSysAdminUser);
        Case caseInstancenew = [select id, CaseNumber from Case where Issue_Name__c='Sample_Test'];
        system.assertnotEquals(null, caseInstancenew);
        FS_CIF__c cif = [select id from FS_CIF__c limit 1];
        system.assertnotEquals(null, cif);
        system.runAs(fetSysAdminUser){
            test.starttest();
            Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
            disableTriggerSetting.IsActive__c = false;
            FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
            
            FS_Installation__c createinstallation = new FS_Installation__c();
            createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
            createinstallation.FS_CIF__c= cif.Id;
            createinstallation.FS_New_Outlet__c= outletAccReloc.id;
            createinstallation.FS_Install_Doc__c= '123';
            createinstallation.RecordTypeId = ipRecTypeRelocationO4W;
            createinstallation.FS_Did_BAST_initiate_this_RO4W__c = FSConstants.no;
            createinstallation.FS_Freestyle_Support_Tool_Case__c = caseInstancenew.CaseNumber;
            insert createinstallation;
            test.stoptest();
            system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
        }
    }
    //check if the  AMOA form is attached to RO4W.
    private static testmethod void testRO4W_AMOAattached(){ 
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        Account outletacn = [select id, FS_ACN__c from account where name='Test Outlet 1'];
        outletacn.FS_ACN__c = '1234567';
        update outletacn;
        Case caseInstancenew = [select id, CaseNumber from Case where Issue_Name__c='Sample_Test'];
        FS_CIF__c cif = [select id from FS_CIF__c limit 1];
        
        FS_Installation__c createinstallation = new FS_Installation__c();
        createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
        createinstallation.FS_CIF__c= cif.Id;
        createinstallation.FS_New_Outlet__c= outletAccReloc.id;
        createinstallation.FS_Install_Doc__c= '123';
        insert createinstallation;
        system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
        system.runAs(fetSysAdminUser){
            test.starttest();
            List<ContentVersion> ContentVersionlist = new List<ContentVersion>();
            ContentVersion contentVersion = new ContentVersion(
                Title = 'AMOA From 1231239999 to 1234567890',
                PathOnClient = 'Penguins22.jpg',
                VersionData = Blob.valueOf('Test Content33'),
                IsMajorVersion = true
            );
            ContentVersion contentVersion2 = new ContentVersion(
                Title = 'AMOA From 1231231231 to 1234567899',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            ContentVersionlist.add(contentVersion);
            ContentVersionlist.add(contentVersion2);
            insert ContentVersionlist; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = createinstallation.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = createinstallation.id;
            cdl2.ContentDocumentId = documents[1].Id;
            cdl2.shareType = 'V';
            cdlList.add(cdl);
            cdlList.add(cdl2);
            insert cdlList;
            system.assertEquals(2, cdlList.size());
            Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
            disableTriggerSetting.IsActive__c = false;
            FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
            
            createinstallation.FS_To_Outlet_Name__c = outletacn.id ;
            createinstallation.FS_Asset_Tracking_Form_AMOA_Status__c = 'Submitted';
            createinstallation.FS_Freestyle_Support_Tool_Case__c = caseInstancenew.CaseNumber;
            createinstallation.FS_Did_BAST_initiate_this_RO4W__c = 'Yes';
            update createinstallation;
            
            test.stoptest();
            system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
        }
    }
    
    //check if the  AMOA form is attached to RO4W.
    private static testmethod void testRO4W_AMOAnotattached(){ 
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        Account outletacn = [select id, FS_ACN__c from account where name='Test Outlet 1'];
        outletacn.FS_ACN__c = '1234567';
        update outletacn;
        Case caseInstancenew = [select id, CaseNumber from Case where Issue_Name__c='Sample_Test'];
        FS_CIF__c cif = [select id from FS_CIF__c limit 1];
        
        FS_Installation__c createinstallation = new FS_Installation__c();
        createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
        createinstallation.FS_CIF__c= cif.Id;
        createinstallation.FS_New_Outlet__c= outletAccReloc.id;
        createinstallation.FS_Install_Doc__c= '123';
        insert createinstallation;
        system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
        try{
            system.runAs(fetSysAdminUser){
                test.starttest();
                Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
                disableTriggerSetting.IsActive__c = false;
                FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
                
                createinstallation.FS_To_Outlet_Name__c = outletacn.id ;
                createinstallation.FS_Asset_Tracking_Form_AMOA_Status__c = 'Submitted';
                createinstallation.FS_Freestyle_Support_Tool_Case__c = caseInstancenew.CaseNumber;
                createinstallation.FS_Did_BAST_initiate_this_RO4W__c = 'Yes';
                update createinstallation;
                system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
                test.stoptest();
                
            }
        }catch(exception e){} 
    }
    
    //check if the  AMOA form is attached to RO4W.
    private static testmethod void testRO4W_AMOAattached_withoutformat(){ 
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        Account outletacn = [select id, FS_ACN__c from account where name='Test Outlet 1'];
        outletacn.FS_ACN__c = '1234567';
        update outletacn;
        Case caseInstancenew = [select id, CaseNumber from Case where Issue_Name__c='Sample_Test'];
        FS_CIF__c cif = [select id from FS_CIF__c limit 1];
        
        FS_Installation__c createinstallation = new FS_Installation__c();
        createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
        createinstallation.FS_CIF__c= cif.Id;
        createinstallation.FS_New_Outlet__c= outletAccReloc.id;
        createinstallation.FS_Install_Doc__c= '123';
        insert createinstallation;
        system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
        try{
            system.runAs(fetSysAdminUser){
                test.starttest();
                ContentVersion contentVersion = new ContentVersion(
                    Title = 'AMOA From 12312312 to 1234567890',
                    PathOnClient = 'Penguins.jpg',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true
                );
                insert contentVersion; 
                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
                //create ContentDocumentLink  record 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = createinstallation.id;
                cdl.ContentDocumentId = documents[0].Id;
                cdl.shareType = 'V';
                insert cdl;
                
                Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
                disableTriggerSetting.IsActive__c = false;
                FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
                
                createinstallation.FS_To_Outlet_Name__c = outletacn.id ;
                createinstallation.FS_Asset_Tracking_Form_AMOA_Status__c = 'Submitted';
                createinstallation.FS_Freestyle_Support_Tool_Case__c = caseInstancenew.CaseNumber;
                createinstallation.FS_Did_BAST_initiate_this_RO4W__c = 'Yes';
                update createinstallation;
                system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
                test.stoptest();
               
            }
        }catch(exception e){} 
    }
    
    //check if the  AMOA form is attached to RO4W.
    private static testmethod void testRO4W_AMOAattached_Complete(){ 
        createTestData();
        
        final List<user> userlist = new list<user>();
        final User systemAdmin=FSTestFactory.createUser(systemAdmin.id);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        userlist.add(fetSysAdminUser);
        userlist.add(systemAdmin);
        insert userlist;
        
        Account outletacn = [select id, FS_ACN__c from account where name='Test Outlet 1'];
        outletacn.FS_ACN__c = '1234567';
        update outletacn;
        Case caseInstancenew = [select id, CaseNumber from Case where Issue_Name__c='Sample_Test'];
        FS_CIF__c cif = [select id from FS_CIF__c limit 1];
        
        FS_Installation__c createinstallation = new FS_Installation__c();
        createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
        createinstallation.FS_CIF__c= cif.Id;
        createinstallation.FS_New_Outlet__c= outletAccReloc.id;
        createinstallation.FS_Install_Doc__c= '123';
        insert createinstallation;
        system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W); 
        try{
            system.runAs(systemAdmin){
                test.starttest();
                ContentVersion contentVersion = new ContentVersion(
                    Title = 'AMOA From 1231231231 to 1234567890',
                    PathOnClient = 'Penguins.jpg',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true
                );
                insert contentVersion; 
                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
                //create ContentDocumentLink  record 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = createinstallation.id;
                cdl.ContentDocumentId = documents[0].Id;
                cdl.shareType = 'V';
                insert cdl;
                
                Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
                disableTriggerSetting.IsActive__c = false;
                FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
                
                createinstallation.FS_To_Outlet_Name__c = outletacn.id ;
                createinstallation.FS_Asset_Tracking_Form_AMOA_Status__c = 'Complete';
                createinstallation.FS_Freestyle_Support_Tool_Case__c = caseInstancenew.CaseNumber;
                createinstallation.FS_Did_BAST_initiate_this_RO4W__c = 'Yes';
                update createinstallation;
                system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
                test.stoptest();
                
            }
        }catch(exception e){}
    }
    
    //check if the  AMOA form is attached to RO4W.
    private static testmethod void testRO4W_AMOANotFETAdmin(){ 
        createTestData();
        
        final List<user> userlist = new list<user>();
        final User systemAdmin=FSTestFactory.createUser(systemAdmin.id);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        userlist.add(fetSysAdminUser);
        userlist.add(systemAdmin);
        insert userlist;
        
        Account outletacn = [select id, FS_ACN__c from account where name='Test Outlet 1'];
        outletacn.FS_ACN__c = '1234567';
        update outletacn;
        Case caseInstancenew = [select id, CaseNumber from Case where Issue_Name__c='Sample_Test'];
        FS_CIF__c cif = [select id from FS_CIF__c limit 1];
        
        FS_Installation__c createinstallation = new FS_Installation__c();
        createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
        createinstallation.FS_CIF__c= cif.Id;
        createinstallation.FS_New_Outlet__c= outletAccReloc.id;
        createinstallation.FS_Install_Doc__c= '123';
        insert createinstallation;
        system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
        try{
            system.runAs(systemAdmin){
                test.starttest();
                ContentVersion contentVersion = new ContentVersion(
                    Title = 'AMOA From 1231231231 to 1234567890',
                    PathOnClient = 'Penguins.jpg',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true
                );
                insert contentVersion; 
                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 10];
                system.debug('contentVersion'+contentVersion);
                
                //create ContentDocumentLink  record 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = createinstallation.id;
                cdl.ContentDocumentId = documents[0].Id;
                cdl.shareType = 'V';
                insert cdl;
                List<ContentDocument> documents2 = [select id,ArchivedById, ArchivedDate, ContentAssetId, ContentModifiedDate, ContentSize, Description, 
                FileExtension, FileType, IsArchived,  LastReferencedDate, LastViewedDate, LatestPublishedVersionId, OwnerId, ParentId, 
                PublishStatus,SharingOption ,  Title from ContentDocument];
                
                system.debug('documents2'+documents2);
                Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
                disableTriggerSetting.IsActive__c = false;
                FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
                
                createinstallation.FS_To_Outlet_Name__c = outletacn.id ;
                createinstallation.FS_Asset_Tracking_Form_AMOA_Status__c = 'Complete';
                createinstallation.FS_Freestyle_Support_Tool_Case__c = '1234';
                createinstallation.FS_Did_BAST_initiate_this_RO4W__c = 'No';
                update createinstallation;
                system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
                test.stoptest();
            }
        }catch(exception e){}
    }
    
    //Auto Create Case when BAST is NO.
    private static testmethod void testRO4W_AutoCaseCreate(){ 
        createTestData();
        
        final List<user> userlist = new list<user>();
        final User systemAdmin=FSTestFactory.createUser(systemAdmin.id);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        userlist.add(fetSysAdminUser);
        userlist.add(systemAdmin);
        insert userlist;
        
        Account outletacn = [select id, FS_ACN__c from account where name='Test Outlet 1'];
        outletacn.FS_ACN__c = '1234567';
        update outletacn;
        Case caseInstancenew = [select id, CaseNumber from Case where Issue_Name__c='Sample_Test'];
        FS_CIF__c cif = [select id from FS_CIF__c limit 1];
        
        FS_Installation__c createinstallation = new FS_Installation__c();
        createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
        createinstallation.FS_CIF__c= cif.Id;
        createinstallation.FS_New_Outlet__c= outletAccReloc.id;
        createinstallation.FS_Install_Doc__c= '123';
        insert createinstallation;
        system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
        try{
            system.runAs(systemAdmin){
                test.starttest();
                ContentVersion contentVersion = new ContentVersion(
                    Title = 'AMOA From 1231231231 to 1234567890',
                    PathOnClient = 'Penguins.jpg',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true
                );
                insert contentVersion; 
                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 10];

                //create ContentDocumentLink  record 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = createinstallation.id;
                cdl.ContentDocumentId = documents[0].Id;
                cdl.shareType = 'V';
                insert cdl;
                
                Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
                disableTriggerSetting.IsActive__c = false;
                FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
                
                createinstallation.FS_To_Outlet_Name__c = outletacn.id ;
                createinstallation.FS_Asset_Tracking_Form_AMOA_Status__c = FSConstants.AMOASUBMIT;
                createinstallation.FS_Did_BAST_initiate_this_RO4W__c = FSConstants.NO;
                createInstallation.FS_Relocation_from_old_outlet_to_SP_is__c = true;
                createInstallation.Overall_Status2__c = FSConstants.PIA_PENDINGTONEWOUTLET;
                createInstallation.FS_Freestyle_Support_Tool_Case__c = Null;
                update createinstallation;
                system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
                test.stoptest();
            }
        }catch(exception e){}
    }
    //Update Case when BAST is Yes.
    private static testmethod void testRO4W_UpdateCase(){ 
        createTestData();
        
        final List<user> userlist = new list<user>();
        final User systemAdmin=FSTestFactory.createUser(systemAdmin.id);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        userlist.add(fetSysAdminUser);
        userlist.add(systemAdmin);
        insert userlist;
        
        Account outletacn = [select id, FS_ACN__c from account where name='Test Outlet 1' Limit 1];
        outletacn.FS_ACN__c = '1234567';
        update outletacn;
        Case caseInstancenew = [select id, CaseNumber from Case where Issue_Name__c='Sample_Test' Limit 1];
        FS_CIF__c cif = [select id from FS_CIF__c limit 1];
        
        FS_Installation__c createinstallation = new FS_Installation__c();
        createinstallation = FSTestUtil.createInstallationAcc(Label.IP_Relocation_O4W_Rec_Type,executionPlan.Id,outletacc.id,false);      
        createinstallation.FS_CIF__c= cif.Id;
        createinstallation.FS_New_Outlet__c= outletAccReloc.id;
        createinstallation.FS_Install_Doc__c= '123';
        insert createinstallation;     
        system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
        try{
            system.runAs(systemAdmin){
                test.starttest();
                ContentVersion contentVersion = new ContentVersion(
                    Title = 'AMOA From 1231231231 to 1234567890',
                    PathOnClient = 'Penguins.jpg',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true
                );
                insert contentVersion; 
                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 10];

                //create ContentDocumentLink  record 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = createinstallation.id;
                cdl.ContentDocumentId = documents[0].Id;
                cdl.shareType = 'V';
                insert cdl;
                
                Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSAccountBusinessProcess');
                disableTriggerSetting.IsActive__c = false;
                FSInstallationCreateEPIPAndMails.spEmailrunonce1=false;
                createinstallation.FS_To_Outlet_Name__c = outletacn.id ;
                createinstallation.FS_Asset_Tracking_Form_AMOA_Status__c = 'Submitted';
                createinstallation.FS_Did_BAST_initiate_this_RO4W__c = FSConstants.YES;
                createinstallation.FS_Relocation_from_old_outlet_to_SP_is__c = true;
                createinstallation.Overall_Status2__c = FSConstants.PIA_PENDINGTONEWOUTLET;
                createinstallation.FS_Freestyle_Support_Tool_Case__c = caseInstancenew.CaseNumber;
                createinstallation.FS_IsPendingToNewOutlet__c = True;
                update createinstallation;
                system.assertEquals(createinstallation.RecordTypeId, ipRecTypeRelocationO4W);
                test.stoptest();
            }
        }catch(exception e){}
    }
    //FNF-747 
    private static testmethod void noOutletDispenserSelected(){       
        createTestData(); 
       
        Account outletAcc = [select id from Account where Name = 'Test Outlet 1'];
        installation.RecordTypeId=recTypeReplace;                
        installation.Type_of_Dispenser_Platform__c='8000;9000';
        installation.FS_SP__c=serviceProvider.Id;
        
        installation.SP_Override__c=true;
        insert installation;      
         
        FS_Outlet_Dispenser__c outDisp = FSTestUtil.createOutletDispenserAllTypes('BoE Dispenser','8000',outletAcc.id,null,true);
        update outDisp;

        Test.startTest();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){
            FSInstallationValidateAndSet.brandsetDateCheck=true;        
            installation.Overall_Status2__c='Scheduled';
            installation.FS_Install_Reconnect_Date__c=system.today().addDays(-120); 
            installation.FS_Rush_Install_Reason__c=REMODEL;
            installation.FS_Confirm_Install_Date__c=true;
            installation.FS_SP__c=serviceProvider1.Id;
            try{
            update installation;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains(Label.FS_DispenserSection_Not_Empty) ? true : false;
                system.assertEquals(expectedExceptionThrown, true);
            }
           
            Test.stopTest(); 
        }
       
    }
    private static testmethod void emptyOutletDispenserSection(){       
        createTestData(); 
       
        Account outletAcc = [select id from Account where Name = 'Test Outlet 1'];
        installation.RecordTypeId=recTypeReplace;                
        installation.Type_of_Dispenser_Platform__c='8000;9000';
        installation.FS_SP__c=serviceProvider.Id;

        installation.SP_Override__c=true;
        insert installation;      
   
        Test.startTest();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){
            FSInstallationValidateAndSet.brandsetDateCheck=true;        
            installation.Overall_Status2__c='Scheduled';
            installation.FS_Install_Reconnect_Date__c=system.today().addDays(-120); 
            installation.FS_Rush_Install_Reason__c=REMODEL;
            installation.FS_Confirm_Install_Date__c=true;
            installation.FS_SP__c=serviceProvider1.Id;
            try{
            update installation;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains(Label.FS_DispenserSection_Empty) ? true : false;
                system.assertEquals(expectedExceptionThrown, true);
            }
          
            Test.stopTest(); 
        }
       
    }
    private static testmethod void installationOutletDispenserPlatformTypeMismatch(){       
        createTestData(); 
       
        Account outletAcc = [select id from Account where Name = 'Test Outlet 1'];
        installation.RecordTypeId=recTypeReplace;                
        installation.Type_of_Dispenser_Platform__c='8000;9000';
        installation.FS_SP__c=serviceProvider.Id;
        installation.SP_Override__c=true;
        insert installation;      
        FS_Outlet_Dispenser__c outDisp = FSTestUtil.createOutletDispenserAllTypes('BoE Dispenser','7000',outletAcc.id,null,true);
        outDisp.FS_Other_PIA_Installation__c = installation.id;
        update outDisp;
   
        Test.startTest();
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        system.runAs(fetSysAdminUser){
            FSInstallationValidateAndSet.brandsetDateCheck=true;        
            installation.Overall_Status2__c='Scheduled';
            installation.FS_Install_Reconnect_Date__c=system.today().addDays(-120); 
            installation.FS_Rush_Install_Reason__c=REMODEL;
            installation.FS_Confirm_Install_Date__c=true;
            installation.FS_SP__c=serviceProvider1.Id;
             try{
            update installation;
            }
            catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains(Label.FS_PlatForm_Type_Mismatch) ? true : false;
                system.assertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest(); 
        }
        
    }
    
}