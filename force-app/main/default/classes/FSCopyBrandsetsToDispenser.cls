global class FSCopyBrandsetsToDispenser implements Database.Batchable<sObject>{
    
   /*private final static Id NULLOBJ = null;
   private final static Date NULLOBJDATE = null;*/     
   public  String recTypeODInternational=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(Label.INT_OD_RECORD_TYPE).getRecordTypeId();
     /******************************************************************************
    //Start the batch and query
    /***************************************************************************/
    global Database.QueryLocator start(final Database.BatchableContext batchContext){
      return Database.getQueryLocator([SELECT ID,FS_Brandset__c FROM FS_Outlet_Dispenser__c 
                                        WHERE RecordtypeID!=:recTypeODInternational AND FS_Brandset__c=NULL]);       
   }
   
   
    /****************************************************************************
    //Process batch
    /***************************************************************************/
   
   global void execute(final Database.BatchableContext batchContext, final List<sObject> scope){
       
       //Collection variable that stores Outlet Dispenser Ids
       final Set<Id> setOfOutletDispenserIds=new Set<Id>();
       
       final List<FS_Association_Brandset__c> associationBrandsetRecordsToUpdate=new List<FS_Association_Brandset__c>();
       
       //Collection variable with outlet dispnser Id as key and association brandet records as values
       final Map<Id,FS_Association_Brandset__c> dispenserAndAssociationBrandsetMap=new Map<Id,FS_Association_Brandset__c>();
       
       final List<FS_Outlet_Dispenser__c> dispenserRecordsToUpdate= new List<FS_Outlet_Dispenser__c>();
       
       //Fetch Outlet Dispenser Record Ids
       for(FS_Outlet_Dispenser__c outletDispenser : (List<FS_Outlet_Dispenser__c>)scope){
           setOfOutletDispenserIds.add(outletDispenser.Id);
       }
       
       //Fetch association brandet records against each outlet dispenser records
       for(FS_Association_Brandset__c assoBrandset :[SELECT ID,FS_Brandset__c,FS_Outlet_Dispenser__c,Name FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:setOfOutletDispenserIds]){
           dispenserAndAssociationBrandsetMap.put(assoBrandset.FS_Outlet_Dispenser__c,assoBrandset);
       }
       
       for( FS_Outlet_Dispenser__c outletDispenser : (List<FS_Outlet_Dispenser__c>)scope){
       
           if(dispenserAndAssociationBrandsetMap.containsKey(outletDispenser.Id)){
           
              final FS_Association_Brandset__c assoBrandset=dispenserAndAssociationBrandsetMap.get(outletDispenser.Id);
              
               if(assoBrandset.FS_Brandset__c!=NULL && assoBrandset.FS_Brandset__c!=outletDispenser.FS_Brandset__c){
                 
                       
                       outletDispenser.FS_Brandset__c=assoBrandset.FS_Brandset__c;
                       dispenserRecordsToUpdate.add(outletDispenser);
               }
           }
       }
       
       //Update all Assosiation brandsets
       /*final Database.SaveResult [] updateAssoBrandsetResult = Database.update(associationBrandsetRecordsToUpdate,false);*/
       //update Outlet Dispenser records
       final Database.SaveResult [] updateODResult= Database.update(dispenserRecordsToUpdate,false);
   }
   
   
    /****************************************************************************
    //finish the batch
    /***************************************************************************/
   
    global void finish(final Database.BatchableContext info){   
        system.debug('Finish Method of the Batch');
   } 

}