/**************************************************************************************
Apex Class Name     : FSFlavorChangeWorkflowControllerTest
Version             : 1.0
Function            : This test class is for  FSFlavorChangeWorkflowController Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             02/17/2017          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSFlavorChangeWorkflowControllerTest{
    
    private static final String NUM7000 ='7000'; 
    private static final String NUM8000 ='8000';
    private static final String NUM9000 ='9000';   
        
    private static final String SERVICEPROVIDERACCOUNTTYPE ='FS Service Provider';
    private static final String EXECUTIONPLANTYPE ='Execution Plan';
    private static final String INSTALLATIONSOBJECT ='FS_Installation__c';
    private static final String CUSTOMFIELDPLATFORM ='FS_Platform__c';
    private static final String CUSTOMFIELDEQUIPTYPE ='FS_Equip_Type__c';
    
    private static final String PARENTRECORDID ='parentRecordId';   
    private static final String ACCOUNTRECORDTYPE ='accountRecordType';   
    private static final String LITERALVALSHOW ='Show';   
    private static final String LITERALVALYES ='Yes';   
    private static final String HQRECTYPEID=FSConstants.RECORD_TYPE_HQ;
    private static final String OUTLETRECTYPEID=FSConstants.RECORD_TYPE_OUTLET;
    
    @testSetup
    private static void loadTestData(){
      
        List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSAccountBusinessProcess','FSInstallationBusinessProcess','FSExecutionPlanTriggerHandler'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
      
      //create Flavor Change Error messages records --custom setting
      FSTestFactory.createTestFlavorChangeErrorMessages();
        //Create custom setting data
      List<Platform_Type_ctrl__c> listplatform = FSTestFactory.lstPlatform();
      List<ProfileListFromCustomSettings__c>  lstOfProfiles = FSTestFactory.lstProfiles();
      //create Brandset records
      List<FS_Brandset__c> brandsetRecordList=FSTestFactory.createTestBrandset();
      
       //Create Single HeadQuarter
      List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(true,1,HQRECTYPEID);
        List<Account> headQuarterCustomerListupdate = New List<Account>();
        For(Account acn : headQuarterCustomerList){
            acn.FS_Requested_Delivery_Method__c = 'Distributor';
           
            headQuarterCustomerListupdate.add(acn);
        }
        update headQuarterCustomerListupdate;
      //Create 20 Outlet
      List<Account> outletCustomerList=new List<Account>();
      for(Account acc : FSTestFactory.createTestAccount(false,25,OUTLETRECTYPEID)){
        acc.FS_Headquarters__c=headQuarterCustomerListupdate.get(0).Id;
        outletCustomerList.add(acc);
      }
      insert outletCustomerList;
      
      
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
        
        List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(headQuarterCustomerListupdate.get(0).Id,false,1,epRecordTypeId);
        
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
          Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,installationRecordType); 
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
       
        //Verify that Installation Plan got created
       system.assertEquals(1,installationPlanList.size());  
      //create service provider account
      List<Account> serviceProviderCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                             FSUtil.getObjectRecordTypeId(Account.SObjectType,SERVICEPROVIDERACCOUNTTYPE));
                                                                             
      List<FS_SP_Aligned_Zip__c> spAlignedZipList=new List<FS_SP_Aligned_Zip__c>();   
      //Id recordTypeId7K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(SERIES7000).getRecordTypeId();                                                                  
      //Id recordTypeId8K9K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(SERIES8000OR9000).getRecordTypeId();
      final string platform7k='7000';
      final string platform8k9k='8000';
       //create trigger switch --custom setting
      FSTestFactory.createTestDisableTriggerSetting(); 
      //Get all the Outlets
      List<Account> accList = [SELECT Id,Name,ShippingPostalCode,ShippingCountry FROM Account where RecordTypeId=:FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet') limit 200];
      for(Account accOutlet : accList){
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
       Test.startTest();
        //Create Association Brandset
        List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
        //create association 10 brandset records for each installation 
        List<FS_Installation__c> installPlanList = New List<FS_Installation__c>();
        installPlanList = [SELECT Id,Type_of_Dispenser_Platform__c,RecordTypeId FROM FS_Installation__c LIMIT 200];
        for(FS_Installation__c installPlan: installPlanList){
            List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
            
            if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM7000)){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset7000List,INSTALLATIONSOBJECT,installPlan.Id,branset7000List.size());
                for(Integer i=0;i<associationList.size();i++){
                    associationList[1].put(CUSTOMFIELDPLATFORM, NUM7000 );
                }
                associationBrandsetList.addAll(associationList);
            }
            
            if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM8000) ){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset8000List,INSTALLATIONSOBJECT,installPlan.Id,branset8000List.size());
                for(Integer i=0;i<associationList.size();i++){
                    associationList[1].put(CUSTOMFIELDPLATFORM, NUM8000 );
                }
                associationBrandsetList.addAll(associationList);
            }
            if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM9000)){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset9000List,INSTALLATIONSOBJECT,installPlan.Id,branset9000List.size());
                for(Integer i=0;i<associationList.size();i++){
                    associationList[1].put(CUSTOMFIELDPLATFORM, NUM9000 );
                }
                associationBrandsetList.addAll(associationList);
            }
        }
        
        insert associationBrandsetList;
  
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
       List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
     
       //Create Outlet Dispensers 
       List<FS_Installation__c> instPlanList = New List<FS_Installation__c>();
       instPlanList = [SELECT Id,Type_of_Dispenser_Platform__c,RecordTypeId,FS_Outlet__c FROM FS_Installation__c  limit 200];
       for(FS_Installation__c installPlan : instPlanList){
           List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
           Id outletDispenserRecordTypeId;
           outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FSConstants.RT_NAME_CCNA_OD);
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM7000)){
              
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
              odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM7000 );
           }
           
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM8000)){
              
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'C');
              odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM8000 );
           }
           if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM9000) ){
              
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'D');
              odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM9000 );
           }
           
           outletDispenserList.addAll(odList);
       }   
       
       insert outletDispenserList;
        Test.stopTest();
       //Verify that Outlet Dispenser got created
       system.assertEquals(1,outletDispenserList.size()); 
    }
    
   private static testMethod void testPageLoadUnderHQ(){
       //Sets the current PageReference for the controller
       PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
       Test.setCurrentPage(pageRef);
       Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
       
       
       //Add parameters to page URL
       ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
       ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
       
       
       FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
       
       final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
       final User adminUser = FSTestFactory.createUser(adminProfile.id);
       insert adminUser;
       system.runAs(adminUser){
           Test.startTest();
           
           controller.getOutletSearchResults();
           
           //Select two outlets 
           List<Account> acctList = New List<Account>();
           acctList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                       Shippingcountry,Shippingpostalcode FROM Account 
                                       WHERE RecordTypeId=:OUTLETRECTYPEID  limit 2];
           for(Account outletAccount: acctList){
                                           
                   controller.outletSearchResults.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));
            }
           
           
           
           controller.getOutletSearchResults();
           system.assert(!controller.outletSearchResults.isEmpty());
           
           //pagination variables
           controller.availableFirst();
           controller.availablePrevious();
           controller.availableNext();
           controller.availableEnd();
           controller.getAvailableDisablePrevious();
           controller.getAvailableDisableNext();
           
           Test.stopTest();
       }
    }
    
    private static testMethod void testSearchWithOutletCity(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            
            Test.startTest();
            
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            //Do not change. Depends on test data
            controller.searchCity='SYRACUSE';
            controller.search();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            Test.stopTest();
        }
    }
    
    private static testMethod void testSearchWithOutletState(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            
            Test.startTest();
            
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            
            controller.searchState='NY';
            controller.search();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            Test.stopTest();
        }
    }
    
    private static testMethod void testSearchWithOutletName(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            
            Test.startTest();
            
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            //Do not change. Depends on test data
            controller.searchName='Test Account 0';
            
            controller.search();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());

            Test.stopTest();
        }
    }
    
    //single ACN without leading zeroes 
    private static testMethod void testSearchWithOutletACN1(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            
            //Do not modify this value.Depends on test Data
            controller.searchAcn='11155';
            
            controller.search();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            Test.stopTest();
        }
    }
    
    
    //More than one ACN in new lines without leading zeroes 
    private static testMethod void testSearchWithOutletACN2(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            
            //Do not modify this value.Depends on test Data
            String acnText='11155\n';
            acnText+='21155';
            controller.searchAcn=acnText;
            
            controller.search();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            Test.stopTest();
        }
    }
    
    //More than one ACN in new lines ACN with leading zeroes 
    private static testMethod void testSearchWithOutletACN3(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            //Do not modify this value.Depends on test Data
            String acnText='0000011155\n';
            acnText+='0000021155';
            controller.searchAcn=acnText;
            
            controller.search();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            Test.stopTest();
        }
    }
    
    //Select two outlets
    private static testMethod void testOutletSelectionFromSearchResult1(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            
            //Select two  outlet records to add     
            List<Account> accntList = New List<Account>();
            accntList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                        Shippingcountry,Shippingpostalcode FROM Account 
                                        WHERE RecordTypeId=:OUTLETRECTYPEID  order by createdDate limit 2];
            for(Account outletAccount: accntList){
                                            
                                            controller.outletSearchResults.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));
                                        }
            
            
            //user clicks on Add Outlets 
            controller.addOutlets(); 
            
            Test.stopTest();
            
            //verify that two outlets were selected
            system.assertEquals(2,controller.selectedOutletRecords.size());
            //pagination variabels
            controller.selectedFirst();
            controller.selectedPrevious();
            controller.selectedNext();
            controller.selectedEnd();
            controller.getSelectedDisablePrevious();
            controller.getSelectedDisableNext();
        }
    }
    
    //Select more than twenty outlets
    private static testMethod void testOutletSelectionFromSearchResult2(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            
            //Select two  outlet records to add      
            List<Account> outletList = New List<Account>();
            outletList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                        Shippingcountry,Shippingpostalcode FROM Account 
                                        WHERE RecordTypeId=:OUTLETRECTYPEID  order by createdDate limit 21];
            for(Account outletAccount: outletList){
                                            
                                            controller.outletSearchResults.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));
                                        }
            
            
            //user clicks on Add Outlets 
            controller.addOutlets(); 
            
            Test.stopTest();
            
            //verify only 20 records should be selected
            system.assertEquals(20,controller.selectedOutletRecords.size());
            
            //Verify error Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'You cannot add more than 20 outlets to the list. Please use Flavor Change File Upload option');
        }
    }
    
    private static testMethod void testRemovalOfSelectedOutlets(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            
            //Select five outlet records to add 
            List<Account> outletsList = New List<Account>();
            outletsList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                        Shippingcountry,Shippingpostalcode FROM Account 
                                        WHERE RecordTypeId=:OUTLETRECTYPEID  order by createdDate limit 5];
            for(Account outletAccount: outletsList){
                                            
                                            controller.outletSearchResults.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));
                                        }
            
            //user clicks on Add Outlets 
            controller.addOutlets(); 
            system.assertEquals(5,controller.selectedOutletRecords.size());
            
            //select outlet records to remove
            List<Account> outletsRecList = New List<Account>();
            outletsRecList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                        Shippingcountry,Shippingpostalcode FROM Account 
                                        WHERE RecordTypeId=:OUTLETRECTYPEID  order by createdDate limit 5];
            for(Account outletAccount: outletsRecList){
                                            
                                            controller.selectedoutletRecords.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));                             
                                        }                                  
            
            //User clicks on remove outlet button
            controller.removeOutlets();
            
            //verify all outlets that were selected are removed.
            system.assert(controller.selectedoutletRecords.isEmpty());
            Test.stopTest();
        }       
    }
    
    private static testMethod void testBrandsetForSelectedOutlets(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            controller.getOutletSearchResults();
            system.assert(controller.outletSearchResults.size()>0);
            
            //Select 2 outlet records to add      
            List<Account> outletsRecList = New List<Account>();
            outletsRecList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                        Shippingcountry,Shippingpostalcode FROM Account 
                                        WHERE RecordTypeId=:OUTLETRECTYPEID  order by createdDate limit 2];
            for(Account outletAccount: outletsRecList){
                                            
                                            controller.outletSearchResults.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));
                                        }
            
            //user clicks on Add Outlets 
            controller.addOutlets(); 
            
            system.assertEquals(2,controller.selectedOutletRecords.size());
            
            //user clicks on next button
            controller.showBrandsets();
            
            //user navigates to brandset screen
            system.assertEquals(true, controller.toggleScreen);
            
            //User sees flavor change records
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            //user clicks on back button
            controller.backToPrevious();
            system.assertEquals(false,controller.toggleScreen);
            
            Test.stopTest();
            
        }
    }
    
    //Date validation for flavor change
    private static testMethod void testBrandsetForSelectedOutletsValidation1(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            controller.getOutletSearchResults();
            system.assert(controller.outletSearchResults.size()>0);
            
            //Select 2 outlet records to add           
            List<Account> outletsRecList = New List<Account>();
            outletsRecList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                        Shippingcountry,Shippingpostalcode FROM Account 
                                        WHERE RecordTypeId=:OUTLETRECTYPEID  order by createdDate limit 2];
            for(Account outletAccount: outletsRecList){
                                            
                                            
                                            controller.outletSearchResults.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));
                                        }
            
            
            //user clicks on Add Outlets 
            controller.addOutlets(); 
            
            system.assertEquals(2,controller.selectedOutletRecords.size());
            
            //user clicks on next button
            controller.showBrandsets();
            
            //User sees flavor change records
            system.assert(!controller.newFlavorChangeData.isEmpty()); 
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                flavor.FS_BS_Effective_Date__c=System.today().addDays(-1);
                flavor.FS_DA_Effective_Date__c=System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
            }
            
            //user clicks on save button
            controller.saveFlavorChange();
            
            Test.stopTest();
            
            //Verify error Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Date values should not be earlier than today');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'New Brandset is required if we have Effective Brandset');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Sow Dasani is required if we have Hide/Show Dasani Effective Date');   
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Show Water Button is required if we have Effectvie Hide/Show Water Button'); 
        }
    }
    
    
    //Branset attributes validation for flavor change
    private static testMethod void testBrandsetForSelectedOutletsValidation2(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            
            //Select 2 outlet records to add          
            List<Account> outletsRecList = New List<Account>();
            outletsRecList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                        Shippingcountry,Shippingpostalcode FROM Account 
                                        WHERE RecordTypeId=:OUTLETRECTYPEID  order by createdDate limit 2];
            for(Account outletAccount: outletsRecList){
                                            
                                            controller.outletSearchResults.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));
                                        }
            
            
            //user clicks on Add Outlets 
            controller.addOutlets(); 
            
            system.assertEquals(2,controller.selectedOutletRecords.size());
            
            //user clicks on next button
            controller.showBrandsets();
            
            //User sees flavor change records
            system.assert(!controller.newFlavorChangeData.isEmpty()); 
            
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){ //
                String platform=flavor.FS_Platform__c;
                Id currentBrandset=flavor.FS_Current_Brandset__c;
                
                flavor.FS_New_Brandset__c=[SELECT Id FROM FS_Brandset__c WHERE FS_Platform__c INCLUDES (:platform) 
                                           AND Id!=:currentBrandset limit 1].Id;
                flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
                flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
            }
            
            //user clicks on save button
            controller.saveFlavorChange();
            
            Test.stopTest();
            
            //Verify error Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Brandset Date is required if we have New Brandset');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Hide/Show Dasani Date is required if we have value in Hide/Show Dasani');   
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Hide/Show Water Button Date is required if we have value in Hide/Show Water Button'); 
        }
    }
    
    
    private static testMethod void testBrandsetForSelectedOutletsSave(){
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:HQRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            controller.getOutletSearchResults();
            system.assert(!controller.outletSearchResults.isEmpty());
            
            //Select 2 outlet records to add   
            List<Account> outletsRecList = New List<Account>();
            outletsRecList = [SELECT Id,Name,FS_ACN__c,RecordTypeId,Shippingcity,Shippingstate,Shippingstreet,
                                        Shippingcountry,Shippingpostalcode FROM Account 
                                        WHERE RecordTypeId=:OUTLETRECTYPEID  order by createdDate limit 2];
            for(Account outletAccount: outletsRecList){
                                            controller.outletSearchResults.add(new FSFlavorChangeWorkflowController.AccountWrapper(outletAccount,true));
                                        }
            
            
            //user clicks on Add Outlets 
            controller.addOutlets(); 
            
            system.assertEquals(2,controller.selectedOutletRecords.size());
            
            //user clicks on next button
            controller.showBrandsets();
            
            //User sees flavor change records
            system.assert(!controller.newFlavorChangeData.isEmpty()); 
            
            Set<Id> currentBrandsetUniqueValues=new Set<Id>();
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
            }
            
            //Collection with platform and Brandset as key
            Map<String,Id> newBrandsetMap=new Map<String,Id>();
            List<FS_Brandset__c> brandsetList = New List<FS_Brandset__c>();
            brandsetList = [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100];
            for(FS_Brandset__c brandset : brandsetList){
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
            
            
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){ 
                String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
                
                flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
                
                flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
                flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
                flavor.FS_SP_go_out__c=LITERALVALYES;
                flavor.FS_BS_Effective_Date__c=System.today();
                flavor.FS_DA_Effective_Date__c=System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
                flavor.FS_Pungent_Change_Indicator__c=LITERALVALYES;
            }
            
            //user clicks on save button
            controller.saveFlavorChange();
            
            
            Test.stopTest();
            
            //Verify Flavor Change Header created for Headquarter
            List<FS_Flavor_Change_Head__c> hqFlavorHeaderList=[SELECT Id FROM FS_Flavor_Change_Head__c WHERE FS_HQ_Chain__c=:parentRecord.Id AND FS_Level__c='FS Headquarters'];
           // system.assert( !hqFlavorHeaderList.isEmpty() );
        }
    }
    
    
    private static testMethod void testPageLoadUnderOutlet(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();//
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            Test.stopTest();
        }
    }
    
    
    
    private static testMethod void testPageLoadUnderOutletAndNavigateToDetailPage(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            //user clicks on back button
            Pagereference detailPage=controller.backToPrevious();
            String redirectUrl=detailPage.getUrl();
            system.assertEquals(redirectUrl,'/'+parentRecord.Id);
            
            Test.stopTest();
        }
    }
    
    
    private static testMethod void testPageUnderOutletValidation1(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                flavor.FS_BS_Effective_Date__c=System.today().addDays(-1);
                //OCR'17 Changes
                flavor.FS_Flavor_Change_Requested_Date__c=System.today().addDays(-1);
                flavor.FS_DA_Effective_Date__c=System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
            }
            
            //user clicks on save button
            controller.saveFlavorChange();
            Test.stopTest();
            
            //Verify error Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Date values should not be earlier than today');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'New Brandset is required if we have Effective Brandset');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Sow Dasani is required if we have Hide/Show Dasani Effective Date');   
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Show Water Button is required if we have Effectvie Hide/Show Water Button');
            //OCR'17 changes
           system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Requested Date cannot be earlier than today’s date');
        }
    }
    
    /*private static testMethod void testValidationPass(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                flavor.FS_BS_Effective_Date__c=System.today();
                //OCR'17 Changes
                flavor.FS_Flavor_Change_Requested_Date__c=System.today();
                flavor.FS_DA_Effective_Date__c=System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
                
            }
            
            //user clicks on save button
            controller.saveFlavorChange();
            Test.stopTest();
            
            //Verify error Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Date values should not be earlier than today');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'New Brandset is required if we have Effective Brandset');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Sow Dasani is required if we have Hide/Show Dasani Effective Date');   
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Show Water Button is required if we have Effectvie Hide/Show Water Button');
            //OCR'17 changes
           system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Requested Date cannot be earlier than today’s date');
        }
    }*/
      private static testMethod void testPageUnderOutletValidation11(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,Name,RecordTypeId,FS_Final_Order_Method__c,FS_Final_Delivery_Method__c FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        system.debug('FS_Final_Delivery_Method__c'+parentRecord.FS_Final_Delivery_Method__c+''+parentRecord.FS_Final_Order_Method__c);
        //Add parameters to page URL
          parentRecord.FS_Requested_Order_Method__c='Distributor';
                parentRecord.FS_Requested_Delivery_Method__c='Distributor';
            parentRecord.FS_Approved_for_Distributor_Ordering__c='Yes';
          Update parentRecord;
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                flavor.FS_BS_Effective_Date__c=System.today().addDays(-1);
                //OCR'17 Changes
                flavor.FS_Flavor_Change_Requested_Date__c=System.today();//System.today().addDays(-1);
                flavor.FS_DA_Effective_Date__c=NULL;//System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
                flavor.FS_BS_Effective_Date__c = NULL;
                flavor.FS_Pungent_Change_Indicator__c='';
                flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
            }
            
            //user clicks on save button
            controller.saveFlavorChange();
            Test.stopTest();
            
            //Verify error Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Date values should not be earlier than today');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'New Brandset is required if we have Effective Brandset');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Sow Dasani is required if we have Hide/Show Dasani Effective Date');   
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Hide/Show Water Button is required if we have Effectvie Hide/Show Water Button');
            //OCR'17 changes
           system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Requested Date cannot be earlier than today’s date');
        }
    } 
    private static testMethod void testPageUnderOutletValidation2(){
        
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            
            Set<Id> currentBrandsetUniqueValues=new Set<Id>();
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
            }
            
            //Collection with platform and Brandset as key
            Map<String,Id> newBrandsetMap=new Map<String,Id>();
            List<FS_Brandset__c> brandsetList = New List<FS_Brandset__c>();
            brandsetList = [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100];
            for(FS_Brandset__c brandset : brandsetList){
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
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){ 
                String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
                flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
                flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
                flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
            }
            
            //user clicks on save button
            controller.saveFlavorChange();
            Test.stopTest();  
            
            //Verify error Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Brandset Date is required if we have New Brandset');
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Hide/Show Dasani Date is required if we have value in Hide/Show Dasani');   
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR), 'Effective Hide/Show Water Button Date is required if we have value in Hide/Show Water Button'); 
        }
    }
    
    
    private static testMethod void testPageUnderOutletSave(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId,FS_Final_Delivery_Method__c FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        system.debug('parentRecord'+parentRecord.FS_Final_Delivery_Method__c);
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
            controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            Set<Id> currentBrandsetUniqueValues=new Set<Id>();
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
            }
            
            //Collection with platform and Brandset as key
            Map<String,Id> newBrandsetMap=new Map<String,Id>();
            List<FS_Brandset__c> brandsetList = New List<FS_Brandset__c>();
            brandsetList = [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100];
            for(FS_Brandset__c brandset : brandsetList){
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
                flavor.FS_Flavor_Change_Requested_Date__c = System.today();
            }
            
            //user clicks on save button
            controller.saveFlavorChange();
            
            Test.stopTest();  
            
        }
    }
    
    
    private static testMethod void testPageUnderOutletFilldown1(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            Set<Id> currentBrandsetUniqueValues=new Set<Id>();
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
            }
            
            //Collection with platform and Brandset as key
            Map<String,Id> newBrandsetMap=new Map<String,Id>();
             List<FS_Brandset__c> brandsetList = New List<FS_Brandset__c>();
             brandsetList = [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100];
            for(FS_Brandset__c brandset : brandsetList){
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
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){ 
                String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
                flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
                flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
                flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
                flavor.FS_BS_Effective_Date__c=System.today();
                flavor.FS_DA_Effective_Date__c=System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
            }
            
            //user clicks on Apply Date to all rows button for Brandset Effective Date
            controller.selectedFillDown='BrandsetEffectiveDate';
            controller.fillDown();
            
            Test.stopTest();  
        }
       
    }
    
    
    private static testMethod void testPageUnderOutletFilldown2(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            Set<Id> currentBrandsetUniqueValues=new Set<Id>();
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
            }
            
            //Collection with platform and Brandset as key
            Map<String,Id> newBrandsetMap=new Map<String,Id>();
            List<FS_Brandset__c> brandsetList = New List<FS_Brandset__c>();
            brandsetList = [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100];
            for(FS_Brandset__c brandset : brandsetList){
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
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){ 
                String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
                flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
                flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
                flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
                flavor.FS_BS_Effective_Date__c=System.today();
                flavor.FS_DA_Effective_Date__c=System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
            }
            
            //user clicks on Apply Date to all rows button for Dasani Effective Date
            controller.selectedFillDown='DasaniEffectiveDate';
            controller.fillDown();
            
            controller.selectedFillDown='Dasani';
            controller.fillDown();
            
            Test.stopTest();  
        }
    }
    
    private static testMethod void testPageUnderOutletFilldown3(){
        
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            Set<Id> currentBrandsetUniqueValues=new Set<Id>();
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
            }
            
            //Collection with platform and Brandset as key
            Map<String,Id> newBrandsetMap=new Map<String,Id>();
            List<FS_Brandset__c> brandsetList = New List<FS_Brandset__c>();
            brandsetList = [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100];
            for(FS_Brandset__c brandset : brandsetList){
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
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){ 
                String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
                flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
                flavor.FS_Hide_Show_Dasani__c=LITERALVALSHOW;
                flavor.FS_Hide_Show_Water_Button__c=LITERALVALSHOW;
                flavor.FS_BS_Effective_Date__c=System.today();
                flavor.FS_DA_Effective_Date__c=System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
            }
            
            //user clicks on Apply Date to all rows button for Water button Effective Date
            controller.selectedFillDown='WaterEffectiveDate';
            controller.fillDown();
            
            controller.selectedFillDown='WaterButton';
            controller.fillDown();
            
            Test.stopTest();  
        }
    }
    
    private static testMethod void testPageUnderOutletFilldown4(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:OUTLETRECTYPEID limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ACCOUNTRECORDTYPE, parentRecord.RecordTypeId );
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
              controller.createRecordsRelatedToHQAndChain();
            //verify brandset displayed or not
            system.assert(controller.newFlavorChangeData.size()>0);
            
            Set<Id> currentBrandsetUniqueValues=new Set<Id>();
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){
                currentBrandsetUniqueValues.add(flavor.FS_Current_Brandset__c);
            }
            
            //Collection with platform and Brandset as key
            Map<String,Id> newBrandsetMap=new Map<String,Id>();
             List<FS_Brandset__c> brandsetList = New List<FS_Brandset__c>();
            brandsetList = [SELECT Id,Name,FS_Platform__c FROM FS_Brandset__c LIMIT 100];
            for(FS_Brandset__c brandset : brandsetList){
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
            
            //User provides values in visualforce page
            for(FS_Flavor_Change_New__c flavor : controller.newFlavorChangeData){ 
                String key= flavor.FS_Platform__c+':'+flavor.FS_Current_Brandset__c;
                flavor.FS_New_Brandset__c=newBrandsetMap.get(key);
                flavor.FS_Pungent_Change_Indicator__c=LITERALVALYES;
                flavor.FS_SP_go_out__c=LITERALVALYES;
                flavor.FS_Flavor_Change_Requested_Date__c=System.today();
                flavor.FS_DA_Effective_Date__c=System.today();
                flavor.FS_WA_Effective_Date__c=System.today();
            }
            
            //user clicks on Apply Date to all rows button for Water button Effective Date
            controller.selectedFillDown='PungentIndicator';
            controller.fillDown();
            
            controller.selectedFillDown='ServiceProvider';
            controller.fillDown();
            
            controller.selectedFillDown='RequestedDate';
            controller.fillDown();
            
            Test.stopTest();  
        }
    }
    
    private static testMethod void testPageLoadUnderInstallation(){
    
        //Sets the current PageReference for the controller
        PageReference pageRef = Page.FSFlavorChangeWorkflowInputPage;
        Test.setCurrentPage(pageRef);
        FS_Installation__c parentRecord= [SELECT Id FROM FS_Installation__c limit 1];
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(PARENTRECORDID, parentRecord.Id);
        
        
        FSFlavorChangeWorkflowController controller = new FSFlavorChangeWorkflowController ();
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            
            controller.loadDefaults();
            
            //verify brandset displayed or not
            system.assert(!controller.newFlavorChangeData.isEmpty());
            
            Test.stopTest();
        }
    }
}