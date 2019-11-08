global class FsUpdateODofDispModelBatch implements Database.batchable <sobject>,Database.AllowsCallouts {
    
    public  String recTypeODInternational=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(Label.INT_OD_RECORD_TYPE).getRecordTypeId();
    
    Map<Id,Dispenser_Model__c> dispModelMap = new Map<Id,Dispenser_Model__c>();
        
    /****************************************************************************
//Constructor
/***************************************************************************/
    global FsUpdateODofDispModelBatch(final Map<Id,Dispenser_Model__c> dispModelMap){
        this.dispModelMap=dispModelMap;
    }    
    
    /****************************************************************************
//Start the batch and query
/***************************************************************************/
    global Database.QueryLocator start(final Database.BatchableContext batchContext){
        return Database.getQueryLocator([SELECT ID,FS_IsActive__c,FS_Equip_Type__c,FS_Dispenser_Type2__c,FSInt_Dispenser_Type__c FROM FS_Outlet_Dispenser__c 
                                         WHERE RecordtypeID =:recTypeODInternational and FSInt_Dispenser_Type__c!=null and FSInt_Dispenser_Type__c IN :dispModelMap.keySet()]);       
    }
    
    /****************************************************************************
//Process batch
/***************************************************************************/
    
    global void execute(final Database.BatchableContext batchContext, final List<sObject> scope){
        
        List<FS_Outlet_Dispenser__c> dispenserToUpdate=new List<FS_Outlet_Dispenser__c>();
        set<id> dispenserIds =new set<id>();
        Map<id,FS_Outlet_Dispenser__c> dispenserToUpdateMap= new Map<id,FS_Outlet_Dispenser__c>();
        
        for( FS_Outlet_Dispenser__c outletDispenser : (List<FS_Outlet_Dispenser__c>)scope){
            if(dispModelMap.containskey(outletDispenser.FSInt_Dispenser_Type__c)){
                outletDispenser.FS_Equip_Type__c=dispModelMap.get(outletDispenser.FSInt_Dispenser_Type__c).Dispenser_Type__c;
                outletDispenser.FS_Dispenser_Type2__c=dispModelMap.get(outletDispenser.FSInt_Dispenser_Type__c).Dispenser_Type1__c;
                dispenserToUpdateMap.put(outletDispenser.Id,outletDispenser);
                if(outletDispenser.FS_IsActive__c){
                    dispenserIds.add(outletDispenser.id);
                }
            }
        }
        
        FSFETNMSConnector.isUpdateSAPIDBatchChange = true;
        FSFETNMSConnector.airWatchSynchronousCall(dispenserIds,null); 
        
        if(dispenserToUpdateMap!=null && !dispenserToUpdateMap.isEmpty()){
            final Database.SaveResult [] updateODResult= Database.update(dispenserToUpdateMap.values(),false);
        }
    }
    
    /****************************************************************************
//finish the batch
/***************************************************************************/
    
    global void finish(final Database.BatchableContext info){   
        
    } 
    
}