/**************************************************************************************
Apex Class Name     : FSOutletDispenserFlavorChangeTest
Version             : 1.0
Function            : This test class is for  FSOutletDispenserFlavorChange Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             05/12/2017          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSOutletDispenserFlavorChangeTest { 

 private static final String SERIES7000 ='7000 Series';   
    private static final String SERIES8000 ='8000 Series'; 
    private static final String SERIES9000 ='9000 Series';  
    private static final String SERIES8000N9000 ='8000 & 9000 Series';
    private static final String SERIES8000OR9000 ='8000/9000 Series';
    
    private static final String NUM7000 ='7000'; 
    private static final String NUM8000 ='8000';
    private static final String NUM9000 ='9000'; 
    
    private static final String HEADQUARTERACCOUNTTYPE ='FS Headquarters';
    private static final String OUTLETACCOUNTTYPE ='FS Outlet';
    private static final String SERVICEPROVIDERACCOUNTTYPE ='FS Service Provider';
    private static final String EXECUTIONPLANTYPE ='Execution Plan';
    private static final String INSTALLATIONSOBJECT ='FS_Installation__c';
    private static final String CUSTOMFIELDPLATFORM ='FS_Platform__c';
    private static final String CUSTOMFIELDEQUIPTYPE ='FS_Equip_Type__c';
    
    private static final String PARENTRECORDID ='parentRecordId';   
    private static final String ACCOUNTRECORDTYPE ='accountRecordType';   
    private static final String LITERALVALSHOW ='Show';   
    private static final String LITERALVALYES ='Yes';   
    
    
    @testSetup
    private static void loadTestData(){
      
      //create trigger switch --custom setting
      FSTestFactory.createTestDisableTriggerSetting();
      
      //create Flavor Change Error messages records --custom setting
      FSTestFactory.createTestFlavorChangeErrorMessages();
      
      //create Brandset records
      List<FS_Brandset__c> brandsetRecordList=FSTestFactory.createTestBrandset();
      for(FS_Brandset__c  brandset : brandsetRecordList){
        system.assert(brandset.Available_for_Selection__c);
      }
       //Create Single HeadQuarter
      List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                             FSUtil.getObjectRecordTypeId(Account.SObjectType,HEADQUARTERACCOUNTTYPE));
      
      //Create 20 Outlet
      List<Account> outletCustomerList=new List<Account>();
      for(Account acc : FSTestFactory.createTestAccount(false,20,FSUtil.getObjectRecordTypeId(Account.SObjectType,OUTLETACCOUNTTYPE))){
        acc.FS_Headquarters__c=headQuarterCustomerList.get(0).Id;
        outletCustomerList.add(acc);
      }
        Test.startTest();
      insert outletCustomerList;
      FSTestFactory.lstPlatform();
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
      
      //Create Execution Plan
      //Collection to hold all recordtype names of Execution plan                                                                       
      Set<String> executionPlanRecordTypesSet=new Set<String>{EXECUTIONPLANTYPE};
      
      //Collection to hold all recordtype values of Execution plan
      Map<Id,String> executionPlanRecordTypesMap=new Map<Id,String>();
      
      List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
      //Create One executionPlan records for each record type
      for(String epRecType : executionPlanRecordTypesSet){
      
        Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,epRecType);
        
        executionPlanRecordTypesMap.put(epRecordTypeId,epRecType);
        
        List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(headQuarterCustomerList.get(0).Id,false,1,epRecordTypeId);
        
        executionPlanList.addAll(epList);                                                                     
      }
      //Verify that four Execution Plan got created
      system.assertEquals(1,executionPlanList.size());         
      
      insert executionPlanList;
      
      
      
      //Create Installation
       Set<String> installationPlanRecordTypesSet=new Set<String>{fsconstants.NEWINSTALLATION};
       
       List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >(); 
       
       Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
       
       //Create Installation for each Execution Plan according to recordtype
       for(String  installationRecordType : installationPlanRecordTypesSet){
          Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,fsconstants.NEWINSTALLATION); 
          List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
          installationPlanList.addAll(installList);
       } 
       
       //Assign different Outlets to Installation
       Integer numberOfOutlets=0;
       for(FS_Installation__c installationPlan : installationPlanList){
           installationPlan.FS_Outlet__c=outletCustomerList.get(numberOfOutlets).Id;
           numberOfOutlets++;
       }
       
       insert installationPlanList;  
       
        //Verify that 1 Installation Plan got created
       system.assertEquals(1,installationPlanList.size());  
      
         
      //create service provider account
      List<Account> serviceProviderCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                             FSUtil.getObjectRecordTypeId(Account.SObjectType,SERVICEPROVIDERACCOUNTTYPE));
                                                                             
      List<FS_SP_Aligned_Zip__c> spAlignedZipList=new List<FS_SP_Aligned_Zip__c>();   
      //Id recordTypeId7K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(SERIES7000).getRecordTypeId();                                                                  
      //Id recordTypeId8K9K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(SERIES8000OR9000).getRecordTypeId();
      final string platform7k='7000';
      final string platform8k9k='8000';
      //Get all the Outlets
      for(Account accOutlet : [SELECT Id,Name,ShippingPostalCode,ShippingCountry FROM Account where RecordTypeId=:FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet') limit 200]){
         String zipCode='';
         if(accOutlet.ShippingPostalCode!=null && accOutlet.ShippingPostalCode.length()>5) {
           zipCode=accOutlet.ShippingPostalCode.substring(0,5);
          }  
         spAlignedZipList.addAll(FSTestFactory.createTestSPAlignedZip(serviceProviderCustomerList.get(0).Id,zipCode,platform7k,false,1));
         spAlignedZipList.addAll(FSTestFactory.createTestSPAlignedZip(serviceProviderCustomerList.get(0).Id,zipCode,platform8k9k,false,1));
      }
      
      //Insert FS_SP_Aligned_Zip__c
      insert spAlignedZipList;
      
      //Separate Brandset based on platform 
         List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
         List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
         List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
         
         for(FS_Brandset__c branset :brandsetRecordList){
            if(branset.FS_Platform__c.contains(NUM7000)){
               branset7000List.add(branset);
            }
            if(branset.FS_Platform__c.contains(NUM8000)){
               branset8000List.add(branset);
            }           
            if(branset.FS_Platform__c.contains(NUM9000)) {
               branset9000List.add(branset);
            }
         }
       
       //Create Association Brandset
       List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
       //create association brandset records for each installation 
       for(FS_Installation__c installPlan: [SELECT Id,RecordTypeId,Type_of_Dispenser_Platform__c FROM FS_Installation__c LIMIT 200]){
           List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
           
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM7000) ){
            associationList=FSTestFactory.createTestAssociationBrandset(false,branset7000List,INSTALLATIONSOBJECT,installPlan.Id,1);
            for(Integer i=0;i<associationList.size();i++){
               associationList[0].put(CUSTOMFIELDPLATFORM, NUM7000 );
            }
            associationBrandsetList.addAll(associationList);
           }
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM8000) ){
            associationList=FSTestFactory.createTestAssociationBrandset(false,branset8000List,INSTALLATIONSOBJECT,installPlan.Id,2);
            for(Integer i=0;i<associationList.size();i++){
               associationList[0].put(CUSTOMFIELDPLATFORM, NUM8000 );
            }
            associationBrandsetList.addAll(associationList);
           }
           
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM9000)){
            associationList=FSTestFactory.createTestAssociationBrandset(false,branset9000List,INSTALLATIONSOBJECT,installPlan.Id,1);
            for(Integer i=0;i<associationList.size();i++){
               associationList[0].put(CUSTOMFIELDPLATFORM, NUM9000 );
            }
            associationBrandsetList.addAll(associationList);
           }
       }
       
       insert associationBrandsetList;
       //Verify that association Brandset got created
       system.assert(!associationBrandsetList.isEmpty()); 
       
       List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
     
       //Create Outlet Dispensers 
       for(FS_Installation__c installPlan : [SELECT Id,Type_of_Dispenser_Platform__c,RecordTypeId,FS_Outlet__c FROM FS_Installation__c  limit 200]){
           List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
           Id outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
           
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM7000)){
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
              odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM7000 );
           }
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM8000)){
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'B');
              odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM8000 );
           }
           
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM9000)){
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'D');
              odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM9000 );
           }
           
           outletDispenserList.addAll(odList);
       }   
        Test.stopTest();
       insert outletDispenserList;
       
       //Verify that 4 Outlet Dispenser got created
       system.assertEquals(1,outletDispenserList.size()); 
    }
    
    private static testMethod void testPageLoad(){
      //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSOutletDispenserFlavorChange;
       Test.setCurrentPage(pageRef);
       FS_Outlet_Dispenser__c parentRecord= [SELECT Id,Name FROM FS_Outlet_Dispenser__c limit 1];
       //system.assertEquals(1,[SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:parentRecord.Id]);
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('odId', parentRecord.Id);
       
       FSOutletDispenserFlavorChange controller = new FSOutletDispenserFlavorChange();
       	final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser){
        
       Test.startTest();
            controller.saveFlavorChange();
         controller.populateFlavorChangeInput();
         controller.setCurrentBrandsetValues();  
            controller.createRecordsRelatedToOutlet();
       Test.stopTest();
       system.assert(!controller.newFlavorChangeData.isEmpty());
        }
    }
    
    private static testMethod void testPageLoadBack(){
      //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSOutletDispenserFlavorChange;
       Test.setCurrentPage(pageRef);
       FS_Outlet_Dispenser__c parentRecord= [SELECT Id,Name FROM FS_Outlet_Dispenser__c limit 1];
       //system.assertEquals(1,[SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:parentRecord.Id]);
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('odId', parentRecord.Id);
       
       FSOutletDispenserFlavorChange controller = new FSOutletDispenserFlavorChange();
       	final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        
       Test.startTest();
         PageReference pageUrl=controller.backToPrevious();
         system.assert(pageUrl.getUrl().contains('/'+parentRecord.Id));
       Test.stopTest();
        }   
    }
    
    
    private static testMethod void testValidation1(){
      //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSOutletDispenserFlavorChange;
       Test.setCurrentPage(pageRef);
       FS_Outlet_Dispenser__c parentRecord= [SELECT Id,Name FROM FS_Outlet_Dispenser__c limit 1];
       //system.assertEquals(1,[SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:parentRecord.Id]);
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('odId', parentRecord.Id);
       
       FSOutletDispenserFlavorChange controller = new FSOutletDispenserFlavorChange();
        
       	final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser) {
        
      	 Test.startTest();
         //User provides values in visualforce page
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             flavor.FS_BS_Effective_Date__c=System.today().addDays(-1);
             flavor.FS_DA_Effective_Date__c=System.today();
             flavor.FS_WA_Effective_Date__c=System.today();
         }
         
         //user clicks on save button
          controller.saveFlavorChange();
              controller.setCurrentBrandsetValues();  
            controller.createRecordsRelatedToOutlet();
       Test.stopTest();
       
       //Verify error Message
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Date values should not be earlier than today');
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'New Brandset is required if we have Effective Brandset');
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Sow Dasani is required if we have Hide/Show Dasani Effective Date');   
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Show Water Button is required if we have Effectvie Hide/Show Water Button'); 
        }
    }
 private static testMethod void testValidation21(){
      //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSOutletDispenserFlavorChange;
       Test.setCurrentPage(pageRef);
       FS_Outlet_Dispenser__c parentRecord= [SELECT Id,Name FROM FS_Outlet_Dispenser__c limit 1];
       //system.assertEquals(1,[SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:parentRecord.Id]);
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('odId', parentRecord.Id);
       
       FSOutletDispenserFlavorChange controller = new FSOutletDispenserFlavorChange();
       
         Set<Id> currentBrandsetUniqueValues=new Set<Id>();
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
         }
         
         //Collection with platform and Brandset as key
         Map<String,Id> newBrandsetMap=new Map<String,Id>();
         for(FS_Brandset__c brandset : [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100]){
             for(Id currentBrandsetId : currentBrandsetUniqueValues ){
                if(brandset.Id!=currentBrandsetId && brandset.FS_Platform__c!=null){
                   if(brandset.FS_Platform__c.contains(NUM7000)){
                      newBrandsetMap.put(NUM7000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM8000)){
                      newBrandsetMap.put(NUM8000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM9000)){
                     newBrandsetMap.put(NUM9000+':'+currentBrandsetId,brandset.Id);
                   }
                   
                }
             }
             
         }
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser){
          
       Test.startTest();
         //User provides values in visualforce page
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
             Id currentBrandset=flavor.FS_Current_Brandset__c;
             flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
             flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
             flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
         }
         
         //user clicks on save button
          controller.saveFlavorChange();
          controller.setCurrentBrandsetValues();  
            controller.createRecordsRelatedToOutlet();  
       Test.stopTest();
        
       
       //Verify error Message
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Brandset Date is required if we have New Brandset');
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Hide/Show Dasani Date is required if we have value in Hide/Show Dasani');   
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Hide/Show Water Button Date is required if we have value in Hide/Show Water Button'); 
    }
  }   
    private static testMethod void testValidation2(){
      //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSOutletDispenserFlavorChange;
       Test.setCurrentPage(pageRef);
       FS_Outlet_Dispenser__c parentRecord= [SELECT Id,Name FROM FS_Outlet_Dispenser__c limit 1];
       //system.assertEquals(1,[SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:parentRecord.Id]);
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('odId', parentRecord.Id);
       
       FSOutletDispenserFlavorChange controller = new FSOutletDispenserFlavorChange();
       
         Set<Id> currentBrandsetUniqueValues=new Set<Id>();
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
         }
         
         //Collection with platform and Brandset as key
         Map<String,Id> newBrandsetMap=new Map<String,Id>();
         for(FS_Brandset__c brandset : [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100]){
             for(Id currentBrandsetId : currentBrandsetUniqueValues ){
                if(brandset.Id!=currentBrandsetId && brandset.FS_Platform__c!=null){
                   if(brandset.FS_Platform__c.contains(NUM7000)){
                      newBrandsetMap.put(NUM7000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM8000)){
                      newBrandsetMap.put(NUM8000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM9000)){
                     newBrandsetMap.put(NUM9000+':'+currentBrandsetId,brandset.Id);
                   }
                   
                }
             }
             
         }
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser){
          
       Test.startTest();
         //User provides values in visualforce page
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
             Id currentBrandset=flavor.FS_Current_Brandset__c;
             flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
             flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
             flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
         }
         
         //user clicks on save button
          controller.saveFlavorChange();
          controller.setCurrentBrandsetValues();  
            controller.createRecordsRelatedToOutlet();  
       Test.stopTest();
        
       
       //Verify error Message
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Brandset Date is required if we have New Brandset');
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Hide/Show Dasani Date is required if we have value in Hide/Show Dasani');   
       system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Hide/Show Water Button Date is required if we have value in Hide/Show Water Button'); 
    }
  }
    
    
    private static testMethod void testCreateHeadersAndrelatedRecords(){
      //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSOutletDispenserFlavorChange;
       Test.setCurrentPage(pageRef);
       FS_Outlet_Dispenser__c parentRecord= [SELECT Id,Name,FS_Outlet__c FROM FS_Outlet_Dispenser__c limit 1];
       //system.assertEquals(1,[SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:parentRecord.Id]);
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('odId', parentRecord.Id);
       
       FSOutletDispenserFlavorChange controller = new FSOutletDispenserFlavorChange();
       
         Set<Id> currentBrandsetUniqueValues=new Set<Id>();
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
         }
         
         //Collection with platform and Brandset as key
         Map<String,Id> newBrandsetMap=new Map<String,Id>();
         for(FS_Brandset__c brandset : [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100]){
             for(Id currentBrandsetId : currentBrandsetUniqueValues ){
                if(brandset.Id!=currentBrandsetId && brandset.FS_Platform__c!=null){
                   if(brandset.FS_Platform__c.contains(NUM7000)){
                      newBrandsetMap.put(NUM7000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM8000)){
                      newBrandsetMap.put(NUM8000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM9000)){
                     newBrandsetMap.put(NUM9000+':'+currentBrandsetId,brandset.Id);
                   }
                   
                }
             }     
         }
         system.debug('Map values'+newBrandsetMap);
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser){
          
       Test.startTest();
         //User provides values in visualforce page
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
             flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
             flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
             flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
             flavor.FS_SP_go_out__c=LITERALVALYES;
             flavor.FS_Pungent_Change_Indicator__c=LITERALVALYES;
             flavor.FS_BS_Effective_Date__c=System.today();
             flavor.FS_DA_Effective_Date__c=System.today();
             flavor.FS_WA_Effective_Date__c=System.today();
             //flavor.FS_Flavor_Change_Requested_Date__c=system.today()-1;
         }
         system.assert( !newBrandsetMap.isEmpty() );
         //user clicks on save button
          controller.saveFlavorChange();
             controller.setCurrentBrandsetValues();  
            controller.createRecordsRelatedToOutlet();
       Test.stopTest(); 
        }
    } 
    
    private static testMethod void testCreateRecordsWithNullBrandset(){
      //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSOutletDispenserFlavorChange;
       Test.setCurrentPage(pageRef);
       FS_Outlet_Dispenser__c parentRecord= [SELECT Id,Name,FS_Outlet__c FROM FS_Outlet_Dispenser__c limit 1];
       //system.assertEquals(1,[SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:parentRecord.Id]);
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('odId', parentRecord.Id);
       
       FSOutletDispenserFlavorChange controller = new FSOutletDispenserFlavorChange();
       
         Set<Id> currentBrandsetUniqueValues=new Set<Id>();
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
         }
         
         //Collection with platform and Brandset as key
         Map<String,Id> newBrandsetMap=new Map<String,Id>();
         for(FS_Brandset__c brandset : [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100]){
             for(Id currentBrandsetId : currentBrandsetUniqueValues ){
                if(brandset.Id!=currentBrandsetId && brandset.FS_Platform__c!=null){
                   if(brandset.FS_Platform__c.contains(NUM7000)){
                      newBrandsetMap.put(NUM7000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM8000)){
                      newBrandsetMap.put(NUM8000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM9000)){
                     newBrandsetMap.put(NUM9000+':'+currentBrandsetId,brandset.Id);
                   }
                   
                }
             }     
         }
         system.debug('Map values'+newBrandsetMap);
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser){
          
       Test.startTest();
         //User provides values in visualforce page
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
             //flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
             flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
             flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
             flavor.FS_SP_go_out__c=LITERALVALYES;
             flavor.FS_Pungent_Change_Indicator__c=LITERALVALYES;
             flavor.FS_BS_Effective_Date__c=System.today();
             flavor.FS_DA_Effective_Date__c=System.today();
             flavor.FS_WA_Effective_Date__c=System.today();
             //flavor.FS_Flavor_Change_Requested_Date__c=system.today()-1;
         }
         system.assert( !newBrandsetMap.isEmpty() );
         //user clicks on save button
          controller.saveFlavorChange();
             controller.setCurrentBrandsetValues();  
            controller.createRecordsRelatedToOutlet();
       Test.stopTest(); 
        }
    } 
    private static testMethod void testFlavorChangeRequestedDate(){
      //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSOutletDispenserFlavorChange;
       Test.setCurrentPage(pageRef);
       FS_Outlet_Dispenser__c parentRecord= [SELECT Id,Name,FS_Outlet__c FROM FS_Outlet_Dispenser__c limit 1];
       //system.assertEquals(1,[SELECT COUNT() FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:parentRecord.Id]);
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('odId', parentRecord.Id);
       
       FSOutletDispenserFlavorChange controller = new FSOutletDispenserFlavorChange();
       
         Set<Id> currentBrandsetUniqueValues=new Set<Id>();
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
         }
         
         //Collection with platform and Brandset as key
         Map<String,Id> newBrandsetMap=new Map<String,Id>();
         for(FS_Brandset__c brandset : [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100]){
             for(Id currentBrandsetId : currentBrandsetUniqueValues ){
                if(brandset.Id!=currentBrandsetId && brandset.FS_Platform__c!=null){
                   if(brandset.FS_Platform__c.contains(NUM7000)){
                      newBrandsetMap.put(NUM7000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM8000)){
                      newBrandsetMap.put(NUM8000+':'+currentBrandsetId,brandset.Id);
                   }
                   if(brandset.FS_Platform__c.contains(NUM9000)){
                     newBrandsetMap.put(NUM9000+':'+currentBrandsetId,brandset.Id);
                   }
                   
                }
             }     
         }
         system.debug('Map values'+newBrandsetMap);
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
		final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
		insert sysAdminUser;

        System.runAs(sysAdminUser){
          
       Test.startTest();
         //User provides values in visualforce page
         for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
             String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
             flavor.FS_New_Brandset__c=null;
             flavor.FS_Hide_Show_Dasani__c=null;
             flavor.FS_Hide_Show_Water_Button__c=null;
             flavor.FS_SP_go_out__c=LITERALVALYES;
             flavor.FS_Pungent_Change_Indicator__c=LITERALVALYES;
             flavor.FS_BS_Effective_Date__c=null;
             flavor.FS_DA_Effective_Date__c=null;
             flavor.FS_WA_Effective_Date__c=null;
             flavor.FS_Flavor_Change_Requested_Date__c=system.today()-1;
         }
         system.assert( !newBrandsetMap.isEmpty() );
         //user clicks on save button
          controller.saveFlavorChange();
            controller.setCurrentBrandsetValues();  
            controller.createRecordsRelatedToOutlet();
       Test.stopTest(); 
        }
    }
}