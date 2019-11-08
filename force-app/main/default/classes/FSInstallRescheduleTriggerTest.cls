/*****************************
Name         : FSInstallRescheduleTriggerTest
Created By   : Infosys
Created Date : 19/03/2018
Usage        : Test class for installation Reschedule object Trigger handler.
*****************************/
@isTest
private class FSInstallRescheduleTriggerTest {
    private static FS_Installation__c installationNew;
    private static FS_Installation__c RelocationIP;
    private static void createData(){     
        
        final List<Account> insertAccounts = new List<Account>();
        //create HQ record        
        final Account accHQ=new Account(Name = 'Test Headquarters',RecordTypeId = FSConstants.RECORD_TYPE_HQ);        
        insertAccounts.add(accHQ);
        //create Outlet record  
        final Account accOutlet=new Account(Name = 'Test Outlet',RecordTypeId = FSConstants.RECORD_TYPE_OUTLET,FS_Headquarters__c= accHQ.Id);        
        accOutlet.ShippingPostalCode='1234';
        insertAccounts.add(accOutlet);        
        insert insertAccounts;
        
        Selling_Activity_Market__c sellingMarket=new Selling_Activity_Market__c();
        sellingMarket.Name='testData';
        sellingMarket.Market_Activation_Date__c=System.today()-30;
        insert sellingMarket;
        
        final List<FS_SP_Aligned_Zip__c> spAlignedList=new List<FS_SP_Aligned_Zip__c>();
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=accOutlet.ShippingPostalCode,FS_Platform_Type__c='7000',FS_Selling_Activity_Market__c=sellingMarket.id));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=accOutlet.ShippingPostalCode,FS_Platform_Type__c='8000',FS_Selling_Activity_Market__c=sellingMarket.id ));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=accOutlet.ShippingPostalCode,FS_Platform_Type__c='9000',FS_Selling_Activity_Market__c=sellingMarket.id));
        spAlignedList.add(new FS_SP_Aligned_Zip__c(FS_Zip_Code__c=accOutlet.ShippingPostalCode,FS_Platform_Type__c='9100',FS_Selling_Activity_Market__c=sellingMarket.id));
        insert spAlignedList;
        
        //create Brandset records
        final List<FS_Brandset__c> brandsetRecordList=FSTestFactory.createTestBrandset();  
        //Separate Brandset based on platform 
        final List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecordList){
            if(branset.FS_Platform__c.contains('7000')){
                branset7000List.add(branset);
            }
            if(branset.FS_Platform__c.contains('8000')){
                branset8000List.add(branset);
            }           
            if(branset.FS_Platform__c.contains('9000')) {
                branset9000List.add(branset);
            }
        }
        //create EP record  
        final FS_Execution_Plan__c executionPlan = new FS_Execution_Plan__c(FS_Headquarters__c = accHQ.Id,FS_Platform_Type__c='7000;8000');
        executionPlan.recordTypeId=Schema.SObjectType.FS_Execution_Plan__c.getRecordTypeInfosByName().get(FSConstants.EXECUTIONPLAN).getRecordTypeId();
        insert executionPlan;
        
        final List<FS_Installation__c> ipInsert = new List<FS_Installation__c>();
        
        FSTestFactory.createTestDisableTriggerSetting();
        //create New Install record
        installationNew = new FS_Installation__c(FS_Execution_Plan__c = executionPlan.Id,FS_Outlet__c = accOutlet.Id);        
        installationNew.recordtypeid=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(FSConstants.NEWINSTALLATION).getRecordTypeId();
        installationNew.Type_of_Dispenser_Platform__c='8000';
        installationNew.FS_Original_Install_Date__c=system.today()+30;
		installationNew.FS_Rush_Install_Reason__c='Remodel';      
        installationNew.FS_Pending_for_Reschedule__c=true;
        installationNew.FS_Scheduled_Install_Date__c=Date.today();
        installationNew.FS_SA_Scheduled_On_Date__c=Date.today();
        installationNew.FS_SA_Completed_Date__c=Date.today();
        ipInsert.add(installationNew);
        
        //create RI4W Installation
        RelocationIP = new FS_Installation__c(FS_Execution_Plan__c = executionPlan.Id,FS_Outlet__c = accOutlet.Id);        
        RelocationIP.recordtypeid=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Relocation_I4W_Rec_Type).getRecordTypeId();
        RelocationIP.FS_Relocation_from_old_outlet_to_SP_is__c=FSConstants.BOOL_VAL;
        RelocationIP.FS_Disconnect_Final_Date__c=Date.today().addDays(1);
        RelocationIP.Type_of_Dispenser_Platform__c='8000';
        ipInsert.add(RelocationIP);
        
        insert ipInsert;

        final List<FS_Association_Brandset__c> abList=[select id,name,FS_Brandset__c,FS_Platform__c,FS_NonBranded_Water__c,FS_Installation__c from FS_Association_Brandset__c where FS_Installation__c=:installationNew.Id];
        for(FS_Association_Brandset__c abRec:abList){
            if(abRec.FS_Platform__c=='8000' &&  !branset8000List.isEmpty() ){
                abRec.FS_Brandset__c=branset8000List[0].Id;
            }
            abRec.FS_NonBranded_Water__c='Hide';
        }
        update abList;
    }
    
    private static testMethod void testInstallReschedule(){
        createData(); 
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        Test.startTest();
        system.runAs(adminUser){
            
            final List<FS_Installation_Reschedule__c> installResch=new List<FS_Installation_Reschedule__c>();
            final FS_Installation_Reschedule__c installReschedule=new FS_Installation_Reschedule__c();
			installReschedule.FS_Reschedule_Install_Date__c=system.today();
            installReschedule.FS_Reason_for_Reschedule__c ='Construction Incomplete';
            installReschedule.FS_Rush_Install_Reason__c='Remodel';
            installReschedule.FS_Installation__c=installationNew.Id;
			installResch.add(installReschedule);
            
            final FS_Installation_Reschedule__c installReschedule1=new FS_Installation_Reschedule__c();
			installReschedule1.FS_Pending_for_Reschedule__c=true;
            installReschedule1.FS_Reason_for_Reschedule__c ='Construction Incomplete';            
            installReschedule1.FS_Installation__c=installationNew.Id;
            installResch.add(installReschedule1);
            
            insert installResch;
            
            final FS_Installation_Reschedule__c installReschedule2=new FS_Installation_Reschedule__c();
            installReschedule2.FS_Reschedule_Install_Date__c=system.today();
            installReschedule2.FS_Reason_for_Reschedule__c ='Construction Incomplete';            
            installReschedule2.FS_Installation__c=RelocationIP.Id;
            try{
                insert installReschedule2;
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('date later than the last Remove/Disconnect') ? true : false;
            	system.assertEquals(expectedExceptionThrown,true);      
            }
                        
        }
        Test.stopTest();
    }
    
}