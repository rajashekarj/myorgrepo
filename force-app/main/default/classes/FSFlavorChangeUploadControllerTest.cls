/**************************************************************************************
Apex Class Name     : FSFlavorChangeUploadControllerTest
Version             : 1.0
Function            : This test class is for  FSMassUpdateOutletDispenserController Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  04/19/2017		  Updated to increase the test coverage	
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSFlavorChangeUploadControllerTest{
    
    private static final string SERIES_7K='7000';
    private static final string FS_EQUIP_TYP ='FS_Equip_Type__c';
    private static final string SERIES_8K='8000';
    private static final string SERIES_9K='9000';
    private static final string DATE_FORMAT='dd/MM/yyyy';
    private static final string HIDE='Hide';
    private static final string YES='Yes';
    private static final string REC_7K='7000 Series';
    private static final string REC_8K='8000 Series';
    private static final string REC_9K='9000 Series';
    private static final string REC_8K_9K='8000 & 9000 Series';
    private static final string USER_ID='testFlavor@testdomain.com';
    public static User user;
    
    @testSetup
    private static void loadTestData(){
        
        //custom setting trigger switch
        FSTestFactory.createTestDisableTriggerSetting();
        
        //create Brandset records
        FSTestFactory.createTestBrandset();
        
        //Create Single HeadQuarter
        final List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        insert headQuarterCustomerList;
        //Create Single Outlet
        final List<Account> outletCustomerList=new List<Account>();
        for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'))){
            acc.FS_Headquarters__c=headQuarterCustomerList.get(0).Id;
            outletCustomerList.add(acc);
        }
        insert outletCustomerList;
        
        //Create Execution Plan
        //Collection to hold all recordtype names of Execution plan                                                                       
        final Set<String> executionPlanRecordTypesSet=new Set<String>{'Execution Plan'};
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
        
        insert executionPlanList;
        List<Platform_Type_ctrl__c> listplatform = FSTestFactory.lstPlatform();
        List<ProfileListFromCustomSettings__c>  lstOfProfiles = FSTestFactory.lstProfiles();
        
        //Create Installation
        final Set<String> installationPlanRecordTypesSet=new Set<String>{fsconstants.NEWINSTALLATION};
            final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >(); 
        final Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
        //Create Installation for each Execution Plan according to recordtype
        
        final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,fsconstants.NEWINSTALLATION); 
        final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
        installationPlanList.addAll(installList);
        
        Test.startTest();
        insert installationPlanList;  
        //Verify that Installation Plan got created
        system.assertEquals(1,installationPlanList.size()); 
        
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        //Create 200 Outlet Dispensers 
        for(Integer i=0;i<200;i++){
            
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            
            Id outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
            
            final Integer elementIndex = Math.mod(i, 1);  //Range ;[0,3]
            final FS_Installation__c installPlan=installationPlanList.get(elementIndex);
            
            if(installPlan.Type_of_Dispenser_Platform__c.contains(SERIES_7K)){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
                odList[0].put(FS_EQUIP_TYP, SERIES_7K);
                
            }
            if(installPlan.Type_of_Dispenser_Platform__c.contains(SERIES_8K)){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'B');
                odList[0].put(FS_EQUIP_TYP, SERIES_8K);
                
            }
            if(installPlan.Type_of_Dispenser_Platform__c.contains(SERIES_9K)){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'D');
                odList[0].put(FS_EQUIP_TYP, SERIES_9K);
                
            }
            outletDispenserList.addAll(odList);
            
        }   
        insert outletDispenserList;
        system.assert((Limits.getLimitQueries() - Limits.getQueries())>0);  
        system.assertEquals(200,outletDispenserList.size());  
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        //get test data 
        final List<FS_Brandset__c> brandsetRecorList=[SELECT Id,Name,FS_Country__c,FS_Effective_End_Date__c,FS_Effective_Start_Date__c,
                                                      FS_Platform__c FROM FS_Brandset__c limit 1000];       
        
        //Separate Brandset based on platform 
        final List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecorList){
            if(branset.FS_Platform__c.contains(SERIES_7K)) {branset7000List.add(branset);}
            if(branset.FS_Platform__c.contains(SERIES_8K)) {branset8000List.add(branset);}
            if(branset.FS_Platform__c.contains(SERIES_9K)) {branset9000List.add(branset);}
        } 
        Test.stopTest();
    }    
    
    private static testMethod void testFileUploadException(){
        
        final PageReference pageRef = Page.FSFlavorChangeWorkBookUpload;
        Test.setCurrentPage(pageRef);
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){ 
            
            final List<FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper> detailWrapperList=new List<FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper>();
            final FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper detailWrapperObj=new FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper();
            final List<FS_Outlet_Dispenser__c> outletDispenserList=[SELECT Id,Name,FS_Serial_Number2__c,FS_Dispenser_Location__c,FS_ACN_NBR__c  FROM FS_Outlet_Dispenser__c limit 1000];
            final List<FS_Brandset__c> brandsetRecorList=[SELECT Id,Name,FS_SAP_Item_Proposal_Number__c FROM FS_Brandset__c limit 1000];       
            for (integer i=0;i<101;i++){
                
                detailWrapperObj.outletACN=outletDispenserList.get(0).FS_ACN_NBR__c;
                //detailWrapperObj.platform=outletDispenserList.get(0).FS_Model__c;
                detailWrapperObj.serialNumber=outletDispenserList.get(0).FS_Serial_Number2__c;
                detailWrapperObj.currentbrandset='Fuze with Barqs';
                detailWrapperObj.newBrandset=brandsetRecorList.get(0).Name;
                detailWrapperObj.brandsetEffectiveDate=DateTime.now().format(DATE_FORMAT);
                detailWrapperObj.waterHideData=HIDE;
                detailWrapperObj.waterHideEffectvieDate=DateTime.now().format(DATE_FORMAT);
                detailWrapperObj.dasaniData=HIDE;
                detailWrapperObj.dasaniDataEffectvieDate=DateTime.now().format(DATE_FORMAT);
                detailWrapperObj.pungentChangeIndicator='No';
                detailWrapperObj.customerPayorAccountPay='Customer Pay';
                detailWrapperObj.requestedDate=DateTime.now().format(DATE_FORMAT);
                detailWrapperObj.productOrderHandeledBy='Infosys';
                detailWrapperObj.spNeedToGoOut=YES;
                detailWrapperObj.dateProductidAvaliableInDC=DateTime.now().format(DATE_FORMAT);
                detailWrapperObj.NDOapprovalCheck=YES;
                detailWrapperObj.CDMSetupComplete=YES;
                detailWrapperObj.estimatedFlavorChangeDate=DateTime.now().format(DATE_FORMAT);
                detailWrapperObj.customerServiceNotes='Test';
                detailWrapperObj.POMActionsComplete=YES;
                detailWrapperObj.orderProcessed=YES;
                // detailWrapperObj.fcCommerciallyApproved=YES;
                detailWrapperObj.aCUser=USER_ID;
                detailWrapperObj.aCUserName=USER_ID;
                detailWrapperObj.projectID='12345';
                detailWrapperObj.projectDescription='Test Proj';
                detailWrapperObj.pmUser=USER_ID;
                detailWrapperObj.pmUserName=USER_ID;
                detailWrapperObj.comUser=USER_ID;
                detailWrapperObj.comUserName=USER_ID;
                detailWrapperObj.scheduledDate=DateTime.now().format(DATE_FORMAT);
                // detailWrapperObj.customerReadiness=YES;
                detailWrapperObj.orderMethod='VMS';
                detailWrapperObj.deliveryMethod='Distributor';
                
                detailWrapperList.add(detailWrapperObj);
            }
            final FSFlavorChangeWorkBookUploadController controller = new FSFlavorChangeWorkBookUploadController();
            Test.startTest();
            controller.csvFileBody=FSTestFactory.createValidCSVBlobForFlavorChangeUpload(detailWrapperList);  
            
            //user uploads the file
            controller.uploadFile();
            
            //Verify success Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.Error), 'Error while uploading file.');                   
            Test.stopTest();
        }
    }
    
    private static testMethod void testFileUploadNew(){
        
        final PageReference pageRef = Page.FSFlavorChangeWorkBookUpload;
        Test.setCurrentPage(pageRef);
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){     
            final Account outlt=[SELECT Id,Name,FS_Headquarters__c,FS_ACN__c FROM Account where FS_Headquarters__c!=null limit 1]; 
            final Account hqAcc=[SELECT Id,Name,FS_ACN__c FROM Account where Id=:outlt.FS_Headquarters__c limit 1]; 
            
            final FS_Outlet_Dispenser__c oDisp=[SELECT Id,Name,FS_Serial_Number2__c,FS_Dispenser_Location__c,FS_ACN_NBR__c  FROM FS_Outlet_Dispenser__c where FS_Outlet__c=:outlt.Id limit 1];
            final List<FS_Brandset__c> brandsetRecorList=[SELECT Id,Name,FS_SAP_Item_Proposal_Number__c FROM FS_Brandset__c limit 1000];       
            system.assertEquals(37,brandsetRecorList.size()); 
            final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
            holder.FS_WorkBook_Name__c='Dispenser WorkBook';
            insert holder;
            
            Test.startTest();
            oDisp.FS_Serial_Number2__c='IPL1234567';
            oDisp.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FSConstants.RT_NAME_CCNA_OD);
            oDisp.FS_Outlet__c=outlt.Id;
            update oDisp;
            outlt.FS_ACN__c='0000001155'; 
            outlt.FS_Requested_Delivery_Method__c='distributor';
            outlt.FS_Requested_Order_Method__c='distributor';
            update outlt;
            final StaticResource staticResrc =[SELECT Id,Body FROM StaticResource WHERE Name = 'Test_Upload' LIMIT 1];
            final FSFlavorChangeWorkBookUploadController controller = new FSFlavorChangeWorkBookUploadController();
            controller.csvFileBody=staticResrc.Body; 
            controller.csvFileName ='Flavor Change WorkBook';
            
            //user uploads the file
            controller.uploadFile();
            
            controller.csvFileName ='Flavor Change WorkBook.csv';
            controller.uploadFile();
            controller.backToPrevious();
            final List<FS_WorkBook_Holder__c> parentHolder=[SELECT Id,Name FROM FS_WorkBook_Holder__c
                                                            WHERE FS_WorkBook_Name__c='Flavor Change WorkBook' limit 1];
            //verify parent record got created
            system.assert(!parentHolder.isEmpty());
            
            //verify Attachement got created 
            final Attachment file=[SELECT Id,Body,Name from Attachment where parentId=:parentHolder.get(0).Id
                                   ORDER BY  createdDate DESC limit 1];
            system.assert(file.Body!=null);   
            
            //Verify success Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.Info), 'File Uploaded Successfully');               
            controller.callBatch();  
            Test.stopTest();
        }  
    }
}