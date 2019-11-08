//***********************************************************
//Name         : FSCreateExecutionPlanTest
//Created By   : Pallavi Sharma (Appiro)
//Created Date : 27 - Sep - 2013
//Usage        : Unit test coverage of FSCreateExecutionPlanExtension
//Modified By  : Ashish Sharma 6th October, 2014 Ref - T-324029
//Modified By  : Venkata 02/13/17 for FET 4.0, changed the test methods to cover the New code in the class
//*************************************************************
@isTest
private class FSCreateExecutionPlanTest {
    private static Account chainAcc,accHeadQtr,accOutlet1,accOutlet2,accOutlet3;
    private static CIF_Header__c cifHeader;
    //private static Contact contact1;
    public static  string valTest = 'test'; 
    public static final string NO9000 = '9000';
    public static final string NO8000 = '8000';
    public static final string NO7000 = '7000';
    public static final string CUSTAPPROVED = 'Approved by Customer'; 
    public static final string EMPTY = ''; 
    public static final string VALID = 'id'; 
    public static final string CURRENTCIFID = 'currentCIFId';   
    
    // testMethod1 Covered Searching, Sorting and basic Functionality
    
    private static void  createData(){
        FSTestFactory.createTestDisableTriggerSetting();
        chainAcc=FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);  
        accHeadQtr = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHeadQtr.FS_Chain__c=chainAcc.Id;
        insert accHeadQtr;       
        List<Account> accList = new List<Account>();
        //Create Outlet Account  
        accOutlet1 = FSTestUtil.createAccountOutlet(valTest,FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.Id, false);
        accOutlet1.Name = valTest;
        accOutlet1.FS_ACN__c = 'test1';
        accOutlet1.ShippingCity = valTest;
        accOutlet1.ShippingState = valTest;
        accoutlet1.RecordTypeId=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Outlet');
        accList.add(accOutlet1);        
        
        //Create Outlet Account 
        accOutlet2 = FSTestUtil.createAccountOutlet(valTest,FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.Id, false);       
        accOutlet2.FS_ACN__c = 'test2';
        accOutlet2.ShippingCity = valTest;
        accOutlet2.ShippingState = valTest;
        accoutlet2.RecordTypeId=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Outlet');
        accList.add(accOutlet2);
        accOutlet3 = FSTestUtil.createAccountOutlet(valTest,FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.Id, false);       
        accOutlet3.FS_ACN__c = '0000128';
        accOutlet3.ShippingCity = valTest;
        accOutlet3.ShippingState = valTest;
        accoutlet3.RecordTypeId=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Outlet');
        accList.add(accOutlet3);
        insert accList;
        cifHeader=new CIF_Header__c();
        cifHeader.FS_HQ__c=accHeadQtr.Id;
        cifHeader.FS_Version__c=0;
        cifHeader.Name=accHeadQtr.Name+system.now();
        insert cifHeader;
    }
    
    private static testMethod void testMethod1(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        List<FS_CIF__c> listCif=new List<FS_CIF__c>();
        system.runAs(adminUser){
            createData();
            Test.startTest();
            final FS_CIF__c cif1=new FS_CIF__c();
            cif1.FS_Account__c=accOutlet1.Id;
            cif1.CIF_Head__c=cifHeader.Id;
            cif1.FS_Platform1__c=NO9000;
            cif1.FS_Platform2__c=NO8000;
            cif1.FS_Platform3__c=NO7000;
            cif1.FS_EP_Check__c=true;
            cif1.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
            listCif.add(cif1);
            final FS_CIF__c cif2=new FS_CIF__c();
            cif2.FS_Account__c=accOutlet2.Id;
            cif2.CIF_Head__c=cifHeader.Id;
            cif2.FS_Platform1__c=NO8000;
            cif2.FS_Platform2__c=NO7000;
            cif2.FS_EP_Check__c=true;
            //cif2.FS_Platform3__c=NO9000;
            cif2.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
            listCif.add(cif2);
           
            final FS_CIF__c cif3=new FS_CIF__c();
            cif3.FS_Account__c=accOutlet3.Id;
            cif3.CIF_Head__c=cifHeader.Id;
            cif3.FS_Platform1__c=NO7000;
            cif3.FS_EP_Check__c=true;
            //cif3.FS_Platform2__c=NO7000;
            cif2.FS_Platform3__c=NO9000;
            cif3.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
            listCif.add(cif3);        
            insert listCif;
            final Pagereference pgRef = Page.FSCreateExecutionPlan; 
            Test.setCurrentPage(pgRef);
            //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(VALID, accHeadQtr.Id);
            ApexPages.currentPage().getParameters().put(CURRENTCIFID, cifHeader.Id);
            
            final apexpages.Standardcontroller sCon = new apexpages.Standardcontroller(accHeadQtr);
            final FSCreateExecutionPlanExtension objController = new FSCreateExecutionPlanExtension(sCon);
            
            objController.selectedPlanType ='new';
            
            objController.createExecutionPlan();
            
            Test.stopTest();                     
        }
        system.assert([select id,FS_EP__c from CIF_header__c where id=:cifHeader.Id].FS_EP__c!=null);
    }
    
    private static testMethod void  testMethod2(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createData();   
            List<FS_CIF__c> cifList = new List<FS_CIF__c>();
            final FS_CIF__c cif1=new FS_CIF__c();
            cif1.FS_Account__c=accOutlet1.Id;
            cif1.CIF_Head__c=cifHeader.Id;
            //cif1.FS_Platform1__c=NO9000;
            cif1.FS_Platform2__c=NO7000;
            cif1.FS_Platform3__c=NO8000;
            cif1.FS_EP_Check__c=true;
            cif1.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
            cifList.add(cif1);
            final FS_CIF__c cif2=new FS_CIF__c();
            cif2.FS_Account__c=accOutlet2.Id;
            cif2.CIF_Head__c=cifHeader.Id;
            //cif1.FS_Platform1__c=NO9000;
            cif2.FS_Platform2__c=NO8000;
            cif2.FS_Platform3__c=NO7000;
            cif2.FS_EP_Check__c=true;
            cif2.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
            cifList.add(cif2);
            insert cifList;
            Test.startTest();
            
            final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan('Execution Plan',accHeadQtr.Id, false);            
            excPlan.FS_Platform_Type__c='7000;8000';        
            insert excPlan;
            
            
            final Pagereference pgRef = Page.FSCreateExecutionPlan; 
            Test.setCurrentPage(pgRef);
            pgRef.getParameters().put(VALID, accHeadQtr.Id);
            pgRef.getParameters().put(CURRENTCIFID,cifHeader.Id);
            final apexpages.Standardcontroller sCon = new apexpages.Standardcontroller(accHeadQtr);
            final FSCreateExecutionPlanExtension objController = new FSCreateExecutionPlanExtension(sCon);
            objController.executionPlanName=excPlan.id+ EMPTY;
            objController.headquarterName=accHeadQtr.Name;
            objController.chainName=chainAcc.Name;
            objController.executionPlanNo=excPlan.FS_Execution_Plan__c;
            objController.selectedPlanType ='addExisting';
            objController.searchExistingExecutionPlan();
            objController.lstExecutionPlan.add(excPlan);
            objController.selectedExecutionPlan=excPlan.id+EMPTY;       
            objController.createExecutionPlan();         
            Test.stopTest();
            system.assertEquals(2, [select id from FS_Installation__c where FS_Execution_Plan__c =:excPlan.Id].size());
        }
    }
    
    private static testMethod void  testMethod3(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createData();  
            List<FS_CIF__c> cifList = new List<FS_CIF__c>();
            final FS_CIF__c cif1=new FS_CIF__c();
            cif1.FS_Account__c=accOutlet1.Id;
            cif1.CIF_Head__c=cifHeader.Id;
            cif1.FS_Platform1__c=NO7000;
            cif1.FS_Platform2__c=NO9000;
            cif1.FS_EP_Check__c=true;
            cif1.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
            cifList.add(cif1);
            final FS_CIF__c cif2=new FS_CIF__c();
            cif2.FS_Account__c=accOutlet2.Id;
            cif2.CIF_Head__c=cifHeader.Id;
            cif2.FS_Platform1__c=NO9000;
            cif2.FS_Platform2__c=NO7000;
            cif2.FS_EP_Check__c=true;
            cif2.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
            cifList.add(cif2);
            insert cifList;
            Test.startTest();
            
            final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan('Execution Plan',accHeadQtr.Id, false);
            excPlan.FS_Platform_Type__c='7000;9000';
            insert excPlan;
            
            
            final Pagereference pgRef = Page.FSCreateExecutionPlan; 
            Test.setCurrentPage(pgRef);
            pgRef.getParameters().put(VALID, accHeadQtr.Id);
            pgRef.getParameters().put(CURRENTCIFID,cifHeader.Id);
            final apexpages.Standardcontroller sCon = new apexpages.Standardcontroller(accHeadQtr);
            final FSCreateExecutionPlanExtension objController = new FSCreateExecutionPlanExtension(sCon);
            objController.executionPlanName=excPlan.id+EMPTY;
            objController.headquarterName=accHeadQtr.Name;
            objController.selectedPlanType ='clone';
            objController.searchExistingExecutionPlan();
            objController.lstExecutionPlan.add(excPlan);
            objController.selectedExecutionPlan=excPlan.id+EMPTY;        
            
            objController.createExecutionPlan();         
            Test.stopTest();            
        }
        system.assertEquals(2, [select id from FS_Execution_Plan__c where FS_Headquarters__c=:accHeadQtr.Id].size());
        
    }
    private static testMethod void  testMethod4(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createData(); 
            List<FS_CIF__c> cifList = new List<FS_CIF__c>();
            final FS_CIF__c cif1=new FS_CIF__c();
            cif1.FS_Account__c=accOutlet1.Id;
            cif1.CIF_Head__c=cifHeader.Id;
            cif1.FS_Platform1__c=NO8000;
            cif1.FS_Platform2__c=NO9000;
            cif1.FS_Platform3__c=NO7000;
            cif1.FS_EP_Check__c=true;
            cif1.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
            cifList.add(cif1);
            final FS_CIF__c cif2=new FS_CIF__c();
            cif2.FS_Account__c=accOutlet2.Id;
            cif2.CIF_Head__c=cifHeader.Id;            
            cif2.FS_Platform1__c=NO9000;
            cif2.FS_Platform2__c=NO7000;
            cif2.FS_Platform3__c=NO8000;
            cif2.FS_EP_Check__c=true;
            cif2.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
             cifList.add(cif2);
            final FS_CIF__c cif3=new FS_CIF__c();
            cif3.FS_Account__c=accOutlet3.Id;
            cif3.CIF_Head__c=cifHeader.Id;            
            cif3.FS_Platform1__c=NO7000;
            //cif3.FS_Platform2__c=NO7000;
            cif2.FS_Platform3__c=NO9000;
            cif3.FS_Customer_s_disposition_after_review__c=FSCONSTANTS.REVIEWAW;
             cifList.add(cif3); 
            insert cifList;
            Test.startTest();
            
            final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan('Execution Plan',accHeadQtr.Id, false);            
            excPlan.FS_Platform_Type__c='9000;7000';        
            insert excPlan;
            
            
            final Pagereference pgRef = Page.FSCreateExecutionPlan; 
            Test.setCurrentPage(pgRef);
            pgRef.getParameters().put(VALID, accHeadQtr.Id);
            pgRef.getParameters().put(CURRENTCIFID,cifHeader.Id);
            final apexpages.Standardcontroller sCon = new apexpages.Standardcontroller(accHeadQtr);
            final FSCreateExecutionPlanExtension objController = new FSCreateExecutionPlanExtension(sCon);
            objController.executionPlanName=excPlan.id+EMPTY;
            objController.headquarterName=accHeadQtr.Name;
            objController.chainName=chainAcc.Name;
            objController.executionPlanNo=excPlan.FS_Execution_Plan__c;
            objController.selectedPlanType ='addExisting';
            objController.searchExistingExecutionPlan();
            objController.lstExecutionPlan.add(excPlan);
            objController.selectedExecutionPlan=excPlan.id+EMPTY;                
            objController.createExecutionPlan();
            Test.stopTest(); 
            system.assertEquals(2, [select id from FS_Installation__c where FS_Execution_Plan__c =:excPlan.Id].size());
        }        
    }   
}