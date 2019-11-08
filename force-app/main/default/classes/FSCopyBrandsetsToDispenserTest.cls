/**************************************************************************************
Apex Class Name     : FSCopyBrandsetsToDispenserTest
Version             : 1.0
Function            : This test class is for  FSCopyBrandsetsToDispenser Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             11/01/2017          Original Version 
*                     05/29/2018          Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
************************************************************************************/
@isTest
private class FSCopyBrandsetsToDispenserTest{
    
    private static String sevenK='7000';
    private static String eightK='8000';
    private static String nineK='9000';    
    private static String equipType='FS_Equip_Type__c';    
    private static String platform='FS_Platform__c';
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    @testSetup
    private static void loadTestData(){
       
        //Platform types custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        //set Mock callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
               
        //create Brandset records
        final List<FS_Brandset__c> brandsetRecordList=FSTestFactory.createTestBrandset();
                
        //creates 1 chain,1 HQ, 1 Outlet,1 Execution Pan('7000 Series'),
        //4 Installation('7000 Series','8000 & 9000 Series','8000 Series','9000 Series') 
        FSTestFactory.createCommonTestInstallationRecords();
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
        
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        
        //Create Outlet Dispensers 
        for(FS_Installation__c installPlan : [SELECT Id,RecordTypeId,FS_Outlet__c FROM FS_Installation__c  limit 1]){
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId;
            
            if(installationRecordTypeIdAndName.get(installPlan.RecordTypeId)==FSConstants.NEWINSTALLATION){
                outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Label.CCNA_Disp_Record_type);
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
                odList[0].put(equipType, sevenK);
            }
            
            outletDispenserList.addAll(odList);
            
        }   
        
        insert outletDispenserList;        
        
        
        
        final Map<Id,String> outletDispenserRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Outlet_Dispenser__c.SObjectType);
        final List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
        
           //Create Association Brandset Records for OutletDispenser
        for(FS_Outlet_Dispenser__c createdDispenser: outletDispenserList){
            List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
            
            if(outletDispenserRecordTypeIdAndName.get(createdDispenser.RecordTypeId)==Label.CCNA_Disp_Record_type) {
                final List<FS_Brandset__c > bransetOtherthanAssociatedToDispenser=new List<FS_Brandset__c>{branset7000List[1]};
                associationList=FSTestFactory.createTestAssociationBrandset(false,bransetOtherthanAssociatedToDispenser,'FS_Outlet_Dispenser__c',createdDispenser.Id,1);
                associationList[0].put(platform, sevenK);
                associationBrandsetList.addAll(associationList);
            }

        }        
        insert associationBrandsetList;  
        final List<FS_Association_Brandset__c > associationBrandsetListNew =new List<FS_Association_Brandset__c >();
        For(FS_Association_Brandset__c AB : associationBrandsetList){
            AB.FS_Brandset__c = branset7000List.get(0).Id;
            associationBrandsetListNew.add(AB);
        }
       update  associationBrandsetListNew;
       FSTestFactory.createTestDisableTriggerSetting();
    }
    
    private static testMethod void testBatchClass(){
        
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            
            Database.executeBatch(new FSCopyBrandsetsToDispenser());
          
        }
        Test.stopTest();
        
    }
    
    private static testMethod void testScheduledBatchClass(){
        Test.startTest();   
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            String sch1 = '0 0 23 * * ?'; System.schedule('New1', sch1, new FSScheduleCopyBrandsetsToDispenser()); 
           
            
            
            //Verify That batch class invoked after scheduled
            final AsyncApexJob batchJob=[SELECT ApexClassId,Id,JobType FROM AsyncApexJob  where JobType = 'ScheduledApex' limit 1];
    
            system.assertEquals(batchJob.ApexClassId,[SELECT Id FROM ApexClass WHERE Name='FSScheduleCopyBrandsetsToDispenser'].Id);
        }
        Test.stopTest();
    }
}