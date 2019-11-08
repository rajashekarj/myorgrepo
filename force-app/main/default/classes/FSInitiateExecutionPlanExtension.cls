/********************************************************************************************************* 
Name         : FSInitiateExecutionPlanExtension
Created By   : Pallavi Sharma (Appiro)
Created Date : 09 - Sep - 2013
Usage        : Extension for FSInitiate Execution Plan , which is use to set Approval date on selected Outlets
***********************************************************************************************************/

public with sharing class FSInitiateExecutionPlanExtension {
    public final set<Id> allSelectedOutletIds;
    public set<Id> currentSelectedOutletIds;
    public final Id accId;
    public Id outletRecordTypeId;
    public static final Integer PAGE_SIZE = 25;
    public string previousSortField;    
    public static final string DEFAULT_SORT_FIELD = 'FS_ACN__c';
    public static final string SYMBOL='%\'';
    public static final ApexPages.StandardSetController CONTROL=null;
    
    public Integer noOfRecords{get; set;}
    public List<OutletWrapper> outletList{get;set;} 
    public string sortField{set;get;}    
    public boolean isAsc{set; get;}
    
    
    //-----------------------------------------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------------------------------------
    public FSInitiateExecutionPlanExtension (final Apexpages.Standardcontroller sct){
        accId = sct.getId();
        outletRecordTypeId = FSConstants.RECORD_TYPE_OUTLET;
        this.currentSelectedOutletIds = new Set<Id>();
        this.allSelectedOutletIds = new Set<Id>();
        populateOutlets();
    }
    
    //-----------------------------------------------------------------------------------------------
    // Page Action called on add Current Selection
    //-----------------------------------------------------------------------------------------------
    public Pagereference addCurrentSelection(){
        updateCurrentSelection();
        if(!currentSelectedOutletIds.isEmpty()){
            allSelectedOutletIds.addALL(currentSelectedOutletIds.clone());
            currentSelectedOutletIds = new Set<Id>();
        }
        return null;
    }
    
    //-----------------------------------------------------------------------------------------------
    // Populates the outlet list from the standard set controller
    //-----------------------------------------------------------------------------------------------
    private void populateOutlets(){
        outletList = new List<OutletWrapper>();
        for(Account a : (List<Account>)setCon.getRecords()) {
            if(this.currentSelectedOutletIds.contains(a.Id)) {
                outletList.add(new OutletWrapper(a, true));
            }
            else{
                outletList.add(new OutletWrapper(a, false));
            }
        }
    }
    
    //-----------------------------------------------------------------------------------------------
    // Page Action called on Search Button
    //-----------------------------------------------------------------------------------------------
    public void searchOutlet(){
        //resetSearchStatus();
        updateCurrentSelection();   
        sortField = DEFAULT_SORT_FIELD;
        previousSortField = DEFAULT_SORT_FIELD;
        isAsc = true;
        setCon = CONTROL;
        populateOutlets();
    }   
    
    //-----------------------------------------------------------------------------------------------
    // Helper Method Update the current Selection Set
    //-----------------------------------------------------------------------------------------------
    private void updateCurrentSelection() {
        currentSelectedOutletIds.clear();
        for(OutletWrapper wrapperObject : outletList) {
            if(wrapperObject.isChecked) {
                currentSelectedOutletIds.add(wrapperObject.outlet.Id);
            }
            else{
                currentSelectedOutletIds.remove(wrapperObject.outlet.Id);
            }
        }
    }
    
    //-----------------------------------------------------------------------------------------------
    // Initiate Execute Plan on Finish Button
    //-----------------------------------------------------------------------------------------------
    public pageReference finish(){
        PageReference pageRef;
        updateCurrentSelection();
        addCurrentSelection();
        if(allSelectedOutletIds.isEmpty()){
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No Outlet is selected.'));			        
        }        
        
        final List<Account> lstUpdateOutlet = new List<Account>();
        Account acc;
        
        if(FSUtil.checkAccessForSobject('Account', FSConstants.ACCESS_IS_UPDATEABLE)) {
            for(String aId : allSelectedOutletIds) {
                acc = new Account(Id = aId);
                FSUtil.putValueInField(acc, 'Account' , 'FS_Approved_For_Execution_Plan__c', true);
                FSUtil.putValueInField(acc, 'Account' , 'FS_Approval_Date__c', date.today());
                lstUpdateOutlet.add(acc);
            }
            update lstUpdateOutlet;
        }        
        if(accId != FSConstants.NULLVALUE){
            pageRef= new PageReference('/' + accId);
        }
        return pageRef;
    } 
    
    //-----------------------------------------------------------------------------------------------
    // Standard Set Controller fetching the records based on the Size mentioned.
    //-----------------------------------------------------------------------------------------------
    private ApexPages.StandardSetController setCon {
        get{
            if(setCon == FSConstants.NULLVALUE){
                final String queryString = buildSearchQuery();
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(PAGE_SIZE);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
    
    //-----------------------------------------------------------------------------------------------
    // Helper Method for Build SOQL
    //-----------------------------------------------------------------------------------------------
    private String buildSearchQuery(){
        String qry = 'Select FS_ACN__c, Name, ShippingStreet, ShippingState, ShippingCity FROM Account' + 
            ' WHERE FS_Headquarters__c =: accId AND RecordTypeId =:outletRecordTypeId';
        if(!String.isBlank(searchOutletName)){
            qry += ' AND Name LIKE \'%' + searchOutletName + SYMBOL;
        }
        
        if(!String.isBlank(searchOutletACN)){
            qry += ' AND FS_ACN__c LIKE \'%' + searchOutletACN + SYMBOL;
        }
        if(!String.isBlank(searchOutletCity)){
            qry += ' AND ShippingCity LIKE \'%' + searchOutletCity  + SYMBOL;
        }
        if(!String.isBlank(searchOutletState)){
            qry += ' AND ShippingState LIKE \'%' + searchOutletState + SYMBOL;
        }
        qry += ' Order by ' + sortString;
        return qry;
    }   
    
    public void sortData(){
        if (previousSortField.equals(sortField)){
            if(isAsc){     isAsc=false;         }
            else{ 		   isAsc =true; 		}           
        }
        else{
            isAsc = true;
        }
        previousSortField = sortField;
        updateCurrentSelection();   
        setCon = CONTROL;
        populateOutlets();
    }
    
    public String searchOutletName{
        get{
            if(searchOutletName == FSConstants.NULLVALUE){
                return FSConstants.BLANK;
            }
            else {
                return searchOutletName.trim();
            }
        }
        set;
    }
    
    public String searchOutletACN{
        get{
            if(searchOutletACN == FSConstants.NULLVALUE){
                return FSConstants.BLANK;
            }
            else{
                return searchOutletACN.trim();
            }
        }
        set;
    }
    
    public String searchOutletCity{
        get{
            if(searchOutletCity == FSConstants.NULLVALUE){
                return FSConstants.BLANK;
            }
            else{
                return searchOutletCity.trim();
            }
        }
        set;
    }
    
    public String searchOutletState{
        get{
            if(searchOutletState == FSConstants.NULLVALUE){
                return FSConstants.BLANK;
            }
            else{
                return searchOutletState.trim();
            }
        }
        set;
    }
    
    public void resetSearchStatus(){
        searchOutletName = FSConstants.BLANK;
        searchOutletCity = FSConstants.BLANK;
        searchOutletState = FSConstants.BLANK;
        searchOutletACN = FSConstants.BLANK;
    }
    
    public String sortString {
        get{
            if (sortField != FSConstants.NULLVALUE) {
                final String sortOrder = isAsc ? ' ASC ' : ' DESC ';
                return sortField + sortOrder;
            }
            else {
                return DEFAULT_SORT_FIELD;
            }
        }
    }
    
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    } 
    
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    public Integer pageSize {
        get {
            return PAGE_SIZE;
        }
        set; 
    }
    
    public Integer totalPages {
        get {
            return Integer.valueOf(math.ceil(((Decimal)noOfRecords)/PAGE_SIZE));
        }
        set;
    }
    
    public PageReference first() {
        updateCurrentSelection();
        setCon.first();
        populateOutlets();
        return null;
    }
    
    public PageReference last() {
        updateCurrentSelection();
        setCon.last();
        populateOutlets();
        return null;
    }
    
    public PageReference previous() {
        updateCurrentSelection();
        setCon.previous();
        populateOutlets();
        return null;
    }
    
    public PageReference next() {
        updateCurrentSelection();
        setCon.next();
        populateOutlets();
        return null;
    }
    
    //-----------------------------------------------------------------------------------------------
    // Wrpper class for handling selected outlets
    //-----------------------------------------------------------------------------------------------
    public class OutletWrapper {
        public Account outlet{get;set;}
        public Boolean isChecked{get;set;}        
        
        public OutletWrapper(final Account acc, final Boolean flag) {
            this.outlet = acc;
            isChecked = flag;
        }
    }
}