/***********************************************************************************************************
Name         : FSTestFactory 
Created By   : Infosys Limited
Created Date : 30-Dec-2016
Usage        : Factory class for Test Classes
***********************************************************************************************************/
@isTest
public without sharing class FSTestFactory { 
    
    public static Map<Id,String> accountRecordTypes=new Map<Id,String>();
    public static String csvHeader,dispenserStatus,pickValYes,pickValShow;
    public static String pickValShareCoke,brandsetName8k9k,brandsetName7k,platform7k;
    public static String accountSobject='Account';
    public static final String DIRECTSHIP='Direct Ship';
    public static final String DISTRIBUTOR='Distributor';    
    public static final Integer VALUETEN=10;
    public static final Integer VALUEZERO=0;
    public static final Integer VALUESEVEN=7;   
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5; 
     /*** @desc creates Account records 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $numberOfAccounts- number of account records to be created.
		* @return List<Account>
		*/
    public static List<Account> createTestAccount(final Boolean isInsert,final Integer numberOfAccounts,final Id recordtypeId) {
        final List<Account> accountList=new List<Account>();
        final Map<String,String> recordTypesAndKOId=new Map<String,String>{'FS Chain'=>'13','FS Headquarters'=>'15','FS Outlet'=>'55'};
            Account newAcc=null;
            if(accountRecordTypes.isEmpty()){
                accountRecordTypes=FSUtil.getObjectRecordTypeIdAndNAme(Account.SObjectType);
            }       
        for(Integer i=0;i<numberOfAccounts;i++){
            newAcc=new Account ();
            newAcc.Name='Test Account '+ i;
            if(recordtypeId!=FSConstants.NULLVALUE){
            	newAcc.RecordtypeId=recordtypeId;            
            	newAcc.FS_ACN__c=FSUtil.leftPadWithZeroes(i+'11',8) + recordTypesAndKOId.get(accountRecordTypes.get(recordtypeId));
            	newAcc.FS_SAP_ID__c=FSUtil.leftPadWithZeroes(i+'22',8)+ recordTypesAndKOId.get(accountRecordTypes.get(recordtypeId));
            }
            newAcc.ShippingCity='SYRACUSE';
            newAcc.ShippingState='NY';
            newAcc.ShippingPostalCode='13217-6969';
            newAcc.ShippingCountry='US';
           /* newAcc.FS_Requested_Order_Method__c='Distributor';
                newAcc.FS_Requested_Delivery_Method__c='Distributor';
            newAcc.FS_Approved_for_Distributor_Ordering__c='Yes';*/
            accountList.add(newAcc);
        }
        if(isInsert) {
            insert accountList;
        }     
        return accountList;
    }
    //Create Platform_Type_ctrl__c custom setting data
    Public static List<Platform_Type_ctrl__c> lstPlatform(){
    final List<Platform_Type_ctrl__c> listplatform = new List<Platform_Type_ctrl__c>();
		platformTypes=new Platform_Type_ctrl__c();
		platformTypes.Name='updateBrands';
        platformTypes.Platforms__c='7000';
        listplatform.add(platformTypes);
		platformTypes1=new Platform_Type_ctrl__c();
		platformTypes1.Name='EquipmentTypeCheckForNMSUpdateCall';
        platformTypes1.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes1);
        platformTypes2=new Platform_Type_ctrl__c();
		platformTypes2.Name='WaterHideCheck';
        platformTypes2.Platforms__c='8000,9000';
        listplatform.add(platformTypes2);
        platformTypes3=new Platform_Type_ctrl__c();
		platformTypes3.Name='all_Platform';
        platformTypes3.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes3);
        platformTypes4=new Platform_Type_ctrl__c();
		platformTypes4.Name='updatecrewServeDasani';
        platformTypes4.Platforms__c='8000';
        listplatform.add(platformTypes4);
        platformTypes5=new Platform_Type_ctrl__c();
		platformTypes5.Name='updateSelfServeDasani';
        platformTypes5.Platforms__c='9000';
        listplatform.add(platformTypes5);
        insert listplatform; 
        return listplatform;
        
    }
    //OCR'17
     //Create ProfileListFromCustomSettings__c custom setting data
     public static List<ProfileListFromCustomSettings__c> lstProfiles (){
        final List<ProfileListFromCustomSettings__c> plist = New  List<ProfileListFromCustomSettings__c> ();
        final ProfileListFromCustomSettings__c acPC = new ProfileListFromCustomSettings__c();
		acPC.Name='ACPCProfiles';
		acPC.FS_Profile_Name__c='FS AC_P,FS PIC_P';
		   plist.add(acPC);
        final ProfileListFromCustomSettings__c com = new ProfileListFromCustomSettings__c();
		com.Name='COMProfiles';
		com.FS_Profile_Name__c='FS COM_P';
		   plist.add(com);
        final ProfileListFromCustomSettings__c pmAdmin = new ProfileListFromCustomSettings__c();
		pmAdmin.Name='PMADMINPMProfiles';
		pmAdmin.FS_Profile_Name__c='FS Admin PM_P,FS PM_P';
		   plist.add(pmAdmin);
        insert plist;
        return plist;
    }
    
     /*** @desc creates executionPlan records 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $numberOfexecutionPlan- number of executionPlanrecords to be created.
		* @return List<FS_Execution_Plan__c>
		*/
    	public static List<FS_Execution_Plan__c> createTestExecutionPlan(final Id headQuarterId,final Boolean isInsert, final Integer numberOfexecutionPlan,final Id recordtypeId) {
        
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
        FS_Execution_Plan__c newExecutionPlan=null;
        for(Integer i=0;i<numberOfexecutionPlan;i++){
            newExecutionPlan =new FS_Execution_Plan__c ();
            newExecutionPlan.Name='Test Execution Plan '+i ;
            newExecutionPlan.FS_Headquarters__c=headQuarterId;
            newExecutionPlan.FS_Platform_Type__c='7000;8000;9000';
            if(recordtypeId!=FSConstants.NULLVALUE){
            	newExecutionPlan.RecordtypeId=recordtypeId;
            }
            executionPlanList.add(newExecutionPlan);
        }
        if(isInsert) {
            insert executionPlanList;
        }     
        return executionPlanList;
    }
    
     /*** @desc creates InstallationPlan records 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $numberOfInstallationPlan- number of numberOfInstallationPlan records to be created.
		* @return List<FS_Installation__c >
		*/
    public static List<FS_Installation__c > createTestInstallationPlan(final Id executionPlanId,final Id outletId,final Boolean isInsert,final Integer numberOfInstallationPlan,final Id recordtypeId) {
        
        final List<FS_Installation__c> installationPlanList=new List<FS_Installation__c>();
        FS_Installation__c installationPlan=null;
        for(Integer i=0;i<numberOfInstallationPlan;i++){            
            installationPlan=new FS_Installation__c();
            installationPlan.FS_Outlet__c =outletId;
            installationPlan.Type_of_Dispenser_Platform__c='7000;8000;9000';
            installationPlan.FS_Type_of_Dispenser_Platform__c='7000';
            installationPlan.FS_Execution_Plan__c =executionPlanId; 
            if(recordtypeId!=FSConstants.NULLVALUE){
            	installationPlan.RecordtypeId=recordtypeId;
            }
            installationPlanList.add(installationPlan);
        }
        if(isInsert) {
            insert installationPlanList;
        }     
        return installationPlanList;
    }    
    
     /*** @desc creates InitialOrder records 
		* @param Boolean $isInsert- true inserts a record
		* @param Id $installationId- Installation Id
		* @param Id $outletId- outlet Id
		* @param Integer $numberOfInitialOrder- number of numberOfInitialOrder records to be created.
		* @return List<FS_Initial_Order__c>
		*/
    public static List<FS_Initial_Order__c> createTestInitialOrder(final Id outletId,final Id installationId,final Boolean isInsert,final Integer numberOfInitialOrder,final Id recordtypeId) {
        
        final List<FS_Initial_Order__c> initialOrderList=new List<FS_Initial_Order__c>();
         FS_Initial_Order__c initialOrder=null;
        for(Integer i=0;i<numberOfInitialOrder;i++){            
            initialOrder=new FS_Initial_Order__c ();
            initialOrder.FS_Outlet__c =outletId; 
            initialOrder.FS_Installation__c =installationId;
            if(recordtypeId!=FSConstants.NULLVALUE){
            	initialOrder.RecordtypeId=recordtypeId;
            }
            initialOrderList.add(initialOrder);
        }
        if(isInsert) {
            insert initialOrderList;
        }     
        return initialOrderList;
    }
    
     /*** @desc creates Outlet Dispensers records 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $numberOfOutletDispenser- number of OutletDispenser records to be created.
		* @return List<FS_Outlet_Dispenser__c>
		*/
    public static List<FS_Outlet_Dispenser__c> createTestOutletDispenser(final Id installationId,final Id outletId,final Id recordtypeId,final Boolean isInsert,final Integer numberOfOutletDispenser,final String serialNumberSuffixCharacter ) {
        
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        FS_Outlet_Dispenser__c outletDispenser=null;
        for(Integer i=0;i<numberOfOutletDispenser;i++){            
            outletDispenser=new FS_Outlet_Dispenser__c();
            outletDispenser.FS_Outlet__c=outletId; 
            outletDispenser.Installation__c=installationId;
            outletDispenser.FS_IsActive__c=true;
            if(recordtypeId!=FSConstants.NULLVALUE){
            	outletDispenser.RecordtypeId=recordtypeId;
            }
            String serialNumberText=FSConstants.BLANKVALUE;
            final String randomNumbers=String.valueOf(Math.abs(Crypto.getRandomInteger()));
            if(randomNumbers.length()<VALUESEVEN){
                //append zeroes based on iteration
                serialNumberText=FSUtil.leftPadWithZeroes(randomNumbers,6);
            }
            else{
                serialNumberText=randomNumbers.substring(0,7);
            }
            outletDispenser.FS_Serial_Number2__c='ZPL' + serialNumberText;
            if(i==VALUETEN){
                outletDispenser.FS_Serial_Number2__c='IPL1234567'; 
            }          
            outletDispenserList.add(outletDispenser);
        }
        if(isInsert) {
            insert outletDispenserList;
        }     
        return outletDispenserList;
    }
    
     /*** @desc creates SP AlignedZip records 
		* @param Boolean $isInsert- true inserts a record
		* @param Id  $serviceProviderId- Service Provider Account Id
		* @param String $zipCode- Zip Code
		* @param Id $recordtypeId- recordtypeId of SP AlignedZip 
		* @param Integer $numberOfSPAlignedZips - number of SP AlignedZip records to be created.
		* @return List<FS_SP_Aligned_Zip__c>
		*/
    public static List<FS_SP_Aligned_Zip__c> createTestSPAlignedZip(final Id serviceProviderId,final String zipCode,final String platform,final Boolean isInsert,final Integer numberOfSPAlignedZips) {
        
        final List<FS_SP_Aligned_Zip__c> spAlignedZipList=new List<FS_SP_Aligned_Zip__c>();
        FS_SP_Aligned_Zip__c spAlignedZip=null;
        for(Integer i=0;i<numberOfSPAlignedZips;i++){            
            spAlignedZip=new FS_SP_Aligned_Zip__c();            
            spAlignedZip.FS_Zip_Code__c=FSUtil.leftPadWithZeroes(zipCode,5);
            if(string.isNotBlank(platform)){
            	spAlignedZip.FS_Platform_Type__c=platform;
            }
            spAlignedZip.FS_Service_Provider__c=serviceProviderId;            
            spAlignedZipList.add(spAlignedZip);
        }
        if(isInsert) {
            insert spAlignedZipList;
        }     
        return spAlignedZipList;
    }
    
 		/*** @desc creates FlavorChangeHeader records 
		* @param Id $entityId- HQ or Outlet Id
		* @param Id $installationId- Installation Id
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $numberOfFlavorChangeHeader- number of FlavorChangeHeader to be created.
		* @return List<FS_Flavor_Change_Head__c >
		*/
    public static List<FS_Flavor_Change_Head__c> createTestFlavorChangeHeader(final Id entityId,final Id installationId,final Boolean isInsert,final Integer numberOfFlavorChangeHeader,final Id recordtypeId) {
        
        final List<FS_Flavor_Change_Head__c> flavorChangeHeaderList=new List<FS_Flavor_Change_Head__c>();
        FS_Flavor_Change_Head__c newFlavorChangeHeader=null;
        for(Integer i=0;i<numberOfFlavorChangeHeader;i++){
            newFlavorChangeHeader =new FS_Flavor_Change_Head__c();
            newFlavorChangeHeader.FS_HQ_Chain__c=entityId ;
            newFlavorChangeHeader.FS_installation__c=installationId;
            if(recordtypeId!=FSConstants.NULLVALUE){
            	newFlavorChangeHeader.RecordtypeId=recordtypeId;
            }
            newFlavorChangeHeader.FS_FC_Type__c='Workflow Flavor Change';
            flavorChangeHeaderList.add(newFlavorChangeHeader);
        }
        if(isInsert) {
            insert flavorChangeHeaderList;
        }     
        return flavorChangeHeaderList;
    }
    
    
     /*** @desc creates FlavorChangeLine records 
		* @param Id $entityId- HQ or Outlet Id
		* @param Id $installationId- Installation Id
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $numberOfFlavorChangeLine- number of FlavorChangeLine to be created.
		* @return List<FS_Flavor_Change_New__c>
		*/
    public static List<FS_Flavor_Change_New__c> createTestFlavorChangeLine(final Id flavorChangeHeaderId,final Id installationId,
                                                                           final Id outletId,final Id outletDispenserId,
                                                                           final Boolean isInsert, final Integer numberOfFlavorChangeLine,
                                                                           final Id recordtypeId) {
                                                                               
    	final List<FS_Flavor_Change_New__c> flavorChangeLineList=new List<FS_Flavor_Change_New__c>();
        FS_Flavor_Change_New__c newFlavorChangeLine=null;                                                                       
        for(Integer i=0;i<numberOfFlavorChangeLine;i++){
        	newFlavorChangeLine =new FS_Flavor_Change_New__c();
            newFlavorChangeLine.FS_FC_Head__c=flavorChangeHeaderId;
            newFlavorChangeLine.FS_Installation__c=installationId;
            newFlavorChangeLine.FS_Outlet__c=outletId;
            newFlavorChangeLine.FS_Outlet_Dispenser__c=outletDispenserId;
            if(recordtypeId!=FSConstants.NULLVALUE){
            	newFlavorChangeLine.RecordtypeId=recordtypeId;
            }
            flavorChangeLineList.add(newFlavorChangeLine);
         }
         if(isInsert) {
         	insert flavorChangeLineList;
         }     
    	return flavorChangeLineList;
  	}
    
     /*** @desc creates Task records 
		* @param Id $whatId- record Id associated with task
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $numberOfTaskRecords- number of Task to be created.
		* @return List<Task>
		*/
    public static List<Task> createTestTasks(final Id whatId,final Boolean isInsert,final Integer numberOfTaskRecords) {
        
        final List<Task> taskList=new List<Task>();
         Task newTask=null;
        for(Integer i=0;i<numberOfTaskRecords;i++){
            newTask=new Task();
            newTask.subject='task created';
            newTask.WhatId=whatId;
            newTask.Status='In Progress';
            newTask.IsReminderSet=false;
            taskList.add(newTask);
        }
        if(isInsert) {
            insert taskList;
        }     
        return taskList;
    }
    
    /** @desc creates cartridge records from static resource file
	* @return List<FS_Cartridge__c >
	*/
    public static List<FS_Cartridge__c >  createTestCartridge(){
        return (List<FS_Cartridge__c >) Test.loadData(FS_Cartridge__c.sObjectType,'TestDataCartridgeRecords');
    }
    
    
    /** @desc creates Brandset records from static resource file
	* @return List<FS_Brandset__c>
	*/
    public static List<FS_Brandset__c>  createTestBrandset(){
        return (List<FS_Brandset__c>) Test.loadData(FS_Brandset__c.sObjectType,'TestDataBrandsetRecords');
    }
    
    
     /*** @desc creates AssociationBrandset records
		* @param Boolean $isInsert- true inserts a record
		* @param List<FS_Brandset__c> $brandSetList- list of Brand set records
		* @param String $parentObjectName- object API name
		* @param Integer $numberOfrecords- number of AssociationBrandset records to be created.
		* @return List<FS_Association_Brandset__c>
		*/
    public static List<FS_Association_Brandset__c>  createTestAssociationBrandset(final Boolean isInsert,final List<FS_Brandset__c> brandSetList,final String parentObjectName,final Id parentRecordId,final Integer numberOfrecords){
        final List<FS_Association_Brandset__c> associationBrandsetList=new List<FS_Association_Brandset__c>();
        final id ABHQTYPE=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_HQ).getRecordTypeId();
        final id ABIPTYPE=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_IP).getRecordTypeId();
        final id ABODTYPE=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_OD).getRecordTypeId();
        FS_Association_Brandset__c associationRecord=null;

        for(Integer i=0;i<numberOfrecords;i++){
            associationRecord=new FS_Association_Brandset__c();
            associationRecord.FS_Brandset__c=brandSetList.get(i).Id;            
            if(parentObjectName==accountSobject) {
                associationRecord.FS_Headquarters__c=parentRecordId;
                associationRecord.RecordTypeId=ABHQTYPE;
            }
            if(parentObjectName==FSConstants.INSTALLATIONOBJECTNAME) {
                associationRecord.FS_Installation__c=parentRecordId;
                associationRecord.RecordTypeId=ABIPTYPE;
            }
            if(parentObjectName==FSConstants.ODOBJECTNAME) {
                associationRecord.FS_Outlet_Dispenser__c=parentRecordId;
                associationRecord.RecordTypeId=ABODTYPE;
            }            
            associationBrandsetList.add(associationRecord);
        }
        
        if(isInsert) {
            insert associationBrandsetList ;
        }
        return associationBrandsetList ;
    }
    
    /** @desc creates OutboundServiceDetails__c records from static resource file
	* @return List<OutboundServiceDetails__c>
	*/
    /*  //Removed as part of FOT
    public static List<OutboundServiceDetails__c>  createTesOutboundServiceDetails(){
        
        return (List<OutboundServiceDetails__c>) Test.loadData(OutboundServiceDetails__c.sObjectType,'TestDataOutboundServiceDetail');
    }*/
    
    /** @desc creates Disable_Trigger__c records from static resource file
	* @return List<Disable_Trigger__c>
	*/
    public static List<Disable_Trigger__c>  createTestDisableTriggerSetting(){
        return (List<Disable_Trigger__c>) Test.loadData(Disable_Trigger__c.sObjectType,'TestDisableTriggerSetting');
    }
    
    /** @desc creates FS_FlavorChange_ErrorMessages__c records from static resource file
	* @return List<FS_FlavorChange_ErrorMessages__c>
	*/
    public static List<FS_FlavorChange_ErrorMessages__c>  createTestFlavorChangeErrorMessages(){
        return (List<FS_FlavorChange_ErrorMessages__c>) Test.loadData(FS_FlavorChange_ErrorMessages__c.sObjectType,'TestFlavorChangeErrormessages');
    }
    
    
     /*** @desc returns Profile details for a profile  
		* @param String $profileName- name of the profile
		* @return Profile 
		*/
    public static Profile getProfileId(final String profileName){
        return [select id from profile where name=:profileName];
    } 
    
    
     /*** @desc create an User of a particular profile  
		* @param Id $profileId- salesforce Id of the profile
		* @return User 
		*/
    public static User createUser(final Id profileId){
        final User user = new User();
        user.FirstName = 'test';
        user.LastName ='user';
        user.Email = 'test-'+profileId+'@testdomain.com';
        user.Username = 'test-'+profileId+'@testdomain.comtestuser';
        user.ProfileId = profileId;
        user.Alias = 'test';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        return user;
    }
    
    /** @desc create a csv file for post install attributes functionality
	* @return Blob
	*/
    public static Blob createValidCSVBlobForPostInstallAttributes(final List<FS_Outlet_Dispenser__c> dispenserRecords){
        
        final Date todaysDate=Date.today();        
        final Date advanceDate=todaysDate.addDays(2);
        final String advanceDateString = advanceDate.format();        
        
        dispenserStatus='Pre-Enroll';
        pickValYes='Yes';
        pickValShow='Show';
        pickValShareCoke='Share a Coke';
        brandsetName8k9k='Brandset A - Pepper';
        brandsetName7k='Brandset 1 - Pepper/Hi-C/Pade';
        String brandsetName=FSConstants.BLANKVALUE;
        platform7k='7000';
        String csvRows=FSConstants.BLANKVALUE;
        csvHeader= 'JDE Equipment Type,Serial Number/Asset Tag,Active (A) / Inactive (I),Dispenser Type,Installation,Status,Enable Consumer Engagement.,CE Enabled Effective Date,Favorite Mix.,Favorite Mix Effective Date,Limited Time Offer.,Limited Time Offer Effective Date,Promotion Enabled.,Promo Enabled Effective Date,7000 Series Water Button.,7000 Series Hide Water Effective Date,8000/9000 Series Water button.,Hide Water Effective Date,Dasani.,Hide Dasani Effective Date,Valid Fill.,Valid Fill Settings Effective Date,Brandset.,Brandset Effective Date\n';
        
        Integer counter=0; 
        
        for(FS_Outlet_Dispenser__c dispenser : dispenserRecords){            
            if(dispenser.FS_Equip_Type__c.contains(platform7k)){
                brandsetName=brandsetName7k;
            }
            else{
                brandsetName=brandsetName8k9k;
            }            
            if(Math.mod(counter, 2)==VALUEZERO){ //Valid Records
                csvRows+=dispenser.FS_Equip_Type__c+FSConstants.COMMA+ dispenser.FS_Serial_Number2__c+FSConstants.COMMA+dispenser.FS_IsActive__c+FSConstants.COMMA+dispenser.FS_Dispenser_Type2__c+FSConstants.COMMA+dispenser.Installation__r.Name+FSConstants.COMMA+ dispenserStatus+ FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValShareCoke+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValShow+FSConstants.COMMA+advanceDateString+',,,'+pickValShow+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+brandsetName+FSConstants.COMMA+FSConstants.NEWLINE;
            }
            else if(Math.mod(counter,5)==VALUEZERO){ //Database errors records
                csvRows+=dispenser.FS_Equip_Type__c+FSConstants.COMMA+ dispenser.FS_Serial_Number2__c+FSConstants.COMMA+dispenser.FS_IsActive__c+FSConstants.COMMA+dispenser.FS_Dispenser_Type2__c+FSConstants.COMMA+dispenser.Installation__r.Name+FSConstants.COMMA+dispenserStatus + FSConstants.COMMA+pickValYes+',,'+pickValYes+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValShareCoke+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValShow+FSConstants.COMMA+advanceDateString+',,,'+pickValShow+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString+FSConstants.COMMA+brandsetName+FSConstants.COMMA+advanceDateString+FSConstants.NEWLINE;
            }
            else{  //custom date validation records
                csvRows+=dispenser.FS_Equip_Type__c+FSConstants.COMMA+ dispenser.FS_Serial_Number2__c+FSConstants.COMMA+dispenser.FS_IsActive__c+FSConstants.COMMA+dispenser.FS_Dispenser_Type2__c+FSConstants.COMMA+dispenser.Installation__r.Name+FSConstants.COMMA+dispenserStatus + FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString +FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString +FSConstants.COMMA+pickValShareCoke+FSConstants.COMMA+advanceDateString +FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString +FSConstants.COMMA+pickValShow+FSConstants.COMMA+advanceDateString +FSConstants.COMMA+pickValShow+FSConstants.COMMA+advanceDateString +FSConstants.COMMA+pickValShow+FSConstants.COMMA+advanceDateString +FSConstants.COMMA+pickValYes+FSConstants.COMMA+advanceDateString +FSConstants.COMMA+brandsetName+FSConstants.COMMA+advanceDateString +FSConstants.NEWLINE;
            }
            counter++;
        }
        final String finalFile=csvHeader+csvRows;        
        return Blob.valueOf(finalFile);
    }
    
    /** @desc create a Failure csv file for post install attributes functionality
	* @return Blob
	*/
    public static Blob createFailureCSVBlob(final List<FS_Outlet_Dispenser__c> dispenserRecords){
        
        String csvRows=FSConstants.BLANKVALUE;
        csvHeader= 'Id,SerialNumber,Outlet ACN,ErrorMessage,FieldsAffected\n';
        Integer counter=0; 
        
        for(FS_Outlet_Dispenser__c dispenser : dispenserRecords){            
            if(Math.mod(counter,5)==0 || Math.mod(counter, 2)!=0){ //Database errors records //custom date validation records
                csvRows+=dispenser.Id+FSConstants.COMMA+ dispenser.FS_Serial_Number2__c+FSConstants.COMMA+dispenser.FS_ACN_NBR__c+',,\n';
            }
            counter++;
        }        
        final String finalFile=csvHeader+csvRows;
        return Blob.valueOf(finalFile);
    }
    
    /** @desc create a Success csv file for post install attributes functionality
	* @return Blob
	*/
    public static Blob createSuccessCSVBlob(final List<FS_Outlet_Dispenser__c> dispenserRecords){
        
        String csvRows=FSConstants.BLANKVALUE;
        csvHeader= 'Id,SerialNumber,Outlet ACN\n';
        Integer counter=0; 
        
        for(FS_Outlet_Dispenser__c dispenser : dispenserRecords){            
            if(Math.mod(counter, 2)==VALUEZERO){ //Valid records
                csvRows+=dispenser.Id+FSConstants.COMMA+ dispenser.FS_Serial_Number2__c+FSConstants.COMMA+dispenser.FS_ACN_NBR__c+FSConstants.NEWLINE;
            }
            counter++;
        }        
        final String finalFile=csvHeader+csvRows;
        return Blob.valueOf(finalFile);
    }
    
    
    /** @desc this method creates 1 chain,1 HQ, 1 Outlet,1 Execution Pan(Execution Plan),
		* 4 Installation('7000 Series','8000 & 9000 Series','8000 Series','9000 Series')
	* @return void 
	*/
    public static void createCommonTestRecords(){
        //Create Single HeadQuarter
        final List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                                     FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        
        //Create Single Outlet
        final List<Account> outletCustomerList=new List<Account>();
        for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'))){
            acc.FS_Headquarters__c=headQuarterCustomerList.get(0).Id;
            outletCustomerList.add(acc);
        }
        insert outletCustomerList;
        
        //Create Execution Plan
        
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
        //Create One executionPlan records for each record type
        //FET 5.0 regular Installation default record type
        final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,FSConstants.EXECUTIONPLAN);                    
        final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(headQuarterCustomerList.get(0).Id,false,1,epRecordTypeId);
        executionPlanList.addAll(epList);  
        insert executionPlanList;       
        //Create Installation         
        final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >();         
        //Create Installation for each Execution Plan according to recordtype       
        
        final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,FSConstants.NEWINSTALLATION); 
        final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
        installationPlanList.addAll(installList);        
        insert installationPlanList;
        //FET 5.0 regular Installation default record type
    }
    
    /** @desc this method creates 1 chain,1 HQ, 1 Outlet,1 Execution Pan(Execution Plan),
		* 4 Installation('7000 Series','8000 & 9000 Series','8000 Series','9000 Series')
	* @return void 
	*/
    public static void createCommonTestInstallationRecords(){
        final List<Account> insertAccounts = new List<Account>();
        
        //Create Single HeadQuarter
        final List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(false,1,
                                                                                     FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        insertAccounts.add(headQuarterCustomerList.get(0));
        
        //Create Single Outlet
        final List<Account> outletCustomerList = FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        outletCustomerList.get(0).FS_Headquarters__c=headQuarterCustomerList.get(0).Id;
        insertAccounts.add(outletCustomerList.get(0));

		insert insertAccounts;
        
       //Create Execution Plan
        
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
        //Create One executionPlan records for each record type
        //FET 5.0 regular Installation default record type
        final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,FSConstants.EXECUTIONPLAN);                    
        final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(headQuarterCustomerList.get(0).Id,false,1,epRecordTypeId);
        executionPlanList.addAll(epList);  
        insert executionPlanList;       
        //Create Installation         
        final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >();         
        //Create Installation for each Execution Plan according to recordtype       
        
        final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,FSConstants.NEWINSTALLATION); 
        final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
        installationPlanList.addAll(installList);        
        insert installationPlanList;
        //FET 5.0 regular Installation default record type  
    }
    
    /** @desc creates Air Watch Data from static resource file
	* @return List<FS_FET_Airwatch_Data_Mapping__c>
	*/
    public static List<FS_FET_Airwatch_Data_Mapping__c> createTestAirWatchData(){
        return (List<FS_FET_Airwatch_Data_Mapping__c>) Test.loadData(FS_FET_Airwatch_Data_Mapping__c.sObjectType,'TestDataforAirWatch');
    }
    
    /** @desc creates Cartridge Brandset data 
	* @return List<FS_Brandsets_Cartridges__c>
	*/
    public static List<FS_Brandsets_Cartridges__c> createTestCartridgeBrandset(){
        
        final List<FS_Brandset__c> brandsetRecordList= FSTestFactory.createTestBrandset();
        final List<FS_Cartridge__c> cartridgeRecordList= FSTestFactory.createTestCartridge(); 
        final List<FS_Brandsets_Cartridges__c> brandsetCartRecordList = new List<FS_Brandsets_Cartridges__c>();
        
        final Set<String> platformValues=new Set<String>();
        for(FS_Brandset__c brandset:brandsetRecordList){
            if(brandset.FS_Platform__c!=FSConstants.NULLVALUE){
                platformValues.add(brandset.FS_Platform__c);
            }
        }  
        
        final Map<String,List<FS_Cartridge__c>> cartridgeBasedOnPlatformMap = new Map<String,List<FS_Cartridge__c>>();
        for(FS_Cartridge__c cartridge:cartridgeRecordList){
            if(cartridgeBasedOnPlatformMap.containsKey(cartridge.FS_Platform__c)){
                cartridgeBasedOnPlatformMap.get(cartridge.FS_Platform__c).add(cartridge);
            }
            else{
                cartridgeBasedOnPlatformMap.put(cartridge.FS_Platform__c,new list<FS_Cartridge__c>());
            }                               
        }
        
        for(FS_Brandset__c brandset : brandsetRecordList){
            if(cartridgeBasedOnPlatformMap.containsKey(brandset.FS_Platform__c)){
                final FS_Brandsets_Cartridges__c brandsetCartRecords= new FS_Brandsets_Cartridges__c();
                brandsetCartRecords.FS_Brandset__c=brandset.id;
                brandsetCartRecords.FS_Cartridge__c=cartridgeBasedOnPlatformMap.get(brandset.FS_Platform__c).get(0).Id;
                brandsetCartRecordList.add(brandsetCartRecords);
            }
        }                                
        insert brandsetCartRecordList;
        return brandsetCartRecordList;
    }
    
    /** @desc create a csv file for flavor change workbook upload attributes functionality
	* @return Blob
	*/
    public static Blob createValidCSVBlobForFlavorChangeUpload(final List<FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper> detailWrapperList){
        
        String csvRows=FSConstants.BLANKVALUE;
        csvHeader= 'outlet ACN (blended in case of relocations),dispenser platform type,serial number,Current Brandset,future brandset,effective date,Future water show hide,future effective date water,Future Dasani show hide,future effective date Dasani,Pungent Change Indicator,Customer pay / account pay,Requested Date,Who will handle the IO for this FC,SP needs to go out,Date product is available at DC,NDO approval checkbox,CDM Setup complete,Estimated Flavor Change Date,Customer Support Notes,POM actions complete,Order Processed,AC/PC,Project ID,Project Description,PM,COM,Scheduled Date,Order Method,Delivery Method\n';
        Integer counter=0;
        
        for(FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper detailList : detailWrapperList){
            if(Math.mod(counter, 2)==VALUEZERO){ //Valid Records                
                csvRows+=detailList.outletACN+FSConstants.COMMA+detailList.platform+FSConstants.COMMA+detailList.serialNumber+FSConstants.COMMA+detailList.currentbrandset+FSConstants.COMMA+detailList.newBrandset+FSConstants.COMMA+detailList.brandsetEffectiveDate+FSConstants.COMMA+detailList.waterHideData+FSConstants.COMMA+detailList.waterHideEffectvieDate+FSConstants.COMMA+detailList.dasaniData+FSConstants.COMMA+detailList.dasaniDataEffectvieDate+FSConstants.COMMA+detailList.pungentChangeIndicator+FSConstants.COMMA+detailList.customerPayorAccountPay+FSConstants.COMMA+detailList.requestedDate+FSConstants.COMMA+detailList.productOrderHandeledBy+FSConstants.COMMA+detailList.spNeedToGoOut+FSConstants.COMMA+detailList.dateProductidAvaliableInDC+FSConstants.COMMA+detailList.NDOapprovalCheck+FSConstants.COMMA+detailList.CDMSetupComplete+FSConstants.COMMA+detailList.estimatedFlavorChangeDate+FSConstants.COMMA+detailList.customerServiceNotes+FSConstants.COMMA+detailList.POMActionsComplete+FSConstants.COMMA+detailList.orderProcessed+FSConstants.COMMA+FSConstants.COMMA+detailList.aCUser+FSConstants.COMMA+detailList.projectID+FSConstants.COMMA+detailList.projectDescription+FSConstants.COMMA+detailList.pmUser+FSConstants.COMMA+detailList.comUser+FSConstants.COMMA+detailList.scheduledDate+FSConstants.COMMA+detailList.orderMethod+FSConstants.COMMA+detailList.deliveryMethod+FSConstants.NEWLINE;                  
            }        
            counter++;
        }        
        final String finalFile=csvHeader+csvRows;       
        return Blob.valueOf(finalFile);
    }
    
     /*** @desc creates cif records 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $recordCount- number of cif records to be created.
		* @param Id cifHead- Id of the cifHead record for which cif to be created
		* @param List<Account> outletLst - List of outlets for assigning the cif to be created
		* @return List<FS_CIF__c>
		*/
    public static List<FS_CIF__c> createTestCif(final List<Account> outletLst,final Id cifHead,final Integer recordCount,final Boolean isInsert){
        
        final List<FS_CIF__c> cifLst=new List<FS_CIF__c>();
        FS_CIF__c cif=null;
        for(Integer i=0;i<recordCount;i++){
            cif = new FS_CIF__c();
            cif.FS_Account__c =outletLst[i].id; 
            cif.CIF_Head__c = cifHead;
            cifLst.add(cif);
        }
        if(isInsert){
            Insert cifLst;
        }        
        return cifLst;        
    }
    
     /*** @desc creates Techinician Instruction records for Installation Plan 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $recordCount- number of Techinician Instruction records to be created.
		* @param Id installationId- Id of the Installation record for which Techinician Instruction to be created
		* @param Id recordtypeId - record type Id of Techinician Instruction
		* @return List<FS_IP_Technician_Instructions__c>
		*/
    
    public static List<FS_IP_Technician_Instructions__c> createTestIPTechnicianInstruction(final Id installationId,final Id recordtypeId,final Integer recordCount,final Boolean isInsert) {
        final List<FS_IP_Technician_Instructions__c> installationPlanTechInstructionLst = new List<FS_IP_Technician_Instructions__c>();
        FS_IP_Technician_Instructions__c installationPlanTechInstruction=null;
        for(Integer i=0;i<recordCount;i++){
            installationPlanTechInstruction = new FS_IP_Technician_Instructions__c();
            installationPlanTechInstruction.FS_Instalation_Process__c = installationId;
             if(recordtypeId!=FSConstants.NULLVALUE){
            	installationPlanTechInstruction.RecordtypeId=recordtypeId;
             }
            installationPlanTechInstructionLst.add(installationPlanTechInstruction);
        }
        if(isInsert){
            insert installationPlanTechInstructionLst;  
        }
        return installationPlanTechInstructionLst;
    }
    
     /*** @desc creates Techinician Instruction records for Execution Plan 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $recordCount- number of Techinician Instruction records to be created.
		* @param Id execPlanId- Id of the Execution Plan record for which Techinician Instruction to be created
		* @param Id recordtypeId - record type Id of Techinician Instruction
		* @return List<FS_EP_Technician_Instructions__c>
		*/
    
    public static List<FS_EP_Technician_Instructions__c> createTestEPTechnicianInstruction(final Id execPlanId,final Id recordtypeId,final Integer recordCount,final Boolean isInsert){
        final List<FS_EP_Technician_Instructions__c> executionPlanTechInstructionLst = new List<FS_EP_Technician_Instructions__c>();
        FS_EP_Technician_Instructions__c executionPlanTechInstruction=null;
        for(Integer i=0;i<recordCount;i++){
            executionPlanTechInstruction = new FS_EP_Technician_Instructions__c();
            executionPlanTechInstruction.Execution_Plan__c = execPlanId;
             if(recordtypeId!=FSConstants.NULLVALUE){	
            	executionPlanTechInstruction.RecordtypeId=recordtypeId;
             }
            executionPlanTechInstructionLst.add(executionPlanTechInstruction);
        }
        if(isInsert){
            insert executionPlanTechInstructionLst;  
        }
        return executionPlanTechInstructionLst;
    }
    
     /*** @desc creates Equipment Package records for Installation Plan 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $recordCount- number of Equipment Package records to be created.
		* @param Id installationId- Id of the Installation record for which Equipment Package to be created
		* @param Id recordtypeId - record type Id of Equipment Package
		* @return List<FS_IP_Equipment_Package__c>
		*/
    
    public static List<FS_IP_Equipment_Package__c> createTestIPEquipmentPackage(final Id installationId,final Id recordtypeId,final Integer recordCount,final Boolean isInsert){
        final List<FS_IP_Equipment_Package__c> installationPlanEquipPackageLst = new List<FS_IP_Equipment_Package__c>();
        FS_IP_Equipment_Package__c installationPlanEquipPackage=null;
        for(Integer i=0;i<recordCount;i++){
            installationPlanEquipPackage = new FS_IP_Equipment_Package__c();
            installationPlanEquipPackage.FS_Installation__c = installationId;
             if(recordtypeId!=FSConstants.NULLVALUE){
            	installationPlanEquipPackage.RecordtypeId=recordtypeId;
             }
            installationPlanEquipPackageLst.add(installationPlanEquipPackage);
        }
        if(isInsert){
            insert installationPlanEquipPackageLst;  
        }
        return installationPlanEquipPackageLst;
    }
    
     /*** @desc creates Equipment Package records for Execution Plan 
		* @param Boolean $isInsert- true inserts a record
		* @param Integer $recordCount- number of Equipment Package records to be created.
		* @param Id execPlanId- Id of the Execution record for which Equipment Package to be created
		* @param Id recordtypeId - record type Id of Equipment Package
		* @return List<FS_EP_Equipment_Package__c>
		*/
    
    public static List<FS_EP_Equipment_Package__c> createTestEPEquipmentPackage(final Id execPlanId,final Id recordtypeId,final Integer recordCount,final Boolean isInsert){
        final List<FS_EP_Equipment_Package__c> executionPlanEquipPackageLst = new List<FS_EP_Equipment_Package__c>();
        FS_EP_Equipment_Package__c executionPlanEquipPackage=null;
        for(Integer i=0;i<recordCount;i++){
            executionPlanEquipPackage = new FS_EP_Equipment_Package__c();
            executionPlanEquipPackage.FS_Execution_Plan__c = execPlanId;
             if(recordtypeId!=FSConstants.NULLVALUE){
            	executionPlanEquipPackage.RecordtypeId=recordtypeId;
             }
            executionPlanEquipPackageLst.add(executionPlanEquipPackage);
        }
        if(isInsert){
            insert executionPlanEquipPackageLst;  
        }               
        return executionPlanEquipPackageLst;
    }
    
     /*** @desc creates Account records with different order and delivery method combinations
		* @param Id recordtypeId - record type Id of Equipment Package
		* @return List<FS_EP_Equipment_Package__c>
		*/
    public static List<Account> accListCreate(){
        final List<Account> accList=new List<Account>();
        final User sysAdminUser=FSTestUtil.createUser(null, 1,FSConstants.USER_POFILE_SYSADMIN, true);
        //manual order direct ship
        final Account manualDirectShip=FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        manualDirectShip.FS_Requested_Order_Method__c='Manual Order';
        manualDirectShip.FS_Requested_Delivery_Method__c=DIRECTSHIP;      
        //manualDirectShip.FS_Manual_Order_Approval_Status__c='Reject';
        accList.add(manualDirectShip);
        //bottler direct ship
        final Account bottlrDirect=FSTestUtil.createTestAccount('Test Headquarters1',FSConstants.RECORD_TYPE_HQ,false);
        bottlrDirect.FS_Requested_Order_Method__c='Bottler';
        bottlrDirect.FS_Requested_Delivery_Method__c=DIRECTSHIP;
        bottlrDirect.FS_Approved_Bottler_Order_Delivery__c=true;
        accList.add(bottlrDirect);
        //bottler direct ship
        final Account bottlrBottlr=FSTestUtil.createTestAccount('Test Headquarters2',FSConstants.RECORD_TYPE_HQ,false);
        bottlrBottlr.FS_Requested_Order_Method__c='Bottler';
        bottlrBottlr.FS_Requested_Delivery_Method__c='Bottler';
        bottlrBottlr.FS_Approved_Bottler_Order_Delivery__c=true;
        accList.add(bottlrBottlr);
        //Distributor Distributor
        final Account distDist=FSTestUtil.createTestAccount('Test Headquarters3',FSConstants.RECORD_TYPE_HQ,false);
        distDist.FS_Requested_Order_Method__c=DISTRIBUTOR;
        distDist.FS_Requested_Delivery_Method__c=DISTRIBUTOR;
        accList.add(distDist);
        //Cokesmart Distributor
        final Account cokeDist=FSTestUtil.createTestAccount('Test Headquarters4',FSConstants.RECORD_TYPE_HQ,false);
        cokeDist.FS_Requested_Order_Method__c='Cokesmart';
        cokeDist.FS_Requested_Delivery_Method__c=DISTRIBUTOR;
        accList.add(cokeDist);
        //VMS Distributor
        final Account vmsDist=FSTestUtil.createTestAccount('Test Headquarters5',FSConstants.RECORD_TYPE_HQ,false);
        vmsDist.FS_Requested_Order_Method__c='VMS';
        vmsDist.FS_Requested_Delivery_Method__c=DISTRIBUTOR;
        accList.add(vmsDist);
        //Cokesmart Direct Ship
        final Account cokeDirect=FSTestUtil.createTestAccount('Test Headquarters6',FSConstants.RECORD_TYPE_HQ,false);
        cokeDirect.FS_Requested_Order_Method__c='Cokesmart';
        cokeDirect.FS_Requested_Delivery_Method__c=DIRECTSHIP;
        accList.add(cokeDirect);
        
        //VMS Direct Ship
        final Account vmsDirect=FSTestUtil.createTestAccount('Test Headquarters7',FSConstants.RECORD_TYPE_HQ,false);
        vmsDirect.FS_Requested_Order_Method__c='VMS';
        vmsDirect.FS_Requested_Delivery_Method__c=DIRECTSHIP;
        accList.add(vmsDirect);
        system.runAs(sysAdminUser){
        	insert accList;
        }
        return accList;
    }      
}