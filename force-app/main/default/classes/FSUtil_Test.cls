@isTest
private class FSUtil_Test{    
    public static final String ACCNAME='Account';
    public static final String CLASSNAME='FSUtil_Test';
    public static final String CLASSMETHOD='testcleanSpecialCharacters';
    private static final String SERIES7K = '7000 Series';
    private static final String SERIES8K9K = '8000 & 9000 Series';
    private static final String SERIES8K = '8000 Series';
    private static final String SERIES9K = '9000 Series';
    private static final String EQUIPTYP = 'FS_Equip_Type__c';
    private static final String PLATFOMTYP = 'FS_Platform__c';
    private static final String DISPNSRTYP = 'FS_Outlet_Dispenser__c';
    private static final String FSOUTLET='FS Outlet';
    private static final string LIT7K = '7000';
    private static final string LIT8K = '8000';
    private static final string LIT9K = '9000';
    private static final Integer ZEROVALUE=0;
    public static List<Account> hqList;
    private final static String LIT7KS='7000 Series';
    private final static String LIT8K9K='8000/9000 Series';
    private final static String SERVICEPROVIDERACCOUNT='FS Service Provider';
    private final static List<String> LISTOFZIPCODES=new List<String>{'13217-6969','13219-6969','30303','30304','30305'}; 
    
   // public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5; 
    
    @testSetup
    private static void loadTestData(){
        
        //Create trigger switch custom setting
        FSTestFactory.createTestDisableTriggerSetting();
        
        //create Brandset records  
        final List<FS_Brandset__c> brandsetRecordList=FSTestFactory.createTestBrandset();
        
        //Separate Brandset based on platform 
        final  List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
        final  List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
        final  List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecordList){
            if(branset.FS_Platform__c.contains(LIT7K)){
                branset7000List.add(branset);
            }
            if(branset.FS_Platform__c.contains(LIT8K)) {
                branset8000List.add(branset);
            }
            if(branset.FS_Platform__c.contains(LIT9K)){
                branset9000List.add(branset);
            }
        }
        
        //verify branset of each platform type
        system.assert(!(branset7000List).isEmpty()); 
        system.assert(!(branset8000List).isEmpty()); 
        system.assert(!(branset9000List).isEmpty()); 
        Test.startTest();
        //Create Single HeadQuarter
        final List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                                     FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
         
        List<Platform_Type_ctrl__c> listplatform = FSTestFactory.lstPlatform();
         
        
        //Create Single Outlet
        final List<Account> outletCustomerList=new List<Account>();
        for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,FSOUTLET))){
            acc.FS_Requested_Delivery_Method__c='Bottler';
            acc.FS_Headquarters__c=headQuarterCustomerList.get(0).Id;
            acc.ShippingPostalCode='30303';
            outletCustomerList.add(acc);
        }
        insert outletCustomerList;
        //create service provider account
        final List<Account> serviceProviderCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                                         FSUtil.getObjectRecordTypeId(Account.SObjectType,SERVICEPROVIDERACCOUNT));
        
        final List<FS_SP_Aligned_Zip__c> spAlignedZipList=new List<FS_SP_Aligned_Zip__c>();   
        //final Id recordTypeId7K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(LIT7KS).getRecordTypeId();                                                                  
        //final Id recordTypeId8K9K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(LIT8K9K).getRecordTypeId();
        final string platform7k='7000';
        final string platform8k9k='8000';
        
        final Set<String> setOfZipCodes=FSServiceProviderHelper.formatZip(LISTOFZIPCODES);
        //Get all the Outlets
        for(String zipCode: setOfZipCodes){
            
            spAlignedZipList.addAll(FSTestFactory.createTestSPAlignedZip(serviceProviderCustomerList.get(0).Id,zipCode.substring(0,5),platform7k,false,1));
            spAlignedZipList.addAll(FSTestFactory.createTestSPAlignedZip(serviceProviderCustomerList.get(0).Id,zipCode.substring(0,5),platform8k9k,false,1));
        }
        
        //Insert FS_SP_Aligned_Zip__c
        spAlignedZipList[0].FS_Platform_Type__c='7000';
        spAlignedZipList[0].FS_Zip_Code__c=String.valueOf(LISTOFZIPCODES[0]).substring(0,5);
        insert spAlignedZipList; 
        Test.stopTest();
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
        insert executionPlanList;       
        //Create Installation
        final Set<String> installationPlanRecordTypesSet=new Set<String>{FSConstants.NEWINSTALLATION}; 
            final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >();         
        //Create Installation for each Execution Plan according to recordtype        
        for(String  installationRecordType : installationPlanRecordTypesSet){
            final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,installationRecordType); 
            final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
            installationPlanList.addAll(installList);
        }         
        insert installationPlanList;
        final List<FS_Outlet_Dispenser__c> odDispList=  createDispenser(branset7000List, branset8000List, branset9000List, installationPlanList) ;
        
        createFlavorChange(outletCustomerList, odDispList,branset7000List, branset8000List, branset9000List);
       
         FSUtil.checkPlatformValues(installationPlanList[0].id, 'newValue', 'oldValue') ;
         FSUtil.checkPlatformValues(installationPlanList[0].id, 'newValue', null) ;
        
           
    }
    
      private static List<FS_Outlet_Dispenser__c> createDispenser(final List<FS_Brandset__c> branset7000List, final List<FS_Brandset__c> branset8000List, final List<FS_Brandset__c> branset9000List, final List<FS_Installation__c > installationPlanList)
    {
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        
        
        //Create 200 Outlet Dispensers 
        for(Integer i=0;i<installationPlanList.size();i++){
            
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId;
            
            final FS_Installation__c installPlan=installationPlanList.get(i);
            final Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
            
            if(installationRecordTypeIdAndName.get(installPlan.RecordTypeId)==FsConstants.NewInstallation){
                outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
                odList[0].put(EQUIPTYP, LIT7K);
                
            }
            
            outletDispenserList.addAll(odList);
            
        }   
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        insert outletDispenserList;
        
        final Map<Id,String> dispenserRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Outlet_Dispenser__c.SObjectType);
        //Create Association Brandset
        final List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
        //create association brandset records for each Outlet Dispenser
        for(FS_Outlet_Dispenser__c dispenser : outletDispenserList){
            List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
            
            if(dispenserRecordTypeIdAndName.get(dispenser.RecordTypeId)==LIT7K){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset7000List,DISPNSRTYP,dispenser.Id,1);
                associationList[0].put(PLATFOMTYP, LIT7K);
                associationBrandsetList.addAll(associationList);
            }
            if(dispenserRecordTypeIdAndName.get(dispenser.RecordTypeId)==LIT8K){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset8000List,DISPNSRTYP,dispenser.Id,1);
                associationList[0].put(PLATFOMTYP, LIT8K);
                associationBrandsetList.addAll(associationList);
            }
            
            if(dispenserRecordTypeIdAndName.get(dispenser.RecordTypeId)==LIT9K){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset9000List,DISPNSRTYP,dispenser.Id,1);
                associationList[0].put(PLATFOMTYP, LIT9K);
                associationBrandsetList.addAll(associationList);
            }
        }
        
        insert associationBrandsetList;
        
        return outletDispenserList;
    }
    private static void createFlavorChange(final List<Account> outletCustomerList, final List<FS_Outlet_Dispenser__c> outletDispenserList, final List<FS_Brandset__c> branset7000List, final List<FS_Brandset__c> branset8000List, final List<FS_Brandset__c> branset9000List)
    {
        
        //Create 200 Flavor Change Header Records
        final Map<Id,String> dispenserRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Outlet_Dispenser__c.SObjectType);
        final List<FS_Flavor_Change_Head__c> flavorChangeHeaderList=new List<FS_Flavor_Change_Head__c>();
        
        final Id installationIdReference;
        final Id flavorChangeHeaderRecordTypeIdForOutlet=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_Head__c.SObjectType,'FS Flavor Change Outlet');
        final List<FS_Flavor_Change_Head__c> flavorChangeHeaderUnderOutletList=FSTestFactory.createTestFlavorChangeHeader(outletCustomerList.get(0).Id,
                                                                                                                          installationIdReference,false,4,flavorChangeHeaderRecordTypeIdForOutlet);
        Integer counterOddEven=0;
        for(FS_Flavor_Change_Head__c header : flavorChangeHeaderUnderOutletList){
            if(Math.mod(counterOddEven,2)==ZEROVALUE){
                header.FS_FC_Type__c='Workflow Flavor Change';
            }
            else{
                header.FS_FC_Type__c='File Upload Flavor Change'; 
            }
            counterOddEven++;
        }
        
        //add header records of FS Flavor Change Outlet type
        flavorChangeHeaderList.addAll(flavorChangeHeaderUnderOutletList); 
        
        //add header records of FS Flavor Change Installation type
        //flavorChangeHeaderList.addAll(flavorChangeHeaderUnderInstallationList);
        
        insert flavorChangeHeaderList;
        system.assertEquals(4,flavorChangeHeaderList.size());  
        
        //Create 200 Flavor Change Line Records
        final Id flavorChangeLineRecordTypeIdForOutlet=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_New__c.SObjectType,'FS Flavor Change Outlet');
        
        final List<FS_Flavor_Change_New__c> flavorChangeLineList=new List<FS_Flavor_Change_New__c>();
        Integer recordIndexCounter=0;
        for(FS_Flavor_Change_Head__c header : flavorChangeHeaderList){
            
            flavorChangeLineList.addAll(FSTestFactory.createTestFlavorChangeLine(header.Id,installationIdReference,outletDispenserList.get(recordIndexCounter).FS_Outlet__c,
                                                                                 outletDispenserList.get(recordIndexCounter).Id,false,1,flavorChangeLineRecordTypeIdForOutlet)); 
             
        }
        
        
        //Iterate to set effective Dates and corresponding values
        recordIndexCounter=0;
        for(FS_Flavor_Change_New__c flavorChangeLine :    flavorChangeLineList){
            flavorChangeLine.FS_Hide_Show_Dasani__c='Show';
            flavorChangeLine.FS_Hide_Show_Water_Button__c='Show';
            flavorChangeLine.FS_WA_Effective_Date__c=Date.today().addDays(2);
            flavorChangeLine.FS_DA_Effective_Date__c=Date.today().addDays(2);
            String dispenserRecordType='';
            final FS_Outlet_Dispenser__c dispenser =NULL;
            if(outletDispenserList.get(recordIndexCounter)!=dispenser){
                dispenserRecordType=dispenserRecordTypeIdAndName.get(outletDispenserList.get(recordIndexCounter).RecordTypeId);
                
                if(Math.mod(recordIndexCounter,2)==ZEROVALUE){
                    flavorChangeLine.FS_BS_Effective_Date__c=Date.today();
                }
                else{
                    flavorChangeLine.FS_BS_Effective_Date__c=Date.today().addDays(2);
                }
            }
            if(outletDispenserList.get(recordIndexCounter).FS_Equip_Type__c==LIT7K){
                flavorChangeLine.FS_Platform__c=LIT7K; 
                flavorChangeLine.FS_New_Brandset__c=branset7000List.get(0).Id;
            }else if(outletDispenserList.get(recordIndexCounter).FS_Equip_Type__c==LIT8K){
                flavorChangeLine.FS_Platform__c=LIT8K; 
                flavorChangeLine.FS_New_Brandset__c=branset8000List.get(0).Id;
            }
            else if(outletDispenserList.get(recordIndexCounter).FS_Equip_Type__c==LIT9K){
                flavorChangeLine.FS_Platform__c=LIT9K; 
                flavorChangeLine.FS_New_Brandset__c=branset9000List.get(0).Id;
            }
            
            
        }
        insert flavorChangeLineList;
        system.assertEquals(4,flavorChangeLineList.size());          
    }
    
    private static testMethod void testgetSelectQuery(){
        final User fetSysAdminUser=FSTestUtil.createUser(null, 1,FSConstants.USER_POFILE_FETADMIN, true);
        system.runAs(fetSysAdminUser){
            Test.starttest();
            FSUtil.getSelectQuery(ACCNAME);
            FSUtil.getEmailTemplateId('Service Message Failure');
            final Account acc=new Account();
            FSUtil.putValueInField(acc,ACCNAME,'Name','testAcc');
            
            final Boolean valueCheck=FSUtil.checkAccessForSobject(ACCNAME,FSConstants.ACCESS_IS_CREATABLE);        
            FSUtil.checkAccessForSobject(ACCNAME,FSConstants.ACCESS_IS_DELETABLE);        
            FSUtil.checkAccessForSobject(ACCNAME,FSConstants.ACCESS_IS_UPDATEABLE);
            FSUtil.checkAccessForSobject(ACCNAME,FSConstants.ACCESS_IS_UNDELETABLE);
            
            FSUtil.isNotNullOrBlank('testString');
            FSUtil.todecimal('2');
            FSUtil.todecimal('str');
            FSUtil.decimalToString(2);
            FSUtil.decimalToString(23.21);
            List<String> fieldList=FSUtil.lstRequiredFields;
            fieldList=FSUtil.lstRequiredFieldsForDoubleAstrik;
            
           // FSUtil.sendBatchReport(null);
            Test.stoptest();     
            system.assert(valueCheck);
        }
    }
    
        private static testMethod void testUpdateFlavorCHangeHeaderApproved(){
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate=new List<FS_Flavor_Change_Head__c>();
        final Map<Id,FS_Flavor_Change_Head__c> headerMap=new Map<Id,FS_Flavor_Change_Head__c>();
        Test.startTest();
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);  
        
        
        system.runAs(contextUser)
        {
        for(FS_Flavor_Change_Head__c header : [SELECT FS_Approved__c,FS_CDM_Setup_Complete__c,FS_POM_Action_Complete__c
                                               FROM FS_Flavor_Change_Head__c LIMIT 200]){
                                                   header.FS_Approved__c=true; 
                                                   header.FS_SP_go_out__c='Yes';
                                                   headerRecordsToUpdate.add(header);                                    
                                               }  
        
        update headerRecordsToUpdate;
        }
        
        
        
        //verify association Brandset update when effective date is today
        final Set<Id> outletDispensers=new Set<Id>();

        for(FS_Flavor_Change_New__c flavorChange :[SELECT ID,name,FS_New_Brandset__c,FS_New_Brandset__r.name,FS_New_Brandset__r.FS_Brandset_number__c,
                                                   FS_BS_Effective_Date__c,FS_Hide_Show_Dasani__c,FS_DA_Effective_Date__c,FS_Hide_Show_Water_Button__c,
                                                   FS_WA_Effective_Date__c,FS_Outlet_Dispenser__c FROM FS_Flavor_Change_New__c WHERE FS_Final_Approval__c=true AND FS_Outlet_Dispenser__c!=NULL
                                                   AND FS_BS_Effective_Date__c=:Date.today() ORDER BY  LastModifiedDate DESC LIMIT 5]){
                                                       outletDispensers.add(flavorChange.FS_Outlet_Dispenser__c);
                                                       
                                                   }    

        
        
        For(FS_Flavor_Change_Head__c Head : headerRecordsToUpdate){
           headerMap.put(Head.Id, Head);
        }
        List<String> LISTOFZIPCODES=new List<String>{'13217-6969','13219-6969','30303','30304','30305'}; 
        FSUtil.createServiceOrder(LISTOFZIPCODES,headerMap);
          
        Test.stopTest();
        
    }
    private static testMethod void testcleanSpecialCharacters(){
        final User fetSysAdminUser=FSTestUtil.createUser(null, 1,FSConstants.USER_POFILE_FETADMIN, true);
        system.runAs(fetSysAdminUser){
            FSUtil.cleanSpecialCharacters('Account***?');
            final Account acctest = new Account(name='helloTest');
            final List<Account> acclist = new List<Account>{acctest};     
            
            Test.startTest();
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                               Method_Name__c=CLASSMETHOD,Object_Name__c=ACCNAME,
                                                               Error_Severity__c=FSConstants.MediumPriority);
            FSUtil.dmlProcessorInsert(acclist,True,apexError);
            FSUtil.dmlProcessorUpdate(acclist,True,apexError);
            FSUtil.dmlProcessorUpsert(acclist,True,apexError);
            FSUtil.dmlProcessorDelete(acclist,True,apexError);    
                  
            FSUtil.getObjectRecordTypeIdAndNAme(Account.SObjectType);
            FSUtil.getObjectRecordTypeNameAndId ( Account.SObjectType);       
            FSUtil.getObjectRecordTypeId( Account.SObjectType, 'FS Outlet');        
            //Send email with attachment
            final Boolean valueCheck=FSUtil.sendMail(true,new List<Attachment>(),'subject','emailBody',new List<String>{UserInfo.getUserEmail()}); 
            
            FSUtil.getDescribeResultForSobject(Account.sobjecttype);
            
            FSUtil.getFieldPicklistValues( Account.SObjectType, 'Name');
            
            FSUtil.calculateNumberOfRowsInCSVFile(Blob.valueof('test'));
            Test.stoptest();
            system.assert(valueCheck);
        }
    }    
    
    private static testmethod void sendBatchReportTest(){      
        final User fetSysAdminUser=FSTestUtil.createUser(null, 1,FSConstants.USER_POFILE_FETADMIN, true);
        system.runAs(fetSysAdminUser){
            final Account acctest = new Account(name='helloTest');
            final List<Account> acclist = new List<Account>{acctest};      
             
            Test.startTest();
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                               Method_Name__c='sendBatchReportTest',Object_Name__c=ACCNAME,
                                                               Error_Severity__c=FSConstants.MediumPriority);
            FSUtil.dmlProcessorUpdate(acclist,True,apexError);
            FSUtil.dmlProcessorUpsert(acclist,True,apexError);
            FSUtil.dateParserHelper('05/05/201');
            FSUtil.dateParserHelper('05/05/2016 04:10:10');  
            FSUtil.dateParserHelper('05/05/1600 04:10:10');
            FSUtil.dateParserHelper('05/32/2016 05:11:15');
            FSUtil.dateParserHelper('13/13/2016 06:12:00');
            
            system.assert(!acclist.isEmpty());
            Test.stoptest();  
        }
    }
    private static testMethod void testMethodDml(){ 
        final User fetSysAdminUser=FSTestUtil.createUser(null, 1,FSConstants.USER_POFILE_FETADMIN, true);
        system.runAs(fetSysAdminUser){
            Test.startTest();
            final List<FS_Execution_Plan__c> exePlanList=FSTestFactory.createTestExecutionPlan(null,false,1,FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.sObjectType,'Execution Plan'));
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                               Method_Name__c='testMethodDml',Object_Name__c='FS_Execution_Plan__c',
                                                               Error_Severity__c=FSConstants.MediumPriority);
            final Boolean valueCheck=FSUtil.dmlProcessorInsert(exePlanList, true,apexError);
            FSUtil.dmlProcessorUpsert(exePlanList, true, apexError);
            system.assert(!valueCheck);
            Test.stopTest();
        }
    }    
    private static testMethod void testRecType(){        
        final User fetSysAdminUser=FSTestUtil.createUser(null, 1,FSConstants.USER_POFILE_FETADMIN, true);
        system.runAs(fetSysAdminUser){
            Test.starttest();
            //final Map<String,Schema.RecordTypeInfo> odrec=FSUtil.rtMapByNameForOD;
            final String valueCheck=FSUtil.leftPadWithZeroes('test',5);
            final List<String> recList = new List<String>{UserInfo.getUserEmail()};
            FSUtil.sendEMail(recList,'subject','emailBody',true); 
            FSUtil.sendEMail(recList,'subject','emailBody',false);         
            Test.stoptest();
            system.assertEquals('0test', valueCheck);
        }
    }    
}