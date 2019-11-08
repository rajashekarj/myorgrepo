/*
Cancel Valid Fill form on all levels
Author: 
Date:05/06/2015

Modified: Neel 9/28/2018 As part of FET 5.2 FFET 1302. Enable 9100 platform type on valid fill.

*/
global class FSBatchClearValidFillOD implements  Database.Batchable<sObject>, Database.Stateful{
    
    public String vfid;
    public Set<Id> setOutletIds;
    global String validFill7k=Schema.SObjectType.FS_Valid_Fill__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_7k).getRecordTypeId();
    global String validFill8k=Schema.SObjectType.FS_Valid_Fill__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_8k).getRecordTypeId();
    global String validFill9k=Schema.SObjectType.FS_Valid_Fill__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_9k).getRecordTypeId();
    global String validFill91k=Schema.SObjectType.FS_Valid_Fill__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_91k).getRecordTypeId();
    
    
    
    //Constructor
    public FSBatchClearValidFillOD (String vfid, Set<Id> setOutletIds) {
        this.vfid=vfid ;
        this.setOutletIds = setOutletIds;
    }
    
    /****************************************************************************
//Start the batch and query
/***************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select Id,FS_Equip_Type__c,Installation__c,FS_Outlet__c From FS_Outlet_Dispenser__c Where FS_Outlet__c = :setOutletIds]);
        
    }
    
    /****************************************************************************
//Process a batch
/***************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> postInstallList){
        
        List<FS_Outlet_Dispenser__c> ListOD = new List<FS_Outlet_Dispenser__c>();
        FS_Valid_Fill__c VF= (FS_Valid_Fill__c)Database.query(FSUtil.getSelectQuery('FS_Valid_Fill__c') + ' where id=:vfid')[0];
        
        for(FS_Outlet_Dispenser__c OD : (List<FS_Outlet_Dispenser__c >)postInstallList){
            System.debug('ODFS_Equip_Type__c:'+OD.FS_Equip_Type__c);
            
            if((VF.recordtypeid ==validFill7k && OD.FS_Equip_Type__c==FSConstants.RECTYPE_7k) || (VF.recordtypeid ==validFill8k  && OD.FS_Equip_Type__c==FSConstants.RECTYPE_8k) || 
               (VF.recordtypeid ==validFill9k && OD.FS_Equip_Type__c==FSConstants.RECTYPE_9k) || (VF.recordtypeid ==validFill91k && OD.FS_Equip_Type__c==FSConstants.RECTYPE_91k)){
                   if(VF.Valid_Fill_Request_Approval_Status__c!=null){
                       OD.FS_Valid_Fill_New__c=null;
                       OD.FS_Valid_Fill_Settings_Effective_Date__c=null;  
                   }
                   ListOD.add(OD);
               }   
            
        }
        try{
            Update ListOD;
        }
        Catch(Exception ex)
        {
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSBatchClearValidFillOD','Execute','Outlet Dispense',FSConstants.MediumPriority,ex,'NA');
            
        }
        
    }
    
    /****************************************************************************
//finish the batch
/***************************************************************************/
    global void finish(Database.BatchableContext BC){
        
    }
    
    
}