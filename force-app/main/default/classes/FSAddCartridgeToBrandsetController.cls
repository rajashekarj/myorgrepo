/*********************************************************************************************************
Name         : FSAddCartridgeToBrandsetController 
Created By   : Infosys Limited 
Created Date : 7-Feb-2017
Usage        : Extension for FSAddCartridgeToBrandset, which is used to add cartridge records to Brandset

***********************************************************************************************************/
public without sharing class FSAddCartridgeToBrandsetController {
    
    private final static Object NULLOBJ = null;
    public static final Integer pageSize=30;
    public static final Boolean IsTrue=true;
    @TestVisible //Collection variable that holds all selected cartridge records
    private Map<Id,FS_Cartridge__c> selectedCartridgeMap;
    @TestVisible //Collection variable that holds all selected cartridge records to be removed
    private Map<Id,FS_Cartridge__c> selectedCartridgeRemoveMap;
    
    @TestVisible //Collection variable that holds all existing catridge records
    private Map<Id,FS_Cartridge__c> existingCartridgesMap;
    //Search literals of Cartridge Fields
    public String searchCartridgeName{set;get;}
    public String searchCartridgeBrand{set;get;}
    public String searchCartridgeFlavor{set;get;}
    public String searchCartridgeType{set;get;}
    public String[] searchCartridgePlatform{set;get;}
    public String searchCartridgeCountry{set;get;}
    
    
    //Collection variable that holds all available cartridge search result
    public List<CartridgeWrapper> cartridgeRecords{get;set;}
    
    //Collection variable that holds all selected cartridge search result
    public List<CartridgeWrapper> selectedCartridgeRecords{get;set;}  
   
    
    
    
    
    
    public ApexPages.StandardController standardController{get;set;}
    
    
    /****Pagination Variables Start****************************/
    
     //paginator reference for selected cartridge records
     public FSDynamicWrapperPaginator paginatorSelected {get;set;}
     
     //Collection variable(used for pagination) that holds selected cartridge search result
     public List<CartridgeWrapper> selectedCartridgesList{get;set;}
     
     //paginator reference for available cartridge records
     public FSDynamicWrapperPaginator paginatorAvailable {get;set;}
     
     //Collection variable (used for pagination) that holds available cartridge search result
     public List<CartridgeWrapper> availableCartridgesList{get;set;}
     
    /****Pagination Variables End****************************/
    
    public FSAddCartridgeToBrandsetController(ApexPages.StandardController controller) {
        
        //reference for Standard controller
        standardController=controller;
        
        //load current Brandset record details
        FS_Brandset__c thisRecord=(FS_Brandset__c )standardController.getRecord();
        
        //default platform type for the brandset record
        searchCartridgePlatform=new List<String>();
        if(String.isNotBlank(thisRecord.FS_Platform__c)){
          searchCartridgePlatform.addAll(thisRecord.FS_Platform__c.split(';'));
        }
        
        searchCartridgeCountry=thisRecord.FS_Country__c;
        
        selectedCartridgeMap=new Map<Id,FS_Cartridge__c>(); 
        selectedCartridgeRemoveMap=new Map<Id,FS_Cartridge__c>(); 
        
        existingCartridgesMap=new Map<Id,FS_Cartridge__c>();  
        
        selectedCartridgeRecords=new List<CartridgeWrapper>();  
        
        fetchExistingBrandsetCartridge();
        
        initializePaginator();
    }
    
    public void fetchExistingBrandsetCartridge(){
      //load already added cartridge records
        Set<Id> existingCartridgesIds=new Set<Id>();
        for(FS_Brandsets_Cartridges__c brandsetCartridge : retrieveAlreadyAddedCartridgeRecords()){
           existingCartridgesIds.add(brandsetCartridge.FS_Cartridge__c);
        }
        
        if(!existingCartridgesIds.isEmpty()){
           for(FS_Cartridge__c cartridge :  [SELECT Id,Name,FS_RFID_and_Version__c from FS_Cartridge__c where Id IN: existingCartridgesIds]){
               existingCartridgesMap.put(cartridge.Id,cartridge);
               selectedCartridgeRecords.add(new CartridgeWrapper(cartridge,false));
           }            
        }
    }
    
    
    public void initializePaginator(){
        this.paginatorAvailable = new FSDynamicWrapperPaginator(getCartridgeRecords());
        this.paginatorAvailable.pageNum =pageSize;
        updateAvailableData();
        
        this.paginatorSelected = new FSDynamicWrapperPaginator(selectedCartridgeRecords);
        this.paginatorSelected.pageNum =pageSize ;
        updateSelectedData();
    }
    
    /*****************************************************************
  	Method: search
  	Description: Method called by Search cartridge to update VF's view state
	*******************************************************************/
    public PageReference search(){
     getCartridgeRecords();
     return null;
    }
    
    public PageReference backToDetailPage(){
     return new PageReference('/'+standardController.getId());
    }
    
    public Pagereference  addSelectedCartridges(){
     
     getSelectedCartridges();
     
     //add existing cartridge records
     for(FS_Cartridge__c cartridge :  existingCartridgesMap.values()){
         selectedCartridgeRecords.add(new CartridgeWrapper(cartridge,false));
     }
     //add selected cartridge records
     for(FS_Cartridge__c cartridge :  selectedCartridgeMap.values()){
         selectedCartridgeRecords.add(new CartridgeWrapper(cartridge,false));
     }
     
     /*** Filter duplicate cartridge Start*********************************/
     Set<FS_Cartridge__c> uniqueCartridges = new Set<FS_Cartridge__c>();
     List<FS_Cartridge__c> result = new List<FS_Cartridge__c>();
     for(CartridgeWrapper wrpItem : selectedCartridgeRecords){
       uniqueCartridges.add(wrpItem.cartridge);
     }
     
     if(!uniqueCartridges.isEmpty()){
        selectedCartridgeRecords.clear();
        for(FS_Cartridge__c cartridge : uniqueCartridges){
           selectedCartridgeRecords.add(new CartridgeWrapper(cartridge,false));
        }
     }
     /*** Filter duplicate cartridge End*********************************/
     
     paginatorSelected = new FSDynamicWrapperPaginator(selectedCartridgeRecords);
     paginatorSelected.pageNum =pageSize ;
     updateSelectedData();
     
     getCartridgeRecords();
     
     return null;
    }
  
    /*****************************************************************
  	Method: saveCartridgesToBrandset
  	Description: Method call by add cartridges method
	*******************************************************************/
    public Pagereference saveCartridgesToBrandset(){
      
      List<FS_Brandsets_Cartridges__c> existingBrandsetCartridges= retrieveAlreadyAddedCartridgeRecords();
      
      List<FS_Brandsets_Cartridges__c > brandsetCartridgeTobeCreated= new List<FS_Brandsets_Cartridges__c >(); 
      
      for(CartridgeWrapper wrpItem :  selectedCartridgeRecords){
             FS_Brandsets_Cartridges__c brandsetCartridge=new FS_Brandsets_Cartridges__c();
               brandsetCartridge.FS_Brandset__c=standardController.getId();
               brandsetCartridge.FS_Cartridge__c=wrpItem.cartridge.Id;
               brandsetCartridgeTobeCreated.add(brandsetCartridge);
      }
      
      //Deleting already existing brandset cartridges        
      if(!existingBrandsetCartridges.isEmpty()){
          final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSAddCartridgeToBrandsetController',
                                                           Method_Name__c='addCartridgesToBrandset',Object_Name__c='FS_Brandsets_Cartridges__c',
                                                           Error_Severity__c=FSConstants.MediumPriority);
           FSUtil.dmlProcessorDelete(existingBrandsetCartridges,true,apexError);
      }
      
      if(!brandsetCartridgeTobeCreated.isEmpty()){
          final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c='FET',Class_Name__c='FSAddCartridgeToBrandsetController',
                                                           Method_Name__c='addCartridgesToBrandset',Object_Name__c='FS_Brandsets_Cartridges__c',
                                                           Error_Severity__c='High');
           FSUtil.dmlProcessorInsert(brandsetCartridgeTobeCreated,true,apexError);
      }   
      
       return standardController.view();
    }
    
    public void getSelectedCartridgesToRemove(){
        if(selectedCartridgeRecords!=NULLOBJ){
            for(CartridgeWrapper wrpItem : selectedCartridgeRecords){
                if(wrpItem.selected){
                  selectedCartridgeRemoveMap.put(wrpItem.cartridge.Id,wrpItem.cartridge); 
                  existingCartridgesMap.remove(wrpItem.cartridge.Id);
                }
                else{
                   selectedCartridgeRemoveMap.remove(wrpItem.cartridge.Id);
                }
            }
        }
    }
    
    /*****************************************************************
  	Method: removeCartridges
  	Description: Method call to remove brandset Cartridge records from the brandset 
	*******************************************************************/
    public Pagereference removeCartridges(){
      getSelectedCartridgesToRemove();
      
      List<CartridgeWrapper> addedCartridges=new List<CartridgeWrapper>();
      for(CartridgeWrapper wrpItem : selectedCartridgeRecords){
         if(!selectedCartridgeRemoveMap.containsKey(wrpItem.cartridge.Id)){
           addedCartridges.add(new CartridgeWrapper(wrpItem.cartridge,false));
         }
      }
      
      selectedCartridgeRecords.clear();
      selectedCartridgeRecords.addAll(addedCartridges);
      
      paginatorSelected = new FSDynamicWrapperPaginator(selectedCartridgeRecords);
      paginatorSelected.pageNum =pageSize ;
      updateSelectedData();
      
      selectedCartridgeMap = new Map<Id,FS_Cartridge__c>();  //loose view state for cartridge selected records
      getCartridgeRecords();
      
      return null;
    }
   
    /*****************************************************************
  	Method: getCartridgeRecords
  	Description: cartridge search result
	*******************************************************************/
    public List<CartridgeWrapper> getCartridgeRecords(){
    
        getSelectedCartridges();
        
        cartridgeRecords=new List<CartridgeWrapper>();
        
        //Collection to hold records that are displayed in selected cartridge section
        Map<Id,FS_Cartridge__c>  displayedSelectedCartridgeMap=new Map<Id,FS_Cartridge__c>();
        
        for(CartridgeWrapper wrpItem : selectedCartridgeRecords){
          displayedSelectedCartridgeMap.put(wrpItem.cartridge.Id,wrpItem.cartridge);
        }
        
        for(FS_Cartridge__c cartridge : fetchCartridgesSOQL()){
             if(!selectedCartridgeMap.containsKey(cartridge.Id)){
                if(!displayedSelectedCartridgeMap.containsKey(cartridge.Id)){
                   cartridgeRecords.add(new CartridgeWrapper(cartridge,false));
                }
             }
             else{
                if(!displayedSelectedCartridgeMap.containsKey(cartridge.Id)){
                   cartridgeRecords.add(new CartridgeWrapper(cartridge,true));
                }
             }
        }
        
        paginatorAvailable = new FSDynamicWrapperPaginator(cartridgeRecords);
        paginatorAvailable.pageNum =pageSize;
        updateAvailableData();
        
        return cartridgeRecords;
      
    }
    
    /*****************************************************************
  	Method: getSelectedCartridges
  	Description: populate collection to hold selected cartridge from search result
	*******************************************************************/
    public void getSelectedCartridges(){
        if(cartridgeRecords!=NULLOBJ){
            for(CartridgeWrapper wrpItem : cartridgeRecords){
                if(wrpItem.selected){
                  selectedCartridgeMap.put(wrpItem.cartridge.Id,wrpItem.cartridge); 
                }
                else{
                   selectedCartridgeMap.remove(wrpItem.cartridge.Id);
                }
            }
        }
    }
    
    /*****************************************************************
  	Method: fetchCartridgesSOQL
  	Description: Search Cartridge records Based on User Input
	*******************************************************************/
    public List<FS_Cartridge__c> fetchCartridgesSOQL(){ 
     
     //search literals
     String cartridgePlatform;
     String cartridgeCountry;
     List<String> cartridgeCountries=new List<String>();
     List<String> cartridgePlatforms=new List<String>();
     
     if(!searchCartridgePlatform.isEmpty()){
          cartridgePlatform='';
           for(String platform : searchCartridgePlatform){
              cartridgePlatform+= '\''+platform+ '\''+',';
           } 
           
           if(cartridgePlatform.lastIndexOf(',')!=-1){
             cartridgePlatform=cartridgePlatform.removeEnd(',');
           }
           
     }
     
     if(String.isNotBlank(searchCartridgeCountry)){
        if(searchCartridgeCountry.contains(';')){
           cartridgeCountries.addAll(searchCartridgeCountry.split(';'));
           cartridgeCountry='';
           for(String country : cartridgeCountries){
              cartridgeCountry+= '\''+country+ '\''+',';
           }
           cartridgeCountry=cartridgeCountry.removeEnd(',');
        }
        else{
          cartridgeCountry='\''+searchCartridgeCountry+ '\'';
        }
       
     }
     
     
     Date todaysDate=Date.today();
     
     String searchquery= 'Select Id,Name,FS_Platform__c,FS_Country__c,FS_Brand__c,FS_Flavor__c,FS_RFID__c,'
                        +'FS_RFID_and_Version__c,FS_Cartridge_type__c,FS_Available_for_commercial_use__c from FS_Cartridge__c WHERE FS_Available_for_commercial_use__c  = :isTrue ';
     
    
     if(String.isNotBlank(searchCartridgeName)){
       searchquery += ' AND Name LIKE \''+searchCartridgeName+'%\' ';
     }
     if(String.isNotBlank(searchCartridgeBrand)){
       searchquery += ' AND FS_Brand__c LIKE \''+searchCartridgeBrand+'%\' ';
     }  
     if(String.isNotBlank(searchCartridgeFlavor)){
       searchquery += ' AND FS_Flavor__c LIKE \''+searchCartridgeFlavor+'%\' ';
     }
     if(String.isNotBlank(cartridgePlatform)){
       searchquery += ' AND FS_Platform__c includes ('+cartridgePlatform+') ';
     }
     if(String.isNotBlank(cartridgeCountry)){
       searchquery += ' AND FS_Country__c includes ('+cartridgeCountry+') '; 
     } 
     if(String.isNotBlank(searchCartridgeType)){
       searchquery += ' AND FS_Cartridge_type__c LIKE \''+searchCartridgeType+'%\' ';
     }         
     searchquery +=' ORDER BY Name LIMIT 2000 ';  
     
     List<SObject> searchList=Database.query(searchquery);
     return (List<FS_Cartridge__c>)searchList;
     
    }

    /*****************************************************************
  	Method: retrieveAlreadyAddedCartridgeRecords
  	Description: brandset cartridge records for the brandset
	*******************************************************************/
    public List<FS_Brandsets_Cartridges__c> retrieveAlreadyAddedCartridgeRecords(){
     
     return [SELECT ID,Name,FS_Brandset__c,FS_Cartridge__c FROM FS_Brandsets_Cartridges__c 
             WHERE FS_Brandset__c =:standardController.getId() ORDER BY CreatedDate DESC];
    }
    
    
    public List<SelectOption> getCartridgeTypes(){ 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));   
        
        // Adding picklist values to the select list
        for(Schema.PicklistEntry entry : FSUtil.getFieldPicklistValues(FS_Cartridge__c.SObjectType,'FS_Cartridge_type__c')){
               options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        
        return options; 
    }
    
    
    /**************Pagination Module Start***********************************/
    
    public PageReference updateAvailableData(){
        availableCartridgesList=new List<CartridgeWrapper>();
        for(Object obj: paginatorAvailable.populateResults()){
          this.availableCartridgesList.add((CartridgeWrapper) obj);
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
        selectedCartridgesList =new List<CartridgeWrapper>();
        for(Object obj: paginatorSelected.populateResults()){
          this.selectedCartridgesList.add((CartridgeWrapper) obj);
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
    
           
    /**************Pagination Module End***********************************/ 
    
    /*****************************************************************
  	Method: CartridgeWrapper
  	Description: Wrapper Class to facilitate Cartridge Selection 
	*******************************************************************/
    public class CartridgeWrapper{
        public Boolean selected{set;get;}
        public FS_Cartridge__c cartridge {set;get;}
        public CartridgeWrapper(FS_Cartridge__c cartridgeIntance,Boolean selectCheck){
            selected=selectCheck;
            cartridge =cartridgeIntance;            
        }
        
    }
     
}