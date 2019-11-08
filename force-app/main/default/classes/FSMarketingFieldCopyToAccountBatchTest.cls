@isTest
public class FSMarketingFieldCopyToAccountBatchTest {
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
            
    }
    
    static testMethod void testMethod1(){
        Test.StartTest();
        createtestData();
        Integer count=0;
                final List<Account> hqCustList= FSTestFactory.createTestAccount(true,4,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));

        final List<Account> outletCustList= FSTestFactory.createTestAccount(false,25,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        for(Account acc:outletCustList){
            acc.FS_Headquarters__c = hqCustList.get(0).id;
            acc.FS_ACN__c = '00001673'+count;
            acc.FS_CE_Enabled__c='yes';
            acc.FS_LTO__c='yes';
            acc.FS_Promo_Enabled__c='yes';
            count++;
        }
        Account acc1=new Account();
        acc1.name='test acc';
        acc1.FS_Headquarters__c = hqCustList.get(0).id;
            acc1.FS_ACN__c = '00001673'+count;
            acc1.FS_CE_Enabled__c='Yes';
            acc1.FS_LTO__c='Yes';
            acc1.FS_Promo_Enabled__c='Yes';
        Insert acc1;
		Disable_Trigger__c disableTriggerSetting= new Disable_Trigger__c();        
        disableTriggerSetting.Trigger_Name__c='FSPostInstallMarketingTriggerHandler';
        disableTriggerSetting.IsActive__c=false;
        disableTriggerSetting.Name='FSPostInstallMarketingTriggerHandler';
        insert disableTriggerSetting;
        system.debug('**********id:'+outletCustList[0].id);
        FS_Post_Install_Marketing__c marketingField = new FS_Post_Install_Marketing__c();
        marketingField =FSTestUtil.createMarketingField(true);
        marketingField.FS_Installation__c=installtion.id;
        marketingField.FS_Enable_Consumer_Engagement__c='No';
        marketingField.FS_Enable_CE_Effective_Date__c=system.today();
		marketingField.FS_FAV_MIX__c='Yes';
        marketingField.FS_FAV_MIX_Effective_Date__c=system.today();
        marketingField.FS_LTO__c='No';
        marketingField.FS_Account__c = acc1.id;

        marketingField.FS_Cncl_Post_Install_Marketting_fields__c=false;
        marketingField.FS_LTO_Effective_Date__c=system.today();
        marketingField.FS_Promo_Enabled__c='No';
        marketingField.FS_Promo_Enabled_Effective_Date__c=system.today();
        update marketingField;  
        FSMarketingFieldCopyToAccountSchedular sh1 = new FSMarketingFieldCopyToAccountSchedular();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}