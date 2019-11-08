/****************************************************************************************************************************
Class Name :FSCopyTodaysBrandsets
Description :Copy All Post install Brandsets of Outlet Dispenser when effective date is today to Assosiation brandsets record
Author: Infosys Limited
Date: 11/01/2017
****************************************************************************************************************************/


global class FSCopyTodaysBrandsets implements Database.batchable <sobject>,Database.AllowsCallouts{
    
    
    public  String recTypeODInternational=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(Label.INT_OD_RECORD_TYPE).getRecordTypeId();
    public Date today; 
    
    global FSCopyTodaysBrandsets(final Date today){
        this.today=today; 
    }
    
    
/****************************************************************************
//Start the batch and query
/***************************************************************************/
    global Database.QueryLocator start(final Database.BatchableContext batchContext){
        return Database.getQueryLocator([SELECT ID,FS_Brandset_New__c,FS_Brandset_Effective_Date__c,FS_Water_Button__c,FS_Hide_Water_Dispenser_New__c,FS_showHideWater_Effective_date__c FROM FS_Outlet_Dispenser__c 
                                         WHERE FS_IsActive__c = true and (FS_Brandset_Effective_Date__c=:today or FS_showHideWater_Effective_date__c=:today) 
                                         and RecordtypeID!=:recTypeODInternational]);       
    }
    
/****************************************************************************
//Process batch
/***************************************************************************/
    
    global void execute(final Database.BatchableContext batchContext, final List<sObject> scope){
        
        //Collection variable that stores Outlet Dispenser Ids
        final Set<Id> setOfOutletDispenserIds=new Set<Id>();
        //Map to hold AB id and updated record values
        final Map<Id,FS_Association_Brandset__c> associationBrandsetUpdate=new Map<Id,FS_Association_Brandset__c>();
        
        //Collection variable with outlet dispnser Id as key and association brandet records as values
        final Map<Id,FS_Association_Brandset__c> dispenserAndAssociationBrandsetMap=new Map<Id,FS_Association_Brandset__c>();
        
        //Map to hold OD id and new updated record values
        final Map<id,FS_Outlet_Dispenser__c> dispenserToUpdateMap=new Map<id,FS_Outlet_Dispenser__c>();
        
        //Fetch Outlet Dispenser Record Ids
        for(FS_Outlet_Dispenser__c outletDispenser : (List<FS_Outlet_Dispenser__c>)scope){
            setOfOutletDispenserIds.add(outletDispenser.Id);
        }
        
        //Fetch association brandet records against each outlet dispenser records
        for(FS_Association_Brandset__c assoBrandset :[SELECT ID,FS_Brandset__c,FS_NonBranded_Water__c,FS_Outlet_Dispenser__c,Name FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:setOfOutletDispenserIds]){
            dispenserAndAssociationBrandsetMap.put(assoBrandset.FS_Outlet_Dispenser__c,assoBrandset);
        }
        
        for( FS_Outlet_Dispenser__c outletDispenser : (List<FS_Outlet_Dispenser__c>)scope){
            
            if(dispenserAndAssociationBrandsetMap.containsKey(outletDispenser.Id)){
                
                final FS_Association_Brandset__c assoBrandset=dispenserAndAssociationBrandsetMap.get(outletDispenser.Id);
                //Check either brandset change or water button change with effective date is Today
                if((assoBrandset.FS_Brandset__c!=outletDispenser.FS_Brandset_New__c 
                    && outletDispenser.FS_Brandset_Effective_Date__c==today) 
                   || 
                   (assoBrandset.FS_NonBranded_Water__c!=outletDispenser.FS_Hide_Water_Dispenser_New__c 
                   && outletDispenser.FS_showHideWater_Effective_date__c==today)){
                       //Check for brandset change
                       if(assoBrandset.FS_Brandset__c!=outletDispenser.FS_Brandset_New__c 
                          && outletDispenser.FS_Brandset_Effective_Date__c==today){
                              //Update Brandset on AB
                              assoBrandset.FS_Brandset__c=outletDispenser.FS_Brandset_New__c;
                              //Update Brandset on OD and balnk New Brandset and effective date
                              outletDispenser.FS_Brandset__c=outletDispenser.FS_Brandset_New__c;
                              outletDispenser.FS_Brandset_New__c=FSConstants.ID_NULL;
                              outletDispenser.FS_Brandset_Effective_Date__c=FSConstants.DATE_NULL;
                          }
                       //Check for water change
                       if(assoBrandset.FS_NonBranded_Water__c!=outletDispenser.FS_Hide_Water_Dispenser_New__c 
                          && outletDispenser.FS_showHideWater_Effective_date__c==today){
                              //Update Waterfield on AB
                              assoBrandset.FS_NonBranded_Water__c=outletDispenser.FS_Hide_Water_Dispenser_New__c;
                              //Update Water field on OD and balnk New Brandset and effective date
                              outletDispenser.FS_Water_Button__c=outletDispenser.FS_Hide_Water_Dispenser_New__c;
                              outletDispenser.FS_Hide_Water_Dispenser_New__c=FSConstants.ID_NULL;
                              outletDispenser.FS_showHideWater_Effective_date__c=FSConstants.DATE_NULL;
                          }
                       //Add AB record to map for update
                       associationBrandsetUpdate.put(assoBrandset.id,assoBrandset);
                       //Add OD record to map for update
                       dispenserToUpdateMap.put(outletDispenser.id,outletDispenser);
                   }
                
            }
        }
        
        //FSFETNMSConnector.isUpdateSAPIDBatchChange = true;
        //FSFETNMSConnector.airWatchSynchronousCall(dispenserToUpdateMap.keyset(),null); 
        //Update all Assosiation brandsets
        if(associationBrandsetUpdate!=null && !associationBrandsetUpdate.isempty()){
            final Database.SaveResult [] updateAssoBrandsetResult = Database.update(associationBrandsetUpdate.values(),false);}
        //Update Outlet Dispenser records
        if(dispenserToUpdateMap !=null && !dispenserToUpdateMap.isEmpty()){
            
            final Database.SaveResult [] updateODResult= Database.update(dispenserToUpdateMap.values(),false);
            // Iterate through each returned result
            for (Database.SaveResult sr : updateODResult) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted OD. OD ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('OD fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
        }
    }
    
    
/****************************************************************************
//finish the batch
/***************************************************************************/
    
    global void finish(final Database.BatchableContext info){   
        
    } 
    
}