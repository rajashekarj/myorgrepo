@isTest
public class FSCustomerInputFormTest {
    public static CIF_Header__c cifHead;
    public static Integer counter = 0;
    public static final String NOT_STARTED ='Not Started';
    public static final String IN_PROGRESS='In Progress';
    public static final String COMPLETED='Completed';
    public static Contact cntct;
    public Static Id recTypeHQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Headquarters');
    public Static Id recTypeVendor=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Vendor');
    public Static Id recTypeOutlet=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Outlet');
    public Static Id exeRecId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.sObjectType,'Execution Plan');
    public static FS_Brandset__c brand1;
    public static final string ACCOUNTSTR = 'Account';
    public static final string ACCID = 'AccId';
    public static final string FPS = 'FS PM_P';
    public static final string COM = 'COM';
    public static final string PLAT9K = '9000';
    public static final string ID = 'id';
    public static final string REMODEL = 'Remodel';
    public static final string ONHOLD = 'On Hold';
    public static final string REASON = 'Test Reason';
    public static final string APRBYCUST = 'Approved by Customer';
    public static final string SPECIFICDATE = 'Specific Date';
    public static final string DAY = 'Day – typically 8am start time';
    public static final string CUSTOMER = 'Customer';
    public static final string YES = 'yes';
    public static final string NO = 'No';
    public static final string BANKDRAFT = 'Bank Draft';
    public static final Integer NUM3 = 3;
    public static final Integer NUM5 = 5;
    public static final Integer NUM2 = 2;
    public static final Integer NUM25 = 25;
  
    
    @testSetup
    private static void loadTestData(){
        Integer count=0;
        //FSTestFactory.createTestDisableTriggerSetting();
        Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
        disableTriggerSetting.name='FSCOMNotifications';
        disableTriggerSetting.IsActive__c=true;
        disableTriggerSetting.Trigger_Name__c='FSCOMNotifications' ; 
        insert disableTriggerSetting;
        
        Disable_Trigger__c disableTriggerSetting2 = new Disable_Trigger__c();
        disableTriggerSetting2.name='FSCIFHeaderTrigger';
        disableTriggerSetting2.IsActive__c=true;
        disableTriggerSetting2.Trigger_Name__c='FSCIFHeaderTrigger' ; 
        insert disableTriggerSetting2;
    
        final List<Account> hqCustList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        //final List<Account> hqCustList1= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        final List<User> userLst = new List<User>();
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        System.runAs(sysAdmin){
        final Profile comProf = FSTestFactory.getProfileId('FS COM_P');
        final User comUserID = FSTestFactory.createUser(comProf.id);
        userLst.add(comUserID);
        final Profile fpsProf = FSTestFactory.getProfileId(FPS);
        final User fpsUserID = FSTestFactory.createUser(fpsProf.id);
        userLst.add(fpsUserID);
        }
        insert userLst;
        //Create Account Team Member
        final List<AccountTeamMember__c> atmLst = new List<AccountTeamMember__c>();
        final AccountTeamMember__c atmCom=new AccountTeamMember__c();
        atmCom.AccountId__c=hqCustList[0].id;
        atmCom.TeamMemberRole__c =COM;
        atmCom.UserId__c =userLst[0].id;
        atmLst.add(atmCom);
        final AccountTeamMember__c atmSales=new AccountTeamMember__c();
        atmSales.AccountId__c=hqCustList[0].id;
        atmSales.TeamMemberRole__c ='Sales Team Member';
        atmSales.UserId__c =userLst[0].id;
        atmLst.add(atmSales);
        Insert atmLst;
        
        system.runAs(userLst[1])
        {
        //Create Contact
        final Contact cntct = FSTestUtil.createTestContact(hqCustList[0].id, 'New Contact', false);
        cntct.phone='9874563210';
        cntct.email='newcontact@mail.com';
        insert cntct;    
        }
        
        //Create Outlets
        final List<Account> outletCustList= FSTestFactory.createTestAccount(false,25,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        for(Account acc:outletCustList){
        acc.FS_Headquarters__c = hqCustList.get(0).id;
        acc.FS_ACN__c = '00001673'+count;
        count++;
      }
               Insert outletCustList;
        //Creating cifHead
        cifHead = new CIF_Header__c();
        cifHead.Name =hqCustList[0].name+' V.0';
        cifHead.FS_Version__c = 10.02;
        cifHead.FS_HQ__c=hqCustList[0].id;
        insert cifHead;
        //Creating CIF records
        List<FS_CIF__c> cifLst = new  List<FS_CIF__c>();
        FS_CIF__c cif = new FS_CIF__c();
        cif.CIF_Head__c = cifHead.id;
        cif.FS_Account__c = outletCustList[0].id;
        cif.FS_Headquarters__c =hqCustList[0].id; 
        cifLst.add(cif);
        
        FS_CIF__c cif1 = new FS_CIF__c();
        cif1.CIF_Head__c = cifHead.id;
        //Edited 12 Dec - Assigned different account to cif
        cif1.FS_Account__c = outletCustList[1].id;
        cif1.FS_Headquarters__c =hqCustList[0].id; 
        cifLst.add(cif1);
        
        insert cifLst;
               
        //Creating vendor Account
        Account vendor = new Account();
        vendor.RecordTypeId = FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Vendor');
        vendor.Name = 'Test Vendor';
        vendor.FS_Vendor_Type__c = 'General Contractor';
        insert vendor;
               Test.startTest();
               //Creating Execution Plan
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
               final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,'Execution Plan');
        final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(hqCustList.get(0).Id,false,4,epRecordTypeId);
        executionPlanList.addAll(epList);                                                                     
              
               insert executionPlanList;
        Integer counter = 0;
        final List<FS_Installation__c> installationLst = new  List<FS_Installation__c>();
        //edited 12 Dec - added 8000/9000 series
        final Set<String> installTypes = new Set<String>{'Replacement','New Install','Relocation (O4W)'};
        for(FS_Execution_Plan__c exePlan: executionPlanList)
        {
        for(String recordType : installTypes){
                final id installationType = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,recordType);
                final List<FS_Installation__c> install = FSTestFactory.createTestInstallationPlan(exePlan.id,outletCustList[counter].id,false,1,installationType); 
                installationLst.addAll(install);
               counter++;
            }    
        }
               
        insert installationLst;

        Test.stopTest();
        //Creating Brandset
        brand1 = new FS_Brandset__c();
        brand1.Name = 'Test Brandset';
        brand1.FS_Platform__c ='9000;8000;7000';
        brand1.FS_Date_Brandset_is_available_for_Select__c = Date.Today();
        brand1.FS_Effective_Start_Date__c = Date.Today();
        insert brand1;
         
        //Creating Association Brandsets
        final List<FS_Association_Brandset__c> assBrandLst = new List<FS_Association_Brandset__c>();
        final FS_Association_Brandset__c assbrand7k = new FS_Association_Brandset__c();
        assbrand7k.FS_Platform__c = '7000';
        assbrand7k.FS_Brandset__c = brand1.id;
        assbrand7k.FS_Headquarters__c = hqCustList.get(0).id;
        assBrandLst.add(assbrand7k);
   
        final FS_Association_Brandset__c assbrand8k = new FS_Association_Brandset__c();
        assbrand8k.FS_Platform__c = '8000';
        assbrand8k.FS_Brandset__c = brand1.id;
        assbrand8k.FS_Headquarters__c = hqCustList.get(0).id;
        assBrandLst.add(assbrand8k);
        
        final FS_Association_Brandset__c assbrand9k = new FS_Association_Brandset__c();
        assbrand9k.FS_Platform__c = PLAT9K;
        assbrand9k.FS_Brandset__c = brand1.id;
        assbrand9k.FS_Headquarters__c = hqCustList.get(0).id;
        assBrandLst.add(assbrand9k);
    
        insert assBrandLst;
        
        List<FS_CIF_View_Profiles__c> CIFViewPro = New List<FS_CIF_View_Profiles__c> ();
        FS_CIF_View_Profiles__c CifV_P = New FS_CIF_View_Profiles__c();
        CifV_P.Name = 'Sales Users';
        CifV_P.Profile_Name__c = 'FS Sales_P';
        CIFViewPro.add(CifV_P);
        insert CIFViewPro;
        
         List<FS_CIF_Closed_Status__c> CIFCloseSat = New List<FS_CIF_Closed_Status__c> ();
        FS_CIF_Closed_Status__c CIFCloseS = New FS_CIF_Closed_Status__c();
        CIFCloseS.Name = 'Closed – Cancelled';
        CIFCloseS.Status__c = 'Closed – Cancelled';
        CIFCloseSat.add(CIFCloseS);
        insert CIFCloseSat;
      
    }
   
    //Method to test the loading and searching of outlets in select outlets section
    private static testMethod void testPageLoadUnderHQ(){
     final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
     system.runAs(sysAdmin){
     Test.startTest();
     final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
     cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
     system.assertNotEquals(Null, cifHead);
     //Create Record
     pageLoadUnderHQ(parentRecord.id,cifHead);
     searchOutletTest(parentRecord.id,cifHead);
     //Edit Record
     pageLoadUnderHQ(cifHead.id,cifHead);
     searchOutletTest(cifHead.id,cifHead);
     Test.stopTest();
        }
    }
    
    private static void pageLoadUnderHQ(final Id parentRec,final CIF_Header__c cifHead){
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef); 
      //Add parameters to page URL
      
     ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
      if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
      {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);  
      }
     final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.onLoad();
      system.assertEquals(controller.currentStage,'1.Select Outlets');
      system.assertEquals(controller.lstOutlet.size(),[SELECT count() FROM Account WHERE RecordTypeId=:recTypeOutlet]);
      controller.actionCopyCustomerInput(); 
      controller.goToHQ();
      system.debug('pageLoadUnderHQ() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }
    
    //Method to test Team Members(Section-2) and SA Request Section(Section-3) in create Page
    private static testMethod void testCreateSection23(){
    cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.assertNotEquals(Null, cifHead);
    final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
    final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.passCIF = false;
        controller.onLoadCheck = false; 
               system.runAs(sysAdmin){
               Test.startTest();
        teamMembersSection(parentRecord.id,cifHead);
        siteSurveyRequestSection(parentRecord.id,cifHead);
               Test.stopTest();
     }
    }
    
    //Method to test Team Members(Section-2) and SA Request Section(Section-3) in Edit Page
    private static testMethod void testEditSection23(){
    cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.assertNotEquals(Null, cifHead);
    final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        system.runAs(sysAdmin){
               Test.startTest();
        controller.passCIF = false;
        controller.onLoadCheck = false;
               teamMembersSection(cifHead.id,cifHead);
               siteSurveyRequestSection(cifHead.id,cifHead);
               Test.stopTest();
        }
    }
    
    //Method to test SA Result(Section-4), Installation(Section-5) and Dispenser(Section-6) sections in create page
    private static testMethod void testCreateSection456(){
    cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.assertNotEquals(Null, cifHead);
    final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
    final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
    final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
    final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        system.runAs(sysAdmin){
               Test.startTest();
        controller.passCIF = false;
        controller.onLoadCheck = false;
               siteSurveyResultSection(parentRecord.id,cifHead);
                    installationSection(parentRecord.id,cifHead);
               Test.stopTest();
               dispenserSection(parentRecord.id,cifHead);
        }
    }
    
    //Method to test SA Result(Section-4), Installation(Section-5) and Dispenser(Section-6) sections in edit page
    private static testMethod void testEditSection456(){
    cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
    system.assertNotEquals(Null, cifHead);
    final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        system.runAs(sysAdmin){
               Test.startTest();
               siteSurveyResultSection(cifHead.id,cifHead);   
               installationSection(cifHead.id,cifHead);
               Test.stopTest();
               dispenserSection(cifHead.id,cifHead);
        }
    }

    
    //Method to test Ice maker/water filter(Section-7), Product(Section-8),Training(Section-9) and finance(Section-10) sections in create page
    private static testMethod void testCreateSection7To10(){
    cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.assertNotEquals(Null, cifHead);
    final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
    final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        system.runAs(sysAdmin){
        Test.startTest();
               iceWaterSectionTest(parentRecord.id,cifHead);
               productSection(parentRecord.id,cifHead);
               trainingSection(parentRecord.id,cifHead);
               Test.stopTest();
               financeSection(parentRecord.id,cifHead);
          
    }
    }
    
    //Method to test Ice maker/water filter(Section-7), Product(Section-8),Training(Section-9) and finance(Section-10) sections in edit page
    private static testMethod void testEditSection7To10(){
    cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.assertNotEquals(Null, cifHead);
    final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        system.runAs(sysAdmin){
        Test.startTest();
               iceWaterSectionTest(cifHead.id,cifHead);
               productSection(cifHead.id,cifHead);
               Test.stopTest();
        //trainingSection(cifHead.id,cifHead);
               financeSection(cifHead.id,cifHead);
    }
    }
    
    //Method to test Pagination
    private static testmethod void paginationTest(){
        counter=0;
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
        Integer pageDetails;
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        system.runAs(sysAdmin){
        //Sets the current PageReference for the controller 
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put(ACCID, parentRecord.id);
         ApexPages.currentPage().getParameters().put(ID, cifHead.id);    
        final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        //Selecting Outlets
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
            if(counter<NUM25){
                wrpOutlet.isSelected = true;
            }
            counter++;
        }
        Test.startTest();
        controller.actionCopyCustomerInput();
        controller.navigateAction();
        //Testing Pagination
        if(controller.hasNextPN)
        {
            controller.nextPN();
        }
        pageDetails = controller.LNumberPN;
        system.assertEquals(pageDetails,1);
        pageDetails = controller.UNumberPN;
        system.assertEquals(pageDetails,2);
        pageDetails = controller.RecordCountPN;
        system.assertEquals(pageDetails,2);
        pageDetails = controller.PageNumberPN;
        system.assertEquals(pageDetails,1);
        pageDetails = controller.PageCountPN;
        if(controller.hasPreviousPN)
        {
            controller.previousPN();
            controller.nextPN();
        }
        if(controller.hasFirstPN)
        {
            controller.firstPN();
        }
        if(controller.hasLastPN)
        {
            controller.LastPN();
        }
        system.debug('paginationTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
                Test.stopTest();
        }
    }
    
    private static void teamMembersSection(final Id parentRec,final CIF_Header__c cifHead){
      final Profile fpsProf = FSTestFactory.getProfileId(FPS);
      final User fpsUser = [select id,name from User where profileId =:fpsProf.id Limit 1];
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
      final AccountTeamMember__c comUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c =:COM Limit 1];
      final AccountTeamMember__c salesUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c ='Sales Team Member' Limit 1];
      
        //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
      if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
      {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);
          ApexPages.currentPage().getParameters().put('tab', FSConstants.SALESREPINFO); 
      }
     
     final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
     controller.onLoad();
     for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM5){
          wrpOutlet.isSelected = True;
        }
        counter++;
      }
  
     controller.getCIFOnSave(); 
      
      controller.currentStage = FSConstants.SALESREPINFO;
      controller.navigateAction();
      //Red Chevron
      system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),NOT_STARTED);
      controller.cifHead.FS_Sales_Rep_Name__c = salesUser.id;
      controller.cifHead.FSCOM__c = comUser.id;
      controller.saveDataPop();
      //Yellow chevron
      
      controller.cifHead.FS_Sales_Rep_Name__c = salesUser.id;
      controller.cifHead.FSCOM__c = comUser.id;
      controller.cifHead.FS_FPS__c = fpsUser.id;
      controller.saveDataPop();
      //Green chevron
      
      controller.nextSection();
      controller.previousSection();
      controller.previousSection();
      system.debug('teamMembersSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
                
    }
    
    private static void siteSurveyRequestSection(final Id parentRec,final CIF_Header__c cifHead){
      cntct = [select id,name from Contact Limit 1];
      counter = 0;
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef); 
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
      if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
      {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);
          ApexPages.currentPage().getParameters().put('tab', FSConstants.SITESURVEYREQUEST); 
      }
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.onLoad();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM3){
          wrpOutlet.isSelected = True;
        }
        counter++;
      }
      controller.getCIFOnSave();
      controller.currentStage = FSConstants.SITESURVEYREQUEST;
      controller.navigateAction();
      //Red Chevron
      system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),NOT_STARTED);
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_What_type_of_outlet_install__c = REMODEL;
            cifWrp.cif.FS_Select_Site_assessment_contact__c = cntct.id;
            cifWrp.cif.FS_Platform1__c = PLAT9K;
            cifWrp.cif.FS_Platform1_Qty__c = 15;
            cifWrp.cif.FS_What_type_of_Site_Assessment__c = 'SA Not Required - OSM approval required for local market';
        }
        controller.saveDataPop();
        
        for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_What_type_of_outlet_install__c = REMODEL;
            cifWrp.cif.FS_Select_Site_assessment_contact__c = cntct.id;
            cifWrp.cif.FS_Platform1__c = PLAT9K;
            cifWrp.cif.FS_Platform1_Qty__c = 15;
            cifWrp.cif.FS_What_type_of_Site_Assessment__c = 'Site Assess + GFE bid proposal (traditional)';
            cifWrp.cif.FS_Total_VPO__c = 12;
            cifWrp.cif.FS_JDE_Doc__c = 'Test JDE';
            cifWrp.cif.FS_Work_Order_WO__c = 'Test WO';
            cifWrp.cif.FS_Perf_Site_Assessment__c = 'Yes';
            cifWrp.cif.FS_Davaco_Order_Entered__c = true;
        }
        controller.saveDataPop();
        //Green Chevron
        system.assertnotEquals(controller.viewStateTrackerList.get(controller.currentStage),null);
        controller.nextSection();
        controller.previousSection();
        controller.cancelCIF();
        system.debug('siteSurveyRequestSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    
    }
    
    private static void siteSurveyResultSection(final Id parentRec,final CIF_Header__c cifHead){
      counter = 0;
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef); 
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
      if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
      {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);
          ApexPages.currentPage().getParameters().put('tab', FSConstants.SITESURVEYRESULTS); 
      }
    
     final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
     controller.onLoad();
     for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM3){
          wrpOutlet.isSelected = True;
        }
        counter++;
      }
     controller.getCIFOnSave();
     controller.currentStage = FSConstants.SITESURVEYRESULTS;
     controller.navigateAction();
     //Yellow chevron  
     system.debug('controller.lstOutlet'+controller.lstOutlet);
    // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),IN_PROGRESS);
        if(!controller.lstOutlet.ISEMPTY()){
            controller.lstOutlet[0].cif.FS_Customer_s_disposition_after_review__c = ONHOLD;
     controller.lstOutlet[0].cif.FS_Reason_if_applicable__c = null;
        }
     
     controller.saveDataPop();
     //Yellow Chevron  
    // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),IN_PROGRESS);
     for(WrpOutlet wrpOutlet:controller.lstOutlet){
               wrpOutlet.cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
     }
     controller.saveDataPop();
     //Green Chevron
   //  system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),COMPLETED);
     controller.nextSection();
     controller.previousSection();
     system.debug('siteSurveyResultSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
       
    }
    
    private static void installationSection(final ID parentRec,final CIF_Header__c cifHead){
      cntct = [select id,name from Contact Limit 1];
      final Account vendor = [Select id,name,FS_Vendor_Type__c from Account where FS_Vendor_Type__c = 'General Contractor' Limit 1];
      counter = 0;
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef); 
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRec);
      if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
      {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id); 
          ApexPages.currentPage().getParameters().put('tab', FSConstants.INSTALLATION); 
      }
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.onLoad();
      controller.getselectedaccnamefields();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM3){
          wrpOutlet.isSelected = True;
        }
        counter++;
      }
      controller.getCIFOnSave();
      controller.currentStage = FSConstants.INSTALLATION;
      controller.navigateAction();
      //Red Chevron
      system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),NOT_STARTED);
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_Requested_Install_Period__c =SPECIFICDATE;
            cifWrp.cif.FS_Requested_Install_Date__c = Date.today();
            cifWrp.cif.FS_Day_AM_or_Night_PM_Installation__c = DAY;
            cifWrp.cif.FS_Contractor_Coordination_to_be_done_by__c = COM;
            cifWrp.cif.FS_Contractor_Contact__c = cntct.id;
            cifWrp.cif.FS_General_Contractor_Name__c = vendor.id;
       }
       controller.saveDataPop();
       //Yellow Chevron
      // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),IN_PROGRESS);
       for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_Requested_Install_Period__c =SPECIFICDATE;
            cifWrp.cif.FS_Requested_Install_Date__c = Date.today();
            cifWrp.cif.FS_Day_AM_or_Night_PM_Installation__c = DAY;
            cifWrp.cif.FS_Contractor_Coordination_to_be_done_by__c = COM;
            cifWrp.cif.FS_Contractor_Contact__c = cntct.id;
            cifWrp.cif.FS_General_Contractor_Name__c = vendor.id;
            cifWrp.cif.FS_Outlet_Contact__c = cntct.id;
        }
       controller.saveDataPop();
       //Green Chevron
       //system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),COMPLETED);
       controller.nextSection();
       controller.previousSection();
       system.debug('installationSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }
    
    private static void dispenserSection(final Id parentRec,final CIF_Header__c cifHead){
      counter = 0;
      final FS_Brandset__c brand1 = [select id,name from FS_Brandset__c where FS_Date_Brandset_is_available_for_Select__c =: Date.Today() limit 1];
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef); 
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRec);
      if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
      {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);
          ApexPages.currentPage().getParameters().put('tab', FSConstants.DISPENSEREQUIPMENT); 
      }
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.onLoad();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM3){
          wrpOutlet.isSelected = True;
          wrpOutlet.cif.FS_Platform1__c = '7000';
        }
        counter++;
      }
      controller.getCIFOnSave();
      controller.currentStage = FSConstants.DISPENSEREQUIPMENT;
      controller.navigateAction();
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_Pepper_Mix__c = '< 20%';
            cifWrp.cif.FS_Brandset1__c = brand1.id;
            cifWrp.cif.FS_Any_Crew_Serve_Dispensers__c = YES;
            cifWrp.cif.FS_DryAccount_curently_no_dispnsd_accnt__c = NO;
        }
       controller.saveDataPop();
      
       for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_Pepper_Mix__c = '< 10%';
            cifWrp.cif.FS_Brandset1__c = brand1.id;
            cifWrp.cif.FS_Any_Crew_Serve_Dispensers__c = NO;
            cifWrp.cif.FS_DryAccount_curently_no_dispnsd_accnt__c = YES;
            
        }
        controller.saveDataPop();
        
        controller.nextSection();
        controller.previousSection();
     system.debug('dispenserSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }
    private static void dispenserSection1(final Id parentRec,final CIF_Header__c cifHead){
      counter = 0;
      final FS_Brandset__c brand1 = [select id,name from FS_Brandset__c where FS_Date_Brandset_is_available_for_Select__c =: Date.Today() limit 1];
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef); 
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRec);
      if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
      {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);
          ApexPages.currentPage().getParameters().put('tab', FSConstants.DISPENSEREQUIPMENT); 
      }
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.onLoad();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM3){
          wrpOutlet.isSelected = True;
          wrpOutlet.cif.FS_Platform1__c = '7000';
        }
        counter++;
      }
      controller.getCIFOnSave();
      controller.currentStage = FSConstants.DISPENSEREQUIPMENT;
      controller.navigateAction();
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_Pepper_Mix__c = '< 20%';
            cifWrp.cif.FS_Brandset1__c = brand1.id;
            cifWrp.cif.FS_Any_Crew_Serve_Dispensers__c = YES;
            cifWrp.cif.FS_DryAccount_curently_no_dispnsd_accnt__c = YES;
        }
       controller.saveDataPop();
      
       for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_Pepper_Mix__c = '< 10%';
            cifWrp.cif.FS_Brandset1__c = brand1.id;
            cifWrp.cif.FS_Any_Crew_Serve_Dispensers__c = NO;
            cifWrp.cif.FS_DryAccount_curently_no_dispnsd_accnt__c = YES;
            
        }
        controller.saveDataPop();
        
        controller.nextSection();
        controller.previousSection();
     system.debug('dispenserSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }
    private static void iceWaterSectionTest(final Id parentRec,final CIF_Header__c cifHead){
        counter=0;
        cntct = [select id,name from Contact Limit 1];
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;      
        Test.setCurrentPage(pageRef);
       
               if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
               {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);
          ApexPages.currentPage().getParameters().put('tab', FSConstants.ICEMAKERWATERFILTER);
         
               }
        else
        {
          ApexPages.currentPage().getParameters().put(ACCID, parentRec);   
        }
      
       final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
       final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        
        
        controller.onLoad();
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
            if(counter<NUM5){
                wrpOutlet.isSelected = true;
            }
            counter++;
        }
        
        controller.getCIFOnSave();
        controller.currentStage=FsConstants.ICEMAKERWATERFILTER;
        controller.navigateAction();
        //Red Status
        system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),NOT_STARTED);
        //Yellow Status
        for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_Kitchen_Ice_Fill_Requirements__c = 'Hard';
            cifWrp.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c = 'Scotsman';
            cifWrp.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c = 'MO-0987';
            cifWrp.cif.FS_Who_will_coordinate_Ice_maker_Install__c = COM;
            cifWrp.cif.FS_WhoWillPerformRequiredIceMakerWork__c = CUSTOMER;
            cifWrp.cif.FS_Is_an_approved_Water_Filter_Installed__c = 'No - approved make/model to be installed';
            cifWrp.cif.FS_Water_Filter_MFG__c = 'Selecto';
            cifWrp.cif.FS_Water_Filter_Model_no__c = 'MO-12345';
            cifWrp.cif.FS_Who_will_install_Water_Filter__c = CUSTOMER;
            cifWrp.cif.FS_Water_Filter_Contact_Name__c = cntct.id;
        }
        
        controller.saveDataPop();
        
        //Green Status
        for(WrpOutlet cifWrp:controller.lstOutlet)
        {
            cifWrp.cif.FS_Kitchen_Ice_Fill_Requirements__c = 'Soft';
            cifWrp.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c = 'Scotsman';
            cifWrp.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c = 'MO-0987';
            cifWrp.cif.FS_Who_will_coordinate_Ice_maker_Install__c = COM;
            cifWrp.cif.FS_WhoWillPerformRequiredIceMakerWork__c = CUSTOMER;
            cifWrp.cif.FS_Is_an_approved_Water_Filter_Installed__c = 'Yes – approved water filter is installed';
            cifWrp.cif.FS_Water_Filter_MFG__c = 'Selecto';
            cifWrp.cif.FS_Water_Filter_Model_no__c = 'MO-12345';
            cifWrp.cif.FS_Who_will_install_Water_Filter__c = CUSTOMER;
            cifWrp.cif.FS_Water_Filter_Contact_Name__c = cntct.id;
            cifWrp.cif.Water_Filter_Installer_Name__c = cntct.id;
        }
        controller.saveDataPop();
        
        //Navigating to next Section from IceMaker/WaterFilter Section
        controller.nextSection();
        //Navigating to Previous Section IceMaker/WaterFilter
        controller.previousSection();
        //Going back to HQ
        controller.getHQDetails();
       system.debug('iceWaterSectionTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    
    }
    
    private static void productSection(final Id parentRec,final CIF_Header__c cifHead){
               cntct = [select id,name from Contact Limit 1];
        final PageReference pageRef = Page.FSCustomerInputForm;
        Integer counter=0;
        //Sets the current PageReference for the controller
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
               if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
               {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);
          ApexPages.currentPage().getParameters().put('tab', FSConstants.PRODUCT);
               }
        final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM5){
          wrpOutlet.isSelected = true;
        }
        counter++;
      }
    
        controller.getCIFOnSave();
        controller.currentStage= FSConstants.PRODUCT;
        controller.navigateAction();
        //Yellow Status
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
          wrpOutlet.cif.FS_Name_of_Sweetener_Distributor__c = 'Distributor';
          wrpOutlet.cif.FS_Distributor_Name_City_ST__c = 'Test Distributor';
          wrpOutlet.cif.FS_Order_Administrator__c = cntct.id;
          wrpOutlet.cif.FS_Order_Standard_User__c = cntct.id;
          wrpOutlet.cif.FS_Delivery_Method__c = FSConstants.STRING_NULL;
          wrpOutlet.cif.FS_Cartridge_Order_Method__c = 'VMS';
          wrpOutlet.cif.FS_Distributor_State__c = 'KO';
          wrpOutlet.cif.FS_Distributor_City__c = 'aaa';
        }
        controller.saveDataPop();
       // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),IN_PROGRESS);
        //Green Status
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
          wrpOutlet.cif.FS_Name_of_Sweetener_Distributor__c = 'Distributor';
          wrpOutlet.cif.FS_Distributor_Name_City_ST__c = 'Test Distributor';
          wrpOutlet.cif.FS_Order_Administrator__c = cntct.id;
          wrpOutlet.cif.FS_Order_Standard_User__c = cntct.id;
          wrpOutlet.cif.FS_Cartridge_Order_Method__c = 'VMS';
          wrpOutlet.cif.FS_Delivery_Method__c = 'Direct Ship';
          wrpOutlet.cif.FS_Distributor_State__c = 'KO';
          wrpOutlet.cif.FS_Distributor_City__c = 'aaa';
        }
        controller.saveDataPop();
       // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),COMPLETED);
        controller.nextSection();
        controller.previousSection();
        system.debug('productSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    
    }
    
    private static void trainingSection(final Id parentRec,final CIF_Header__c cifHead){
        
        //Sets the current PageReference for the controller
        cntct = [select id,name from Contact Limit 1];
        final PageReference pageRef = Page.FSCustomerInputForm;
        counter=0;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
        if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
        {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id); 
          ApexPages.currentPage().getParameters().put('tab', FSConstants.TRAINING);
        }
        final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM5){
          wrpOutlet.isSelected = true;
        }
        counter++;
      }
     
        controller.getCIFOnSave();
        controller.currentStage= FSConstants.TRAINING;
        controller.navigateAction();
        system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),NOT_STARTED);
        //Yellow Status
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
          wrpOutlet.cif.FS_OB_Trainer__c=COM;
          wrpOutlet.cif.FS_On_Boarding_Days_after_Install__c = '6';
          wrpOutlet.cif.FS_Select_On_Boarding_Start_Time__c = '9:30 AM';
          wrpOutlet.cif.FS_On_boarding_time_requested__c = '8:00 AM';
          }
        controller.saveDataPop();
       // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),IN_PROGRESS);
        //Green Status
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
          wrpOutlet.cif.FS_OB_Trainer__c=COM;
          wrpOutlet.cif.FS_On_Boarding_Days_after_Install__c = '9';
          wrpOutlet.cif.FS_Select_On_Boarding_Start_Time__c = '9:30 AM';
          wrpOutlet.cif.FS_On_boarding_time_requested__c = '7:30 AM';
          wrpOutlet.cif.FS_On_Boarding_Contact__c = cntct.id;
        }
        controller.saveDataPop();
       // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),COMPLETED);
        controller.nextSection();
        controller.previousSection();
        controller.currentStage = FSConstants.SELECTOUTLETS;
        controller.lstOutlet[0].isSelected = false;
        controller.actionCopyCustomerInput();
    system.debug('TrainingSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }
    
    private static void financeSection(final Id parentRec,final CIF_Header__c cifHead){
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        counter=0;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
        if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
        {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);
          ApexPages.currentPage().getParameters().put('tab', FSConstants.FINANCE);
        }
        final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM5){
          wrpOutlet.isSelected = true;
        }
        counter++;
       }
        controller.getCIFOnSave();
        controller.currentStage= FSConstants.FINANCE;
        controller.navigateAction();
        system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),NOT_STARTED);
        //Yellow Status
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
          wrpOutlet.cif.FS_Cartridge_Payment_Method__c=BANKDRAFT;
         }
        controller.saveDataPop();
       // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),IN_PROGRESS);
        //Green Status
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
          wrpOutlet.cif.FS_Cartridge_Payment_Method__c=BANKDRAFT;
          wrpOutlet.cif.FS_Program_Fee_Payment_Method__c = 'Credit Card';
        }
        controller.saveDataPop();
       // system.assertEquals(controller.viewStateTrackerList.get(controller.currentStage),COMPLETED);
        controller.nextSection();
        controller.summarySec();
        controller.navigateAction();
        controller.previousSection();
                system.debug('financeSection() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }

    //Method to test workbook upload without file and with valid file
    private static testMethod void testWorkBookUpload(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
      final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
      system.runAs(sysAdmin){
      Test.startTest();
      final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRecord.Id);
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.onLoad();
      controller.showPopup();
      //Uploading without csv file
      controller.getreadFromFile();
      //create parent csv Holder
      final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
      holder.FS_WorkBook_Name__c='CIF WorkBook';
      insert holder;
      //Modified as part of FET-7.1 FNF 1019  
            final string uplFile = 'Workbook,Sales Email,Operations Manager Email,Outlet ACN#,Bill-To Street Address,Bill-To City,Bill-To State,Bill-To ZIP,Bill-To Phone,Mail-To Street Address,Mail-To City,Mail-To State,Mail-To ZIP,Outlet Contact Name ,Outlet Phone Number,Channel,Product Billing Set Up,Estimated Gallons,Site Assessment Requirements,SA Contact Email,Platform 1,Quantity 1,Platform 2,Quantity 2,Platform 3,Quantity 3,Brandset 1,Brandset 2,Brandset 3,Dasani 1,Dasani 2,Dasani 3,Color of 9000,# Top-Mounted Ice Makers (9000),# Top-Mounted Ice Makers (7000),7000/7100 HFCS/Sweetener location,Installation Type,Describe any known construction needs?,Contractor Coordination done by,General Contractor,GC Email,Outlet Construction Contact Email,Pepper Mix,Water Button Option 9000,Water Button Option 8000,Water Button Option 7000,Time to call home,Wired Solutions Required,ValidFill Option,Crew Serve,Portion Control Setting,Customer\'s Ice Fill Policy,Top-Off Feature,size 1,cup name 1,fl oz 1,size 2,cup name 2,fl oz 2,size 3,cup name 3,fl oz 3,size 4,cup name 4,fl oz 4,size 5,cup name 5,fl oz 5,size 6,cup name 6,fl oz 6,Provide On-Boarding Contact Email,On-Boarding Trainer,On-Boarding - Days after Install,Requested training start time,Outlet Open Time,Training Comments,Requested Cartridge Order Method,Admin User Email,Standard User Email,Distributor Name,DistributorCity,Distributor State,Cartridge Payment Method,Program Fee Payment Method,Remove All FTN (Legacy) Serve Dispensers?,Product Comments,Installation Contact Email,Install Period,Install Date,Day or Night Install,Projected Opening,Line Installation,Equipment Install,Projected Fire-Up,DRY ACCOUNT,Is an approved Water Filter installed?,Water Filter Outlet Contact Email,Water Filter Installer Contact Email,Water Filter Manufacturer,Water Filter Model #,Water Filter Installer,Ice Fill Method,Top Mounted Ice Maker Manufacturer,Ice Maker Model,Who will coordinate Ice Maker install?,Ice Maker Installer,Who will provide ice maker,What type of ice is used for Manual Fill?,Ownership of current Fountain Equipment,Disposition of current Fountain Equipment,Disposition of Current BIB Rack,Disposition of Current BIB Pump,Ice maker and water filter comments,Please list any ancillary equipment to remain on-site,Ancillary equipment needed,Dispenser comments'
                        +'\n'+'CIF workbook upload test,test-00e61000000ixt4@testdomain.com,test-00e61000000ixt4@testdomain.com,167324,Ind,Mysore,GA,234567,nhoj,Ind,Mysore,GA,234567,John,nhoj,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,newcontact@mail.com,9000,89,8000,21,7000,10,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 05 - Pibb/Hi-C/Rasp,Hide,Hide,Hide,Red,23,32,7000 HFCS location,New Construction,Construction 1,Coca-Cola Freestyle Project Team,Wendy\'s International-Tommy Morgan,newcontact@mail.com,newcontact@mail.com,> 20%,Hide,Show,Hide,2:00 AM,Yes,Yes,Yes,Yes,50%,Yes,12,fg,12,12,fg,21,12,fg,12,2,fg,12,12,gf,12,2,fg,2,newcontact@mail.com,EcoSure,3,6:00 AM,6:30 AM,Training comments,VMS,newcontact@mail.com,newcontact@mail.com,sa,sa,as,Invoice (Payment Terms),Invoice (Payment Terms),No,Product comments,newcontact@mail.com,Week of?,2/25/2017,Night - typically 10pm start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,No - approved make/model to be installed,newcontact@mail.com,newcontact@mail.com,Ecolab,mo-098,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,Customer ,Approved soft,Bottler,Return to KO warehouse,Return to bottler warehouse,Return to KO warehouse,Ice maker and water filter comments,Please list any ancillary equip needed,Ancillary equip needed,Dispenser comments'  +'\n';   
                
      //create Attachment
      final Attachment file= new Attachment();
      file.Body= Blob.valueof(uplFile);
      file.ContentType = 'text/csv';
      file.parentId = holder.Id;
      file.Name='CIF WorkBook.csv'; 
      insert file;
      controller.cifCsvFileBody= file.body;
      controller.cifCsvFileName = file.name;
      controller.getreadFromFile();
      controller.closePopup();
      controller.getCIFOnSave();
      system.assertEquals(controller.lstOutlet.size(),1);
      system.debug('testWorkBookUpload() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
      Test.stopTest();
      }
    }
    
    //Method to test workbook upload with invalid file
    private static testMethod void testWorkBookUploadInvalid(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
      //Sets the current PageReference for the controller
     final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
      final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
      system.runAs(sysAdmin){
      Test.startTest();
      final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRecord.Id);
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.onLoad();
                    
      controller.showPopup();
            
      //create parent csv Holder
      final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
      holder.FS_WorkBook_Name__c='CIF WorkBook';
      insert holder;
      //Modified as part of FET-7.1 FNF 1019   
           final string uplFile = 'Workbook,Sales Email,Operations Manager Email,Outlet ACN#,Bill-To Street Address,Bill-To City,Bill-To State,Bill-To ZIP,Bill-To Phone,Mail-To Street Address,Mail-To City,Mail-To State,Mail-To ZIP,Outlet Contact Name ,Outlet Phone Number,Channel,Product Billing Set Up,Estimated Gallons,Site Assessment Requirements,SA Contact Email,Platform 1,Quantity 1,Platform 2,Quantity 2,Platform 3,Quantity 3,Brandset 1,Brandset 2,Brandset 3,Dasani 1,Dasani 2,Dasani 3,Color of 9000,# Top-Mounted Ice Makers (9000),# Top-Mounted Ice Makers (7000),7000/7100 HFCS/Sweetener location,Installation Type,Describe any known construction needs?,Contractor Coordination done by,General Contractor,GC Email,Outlet Construction Contact Email,Pepper Mix,Water Button Option 9000,Water Button Option 8000,Water Button Option 7000,Time to call home,Wired Solutions Required,ValidFill Option,Crew Serve,Portion Control Setting,Customer\'s Ice Fill Policy,Top-Off Feature,size 1,cup name 1,fl oz 1,size 2,cup name 2,fl oz 2,size 3,cup name 3,fl oz 3,size 4,cup name 4,fl oz 4,size 5,cup name 5,fl oz 5,size 6,cup name 6,fl oz 6,Provide On-Boarding Contact Email,On-Boarding Trainer,On-Boarding - Days after Install,Requested training start time,Outlet Open Time,Training Comments,Requested Cartridge Order Method,Admin User Email,Standard User Email,Distributor Name,DistributorCity,Distributor State,Cartridge Payment Method,Program Fee Payment Method,Remove All FTN (Legacy) Serve Dispensers?,Product Comments,Installation Contact Email,Install Period,Install Date,Day or Night Install,Projected Opening,Line Installation,Equipment Install,Projected Fire-Up,DRY ACCOUNT,Is an approved Water Filter installed?,Water Filter Outlet Contact Email,Water Filter Installer Contact Email,Water Filter Manufacturer,Water Filter Model #,Water Filter Installer,Ice Fill Method,Top Mounted Ice Maker Manufacturer,Ice Maker Model,Who will coordinate Ice Maker install?,Ice Maker Installer,Who will provide ice maker,What type of ice is used for Manual Fill?,Ownership of current Fountain Equipment,Disposition of current Fountain Equipment,Disposition of Current BIB Rack,Disposition of Current BIB Pump,Ice maker and water filter comments,Please list any ancillary equipment to remain on-site,Ancillary equipment needed,Dispenser comments'
                        +'\n'+'CIF workbook upload test,test-00e61000000ixt4@testdomain.com,test-00e61000000ixt4@testdomain.com,167352,Ind,Mysore,GA,234567,nhoj,Ind,Mysore,GA,234567,John,nhoj,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,newcontact@mail.com,9000,89,8000,21,7000,10,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 05 - Pibb/Hi-C/Rasp,0,0,0,Red,23,32,0,New Construction,Construction 1,Coca-Cola Freestyle Project Team,Wendy\'s International-Tommy Morgan,newcontact@mail.com,newcontact@mail.com,> 20%,Hide,Show,0,,0,0,Yes,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,newcontact@mail.com,EcoSure,3,6:00 AM,6:30 AM,0,VMS,newcontact@mail.com,newcontact@mail.com,sa,sa,as,Invoice (Payment Terms),Invoice (Payment Terms),No,0,newcontact@mail.com,Week of?,2/25/2017,Night - typically 10pm start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,No - approved make/model to be installed,newcontact@mail.com,newcontact@mail.com,Ecolab,mo-098,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,Customer ,Approved soft,Bottler,Return to KO warehouse,Return to bottler warehouse,Return to KO warehouse,0,0,0,0'  +'\n';   
       
       //create Attachment
       final Attachment file= new Attachment();
       file.Body= Blob.valueof(uplFile);
       file.ContentType = 'image/png';
       file.parentId = holder.Id;
       file.Name='CIF WorkBook.jpg'; 
       insert file;
       controller.cifCsvFileBody= file.body;

       //Uploading invalid file
       controller.cifCsvFileName = file.name;
       controller.getreadFromFile();
       controller.closePopup();
       controller.getCIFOnSave();
       system.assertEquals(controller.lstOutlet.size(),25);
       system.debug('testWorkBookUploadInvalid() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
       Test.stopTest();
      }
    }
      //
    private static testMethod void testWorkBookUploadInvalid1(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.assertNotEquals(Null, cifHead);
        cifHead.FS_Status__c = 'Closed – Cancelled';
        update cifHead;
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
      final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          final Profile FSSales_P=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SALES_P);
        final User FSSales_User=FSTestFactory.createUser(FSSales_P.id);
     
      final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
      //Add parameters to page URL
       system.runAs(FSSales_User){
      Test.startTest();
      ApexPages.currentPage().getParameters().put(ACCID, parentRecord.Id);
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.onLoad();
    system.debug('testWorkBookUploadInvalid() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
       Test.stopTest();
      }
    }
    //Method to test cancelled CIF
    public static testmethod void cancelledCIFTest(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
      //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final User sysAdmin = FSTestFactory.createUser(FSTestFactory.getProfileId('FS AC_P').id);
        system.runAs(sysAdmin){
         Test.startTest();
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
           //Add parameters to page URL
           // ApexPages.currentPage().getParameters().put(ACCID, parentRecord.Id);
        ApexPages.currentPage().getParameters().put(ID, cifHead.Id);
        ApexPages.currentPage().getParameters().put('tab', FSConstants.SELECTOUTLETS);
        final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM2){
          wrpOutlet.isSelected = true;
        }
        counter++;
      }
        controller.getCIFOnSave();
        controller.currentStage= FSConstants.SITESURVEYRESULTS;
        controller.navigateAction();
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
            wrpOutlet.cif.FS_Customer_s_disposition_after_review__c = 'Cancelled';
            wrpOutlet.cif.FS_Reason_if_applicable__c = REASON;
          }
        
        controller.saveDataPop();
        controller.cancelHeader();
        controller.cifHead = controller.cifNE.getCIFHeaderDetails(controller.currentCIFId);
        system.assertEquals(controller.cifHead.FS_Status__c, FSConstants.CLCANCELLED);
       
        controller.onLoad();
        system.debug('cancelledCIFTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        Test.stoptest();
        }     
    }
    
    //Method to test Not Approved CIF
    public static testmethod void notApprovedCIFTest(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
      //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        system.runAs(sysAdmin){
         Test.startTest();
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
           //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(ACCID, parentRecord.Id);
            ApexPages.currentPage().getParameters().put(ID, cifHead.Id);
           final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
            final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
            //controller.passCIF = false;
            controller.onLoadCheck = true;
            controller.onLoad();
            for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM2){
          wrpOutlet.isSelected = true;
        }
        counter++;
      }
        controller.getCIFOnSave();
        controller.currentStage= FSConstants.SITESURVEYRESULTS;
        controller.navigateAction();
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
            wrpOutlet.cif.FS_Customer_s_disposition_after_review__c = 'Not Approved';
            wrpOutlet.cif.FS_Reason_if_applicable__c = REASON;
          }
        controller.saveDataPop();
                                controller.cancelHeader();
        controller.cifHead = controller.cifNE.getCIFHeaderDetails(controller.currentCIFId);
        system.assertEquals(controller.cifHead.FS_Status__c, FSConstants.CLNOTAPPROVED);
        ApexPages.currentPage().getParameters().put(ID, controller.cifHead.Id);
        system.assertEquals(controller.currentURLParm,null);
        controller.onLoad();
        system.debug('notApprovedCIFTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        Test.stoptest();
        }    
    }
    
    
    //Method to test both Cancelled and NA CIF
    public static testmethod void cancelledNotApprovedCIFTest(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
      //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
               system.runAs(sysAdmin){
         Test.startTest();
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
           //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(ACCID, parentRecord.Id);
            final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
            final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
            controller.passCIF = true;
            controller.onLoad();
            for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM2){
          wrpOutlet.isSelected = true;
        }
        counter++;
      }
        controller.passCIF = true;
        controller.getCIFOnSave();
        controller.currentStage= FSConstants.SITESURVEYRESULTS;
        controller.navigateAction();
        for(WrpOutlet wrpOutlet:controller.lstOutlet){
            wrpOutlet.cif.FS_Customer_s_disposition_after_review__c = 'Not Approved';
            wrpOutlet.cif.FS_Reason_if_applicable__c = REASON;
          }
        controller.lstOutlet[0].cif.FS_Customer_s_disposition_after_review__c = 'Cancelled';
        controller.saveDataPop();
        controller.passCIF = true;
        controller.cancelHeader();
        controller.cifHead = controller.cifNE.getCIFHeaderDetails(controller.currentCIFId);
        system.assertEquals(controller.cifHead.FS_Status__c, FSConstants.CLOSEDCANNOTAPP);
        ApexPages.currentPage().getParameters().put(ID, controller.cifHead.Id);
        system.assertEquals(controller.currentURLParm,null);
        controller.passCIF = true;
        controller.onLoad();
        system.debug('cancelledNotApprovedCIFTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        Test.stoptest();
        }
            
    }
    
    //Method to test search outlets
    private static void searchOutletTest(final Id parentRec,final CIF_Header__c cifHead){
       
       //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
           //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(ACCID, parentRec); 
      if(parentRec.getSobjectType().getDescribe().getName() != ACCOUNTSTR)
      {
          ApexPages.currentPage().getParameters().put(ID, cifHead.id);  
      }
            final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
            final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
            controller.onLoad();
               system.assertEquals(controller.lstoutlet.size(), 25);
            //Searching outlets without providing search data
                controller.searchOutlet();
                controller.searchOutletCity = 'xxx';
                controller.searchOutletName = 'yyy';
                controller.searchOutletACN = '00016735';
                controller.searchOutletState = 'MO';
                controller.searchOutlet();
                controller.searchOutletButton();
                controller.resetSearchStatus();
                controller.cancelCIF();
       
    }
    //Method to test create EP without Team members
    private static testmethod void createEPwithoutTeamMemTest()
    {
      final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
      
      final AccountTeamMember__c comUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c =:COM Limit 1];
      final AccountTeamMember__c salesUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c ='Sales Team Member' Limit 1];
      counter = 0;
      CIF_Header__c cifHeadstd = new CIF_Header__c();
      cifHeadstd.FS_HQ__c = parentRecord.id;
      insert cifHeadstd;
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
      final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
               system.runAs(sysAdmin){  
        //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRecord.id);
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHeadstd);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.passCIF = true;
      controller.onLoad();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM5){
          wrpOutlet.isSelected = True;
        }
        counter++;
      }
     Test.startTest();
      controller.getCIFOnSave(); 
      controller.cifHead.FS_Sales_Rep_Name__c = salesUser.id;
      controller.cifHead.FSCOM__c = comUser.id;
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
        cifWrp.cif.FS_What_type_of_outlet_install__c = REMODEL;
            cifWrp.cif.FS_Platform1__c = PLAT9K;
            cifWrp.cif.FS_Platform1_Qty__c = 15;
            cifWrp.cif.FS_What_type_of_Site_Assessment__c = 'Site Assess + GFE bid proposal (traditional)';
            cifWrp.cif.FS_Total_VPO__c = 12;
         }
        controller.lstOutlet.get(0).cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
        controller.passCIF = true;
        controller.saveData();
        controller.summarySec();
        controller.passCIF = true;
        controller.createEP();
        system.assertEquals(controller.lstOutletEP.size(), 5);
        controller.passCIF = true;
        controller.mandCheck();
        controller.passCIF = true;
        controller.mandChecktrue1();
        system.debug('createEPwithoutTeamMemTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        Test.stopTest(); 
        }
    }
    //Method to test create EP with less mandatory fields filled
    private static testmethod void createEPLessMandTest(){
      final Profile fpsProf = FSTestFactory.getProfileId(FPS);
      final User fpsUser = [select id,name from User where profileId =:fpsProf.id Limit 1];
      final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
      
      final AccountTeamMember__c comUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c =:COM Limit 1];
      final AccountTeamMember__c salesUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c ='Sales Team Member' Limit 1];
      counter = 0;
      CIF_Header__c cifHeadstd = new CIF_Header__c();
      cifHeadstd.FS_HQ__c = parentRecord.id;
      insert cifHeadstd;
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
               system.runAs(sysAdmin){
        //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRecord.id);
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHeadstd);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
                  controller.passCIF = true;           
      controller.onLoad();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM5){
          wrpOutlet.isSelected = True;
        }
        counter++;
     }
     Test.startTest();
      controller.getCIFOnSave(); 
      controller.cifHead.FS_Sales_Rep_Name__c = salesUser.id;
      controller.cifHead.FSCOM__c = comUser.id;
      controller.cifHead.FS_FPS__c = fpsUser.id;
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
        cifWrp.cif.FS_What_type_of_outlet_install__c = REMODEL;
            cifWrp.cif.FS_Platform1__c = PLAT9K;
            cifWrp.cif.FS_Platform1_Qty__c = 15;
            cifWrp.cif.FS_What_type_of_Site_Assessment__c = 'Site Assess + GFE bid proposal (traditional)';
            cifWrp.cif.FS_Total_VPO__c = 12;
         }
        controller.lstOutlet.get(0).cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
        controller.lstOutlet.get(1).cif.FS_Customer_s_disposition_after_review__c = ONHOLD;
        controller.lstOutlet.get(1).cif.FS_Reason_if_applicable__c = REASON;
               controller.saveData();
        controller.summarySec();
        controller.getSummaryReport();
        controller.createEP();
        system.assertEquals(controller.lstOutletEP.size(), 5);
        controller.mandCheck();
        controller.passCIF = true;
        controller.mandChecktrue1();
        
        Test.stopTest();
        }
    }
    
    //Method to test create EP with all mandatory fields
    private static testmethod void createEPAllMandTest(){
      final Profile fpsProf = FSTestFactory.getProfileId(FPS);
      final User fpsUser = [select id,name from User where profileId =:fpsProf.id Limit 1];
      final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
      
      final AccountTeamMember__c comUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c =:COM Limit 1];
      final AccountTeamMember__c salesUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c ='Sales Team Member' Limit 1];
      cntct = [select id,name from Contact Limit 1];
      final Account vendor = [Select id,name from Account where RecordTypeId = :recTypeVendor Limit 1];
      
        counter = 0;
        CIF_Header__c cifHeadstd = new CIF_Header__c();
      cifHeadstd.FS_HQ__c = parentRecord.id;
      insert cifHeadstd;
        system.assertNotEquals(Null, cifHeadstd.id);
      final FS_Brandset__c brand1 = [select id,name from FS_Brandset__c where FS_Date_Brandset_is_available_for_Select__c =: Date.Today() limit 1];
        //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
               system.runAs(sysAdmin){
        //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ACCID, parentRecord.id);
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHeadstd);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.passCIF = true;
      controller.onLoadCheck = false;
      controller.onLoad();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM5){
          wrpOutlet.isSelected = True;
        }
        counter++;
      }
     Test.startTest();
     controller.passCIF = true;
     controller.onLoadCheck = false;
     controller.getCIFOnSave(); 
      controller.cifHead.FS_Sales_Rep_Name__c = salesUser.id;
      controller.cifHead.FSCOM__c = comUser.id;
      controller.cifHead.FS_FPS__c = fpsUser.id;
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
        cifWrp.cif.FS_What_type_of_outlet_install__c = REMODEL;
            cifWrp.cif.FS_Select_Site_assessment_contact__c = cntct.id;
            cifWrp.cif.FS_Platform1__c = PLAT9K;
            cifWrp.cif.FS_Platform1_Qty__c = 15;
            cifWrp.cif.FS_What_type_of_Site_Assessment__c = 'Site Assess + GFE bid proposal (traditional)';
            cifWrp.cif.FS_Total_VPO__c = 12;
            cifWrp.cif.FS_JDE_Doc__c = 'Test JDE';
            cifWrp.cif.FS_Work_Order_WO__c = 'Test WO';
            cifWrp.cif.FS_Perf_Site_Assessment__c = 'Yes';
            cifWrp.cif.FS_Davaco_Order_Entered__c = true;
            cifWrp.cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
            cifWrp.cif.FS_Requested_Install_Period__c =SPECIFICDATE;
            cifWrp.cif.FS_Requested_Install_Date__c = Date.today();
            cifWrp.cif.FS_Day_AM_or_Night_PM_Installation__c = DAY;
            cifWrp.cif.FS_Contractor_Coordination_to_be_done_by__c = COM;
            cifWrp.cif.FS_Contractor_Contact__c = cntct.id;
            cifWrp.cif.FS_General_Contractor_Name__c = vendor.id;
            cifWrp.cif.FS_Outlet_Contact__c = cntct.id;
            cifWrp.cif.FS_Pepper_Mix__c = '< 20%';
            cifWrp.cif.FS_Brandset1__c = brand1.id;
            cifWrp.cif.FS_Any_Crew_Serve_Dispensers__c = NO;
            cifWrp.cif.FS_DryAccount_curently_no_dispnsd_accnt__c = YES;
            cifWrp.cif.FS_Kitchen_Ice_Fill_Requirements__c = 'Hard';
            cifWrp.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c = 'Follett';
            cifWrp.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c = 'MO-098';
            cifWrp.cif.FS_Who_will_coordinate_Ice_maker_Install__c = 'Sales';
            cifWrp.cif.FS_WhoWillPerformRequiredIceMakerWork__c = CUSTOMER;
            cifWrp.cif.FS_Is_an_approved_Water_Filter_Installed__c = 'Yes – approved water filter is installed';
            cifWrp.cif.FS_Water_Filter_MFG__c = 'Ecolab';
            cifWrp.cif.FS_Water_Filter_Model_no__c = 'MO-1234';
            cifWrp.cif.FS_Who_will_install_Water_Filter__c = CUSTOMER;
            cifWrp.cif.FS_Water_Filter_Contact_Name__c = cntct.id;
            cifWrp.cif.Water_Filter_Installer_Name__c = cntct.id;
            cifWrp.cif.FS_Name_of_Sweetener_Distributor__c = 'Bottler';
            cifWrp.cif.FS_Distributor_Name_City_ST__c = 'Test Distributor Co2';
            cifWrp.cif.FS_Order_Administrator__c = cntct.id;
            cifWrp.cif.FS_Order_Standard_User__c = cntct.id;
            cifWrp.cif.FS_Cartridge_Order_Method__c = 'CokeSmart';
            cifWrp.cif.FS_Delivery_Method__c = 'Direct Ship';
            cifWrp.cif.FS_Distributor_State__c = 'MO';
            cifWrp.cif.FS_Distributor_City__c = 'aaaStreet';
            cifWrp.cif.FS_OB_Trainer__c=COM;
            cifWrp.cif.FS_On_Boarding_Days_after_Install__c = '2';
            cifWrp.cif.FS_Select_On_Boarding_Start_Time__c = '6:30 AM';
            cifWrp.cif.FS_On_boarding_time_requested__c = '7:30 AM';
            cifWrp.cif.FS_On_Boarding_Contact__c = cntct.id;
            cifWrp.cif.FS_Cartridge_Payment_Method__c=BANKDRAFT;
            cifWrp.cif.FS_Program_Fee_Payment_Method__c = 'Credit Card';
            cifWrp.cif.Does_Install_Involve_RO4W__c='No';
        }
        controller.lstOutlet.get(0).cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
        controller.lstOutlet.get(1).cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
        controller.passCIF = true;
        controller.onLoadCheck = false;
        controller.saveData();
        controller.summarySec();
        controller.getSummaryReport();
        controller.passCIF = true;
        controller.onLoadCheck = false;
        controller.createEP();
        controller.lstOutletEP.get(0).isSelected = false;
        controller.passCIF = true;
        controller.onLoadCheck = false;
        controller.mandCheck();
        controller.passCIF = true;
        controller.onLoadCheck = false;
        controller.mandChecktrue1();
        system.debug('createEPAllMandTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        Test.stopTest();
        }
    }
    
    //Method to test migrate EP
    private static testmethod void updateMigratedEPTest(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
      final Profile fpsProf = FSTestFactory.getProfileId(FPS);
      final User fpsUser = [select id,name from User where profileId =:fpsProf.id Limit 1];
      final FS_Execution_Plan__c exePlan=[Select id from FS_Execution_Plan__c where recordtypeId=:exeRecId limit 1];
      final FS_Brandset__c brand1 = [select id,name from FS_Brandset__c where FS_Date_Brandset_is_available_for_Select__c =: Date.Today() limit 1];  
      final AccountTeamMember__c comUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c =:COM Limit 1];
      final AccountTeamMember__c salesUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c ='Sales Team Member' Limit 1];
      cntct = [select id,name from Contact Limit 1];
      final Account vendor = [Select id,name from Account where RecordTypeId = :recTypeVendor Limit 1];
      counter = 0;
     
      final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
     
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
               system.runAs(sysAdmin){
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ID, cifHead.id);
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.passCIF = true;
      controller.onLoad();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM2){
          wrpOutlet.isSelected = True;
        }
       counter++;
      }
     Test.startTest();
      controller.getCIFOnSave();
      controller.summarySec(); 
      controller.cifHead.FS_Sales_Rep_Name__c = salesUser.id;
      controller.cifHead.FSCOM__c = comUser.id;
      controller.cifHead.FS_FPS__c = fpsUser.id;
      controller.cifHead.FS_EP__c = exePlan.id;
      controller.cifHead.FS_Status__c = 'In Progress';
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
        cifWrp.cif.FS_What_type_of_outlet_install__c = REMODEL;
            cifWrp.cif.FS_Select_Site_assessment_contact__c = cntct.id;
            cifWrp.cif.FS_Platform1__c ='7000' ;
            cifWrp.cif.FS_Platform1_Qty__c = 15;
            cifWrp.cif.FS_Platform2__c = '8000';
            //cifWrp.cif.FS_Platform3__c = '7000';
            cifWrp.cif.FS_What_type_of_Site_Assessment__c = 'Site Assess + GFE bid proposal (traditional)';
            cifWrp.cif.FS_Total_VPO__c = 12;
            cifWrp.cif.FS_JDE_Doc__c = 'Test JDE';
           cifWrp.cif.FS_Work_Order_WO__c = 'Test WO';
            cifWrp.cif.FS_Perf_Site_Assessment__c = 'Yes';
            cifWrp.cif.FS_Davaco_Order_Entered__c = true;
            cifWrp.cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
            cifWrp.cif.FS_Requested_Install_Period__c =SPECIFICDATE;
            cifWrp.cif.FS_Requested_Install_Date__c = Date.today();
            cifWrp.cif.FS_Day_AM_or_Night_PM_Installation__c = DAY;
            cifWrp.cif.FS_Contractor_Coordination_to_be_done_by__c = COM;
            cifWrp.cif.FS_Contractor_Contact__c = cntct.id;
            cifWrp.cif.FS_General_Contractor_Name__c = vendor.id;
            cifWrp.cif.FS_Outlet_Contact__c = cntct.id;
            cifWrp.cif.FS_Pepper_Mix__c = '< 10%';
            cifWrp.cif.FS_Brandset1__c = brand1.id;
            cifWrp.cif.FS_Water1__c = 'Hide';
            //cifWrp.cif.FS_Dasani1__c = 'Hide';
            //cifWrp.cif.FS_7000_Series_Top_Mnt_Ice_Maker_Instld__c = 7;
            cifWrp.cif.FS_Any_Crew_Serve_Dispensers__c = NO;
            cifWrp.cif.FS_Fluid_Ounces_1__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_2__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_3__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_4__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_5__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_6__c = 2.1;
            cifWrp.cif.FS_ValidFill_Option__c = 'Yes';
            cifWrp.cif.FS_DryAccount_curently_no_dispnsd_accnt__c = YES;
            cifWrp.cif.FS_Kitchen_Ice_Fill_Requirements__c = 'Soft';
            cifWrp.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c = 'Follett';
            cifWrp.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c = 'MO-098';
            cifWrp.cif.FS_Who_will_coordinate_Ice_maker_Install__c = 'Sales';
            cifWrp.cif.FS_WhoWillPerformRequiredIceMakerWork__c = CUSTOMER;
            cifWrp.cif.FS_Is_an_approved_Water_Filter_Installed__c = 'Yes – approved water filter is installed';
            cifWrp.cif.FS_Water_Filter_MFG__c = 'Ecolab';
            cifWrp.cif.FS_Water_Filter_Model_no__c = 'MO-1234';
            cifWrp.cif.FS_Who_will_install_Water_Filter__c = CUSTOMER;
            cifWrp.cif.FS_Water_Filter_Contact_Name__c = cntct.id;
            cifWrp.cif.Water_Filter_Installer_Name__c = cntct.id;
               cifWrp.cif.FS_Name_of_Sweetener_Distributor__c = 'Bottler';
            cifWrp.cif.FS_Distributor_Name_City_ST__c = 'Test Distributor Co2';
            cifWrp.cif.FS_Order_Administrator__c = cntct.id;
            cifWrp.cif.FS_Order_Standard_User__c = cntct.id;
            cifWrp.cif.FS_Cartridge_Order_Method__c = 'CokeSmart';
            cifWrp.cif.FS_Delivery_Method__c = 'Direct Ship';
            cifWrp.cif.FS_Distributor_State__c = 'MO';
            cifWrp.cif.FS_Distributor_City__c = 'aaaStreet';
            cifWrp.cif.FS_OB_Trainer__c=COM;
            cifWrp.cif.FS_On_Boarding_Days_after_Install__c = '2';
            cifWrp.cif.FS_Select_On_Boarding_Start_Time__c = '6:30 AM';
            cifWrp.cif.FS_On_boarding_time_requested__c = '7:30 AM';
            cifWrp.cif.FS_On_Boarding_Contact__c = cntct.id;
            cifWrp.cif.FS_Cartridge_Payment_Method__c=BANKDRAFT;
            cifWrp.cif.FS_Program_Fee_Payment_Method__c = 'Credit Card';
        }
            //added 12 Dec CIF 8000/9000 series included
        WrpOutlet cifWrp = controller.lstOutlet[1];
        cifWrp.cif.FS_Platform1__c ='9000' ;
        cifWrp.cif.FS_Platform2__c = '8000';
            
        //controller.lstOutlet.get(0).cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
       // controller.lstOutlet.get(1).cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
        //controller.lstOutlet.get(1).cif.FS_Platform1__c = PLAT9K;
        controller.passCIF = true;
        controller.saveData();
        controller.summarySec();
        
        system.assertEquals(controller.lstOutlet[0].isSelected,true);
        controller.passCIF = true;
        controller.updateMigratedEP();
       
        system.debug('updateMigratedEPTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        Test.stopTest();
        }
    }
    
       //Method to test update Reparent EP
    private static testmethod void updateReparentEPTest(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
      final Profile fpsProf = FSTestFactory.getProfileId(FPS);
      final User fpsUser = [select id,name from User where profileId =:fpsProf.id Limit 1];
      final FS_Execution_Plan__c exePlan=[Select id from FS_Execution_Plan__c where recordtypeId=:exeRecId limit 1];
      final FS_Brandset__c brand1 = [select id,name from FS_Brandset__c where FS_Date_Brandset_is_available_for_Select__c =: Date.Today() limit 1];  
      final AccountTeamMember__c comUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c =:COM Limit 1];
      final AccountTeamMember__c salesUser = [select id,name from AccountTeamMember__c where TeamMemberRole__c ='Sales Team Member' Limit 1];
      cntct = [select id,name from Contact Limit 1];
      final Account vendor = [Select id,name from Account where RecordTypeId = :recTypeVendor Limit 1];
      counter = 0;
     
      final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
     
      //Sets the current PageReference for the controller
      final PageReference pageRef = Page.FSCustomerInputForm;
      Test.setCurrentPage(pageRef);
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
               system.runAs(sysAdmin){
      //Add parameters to page URL
      ApexPages.currentPage().getParameters().put(ID, cifHead.id);
      final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
      final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
      controller.passCIF = true;
      controller.onLoad();
      for(WrpOutlet wrpOutlet:controller.lstOutlet){
        if(counter<NUM2){
          wrpOutlet.isSelected = True;
        }
        counter++;
      }
     Test.startTest();
      controller.getCIFOnSave();
      controller.summarySec(); 
      controller.cifHead.FS_Sales_Rep_Name__c = salesUser.id;
      controller.cifHead.FSCOM__c = comUser.id;
      controller.cifHead.FS_FPS__c = fpsUser.id;
      controller.cifHead.FS_EP__c = exePlan.id;
      controller.cifHead.FS_Status__c = 'In Progress';
      for(WrpOutlet cifWrp:controller.lstOutlet)
        {
        cifWrp.cif.FS_What_type_of_outlet_install__c = REMODEL;
            cifWrp.cif.FS_Select_Site_assessment_contact__c = cntct.id;
            cifWrp.cif.FS_Platform1__c ='7000' ;
            cifWrp.cif.FS_Platform1_Qty__c = 15;
            cifWrp.cif.FS_Platform2__c = '8000';
            //cifWrp.cif.FS_Platform3__c = '7000';
            cifWrp.cif.FS_What_type_of_Site_Assessment__c = 'Site Assess + GFE bid proposal (traditional)';
            cifWrp.cif.FS_Total_VPO__c = 12;
            cifWrp.cif.FS_JDE_Doc__c = 'Test JDE';
            cifWrp.cif.FS_Work_Order_WO__c = 'Test WO';
            cifWrp.cif.FS_Perf_Site_Assessment__c = 'Yes';
            cifWrp.cif.FS_Davaco_Order_Entered__c = true;
            cifWrp.cif.FS_Customer_s_disposition_after_review__c = APRBYCUST;
            cifWrp.cif.FS_Requested_Install_Period__c =SPECIFICDATE;
            cifWrp.cif.FS_Requested_Install_Date__c = Date.today();
            cifWrp.cif.FS_Day_AM_or_Night_PM_Installation__c = DAY;
            cifWrp.cif.FS_Contractor_Coordination_to_be_done_by__c = COM;
            cifWrp.cif.FS_Contractor_Contact__c = cntct.id;
            cifWrp.cif.FS_General_Contractor_Name__c = vendor.id;
            cifWrp.cif.FS_Outlet_Contact__c = cntct.id;
            cifWrp.cif.FS_Pepper_Mix__c = '< 10%';
            cifWrp.cif.FS_Brandset1__c = brand1.id;
            cifWrp.cif.FS_Water1__c = 'Hide';
            //cifWrp.cif.FS_Dasani1__c = 'Hide';
            //cifWrp.cif.FS_7000_Series_Top_Mnt_Ice_Maker_Instld__c = 7;
            cifWrp.cif.FS_Any_Crew_Serve_Dispensers__c = NO;
            cifWrp.cif.FS_Fluid_Ounces_1__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_2__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_3__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_4__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_5__c = 2.1;
            cifWrp.cif.FS_Fluid_Ounces_6__c = 2.1;
            cifWrp.cif.FS_ValidFill_Option__c = 'Yes';
            cifWrp.cif.FS_DryAccount_curently_no_dispnsd_accnt__c = YES;
            cifWrp.cif.FS_Kitchen_Ice_Fill_Requirements__c = 'Soft';
            cifWrp.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c = 'Follett';
            cifWrp.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c = 'MO-098';
            cifWrp.cif.FS_Who_will_coordinate_Ice_maker_Install__c = 'Sales';
            cifWrp.cif.FS_WhoWillPerformRequiredIceMakerWork__c = CUSTOMER;
            cifWrp.cif.FS_Is_an_approved_Water_Filter_Installed__c = 'Yes – approved water filter is installed';
            cifWrp.cif.FS_Water_Filter_MFG__c = 'Ecolab';
            cifWrp.cif.FS_Water_Filter_Model_no__c = 'MO-1234';
            cifWrp.cif.FS_Who_will_install_Water_Filter__c = CUSTOMER;
            cifWrp.cif.FS_Water_Filter_Contact_Name__c = cntct.id;
            cifWrp.cif.Water_Filter_Installer_Name__c = cntct.id;
               cifWrp.cif.FS_Name_of_Sweetener_Distributor__c = 'Bottler';
            cifWrp.cif.FS_Distributor_Name_City_ST__c = 'Test Distributor Co2';
            cifWrp.cif.FS_Order_Administrator__c = cntct.id;
            cifWrp.cif.FS_Order_Standard_User__c = cntct.id;
            cifWrp.cif.FS_Cartridge_Order_Method__c = 'CokeSmart';
            cifWrp.cif.FS_Delivery_Method__c = 'Direct Ship';
            cifWrp.cif.FS_Distributor_State__c = 'MO';
            cifWrp.cif.FS_Distributor_City__c = 'aaaStreet';
            cifWrp.cif.FS_OB_Trainer__c=COM;
            cifWrp.cif.FS_On_Boarding_Days_after_Install__c = '2';
            cifWrp.cif.FS_Select_On_Boarding_Start_Time__c = '6:30 AM';
            cifWrp.cif.FS_On_boarding_time_requested__c = '7:30 AM';
            cifWrp.cif.FS_On_Boarding_Contact__c = cntct.id;
            cifWrp.cif.FS_Cartridge_Payment_Method__c=BANKDRAFT;
            cifWrp.cif.FS_Program_Fee_Payment_Method__c = 'Credit Card';
        }
            //added 12 Dec CIF 8000/9000 series included
        WrpOutlet cifWrp = controller.lstOutlet[1];
        cifWrp.cif.FS_Platform1__c ='9000' ;
        cifWrp.cif.FS_Platform2__c = '8000';
            
        controller.passCIF = true;
        controller.saveData();
        controller.summarySec();
        
        system.assertEquals(controller.lstOutlet[0].isSelected,true);
        controller.passCIF = true;
        controller.updateReparentEP();
            
        controller.saveclose();
       
        system.debug('updateReparentEPTest() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        Test.stopTest();
        }
    }
    
       //Method to test setStageEditCIF as FET System Admin
    private static testmethod void setStageEditCIFtest(){
      cifHead = [Select id,Name,FS_Version__c,FS_HQ__c,FS_Status__c from CIF_Header__c Limit 1];
        system.assertNotEquals(Null, cifHead);
        //create user
        final User acUser = FStestFactory.createUser(FStestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN).id);
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        system.runAs(acUser){
            
            //Add parameters to page URL
            ApexPages.currentPage().getParameters().put(ID, cifHead.id);
            final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
            final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
            controller.passCIF = true;
            controller.cifHead.FS_Status__c = FSConstants.CLOSEDCONVTOEP;
            controller.onLoad();
            system.debug('--------------'+cifHead.FS_Status__c);
            system.debug('setStageEditCIF() - End- Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Test.stopTest();
        }
    }
    
}