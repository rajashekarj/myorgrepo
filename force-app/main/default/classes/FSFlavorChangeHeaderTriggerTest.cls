/**************************************************************************************
Apex Class Name     : FSFlavorChangeHeaderTriggerTest
Version             : 1.0
Function            : This test class is for  FSFlavorChangeHeaderTrigger Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             01/21/2017          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSFlavorChangeHeaderTriggerTest{
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
        
        insert new Disable_Trigger__c(Name='FSAccountBusinessProcess',ISACTIVE__C=false);
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
        //Verify that 4 (1 * 4) Installation Plan got created
        system.assertEquals(1,installationPlanList.size()); 
        
        final List<FS_Outlet_Dispenser__c> odDispList=  createDispenser(branset7000List, branset8000List, branset9000List, installationPlanList) ;
        //Create trigger switch custom setting
        FSTestFactory.createTestDisableTriggerSetting();
        createFlavorChange(outletCustomerList, odDispList,branset7000List, branset8000List, branset9000List);
        
    }
    private static List<FS_Outlet_Dispenser__c> createDispenser(final List<FS_Brandset__c> branset7000List, final List<FS_Brandset__c> branset8000List, final List<FS_Brandset__c> branset9000List, final List<FS_Installation__c > installationPlanList)
    {
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        
        
        //Create 200 Outlet Dispensers 
        for(Integer i=0;i<1;i++){
            
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId;
            
            final FS_Installation__c installPlan=installationPlanList.get(i);
            final Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
            
            outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
            odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
            odList[0].put(EQUIPTYP, LIT7K);
            outletDispenserList.addAll(odList);
            
        }   
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        insert outletDispenserList;
        system.assertEquals(1,outletDispenserList.size());  
        
        final Map<Id,String> dispenserRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Outlet_Dispenser__c.SObjectType);
        //Create Association Brandset
        final List<FS_Association_Brandset__c > associationBrandsetList =new List<FS_Association_Brandset__c >();
        //create association brandset records for each Outlet Dispenser
        for(FS_Outlet_Dispenser__c dispenser : outletDispenserList){
            List<FS_Association_Brandset__c > associationList=new List<FS_Association_Brandset__c >();
            
            if(dispenser.FS_Equip_Type__c==LIT7K){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset7000List,DISPNSRTYP,dispenser.Id,1);
                associationList[0].put(PLATFOMTYP, LIT7K);
                associationBrandsetList.addAll(associationList);
            }
            if(dispenser.FS_Equip_Type__c==LIT8K){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset8000List,DISPNSRTYP,dispenser.Id,1);
                associationList[0].put(PLATFOMTYP, LIT8K);
                associationBrandsetList.addAll(associationList);
            }
            
            if(dispenser.FS_Equip_Type__c==LIT9K){
                associationList=FSTestFactory.createTestAssociationBrandset(false,branset9000List,DISPNSRTYP,dispenser.Id,1);
                associationList[0].put(PLATFOMTYP, LIT9K);
                associationBrandsetList.addAll(associationList);
            }
        }
        
        insert associationBrandsetList;
        system.assertEquals(1,associationBrandsetList.size());  
        
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
                                                                                                                          installationIdReference,false,1,flavorChangeHeaderRecordTypeIdForOutlet);
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
        system.assertEquals(1,flavorChangeHeaderList.size());  
        
        //Create 200 Flavor Change Line Records
        final Id flavorChangeLineRecordTypeIdForOutlet=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_New__c.SObjectType,'FS Flavor Change Outlet');
        
        final List<FS_Flavor_Change_New__c> flavorChangeLineList=new List<FS_Flavor_Change_New__c>();
        Integer recordIndexCounter=0;
        for(FS_Flavor_Change_Head__c header : flavorChangeHeaderList){
            
            flavorChangeLineList.addAll(FSTestFactory.createTestFlavorChangeLine(header.Id,installationIdReference,outletDispenserList.get(recordIndexCounter).FS_Outlet__c,
                                                                                 outletDispenserList.get(recordIndexCounter).Id,false,1,flavorChangeLineRecordTypeIdForOutlet)); 
            recordIndexCounter++; 
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
            if(dispenserRecordType==LIT7K){
                flavorChangeLine.FS_Platform__c=LIT7K; 
                flavorChangeLine.FS_New_Brandset__c=branset7000List.get(0).Id;
            }else if(dispenserRecordType==LIT8K){
                flavorChangeLine.FS_Platform__c=LIT8K; 
                flavorChangeLine.FS_New_Brandset__c=branset8000List.get(0).Id;
            }
            else if(dispenserRecordType==LIT9K){
                flavorChangeLine.FS_Platform__c=LIT9K; 
                flavorChangeLine.FS_New_Brandset__c=branset9000List.get(0).Id;
            }
            
            recordIndexCounter++;
        }
        insert flavorChangeLineList;
        system.assertEquals(1,flavorChangeLineList.size());          
    }
    
    
    private static testMethod void testUpdateFlavorCHangeHeaderApproved(){
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
        List<FS_Flavor_Change_New__c> f=new List<FS_Flavor_Change_New__c>();
        for(FS_Flavor_Change_New__c flavorChange :[SELECT ID,name,FS_New_Brandset__c,FS_New_Brandset__r.name,FS_New_Brandset__r.FS_Brandset_number__c,
                                                   FS_BS_Effective_Date__c,FS_Hide_Show_Dasani__c,FS_DA_Effective_Date__c,FS_Hide_Show_Water_Button__c,
                                                   FS_WA_Effective_Date__c FROM FS_Flavor_Change_New__c WHERE FS_Final_Approval__c=true AND FS_Outlet_Dispenser__c!=NULL
                                                   AND FS_BS_Effective_Date__c=:Date.today() ORDER BY  LastModifiedDate DESC LIMIT 5]){
                                                       outletDispensers.add(flavorChange.FS_Outlet_Dispenser__c);
                                                       flavorChange.FS_FC_Head__c=headerRecordsToUpdate[0].id;
                                                       f.add(flavorChange);
                                                   }    
update f;  
        
        for(FS_Outlet_Dispenser__c  dispenser :  [SELECT Id,FS_Brandset_New__c,FS_Brandset_Effective_Date__c 
                                                  FROM FS_Outlet_Dispenser__c   WHERE Id in: outletDispensers]){
                                                      system.assertEquals(NULL,dispenser.FS_Brandset_New__c);    
                                                      system.assertEquals(NULL,dispenser.FS_Brandset_Effective_Date__c );                                   
                                                  } 
        For(FS_Flavor_Change_Head__c Head : headerRecordsToUpdate){
           headerMap.put(Head.Id, Head);
        }
        
        FSFlavorChangeHeaderBusinessProcess.createServiceOrder(headerMap);
        
        Test.stopTest();
        
    }
    
    private static testMethod void testUpdateFlavorCHangeHeaderCDMSetup2(){
        final List<Account> outletsToUpdate=new  List<Account>();
        Test.startTest();
        for(Account outlet: [SELECT Id,FS_Requested_Delivery_Method__c,FS_Requested_Order_Method__c FROM Account WHERE RecordTypeId=:FSUtil.getObjectRecordTypeId(Account.SObjectType,FSOUTLET)]){
            outlet.FS_Requested_Delivery_Method__c='Distributor';
            outlet.FS_Requested_Order_Method__c ='VMS';
            outletsToUpdate.add(outlet);
        }
        
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        
        system.runas(contextUser){
            //update Outlet's Request Delivery Method
            update outletsToUpdate;
            
            final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate=new List<FS_Flavor_Change_Head__c>();
            
            for(FS_Flavor_Change_Head__c header : [SELECT FS_Approved__c,FS_CDM_Setup_Complete__c,FS_POM_Action_Complete__c
                                                   FROM FS_Flavor_Change_Head__c LIMIT 200]){
                                                       
                                                       header.FS_CDM_Setup_Complete__c=true;
                                                       header.FS_SS_Readiness_Alert__c=true;
                                                       header.FS_SS_Alert_Status__c=true;
                                                       header.FS_POM_Action_Complete__c=true;
                                                       header.FS_NDO_Approval__c='Rejected';
                                                       header.FS_FC_Type__c='File Upload Flavor Change';
                                                       header.FS_HQ_Chain__c=outletsToUpdate[0].id;
                                                       headerRecordsToUpdate.add(header);                                    
                                                   }  
            
            update headerRecordsToUpdate;
            headerRecordsToUpdate[0].FS_NDO_Approval__c='Approved';
            update headerRecordsToUpdate[0];
            
            System.assertEquals(1,headerRecordsToUpdate.size());
        }
        Test.stopTest();
    }
    
    
    private static testMethod void testUpdateFlavorCHangeHeaderCDMSetup(){
        final List<Account> outletsToUpdate=new  List<Account>();
        Test.startTest();
        for(Account outlet: [SELECT Id,FS_Requested_Delivery_Method__c,FS_Requested_Order_Method__c FROM Account WHERE RecordTypeId=:FSUtil.getObjectRecordTypeId(Account.SObjectType,FSOUTLET)]){
            outlet.FS_Requested_Delivery_Method__c='Direct Ship';
            outlet.FS_Requested_Order_Method__c ='VMS';
            outletsToUpdate.add(outlet);
        }
        
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        
        system.runas(contextUser){
            //update Outlet's Request Delivery Method
            update outletsToUpdate;
            
            final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate=new List<FS_Flavor_Change_Head__c>();
            
            for(FS_Flavor_Change_Head__c header : [SELECT FS_Approved__c,FS_CDM_Setup_Complete__c,FS_POM_Action_Complete__c
                                                   FROM FS_Flavor_Change_Head__c LIMIT 200]){
                                                       
                                                       header.FS_CDM_Setup_Complete__c=true;
                                                       header.FS_SS_Readiness_Alert__c=true;
                                                       header.FS_SS_Alert_Status__c=true;
                                                       header.FS_POM_Action_Complete__c=true;
                                                       header.FS_NDO_Approval__c='Rejected';
                                                       headerRecordsToUpdate.add(header);                                    
                                                   }  
            
            update headerRecordsToUpdate;
            System.assertEquals(1,headerRecordsToUpdate.size());
        }
        Test.stopTest();
    }
    
    private static testMethod void testUpdateFlavorCHangeHeaderCDMSetup1(){
        
        final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate=new List<FS_Flavor_Change_Head__c>();
        final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate1=new List<FS_Flavor_Change_Head__c>();
        final List<FS_Flavor_Change_Head__c> fcOutletLevelHeadList=new List<FS_Flavor_Change_Head__c>();
        final FS_Flavor_Change_Head__c header=new FS_Flavor_Change_Head__c();  
        //Id recType=  FSUtil.getObjectRecordTypeId(FS_Flavor_Change_Head__c.SObjectType,'FS Flavor Change Chain HQ'); 
        //header.RecordTypeId=recType;
        header.FS_FC_Type__c='Workflow Flavor Change';
        header.FS_CDM_Setup_Complete__c=false;
        header.FS_SS_Readiness_Alert__c=false;
        header.FS_SS_Alert_Status__c=false;
        header.FS_Project_Name__c='sample';
        header.RecordTypeId=Schema.SObjectType.FS_Flavor_Change_Head__c.getRecordTypeInfosByName().get('FS Flavor Change Chain HQ').getRecordTypeId();
        insert header;
        final FS_Flavor_Change_Head__c newFlavorChangeHeader =new FS_Flavor_Change_Head__c();
        newFlavorChangeHeader.FS_Parent_Flavor_Change__c=header.Id;
        newFlavorChangeHeader.RecordtypeId=Schema.SObjectType.FS_Flavor_Change_Head__c.getRecordTypeInfosByName().get('FS Flavor Change Outlet').getRecordTypeId();
        newFlavorChangeHeader.FS_FC_Type__c='Workflow Flavor Change';
        fcOutletLevelHeadList.add(newFlavorChangeHeader);
        Test.startTest();
        final FS_Flavor_Change_Head__c newFlavChangeHeader =new FS_Flavor_Change_Head__c();
        newFlavChangeHeader.FS_Parent_Flavor_Change__c=header.Id;
        newFlavChangeHeader.RecordtypeId=Schema.SObjectType.FS_Flavor_Change_Head__c.getRecordTypeInfosByName().get('FS Flavor Change Outlet').getRecordTypeId();
        newFlavChangeHeader.FS_FC_Type__c='Workflow Flavor Change';
        fcOutletLevelHeadList.add(newFlavChangeHeader);
        
        insert fcOutletLevelHeadList;
        
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);
        
         
        System.runAs(contextUser){
            FS_Flavor_Change_Head__c newFCHeader =new FS_Flavor_Change_Head__c();
            newFCHeader=header;
            //newFCHeader=[SELECT FS_Approved__c,FS_CDM_Setup_Complete__c,FS_POM_Action_Complete__c,FS_Project_Name__c,FS_SS_Readiness_Alert__c,
            //FS_SS_Alert_Status__c FROM FS_Flavor_Change_Head__c where FS_Project_Name__c LIKE '%sample%' LIMIT 1];
            newFCHeader.FS_CDM_Setup_Complete__c=true;
            newFCHeader.FS_SS_Readiness_Alert__c=true;
            newFCHeader.FS_SS_Alert_Status__c=true;
            newFCHeader.FS_Project_Name__c='akdasjdkasjskdsajkd';
            //newFCHeader.RecordTypeId=Schema.SObjectType.FS_Flavor_Change_Head__c.getRecordTypeInfosByName().get('FS Flavor Change Chain HQ').getRecordTypeId();
            headerRecordsToUpdate.add(newFCHeader); 
            update headerRecordsToUpdate;
        }                            
        Test.stopTest(); 
        
        system.assertEquals(2,fcOutletLevelHeadList.size());
    }
    
    private static testMethod void testUpdateNDO(){
        final List<Account> outletsToUpdate=new  List<Account>();
        Test.startTest();
        for(Account outlet: [SELECT Id,FS_Requested_Delivery_Method__c,FS_Requested_Order_Method__c FROM Account WHERE RecordTypeId=:FSUtil.getObjectRecordTypeId(Account.SObjectType,FSOUTLET)]){
            outlet.FS_Requested_Delivery_Method__c='Distributor';
            outlet.FS_Requested_Order_Method__c ='Distributor';
            outletsToUpdate.add(outlet);
        }
        
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        
        System.runAs(contextUser){
            //update Outlet's Request Delivery Method
            update outletsToUpdate;
            
            final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate=new List<FS_Flavor_Change_Head__c>();
            
            for(FS_Flavor_Change_Head__c header : [SELECT FS_Approved__c,FS_CDM_Setup_Complete__c,FS_POM_Action_Complete__c
                                                   FROM FS_Flavor_Change_Head__c LIMIT 200]){
                                                       
                                                       header.FS_CDM_Setup_Complete__c=true;
                                                       header.FS_SS_Readiness_Alert__c=true;
                                                       header.FS_SS_Alert_Status__c=true;
                                                       header.FS_POM_Action_Complete__c=true;
                                                       header.FS_NDO_Approval__c='Rejected';
                                                       headerRecordsToUpdate.add(header);                                    
                                                   }  
            
            update headerRecordsToUpdate; 
            System.assertEquals(1,headerRecordsToUpdate.size());
        }
        Test.stopTest();
    }
    
    private static testMethod void testUpdateNDOApproved(){
        final List<Account> outletsToUpdate=new  List<Account>();
        Test.startTest();
        for(Account outlet: [SELECT Id,FS_Requested_Delivery_Method__c,FS_Requested_Order_Method__c FROM Account WHERE RecordTypeId=:FSUtil.getObjectRecordTypeId(Account.SObjectType,FSOUTLET)]){
            outlet.FS_Requested_Delivery_Method__c='Distributor';
            outlet.FS_Requested_Order_Method__c ='Distributor';
            outletsToUpdate.add(outlet);
        }
        
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        
        System.runAs(contextUser){
            //update Outlet's Request Delivery Method
            update outletsToUpdate;
            
            final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate=new List<FS_Flavor_Change_Head__c>();
            
            for(FS_Flavor_Change_Head__c header : [SELECT FS_Approved__c,FS_CDM_Setup_Complete__c,FS_POM_Action_Complete__c
                                                   FROM FS_Flavor_Change_Head__c LIMIT 200]){
                                                       
                                                       header.FS_CDM_Setup_Complete__c=true;
                                                       header.FS_SS_Readiness_Alert__c=true;
                                                       header.FS_SS_Alert_Status__c=true;
                                                       header.FS_POM_Action_Complete__c=true;
                                                       header.FS_NDO_Approval__c='Approved';
                                                       headerRecordsToUpdate.add(header);                                    
                                                   }  
            
            update headerRecordsToUpdate; 
            System.assertEquals(1,headerRecordsToUpdate.size());
        }
        Test.stopTest();
    }  
    
    private static testMethod void testUpdateNDOReject(){
        
        final Account bottlrBottlr=FSTestUtil.createTestAccount('Test HQ1', FSConstants.RECORD_TYPE_HQ, true);
        system.debug('Limits'+limits.getQueries());
        Test.startTest();
        // final Account bottlrBottlr=FSTestUtil.createAccountHeadquarter(true);
        bottlrBottlr.FS_Requested_Order_Method__c='Bottler';
        bottlrBottlr.FS_Requested_Delivery_Method__c='Bottler';
        bottlrBottlr.FS_Approved_Bottler_Order_Delivery__c=true;
        
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        
        System.runAs(contextUser){
            update bottlrBottlr;
            system.debug('Limits1'+limits.getQueries());
            final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate=new List<FS_Flavor_Change_Head__c>();
            
            for(FS_Flavor_Change_Head__c header : [SELECT FS_Approved__c,FS_CDM_Setup_Complete__c,FS_POM_Action_Complete__c,FS_HQ_Chain__c
                                                   FROM FS_Flavor_Change_Head__c LIMIT 200]){
                                                       
                                                       header.FS_CDM_Setup_Complete__c=true;
                                                       header.FS_SS_Readiness_Alert__c=true;
                                                       header.FS_SS_Alert_Status__c=true;
                                                       header.FS_POM_Action_Complete__c=true;
                                                       header.FS_HQ_Chain__c=bottlrBottlr.Id;
                                                       header.FS_NDO_Approval__c='Rejected';
                                                       headerRecordsToUpdate.add(header);                                    
                                                   }  
            
            update headerRecordsToUpdate; 
            system.debug('Limits2'+limits.getQueries());
            //System.assertEquals(4,headerRecordsToUpdate.size());
        }
        Test.stopTest();
    }
    
    private static testMethod void testUpdateNDOApproved1(){
        
        final Account bottlrBottlr=FSTestUtil.createTestAccount('Test HQ2', FSConstants.RECORD_TYPE_HQ, false);
        
        // final Account bottlrBottlr=FSTestUtil.createAccountHeadquarter(true);
        bottlrBottlr.FS_Requested_Order_Method__c='Bottler';
        bottlrBottlr.FS_Requested_Delivery_Method__c='Bottler';
        bottlrBottlr.FS_Approved_Bottler_Order_Delivery__c=true;
        Test.startTest();
        final Profile contextProfile = [select id from profile where name='System Administrator'];
        final User contextUser = FSTestFactory.createUser(contextProfile.id);     
        
        System.runAs(contextUser){
            insert bottlrBottlr;
            
            final List<FS_Flavor_Change_Head__c> headerRecordsToUpdate=new List<FS_Flavor_Change_Head__c>();
            
            for(FS_Flavor_Change_Head__c header : [SELECT FS_Approved__c,FS_CDM_Setup_Complete__c,FS_POM_Action_Complete__c,FS_HQ_Chain__c
                                                   FROM FS_Flavor_Change_Head__c LIMIT 200]){
                                                       
                                                       header.FS_CDM_Setup_Complete__c=true;
                                                       header.FS_SS_Readiness_Alert__c=true;
                                                       header.FS_SS_Alert_Status__c=true;
                                                       header.FS_POM_Action_Complete__c=true;
                                                       header.FS_HQ_Chain__c=bottlrBottlr.Id;
                                                       header.FS_NDO_Approval__c='Approved';
                                                       headerRecordsToUpdate.add(header);                                    
                                                   } 
            Test.stopTest();
            
            update headerRecordsToUpdate; 
            //System.assertEquals(4,headerRecordsToUpdate.size());
        }
        
    }   
}