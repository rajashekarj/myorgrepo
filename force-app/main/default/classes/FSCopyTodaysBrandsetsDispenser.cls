/*********************************************************************************************************
Name         : FSCopyTodaysBrandsetsDispenser
Created By   : Infosys Limited
Created Date : 24-April-2017
Usage        : Class is Invoked in trigger context to Copy Todays Brandsets to Current Brandset of Dispenser
***********************************************************************************************************/
public without sharing class FSCopyTodaysBrandsetsDispenser{

 public static Boolean copyTodaysBrandsetsToCurrentBrandset(final List<FS_Outlet_Dispenser__c> outletDispenserList) {
   
   Boolean executionSuccess=false;
   
   final Set<Id> setOfOutletDispenserIds=new Set<Id>();
   //Fetch Outlet Dispenser Record Ids 
   for(FS_Outlet_Dispenser__c outletDispenser : outletDispenserList){
       setOfOutletDispenserIds.add(outletDispenser.Id);
   }
   
   //Collection variable with outlet dispnser Id as key and association brandet records as values
    final Map<Id,FS_Association_Brandset__c> dispenserAndAssociationBrandsetMap=new Map<Id,FS_Association_Brandset__c>();
   //Fetch association brandet records against each outlet dispenser records
   for(FS_Association_Brandset__c assoBrandset :[SELECT ID,FS_Brandset__c,FS_NonBranded_Water__c,FS_Outlet_Dispenser__c,Name FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c=:setOfOutletDispenserIds]){
       dispenserAndAssociationBrandsetMap.put(assoBrandset.FS_Outlet_Dispenser__c,assoBrandset);
   }
   
   //Collection to hold records to be create or updated
   final List<FS_Association_Brandset__c> associationBrandsetRecords=new List<FS_Association_Brandset__c>();
   for(FS_Outlet_Dispenser__c outletDispenser : outletDispenserList){
      if(dispenserAndAssociationBrandsetMap.containsKey(outletDispenser.Id)){
          final FS_Association_Brandset__c assoBrandset=dispenserAndAssociationBrandsetMap.get(outletDispenser.Id);
           if(assoBrandset.FS_Brandset__c!=outletDispenser.FS_Brandset_New__c  && outletDispenser.FS_Brandset_Effective_Date__c==Date.today()){
             assoBrandset.FS_Brandset__c=outletDispenser.FS_Brandset_New__c;
             
           }
          if(assoBrandset.FS_NonBranded_Water__c != outletDispenser.FS_Hide_Water_Dispenser_New__c && outletDispenser.FS_showHideWater_Effective_date__c==Date.today()){
              assoBrandset.FS_NonBranded_Water__c=outletDispenser.FS_Hide_Water_Dispenser_New__c;
          }
          associationBrandsetRecords.add(assoBrandset);
      }
      
   }   
   
    if(!associationBrandsetRecords.isEmpty()){
        final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSCopyTodaysBrandsetsDispenserPB',
                                                           Method_Name__c='copyTodaysBrandsetsToCurrentBrandset',Object_Name__c='FS_Association_Brandset__c',
                                                           Error_Severity__c='High');
        System.debug('in copy Brandset' + associationBrandsetRecords);
        Set<FS_Association_Brandset__c> tempSet =new Set<FS_Association_Brandset__c>();
        tempSet.addAll(associationBrandsetRecords);
        List<FS_Association_Brandset__c> finalList =new List<FS_Association_Brandset__c>();
        finalList.addAll(tempSet);
        system.debug('ASSO BRAn' + tempSet);
        executionSuccess=FSUtil.dmlProcessorUpsert(finalList,true,apexError);
        
       system.debug('Final list' + finalList);
                             
     }      
     system.debug('execution success' +executionSuccess);
     return executionSuccess;     
 }
 
}