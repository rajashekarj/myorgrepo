@istest
private class FS_SellingActivityMarket_TriggerTest{
    public static Account chainAcc,headquartersAcc,outletAcc,outletAccRelocation,serviceProviderAcc;
    public static Contact spContact;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;
    public static Selling_Activity_Market__c sellingActivityMarket;
    public static String recTypeNew=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('New Install').getRecordTypeId() ;
    public static String recTypeRelocation=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Relocation_I4W_Rec_Type).getRecordTypeId() ;
    public static String recTypeRemoval=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Removal_Rec_Type).getRecordTypeId();
    public static String recTypeReplacement=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Replacement_Rec_Type).getRecordTypeId();
    public static String recServiceProviderAcc=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Service Provider').getRecordTypeId();
    public static String recServiceProviderCnt=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Service Provider').getRecordTypeId();
     private static Profile fetSysAdmin;
    
    private static FS_Installation__c createTestData(){
        final List<Account> accList=new List<Account>();
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        outletAccRelocation=FSTestUtil.createAccountOutlet('Test Outlet1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
        
        outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
        outletAcc.ShippingStreet='7700 N MACARTHUR BLVD';
        outletAcc.ShippingCity='IRVING';
        outletAcc.ShippingState='TX';
        outletAcc.ShippingPostalCode='75063-7514';
        outletAcc.ShippingCountry='US';
        
        accList.add(outletAcc);
        accList.add(outletAccRelocation);     
        
        //Create Service Provider Account
        final Account serviceProviderAccount =FSTestUtil.createTestAccount('Serice Provider Account',null,false);        
        serviceProviderAccount.FS_Primary_Service_Provider__c=true;
        serviceProviderAccount.RecordTypeId=recServiceProviderAcc ;
        accList.add(serviceProviderAccount);
        
        insert accList;
        
        //Create SP Alignes Zip
        final List<FS_SP_Aligned_Zip__c >  spAlignedZipList=new List<FS_SP_Aligned_Zip__c >();
        spAlignedZipList.add(FSTestUtil.createSPZipAligned('SP Aligned Zip','75063',serviceProviderAccount.Id,false));
        insert spAlignedZipList;
        
        //Create Execution Plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, true);
        
        //Create Installation
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        installation.FS_New_Outlet__c=outletAcc.id;
        installation.RecordTypeId=recTypeRelocation;
        installation.FS_7000_Series_Brands_Option_Selections__c = '0 Static/ 1 Agitated';
        installation.FS_7000_Series_Agitated_Brands_Selection__c = 'Pibb';
        installation.FS_7000_Series_Statics_Brands_Selection__c = '';
        installation.Type_of_Dispenser_Platform__c=FSConstants.RECTYPE_7k;
        return installation;        
    }
    
    private static testmethod  void sellingActivityMarketTriggerRelocation7kTest(){
        
        installation=createTestData();
        
        //Create Selling Activity Market
        sellingActivityMarket=new Selling_Activity_Market__c();
        sellingActivityMarket.name='7k test';
        sellingActivityMarket.Dispenser_Model__c=FSConstants.RECTYPE_7k;
        sellingActivityMarket.Market_Activation_Date__c=system.today(); 
        insert sellingActivityMarket;        
        
        //link Selling Activity Market to SP Aligned Zip
        final List<FS_SP_Aligned_Zip__c> spAlignesZip7000=[SELECT Id,FS_Selling_Activity_Market__c FROM FS_SP_Aligned_Zip__c where FS_Platform_Type__c='7000' limit 1];
        for(FS_SP_Aligned_Zip__c spAligned : spAlignesZip7000){
            spAligned.FS_Selling_Activity_Market__c=sellingActivityMarket.Id;
            
        }
        update spAlignesZip7000;
        
        //Create Installation
        installation.Type_of_Dispenser_Platform__c=FSConstants.RECTYPE_7k;
        insert installation;
        
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            //update selling market
            sellingActivityMarket.Market_Activation_Date__c=sellingActivityMarket.Market_Activation_Date__c.addDays(2);
            update sellingActivityMarket;
        }
        test.stopTest(); 
        system.assertEquals(system.today().addDays(2), sellingActivityMarket.Market_Activation_Date__c);
    }
    
    private static testMethod void testMethod1() {
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        //Create Selling Activity Market
        final Selling_Activity_Market__c sellingActivityMarketnew= new Selling_Activity_Market__c();         
        sellingActivityMarketnew.name='7k test';
        sellingActivityMarketnew.Dispenser_Model__c=FSConstants.RECTYPE_7k;
        sellingActivityMarketnew.Market_Activation_Date__c=system.today(); 
        insert sellingActivityMarketnew; 
        
        //link Selling Activity Market to SP Aligned Zip
        final List<FS_SP_Aligned_Zip__c> spAlignesZip7000=[SELECT Id,FS_Selling_Activity_Market__c FROM FS_SP_Aligned_Zip__c where FS_Platform_Type__c='7000' limit 1];
        for(FS_SP_Aligned_Zip__c spAligned : spAlignesZip7000){
            spAligned.FS_Selling_Activity_Market__c=sellingActivityMarketnew.Id;
        }
        update spAlignesZip7000;  
         
        //update selling market
        sellingActivityMarketnew.Market_Activation_Date__c=sellingActivityMarketnew.Market_Activation_Date__c.addDays(2);
        update sellingActivityMarketnew;   
        system.assertEquals(system.today().addDays(2), sellingActivityMarketnew.Market_Activation_Date__c);
        string query7k='';
        query7k = 'SELECT ID,FS_Mrkt_ActiveDate1__c,FS_Mrkt_ActiveDate2__c,FS_Mrkt_ActiveDate3__c,Type_of_Dispenser_Platform__c,FS_Market_Text__c,Overall_Status2__c,FS_Install_Date_Validation_Bypass_Check__c FROM FS_Installation__c LIMIT 50'; 	
        final Set<String> MarketNameSetk7=new Set<String>();
        final Map<String,Date> SellingActivityMrktMapk7=new Map<String,Date>();  
        
        SellingActivityMrktMapk7.put(sellingActivityMarketnew.name,sellingActivityMarketnew.Market_Activation_Date__c);
        MarketNameSetk7.add(sellingActivityMarketnew.name);
        
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        outletAccRelocation=FSTestUtil.createAccountOutlet('Test Outlet1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,true);
        outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);
        outletAcc.ShippingStreet='7700 N MACARTHUR BLVD';
        outletAcc.ShippingCity='IRVING';
        outletAcc.ShippingState='TX';
        outletAcc.ShippingPostalCode='75063-7514';
        outletAcc.ShippingCountry='US';
        insert outletAcc;
        
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, true);
        
        final List<FS_Installation__c>  installationnew = new List<FS_Installation__c>();          
        installation= FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        installation.Type_of_Dispenser_Platform__c=FSConstants.RECTYPE_7k;
        installation.FS_Mrkt_ActiveDate1__c = system.today();
        
        installationnew.add(installation); 
        installation= FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        installation.Type_of_Dispenser_Platform__c='8000'; 
        installation.FS_Mrkt_ActiveDate2__c = system.today();
        
        installationnew.add(installation);  
        installation= FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        installation.Type_of_Dispenser_Platform__c='9100';
        installation.FS_Mrkt_ActiveDate3__c = system.today();  
         //FET 7.0 FNF-823
        installationnew.add(installation); 
        insert installationnew;
         //FET 7.0 FNF-823
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FSBatchUpdateActivationDTInstall testbatch= new FSBatchUpdateActivationDTInstall(query7k,MarketNameSetk7,SellingActivityMrktMapk7);         
            testbatch.execute(null,installationnew);
        }
        Test.stopTest();
    }  
}