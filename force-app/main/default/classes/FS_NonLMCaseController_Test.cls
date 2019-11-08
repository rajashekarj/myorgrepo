/*********************************************************************************************************
Apex Class Name     : FS_NonLMCaseController_Test
Function            : This test class is created for class FS_NonLMCaseController
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* BhargavD	          09/10/2019       This class is a test class for FS_NonLMCaseController
									   
***********************************************************************************************************/
@isTest(SeeAllData=false)
private class FS_NonLMCaseController_Test {
    
    static Account headQuarterAcc,outletAcc, defaultAccount, internationalOutlet, chainAccount,bottler;
    static FS_Execution_Plan__c executionPlan;
    static FS_Installation__c installation;
    static User apiUser, coordinatorUser;
    static FS_Outlet_Dispenser__c outletDispenser;
    static FS_Outlet_Dispenser__c outletDispenser1,outletDispenser2;
    static FS_Outlet_Dispenser__c outletDispenserInt,outletDispenserInt1;
    static final string SERIES_7K='7000 Series';
    static FS_Integration_NMS_User__c integrationUser;
    static FS_IP_Technician_Instructions__c  ipTechInstruction;
    static Shipping_Form__c shippingForm;
    static Dispenser_Model__c dispenserModel;
    static SEMultiDispensers testSEMultiDispensers;
    static case sampleCase;
    static case sampleCase1;
    static PageReference pageRef;
    
   /*****************************************************************************************
  Method : createTestData
   Description : Method for setting up the data required in this unit test class.
  ******************************************************************************************/
    static void createTestData(){
        try{

            User userRecord = new User();
            userRecord.LastName='Testuser';
            userRecord.Alias='testuser';
            userRecord.Email='abc@defq.com';
            userRecord.Username='hkrishna@test.com';
            userRecord.TimeZoneSidKey='America/Los_Angeles';
            profile id1=[select id from profile where name='FS_FACT_BAST_P'];
            userRecord.ProfileId=id1.id;
            userRecord.LocaleSidKey='en_US';
            userRecord.EmailEncodingKey='ISO-8859-1';
            userRecord.LanguageLocaleKey='en_US';
            insert userRecord; 
            
            User testuser = [select id from User where Email='abc@defq.com'];
            system.runAs(testuser)
            {  
            FSTestFactory.lstPlatform();
            Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
            apiUser=FSTestUtil.createUser(null,null,'API User',false);
            coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
            chainAccount = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);        
            chainAccount.FS_ACN__c = '76876876';
            insert chainAccount;
            HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false); 
            HeadQuarterAcc.FS_ACN__c = '7658765876';
            insert HeadQuarterAcc;
            
            //Creates Outlet Accounts
            outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, true);
            bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
            defaultAccount = FSTestUtil.createAccountOutlet(FSConstants.defaultOutletName,FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, false);
            internationalOutlet = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET_INT,HeadQuarterAcc.Id,false);
            system.runAs(coordinatorUser){
                shippingForm = FSTestUtil.createShippingForm(true);
            }
            dispenserModel = FSTestUtil.createDispenserModel(true, '7000');
            //Creates execution plan
            executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,HeadQuarterAcc.Id, true);
            //creates installation
            installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.Id,true);                 
            
            ipTechInstruction=FSTestUtil.createTechnicianInstructions(FSConstants.TECHINSTRECTYPE,false);
            
            //creates initial order
            
            outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);
            outletDispenser1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);
            outletDispenser2= FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);        
            outletDispenserInt = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,internationalOutlet.id,null,false);
            outletDispenserInt1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,internationalOutlet.id,null,false);
           }
        }
        Catch(Exception ex)
        {
            system.debug('Exception : ' + ex.getMessage());
        }
    }
    
  //insert CustomSettings  
    
    
    public static void insertCustomSetting()
    {
        try
        {
            User testuser = [select id from User where Email='abc@defq.com'];
            system.runAs(testuser)
            {  
            Fact_EmailRoles__c customSetting = new Fact_EmailRoles__c();
            customSetting.Name = 'COM';
            customSetting.Role_Name__c = 'COM';
            customSetting.Case_Close__c = true;
            customSetting.Case_Comment__c = true;
            customSetting.Case_Create__c = true;
            insert customSetting;
            system.assertNotEquals(null, customSetting.Id);
           }
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
  /*****************************************************************************************
    	Method : getCaseDetails ,getCaseDetailsAfterUpdate,deleteNonLMCase
    	Description : Method for fetching case record details and deleteNonLMCase.
    ******************************************************************************************/
    
    
     static testmethod void getCaseDetailsTest(){
         
        Id caseIn;
        createTestData();
         User testuser = [select id from User where Email='abc@defq.com'];
         system.runAs(testuser)
         {  
        Test.startTest();
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c='ZPL12345';
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Date_Status__c=system.Date.today();
        insert outletDispenser1;
        FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
        //case create
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
        CaseIn = IdCase.Id;
        FS_NonLMCaseController.getCaseDetails(CaseIn);
        FS_NonLMCaseController.getCaseDetailsAfterUpdate(CaseIn);
        FS_NonLMCaseController.deleteNonLMCase(CaseIn);
        
        Test.stopTest();
         
        case caseR;
        caseR=new case(Issue_Name__c='test case1',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert caseR;
        system.assert(caseR!=NULL); 
         }
    }
    
      /*****************************************************************************************
    	Method : updateCaseDetails
    	Description : Method for updateCaseDetails.
    ******************************************************************************************/
    
    static testmethod void updateCase(){
        
        
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
        Test.startTest();
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c='ZPL12345';
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Date_Status__c=system.Date.today();
        insert outletDispenser1;
        FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
        //case create
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case cs = [select Id,CaseNumber,RecordType.Name,FS_Outlet_Dispenser__r.Name,Escalate_to_Global_Center__c,Issue_Name__c,Status,LM_Sub_Status__c,FS_New_Case_Type__c,To_Account__c,Owner.Name from Case where Issue_Name__c='test case'];
        
        FS_NonLMCaseController.updateCaseDetails(cs);
        Test.stopTest();
         Case caseR = [select Id,CaseNumber,RecordType.Name,FS_Outlet_Dispenser__r.Name,Escalate_to_Global_Center__c,Issue_Name__c,Status,LM_Sub_Status__c,FS_New_Case_Type__c,To_Account__c,Owner.Name from Case where Id = :cs.id];
         system.assert(caseR!=NULL);
        }
    }
    
  /*****************************************************************************************
    	Method : saveAccountTeamMembersAndSendEmail
    	Description : Method for saveAccountTeamMembersAndSendEmail.
    ******************************************************************************************/  
    
     static testmethod void accountTeamMembers(){
        
       
        Id caseIn;
        createTestData();
         User testuser = [select id from User where Email='abc@defq.com'];
         system.runAs(testuser)
         {  
        Test.startTest();
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c='ZPL12345';
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Date_Status__c=system.Date.today();
        insert outletDispenser1;
        FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
        //case create
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
        CaseIn = IdCase.Id;
        
         
         Email_Details__c emailDetails = new Email_Details__c();
         emailDetails.User_Name__c = 'TestUser1';
         emailDetails.User_Email__c = 'testlm@gmail.com';
         emailDetails.Parent_Case__c = CaseIn;
         emailDetails.Send_Email__c = false;
         emailDetails.User_Role__c = 'COM';
         emailDetails.Creation_Mail_Flag__c = false;
         insert emailDetails;
         
         Email_Details__c emailDetails1 = new Email_Details__c();
         emailDetails1.User_Name__c = 'TestUser2';
         emailDetails1.User_Email__c = 'testlm2@gmail.com';
         emailDetails1.Parent_Case__c = CaseIn;
         emailDetails1.Send_Email__c = true;
         emailDetails1.User_Role__c = 'FS_FACT_BAST_P';
         emailDetails1.Creation_Mail_Flag__c = true;
         insert emailDetails1;
         
         //helper
         insertCustomSetting();
         List<String> emailRoles;
         List<Case> caseRecord = [select Id,RecordTypeId from Case where status='New' Limit 1];
         FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         emailRoles = caseManagement.getAllEmailRoles(true,false,false);
         caseManagement.getAllEmailRoles(false,true,false);
         caseManagement.getAllEmailRoles(false,false,true);
         caseManagement.getAllEmailRoles(false,false,false);
         system.debug('emailRoles' + emailRoles);
         
         List <Email_Details__c> actTM = new List<Email_Details__c>();
         ActTM = [Select Id,User_Name__c,User_Role__c,User_Email__c,Send_Email__c,Creation_Mail_Flag__c,Closure_Mail_Flag__c from Email_Details__c where Parent_Case__c=:CaseIn];
         
         List<Id> actIds = new List<Id>();
         
         for(Email_Details__c ids :ActTM)
         {
             ActIds.add(Ids.Id);
         }
         //system.debug('SelectedId' + ActIds);
         
         //system.debug('SelectedUSers' + FS_NonLMCaseController.getAccountTeamMembersList(CaseIn));
         FS_NonLMCaseController.saveAccountTeamMembersAndSendEmail(FS_NonLMCaseController.getAccountTeamMembersList(CaseIn),ActIds,CaseIn);
         Test.stopTest();
         Case caseR = [select Id,CaseNumber,RecordType.Name,FS_Outlet_Dispenser__r.Name,Escalate_to_Global_Center__c,Issue_Name__c,Status,LM_Sub_Status__c,FS_New_Case_Type__c,To_Account__c,Owner.Name from Case where Id=:CaseIn];
         system.assert(caseR!=NULL);
         }
         
    }
    
   
    /*****************************************************************************************
    	Method : getLoggedinUserDetails
    	Description : Method for getLoggedinUserDetails.
    ******************************************************************************************/  
    
    static testmethod void loggedinUserTest(){
            createTestData();
            User testuser = [select id from User where Email='abc@defq.com'];
            system.runAs(testuser)
            {  
            Test.startTest(); 
            FS_NonLMCaseController.getLoggedinUserDetails();
            Test.stopTest();
            User userR = [select Id,Profile.Name,Related_Permission_Set__c from User where Email='abc@defq.com'];
            system.assert(userR!=NULL);
            }
        }    
    
    
     /*****************************************************************************************
    	Method : saveAccountTeamMembersAndSendEmail
    	Description : Method for saveAccountTeamMembersAndSendEmail to pass else conditions
    ******************************************************************************************/  
    
     static testmethod void accountTeamMemberstest(){
        
       
        Id caseIn;
        createTestData();
         User testuser = [select id from User where Email='abc@defq.com'];
         system.runAs(testuser)
         {  
        Test.startTest();
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c='ZPL12345';
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Date_Status__c=system.Date.today();
        insert outletDispenser1;
        FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
        //case create
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
        CaseIn = IdCase.Id;
        
         sampleCase1=new case(Issue_Name__c='test cases',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
         insert sampleCase1;
         Case idCase1 = [Select Id,Issue_Name__c from Case where Issue_Name__c='test cases'];
         id caseIn1 = IdCase1.Id;
         
    
         Email_Details__c emailDetails1 = new Email_Details__c();
         emailDetails1.User_Name__c = 'TestUser3';
         emailDetails1.User_Email__c = 'testlm2@gmail.com';
         emailDetails1.Parent_Case__c = CaseIn;
         emailDetails1.Send_Email__c = true;
         emailDetails1.User_Role__c = 'FS_FACT_BAST_P';
         emailDetails1.Creation_Mail_Flag__c = false;
         insert emailDetails1;
         
         //helper
         insertCustomSetting();
         List<String> emailRoles;
         List<Case> caseRecord = [select Id,RecordTypeId from Case where status='New' Limit 1];
         FSCaseManagementHelper caseManagement = new FSCaseManagementHelper();
         emailRoles = caseManagement.getAllEmailRoles(true,false,false);
         caseManagement.getAllEmailRoles(false,true,false);
         caseManagement.getAllEmailRoles(false,false,true);
         caseManagement.getAllEmailRoles(false,false,false);
          
         List <Email_Details__c> actTM = new List<Email_Details__c>();
         ActTM = [Select Id,User_Name__c,User_Role__c,User_Email__c,Send_Email__c,Creation_Mail_Flag__c,Closure_Mail_Flag__c from Email_Details__c where Parent_Case__c=:CaseIn1];
         
         List<Id> actIds = new List<Id>();
         
         for(Email_Details__c ids :ActTM)
         {
             ActIds.add(Ids.Id);
         }
         
         FS_NonLMCaseController.saveAccountTeamMembersAndSendEmail(FS_NonLMCaseController.getAccountTeamMembersList(CaseIn),ActIds,CaseIn);
         FS_NonLMCaseController.checkCommunity();
         Test.stopTest();
         Case caseR = [select Id,CaseNumber,RecordType.Name,FS_Outlet_Dispenser__r.Name,Escalate_to_Global_Center__c,Issue_Name__c,Status,LM_Sub_Status__c,FS_New_Case_Type__c,To_Account__c,Owner.Name from Case where Id= :CaseIn];
         system.assert(caseR!=NULL);
         }
         
    }
     

}