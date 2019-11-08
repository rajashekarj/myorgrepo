@isTest
public class ODInstallationLinkBatchTest {
     private static Account accchain,bottler,outlet,accHQ;

    //Variables
	private static final string SERIES_7K='7000';
    private static final string SERIES_8K='8000';
    private static final string SERIES_9K='9000';
    public static User tuser,apiUser, coordinatorUser;
    public static FS_Integration_NMS_User__c integrationUser;
    public static Account chainAcc,hQAcc,outletAcc,intoutletAcc,hqInt,chainInt;
    public static FS_IP_Technician_Instructions__c  ipTechInstruction;
    public static Shipping_Form__c shippingForm;
    public static Dispenser_Model__c dispenserModel;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation,replaceInstall,relocInstall;
    public static FS_Outlet_Dispenser__c outletDispenser,intOutletDispenser;
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5;
    private static final string POWER_RAS='Powerade;raspberry';
    private static final string PIBB='Pibb';    
    private static final string MODEL_2K='2000';
    private static final string LT01='LTO1';
    private static final string SHOW='Show';
    private static final string YES='Yes';
    private static final string PIBB1='Pibb;';
    private static final string BRAND_SELECTION='2 Static/1 Agitated';
    private static final string HIDE='Hide';
    private static final string NO_VAL='No';
    private static final string BRAND_SELECTION1='0 Static/2 Agitated';   
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    
    //Create Test Data
    private static void createTestData(){    
        
        tuser = FSTestUtil.createUser(null,0,FSConstants.USER_POFILE_FETADMIN,true);
        apiUser=FSTestUtil.createUser(null,null,'API User',false);
        
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
        final List<Account> listAcc = new LIst<Account>();
        //Chain Account
        chainAcc = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAcc.FS_ACN__c = '76876876';
        listAcc.add(chainAcc);
        chainInt=FSTestUtil.createTestAccount('Test Chain 2',FSConstants.RECORD_TYPE_CHAIN,false);
        chainInt.FS_ACN__c = '7687687ICH';
        listAcc.add(chainInt);
        //HQ Account
        hQAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        hQAcc.FS_ACN__c = '7658765876';
        hQAcc.FS_Payment_Method__c = 'Credit Card';
        hQAcc.Cokesmart_Payment_Method__c='Credit Card';
        hQAcc.FS_Payment_Type__c='No';
        hQAcc.Invoice_Customer__c= 'No';
        listAcc.add(hQAcc);
        hqInt= FSTestUtil.createTestAccount('Test Headquarters Int',FSConstants.RECORD_TYPE_HQ,false);
        hqInt.FS_ACN__c = '7658765800';
        listAcc.add(hqInt);
        //Creates Outlet Accounts 
        outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,hQAcc.Id, false);
        outletAcc.FS_ACN__c='9874562100';
        outletAcc.ShippingCountry='US';
       	listAcc.add(outletAcc);
        //Bottler for international
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,false);
        listAcc.add(bottler);
       
        insert listAcc;
        
        intoutletAcc= new Account(Name='TEst Int Outlet',RecordTypeId= FSConstants.RECORD_TYPE_OUTLET_INT,ShippingCountry='US',
                                 FS_Chain__c=chainInt.Id,fs_acn__C='1234567890',FS_Is_Address_Validated__c='yes');
        insert intoutletAcc;
        Disable_Trigger__c setting = new Disable_Trigger__c();
        setting.Name = 'FSODBusinessProcess';
        setting.IsActive__c = false;
        setting.Trigger_Name__c='FS_OD_Trigger';     
        insert setting;
        //creates OD
        FS_Outlet_Dispenser__c outletDispenser = new FS_Outlet_Dispenser__c();
        outletDispenser.FS_Outlet__c=outletAcc.id;
        outletDispenser.FS_IsActive__c=true;
        outletDispenser.FS_Status__c='Enrolled';
        outletDispenser.FS_Date_Installed2__c=Date.newInstance(2019,4,4);
        outletDispenser.FS_Planned_Install_Date__c=Date.newInstance(2019,4,4);
        outletDispenser.FS_Equip_Type__c='7000';
        outletDispenser.FS_Date_Status__c=Date.newInstance(2019,4,4);
        
        insert outletDispenser;
        system.debug('outletDispenser'+outletDispenser);
        system.runAs(coordinatorUser){
            shippingForm = FSTestUtil.createShippingForm(true);
        }
        
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN ,hQAcc.Id, true);
        
        //create trigger switch --custom setting
        FSTestFactory.createTestDisableTriggerSetting();
        
        //creates installation
        final List<Fs_Installation__C> listInstallation = new List<Fs_Installation__C>();
      
        replaceInstall=FSTestUtil.createInstallationAcc(Label.IP_Replacement_Rec_Type,executionPlan.Id,outletAcc.Id,false);
        replaceInstall.Overall_Status2__c = 'Scheduled';
        replaceInstall.Type_of_Dispenser_Platform__c='7000';
        replaceInstall.FS_Reason_Code__c='Unit Damaged at Arrival';
        replaceInstall.Type_of_Dispenser_Platform__c='7000';
        replaceInstall.FS_Scheduled_Install_Date__c=Date.newInstance(2019,5,5);
        listInstallation.add(replaceInstall) ;

        insert listInstallation;
      
	
        
    }
     static testmethod void test() {  
                  createTestData();
     
        Test.startTest();
        ODInstallationLinkBatch uca = new ODInstallationLinkBatch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }
     static testmethod void test1() {  
                  createTestData();
    relocInstall=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION ,executionPlan.Id,outletAcc.Id,false);
        relocInstall.Overall_Status2__c = 'Scheduled';
        relocInstall.Type_of_Dispenser_Platform__c='7000';
        relocInstall.FS_Reason_Code__c='Customer Request';
        relocInstall.FS_Scheduled_Install_Date__c=Date.newInstance(2019,5,5);
        //relocInstall.FS_Equip_Type__c='';
     insert relocInstall;
        Test.startTest();
        ODInstallationLinkBatch uca = new ODInstallationLinkBatch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }
      static testmethod void testscheduler() {  
            createTestData();
    		Test.startTest(); 
            // Schedule the test job
            final String sch = '0 0 0 * * ?';
            final String jobId = System.schedule('ODInstallationLinkSchedule', sch, new ODInstallationLinkSchedule());
            // Get the information from the CronTrigger API object
            final CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            
            // Verify the expressions are the same  
            System.assertEquals(sch,ct.CronExpression);
            
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            
            Test.stopTest();

            System.abortJob(jobId); 
    }
    
}