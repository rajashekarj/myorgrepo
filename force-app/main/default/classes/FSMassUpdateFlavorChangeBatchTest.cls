/**************************************************************************************
Apex Class Name     : FSMassUpdateFlavorChangeBatchTest
Version             : 1.0
Function            : This test class is for  FSMassUpdateFlavorChangeBatch Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSMassUpdateFlavorChangeBatchTest{
    private static final String SERIES7K = '7000 Series';
    private static final String SERIES8K9K = '8000 & 9000 Series';
    private static final String SERIES8K = '8000 Series';
    private static final String SERIES9K = '9000 Series';
    private static final String EQUIPTYP = 'FS_Equip_Type__c';
    private static final String PLATFORM = 'FS_Platform__c';
    private static final string LIT7K = '7000';
    private static final string LIT8K = '8000';
    private static final string LIT9K = '9000';
    //private static final string LITDATE = 'dd/MM/yyyy';
    @testSetup
    private static void loadTestData(){      
        
        //create Brandset records
        FSTestFactory.createTestBrandset();
        //Create custom setting data
        List<Platform_Type_ctrl__c> listplatform = FSTestFactory.lstPlatform();
        List<ProfileListFromCustomSettings__c>  lstOfProfiles = FSTestFactory.lstProfiles();
        //Create Single HeadQuarter
        final List<Account> hqCustList= FSTestFactory.createTestAccount(true,1,
                                                                        FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        
        //Create Single Outlet
        final List<Account> outletCustList=new List<Account>();
        for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'))){
            acc.FS_Headquarters__c=hqCustList.get(0).Id;
            acc.FS_Requested_Delivery_Method__c='Distributor';
            acc.FS_Requested_Order_Method__c='Distributor';
            outletCustList.add(acc);
            
        }
        insert outletCustList;
        //Create Execution Plan
       
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
        
            final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,FSConstants.EXECUTIONPLAN);
            
            final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(hqCustList.get(0).Id,false,1,epRecordTypeId);
            
            executionPlanList.addAll(epList);                                                                     
       
        //Verify that four Execution Plan got created
        system.assertEquals(1,executionPlanList.size());         
        
        insert executionPlanList;
        
        //Create Installation
        final Set<String> ipRecTypSet=new Set<String>{fsconstants.NEWINSTALLATION};
            
            final List<FS_Installation__c > ipList=new List<FS_Installation__c >(); 
        
        final Map<Id,String> instRecTypIdNam=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
        //Create Installation for each Execution Plan according to recordtype
        
        for(String  installationRecordType : ipRecTypSet){
            final Id instRecTypId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,fsconstants.NEWINSTALLATION); 
            final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustList.get(0).Id,false,1,instRecTypId);
            ipList.addAll(installList);
        } 
        Test.startTest();
        
        insert ipList;
        //Verify that Installation Plan got created
        system.assertEquals(1,ipList.size()); 
        
        
        final List<FS_Outlet_Dispenser__c> oDispList=new List<FS_Outlet_Dispenser__c>();
        //Create 200 Outlet Dispensers 
        for(Integer i=0;i<200;i++){
            
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id oDispRecTypId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
                       
            final Integer elementIndex = Math.mod(i, 1);  //Range ;[0,3]
            final FS_Installation__c installPlan=ipList.get(elementIndex);
            if(installPlan.Type_of_Dispenser_Platform__c.contains(LIT7K)){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,oDispRecTypId,false,1,'A');
                odList[0].put(EQUIPTYP, LIT7K);
                
            }
            if(installPlan.Type_of_Dispenser_Platform__c.contains(LIT8K)){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,oDispRecTypId,false,1,'B');
                odList[0].put(EQUIPTYP, LIT8K);
                
            }
            
            if(installPlan.Type_of_Dispenser_Platform__c.contains(LIT9K)){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,oDispRecTypId,false,1,'D');
                odList[0].put(EQUIPTYP, LIT9K);
                
            }
            oDispList.addAll(odList);
        }
        insert oDispList;
        system.assert((Limits.getLimitQueries() - Limits.getQueries())>0);  
        system.assertEquals(200,oDispList.size());  
        
        //get test data 
        final List<FS_Brandset__c> brandsetRecorList=[SELECT Id,Name,FS_Country__c,FS_Effective_End_Date__c,FS_Effective_Start_Date__c,
                                                      FS_Platform__c FROM FS_Brandset__c limit 1000];       
        final Map<Id,String> dispRecTypIdNam=FSUtil.getObjectRecordTypeIdAndNAme(FS_Outlet_Dispenser__c.SObjectType);
        //Separate Brandset based on platform 
        final List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecorList){
            if(branset.FS_Platform__c.contains(LIT7K)){ branset7000List.add(branset);}
            if(branset.FS_Platform__c.contains(LIT8K)){ branset8000List.add(branset);}
            if(branset.FS_Platform__c.contains(LIT9K)){ branset9000List.add(branset);}
        }
         Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        //Create Association Brandset
        final List<FS_Association_Brandset__c > assoBrndstLst =new List<FS_Association_Brandset__c >();
        //create association 10 brandset records for each installation 
        for(FS_Outlet_Dispenser__c outletDispenser: [SELECT Id,FS_Equip_Type__c,RecordTypeId FROM FS_Outlet_Dispenser__c limit 200]){
            List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
            
            if(outletDispenser.FS_Equip_Type__c.contains(LIT7K)){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset7000List,'FS_Outlet_Dispenser__c',outletDispenser.Id,1);
                for(Integer i=0;i<associationList.size();i++){
                    associationList[0].put(PLATFORM, LIT7K);
                }
                assoBrndstLst.addAll(associationList);
            }
            if(outletDispenser.FS_Equip_Type__c.contains(LIT8K)){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset8000List,'FS_Outlet_Dispenser__c',outletDispenser.Id,1);
                for(Integer i=0;i<associationList.size();i++){
                    associationList[0].put(PLATFORM, LIT8K);
                }
                assoBrndstLst.addAll(associationList);
            }
            
            if(outletDispenser.FS_Equip_Type__c.contains(LIT9K)){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset9000List,'FS_Outlet_Dispenser__c',outletDispenser.Id,1);
                for(Integer i=0;i<associationList.size();i++){
                    associationList[0].put(PLATFORM, LIT9K);
                }
                assoBrndstLst.addAll(associationList);
            }
        } 
        insert assoBrndstLst;
        Test.stopTest();
        final profile sysProfile=[SELECT id,name from profile where name='System Administrator'];
        final User user = new User();
        user.FirstName = 'test';
        user.LastName ='user';
        user.Email = 'testFlavor@testdomain.com';
        user.Username = 'test-'+sysProfile.ID+'@testdomain.comtestuser';
        user.ProfileId = sysProfile.id;
        user.Alias = 'test';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        insert user;    
        //custom setting trigger switch
        FSTestFactory.createTestDisableTriggerSetting();
    }
    
    private static testMethod void testReadValidDocumentMoreRecords(){
        
        
        //to get SObjectType for Outlet Dispenser from TriggerClass
        //start
        final FS_Outlet_Dispenser__c oD=new FS_Outlet_Dispenser__c();
        final TriggerClass trigClass = new TriggerClass(oD,false,false,false,false,false,false,null,null,null,null);
        final TriggerClass trigClass2=new TriggerClass();
        final Schema.SObjectType targetType = Schema.getGlobalDescribe().get('FS_Outlet_Dispenser__c');
        final sObject obj1 = targetType.newSObject();
        TriggerClass.obj=obj1;
        final sObjectType sObj=trigClass.getObjectType();
        //end
       
        final User sysAdminUser=FSTestUtil.createUser(null,1, FSConstants.USER_POFILE_SYSADMIN, true); 
         final User acUser=FSTestUtil.createUser(null,2, FSConstants.USER_POFILE_AC, true);  
        final User comUser=FSTestUtil.createUser(null,3, FSConstants.USER_POFILE_COM, true);  
        final User pmUser=FSTestUtil.createUser(null,4, FSConstants.USER_POFILE_PM, true);  
        system.debug('@@@@'+acUser+comUser+pmUser);
        system.runAs(sysAdminUser)
        {
            Test.startTest();
            final Account outlt=[SELECT Id,Name,FS_Headquarters__c,FS_ACN__c FROM Account where FS_Headquarters__c!=null limit 1]; 
            final Account hqAcc=[SELECT Id,Name,FS_ACN__c FROM Account where Id=:outlt.FS_Headquarters__c limit 1]; 
            final FS_Outlet_Dispenser__c oDisp=[SELECT Id,Name,FS_Serial_Number2__c,FS_Dispenser_Location__c,FS_ACN_NBR__c  FROM FS_Outlet_Dispenser__c where FS_Outlet__c=:outlt.Id limit 1];
            final List<FS_Brandset__c> brandsetRecorList=[SELECT Id,Name,FS_SAP_Item_Proposal_Number__c FROM FS_Brandset__c limit 1000];       
            system.assertEquals(37,brandsetRecorList.size()); 
            final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
            holder.FS_WorkBook_Name__c='Dispenser WorkBook';
            insert holder;
            
            
            outlt.FS_ACN__c='0000001155'; 
            outlt.FS_Requested_Delivery_Method__c='distributor';
            outlt.FS_Requested_Order_Method__c='distributor';
            update outlt;
            oDisp.FS_Serial_Number2__c='IPL1234567';
            oDisp.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
            oDisp.FS_Outlet__c=outlt.Id;
            update oDisp;
            //create Attachment
            final Attachment file= new Attachment();
            //file.Body=csvFile;
            final StaticResource staticResrc =[SELECT Id,Body FROM StaticResource WHERE Name = 'Test_Upload' LIMIT 1];
            file.Body= staticResrc.Body;
            file.ContentType = 'text';
            file.parentId = holder.Id;
            file.Name='Dispenser WorkBook'; 
            insert file;
            
            Database.executeBatch(new FSMassUpdateFlavorChangeBatch(holder.Id,hqAcc.Id,hqAcc.FS_ACN__c));
            Test.stopTest();
        }
    }
    
    
    private static testMethod void testReadValidDocumentMoreRecords1(){
       
        final User sysAdminUser=FSTestUtil.createUser(null,1, FSConstants.USER_POFILE_SYSADMIN, true);
        
        system.runAs(sysAdminUser){
            Test.startTest();
            
            
            final  Account outlt=[SELECT Id,Name,FS_Headquarters__c,FS_ACN__c FROM Account where FS_Headquarters__c!=null limit 1]; 
            final Account hqAcc=[SELECT Id,Name,FS_ACN__c FROM Account where Id=:outlt.FS_Headquarters__c limit 1]; 
            final  FS_Outlet_Dispenser__c oDisp=[SELECT Id,Name,FS_Serial_Number2__c,FS_Dispenser_Location__c,FS_ACN_NBR__c  FROM FS_Outlet_Dispenser__c where FS_Outlet__c=:outlt.Id limit 1];
            final List<FS_Brandset__c> brandsetRecorList=[SELECT Id,Name,FS_SAP_Item_Proposal_Number__c FROM FS_Brandset__c limit 1000];       
            system.assertEquals(37,brandsetRecorList.size()); 
            final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
            holder.FS_WorkBook_Name__c='Dispenser WorkBook';
            insert holder;
            
            oDisp.FS_Serial_Number2__c='IPL1234567';
            oDisp.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
            oDisp.FS_Outlet__c=outlt.Id;
            update oDisp;
            outlt.FS_ACN__c='0000001155'; 
            outlt.FS_Requested_Delivery_Method__c='distributor';
            outlt.FS_Requested_Order_Method__c='Coke Smart';
            update outlt;
            //create Attachment
            final Attachment file= new Attachment();
            //file.Body=csvFile;
            final StaticResource staticResrc =[SELECT Id,Body FROM StaticResource WHERE Name = 'Test_Upload1' LIMIT 1];
            file.Body= staticResrc.Body;
            file.ContentType = 'text';
            file.parentId = holder.Id;
            file.Name='Dispenser WorkBook'; 
            insert file;
            
            Database.executeBatch(new FSMassUpdateFlavorChangeBatch(holder.Id,hqAcc.Id,hqAcc.FS_ACN__c));
            Test.stopTest(); 
        }
    }
         private static testMethod void testReadValidDocumentMoreRecords2(){
             
     
         final User acUser=FSTestUtil.createUser(null,2, FSConstants.USER_POFILE_AC, true);  
        final User comUser=FSTestUtil.createUser(null,3, FSConstants.USER_POFILE_COM, true);  
        final User pmUser=FSTestUtil.createUser(null,4, FSConstants.USER_POFILE_PM, true); 
        final User sysAdminUser=FSTestUtil.createUser(null,1, FSConstants.USER_POFILE_SYSADMIN, true);
        
        system.runAs(sysAdminUser){
            Test.startTest();
            
            
            final  Account outlt=[SELECT Id,Name,FS_Headquarters__c,FS_ACN__c FROM Account where FS_Headquarters__c!=null limit 1]; 
            final Account hqAcc=[SELECT Id,Name,FS_ACN__c FROM Account where Id=:outlt.FS_Headquarters__c limit 1]; 
            final  FS_Outlet_Dispenser__c oDisp=[SELECT Id,Name,FS_Serial_Number2__c,FS_Dispenser_Location__c,FS_ACN_NBR__c  FROM FS_Outlet_Dispenser__c where FS_Outlet__c=:outlt.Id limit 1];
            final List<FS_Brandset__c> brandsetRecorList=[SELECT Id,Name,FS_SAP_Item_Proposal_Number__c FROM FS_Brandset__c limit 1000];       
            system.assertEquals(37,brandsetRecorList.size()); 
            final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
            holder.FS_WorkBook_Name__c='Dispenser WorkBook';
            insert holder;
            
            oDisp.FS_Serial_Number2__c='IPL1234567';
            oDisp.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
            oDisp.FS_Outlet__c=outlt.Id;
            update oDisp;
            outlt.FS_ACN__c='0000001155'; 
            outlt.FS_Requested_Delivery_Method__c='distributor';
            outlt.FS_Requested_Order_Method__c='distributor';
            update outlt;
            //create Attachment
            final Attachment file= new Attachment();
            //file.Body=csvFile;
            final StaticResource staticResrc =[SELECT Id,Body FROM StaticResource WHERE Name = 'Test_Upload3' LIMIT 1];
            file.Body= staticResrc.Body;
            file.ContentType = 'text';
            file.parentId = holder.Id;
            file.Name='Dispenser WorkBook'; 
            insert file;
            
            Database.executeBatch(new FSMassUpdateFlavorChangeBatch(holder.Id,hqAcc.Id,hqAcc.FS_ACN__c));
            Test.stopTest(); 
        }
    }   
    private static testMethod void booleanParserTest(){
        
        
        //to get SObjectType for Outlet Dispenser from TriggerClass
        //start
        final FS_Outlet_Dispenser__c oD=new FS_Outlet_Dispenser__c();
        final TriggerClass trigClass = new TriggerClass(oD,false,false,false,false,false,false,null,null,null,null);
        final TriggerClass trigClass2=new TriggerClass();
        final Schema.SObjectType targetType = Schema.getGlobalDescribe().get('FS_Outlet_Dispenser__c');
        final sObject obj1 = targetType.newSObject();
        TriggerClass.obj=obj1;
        final sObjectType sObj=trigClass.getObjectType();
        //end
       
        final User sysAdminUser=FSTestUtil.createUser(null,1, FSConstants.USER_POFILE_SYSADMIN, true); 
         final User acUser=FSTestUtil.createUser(null,2, FSConstants.USER_POFILE_AC, true);  
        final User comUser=FSTestUtil.createUser(null,3, FSConstants.USER_POFILE_COM, true);  
        final User pmUser=FSTestUtil.createUser(null,4, FSConstants.USER_POFILE_PM, true);  
        system.debug('@@@@'+acUser+comUser+pmUser);
        system.runAs(sysAdminUser)
        {
            Test.startTest();
            Boolean bVal = FSMassUpdateFlavorChangeBatchHelper.booleanParser('yes');
            Test.stopTest();
            system.assertEquals(true,bVal);
        }
    }
}