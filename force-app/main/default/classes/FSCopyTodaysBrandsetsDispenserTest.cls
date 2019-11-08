/**************************************************************************************
Apex Class Name     : FSCopyTodaysBrandsetsDispenserTest
Version             : 1.0
Function            : This test class is for  FSCopyTodaysBrandsetsDispenser Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             04/24/2017          Original Version 
*                     05/29/2018          Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private  class FSCopyTodaysBrandsetsDispenserTest{
    private static final String SERIES7000 ='7000 Series';   
    private static final String SERIES8000 ='8000 Series'; 

    private static final String SERIES8000N9000 ='8000 & 9000 Series';
    
    private static final String NUM7000 ='7000'; 
    private static final String NUM8000 ='8000';
    private static final String NUM9000 ='9000'; 
    private static final String CUSTOMFIELDEQUIPTYPE='FS_Equip_Type__c';
    private static final String CUSTOMFIELDPLATFORM ='FS_Platform__c';
    private static List<FS_Brandset__c> brandset7000List;
    private static List<FS_Brandset__c> brandset8000List;
    private static List<FS_Brandset__c> brandset9000List;
    private static List<FS_Outlet_Dispenser__c> dispenserToUpdate;
    
    
    @testSetup
    public static void loadTestData(){              
        //create Brandset records
        FSTestFactory.createTestBrandset();
        
         /** @desc this method creates 1 chain,1 HQ, 1 Outlet,1 Execution Pan(Execution Plan),
      * 4 Installation('7000 Series','8000 & 9000 Series','8000 Series','9000 Series')*/
       //Create Single HeadQuarter
        final List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                                     FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        
        //Create Single Outlet
        final List<Account> outletCustomerList=new List<Account>();
        for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'))){
            acc.FS_Headquarters__c=headQuarterCustomerList.get(0).Id;
            outletCustomerList.add(acc);
        }
        insert outletCustomerList;
        
        //Create Execution Plan
        //Collection to hold all recordtype names of Execution plan                                                                       
        final Set<String> executionPlanRecordTypesSet=new Set<String>{fsconstants.EXECUTIONPLAN};
            //Collection to hold all recordtype values of Execution plan
            final Map<Id,String> executionPlanRecordTypesMap=new Map<Id,String>();
        
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
        //Create One executionPlan records for each record type
        for(String epRecType : executionPlanRecordTypesSet){            
            final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,epRecType);            
            executionPlanRecordTypesMap.put(epRecordTypeId,epRecType);            
            final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(headQuarterCustomerList.get(0).Id,false,1,epRecordTypeId);
            executionPlanList.addAll(epList);                                                                     
        }                       
        insert executionPlanList;       
        //Create Installation
        final Set<String> installationPlanRecordTypesSet=new Set<String>{fsconstants.NEWINSTALLATION}; 
            final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >();         
        //Create Installation for each Execution Plan according to recordtype        
        for(String  installationRecordType : installationPlanRecordTypesSet){
            final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,installationRecordType); 
            final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
            installationPlanList.addAll(installList);
        }         
        insert installationPlanList;  
        //Create custom setting data
        List<Platform_Type_ctrl__c> listplatform = FSTestFactory.lstPlatform();
        List<ProfileListFromCustomSettings__c>  lstOfProfiles = FSTestFactory.lstProfiles();
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
        
        
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        
        //Create Outlet Dispensers 
        for(FS_Installation__c installPlan : [SELECT Id,RecordTypeId,FS_Outlet__c,Type_of_Dispenser_Platform__c FROM FS_Installation__c  limit 100]){
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId =FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
            
            if(installPlan.Type_of_Dispenser_Platform__c.contains(SERIES7000) ){
                
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'');
                odList[0].put(CUSTOMFIELDEQUIPTYPE, SERIES7000);
            }
            
            if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM8000) ){
                
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'');
                odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM8000);
                
            }
            if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM9000) ){
                
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'');
                odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM9000);
            }
            outletDispenserList.addAll(odList);
            
        }
        //create trigger switch --custom setting
        FSTestFactory.createTestDisableTriggerSetting();
        test.startTest();
        insert outletDispenserList;
        test.stopTest();
    }
    
    private static testMethod void testDispenserWithoutAssociationBrandset(){
        //create HTTP mock to handle runtime HTTP request from FETNMS Connector
        try{
            Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
            //FSFETNMSConnector.airWatchSynchronousCall(lstOutletDispensersID,NULL);
        }catch(Exception ex){
            System.debug('Exception- '+ex);
        }
        FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
        
        //Separate Brandset based on platform 
        final List<FS_Brandset__c> brandset7000List=new List<FS_Brandset__c>();
        brandset8000List=new List<FS_Brandset__c>();
        brandset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c brandset: [SELECT Id,FS_Platform__c FROM FS_Brandset__c LIMIT 100]){
            if(brandset.FS_Platform__c.contains(NUM7000)){
                brandset7000List.add(brandset);
            } 
            if(brandset.FS_Platform__c.contains(NUM8000)){
                brandset8000List.add(brandset);
            } 
            if(brandset.FS_Platform__c.contains(NUM9000)) {
                brandset9000List.add(brandset);
            }
            
        }

        dispenserToUpdate=[SELECT Id,Name,FS_Equip_Type__c,FS_Brandset_New__c,FS_Brandset_Effective_Date__c FROM FS_Outlet_Dispenser__c LIMIT 200];

        for(FS_Outlet_Dispenser__c dispenser : dispenserToUpdate){
            if(dispenser.FS_Equip_Type__c==NUM7000){

                dispenser.FS_Brandset_New__c=brandset7000List.get(0).Id;
                dispenser.FS_Brandset_Effective_Date__c =System.today();
            }
            if(dispenser.FS_Equip_Type__c==NUM8000){

                dispenser.FS_Brandset_New__c=brandset8000List.get(0).Id;
                dispenser.FS_Brandset_Effective_Date__c =System.today();
            }
            if(dispenser.FS_Equip_Type__c==NUM9000){
                dispenser.FS_Brandset_New__c=brandset9000List.get(0).Id;
                dispenser.FS_Brandset_Effective_Date__c =System.today();
            }
        }
        Test.startTest();
        UPDATE dispenserToUpdate;
        
        Test.stopTest();
        
        //verify values were copied
        for(FS_Outlet_Dispenser__c dispenser :  [SELECT Id,FS_Brandset_New__c,FS_Brandset_Effective_Date__c  FROM FS_Outlet_Dispenser__c  LIMIT 200]){
            system.assert(dispenser.FS_Brandset_New__c!=NULL);
            system.assert(dispenser.FS_Brandset_Effective_Date__c !=NULL);
        }
    }
    
    private static testMethod void testDispenserWithAssociationBrandset(){
        //Separate Brandset based on platform 
        brandset7000List=new List<FS_Brandset__c>();
        brandset8000List=new List<FS_Brandset__c>();
        brandset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c brandset: [SELECT Id,FS_Platform__c FROM FS_Brandset__c LIMIT 100]){
            if(brandset.FS_Platform__c.contains(NUM7000)){
                brandset7000List.add(brandset);
            } 
            if(brandset.FS_Platform__c.contains(NUM8000)){
                brandset8000List.add(brandset);
            } 
            if(brandset.FS_Platform__c.contains(NUM9000)) {
                brandset9000List.add(brandset);
            }
        }
        
        dispenserToUpdate=[SELECT Id,Name,FS_Equip_Type__c,FS_Brandset_New__c,FS_Brandset_Effective_Date__c FROM FS_Outlet_Dispenser__c LIMIT 200];
        final List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
        
        for(FS_Outlet_Dispenser__c dispenser : dispenserToUpdate){
            List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
            if(dispenser.FS_Equip_Type__c==NUM7000){
                final List<FS_Brandset__c > bransetOtherthanAssociatedToDispenser=new List<FS_Brandset__c>{brandset7000List[1]};
                associationList=FSTestFactory.createTestAssociationBrandset(false,bransetOtherthanAssociatedToDispenser,'FS_Outlet_Dispenser__c',dispenser.Id,1);
                associationList[0].put(CUSTOMFIELDPLATFORM , NUM7000);
                associationBrandsetList.addAll(associationList);
                
                dispenser.FS_Brandset_New__c=brandset7000List.get(0).Id;
                dispenser.FS_Brandset_Effective_Date__c =System.today();
            }
            if(dispenser.FS_Equip_Type__c==NUM8000){
                final List<FS_Brandset__c > bransetOtherthanAssociatedToDispenser=new List<FS_Brandset__c>{brandset8000List[1]};
                    associationList=FSTestFactory.createTestAssociationBrandset(false,bransetOtherthanAssociatedToDispenser,'FS_Outlet_Dispenser__c',dispenser.Id,1);
                associationList[0].put(CUSTOMFIELDPLATFORM , NUM8000);
                associationBrandsetList.addAll(associationList);
                
                dispenser.FS_Brandset_New__c=brandset8000List.get(0).Id;
                dispenser.FS_Brandset_Effective_Date__c =System.today();
            }
            if(dispenser.FS_Equip_Type__c==NUM9000){
                final List<FS_Brandset__c > bransetOtherthanAssociatedToDispenser=new List<FS_Brandset__c>{brandset9000List[1]};
                    associationList=FSTestFactory.createTestAssociationBrandset(false,bransetOtherthanAssociatedToDispenser,'FS_Outlet_Dispenser__c',dispenser.Id,1);
                associationList[0].put(CUSTOMFIELDPLATFORM, NUM9000);
                associationBrandsetList.addAll(associationList);
                
                dispenser.FS_Brandset_New__c=brandset9000List.get(0).Id;
                dispenser.FS_Brandset_Effective_Date__c =System.today();
            }
        }
        
        INSERT associationBrandsetList;
        system.assert([select id from FS_Association_Brandset__c]!=null);
        final User sysAdminUser=FSTestUtil.createUser(null,1,FSConstants.USER_POFILE_SYSADMIN,true);
        system.runAs(sysAdminUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
            UPDATE dispenserToUpdate;
            
            Test.stopTest();
            for(FS_Outlet_Dispenser__c dispenser :  [SELECT Id,FS_Brandset_New__c,FS_Brandset_Effective_Date__c  FROM FS_Outlet_Dispenser__c  LIMIT 200]){
            system.assert(dispenser.FS_Brandset_New__c!=NULL);
            system.assert(dispenser.FS_Brandset_Effective_Date__c !=NULL);
        }
        }
    } 
}