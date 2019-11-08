/*
Cancel Flavour Changes form on all levels
Author: 
Date:05/06/2015
*/
global class FSBatchCancelValidFill implements  Database.Batchable<sObject>, Database.Stateful{
    
    public String cancelId;
    public String vfid;
    public Set<Id> setoutletIds = new Set<Id>();
    
    //Constructor
    public FSBatchCancelValidFill(String cancelId) {
        this.cancelId =cancelId;
        this.vfid=cancelId;
    }
    
    /****************************************************************************
//Start the batch and query
/***************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        cancelId =[SELECT FS_RcdIDForCncl__c FROM FS_Valid_Fill__c WHERE id=:cancelId].FS_RcdIDForCncl__c;  
        
        return Database.getQueryLocator([Select Id,FS_Cancel_Valid_Fill__c,FS_Outlet__c,FS_Installation__c,FS_RcdIDForCncl__c From FS_Valid_Fill__c Where FS_RcdIDForCncl__c=:cancelId AND FS_RcdIDForCncl__c!='']);
        
    }
    
    /****************************************************************************
//Process a batch
/***************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> validFillList){
        List<FS_Valid_Fill__c> lstCancelVF= new List<FS_Valid_Fill__c>();
        List<FS_Valid_Fill__c> vflist;
        Set<Id> IDSet=new Set<Id>(); 
        for(FS_Valid_Fill__c  vf:(List<FS_Valid_Fill__c >)validFillList){
            IDSet.add(vf.id);
        }
        vflist= Database.query(FSUtil.getSelectQuery('FS_Valid_Fill__c') + ' where id=:IDSet');
        for(FS_Valid_Fill__c ValidFill : vflist){
            ValidFill.FS_Cancel_Valid_Fill__c=true; 
            lstCancelVF.add(ValidFill);         
            if(ValidFill.FS_Outlet__c != null){
                setoutletIds.add(ValidFill.FS_Outlet__c);
            }
        }
        try{
            if(!lstCancelVF.isEmpty()){
                Update lstCancelVF;
            }
        }
        Catch(Exception ex)
        {
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSBatchCancelValidFill','Execute','Valid Fill',FSConstants.MediumPriority,ex,'NA');
            
        }
        
    }
    
    /****************************************************************************
//finish the batch
/***************************************************************************/
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(New FSBatchClearValidFillOD (vfid, setoutletIds),200);
    }
}