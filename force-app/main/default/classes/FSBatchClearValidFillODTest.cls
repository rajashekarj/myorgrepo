/**************************************************************************************
Apex Class Name     : FSBatchClearValidFillODTest
Version             : 1.0
Function            : This test class is for  FSBatchClearValidFillOD Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSBatchClearValidFillODTest{
    
    public static Account headquartersAcc,outletAcc;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;
    public static FS_Outlet_Dispenser__c oDispenser7k,oDispenser8k,oDispenser9k;
    public static FS_Valid_Fill__c validFill7k,validFill8k9k;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    private static void createTestData(){
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        outletAcc=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,true);       
        
        executionPlan= FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);       
        insert executionPlan;       
        
        installation= FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);        
        insert installation;
    }
    
    private static testmethod void validFill7kTest(){
        createTestData();
        oDispenser7k=FSTestUtil.createOutletDispenserAllTypes('CCNA Dispenser','7000',outletAcc.id,installation.id,true);
        
        validFill7k=FSTestUtil.createValidFill('7000',true);
        final Set<Id> installIds=new Set<Id>{installation.id};
            Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchClearValidFillOD batchInstance=new FSBatchClearValidFillOD(validFill7k.id,installIds);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();      
    }
    
    private static testmethod void validFill8kTest(){
        createTestData();
        oDispenser8k=FSTestUtil.createOutletDispenserAllTypes('CCNA Dispenser','8000',outletAcc.id,installation.id,true);
        
        validFill8k9k=FSTestUtil.createValidFill('8000',true);
        final Set<Id> installIds=new Set<Id>{installation.id};
            Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchClearValidFillOD batchInstance=new FSBatchClearValidFillOD(validFill8k9k.id,installIds);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();        
    }
    
    private static testmethod void validFill9kTest(){
        createTestData();
        oDispenser9k=FSTestUtil.createOutletDispenserAllTypes('CCNA Dispenser','9000',outletAcc.id,installation.id,true);
        
        validFill8k9k=FSTestUtil.createValidFill('9000',true);
        final Set<Id> installIds=new Set<Id>{installation.id};
            Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchClearValidFillOD batchInstance=new FSBatchClearValidFillOD(validFill8k9k.id,installIds);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();        
    }
}