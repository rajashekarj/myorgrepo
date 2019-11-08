/*
Cancel Post Install Marketing form on all levels
Author: 
Date:05/06/2015
*/
global class FSBatchClearPostInsMrktOD implements  Database.Batchable<sObject>, Database.Stateful{

   public String pmid;
   public Set<Id> setInstallationIds;
   
   
   //Constructor
   public FSBatchClearPostInsMrktOD (String pmid, Set<Id> setInstallationIds) {
     this.pmid = pmid;
     this.setInstallationIds = setInstallationIds;
   }
   
     /****************************************************************************
    //Start the batch and query
    /***************************************************************************/
    
     global Database.QueryLocator start(Database.BatchableContext BC){
                                
          return Database.getQueryLocator([Select Id,FS_Equip_Type__c,Installation__c From FS_Outlet_Dispenser__c Where Installation__c = :setInstallationIds]);

   }

    /****************************************************************************
    //Process a batch
    /***************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> postInstallList){
    
    List<FS_Outlet_Dispenser__c> ListOD = new List<FS_Outlet_Dispenser__c>();
      FS_Post_Install_Marketing__c PM = (FS_Post_Install_Marketing__c)Database.query(FSUtil.getSelectQuery('FS_Post_Install_Marketing__c') + ' where id=:pmid')[0];
        
     for(FS_Outlet_Dispenser__c OD : (List<FS_Outlet_Dispenser__c >)postInstallList){
         if(PM.FS_Enable_Consumer_Engagement__c != null){
                OD.FS_CE_Enabled_New__c=null;
                OD.FS_CE_Enabled_Effective_Date__c=null;
            }
            
            if(PM.FS_FAV_MIX__c != null){
                //OD.FS_FAV_MIX_New__c=null;
                OD.FS_FAV_MIX_Effective_Date__c=null;    
            }
            
            if(PM.FS_LTO__c != null){
                OD.FS_LTO_New__c=null;
                OD.FS_LTO_Effective_Date__c=null;            
            }
           
            if(PM.FS_Promo_Enabled__c != null){
                OD.FS_Promo_Enabled_New__c=null;
                OD.FS_Promo_Enabled_Effective_Date__c=null;
             }
           
            ListOD.add(OD);
        }
        
        try{
         Update ListOD;
         }
         Catch(Exception ex)
         {      
         }


        
      
 
    }

     /****************************************************************************
    //finish the batch
    /***************************************************************************/
    global void finish(Database.BatchableContext BC){
    
    }
    

}