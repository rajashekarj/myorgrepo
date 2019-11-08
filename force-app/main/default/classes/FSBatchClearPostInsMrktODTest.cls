/**************************************************************************************
Apex Class Name     : FSBatchClearPostInsMrktODTest
Version             : 1.0
Function            : This test class is for FSBatchClearPostInsMrkt Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSBatchClearPostInsMrktODTest{
    public static Account headquartersAcc,outletAcc;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;
    public static FS_Outlet_Dispenser__c oDispenser7k,oDispenser8k,oDispenser9k;
    public static FS_Post_Install_Marketing__c postInstallObject;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    private static void createTestData(){
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FSTestUtil.insertPlatformTypeCustomSettings();

        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        outletAcc=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,true);

        executionPlan= FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);        
        
        final List<FS_Execution_Plan__c> epList=new List<FS_Execution_Plan__c>();
        epList.add(executionPlan);
       
        insert epList;
        
        installation= FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        
        final List<FS_Installation__c> ipList=new List<FS_Installation__c>();
        ipList.add(installation);
        
        
        insert ipList;
    }
    private static testmethod void clearPostInsMrktOD(){
        createTestData();
        oDispenser7k=FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,'7000',outletAcc.id,installation.id,true);
        
        postInstallObject=FSTestUtil.createMarketingField(true);
        final Set<Id> installIds=new Set<Id>{installation.id};
            Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchClearPostInsMrktOD batchInstance=new FSBatchClearPostInsMrktOD (postInstallObject.id,installIds);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();
        
    }
}