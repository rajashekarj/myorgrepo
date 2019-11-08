/**************************************************************************************
Apex Class Name     : FSBatchCopyOutletToODTest
Version             : 1.0
Function            : This test class is for FSBatchCopyOutletToOD Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys                                 Original Version 
*                     05/29/2018          Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest 
public Class FSBatchCopyOutletToODTest {
    public static Account accchain,accHQ,accOutlet;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installtion;
    public Static FS_outlet_dispenser__c outletDispenser;   
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN); 
    public static string odRecType=Schema.SObjectType.FS_outlet_dispenser__c.getRecordTypeInfosByName().get(Label.CCNA_Disp_Record_type).getRecordTypeId();
    
    private Static void createtestData(){
        final List<Account> accList=new List<Account>();
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false); 
        accList.add(accchain);
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        accList.add(accHQ);        
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false);        
        accList.add(accOutlet);
        insert accList;
        executionPlan =FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN ,accHQ.Id, true);
        system.debug('Execution Id'+executionPlan );
        
        installtion =FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,accOutlet.id , true);
        
        //Create custom setting data
        final List<Platform_Type_ctrl__c> listplatform = FSTestFactory.lstPlatform();
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        System.Debug('Outlet'+accOutlet.Id);
        outletDispenser= new FS_outlet_dispenser__c();       
        
        outletDispenser.FS_Outlet__c = accOutlet.Id;
        outletDispenser.recordtypeID=odRecType;
        outletDispenser.FS_Equip_Type__c  ='7000';
        outletDispenser.FS_Serial_Number2__c = 'AHK7785';
        outletDispenser.Installation__c = installtion.id;
        outletDispenser.FS_7000_Series_Agitated_Selections_New__c = 'N/A to 8000/9000 Series';
        insert outletDispenser;
        
        final FS_Msg_Copy_to_lower_levels__c mc = new  FS_Msg_Copy_to_lower_levels__c(Name = 'Successfully Copied to lower level',FS_Success_Copy_to_Lower_Levels__c='For Larger Data Sets it may take time to reflect in lower levels');
        insert mc;        
    }
    
    private static testMethod void  testUnitFSCopyValidFill7000(){    
        createtestData();
        String fcid = accOutlet.id; 
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='7000';
        update outletDispenser; 
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill =FSTestUtil.createValidFill('7000',true);
        //validFill.FS_Installation__c=installtion.id;
        validFill.FS_Outlet__c=accOutlet.Id;
        update validFill;
        String vfid= validFill.id;  
        
        Test.startTest();
        Account accOutlet1=new Account();
        accOutlet1 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        
        
        FS_Installation__c Installation1= new FS_Installation__c();
        Installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
        validFill.FS_Outlet__c=accOutlet1.id;   
        update validFill;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            Database.executeBatch(New FSBatchCopyOutletToOD(fcid,null,null,validFill,null),10);
        }
        system.assertNotEquals(validFill, null);
        Test.stopTest();
    }
    
    
    private static testMethod void  testUnitFSCopyValidFill8000(){    
        createtestData();
        String fcid = accOutlet.id; 
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='8000';
        outletDispenser.RecordTypeId=odRecType;
        update outletDispenser; 
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill =FSTestUtil.createValidFill('8000',true);
        //validFill.FS_Installation__c=installtion.id;
        validFill.FS_Outlet__c=accOutlet.id; 
        update validFill;
        String vfid= validFill.id;  
        
        Test.startTest();
        Account accOutlet1=new Account();
        accOutlet1 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        FS_Installation__c Installation1= new FS_Installation__c();
        Installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
        validFill.FS_Outlet__c=accOutlet1.id; 
        update validFill;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){                                               
            Database.executeBatch(New FSBatchCopyOutletToOD(fcid,null,null,validFill,null),10);
        }
                system.assertNotEquals(validFill, null);

        Test.stopTest();
    }
    
    private static testMethod void  testUnitFSCopyValidFill9000(){    
        createtestData();
        String fcid = accOutlet.id; 
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='9000';
        outletDispenser.RecordTypeId=odRecType;
        update outletDispenser; 
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill = FSTestUtil.createValidFill('9000',true);
        //validFill.FS_Installation__c=installtion.id; 
        validFill.FS_Outlet__c=accOutlet.id; 
        update validFill;
        String vfid= validFill.id;  
        
        Test.startTest();
        Account accOutlet1=new Account();
        accOutlet1 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        FS_Installation__c Installation1= new FS_Installation__c();
        Installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
        //validFill.FS_Installation__c=Installation1.id; 
        validFill.FS_Outlet__c=accOutlet1.id;       
        update validFill;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            Database.executeBatch(New FSBatchCopyOutletToOD(fcid,null,null,validFill,null),10);
        }
        system.assertNotEquals(validFill, null);

        Test.stopTest();
    }
    
    private static testMethod void  testUnitFSCopyValidFill9100(){    
        createtestData();
        String fcid = accOutlet.id; 
        outletDispenser.Installation__c=installtion.id; 
        outletDispenser.FS_Equip_Type__c  ='9100';
        outletDispenser.RecordTypeId=odRecType;
        update outletDispenser; 
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill = FSTestUtil.createValidFill('9100',true);
        //validFill.FS_Installation__c=installtion.id; 
        validFill.FS_Outlet__c=accOutlet.id; 
        update validFill;
        String vfid= validFill.id;  
        
        Test.startTest();
        Account accOutlet1=new Account();
        accOutlet1 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        FS_Installation__c Installation1= new FS_Installation__c();
        Installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, true );
        //validFill.FS_Installation__c=Installation1.id; 
        validFill.FS_Outlet__c=accOutlet1.id;       
        update validFill;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            Database.executeBatch(New FSBatchCopyOutletToOD(fcid,null,null,validFill,null),10);
        }
        system.assertNotEquals(validFill, null);
        Test.stopTest();
    }
    
}