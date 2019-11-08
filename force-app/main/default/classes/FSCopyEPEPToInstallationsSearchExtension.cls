/**************************************************************************************
Apex Class Name     : FSCopyEPEPToInstallationsSearchExtension
Version             : 1.0
Function            : This is an Extension class for FSCopyEPEPToInstallationsSearch VF, which shows the list of Installations for 
to select and update those particular Equipment package records with the current Equipment Package record data
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkat FET 4.0            11/23/2016          Original Version
* Venkat FET 5.0	  		 02/09/2018		  	 Updated  Version
*************************************************************************************/

public class FSCopyEPEPToInstallationsSearchExtension{    
    //variable used in page.      
    
    public static final Integer PAGE_SIZE = 20;
    public static final String CLASSNAME='FSCopyEPEPToInstallationsSearchExtension';
    public static final String METHODNAME='createEPIP';
    public FS_EP_Equipment_Package__c newEPEP;
    public PageReference page;
    public List<FS_IP_Equipment_Package__c> ipEP,updateIPEP;    
    public static final ApexPages.StandardSetController PAGENULL= null;
    public String platformType;
    public List <WrapperClass> installList;
    public Map<Id,FS_IP_Equipment_Package__c> mapIPEP;
    public Id epEPId{get;set;}
    public Integer noOfRecords{get; set;} 
    public List <WrapperClass> wrapperRecordList{get;set;}
    public Map<Id, WrapperClass> mapHoldSelectedIP{get;set;}   
    public Set<Id> listIds{get;set;}
    
    //constructor calling init method.
    public FSCopyEPEPToInstallationsSearchExtension(final Apexpages.Standardcontroller controller){
        //initialize the collections
        newEPEP=new FS_EP_Equipment_Package__c();
        mapHoldSelectedIP = new Map<Id, WrapperClass>();
        listIds=new Set<Id>();
        //get equipment package record Id
        epEPId=controller.getId();        
        //query the EP Equipment package record details
        newEPEP=database.query(FSUtil.getSelectQuery('FS_EP_Equipment_Package__c') + ' Where id=:epEPId limit 1'); 
        //get the Equipment package Platform type value
        platformType=newEPEP.FS_Platform_Type__c;
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
the execution plan related to the current Equipment package record
Modified: Venkat FET 5.0 JIRA: 135
*******************************************************************/
    public String buildSearchQuery(){
        String querry='';
        String query='';         
        query+='SELECT Id,Name,FS_Outlet__r.Name,Outlet_ACN__c,FS_Outlet_Address__c,recordTypeId,';
        query+='FS_Execution_Plan_Final_Approval_PM__c,Type_of_Dispenser_Platform__c,FS_Execution_Plan__r.FS_PM__c,FS_Execution_Plan_Final_Approval__c from FS_Installation__c';
        querry = query+' WHERE FS_Execution_Plan__c = \''+newEPEP.FS_Execution_Plan__c+'\' AND RecordTypeId=\''+FSInstallationValidateAndSet.ipNewRecType +'\' AND FS_Overall_Status__c!=\''+FSConstants.IPCANCELLED+'\' AND Type_of_Dispenser_Platform__c INCLUDES (\''+platformType+'\')';   
        if(!String.isBlank(searchOutletName)){
            querry += ' AND Name LIKE \'%' + searchOutletName + '%\'';
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
    public String searchOutletName{
        get{
            if(searchOutletName == FSConstants.NULLVALUE){
                return '';
            }
            else {
                return searchOutletName.trim();
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
Description: cancelEPIP method is to get the user back to the Equipment package record 				
*******************************************************************/
    
    public Pagereference cancelEPIP(){
        page = new PageReference('/'+ epEPId);
        page.setRedirect(true);        
        return page;
    }  
    
    /*****************************************************************
Method: createEPIP
Description: createEPIP method is used to copy the current equipment package record data 
to the selected Installation related Equipment package records based on the record type of the 
current Equipment Package and the related Execution plan record of it
Modified: Venkat FET 5.0 JIRA:135
*******************************************************************/
    
    public Pagereference createEPIP(){        
        updateSearchItemsMap();
        Apex_Error_Log__c errorRec; //Apex error logger variable
        SavePoint savePosition;   //Save Point Variable
        FS_IP_Equipment_Package__c OLDEPIP;
        installList = new List<WrapperClass>();
        //collection to store installation equipment package        
        ipEP=new List<FS_IP_Equipment_Package__c>();
        //collection to store updated equipment records of installation
        updateIPEP=new List<FS_IP_Equipment_Package__c>();
        //map to store equipment packages records with installation id
        mapIPEP=new Map<Id,FS_IP_Equipment_Package__c>();
        //collection to store the installation list
        List<FS_Installation__c> selectedIPList=new List<FS_Installation__c>();
        //collection to store the updated installation list
        List<FS_Installation__c> updateInstallList=new List<FS_Installation__c>();
        
        for(WrapperClass ow : wrapperRecordList){
            if(this.mapHoldSelectedIP.containskey(ow.installation.Id)){
                listIds.add(ow.installation.Id);
                installList.add(new WrapperClass(ow.installation,true));
            }
        }
        try{
            if(!listIds.isEmpty()){
                savePosition = Database.setSavePoint();
                //fetch execution plan Id
                final Id EPID=newEPEP.FS_Execution_Plan__c;                
                //query for execution plan record
                final List<FS_Execution_Plan__c> execPlan=database.query(FSUtil.getSelectQuery(FSConstants.EXECUTIONPLANOBJECTNAME) +' Where Id=:EPID');
                //list of records of equipment package records with selected installations
                ipEP=database.query(FSUtil.getSelectQuery('FS_IP_Equipment_Package__c') + ' Where FS_Installation__c IN :listIds and FS_Platform_Type__c=:platformType');
                
                //storing installation equipment in map
                for(FS_IP_Equipment_Package__c listEP:ipEP){
                    mapIPEP.put(listEP.FS_Installation__c,listEP);
                }
                if(mapIPEP!=FSConstants.NULLVALUE){
                    //copies the execution plan equipment package to installation equipment package
                    for(Id install:listIds){ 
                        if(mapIPEP.get(install)!=FSConstants.NULLVALUE){
                            OLDEPIP=FSCopyEPIPHelperClass.copyEquipment(mapIPEP.get(install),newEPEP);
                            updateIPEP.add(OLDEPIP); 
                        }
                    }
                    
                    //update the installation quipment package
                    if(!updateIPEP.isEmpty()){ 
                        errorRec=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                       Method_Name__c=METHODNAME,Object_Name__c='FS_IP_Equipment_Package__c',
                                                       Error_Severity__c=FSConstants.MediumPriority);
                        update updateIPEP;
                    } 
                    //query to store all selected installation records 
                	selectedIPList=database.query(FSUtil.getSelectQuery(FSConstants.INSTALLATIONOBJECTNAME) + ' Where Id IN :listIds');
                
                    //copies the execution plana data to selected installations
                    if(!execPlan.isEmpty()){                        
                        updateInstallList=FSCopyEPIPHelperClass.copyEPtoInstallation(selectedIPList,execPlan[0]);
                    }
                    //updates the installation records
                    if(!updateInstallList.isEmpty()){ 
                        errorRec=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                       Method_Name__c=METHODNAME,Object_Name__c=FSConstants.INSTALLATIONOBJECTNAME,
                                                       Error_Severity__c=FSConstants.MediumPriority);
                        update updateInstallList;
                    }
                    //page reference to the euipment package record of execution plan
                    page= cancelEPIP();                        
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,FSConstants.ERRORMESSAGEIPSELECTION));              
            }
        }
        catch(DMLException ex){
            Database.rollback(savePosition);
            ApexPages.addMessages(ex);            
            ApexErrorLogger.addApexErrorLog(errorRec.Application_Name__c,errorRec.Class_Name__c, errorRec.Method_Name__c,
                                            errorRec.Object_Name__c,errorRec.Error_Severity__c,ex,ex.getMessage());
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