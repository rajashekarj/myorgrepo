/**************************************************************************************
Apex Class Name     : FSHomePageAlerts
Version             : 1.0
Function            : This is an Controller class for FSHomePageApprovalAlert VF, which shows the list of 
					  tasks created for that particular user, so that user can take some action on thsoe.
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata             01/12/2017          Original Version
*************************************************************************************/


public class FSHomePageAlerts {
    @TestVisible
    private String sortOrder = 'CreatedDate';
    @TestVisible
    private String sortDirection = ' DESC';    
    public String strDESC=' DESC';    
    public static integer valueAssign=0;
    public FSPaginationCustomIterableAlerts pageNat;    
    public List<Task> taskList,taskMainList;
    public Set<Id> cifIdSet,exePlanIdSet,installIdSet,removalIPIdSet;
    public Set<String> setOfsObjects,setOftaskStatus,setOfSubjects;    
    public List<FS_CIF__c> cifApprovalList;	   
    public integer PageSize {get;set;}
    public integer RecordCount {get;set;}    
    public List<Task> setlstTask {get;set;}
    public Map<String,String> executionPlanMap{get;set;}
    public Map<String,String> cifHeader{get;set;}
    public Map<String,String> davacoMap{get;set;}
    public Map<String,String> executionMap{get;set;}   
    
    public static Object nullVal() { return null; }
    
    /*****************************************************************
  Method: tasksList
  Description: tasksList method used to list down the tasks assigned to the particular user
				on his home page. so that user can open the tasks and take concern action on the task
*******************************************************************/

    public void tasksList() { 
        //initialize the collections
        taskList=new List<Task>();        
        setlstTask= new List<Task>();
        //collections to store the whatId and their respective details
        cifHeader=new Map<String,String>();        
        davacoMap=new Map<String,String>();
        executionPlanMap=new Map<String,String>();
        executionMap=new Map<String,String>();	
        //collections to store the Ids of different Sobject records from task list
        cifIdSet=new Set<Id>();
        exePlanIdSet=new Set<Id>();
        installIdSet=new Set<id>();        
        removalIPIdSet=new Set<Id>();        
        //get the ownerId
        final ID OWNERID = userinfo.getUserId(); 
        //Collection to store the Sobjects names
        setOfsObjects=new Set<String>{FSConstants.FLAVORHEADOBJECTNAME,FSConstants.INSTALLATIONOBJECTNAME,FSConstants.CIFLINEOBJECTNAME,FSConstants.EXECUTIONPLANOBJECTNAME};
        //collection to store the task status names
        setOftaskStatus=new Set<String>{'Open','In Progress','Not Started'};
        //collection to store the subject of the task to retreive
        setOfSubjects = new Set<String>{'FC SCHDLD date needed%','FC Rejected%','FC Closeout needed%','FC Readiness needed%','EP Created','EP APV Requested','IP Ready for Schd','FC APV STS Updated','Survey Approved','Survey Results Back'};
        //Query for the task list               
        String query='SELECT Id,FS_Action__c,subject,OwnerId,status,TaskSubtype,whatId,What.Type,what.name,CreatedDate FROM TASK ';
        query=query +'WHERE What.Type IN:setOfsObjects AND status IN:setOftaskStatus AND Subject LIKE:setOfSubjects AND Ownerid =: OWNERID';
        query=query + ' ORDER BY '+ sortOrder + sortDirection +' Limit 5000' ;
        
        taskList = (List<Task>)Database.query(query);        
        //iterating the task list to get the Ids of the records based on the Type of task
        for(Task taskItem:taskList){ 
            if(taskItem.What.Type==FSConstants.INSTALLATIONOBJECTNAME){
                installIdSet.add(taskItem.whatId);
            }
            if(taskItem.What.Type==FSConstants.CIFLINEOBJECTNAME){
                cifIdSet.add(taskItem.whatId);
            }
            if(taskItem.What.Type==FSConstants.EXECUTIONPLANOBJECTNAME){
                exePlanIdSet.add(taskItem.whatId);
            }				
        }    
        //Soql of Installation records to get the details of the execution plan linked to it
        final List<FS_Installation__c> installList=[Select Id,FS_Execution_Plan__r.FS_Execution_Plan__c,FS_Execution_Plan_Final_Approval_PM__c,FS_Ready_For_PM_Approval__c ,RecordType.Name From FS_Installation__c where Id IN:installIdSet];
        for(FS_Installation__c installation:installList){
            executionPlanMap.put(installation.Id,installation.FS_Execution_Plan__r.FS_Execution_Plan__c);
            executionMap.put(installation.Id,installation.FS_Execution_Plan__c); 
            if(installation.FS_Execution_Plan_Final_Approval_PM__c!=nullVal()){
                removalIPIdSet.add(installation.Id);			
            }
        }  
        //Soql of CIF records to get the details of the Account and CIF Header linked to it
        final List<FS_CIF__c> cifApprovalList = [Select Id,FS_Account__r.FS_ACN__c,CIF_Head__r.Name,CIF_Head__c,CIF_Head__r.FS_EP__c,FS_Customer_s_disposition_after_review__c from FS_CIF__c where Id IN:cifIdSet];
        for(FS_CIF__c cif:cifApprovalList){
            executionPlanMap.put(cif.Id,cif.CIF_Head__r.Name);
            davacoMap.put(cif.Id,cif.FS_Account__r.FS_ACN__c); 
            cifHeader.put(cif.id,cif.CIF_Head__c);                    
        } 
        //Soql of Execution Plan records to get the further details of Execution Plan
        final List<FS_Execution_Plan__c> exePlanList=[select id,FS_Execution_Plan__c from FS_Execution_Plan__c where Id IN:exePlanIdSet];
        //storing the execution plan id and 
        for(FS_Execution_Plan__c exePlan:exePlanList){
            executionPlanMap.put(exePlan.Id,exePlan.FS_Execution_Plan__c);
            executionMap.put(exePlan.Id,exePlan.Id);
            davacoMap.put(exePlan.Id,exePlan.FS_Execution_Plan__c); 		
        }         
        taskMainList=new List<Task>();
        //Iterating Task List for the final List to display based on the conditions
        for(Task taskItem:taskList){
            //adding all CIF,Execution plan and Flavor change task
            if(taskItem.what.type==FSConstants.FLAVORHEADOBJECTNAME || taskItem.what.type==FSConstants.CIFLINEOBJECTNAME ||
               taskItem.what.type==FSConstants.EXECUTIONPLANOBJECTNAME){
                   taskMainList.add(taskItem);			
               }
            //adding Installation task to the list based on the conditions
            // if "EP APV Requested" task IP is already approved/rejected, we are not adding those IP to the list
            if(((taskItem.subject=='EP APV Requested' && !removalIPIdSet.contains(taskItem.whatId)) || 
                taskItem.subject=='IP Ready for Schd' ) && taskItem.what.type==FSConstants.INSTALLATIONOBJECTNAME){
                    taskMainList.add(taskItem);			
                }           		
        }            
        pageNat = new FSPaginationCustomIterableAlerts(taskMainList);
        pageNat.setPageSize = 10;
        nextPN();       
    } 
    
    //pagination Methods   
    public integer PageCountPN {
        get{return pageNat.PageCount;}
        set;
    }
    public integer PageNumberPN {
        get{return pageNat.PageNumber;}
        set;
    }
    public integer LNumberPN {
        get{return pageNat.LNumber;}
        set;
    }
    public integer UNumberPN {
        get{return pageNat.UNumber;}
        set;
    }
    public integer RecordCountPN {
        get{return pageNat.RecordCount;}
        set;
    }
    
    public void defineSortDirection(){
        if(sortDirection==strDESC){
            sortDirection=' ASC';
        }
        else{
            sortDirection=' DESC';
        }
    }
    public void sortByCreatedDate() {
        this.sortOrder = 'CreatedDate';
        defineSortDirection();
        tasksList();
    }
    public void sortByName() {
        this.sortOrder = 'what.name';
        defineSortDirection();
        tasksList();
    }
    public Boolean hasNextPN {
        get{return pageNat.hasNext();}
        set;
    }
    public Boolean hasFirstPN {
        get{return pageNat.hasPrevious();}
        set;
    }
    public Boolean hasLastPN {
        get{return pageNat.hasNext();}
        set;
    }
    public Boolean hasPreviousPN {
        get{return pageNat.hasPrevious();}
        set;
    }
    public void nextPN(){
        pageNat.PageNumber++; 
        if (pageNat.PageNumber > pageNat.PageCount) {pageNat.PageNumber = pageNat.PageCount;}
        setlstTask = pageNat.next();
    }
    public void firstPN(){        
        pageNat.PageNumber = 1;
        setlstTask = pageNat.first();
    }
    public void previousPN(){
        pageNat.PageNumber--;
        if (pageNat.PageNumber <= valueAssign) {pageNat.PageNumber = 1;}
        setlstTask = pageNat.previous();
    }
    public void lastPN(){     
        pageNat.PageNumber = pageNat.PageCount;
        setlstTask = pageNat.last();
    }
    //pagination Methods  
}