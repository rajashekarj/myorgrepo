/**************************************************************************************
Apex Class Name     : FSCopyEPIPAccountTeamInfoExtension
Version             : 1.0
Function            : This is an Extension class for FSCopyEPIPAccountTeamInfo VF, which shows the list of Installations for 
to select and update the selected Installation records with Account Team info
Modification Log    :
* Developer         :    Date              Description
* ---------------------------------------------------------------------------- 
* Venkat FET 5.2	  		 09/05/2018		  	 Initial  Version
*************************************************************************************/

public class FSCopyEPIPAccountTeamInfoExtension{    
    //variable used in page.      
    
    public static final Integer PAGE_SIZE = 20;
    public static final String CLASSNAME='FSCopyEPIPAccountTeamInfoExtension';
    public static final String METHODNAME='copyEPIPAccountTeam';    
    public PageReference page;        
    public static final ApexPages.StandardSetController PAGENULL= null;
    public Id exePlanId;    
    public List <FS_Installation__c> installList;  
    public Integer noOfRecords{get; set;} 
    public List <WrapperClass> wrapperRecordList{get;set;}
    public Map<Id, WrapperClass> mapHoldSelectedIP{get;set;}   
    public Set<Id> listIds{get;set;}
    
    //constructor calling init method.
    public FSCopyEPIPAccountTeamInfoExtension(final Apexpages.Standardcontroller controller){
        //initialize the collections        
        mapHoldSelectedIP = new Map<Id, WrapperClass>();
        listIds=new Set<Id>();
        //get Execution Plan record Id
        exePlanId=controller.getId();      
        init();                     
    }
    
    //Init method which queries the records from standard set controller.
    public void init() {
        try{
            wrapperRecordList = new List<WrapperClass>();
            for (FS_Installation__c cont : (List<FS_Installation__c>)setCon.getRecords()) {
                if(mapHoldSelectedIP != FSConstants.NULLVALUE && mapHoldSelectedIP.containsKey(cont.id)){
                    wrapperRecordList.add(mapHoldSelectedIP.get(cont.id));                
                }
                else{
                    wrapperRecordList.add(new WrapperClass(cont, false));
                }
            }
        }
        catch(QueryException ex){
            ApexPages.addMessages(ex);
        }
    }
    
    /** Instantiate the StandardSetController from a query locater*/
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == PAGENULL) {
                final string queryString = buildSearchQuery();
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));                
                // sets the number of records to show in each page view
                setCon.setPageSize(PAGE_SIZE);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }
        set;
    }
    /*****************************************************************
Method: buildSearchQuery
Description: buildSearchQuery method is used to return the query for to get the list of Installations linked to 
the execution plan 
*******************************************************************/
    public String buildSearchQuery(){
        String querry='';
        String query='';         
        query+='SELECT Id,Name,FS_Outlet__r.Name,Outlet_ACN__c,FS_Outlet_Address__c,recordTypeId,Overall_Status2__c,FS_Execution_Plan__r.FS_Sales_Lead__c,FS_Execution_Plan__r.FS_PIC__c,';
        query+='FS_Execution_Plan_Final_Approval_PM__c,Type_of_Dispenser_Platform__c,FS_Execution_Plan__r.FS_PM__c,FS_Execution_Plan__r.FS_Back_up_COM__c from FS_Installation__c';
        querry = query+' WHERE FS_Execution_Plan__c = \''+exePlanId+'\' AND RecordTypeId=\''+FSInstallationValidateAndSet.ipNewRecType +'\' AND FS_Overall_Status__c!=\''+FSConstants.IPCANCELLED+'\'';   
        if(!String.isBlank(searchInstallName)){
            querry += ' AND Name LIKE \'%' + searchInstallName + '%\'';
        }       
        return querry;
    }    
    
    
    //search method for searching of IP by Name
    public void searchOutlet(){
        this.mapHoldSelectedIP.clear();
        updateSearchItemsMap();        
        setCon = PAGENULL;
        init();        
    }
    //assigns the outlet name which in search scenario
    public String searchInstallName{
        get{
            if(searchInstallName == FSConstants.NULLVALUE){
                return '';
            }
            else {
                return searchInstallName.trim();
            }
        }
        set;
    }   
    //Pagination methods
    /** indicates whether there are more records after the current page set.*/
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    /** indicates whether there are more records before the current page set.*/
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    /** returns the page number of the current page set*/
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
    
    /** return total number of pages for page set*/
    Public Integer getTotalPages(){
        final Decimal totalSize = setCon.getResultSize();
        final Decimal pageSize = setCon.getPageSize();
        final Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    /** returns the first page of the page set*/
    public void first() {
        updateSearchItemsMap();
        setCon.first();
        init();
    }
    
    /** returns the last page of the page set*/
    public void last() {
        updateSearchItemsMap();
        setCon.last();
        init();
    }
    
    /** returns the previous page of the page set*/
    public void previous() {
        updateSearchItemsMap();
        setCon.previous();
        init();
    }
    
    /** returns the next page of the page set*/
    public void next() {
        updateSearchItemsMap();
        setCon.next();
        init();
    }
    
    //This is the method which manages to remove the deselected records, and keep the records which are selected in map.
    private void updateSearchItemsMap() {
        for(WrapperClass wrp : wrapperRecordList){
            if(wrp.isSelected){
                mapHoldSelectedIP.put(wrp.installation.id, wrp);
            }
            if(!wrp.isSelected && mapHoldSelectedIP.containsKey(wrp.installation.id)){
                mapHoldSelectedIP.remove(wrp.installation.id);
            }
        }
    }
    //Pagination methods 
    
    /*****************************************************************
Method: cancelEPIP
Description: cancelEPIP method is to get the user back to the Execution Plan record			
*******************************************************************/
    
    public Pagereference cancelEPIP(){
        page = new PageReference('/'+ exePlanId);
        page.setRedirect(true);        
        return page;
    }  
    
    /*****************************************************************
Method: copyEPIPAccountTeam
Description: Method to Copy Account Team Info From Execution Plan to selected Installations
*******************************************************************/
    
    public Pagereference copyEPIPAccountTeam(){        
        updateSearchItemsMap();
        Apex_Error_Log__c errorRec; //Apex error logger variable
        SavePoint savePosition;   //Save Point Variable        
        installList = new List<FS_Installation__c>();  
        
        for(WrapperClass ow : wrapperRecordList){
            if(this.mapHoldSelectedIP.containskey(ow.installation.Id)){                
                installList.add(ow.installation);
            }
        }
        try{
            if(!installList.isEmpty()){
                savePosition = Database.setSavePoint();
                for(FS_Installation__c install:installList){                                      
                    install.FS_COM_Regular__c=install.FS_Execution_Plan__r.FS_Back_up_COM__c;
                    install.FS_PM_Regular__c=install.FS_Execution_Plan__r.FS_PM__c;
                    install.FS_Installation_PC_AC_1__c=install.FS_Execution_Plan__r.FS_PIC__c;
                    install.FS_Sales_Lead__c=install.FS_Execution_Plan__r.FS_Sales_Lead__c;
                }
                update installList;
                //page reference to execution plan record
                page= cancelEPIP();                        
                
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,FSConstants.ERRORMESSAGEIPSELECTION));              
            }
        }
        catch(DMLException ex){
            Database.rollback(savePosition);
            ApexPages.addMessages(ex);            
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,CLASSNAME,METHODNAME,FSConstants.INSTALLATIONOBJECTNAME,FSConstants.MediumPriority,ex,ex.getMessage());
        }
        catch(QueryException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return page;         
    }   
    
    
    //wrapper class being used for to store the checkbox selection status of the records.
    public class WrapperClass {
        public Boolean isSelected {get;set;}
        public FS_Installation__c installation {get;set;}
        public WrapperClass(final FS_Installation__c installation, final Boolean isSelected) {
            this.installation = installation;
            this.isSelected = isSelected;
        }
    }    
}