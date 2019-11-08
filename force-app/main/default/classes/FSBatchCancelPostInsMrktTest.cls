/**************************************************************************************
Apex Class Name     : FSBatchCancelPostInsMrktTest
Version             : 1.0
Function            : This test class is for FSBatchCancelPostInsMrkt Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSBatchCancelPostInsMrktTest{
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
        
        executionPlan= FSTestUtil.createExecutionPlan(FSconstants.EXECUTIONPLAN,headquartersAcc.Id, true);
        installation= FSTestUtil.createInstallationAcc(FSconstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , true);     
        
    }
    
    private static testmethod void cancelPostInsMrkt(){
        createTestData();
        oDispenser7k=FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,'7000',outletAcc.id,installation.id,true);
        
        postInstallObject=FSTestUtil.createMarketingField(false);
        postInstallObject.FS_Installation__c=installation.id;
        insert postInstallObject;
        Test.startTest();
        postInstallObject.FS_RcdIDForCncl__c=postInstallObject.id;
        update postInstallObject;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchCancelPostInsMrkt batchInstance=new FSBatchCancelPostInsMrkt(postInstallObject.id);
            Database.executeBatch(batchInstance);
        }
        Test.stopTest();
        
    }
}