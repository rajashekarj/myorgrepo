//**************************************************
//Name         : FSGeneralContractorCtrl
//Created By   : Mohit Parnami (Appiro)
//Created Date : 1 - oct - 2013
//Usage        : Controller class of FSGeneralContractor
//Modification Log: venkata as part of FET 4.0
//9th Jan,2019 Modified by: Sai Krishna. Added a new Cancel method for redirection to prev Execution plan record page. Reg: FET 6 Ref:(Jira FNF-115)
// **************************************************
public with sharing class FSGeneralContractorCtrl {
    public static final string ALL='All';
    public static final string COORDINATION='Coordination';
    public static final string RELATEDVENDOR='RelatedVendor';
    public FS_Execution_Plan__c executionPlan {get;set;}    
    public List<FS_Installation__c> lstInstallations{get;set;}
    public string selectedFillDown{get;set;}  
    
    public static object nullValue() { return null; }
    //constructor method to fetch the execution plan record
    public FSGeneralContractorCtrl(final ApexPages.StandardController stdController){
        //getting the execution plan record
        executionPlan = (FS_Execution_Plan__c)stdController.getRecord();        
        init();
    }   
    
        /*****************************************************************
  	Method: init
  	Description: init method is used to get all the installation under the execution plan		
	*******************************************************************/
    public  void init(){
        lstInstallations = new List<FS_Installation__c>();
        //fetching all the installations under the execution plan
        for(FS_Installation__c inst : [select id,Name,FS_Outlet__r.FS_Outlet_Information__c, FS_Related_Vendor__c, FS_GC_Coordination_to_be_done_by__c,
                                       FS_Related_Vendor__r.FS_Vendor_Type__c, FS_Related_Vendor__r.Name, FS_Related_Vendor__r.FS_Vendor_Primary_Contact__c,
                                       FS_Related_Vendor__r.FS_Vendor_Primary_Phone__c, FS_Related_Vendor__r.FS_Vendor_Primary_Email__c,
                                       FS_Related_Vendor__r.FS_Vendor_Secondary_Contact__c, FS_Related_Vendor__r.FS_Vendor_Secondary_Phone__c,
                                       FS_Related_Vendor__r.FS_Vendor_Secondary_Email__c From FS_Installation__c
                                       Where FS_Execution_Plan__c =: executionPlan.Id]){
                                           lstInstallations.add(inst); 
                                       }      
    }
    
     /*****************************************************************
  	Method: saveOutletInfo
  	Description: saveOutletInfo method is to save the outlets and the respective Installation records		
	*******************************************************************/
    public PageReference saveOutletInfo(){ 
        PageReference page;       
        SavePoint savePosition;   //Save Point Variable        
        final List<Account> lstAccountToUpdate = new List<Account>();
        final set<Account> setAccountToUpdate=new Set<Account>();
        
        for(FS_Installation__c ins :lstInstallations){           
            if(ins.FS_Outlet__r != nullValue()){
                setAccountToUpdate.add(ins.FS_Outlet__r);                
            }
        }
        lstAccountToUpdate.addAll(setAccountToUpdate);
        
        //OCR1 Req to bypass Bottler by srini
        FSConstants.BypassOrderDelivery =true;
        try{
            savePosition = Database.setSavePoint();
            //update the account details
            if(!lstAccountToUpdate.isEmpty()){
                update lstAccountToUpdate;             
            }
            //update the installation records
            if(!lstInstallations.isEmpty()){
                update lstInstallations;               
            }     
            page=new PageReference('/' + executionPlan.Id);
        }
        //catching DML Exceptions and rolling back the changes to savepoint state
        catch(DMLException ex){
            apexpages.addMessages(ex);
            Database.rollback(savePosition);			           
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSGeneralContractorCtrl','saveOutletInfo',FSConstants.INSTALLATIONOBJECTNAME,FSConstants.MediumPriority,ex,ex.getMessage());            
        }                     
        return page;
    }
    /*****************************************************************
  	Method: fillDown
  	Description: fillDown method is to fill the same value of the first record to the respective following records		
	*******************************************************************/
   
    public void fillDown(){       
        if (selectedFillDown == ALL){
            for (FS_Installation__c inst :lstInstallations){       
                inst.FS_GC_Coordination_to_be_done_by__c= lstInstallations[0].FS_GC_Coordination_to_be_done_by__c ;
                inst.FS_Related_Vendor__c= lstInstallations[0].FS_Related_Vendor__c ;
            }
        }
        else if (selectedFillDown == COORDINATION){
            for (FS_Installation__c inst :lstInstallations){       
                inst.FS_GC_Coordination_to_be_done_by__c= lstInstallations[0].FS_GC_Coordination_to_be_done_by__c ;
            }
        }
        else if (selectedFillDown == RELATEDVENDOR){
            for (FS_Installation__c inst :lstInstallations){       
                inst.FS_Related_Vendor__c= lstInstallations[0].FS_Related_Vendor__c ;
            }
        }     
    }
    /*****************************************************************
  	Method: cancel
  	Description: cancel method helps the user return back to the execution plan record  
	*******************************************************************/
    public PageReference cancel(){
        PageReference pageRef;
        if(executionPlan.Id!= Null){
            pageRef= new PageReference('/' + executionPlan.Id);
        }
        return pageRef;        
    } 
}