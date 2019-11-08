/**************************************************************************************
Apex Class Name     : FSBatchCancelValidFillTest
Version             : 1.0
Function            : This test class is for FSBatchCancelValidFill Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSBatchCancelValidFillTest{
    public static Account headquartersAcc,outletAcc;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;
    public static FS_Outlet_Dispenser__c oDispenser7k,oDispenser8k,oDispenser9k;
    public static FS_Valid_Fill__c validFill7k,validFill8k,validFill9k;
    
    private static void createTestData(){
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FSTestUtil.insertPlatformTypeCustomSettings();

        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        outletAcc=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,true);        
        executionPlan=FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);    
        final List<FS_Execution_Plan__c> epList=new List<FS_Execution_Plan__c>();
        epList.add(executionPlan);        
        insert epList;
        
        installation= FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        
        final List<FS_Installation__c> ipList=new List<FS_Installation__c>();
        ipList.add(installation);      
        
        insert ipList;
    }
    
    private static testmethod void cancelValidFill(){
        createTestData();
        oDispenser7k=FSTestUtil.createOutletDispenserAllTypes('CCNA Dispenser','7000',outletAcc.id,installation.id,true);
        
        validFill7k=FSTestUtil.createValidFill('7000',false);
        validFill7k.FS_Outlet__c=outletAcc.id;
        insert validFill7k;
        Test.startTest();
        validFill7k.FS_RcdIDForCncl__c=validFill7k.id;
        update validFill7k;
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchCancelValidFill batchInstance=new FSBatchCancelValidFill(validFill7k.id);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();        
    }
    
    private static testmethod void cancelValidFill8000(){
        createTestData();
        oDispenser7k=FSTestUtil.createOutletDispenserAllTypes('CCNA Dispenser','8000',outletAcc.id,installation.id,true);
        
        validFill8k=FSTestUtil.createValidFill('8000',false);
        validFill8k.FS_Outlet__c=outletAcc.id;
        insert validFill8k;
        Test.startTest();
        validFill8k.FS_RcdIDForCncl__c=validFill8k.id;
        update validFill8k;
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchCancelValidFill batchInstance=new FSBatchCancelValidFill(validFill8k.id);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();        
    }
    
    private static testmethod void cancelValidFill9000(){
        createTestData();
        oDispenser7k=FSTestUtil.createOutletDispenserAllTypes('CCNA Dispenser','9000',outletAcc.id,installation.id,true);
        
        validFill8k=FSTestUtil.createValidFill('9000',false);
        validFill8k.FS_Outlet__c=outletAcc.id;
        insert validFill8k;
        Test.startTest();
        validFill8k.FS_RcdIDForCncl__c=validFill8k.id;
        update validFill8k;
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchCancelValidFill batchInstance=new FSBatchCancelValidFill(validFill8k.id);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();        
    }
    
     private static testmethod void cancelValidFill9100(){
        createTestData();
        oDispenser7k=FSTestUtil.createOutletDispenserAllTypes('CCNA Dispenser','9100',outletAcc.id,installation.id,true);
        
        validFill8k=FSTestUtil.createValidFill('9100',false);
        validFill8k.FS_Outlet__c=outletAcc.id;
        insert validFill8k;
        Test.startTest();
        validFill8k.FS_RcdIDForCncl__c=validFill8k.id;
        update validFill8k;
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchCancelValidFill batchInstance=new FSBatchCancelValidFill(validFill8k.id);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();        
    }
}