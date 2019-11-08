/**************************************************************************************
Apex Class Name     : FSCopyTodaysBrandsetsTest
Version             : 1.0
Function            : This test class is for  FSCopyTodaysBrandsets Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             11/01/2017	      Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/

@isTest
private class FSCopyTodaysBrandsetsTest{
    
    private static String sevenK='7000';
    private static String eightK='8000';
    private static String nineK='9000';
    private static String sevenKSeries='7000 Series';
    private static String eightKSeries='8000 Series';
    private static String nineKSeries='9000 Series';
    private static String series8K9K='8000 & 9000 Series';
    private static String equipType='FS_Equip_Type__c';
    private static String newBrandset='FS_Brandset_New__c';
    private static String brandEffectDate='FS_Brandset_Effective_Date__c';
    private static string waterEffectiveDate='FS_showHideWater_Effective_date__c';
    private static String platform='FS_Platform__c';
    private static String nonBrandedWater='FS_NonBranded_Water__c';

    @testSetup
    private static void loadTestData(){
        
        //create trigger switch --custom setting
        FSTestFactory.createTestDisableTriggerSetting();
        
        //disable FSInstallationBusinessProcess trigger
		Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSInstallationBusinessProcess');
        disableTriggerSetting.IsActive__c = false;
        update disableTriggerSetting;
        
        Disable_Trigger__c disableTriggerSetting1 = new Disable_Trigger__c();
        disableTriggerSetting1.Name='FSODBusinessProcess';
        disableTriggerSetting1.IsActive__c=false;
        insert disableTriggerSetting1;
        
        //create Brandset records
        final List<FS_Brandset__c> brandsetRecordList=FSTestFactory.createTestBrandset();
        
        system.debug('#Queries before create common test data '+Limits.getQueries());
        //creates 1 chain,1 HQ, 1 Outlet,4 Execution Pan('7000 Series','8000 & 9000 Series','8000 Series','9000 Series'),
        //4 Installation('7000 Series','8000 & 9000 Series','8000 Series','9000 Series') 
        FSTestFactory.createCommonTestRecords();
        system.debug('#Queries after create common test data '+Limits.getQueries());
        
        final Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
        
        //Separate Brandset based on platform 
        final List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecordList){
            if(branset.FS_Platform__c.contains(sevenK)) 
            {
                branset7000List.add(branset);
            }
            if(branset.FS_Platform__c.contains(eightK)){
                branset8000List.add(branset);
            }
            if(branset.FS_Platform__c.contains(nineK)){
                branset9000List.add(branset);
            }
        }
        system.assert(!branset7000List.isEmpty());   
        system.assert(!branset8000List.isEmpty());   
        system.assert(!branset9000List.isEmpty());   
        
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        
        system.debug('#Queries before create OD '+Limits.getQueries());
        
        //Create Outlet Dispensers 
        for(FS_Installation__c installPlan : [SELECT Id,RecordTypeId,FS_Outlet__c FROM FS_Installation__c  limit 4]){
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId;
            
            if(installationRecordTypeIdAndName.get(installPlan.RecordTypeId)==FSConstants.NEWINSTALLATION){
                outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Label.CCNA_Disp_Record_type);
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
                odList[0].put(equipType, sevenK);
                odList[0].put(newBrandset, branset7000List[0].Id); 
                odList[0].put(brandEffectDate, System.today());
                odList[0].put('FS_Hide_Water_Dispenser_New__c', 'Show');
                odList[0].put(waterEffectiveDate, System.today());
            }
            outletDispenserList.addAll(odList);
            
        }   
        
        insert outletDispenserList;
        system.debug('@@@ OD INsert'+outletDispenserList);
        system.debug('#Queries after create '+outletDispenserList.size()+' ODs '+Limits.getQueries());

                final Map<Id,String> outletDispenserRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Outlet_Dispenser__c.SObjectType);
        final List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
        
        //Create Association Brandset Records for OutletDispenser
        for(FS_Outlet_Dispenser__c createdDispenser: outletDispenserList){
            List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
            
            if(outletDispenserRecordTypeIdAndName.get(createdDispenser.RecordTypeId)==Label.CCNA_Disp_Record_type) {
                final List<FS_Brandset__c > bransetOtherthanAssociatedToDispenser=new List<FS_Brandset__c>{branset7000List[1]};
                associationList=FSTestFactory.createTestAssociationBrandset(false,bransetOtherthanAssociatedToDispenser,'FS_Outlet_Dispenser__c',createdDispenser.Id,1);
                associationList[0].put(platform, sevenK);
                associationList[0].put(nonBrandedWater, 'Hide');
                associationBrandsetList.addAll(associationList);
            }
        }
        
        insert associationBrandsetList;
        system.debug('@@@ AB Insert'+associationBrandsetList);
    }
    
    
    private static testMethod void testBatchClass(){
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
       	Date datetoday=System.today();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        system.debug('User DATE ###'+system.today());
        system.runAs(sysAdminUser){
            Database.executeBatch(new FSCopyTodaysBrandsets(system.today()));
            system.debug('ADMIN DATE ###'+system.today());
        }
        
    }
    
    private static testMethod void testScheduledBatchClass(){
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        system.runAs(sysAdminUser){
            Test.startTest();
            final String cronExp = '0 0 23 * * ?';
            System.schedule('Call Scheduled FSCopyTodaysBrandsets', cronExp, new FSScheduleCopyTodaysBrandsets());
            Test.stopTest();
            
        }
        
        //Verify That batch class invoked after scheduled
        final AsyncApexJob batchJob=[SELECT ApexClassId,Id,JobType FROM AsyncApexJob WHERE JobType='BatchApex' limit 1];
        system.assertEquals(batchJob.ApexClassId,[SELECT Id FROM ApexClass WHERE Name='FSCopyTodaysBrandsets'].Id);
        
    }
}