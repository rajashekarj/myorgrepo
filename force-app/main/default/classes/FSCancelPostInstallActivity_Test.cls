/**************************************************************************************
Apex Class Name     : FSCancelPostInstallActivity_Test
Version             : 1.0
Function            : This test class is for FSCancelPostInstallActivity Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest 
public Class FSCancelPostInstallActivity_Test {
    public static Account accchain,accHQ,accOutlet;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installtion;
    public Static FS_outlet_dispenser__c outletDispenser;   
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    private Static testMethod void createtestData(){
        final List<Account> accList=new List<Account>();
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false); 
        accList.add(accchain);
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        accList.add(accHQ);        
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false);        
        accList.add(accOutlet);
        insert accList;
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);
        system.debug('Execution Id'+executionPlan );
        
        installtion =FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,accOutlet.id , true);
        
        //Create custom setting data
        FSTestFactory.lstPlatform();
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        outletDispenser= new FS_outlet_dispenser__c();
        
        outletDispenser.FS_Outlet__c = accOutlet.Id;
        outletDispenser.FS_Equip_Type__c  ='7000';
        outletDispenser.FS_Serial_Number2__c = 'AHK7785';
        outletDispenser.Installation__c = installtion.id;
        outletDispenser.FS_7000_Series_Agitated_Selections_New__c = 'N/A to 8000/9000 Series';
        insert outletDispenser;  
                system.assertNotEquals(outletDispenser, null);

    }
    
    
    
    private static testMethod void  testUnitFSCancelValidFill7000(){    
        
        Test.startTest();
        createtestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
            validFill =FSTestUtil.createValidFill('7000',true);
            validFill.FS_Installation__c=installtion.id; 
            update validFill;
                 
            FSCancelPostInstallActivity.FSCancelValidFill(validFill.id);
        }
                        system.assertNotEquals(fetSysAdminUser, null);
        Test.stopTest();
    }
    
    private static testMethod void  testUnitFSCancelValidFill8000(){    
        
        Test.startTest();
        createtestData();
        outletDispenser.FS_Equip_Type__c  ='8000';
        update outletDispenser; 
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
            validFill =FSTestUtil.createValidFill('8000',true);
            validFill.FS_Installation__c=installtion.id; 
            update validFill;
                 
            FSCancelPostInstallActivity.FSCancelValidFill(validFill.id);
        }
                        system.assertNotEquals(fetSysAdminUser, null);
        Test.stopTest();
    }
    private static testMethod void  testUnitFSCancelValidFill9000(){    
        Test.startTest();
        createtestData();
        outletDispenser.FS_Equip_Type__c  ='9000';
        update outletDispenser; 
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
            validFill =FSTestUtil.createValidFill('9000',true);
            validFill.FS_Installation__c=installtion.id; 
            update validFill;
                
            FSCancelPostInstallActivity.FSCancelValidFill(validFill.id);
        }
                        system.assertNotEquals(fetSysAdminUser, null);
        Test.stopTest();
    }
    private static testMethod void  testUnitFSCancelValidFill8k9k(){    
        
        Test.startTest();
        createtestData();
        outletDispenser.FS_Equip_Type__c  ='9100';
        update outletDispenser; 
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
            validFill =FSTestUtil.createValidFill('9100',true);
            validFill.FS_Installation__c=installtion.id; 
            update validFill;
                  
            FSCancelPostInstallActivity.FSCancelValidFill(validFill.id);
        }
        system.assertNotEquals(fetSysAdminUser, null);
        Test.stopTest();
    }
    
    private static testMethod void  testUnitFSCancelPostInsMrkt(){
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
            FSCancelPostInstallActivity.FSCancelPostInsMrkt(marketingField.id);
        }
        system.assertNotEquals(fetSysAdminUser, null);
        Test.stopTest();        
    }
    
}