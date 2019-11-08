/**************************************************************************************
Apex Class Name     : FSOutletDispenserProcessBuilderTest
Version             : 1.0
Function            : This test class is for  FSOutletDispenserProcessBuilder Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSOutletDispenserProcessBuilderTest{
    
    private static String sevenK='7000';
    private static String eightK='8000';
    private static String nineK='9000';    
    private static String installObj='FS_Installation__c';
    private static String platform1='FS_Platform__c';
    private static String equipType='FS_Equip_Type__c';    
    public static FS_Installation__C install;
    
    @testSetup
    private static void loadTestData(){

        //create Brandset records
        final List<FS_Brandset__c> brandsetRecorList=FSTestFactory.createTestBrandset();
        
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
        
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
        
        final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,FSConstants.EXECUTIONPLAN);  
        
        final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(headQuarterCustomerList.get(0).Id,false,1,epRecordTypeId);
        
        executionPlanList.addAll(epList);                                                                                 
        
        insert executionPlanList;      
        
        //Create Installation
        final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >(); 
        final Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
        //Create 50  Installation for each Execution Plan according to recordtype
        
        for(FS_Execution_Plan__c executionPlan : executionPlanList){
            final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,FSConstants.NEWINSTALLATION); 
            final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlan.Id,outletCustomerList.get(0).Id,false,2,intallationRecordTypeId);
            installationPlanList.addAll(installList);
        } 
        install=new Fs_Installation__C(FS_Execution_Plan__c=executionPlanList[0].id,FS_Outlet__C=outletCustomerList.get(0).Id);
        install.Overall_Status2__c=FSConstants.x4InstallSchedule;
        installationPlanList.add(install) ;
        
        insert installationPlanList;       
        
        //Separate Brandset based on platform 
        final List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecorList){
            if(branset.FS_Platform__c.contains(sevenK)){
                branset7000List.add(branset);
            }
            if(branset.FS_Platform__c.contains(eightK)){
                branset8000List.add(branset);
            }
            if(branset.FS_Platform__c.contains(nineK)){
                branset9000List.add(branset);
            }
        }
        
        //Create Association Brandset
        final List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
        //create association 10 brandset records for each installation 
        for(FS_Installation__c installPlan: installationPlanList){
            List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
            
            associationList=FSTestFactory.createTestAssociationBrandset(false,branset7000List,installObj,installPlan.Id,branset7000List.size());
            for(Integer i=0;i<associationList.size();i++){
                associationList[1].put(platform1, sevenK);
            }
            associationBrandsetList.addAll(associationList);           
            associationList=FSTestFactory.createTestAssociationBrandset(false,branset8000List,installObj,installPlan.Id,branset8000List.size());
            for(Integer i=0;i<associationList.size();i++){
                associationList[1].put(platform1, eightK);
            }
            associationBrandsetList.addAll(associationList);
            
            
            associationList=FSTestFactory.createTestAssociationBrandset(false,branset8000List,installObj,installPlan.Id,branset8000List.size());
            for(Integer i=0;i<associationList.size();i++){
                associationList[1].put(platform1, eightK);
            }
            associationBrandsetList.addAll(associationList);
            
            
            associationList=FSTestFactory.createTestAssociationBrandset(false,branset9000List,installObj,installPlan.Id,branset9000List.size());
            for(Integer i=0;i<associationList.size();i++){
                associationList[1].put(platform1, nineK);
            }
            associationBrandsetList.addAll(associationList);
            
        }        
        insert associationBrandsetList;        
    }
    
    
    private static testMethod void testCreateOutletDispenser(){
        
        FSTestFactory.createTestDisableTriggerSetting();
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        FSTestFactory.lstPlatform(); 
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        //Create Outlet Dispensers 
        for(FS_Installation__c installPlan : [SELECT Id,RecordTypeId,FS_Outlet__c FROM FS_Installation__c  limit 200]){
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId;
            outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Label.CCNA_Disp_Record_type);
            odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
            odList[0].put(equipType, sevenK);
            outletDispenserList.addAll(odList);
                       
        }   
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        	Test.startTest();
        	system.runAs(sysAdminUser){            
            insert outletDispenserList;
            Test.stopTest();
        }        
    }
    
   private static testMethod void testUpdateOutletDispenser(){
        
        FSTestFactory.createTestDisableTriggerSetting();
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        FSTestFactory.lstPlatform(); 
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
       	
        //Create Outlet Dispensers 
        for(FS_Installation__c installPlan : [SELECT Id,RecordTypeId,FS_Outlet__c FROM FS_Installation__c  limit 200]){
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId;
            outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Label.CCNA_Disp_Record_type);
            odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
            odList[0].put(equipType, sevenK);
            outletDispenserList.addAll(odList);
                       
        }   
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        test.startTest();
        List<FS_Installation__c> instnewlist=[select id,name from FS_Installation__c limit 1];
        	system.runAs(sysAdminUser){            
            insert outletDispenserList;
                for(FS_Outlet_Dispenser__c od:outletDispenserList){
                    od.Installation__C=instnewlist[0].id;
                }    
           
                update outletDispenserList;
            test.stopTest();
        }        
    }
    
}