/**************************************************************************************
Apex Class Name     : FS_LM_CaseEditPageController_Test
Function            : This is a Test class for handling all Unit test methods for FS_LM_CaseEditPageController class.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Hari            	03/06/2018       	First version for handling unit test methods for all methods in FS_LM_CaseEditPageController class.
					05/29/2018		 	Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest(SeeAllData=false)
public class FS_LM_CaseEditPageController_Test {
 
    static FS_Outlet_Dispenser__c outletDisp1;
    static FS_Outlet_Dispenser__c outletDisp2;
    public static Id fsaccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(FSConstants.OUTLET_RECORD_TYPE).getRecordTypeId();
    public static Id ODRecordTypeId = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(FSConstants.RT_NAME_CCNA_OD).getRecordTypeId();
    public static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(FSConstants.RECORD_TYPE_NAME_LMCASE).getRecordTypeId();
     
    @testSetup
    public static void dataSetup()
    {
         User userRecord = new User();
            userRecord.LastName='Testuser';
            userRecord.Alias='testuser';
            userRecord.Email='abc@def.com';
            userRecord.Username='hkrishna12@test.com';
            userRecord.TimeZoneSidKey='America/Los_Angeles';
            profile id1=[select id from profile where name='FS_FACT_BAST_P'];
            userRecord.ProfileId=id1.id;
            userRecord.LocaleSidKey='en_US';
            userRecord.EmailEncodingKey='ISO-8859-1';
            userRecord.LanguageLocaleKey='en_US';
            insert userRecord;
        
        	User adminUser = new User();
            adminUser.LastName='Administrator';
        	adminUser.FirstName='Freestyle';
            adminUser.Alias='fadmi';
            adminUser.Email='abc1@def.com';
            adminUser.Username='admin23@test.com';
            adminUser.TimeZoneSidKey='America/Los_Angeles';
            profile id2=[select id from profile where name='System Administrator'];
            adminUser.ProfileId=id2.id;
            adminUser.LocaleSidKey='en_US';
            adminUser.EmailEncodingKey='ISO-8859-1';
            adminUser.LanguageLocaleKey='en_US';
            insert adminUser;
        
        //FACT_TestFactory.loadOutboundServiceForOutletDispensers();
        Account fsaccount1 = new Account();
        fsaccount1.RecordTypeId=fsaccountRecordTypeId;
        fsaccount1.shippingCountry='US';
        fsaccount1.name='FS Outlet To Account';
        insert fsaccount1;
        
        Account fsaccount2 = new Account();
        fsaccount2.RecordTypeId=fsaccountRecordTypeId;
        fsaccount2.shippingCountry='US';
        fsaccount2.name='FS Outlet From Account';
        insert fsaccount2;
        
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        OutletDisp1 =FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,fsaccount2.id,null,false);
        OutletDisp1.FS_Outlet__c = fsaccount2.Id;
        OutletDisp1.FS_Equip_Type__c  ='9000';
        OutletDisp1.FS_Serial_Number2__c = 'AHKJ1775';
        //OutletDisp1.Installation__c = installation.id;
        //OutletDisp1.FS_Color__c = 'Black1';
        OutletDisp1.FS_IsActive__c = true ;
        OutletDisp1.FS_LTO__c='LTO11';
        OutletDisp1.FS_Model__c='90001';
        OutletDisp1.FS_Pending_Migration_to_AW__c=false;
        OutletDisp1.FS_Migration_to_AW_Required__c=true;
        OutletDisp1.FS_Valid_Fill__c='No1';
        OutletDisp1.FS_7000_Series_Brands_Option_Selections__c  = FSconstants.twoStatic1Agitated;
        OutletDisp1.FS_7000_Series_Static_Brands_Selections__c='Powerade1;Hi-C/Vitamin Water1';
        OutletDisp1.FS_7000_Series_Agitated_Brands_Selection__c = 'Barqs1';
        OutletDisp1.Brand_Set__c='GER Default Collection';
        OutletDisp1.FS_Soft_Ice_Adjust_Flag__c='No1';
        OutletDisp1.FS_Outlet__c = fsaccount2.id;
        OutletDisp1.FS_IsActive__c =True;
        OutletDisp1.FS_Serial_Number2__c='AHKJ1775';
        
        insert OutletDisp1;
        
        OutletDisp2 =FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,fsaccount2.id,null,false);
        OutletDisp2.FS_Outlet__c = fsaccount1.Id;
        OutletDisp2.FS_Equip_Type__c  ='9000';
        OutletDisp2.FS_Serial_Number2__c = 'AKHJ1775';
        //OutletDisp1.Installation__c = installation.id;
        //OutletDisp2.FS_Color__c = 'Black1';
        OutletDisp2.FS_IsActive__c = true ;
        OutletDisp2.FS_LTO__c='LTO11';
        OutletDisp2.FS_Model__c='90001';
        OutletDisp2.FS_Pending_Migration_to_AW__c=false;
        OutletDisp2.FS_Migration_to_AW_Required__c=true;
        OutletDisp2.FS_Valid_Fill__c='No1';
        OutletDisp2.FS_7000_Series_Brands_Option_Selections__c  =FSconstants.twoStatic1Agitated;
        OutletDisp2.FS_7000_Series_Static_Brands_Selections__c='Powerade1;Hi-C/Vitamin Water1';
        OutletDisp2.FS_7000_Series_Agitated_Brands_Selection__c = 'Barqs1';
        OutletDisp2.Brand_Set__c='GER Default Collection';
        OutletDisp2.FS_Soft_Ice_Adjust_Flag__c='No1';
        OutletDisp2.FS_Outlet__c = fsaccount1.id;
        OutletDisp2.FS_IsActive__c =True;
        OutletDisp2.FS_Serial_Number2__c='AKHJ1775';
        insert OutletDisp2;
   
    
    }
 
    public static testMethod void LMcaseinsert()
    {
        Account toaccount = [select id from Account where name='FS Outlet To Account'];
        Account fromaccount = [select id from Account where name='FS Outlet From Account'];
    FS_Outlet_Dispenser__c Disp1 =[select id from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='AHKJ1775'];
    
        User testuser = [select id from User where Email='abc@def.com'];
    try
        {   system.runAs(testuser){
            Case caseInstance = new Case();
            caseInstance.Status = 'New';
            caseInstance.recordtypeId = caseRecordTypeId;
            caseInstance.Issue_Name__c ='Sample_Test';
            caseInstance.type ='JDE Linkage Request';
            caseInstance.To_Account__c = toaccount.Id;
            caseInstance.From_Account__c = fromaccount.Id;
            insert caseInstance;
            test.startTest();
            ApexPages.currentPage().getParameters().put('id',caseInstance.Id);
            Apexpages.StandardController stdController = new Apexpages.StandardController(caseInstance);
            FS_LM_CaseEditPageController FSLMCaseEditPageController =new FS_LM_CaseEditPageController(stdController);
             
            FSLMCaseEditPageController.toACNODdetails();
            FSLMCaseEditPageController.fromACNODdetailswrpr();
            FSLMCaseEditPageController.getdetails();
            FS_LM_CaseEditPageController.ODwrpr ODwrapObj= new FS_LM_CaseEditPageController.ODwrpr(Disp1,true); 
      		FSLMCaseEditPageController.ODList.add(ODwrapObj);
      		FSLMCaseEditPageController.saveCase();
            FSLMCaseEditPageController.saveNew();
            FSLMCaseEditPageController.editCase();
            FSLMCaseEditPageController.dpcancel();
            caseComment testcomment= new caseComment();
            testcomment.CommentBody='test sample';
            testcomment.ParentId = caseInstance.id;
            insert testcomment;
            ApexPages.currentPage().getParameters().put('CommentId_d',testComment.Id);
            FSLMCaseEditPageController.NewComment();
            FSLMCaseEditPageController.deleteComment();
            FSLMCaseEditPageController.deleteCase();
            test.stopTest();
        }}
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
       
        
    }
    
    public static testMethod void LMEsclateToSalesSupport()
    {
        Account toaccount = [select id from Account where name='FS Outlet To Account'];
        Account fromaccount = [select id from Account where name='FS Outlet From Account'];
        FS_Outlet_Dispenser__c Disp1 =[select id from FS_Outlet_Dispenser__c where FS_Serial_Number2__c='AHKJ1775'];
    
        User testuser = [select id from User where Email='abc@def.com'];
        try
        {   system.runAs(testuser){
            Case caseInstance = new Case();
            caseInstance.Status = 'New';
            caseInstance.recordtypeId = caseRecordTypeId;
            caseInstance.Issue_Name__c ='Sample_Test';
            caseInstance.type ='JDE Initiated AMOA';
            caseInstance.To_Account__c = toaccount.Id;
            caseInstance.From_Account__c = fromaccount.Id;
            insert caseInstance;
            test.startTest();
            ApexPages.currentPage().getParameters().put('id',caseInstance.Id);
            Apexpages.StandardController stdController = new Apexpages.StandardController(caseInstance);
            FS_LM_CaseEditPageController FSLMCaseEditPageController =new FS_LM_CaseEditPageController(stdController);
            FSLMCaseEditPageController.escalateToSalesSupport();
            System.AssertNotEquals(caseInstance.Status,FSConstants.STRING_NULL);
            test.stopTest();
        }}
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    } 
}