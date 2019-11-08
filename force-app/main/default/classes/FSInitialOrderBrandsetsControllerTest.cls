/**************************************************************************
 Name         : FSInitialOrderBrandsetsController
 Created By   : Lavanya Valluru 
 Description  : Test class of FSInitialOrderBrandsetsController
 Created Date : Jan 18, 2017         
***************************************************************************/
@isTest
private class FSInitialOrderBrandsetsControllerTest {
     private static final String SERIES7000 = '7000 Series'; 
     private static final String FSINSTALLATION = 'FS_Installation__c';
     private static final String FSPLATFORM = 'FS_Platform__c';
     private static final String SERIES8000AND9000 = '8000 & 9000 Series';
     private static final String SERIES8000 = '8000 Series'; 
     private static final String SERIES9000 = '9000 Series'; 
     private static final String NUM7000 ='7000'; 
   	 private static final String NUM8000 ='8000';
     private static final String NUM9000 ='9000'; 	
    
     @testSetup
     private static void loadTestData(){
     
         //Custom Setting for Trigger switch
         FSTestFactory.createTestDisableTriggerSetting();
         
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
         
         //Create Execution Plan
         //Collection to hold all recordtype names of Execution plan                                                                       
         final Set<String> executionPlanRecordTypesSet=new Set<String>{FsConstants.EXECUTIONPLAN};
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
         //Verify that four Execution Plan got created
         system.assertEquals(1,executionPlanList.size());         
         Test.startTest();
         
         insert executionPlanList;
         
         //Create Installation
         final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >(); 
         final Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
         //Create Installation for each Execution Plan according to recordtype
         
         for(FS_Execution_Plan__c executionPlan : executionPlanList){
             Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,fsconstants.NEWINSTALLATION);
             final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlan.Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
             installationPlanList.addAll(installList);
         } 
         insert installationPlanList;  
         //Verify that Installation Plan got created
         system.assertEquals(1,installationPlanList.size()); 
         
         
         //Separate Brandset based on platform 
         final List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
         final List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
         final List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
         
         for(FS_Brandset__c branset :brandsetRecorList){
             if(branset.FS_Platform__c.contains('7000')) {branset7000List.add(branset);}
             if(branset.FS_Platform__c.contains('8000')) {branset8000List.add(branset);}
             if(branset.FS_Platform__c.contains('9000')) {branset9000List.add(branset);}
         }
         
       //Create Association Brandset
       final List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
       //create association 10 brandset records for each installation 
         for(FS_Installation__c installPlan: installationPlanList){
             List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
             
             if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM7000)){
                 associationList=FSTestFactory.createTestAssociationBrandset(false,branset7000List,FSINSTALLATION,installPlan.Id,1);
                 for(Integer i=0;i<associationList.size();i++){
                     associationList[0].put(FSPLATFORM, NUM7000);
                 }
                 associationBrandsetList.addAll(associationList);
             }
             if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM8000)){
                 associationList=FSTestFactory.createTestAssociationBrandset(false,branset8000List,FSINSTALLATION,installPlan.Id,1);
                 for(Integer i=0;i<associationList.size();i++){
                     associationList[0].put(FSPLATFORM, NUM8000);
                 }
                 associationBrandsetList.addAll(associationList);
             }
             if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM9000)){
                 associationList=FSTestFactory.createTestAssociationBrandset(false,branset9000List,FSINSTALLATION,installPlan.Id,1);
                 for(Integer i=0;i<associationList.size();i++){
                     associationList[0].put(FSPLATFORM, NUM9000);
                 }
                 associationBrandsetList.addAll(associationList);
             }
         }
       
       insert associationBrandsetList;
       //Verify that association Brandset got created
        Test.stopTest();
       system.assert(!associationBrandsetList.isEmpty()); 
       
       /************************************************************/
       //create Initial Order for Installation
       final List<FS_Initial_Order__c> initialOrderCreateList =new List<FS_Initial_Order__c>();
       
       final Id initialOrderRecordType=FSUtil.getObjectRecordTypeId(FS_Initial_Order__c.SObjectType,FsConstants.NEWINITIALORDER);
       
       //Iterate over Installation
       for(FS_Installation__c installPlan: installationPlanList){
          List<FS_Initial_Order__c> initialOrderList=new List<FS_Initial_Order__c>();
            initialOrderList=FSTestFactory.createTestInitialOrder(installPlan.FS_Outlet__c,installPlan.Id,false,1,initialOrderRecordType);
            initialOrderCreateList.addAll(initialOrderList);
          
       }
       
       insert initialOrderCreateList;
      
       //Verify that association Brandset got created
       system.assert(!initialOrderCreateList.isEmpty()); 
    }
    
    private static testMethod void testInitialOrder7000Series(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.startTest();
            //Sets the current PageReference for the controller
            final PageReference pageRef = Page.FSInitialOrderBrandsetsPage;
            Test.setCurrentPage(pageRef);
 
            final FS_Initial_Order__c  parentRecord= [SELECT Id,FS_Installation__c FROM FS_Initial_Order__c WHERE RecordType.Name=:FsConstants.NEWINITIALORDER limit 1];
			final ApexPages.StandardController standardController = new ApexPages.StandardController(parentRecord);
            final FSInitialOrderBrandsetsController controller = new FSInitialOrderBrandsetsController(standardController);
            
            //page loaded
            controller.getAssosiationBrandsets();
            
            Test.stopTest();
            //verify association displayed
            system.assert([SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Installation__c=:parentRecord.FS_Installation__c]>0);
        }
    }
    
    
    private static testMethod void testInitialOrder8k9kSeries(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.startTest();
            //Sets the current PageReference for the controller
            final PageReference pageRef = Page.FSInitialOrderBrandsetsPage;
            Test.setCurrentPage(pageRef);

            final FS_Initial_Order__c  parentRecord= [SELECT Id,FS_Installation__c FROM FS_Initial_Order__c WHERE RecordType.Name=:FsConstants.NEWINITIALORDER limit 1];
            final ApexPages.StandardController standardController = new ApexPages.StandardController(parentRecord);
            final FSInitialOrderBrandsetsController controller = new FSInitialOrderBrandsetsController(standardController);
            
            //page loaded
            controller.getAssosiationBrandsets();
            
            Test.stopTest();
            //verify association displayed
            system.assert([SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Installation__c=:parentRecord.FS_Installation__c]>0);
        }
    }
}