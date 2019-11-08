/**************************************************************************************
Apex Class Name     : FSCopyPostInstallActivity_Test
Version             : 1.0
Function            : This test class is for FSCopyPostInstallActivity Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys                                 Original Version 
*                     05/29/2018          Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest 
public Class FSCopyPostInstallActivity_Test {
    public static Account accchain,accHQ,accOutlet;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installtion;
    public Static FS_outlet_dispenser__c outletDispenser;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    public static string accName='Account';
    public static string ipName='Installation';
    public static string plat8k='8000 Series';
    
    
    private Static testMethod void createtestData(){
        //List<Account> accList=new List<Account>();
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true); 
        //accList.add(accchain);
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        //accList.add(accHQ);        
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, true);        
        //accList.add(accOutlet);
        //insert accList;
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);
        //Create custom setting data
        FSTestFactory.lstPlatform();
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        installtion = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,accOutlet.id , false);
        installtion.Overall_Status2__c=FSConstants.x4InstallSchedule;
        insert installtion;
        
        outletDispenser= new FS_outlet_dispenser__c();
        
        outletDispenser.FS_Outlet__c = accOutlet.Id;
        outletDispenser.FS_Equip_Type__c  ='7000';
        outletDispenser.FS_Serial_Number2__c = 'AHK7785';
        outletDispenser.Installation__c = installtion.id;
        outletDispenser.FS_7000_Series_Agitated_Selections_New__c = 'N/A to 8000/9000 Series';
        insert outletDispenser;
        final FS_Msg_Copy_to_lower_levels__c msgc = new  FS_Msg_Copy_to_lower_levels__c(Name = 'Successfully Copied to lower level',FS_Success_Copy_to_Lower_Levels__c='For Larger Data Sets it may take time to reflect in lower levels');
        insert msgc; 
        system.assertNotEquals(outletDispenser, null);
    }
    
   private static testMethod void  testUnitFSCopyValidFill(){    
        createtestData();
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='7000';
        update outletDispenser; 
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill =FSTestUtil.createValidFill('7000',true);
        validFill.FS_Installation__c=installtion.id; 
        update validFill;        
        
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FSCopyPostInstallActivity.ChaintoHqValidFill(accchain.id,validFill.id,accName);
            FSCopyPostInstallActivity.ChaintoHqValidFill(accHQ.id,validFill.id,accName);
            FSCopyPostInstallActivity.ChaintoHqValidFill(accOutlet.id,validFill.id,accName);
            
            FS_Installation__c installation1= new FS_Installation__c();
            installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
            validFill.FS_Installation__c=installation1.id;   
            update validFill;
            FSCopyPostInstallActivity.ChaintoHqValidFill(installation1.id,validFill.id,ipName);
        }
        system.assertNotEquals(validFill, null);
        Test.stopTest();
    }
    
    private static testMethod void  testUnitFSCopyValidFill8000(){  
        
        createtestData();
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='8000';
        update outletDispenser; 
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill =FSTestUtil.createValidFill('8000',true);
        validFill.FS_Installation__c=installtion.id; 
        update validFill;       
        
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FSCopyPostInstallActivity.ChaintoHqValidFill(accchain.id,validFill.id,accName);
            FSCopyPostInstallActivity.ChaintoHqValidFill(accHQ.id,validFill.id,accName);
            FSCopyPostInstallActivity.ChaintoHqValidFill(accOutlet.id,validFill.id,accName);
            
            FS_Installation__c installation1= new FS_Installation__c();
            installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
            validFill.FS_Installation__c=installation1.id;   
            update validFill;
            FSCopyPostInstallActivity.ChaintoHqValidFill(installation1.id,validFill.id,ipName);
        }
        system.assertNotEquals(validFill, null);
        Test.stopTest();
    }
    private static testMethod void  testUnitFSCopyValidFill9000(){    
        
        createtestData();
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='9000';
        update outletDispenser;  
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill =FSTestUtil.createValidFill('9000',true);
        validFill.FS_Installation__c=installtion.id; 
        update validFill;
   
        Test.startTest(); 
         final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FSCopyPostInstallActivity.ChaintoHqValidFill(accchain.id,validFill.id,accName);
            FSCopyPostInstallActivity.ChaintoHqValidFill(accHQ.id,validFill.id,accName);
            FSCopyPostInstallActivity.ChaintoHqValidFill(accOutlet.id,validFill.id,accName);
            
            FS_Installation__c installation1= new FS_Installation__c();
            installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
            validFill.FS_Installation__c=installation1.id;   
            update validFill;
            FSCopyPostInstallActivity.ChaintoHqValidFill(installation1.id,validFill.id,ipName);
        }
        system.assertNotEquals(validFill, null);
        Test.stopTest();
    }
    
    private static testMethod void  testUnitFSCopyValidFill9100(){    
        
        createtestData();
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='9100';
        update outletDispenser;  
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill =FSTestUtil.createValidFill('9100',true);
        validFill.FS_Installation__c=installtion.id; 
        update validFill;
   
        Test.startTest(); 
         final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FSCopyPostInstallActivity.ChaintoHqValidFill(accchain.id,validFill.id,accName);
            FSCopyPostInstallActivity.ChaintoHqValidFill(accHQ.id,validFill.id,accName);
            FSCopyPostInstallActivity.ChaintoHqValidFill(accOutlet.id,validFill.id,accName);
            
            FS_Installation__c installation1= new FS_Installation__c();
            installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
            validFill.FS_Installation__c=installation1.id;   
            update validFill;
            FSCopyPostInstallActivity.ChaintoHqValidFill(installation1.id,validFill.id,ipName);
        }
        system.assertNotEquals(validFill, null);
        Test.stopTest();
    }
    
    private static testMethod void  testUnitFSCopyValidFillRelocation(){ 
        
        createtestData();
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='8000';
        update outletDispenser; 
        
        FS_Installation__c installation1= new FS_Installation__c();
        installation1=FSTestUtil.createInstallationAcc(Label.IP_Relocation_I4W_Rec_Type,executionPlan.id,accOutlet.id, false );
        installation1.FS_New_Outlet__c=accOutlet.id;
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            insert installation1;
            
            FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
            validFill =FSTestUtil.createValidFill('8000 & 9000 Series',true);
            validFill.FS_Installation__c=installation1.id;   
            update validFill;
          
            FSCopyPostInstallActivity.ChaintoHqValidFill(accchain.id,validFill.id,accName);
        }
        system.assertNotEquals(fetSysAdminUser, null);
        Test.stopTest();
    }
    
    private static testMethod void  testUnitFSCopyPostInsMrkt(){
        createtestData();       
        
        FS_Post_Install_Marketing__c marketingField = new FS_Post_Install_Marketing__c();
        marketingField =FSTestUtil.createMarketingField(true);
        marketingField.FS_Installation__c=installtion.id;
        marketingField.FS_Enable_Consumer_Engagement__c='Yes';
        marketingField.FS_Enable_CE_Effective_Date__c=system.today();
        marketingField.FS_FAV_MIX__c='Yes';
        marketingField.FS_FAV_MIX_Effective_Date__c=system.today();
        marketingField.FS_LTO__c='LTO1';
        marketingField.FS_LTO_Effective_Date__c=system.today();
        marketingField.FS_Promo_Enabled__c='Yes';
        marketingField.FS_Promo_Enabled_Effective_Date__c=system.today();
        update marketingField;     
        
        Test.startTest();
         final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FSCopyPostInstallActivity.ChaintoHqMarketing(accchain.id,marketingField.id,accName);
            FSCopyPostInstallActivity.ChaintoHqMarketing(accHQ.id,marketingField.id,accName);
            FSCopyPostInstallActivity.ChaintoHqMarketing(accOutlet.id,marketingField.id,accName);
            
            FS_Installation__c installation1= new FS_Installation__c();
            installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
            marketingField.FS_Installation__c=installation1.id;   
            update marketingField;
            FSCopyPostInstallActivity.ChaintoHqMarketing(installation1.id,marketingField.id,ipName);
        }
        system.assertNotEquals(marketingField, null);
        Test.stopTest();        
    }
    
}