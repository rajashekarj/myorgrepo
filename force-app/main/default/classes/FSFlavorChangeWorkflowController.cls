/*********************************************************************************************************
Name         : FSFlavorChangeWorkflowController
Created By   : Infosys Limited 
Created Date : 17-Feb-2017
Usage        : Custom Controller for FSFlavorChangeWorkflowPage/FSFlavorChangeWorkflowInputPage, 
which is used create Flavor Change Header/Line.

******************* ****************************************************************************************/
public with sharing class FSFlavorChangeWorkflowController {
    
    /******Constants**********************************/
    //private final static Integer numVal25=25;
    private final static Integer numVal20=20;
    private final static Integer numVal10=10;
    private final static Integer numVal5=5;
    private final static Integer numVal2=2;
    private final static String outletRecordType ='FS Outlet';  
   // private final static String outletRecordType1 ='FS Headquarters';    
   // private final static String outletRecordType2 ='FS Chain';
   // private final static String outletRecordType3 ='FS Flavor Change Installation';
    private final static String falvorChangeHQRecordType='FS Flavor Change Chain HQ';
    private final static String falvorChangeInstallRecordType='FS Flavor Change Installation'; 
    private final static String falvorChangeOutletRecordType='FS Flavor Change Outlet';          
    private final static String accountSobject='Account';
    private final static String installationSobject='FS_Installation__c';
    private final static String flavorChangeHeadSobject='FS_Flavor_Change_Head__c';
    private final static String flavorChangeSobject='FS_Flavor_Change_New__c';
    private final static String serviceOrderSobject='FS_Service_Order__c';
   	private final static String OutletDispenserSobject='FS_Outlet_Dispenser__c';
    private final static String appName='FET';
    private final static String className='FSFlavorChangeWorkflowController';
    private final static String flavorChangeType='Workflow Flavor Change';
    private final static Object nullConstant=NULL;
    public Integer invalidRows=0;
    public Integer blankRows=0;
    public Integer totalRows=0;
    public Integer validRows=0;
    public Integer incorrectRows=0;
    public List<AccountWrapper> outletSearchResults;
    @TestVisible
    private Map<Id,Account> selectedOutletsMap;
    @TestVisible
    private Map<Id,Account> selectedOutletsRemoveMap;
    private enum stringLiterals{Yes,No,Medium,NA} 
    
    //Enum has all the method names that perform DML
    private enum methodNamesDML{createRecordsRelatedToHQAndChain,createFlavorChangeForHQChain,
        createFlavorChangeHeader,createFlavorChange,createServiceOrder} 
    //Enum has all the method names which do SOQL
    private enum methodNamesSOQL{fetchOutletsSOQL,fetchOutletDispensers}
    
    private enum selectFillDownValues {BrandsetEffectiveDate,Dasani,DasaniEffectiveDate,
        WaterButton,WaterEffectiveDate,PungentIndicator,
        ServiceProvider,RequestedDate}
    
    private enum flavorChangeErrorMessageHeader {EarlyDateError,EffBrandsetRequired,NewBrandsetRequired,
        EffDasainiDateRequired,DasaniRequired,EffWaterButtonDateRequired,
        WaterButtonRequired,PungentChangeRequired,SpNeedsToGoOutRequired,ValueChangeRequired}
    
    
    
    /******Constants**********************************/
    
    public String sObjectType{get;set;}
    public Id parentRecordId{get;set;}
    
    public String searchCity{get;set;}
    public String searchName{get;set;}
    public String searchAcn{get;set;}
    public String searchState{get;set;}
    
    public List<AccountWrapper> selectedoutletRecords{get;set;}
    
    /****Pagination Variables Start****************************/
    
    //paginator reference for selected Outlet records
    public FSDynamicWrapperPaginator paginatorSelected {get;set;}
    
    //Collection variable(used for pagination) that holds selected Outlet search result
    public List<AccountWrapper> selectedOutletsList{get;set;}
    
    //paginator reference for available outlet records
    public FSDynamicWrapperPaginator paginatorAvailable {get;set;}
    
    //Collection variable (used for pagination) that holds available Outlet search result
    public List<AccountWrapper> availableOutletsList{get;set;}
    
    /****Pagination Variables End****************************/
    
    
    
    //Screen 2 variables
    public List<FS_Flavor_Change_New__c > newFlavorChangeData{get;set;} 
    
    public string selectedFillDown{get;set;}
    public Boolean toggleScreen{get;set;}
    public String accountRecordTypeName{get;set;}
    
    public FSFlavorChangeWorkflowController() {
        
        parentRecordId=ApexPages.currentPage().getParameters().get('parentRecordId');
        //Get Object API Name from Parent Record Id using describe calls
        Schema.SObjectType objType = parentRecordId.getSObjectType();
        sObjectType= objType.getDescribe().getName();
        
        selectedOutletsMap= new Map <Id,Account>();
        selectedOutletsRemoveMap= new Map <Id,Account>();
        selectedOutletRecords=new List<AccountWrapper>();
        
        newFlavorChangeData=new List<FS_Flavor_Change_New__c >();
        if(sObjectType==accountSobject) {
            Id acountRecordTypeId =ApexPages.currentPage().getParameters().get('accountRecordType');
            accountRecordTypeName =FSUtil.getObjectRecordTypeIdAndNAme(objType).get(acountRecordTypeId);
        }
        
        toggleScreen=false;
        
        initializePaginator();
    }
    
    public void initializePaginator(){
        this.paginatorAvailable = new FSDynamicWrapperPaginator(getOutletSearchResults());
        this.paginatorAvailable.pageNum =numVal20;
        updateAvailableData();
        
        this.paginatorSelected = new FSDynamicWrapperPaginator(selectedOutletRecords);
        this.paginatorSelected.pageNum =numVal20;
        updateSelectedData();
    }
    
    //Search Brand Set records Based on User Input
    public List<Account> fetchOutletsSOQL(){
        Id outletRecordTypeId=FSUtil.getObjectRecordTypeId(Account.SObjectType,outletRecordType);
        try{
        String searchquery='SELECT Id,Name,FS_ACN__c,Shippingcity,Shippingstate,Shippingstreet,Shippingcountry,Shippingpostalcode,FS_Final_Order_Method__c,FS_Final_Delivery_Method__c FROM Account WHERE RecordTypeId=:outletRecordTypeId '; 
        searchquery+='AND (Id=:parentRecordId OR FS_headquarters__c=:parentRecordId OR FS_Chain__c=:parentRecordId ) '; 
        
        if(String.isNotBlank(searchName)){
            searchName=searchName.trim();
            String escapedSearchName=String.escapeSingleQuotes(searchName);
            searchquery += ' AND Name LIKE \'%'+escapedSearchName+'%\' ';
        }
        if(String.isNotBlank(searchCity)){
            searchCity=searchCity.trim();
            searchquery += ' AND Shippingcity LIKE \'%'+searchCity+'%\'  ';
        }
        if(String.isNotBlank(searchState)){
            searchState=searchState.trim();
            searchquery += ' AND Shippingstate LIKE \'%'+searchState+'%\'  ';
        }
        
        if(String.isNotBlank(searchAcn)){
            searchAcn=searchAcn.trim();
            if(searchAcn.contains('\n')){
                String sAcn='';
                List<String> splitAcn=searchAcn.split('\n');   
                for(Integer i=0;i<splitAcn.size();i++){
                    if(String.isNotBlank(splitAcn[i]) && splitAcn[i].trim().length()< numVal10){
                        sAcn+='\''+ FSUtil.leftPadWithZeroes(splitAcn[i].trim().replace(' ', '0'),numVal10)+'\',' ;
                    }
                    else{
                        splitAcn[i].trim();
                        sAcn+='\''+splitAcn[i].trim().replace(' ', '0')+'\',' ;
                        
                    }
                }
                
                sAcn= sAcn.removeEnd(',');
              
                searchquery+=' AND FS_ACN__c in ('+sAcn+')' ;
            }
            else{
                String paddedsearchAcn=FSUtil.leftPadWithZeroes(searchAcn.trim().replace(' ', '0'),numVal10);
                system.debug('paddedsearchAcn ACN Value'+paddedsearchAcn);
                searchquery+='and FS_ACN__c LIKE: paddedsearchAcn';
            }
        }
        searchquery +=' ORDER BY FS_ACN__c ASC NULLS LAST LIMIT 2000 ';  
        List<SObject> searchList=Database.query(searchquery);
        
        return (List<Account>)searchList;
    }
        catch(QueryException ex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                                 ApexErrorLogger.addApexErrorLog(appName,className,methodNamesSOQL.fetchOutletsSOQL.name(),
                                                                 accountSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name());
                                 return null;
                                }
    }
    
    
    
    public PageReference search(){
        outletSearchResults.clear(); //clear previous selection
        getOutletSearchResults();
        return null;
    }
    
    public PageReference showBrandsets(){
        toggleScreen=true;
        newFlavorChangeData=new List<FS_Flavor_Change_New__c >();
        populateFlavorChangeInput();               
        return null; 
    }
    
    public PageReference backToPrevious(){
        toggleScreen=false;
        PageReference pageRef;
        
        if((sObjectType==accountSobject && accountRecordTypeName == outletRecordType ) || sObjectType==installationSobject){
            pageRef=new pagereference('/'+parentRecordId);
        } 
        
        return pageRef;
        
    }
    
    public void getSelectedOutlets(){
        if(outletSearchResults!= nullConstant){
            for(AccountWrapper wrpItem : outletSearchResults){
                if(wrpItem.selected){
                    selectedOutletsMap.put(wrpItem.outletRecord.Id,wrpItem.outletRecord); 
                }
                else{
                    selectedOutletsMap.remove(wrpItem.outletRecord.Id);
                }
            }
        }
    }
    
    
    public void getSelectedOutletsToRemove(){
        if(selectedOutletRecords!= nullConstant){
            for(AccountWrapper wrpItem : selectedOutletRecords){
                if(wrpItem.selected){
                    selectedOutletsRemoveMap.put(wrpItem.outletRecord.Id,wrpItem.outletRecord); 
                }
                else{
                    selectedOutletsRemoveMap.remove(wrpItem.outletRecord.Id);
                }
            }
        }
    }
    
    public List<AccountWrapper> getOutletSearchResults(){
        getSelectedOutlets();
        
        outletSearchResults=new List<AccountWrapper>();
        
        //Collection to hold records that are displayed in selected Outlets section
        Map<Id,Account>  displayedSelectedOutletMap=new Map<Id,Account>();
        
        for(AccountWrapper wrpItem : selectedoutletRecords){
            displayedSelectedOutletMap.put(wrpItem.outletRecord.Id,wrpItem.outletRecord);
        }
        
        for(Account accOutlet: fetchOutletsSOQL()){
            if(!selectedOutletsMap.containsKey(accOutlet.Id)){
                if(!displayedSelectedOutletMap.containsKey(accOutlet.Id)){
                    outletSearchResults.add(new AccountWrapper(accOutlet,false));
                }
            }
            else{
                if(!displayedSelectedOutletMap.containsKey(accOutlet.Id)){
                    outletSearchResults.add(new AccountWrapper(accOutlet,true));
                }
            }
        }
        
        paginatorAvailable = new FSDynamicWrapperPaginator(outletSearchResults);
        paginatorAvailable.pageNum =numVal20;
        updateAvailableData();
        
        return outletSearchResults;
        
    }
    
    public pageReference addOutlets(){
        getSelectedOutlets();
        
        selectedOutletRecords=new List<AccountWrapper>();
        Integer noOfOutletsSelected=selectedOutletsMap.size();
        if(noOfOutletsSelected > numVal20 ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot add more than 20 outlets to the list. Please use Flavor Change File Upload option'));
            Integer counter=0;
            
            for (Account accOutlet: selectedOutletsMap.values()){
                selectedOutletRecords.add(new AccountWrapper(accOutlet,false));
                counter++;
                if(counter== numVal20 ){
                    break;
                } 
            }
        }
        
        else{
            for (Account accOutlet: selectedOutletsMap.values()){
                selectedOutletRecords.add(new AccountWrapper(accOutlet,false));
            }
        }
        
        paginatorSelected = new FSDynamicWrapperPaginator(selectedOutletRecords);
        paginatorSelected.pageNum =numVal20;
        updateSelectedData();
        
        getOutletSearchResults();
        
        return null;
    }
    
    
    public pageReference removeOutlets(){
        getSelectedOutletsToRemove();
        
        List<AccountWrapper> addedOutlets=new List<AccountWrapper>();
        for(AccountWrapper wrpItem : selectedOutletRecords){
            if(!selectedOutletsRemoveMap.containsKey(wrpItem.outletRecord.Id)){
                addedOutlets.add(new AccountWrapper(wrpItem.outletRecord,false));
            }
            else{
                selectedOutletsMap.remove(wrpItem.outletRecord.Id);
            }
        }
        
        selectedOutletRecords.clear();
        selectedOutletRecords.addAll(addedOutlets);
        
        paginatorSelected = new FSDynamicWrapperPaginator(selectedOutletRecords);
        paginatorSelected.pageNum =numVal20;
        updateSelectedData();
        
        getOutletSearchResults();
        
        return null;
    }
    
    public Map<Id,FS_Outlet_Dispenser__c> fetchOutletDispensers(){
        //Query Formation
        try{
        String querySobject='SELECT Id,FS_outlet__c,FS_outlet__r.ShippingPostalCode FROM FS_Outlet_Dispenser__c WHERE FS_IsActive__c=TRUE and ';
        if(sObjectType==accountSobject){
            Set<Id> outletIds=new Set<Id>();
            for(AccountWrapper wrpItem :selectedoutletRecords){
                outletIds.add(wrpItem.outletRecord.Id);
            }
            querySobject+=' FS_outlet__c in:outletIds';
        }
        else{
            querySobject+=' Installation__c=:parentRecordId';
        }
        
        return new Map<Id,FS_Outlet_Dispenser__c>((List<FS_Outlet_Dispenser__c>)Database.query(querySobject));
    }
        catch(QueryException ex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                                 ApexErrorLogger.addApexErrorLog(appName,className,methodNamesSOQL.fetchOutletDispensers.name(),
                                                                 OutletDispenserSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name());
                                 return null;
                                }
    }
    
    public List<FS_Association_Brandset__c> fetchAssociationBrandsets(){
        
        //Collection that holds the dispenser records under selected Outlets
        Map<Id,FS_Outlet_Dispenser__c> mapOfDispenserRecords=fetchOutletDispensers();
        
        return [SELECT Id,FS_Platform__c,name,FS_Brandset__c,FS_Outlet_Dispenser__c,
                FS_Brandset__r.FS_Brandset_Number__c,FS_Outlet_Dispenser__r.FS_outlet__c,
                FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode 
                FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c in : mapOfDispenserRecords.keySet()  
                ORDER BY FS_Platform__c];
    }
    
    public pageReference populateFlavorChangeInput(){
        
        Map<String,FS_Flavor_Change_New__c> existingPlatformBrandsetFlavorChangeMap=new Map<String,FS_Flavor_Change_New__c>();
        for(FS_Association_Brandset__c  associationBrandset: fetchAssociationBrandsets()) {
            String key=associationBrandset.FS_Brandset__c+associationBrandset.FS_Platform__c; 
            
            FS_Flavor_Change_New__c flavorChangeNew=new FS_Flavor_Change_New__c();
            flavorChangeNew.FS_Platform__c=associationBrandset.FS_Platform__c;
            flavorChangeNew.FS_Current_Brandset__c=associationBrandset.FS_Brandset__c;
            flavorChangeNew.FS_Current_Brandset_Name_txt__c=associationBrandset.FS_Brandset__r.FS_Brandset_Number__c;   
            flavorChangeNew.FS_Outlet__c=associationBrandset.FS_Outlet_Dispenser__r.FS_Outlet__c;
            existingPlatformBrandsetFlavorChangeMap.put(key,flavorChangeNew);   
            
        }
        
        for(String platfromBrandset  :  existingPlatformBrandsetFlavorChangeMap.keyset()){
            newFlavorChangeData.add(existingPlatformBrandsetFlavorChangeMap.get(platfromBrandset));
        }
        return null;
    }
    
    public pageReference saveFlavorChange(){
        Boolean validation=false;
        
        PageReference pageRef;
        
        if(!newFlavorChangeData.isEmpty()) {validation = validateCurrentBrandAttributes();}
        
        
        if(validation){
            FS_Flavor_Change_Head__c flavorChangeHead;  //For Headquarter
            //Functionality for Outlet and Installation
            if((sObjectType==accountSobject && accountRecordTypeName == outletRecordType ) || sObjectType==installationSobject){
                FS_Flavor_Change_Head__c flavorChangeHeadOutlet =createRecordsRelatedToOutlet(flavorChangeHead);
                pageRef=new Pagereference('/'+flavorChangeHeadOutlet.Id);
            }
            else{//Functionality for Headquarter and Chain
                //Create a savepoint
                Savepoint savepoint1 = Database.setSavepoint();
                
                flavorChangeHead = createRecordsRelatedToHQAndChain();
                FS_Flavor_Change_Head__c flavorChangeHeadForOutlet=createRecordsRelatedToOutlet(flavorChangeHead);
                
                if(flavorChangeHeadForOutlet!= nullConstant){                 
                    pageRef=new Pagereference('/'+flavorChangeHead.Id);
                }
                else{
                    // Rollback to the previous null value
                    Database.rollback(savepoint1);
                }
            }
            
        }
        return pageRef;
        
    }
    
    public FS_Flavor_Change_Head__c createRecordsRelatedToHQAndChain(){
        
        FS_Flavor_Change_Head__c flavorChangeHead=new FS_Flavor_Change_Head__c();
        flavorChangeHead.FS_HQ_Chain__c=parentRecordId;
        flavorChangeHead.FS_FC_Type__c=flavorChangeType; 
        flavorChangeHead.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_Head__c.SObjectType,falvorChangeHQRecordType);
        
        try{
            insert flavorChangeHead;
            createFlavorChangeForHQChain(flavorChangeHead);
            
        }catch(DMLException ex){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                                ApexErrorLogger.addApexErrorLog(appName,className,methodNamesDML.createRecordsRelatedToHQAndChain.name(),
                                                                flavorChangeHeadSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name());}
        
        return flavorChangeHead;   
    }
    
    
    public List<FS_Flavor_Change_New__c> createFlavorChangeForHQChain(FS_Flavor_Change_Head__c  flavorChangeHead){
     
        
        //Refer user selected values
        Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap=setCurrentBrandsetValues();
        
        List<FS_Association_Brandset__c> associationBrandsetRecords=fetchAssociationBrandsets();
       
        //Creating Flavour Change lines at Headquarters or chain level
        List<FS_Flavor_Change_New__c> newFalvorChangeList=new List<FS_Flavor_Change_New__c>();
        Set<ID> outletLevel=new Set<ID>();
        List<Date> scheduledDate_WD = new List<Date> ();
        for(FS_Association_Brandset__c assosiatedBrandset:associationBrandsetRecords){
            if(newPlatformBrandsetFlavorChangeMap.containsKey(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c)){
                FS_Flavor_Change_New__c inputFlavorChange=newPlatformBrandsetFlavorChangeMap.get(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c);
                if(inputFlavorChange!=nullConstant){
                    FS_Flavor_Change_New__c newFlavorChange=new FS_Flavor_Change_New__c ();
                    newFlavorChange.FS_FC_Head__c=flavorChangeHead.Id;
                    
                    if(assosiatedBrandset.FS_Outlet_Dispenser__r.fs_outlet__c!= nullConstant){
                        newFlavorChange.FS_outlet__c=assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c;
                    }  
                     //OCR'17 FR_12 Rahim_Uddin
                    if(inputFlavorChange.FS_New_Brandset__c==FSConstants.NULLVALUE)
                    {
                        outletLevel.add(flavorChangeHead.Id);
                        newFlavorChange.FS_Only_Water_Dasani__c= true;
                    }
                    newFlavorChange.recordTypeID=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_New__c.SObjectType,falvorChangeHQRecordType);
                    newFlavorChange.FS_Outlet_Dispenser__c=assosiatedBrandset.FS_Outlet_Dispenser__c;
                    newFlavorChange.FS_Platform__c =assosiatedBrandset.FS_Platform__c;
                    newFlavorChange.FS_Current_Brandset__c =assosiatedBrandset.FS_Brandset__c;
                    newFlavorChange.FS_New_Brandset__c=inputFlavorChange.FS_New_Brandset__c;
                    newFlavorChange.FS_BS_Effective_Date__c=inputFlavorChange.FS_BS_Effective_Date__c;
                    //newFlavorChange.FS_Hide_Show_Dasani__c=inputFlavorChange.FS_Hide_Show_Dasani__c;
                    newFlavorChange.FS_Hide_Show_Water_Button__c=inputFlavorChange.FS_Hide_Show_Water_Button__c;
                    //newFlavorChange.FS_DA_Effective_Date__c=inputFlavorChange.FS_DA_Effective_Date__c;
                    newFlavorChange.FS_WA_Effective_Date__c=inputFlavorChange.FS_WA_Effective_Date__c;
                    newFlavorChange.FS_Flavor_Change_Requested_Date__c=inputFlavorChange.FS_Flavor_Change_Requested_Date__c;
                    newFlavorChange.FS_SP_go_out__c=inputFlavorChange.FS_SP_go_out__c;
                    newFlavorChange.FS_Pungent_Change_Indicator__c=inputFlavorChange.FS_Pungent_Change_Indicator__c;
                    newFalvorChangeList.add(newFlavorChange);
                }
            }
        }
        
        
        try{
            insert newFalvorChangeList;
            //OCR'17 FR_12 Rahim_Uddin:to update schedule date
            List<FS_Flavor_Change_Head__c> outletValues=[Select Id,Name,FS_SP_Scheduled_Date__c,(SELECT Id,FS_Only_Water_Dasani__c,FS_WA_Effective_Date__c,FS_DA_Effective_Date__c  FROM Flavor_Changes_New__r LIMIT 1) from FS_Flavor_Change_Head__c where ID in :outletLevel];
            List<FS_Flavor_Change_Head__c> outletTest = new List<FS_Flavor_Change_Head__c>();
            List<FS_Flavor_Change_New__c> lineItems = new List<FS_Flavor_Change_New__c>();
            If(!outletValues.isEmpty()) {
            for(FS_Flavor_Change_Head__c value:outletValues )
             {
                 lineItems=value.Flavor_Changes_New__r;
                 if(lineItems.size()>FSConstants.ZERO){
                     if(lineItems[0].FS_WA_Effective_Date__c!=FSConstants.NULLVALUE){
                         value.FS_SP_Scheduled_Date__c=lineItems[0].FS_WA_Effective_Date__c;
                     }
                     else{
                         value.FS_SP_Scheduled_Date__c=lineItems[0].FS_DA_Effective_Date__c;
                     }
                     
                 }
                 outletTest.add(value); 
             }
            
            update  outletTest;  
            }
        }
        catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            ApexErrorLogger.addApexErrorLog(appName,className,methodNamesDML.createFlavorChangeForHQChain.name(),
                                            flavorChangeSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name());
            newFalvorChangeList=new List<FS_Flavor_Change_New__c>();
        }
        
        return newFalvorChangeList; 
    }
    
    public FS_Flavor_Change_Head__c  createRecordsRelatedToOutlet(FS_Flavor_Change_Head__c  parentFlavorChangeHead){
        
        //Variable to be returned
        FS_Flavor_Change_Head__c  returnReference;
        
        List<String> outletZipCodes =new List<String>();  
        
        List<FS_Association_Brandset__c> associationBrandsetRecords=fetchAssociationBrandsets();
        
        for(FS_Association_Brandset__c assosiatedBrandset : associationBrandsetRecords){
            
            if(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode!= nullConstant){
                outletZipCodes.add(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__r.ShippingPostalCode);
            }  
            
        }
        
        //Refer user selected values
        Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap=setCurrentBrandsetValues();
        
        if(!newPlatformBrandsetFlavorChangeMap.isEmpty()){
            //Create Flavor Change Header
            Map<Id,FS_Flavor_Change_Head__c> flavorChangeHeaderOutletMap=createFlavorChangeHeader(associationBrandsetRecords,newPlatformBrandsetFlavorChangeMap,parentFlavorChangeHead);
            //Create Flavor Change 
            createFlavorChange(flavorChangeHeaderOutletMap,associationBrandsetRecords,newPlatformBrandsetFlavorChangeMap);
            //Create Service Order
            createServiceOrder(outletZipCodes,flavorChangeHeaderOutletMap);
            
            returnReference= flavorChangeHeaderOutletMap.values()[0];
        }
        return returnReference;
    }
    
    
    public Map<Id,FS_Flavor_Change_Head__c> createFlavorChangeHeader(List<FS_Association_Brandset__c> associationBrandsetRecords,
                                                                     Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap,
                                                                     FS_Flavor_Change_Head__c  parentFlavorChangeHead){
                                                                         
                                                                         //Collection with Outlet Id as key and Flavor Change Header as values
                                                                         Map<Id,FS_Flavor_Change_Head__c> flavorChangeHeaderOutletMap=new Map<Id,FS_Flavor_Change_Head__c>();
                                                                         
                                                                         
                                                                         Id recTypeHeadInstall=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_Head__c.SObjectType,falvorChangeInstallRecordType);
                                                                         Id recTypeHeadOutlet=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_Head__c.SObjectType,falvorChangeOutletRecordType);
                                                                         
                                                                         //Iterate over association brandset
                                                                         for(FS_Association_Brandset__c assosiatedBrandset: associationBrandsetRecords){
                                                                             if(newPlatformBrandsetFlavorChangeMap.containsKey(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c)){
                                                                                 FS_Flavor_Change_New__c inputFlavorChange=newPlatformBrandsetFlavorChangeMap.get(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c);
                                                                               
                                                                                 if(!flavorChangeHeaderOutletMap.containsKey(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c)){
                                                                                     
                                                                                     FS_Flavor_Change_Head__c flavorChangeHeadOutlet=new FS_Flavor_Change_Head__c(); 
                                                                                     flavorChangeHeadOutlet.FS_HQ_Chain__c=assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c;
                                                                                     flavorChangeHeadOutlet.FS_FC_Type__c=flavorChangeType;
                                                                                     
                                                                                     if(sObjectType==installationSobject){
                                                                                         flavorChangeHeadOutlet.RecordTypeId=recTypeHeadInstall; 
                                                                                         flavorChangeHeadOutlet.FS_installation__c=parentRecordId;
                                                                                     }
                                                                                     else{
                                                                                         flavorChangeHeadOutlet.RecordTypeId=recTypeHeadOutlet; 
                                                                                     }
                                                                                     flavorChangeHeadOutlet.FS_Pungent_Change_Indicator__c=inputFlavorChange.FS_Pungent_Change_Indicator__c;
                                                                                     flavorChangeHeadOutlet.FS_SP_go_out__c=inputFlavorChange.FS_SP_go_out__c;
                                                                                     
                                                                                     if(parentFlavorChangeHead!=nullConstant){
                                                                                         flavorChangeHeadOutlet.FS_Parent_Flavor_Change__c=parentFlavorChangeHead.Id;
                                                                                     }
                                                                                     
                                                                                     flavorChangeHeaderOutletMap.put(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c,flavorChangeHeadOutlet);
                                                                                 }
                                                                                 else{
                                                                                     //SP Needs to go Out criteria
                                                                                     //1. If an outlet has one or more related dispenser that have the indicator set as yes, 
                                                                                     //   the indicator at the outlet level will be yes
                                                                                     //2. If an outlet has no dispenser that has the indicator set as yes, the indicator at the outlet level will be no.
                                                                                     FS_Flavor_Change_Head__c flavorChangeHeadOutlet=new FS_Flavor_Change_Head__c();
                                                                                     flavorChangeHeadOutlet=flavorChangeHeaderOutletMap.get(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c);
                                                                                     if(String.isNotBlank(inputFlavorChange.FS_SP_go_out__c) && inputFlavorChange.FS_SP_go_out__c.containsIgnoreCase('Yes')){
                                                                                         flavorChangeHeadOutlet.FS_SP_go_out__c='Yes';
                                                                                     }
                                                                                     if(String.isNotBlank(inputFlavorChange.FS_SP_go_out__c) &&  inputFlavorChange.FS_Pungent_Change_Indicator__c.containsIgnoreCase('Yes')){
                                                                                         flavorChangeHeadOutlet.FS_Pungent_Change_Indicator__c='Yes';
                                                                                     }
                                                                                     if(String.isBlank(inputFlavorChange.FS_New_Brandset__c))
                                                                                     {
                                                                                         flavorChangeHeadOutlet.FS_SP_Scheduled_Date__c=inputFlavorChange.FS_DA_Effective_Date__c;
                                                                                     }
                                                                                     system.debug('flavorChangeHeadOutlet:-'+flavorChangeHeadOutlet);
                                                                                     flavorChangeHeaderOutletMap.put(assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c,flavorChangeHeadOutlet);
                                                                                 }
                                                                             }
                                                                         }
                                                                         
                                                                         try{
                                                                             insert flavorChangeHeaderOutletMap.values();
                                                                             // system.debug('flavorChangeHeadOutlet:-'+flavorChangeHeadOutlet);
                                                                         }
                                                                         catch(DMLException ex){
                                                                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                                                                             ApexErrorLogger.addApexErrorLog(appName,className,methodNamesDML.createFlavorChangeHeader.name(),
                                                                                                             flavorChangeHeadSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name());
                                                                             flavorChangeHeaderOutletMap=new Map<Id,FS_Flavor_Change_Head__c>();
                                                                         }
                                                                         return flavorChangeHeaderOutletMap;
                                                                     }
    
    
    public List<FS_Flavor_Change_New__c> createFlavorChange(Map<Id,FS_Flavor_Change_Head__c> flavorChangeHeaderOutletMap,
                                                            List<FS_Association_Brandset__c> associationBrandsetRecords,
                                                            Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap){
                                                         
                                                                List<FS_Flavor_Change_New__c> flavorChangeLineOutletList=new List<FS_Flavor_Change_New__c>();
                                                                Set<ID> outID= new Set<ID>();
                                                                Id recTypeLineOutletOD=FSUtil.getObjectRecordTypeId(FS_Flavor_Change_New__c.SObjectType,falvorChangeOutletRecordType);
                                                               
                                                                List<Date> scheduledDate_WD = New List<Date>();
                                                                for(FS_Association_Brandset__c assosiatedBrandset : associationBrandsetRecords){
                                                                    if(newPlatformBrandsetFlavorChangeMap.containsKey(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c)){
                                                                        FS_Flavor_Change_New__c inputFlavorChange=newPlatformBrandsetFlavorChangeMap.get(assosiatedBrandset.FS_Brandset__c+assosiatedBrandset.FS_Platform__c);
                                                                        Id outletId=assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c;
                                                                        if(flavorChangeHeaderOutletMap.containsKey(outletId)){
                                                                            
                                                                            
                                                                            FS_Flavor_Change_New__c fcLineOutlet=new FS_Flavor_Change_New__c ();
                                                                            fcLineOutlet.FS_FC_Head__c=flavorChangeHeaderOutletMap.get(outletId).id;
                                                                            fclineOutlet.RecordTypeId=recTypeLineOutletOD;
                                                                            fcLineOutlet.FS_outlet__c=assosiatedBrandset.FS_Outlet_Dispenser__r.FS_outlet__c;
                                                                            fcLineOutlet.FS_Outlet_Dispenser__c=assosiatedBrandset.FS_Outlet_Dispenser__c;
                                                                            fcLineOutlet.FS_Platform__c =assosiatedBrandset.FS_Platform__c;
                                                                            fcLineOutlet.FS_Current_Brandset__c =assosiatedBrandset.FS_Brandset__c;
                                                                            fcLineOutlet.FS_New_Brandset__c=inputFlavorChange.FS_New_Brandset__c;
                                                                            fcLineOutlet.FS_BS_Effective_Date__c=inputFlavorChange.FS_BS_Effective_Date__c;
                                                                            //fcLineOutlet.FS_Hide_Show_Dasani__c=inputFlavorChange.FS_Hide_Show_Dasani__c;
                                                                            fcLineOutlet.FS_Hide_Show_Water_Button__c=inputFlavorChange.FS_Hide_Show_Water_Button__c;
                                                                            //fcLineOutlet.FS_DA_Effective_Date__c=inputFlavorChange.FS_DA_Effective_Date__c;
                                                                            fcLineOutlet.FS_WA_Effective_Date__c=inputFlavorChange.FS_WA_Effective_Date__c;
                                                                            fcLineOutlet.FS_Flavor_Change_Requested_Date__c=inputFlavorChange.FS_Flavor_Change_Requested_Date__c;
                                                                            fcLineOutlet.FS_SP_go_out__c=inputFlavorChange.FS_SP_go_out__c;
                                                                            fcLineOutlet.FS_Pungent_Change_Indicator__c=inputFlavorChange.FS_Pungent_Change_Indicator__c;
                                                                            //OCR'17 FR_12 Rahim_Uddin 
                                                                            if(inputFlavorChange.FS_New_Brandset__c==FSConstants.NULLVALUE)
                                                                            {
                                                                                outID.add(flavorChangeHeaderOutletMap.get(outletId).id);
                                                                                
                                                                                fcLineOutlet.FS_Only_Water_Dasani__c= true;
                                                                            }
                                                                            
                                                                            flavorChangeLineOutletList.add(fcLineOutlet);
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                try{
                                                                    insert flavorChangeLineOutletList;
                                                                     //OCR'17 FR_12 Rahim_Uddin:to update schedule date
                                                                    List<FS_Flavor_Change_Head__c> outletWithNoBS=[Select Id,Name,FS_SP_Scheduled_Date__c,(SELECT Id,FS_Only_Water_Dasani__c,FS_WA_Effective_Date__c,FS_DA_Effective_Date__c  FROM Flavor_Changes_New__r LIMIT 1) from FS_Flavor_Change_Head__c where ID in :outID ];
                                                                    
                                                                    List<FS_Flavor_Change_Head__c> outlet = new List<FS_Flavor_Change_Head__c>();
                                                                    if(!outletWithNoBS.isEmpty()){
                                                                    for(FS_Flavor_Change_Head__c value:outletWithNoBS )
                                                                    {
                                                                        List<FS_Flavor_Change_New__c> lineItems =value.Flavor_Changes_New__r;
                                                                        if(lineItems.size()>FSConstants.ZERO){
                                                                            if(lineItems[0].FS_WA_Effective_Date__c!=FSConstants.NULLVALUE){
                                                                                value.FS_SP_Scheduled_Date__c=lineItems[0].FS_WA_Effective_Date__c;
                                                                                
                                                                            }
                                                                            else{
                                                                                value.FS_SP_Scheduled_Date__c=lineItems[0].FS_DA_Effective_Date__c;
                                                                            }
                                                                        }
                                                                        outlet.add(value);    
                                                                    }
                                                                    }
                                                                    update  outlet;
                                                                }
                                                                catch(DMLException ex){
                                                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                                                                    ApexErrorLogger.addApexErrorLog(appName,className,methodNamesDML.createFlavorChange.name(),
                                                                                                    flavorChangeSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name());
                                                                    
                                                                    flavorChangeLineOutletList=new List<FS_Flavor_Change_New__c>();
                                                                }
                                                                return flavorChangeLineOutletList;
                                                            }
    
    
    public void createServiceOrder(List<String> outletZipCodes, Map<Id,FS_Flavor_Change_Head__c> flavorChangeHeaderOutletMap){
        
      
        
        List<FS_Service_Order__c> serviceOrderList=new List<FS_Service_Order__c>();
        
        //Creating dummy Service orders to Outlet level Falvor change header where SP needs to go out Value is 'yes'
        serviceOrderList=FSUtil.createServiceOrder(outletZipCodes,flavorChangeHeaderOutletMap);
        
        try{
            insert serviceOrderList;
        }
        catch(DMLException ex){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                               ApexErrorLogger.addApexErrorLog(appName,className,methodNamesDML.createServiceOrder.name(),
                                                               serviceOrderSobject,stringLiterals.Medium.name(),ex,stringLiterals.NA.name()); }
        
    }
    
    
    public Map<String,FS_Flavor_Change_New__c> setCurrentBrandsetValues(){
        Map<String,FS_Flavor_Change_New__c> newPlatformBrandsetFlavorChangeMap=new Map<String,FS_Flavor_Change_New__c>();
        
        for(Fs_flavor_change_new__c flavorChange :newFlavorChangeData){
            if(flavorChange.FS_New_Brandset__c!=nullConstant||flavorChange.FS_Hide_Show_Water_Button__c!=nullConstant){
                   newPlatformBrandsetFlavorChangeMap.put(flavorChange.FS_Current_Brandset__c+flavorChange.FS_Platform__c,flavorChange );
               }
            
        }
        return newPlatformBrandsetFlavorChangeMap;
    }
    
    
    
    public Boolean validateCurrentBrandAttributes() {
        Boolean validationPassed=true;
        Boolean validationFinal=false;
        Boolean userInputsAtleastOneValidRow=false;
        Boolean invalidRowEntered=false;
        blankRows=0;
        totalRows=0;
        Map<String, FS_FlavorChange_ErrorMessages__c> errorMessages= FS_FlavorChange_ErrorMessages__c.getAll();
        for(FS_Flavor_Change_New__c flavorChange :newFlavorChangeData){
            totalRows++;
            if(flavorChange.FS_New_Brandset__c==nullConstant &&  flavorChange.FS_Hide_Show_Dasani__c==nullConstant
               &&  flavorChange.FS_Hide_Show_Water_Button__c==nullConstant && flavorChange.FS_BS_Effective_Date__c==nullConstant
               && flavorChange.FS_DA_Effective_Date__c==nullConstant && flavorChange.FS_WA_Effective_Date__c==nullConstant && flavorChange.FS_SP_go_out__c==nullConstant && flavorChange.FS_Pungent_Change_Indicator__c==nullConstant){
                   blankRows++;
               }
            else{
                validationPassed=attributesAndDatesValidation(flavorChange,errorMessages);
                if(validationPassed){
                    validationFinal=true;
                }
                else{
                    invalidRowEntered=true;
                }
            }               
        } 
        if(blankRows==totalRows){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.ValueChangeRequired.name()).FS_Error_Message__c));
        }
        if(invalidRowEntered){
            validationFinal=false;
        }
        
        return validationFinal;
    }
    
    public Boolean attributesAndDatesValidation(FS_Flavor_Change_New__c flavorChange,Map<String, FS_FlavorChange_ErrorMessages__c> errorMessages){
        Boolean validationPassed=true;
       
        if((flavorChange.FS_BS_Effective_Date__c<Date.today())||(flavorChange.FS_DA_Effective_Date__c < Date.today())
           ||(flavorChange .FS_WA_Effective_Date__c < Date.today())){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages.get(flavorChangeErrorMessageHeader.EarlyDateError.name()).FS_Error_Message__c));
            validationPassed= false;
        }
         //OCR'17 FR_12 Sowmaya:Added for FS_Flavor_Change_Requested_Date__c validation
        if(flavorChange.FS_Flavor_Change_Requested_Date__c<Date.today()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Requested Date cannot be earlier than today’s date'));
            validationPassed= false;
        }
        
        Account acc = [SELECT Id,FS_Final_Delivery_Method__c,FS_Final_Order_Method__c FROM Account WHERE Id=:flavorChange.FS_Outlet__c];
        
        if(acc.FS_Final_Order_Method__c == null || acc.FS_Final_Delivery_Method__c == null){
            system.debug('OD'+ acc.FS_Final_Order_Method__c);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure the order and delivery methods are present against this outlet, otherwise the flavor change workflow will not work'));
            validationPassed= false;
        } 
        
        if(flavorChange.FS_New_Brandset__c!=nullConstant  && flavorChange.FS_BS_Effective_Date__c== nullConstant){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.EffBrandsetRequired.name()).FS_Error_Message__c));
            validationPassed= false;
        }
        if(flavorChange.FS_New_Brandset__c==nullConstant  && flavorChange.FS_BS_Effective_Date__c!= nullConstant ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.NewBrandsetRequired.name()).FS_Error_Message__c));
            validationPassed= false;
        }
        /* Commented as part of FFET-651 FET5.1
        if(flavorChange.FS_Hide_Show_Dasani__c!=nullConstant && flavorChange.FS_DA_Effective_Date__c== nullConstant ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.EffDasainiDateRequired.name()).FS_Error_Message__c));
            validationPassed= false;
        }
        if(flavorChange.FS_Hide_Show_Dasani__c==nullConstant && flavorChange.FS_DA_Effective_Date__c!= nullConstant ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.DasaniRequired.name()).FS_Error_Message__c));
            validationPassed= false;
        }*/
        if(flavorChange.FS_Hide_Show_Water_Button__c!=nullConstant && flavorChange.FS_WA_Effective_Date__c==nullConstant ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.EffWaterButtonDateRequired.name()).FS_Error_Message__c));
            validationPassed= false;
        }
        if(flavorChange.FS_Hide_Show_Water_Button__c==nullConstant && flavorChange.FS_WA_Effective_Date__c!=nullConstant ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages.get(flavorChangeErrorMessageHeader.WaterButtonRequired.name()).FS_Error_Message__c));
            validationPassed= false;
        }
        if(flavorChange.FS_New_Brandset__c!=nullConstant && string.isBlank(flavorChange.FS_Pungent_Change_Indicator__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages.get(flavorChangeErrorMessageHeader.PungentChangeRequired.name()).FS_Error_Message__c));
            validationPassed= false;
        }
        if(flavorChange.FS_New_Brandset__c!=nullConstant && string.isBlank(flavorChange.FS_SP_go_out__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages.get(flavorChangeErrorMessageHeader.SpNeedsToGoOutRequired.name()).FS_Error_Message__c));
            validationPassed= false;
        }        
        
        if(flavorChange.FS_New_Brandset__c==nullConstant &&  flavorChange.FS_Hide_Show_Dasani__c==nullConstant
           &&  flavorChange.FS_Hide_Show_Water_Button__c==nullConstant){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.ValueChangeRequired.name()).FS_Error_Message__c));
               validationPassed= false;
           }
        if(flavorChange.FS_New_Brandset__c==nullConstant &&  flavorChange.FS_Hide_Show_Dasani__c==nullConstant
           &&  flavorChange.FS_Hide_Show_Water_Button__c==nullConstant && (flavorChange.FS_SP_go_out__c!=nullConstant || flavorChange.FS_Pungent_Change_Indicator__c!=nullConstant)){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessages.get(flavorChangeErrorMessageHeader.ValueChangeRequired.name()).FS_Error_Message__c));
               validationPassed= false;
           }
        return validationPassed;
    }
    
    public pageReference loadDefaults(){
        
        for(Account outlet : fetchOutletsSOQL()){
            selectedoutletRecords.add(new AccountWrapper(outlet,true));
        }
        populateFlavorChangeInput();
        
        return null;
    } 
    /**** @MethodName - fillDown
* @Description -Copy first row values to all records below it.
* @Return - void
*/
    public void fillDown(){
        if (selectedFillDown == selectFillDownValues.BrandsetEffectiveDate.name()){
            Date bsEffectiveDate=newFlavorChangeData[0].FS_BS_Effective_Date__c;
            for(Fs_flavor_change_new__c fc :newFlavorChangeData){
                fc.FS_BS_Effective_Date__c=bsEffectiveDate;
            }
        }
        if (selectedFillDown == selectFillDownValues.Dasani.name()){
            String dasaniValue=newFlavorChangeData[0].FS_Hide_Show_Dasani__c;
            for(Fs_flavor_change_new__c fc :newFlavorChangeData){
                fc.FS_Hide_Show_Dasani__c=dasaniValue;
            }
        }
        if (selectedFillDown == selectFillDownValues.DasaniEffectiveDate.name() ){
            Date dasaniEffectiveDate=newFlavorChangeData[0].FS_DA_Effective_Date__c;
            for(Fs_flavor_change_new__c fc :newFlavorChangeData){
                fc.FS_DA_Effective_Date__c=dasaniEffectiveDate;
            }
        }
        if (selectedFillDown == selectFillDownValues.WaterButton.name()){
            String waterButtonValue=newFlavorChangeData[0].FS_Hide_Show_Water_Button__c;
            for(Fs_flavor_change_new__c fc :newFlavorChangeData){
                fc.FS_Hide_Show_Water_Button__c=waterButtonValue;
            }
        }
        
        if (selectedFillDown == selectFillDownValues.WaterEffectiveDate.name()){
            Date waterEffectiveDate=newFlavorChangeData[0].FS_WA_Effective_Date__c;
            for(Fs_flavor_change_new__c fc :newFlavorChangeData){
                fc.FS_WA_Effective_Date__c=waterEffectiveDate;
            }
        }
        
        if (selectedFillDown == selectFillDownValues.PungentIndicator.name()){
            String pungentIndicatorValue=newFlavorChangeData[0].FS_Pungent_Change_Indicator__c;
            for(Fs_flavor_change_new__c fc :newFlavorChangeData){
                fc.FS_Pungent_Change_Indicator__c=pungentIndicatorValue;
            }
        }
        
        if (selectedFillDown == selectFillDownValues.ServiceProvider.name()){
            String serviceProviderValue=newFlavorChangeData[0].FS_SP_go_out__c;
            for(Fs_flavor_change_new__c fc :newFlavorChangeData){
                fc.FS_SP_go_out__c=serviceProviderValue;
            }
        }
        
        if (selectedFillDown == selectFillDownValues.RequestedDate.name()){
          Date requestedDate=newFlavorChangeData[0].FS_Flavor_Change_Requested_Date__c;
           
            for(Fs_flavor_change_new__c fc :newFlavorChangeData){
                fc.FS_Flavor_Change_Requested_Date__c=requestedDate;
            }
        }
    }
    
    /**************Pagination Module Start***********************************/
    
    public PageReference updateAvailableData(){
        availableOutletsList=new List<AccountWrapper>();
        for(Object obj: paginatorAvailable.populateResults()){
            this.availableOutletsList.add((AccountWrapper) obj);
        }
        
        return null;
    }
    public PageReference availableFirst() {
        
        paginatorAvailable.First();
        updateAvailableData();
        return null;
    }
    
    public PageReference availablePrevious() { 
        
        paginatorAvailable.Previous();
        updateAvailableData();
        return null;
    }
    
    public PageReference availableNext() { 
        
        paginatorAvailable.Next();
        updateAvailableData();
        return null;
    }
    
    public PageReference availableEnd(){
        
        paginatorAvailable.Last();
        updateAvailableData();
        return null;
    }
    
    public Boolean getAvailableDisablePrevious() {
        return paginatorAvailable.getDisablePrevious();
    }
    
    public Boolean getAvailableDisableNext() {
        return paginatorAvailable.getDisableNext();
    }
    
    
    /*********************************************/
    
    public PageReference updateSelectedData(){
        selectedOutletsList=new List<AccountWrapper>();
        for(Object obj: paginatorSelected.populateResults()){
            this.selectedOutletsList.add((AccountWrapper) obj);
        }
        
        return null;
    }
    public PageReference selectedFirst() {
        paginatorSelected.First();
        updateSelectedData();
        return null;
    }
    
    public PageReference selectedPrevious() { 
        paginatorSelected.Previous();
        updateSelectedData();
        return null;
    }
    
    public PageReference selectedNext() { 
        paginatorSelected.Next();
        updateSelectedData();
        return null;
    }
    
    public PageReference selectedEnd(){ 
        paginatorSelected.Last();
        updateSelectedData();
        return null;
    }
    
    public Boolean getSelectedDisablePrevious() { 
        return paginatorSelected.getDisablePrevious();
    }
    
    public Boolean getSelectedDisableNext() { 
        return paginatorSelected.getDisableNext();
    }
    
    
    //Wrapper Class to facilitate Brand Set Record Selection 
    public class AccountWrapper{
        public Boolean selected{set;get;}
        public Account outletRecord{set;get;}
        public AccountWrapper(Account outletInstance,Boolean selectCheck){
            selected=selectCheck;
            outletRecord=outletInstance;            
        }
        
    }
}