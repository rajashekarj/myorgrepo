/*********************************************************************************************************
Name         : FSOutletDispenserUpdateProcessBuilder
Created By   : Aman S, Infosys Limited
Created Date : 11/6/2107
Usage        : Class is Invoked by Process Builder to Copy association Brandset records from Installation to OutletDispenser
***********************************************************************************************************/
public with sharing class FSOutletDispenserUpdateProcessBuilder{

    @InvocableMethod(label='Update Copy Association Brandset From Installation' description='updates association brandset records from Outlet Dispenser')
  
    public static void updateAssociationBransetForOutletDispenser(List<FS_Outlet_Dispenser__c> outletDispenserList) {
    
    Set<Id> odList=new Set<Id>();
    for(FS_Outlet_Dispenser__c odInstance:outletDispenserList){
    odList.add(odInstance.Id);
    }
    
    Set<Id> installationIds=new Set<Id>();
    Map<Id,FS_Association_Brandset__c> installationOdMap =new Map<Id,FS_Association_Brandset__c>();
    List<FS_Association_Brandset__c> assList = [SELECT Id,FS_Brandset__c,FS_Platform__c,FS_Outlet_Dispenser__c,FS_NonBranded_Water__c FROM FS_Association_Brandset__c
                                                    WHERE FS_Outlet_Dispenser__c in: odList];
    
    for(FS_Association_Brandset__c assbrandsetInstance: assList){
        installationOdMap.put(assbrandsetInstance.FS_Outlet_Dispenser__c,assbrandsetInstance);
    }
    //Get all Installation Ids
    for(FS_Outlet_Dispenser__c dispenserInstance :outletDispenserList){
      installationIds.add(dispenserInstance.Installation__c);
    }
    
    //Get all association brandset records of Installation
    Map<Id,List<FS_Association_Brandset__c>> installationAndAsociationBrandsetMap=new Map<Id,List<FS_Association_Brandset__c>>();
    for(FS_Association_Brandset__c association : [SELECT Id,FS_Brandset__c,FS_Platform__c,FS_Installation__c,FS_NonBranded_Water__c FROM FS_Association_Brandset__c 
                                                    WHERE FS_Installation__c!=null AND FS_Installation__c in : installationIds ]){
      
       if(installationAndAsociationBrandsetMap.containskey(association.FS_Installation__c)){
          installationAndAsociationBrandsetMap.get(association.FS_Installation__c).add(association);
       }
       else{
          installationAndAsociationBrandsetMap.put(association.FS_Installation__c,new List<FS_Association_Brandset__c>{association});
       }
    }
    
    if(!installationAndAsociationBrandsetMap.isEmpty()){
       //Create AssociationBrandset for Dispenser
        //List<FS_Association_Brandset__c> newAssociationBrandsetRecords=new List<FS_Association_Brandset__c>();
        
        for(FS_Outlet_Dispenser__c dispenserInstance :outletDispenserList){
           if(installationAndAsociationBrandsetMap.containskey(dispenserInstance.Installation__c)){
              for(FS_Association_Brandset__c association : installationAndAsociationBrandsetMap.get(dispenserInstance.Installation__c)){
                  if(association.FS_Platform__c==dispenserInstance.FS_Equip_Type__c){
                      if(installationOdMap.get(dispenserInstance.Id)!=NULL){
                        installationOdMap.get(dispenserInstance.Id).FS_NonBranded_Water__c=association.FS_NonBranded_Water__c;
                        installationOdMap.get(dispenserInstance.Id).FS_Brandset__c=association.FS_Brandset__c;
                        installationOdMap.get(dispenserInstance.Id).FS_Outlet_Dispenser__c=dispenserInstance.Id;
                        installationOdMap.get(dispenserInstance.Id).FS_Platform__c=dispenserInstance.FS_Equip_Type__c;
                        //FET 5.0
                        installationOdMap.get(dispenserInstance.Id).recordTypeId=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_OD).getRecordTypeId();
                  	}
                  }
              }
           }
        }
       
        update installationOdMap.values();
       } 
      
}
}