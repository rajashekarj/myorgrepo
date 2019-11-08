/*********************************************************************************************************
Apex Class Name     : FS_LMCaseControllerTest
Function            : This test class is created for class FS_LMCaseController
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* BhargavD	          09/30/2019       This class is a test class for FS_LMCaseController
									   
***********************************************************************************************************/

@isTest(SeeAllData=false)

public class FS_LMCaseControllerTest {
    
      
    static Account headQuarterAcc,outletAcc, defaultAccount, internationalOutlet, chainAccount,bottler;
    static FS_Execution_Plan__c executionPlan;
    static FS_Installation__c installation;
    static User apiUser, coordinatorUser;
    static FS_Outlet_Dispenser__c outletDispenser;
    static FS_Outlet_Dispenser__c outletDispenser1,outletDispenser2,outletDispenser3,outletDispenser4;
    static FS_Outlet_Dispenser__c outletDispenserInt,outletDispenserInt1;
    static final string SERIES_7K='7000 Series';
    static FS_Integration_NMS_User__c integrationUser;
    static FS_IP_Technician_Instructions__c  ipTechInstruction;
    static Shipping_Form__c shippingForm;
    static Dispenser_Model__c dispenserModel;
    static SEMultiDispensers testSEMultiDispensers;
    static Account sampleaccount;
    static Case samplecase,sampleCaseD;
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
    
/*****************************************************************************************
Method : getAccountDetails
Description : Method for testing to get Account details.
******************************************************************************************/     
    
    static testmethod void getAccountDetails(){
        
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest();
            List<Account> acc = new List<Account>();
            Account acct = [select id,FS_ACN__c from account where Name = 'Test Chain 1'];
            ID accId = acct.Id;
            acc = FS_LMCaseController.toACNdetails(accId);
            Test.stopTest(); 
            system.assert(acc!=NULL);
        }     
 } 
    
/*****************************************************************************************
Method : getAccountODDetails
Description : Method for testing to get Account OD details.
******************************************************************************************/ 
    static testmethod void getAccountODDetails(){
        
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
        List<FS_Outlet_Dispenser__c> oD = new List<FS_Outlet_Dispenser__c>();
        Account acct = [select id,FS_ACN__c from account where Name = 'Test Outlet 1'];
        ID accId = acct.Id;
        List<FS_Outlet_Dispenser__c> toAcnOD = new List<FS_Outlet_Dispenser__c>();
        toAcnOD = FS_LMCaseController.toACNODdetails(accId);
        Test.stopTest(); 
        system.assert(toAcnOD!=NULL);
        }
    }
    
    
    
/*****************************************************************************************
Method : getFromAccountDetails
Description : Method for testing to get Account OD details.
******************************************************************************************/
    
    static testmethod void getFromAccountDetails(){
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest();
            List<Account> acc = new List<Account>();
            Account acct = [select id,FS_ACN__c from account where Name = 'Test Chain 1'];
            ID accId = acct.Id;
            acc = FS_LMCaseController.fromAccnDetailsWrap(accId);
            Test.stopTest(); 
            system.assert(acc!=NULL);
        }    
          
    }
  
/*****************************************************************************************
Method : getAccountODDetailsWrp
Description : Method for testing to get Account OD details.
******************************************************************************************/
    
      static testmethod void getAccountODDetailsWrp(){
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest();
            //insert OD
            outletDispenser1.FS_Outlet__c = outletAcc.Id;
            outletDispenser1.FS_Equip_Type__c  ='8000';
            outletDispenser1.FS_Serial_Number2__c='ZPL12345';
            outletDispenser1.FS_IsActive__c=true;
            outletDispenser1.FS_Date_Status__c=system.Date.today();
            insert outletDispenser1;
            FS_Outlet_Dispenser__c odRec = [Select Id,Name from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='ZPL12345'];
            List<FS_Outlet_Dispenser__c> oD = new List<FS_Outlet_Dispenser__c>();
            Account acct = [select id,FS_ACN__c from account where Name = 'Test Outlet 1'];
            ID accId = acct.Id;
            //insert Case
            sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCase;
            Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
            Id caseIn = IdCase.Id;
            CaseToOutletdispenser__c cToOD = new CaseToOutletdispenser__c();
            cToOD.Case__c = IdCase.id;
            cToOD.Outlet_Dispenser__c = odRec.Id;
            insert cToOD;           
            FS_LMCaseController.fromACNODdetailswrpr(accId,caseIn);
            Test.stopTest(); 
            system.assert(acct!=NULL);
        }    
          
    }    
    
 /*****************************************************************************************
Method : getCaseDetails
Description : Method for testing to get Case Details.
******************************************************************************************/   
     static testmethod void getCaseDetail(){
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest();
             sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCase;
            Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
            Id caseIn = IdCase.Id;
            List<Case> cs = New list<Case>();
            cs = FS_LMCaseController.getCaseDetails(caseIn);
            Test.stopTest(); 
            system.assert(cs!=NULL);
        }    
          
    }  
    
    
/*****************************************************************************************
Method : getFactODDetails
Description : Method for testing to get Case Details.
******************************************************************************************/  
    static testmethod void getFactODDetails(){
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
            Id odID = odRec.Id;
            FS_LMCaseController.getFactOutletDispensers(OdID);
            Test.stopTest(); 
            system.assert(odRec!=NULL);
        }    
    
    }
    
    
/*****************************************************************************************
Method : DeleteLM Case
Description : Method for testing to get Case Details.
******************************************************************************************/ 
        static testmethod void deleteCase(){
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest();
             sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCase;
            Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
            Id caseIn = IdCase.Id;
            FS_LMCaseController.deleteLMCase(caseIn);
            Test.stopTest(); 
            sampleCaseD=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCaseD;
            Case caseD = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
            system.assert(caseD!=NULL);
        }    
          
    }  
    
/*****************************************************************************************
Method : getloggedUser
Description : Method for testing to get logged user.
******************************************************************************************/ 
    
   static testmethod void getloggedUser(){
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
       // createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest(); 
            User userDetail = New User();
            userDetail = FS_LMCaseController.getLoggedinUserDetails();
            Test.stopTest(); 
            
            system.assert(userDetail!=NULL);
        }    
          
    }


/*****************************************************************************************
Method : EscalatetoSales
Description : Method for testing to get logged user.
******************************************************************************************/     
    static testmethod void escalatetoSales(){
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest();
             sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCase;
            Case idCase = [Select Id,Issue_Name__c from Case where Issue_Name__c='test case'];
            Id caseIn = IdCase.Id;
            FS_LMCaseController.escalateToSalesSupport(caseIn);
            Test.stopTest(); 
            system.assert(idCase!=NULL);
        }    
          
    }
    
    
/*****************************************************************************************
Method : getCaseRecordTypeID
Description : Method for testing to get record types.
******************************************************************************************/ 
    static testmethod void getCaseRecordTypeID(){
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest();
            sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCase;
            Case idCase = [Select Id,Issue_Name__c,FS_LM_Case_Record_Type__c from Case where Issue_Name__c='test case'];
            string recordType = IdCase.FS_LM_Case_Record_Type__c;
            List<RecordType> lmCaseRecord = New List<RecordType>();
            system.debug('CaseRecordTypeId=====>' + RecordType);
            lmCaseRecord = FS_LMCaseController.getLMCaseRecordTypeID(RecordType);
            Test.stopTest(); 
            system.assert(lmCaseRecord!=NULL);
        }    
    
   }
    
/*****************************************************************************************
Method : updateCase and sendmailwithAtt
Description : Method for testing to send mail with attachement.
******************************************************************************************/ 
     static testmethod void updatecase(){
        createTestData();
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            Test.startTest();
            sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
            insert sampleCase;
            Case idCase = [Select Id,Issue_Name__c,FS_LM_Case_Record_Type__c,LM_Sub_Status__c,CreatedBy.Id  from Case where Issue_Name__c='test case'];
            idCase.Status = 'Assigned';
            idCase.LM_Sub_Status__c = 'Finance on Hold';
            update idCase;
            string caseCreaterId = idCase.CreatedBy.Id;
            //insert contact
            Contact con = new Contact(FirstName='test contact',LastName='test',FS_Title__c='DM');
            insert con;
            //insert contentversion
            ContentVersion contentVersion = new ContentVersion(Title = 'AMOAPenguins',PathOnClient = 'Penguins.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion; 
            id contentVersionId = contentVersion.id;
            //insert content document link
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 10];
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = idCase.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            FS_LMCaseController.updateCaseDetails(idCase);
           
            Test.stopTest(); 
            system.assert(idCase!=NULL);
        }    
    
   }
        
/*****************************************************************************************
Method : saveCaseOutletDispensers
Description : Method for testing to update case
******************************************************************************************/ 
     static testmethod void saveCaseOutletDispensers(){
        
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
        outletDispenser2.FS_Outlet__c = outletAcc.Id;
        outletDispenser2.FS_Equip_Type__c  ='9000';
        outletDispenser2.FS_Serial_Number2__c='ZPL12346';
        outletDispenser2.FS_IsActive__c=true;
        outletDispenser2.FS_Date_Status__c=system.Date.today();
        insert outletDispenser2;
        List<Id> selODList = new List<Id>();
        FS_Outlet_Dispenser__c selOD = [select id,FS_Equip_Type__c from FS_Outlet_Dispenser__c where FS_Equip_Type__c = '8000'];
        SelODList.add(SelOD.id);
        List<Id> nonSelODList = new List<Id>();
        FS_Outlet_Dispenser__c nonSelOD = [select id,FS_Equip_Type__c from FS_Outlet_Dispenser__c where FS_Equip_Type__c = '9000'];
        NonSelODList.add(NonSelOD.id);
        sampleCase=new case(Issue_Name__c='test case',Status='New',FS_Dispenser_Type__c=SERIES_7K,Categories__c='CDM',Dispenser_serial_number__c=outletDispenser1.FS_Serial_Number2__c);
        insert sampleCase;
        Case idCase = [Select Id,Issue_Name__c,FS_LM_Case_Record_Type__c from Case where Issue_Name__c='test case'];
        FS_LMCaseController.saveCaseOD(idCase.id,SelODList,NonSelODList);
        FS_LMCaseController.isCommunity();
        Test.stopTest(); 
        system.assert(SelOD!=NULL);
        }
    }
    
    
    
 }