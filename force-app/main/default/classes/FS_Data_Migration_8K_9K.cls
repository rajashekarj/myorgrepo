global with sharing class FS_Data_Migration_8K_9K implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public List<Id> dispenserIds=new List<Id>(); //Added to facilitate single record callout to AW.10th June 2016
    
    public FS_Data_Migration_8K_9K(final List<Id> dispenserIds){
      this.dispenserIds=dispenserIds;
    }
    
    public FS_Data_Migration_8K_9K(){
      
    }
    
    global Database.QueryLocator start(final Database.BatchableContext BC){
        String query;
        if(dispenserIds.isEmpty()){
            query= 'SELECT Id, FS_Outlet__c, FS_ACN_NBR__c '
                        + ' FROM FS_Outlet_Dispenser__c '  
                        + ' WHERE FS_Migration_to_AW_Required__c = TRUE ' 
                        + '   AND FS_Pending_Migration_to_AW__c= TRUE '
                        + '   AND FS_Migration_to_AW_Complete__c = FALSE '
                        + '   AND FS_IsActive__c = TRUE ';
        }
        else{
            query= 'SELECT Id, FS_Outlet__c, FS_ACN_NBR__c '
                        + ' FROM FS_Outlet_Dispenser__c '  
                        + ' WHERE FS_Migration_to_AW_Required__c = TRUE ' 
                        + '   AND FS_Pending_Migration_to_AW__c= TRUE '
                        + '   AND FS_Migration_to_AW_Complete__c = FALSE '
                        + '   AND FS_IsActive__c = TRUE '
                        + '   AND Id IN:dispenserIds ';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(final Database.BatchableContext BC, final List<sObject> scope) {
       try {
            final List<FS_Outlet_Dispenser__c> beList = (List<FS_Outlet_Dispenser__c>)scope;
            final List<FS_Outlet_Dispenser__c> updateOD = new List<FS_Outlet_Dispenser__c> ();
            final Set<Id> setDispenserIds = new Set<Id>();
            
            for(FS_Outlet_Dispenser__c obj : beList) {
                    setDispenserIds.add(obj.Id);
            }
            
            if(beList.size() > 0){
                FSFETNMSConnector.isUpdateSAPIDBatchChange = true;
                FSFETNMSConnector.airWatchSynchronousCall(setDispenserIds,NULL);       
            }
            
            for(FS_Outlet_Dispenser__c updateflag : beList){
                updateflag.FS_Migration_to_AW_Complete__c = true;
                updateOD.add(updateflag);
            }
            
            UPDATE updateOD;        
       } catch(Exception exp) {
            System.debug('FS_Data_Migration_8K_9K#Exception occurred- '+exp);
       }
    }

    global void finish(final Database.BatchableContext BC){
        
    }

}