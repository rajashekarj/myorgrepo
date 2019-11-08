/**************************************************************************************
Apex Class Name     : FSCopyEPTIToInstallationsSearchExtension
Version             : 1.0
Function            : This is an Extension class for FSCopyEPTIToInstallationsSearch VF, which shows the list of Installations for 
					  to select and update those particular Technician Instruction records with the current Technician Instruction record data
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkat FET 4.0     11/23/2016          Original Version
* Venkat FET 5.0	  02/09/2018		  Updated  Version
*************************************************************************************/

public class FSCopyEPTIToInstallationsSearchExtension {    
    
    //variable used in page.     
    public static final Integer PAGE_SIZE = 20;
    public static final String CLASSNAME='FSCopyEPTIToInstallationsSearchExtension';
    public static final String METHODNAME='createTIIP';
    public FS_EP_Technician_Instructions__c newTIEP;
    public PageReference page;
    public List<FS_IP_Technician_Instructions__c> ipTI,updateIPTI;
    public static final object OBJECTNULL= null; 
    public static final ApexPages.StandardSetController PAGENULL= null;
    public String platformType;
    public List <WrapperClass> installList;
    public Map<Id,FS_IP_Technician_Instructions__c> mapIPTI;
    public Id epTIId{get;set;}
    public Integer noOfRecords{get; set;} 
    public List <WrapperClass> wrapperRecordList{get;set;}
    public Map<Id, WrapperClass> mapHoldSelectedIP{get;set;}   
    public Set<Id> listIds{get;set;}
    
     //constructor calling init method.
    public FSCopyEPTIToInstallationsSearchExtension(final Apexpages.Standardcontroller controller){
         //initialize the collections
        newTIEP=new FS_EP_Technician_Instructions__c();
        mapHoldSelectedIP = new Map<Id, WrapperClass>();
        listIds=new Set<Id>();
        //get Technician Instructions record Id
        epTIId=controller.getId();  
        //query the EP Technician Instructions record details
        newTIEP=database.query(FSUtil.getSelectQuery('FS_EP_Technician_Instructions__c') + ' Where id=:epTIId limit 1'); 
        //get the Technician Instructions Platform type value
        platformType=newTIEP.FS_Platform_Type__c; 
        init();
    }
  
    //Init method which queries the records from standard set controller.
    public void init() {
        wrapperRecordList = new List<WrapperClass>();
        for (FS_Installation__c cont : (List<FS_Installation__c>)setCon.getRecords()) {
            if(mapHoldSelectedIP != OBJECTNULL && mapHoldSelectedIP.containsKey(cont.id)){
                wrapperRecordList.add(mapHoldSelectedIP.get(cont.id));                
            }
            else{
                wrapperRecordList.add(new WrapperClass(cont, false));
            }
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
				the execution plan related to the current Technician Instruction record
	Modified: Venkat FET 5.0 JIRA:136
	*******************************************************************/
    public String buildSearchQuery(){
        String querry='';
        String query='';         
        query+='SELECT Id,Name,FS_Outlet__r.Name,Outlet_ACN__c,FS_Outlet_Address__c,recordTypeId,';
        query+='FS_Execution_Plan_Final_Approval_PM__c,Type_of_Dispenser_Platform__c,FS_Execution_Plan__r.FS_PM__c,FS_Execution_Plan_Final_Approval__c from FS_Installation__c';
        querry = query+' WHERE FS_Execution_Plan__c = \''+newTIEP.Execution_Plan__c+'\'  AND RecordTypeId=\''+FSInstallationValidateAndSet.ipNewRecType +'\' AND FS_Overall_Status__c!=\''+FSConstants.IPCANCELLED+'\' AND Type_of_Dispenser_Platform__c INCLUDES (\''+platformType+'\')';      
        if(!String.isBlank(searchOutletName)){
            querry +=' AND Name LIKE \'%' + searchOutletName + '%\'';
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
            if(searchOutletName == OBJECTNULL){
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
  	Method: cancelTIIP
  	Description: cancelTIIP method is to get the user back to the Technician instruction record 				
	*******************************************************************/
    public Pagereference cancelTIIP(){
        page = new PageReference('/'+ epTIId);
        page.setRedirect(true);        
        return page;
    }
    
    /*****************************************************************
  	Method: createTIIP
  	Description: createTIIP method is used to copy the current Technician Instruction record data 
			   to the selected Installation related Technician Instruction records based on the record type of the 
				current Technician Instruction and the related Execution plan record of it
	Modified: Venkat FET 5.0 JIRA:136
	*******************************************************************/
 
    public Pagereference createTIIP(){
        updateSearchItemsMap();              
        SavePoint savePosition;   //Save Point Variable
        Apex_Error_Log__c errorRec; //Apex error logger variable
        FS_IP_Technician_Instructions__c OLDTIIP;
        installList = new List<WrapperClass>();
         //collection to store installation Technician Instruction        
        ipTI=new List<FS_IP_Technician_Instructions__c>();
       //collection to store updated Technician Instruction  of installation
        updateIPTI=new List<FS_IP_Technician_Instructions__c>();
        //map to store Technician Instruction  records with installation id
        mapIPTI=new Map<Id,FS_IP_Technician_Instructions__c>();
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
                final Id EPID=newTIEP.Execution_Plan__c;                
                //query for execution plan record
                final List<FS_Execution_Plan__c> execPlan=database.query(FSUtil.getSelectQuery('FS_Execution_Plan__c') +' Where Id=:EPID');
                //list of records of equipment package records with selected installations
                ipTI=database.query(FSUtil.getSelectQuery('FS_IP_Technician_Instructions__c') + ' Where FS_Instalation_Process__c IN :listIds and FS_Platform_Type__c=:platformType');  
                 //storing installation equipment in map
                for(FS_IP_Technician_Instructions__c listTI:ipTI){
                    mapIPTI.put(listTI.FS_Instalation_Process__c,listTI);
                }
                if(mapIPTI!=FSConstants.NULLVALUE){
                    //copies the execution plan tech instruction to installation tech instruction
                    for(Id install:listIds){ 
                        if(mapIPTI.get(install)!=FSConstants.NULLVALUE){
                            OLDTIIP=FSCopyEPIPHelperClass.copyTechData(mapIPTI.get(install),newTIEP);
                            updateIPTI.add(OLDTIIP); 
                        }
                    }
                    //update the installation tech instruction
                    if(!updateIPTI.isEmpty()){
                        errorRec=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                           Method_Name__c=METHODNAME,Object_Name__c='FS_IP_Technician_Instructions__c',
                                                           Error_Severity__c=FSConstants.MediumPriority);
                        update updateIPTI;
                    }
                    //query to store all selected installation records 
                    selectedIPList=database.query(FSUtil.getSelectQuery('FS_Installation__c') + ' Where Id IN :listIds');
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
                    //page reference to the tech instruction record of execution plan
                    page= cancelTIIP();                        
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,FSConstants.ERRORMESSAGEIPSELECTION));              
            }
        }
        catch(DMLException ex){
            Database.rollback(savePosition);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
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