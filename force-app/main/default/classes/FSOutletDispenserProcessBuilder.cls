/*********************************************************************************************************
Name         : FSOutletDispenserProcessBuilder
Created By   : Infosys Limited
Created Date : 30-Dec-2016
Usage        : Class is Invoked by Process Builder to Copy association Brandset records from Installation to OutletDispenser
***********************************************************************************************************/
public with sharing class FSOutletDispenserProcessBuilder{

@InvocableMethod(label='Copy Association Brandset From Installation' description='creates association brandset records from Outlet Dispenser')
  
  public static void createAssociationBransetForOutletDispenser(List<FS_Outlet_Dispenser__c> outletDispenserList) {
        
    Set<Id> installationIds=new Set<Id>();
    
    //Get all Installation Ids
    for(FS_Outlet_Dispenser__c dispenserInstance :outletDispenserList){
      installationIds.add(dispenserInstance.Installation__c);
    }
    
    //Get all association brandset records of Installation
    Map<Id,List<FS_Association_Brandset__c>> installationAndAsociationBrandsetMap=new Map<Id,List<FS_Association_Brandset__c>>();
    for(FS_Association_Brandset__c association : [SELECT Id,FS_Brandset__c,FS_Platform__c,FS_Installation__c,FS_NonBranded_Water__c FROM FS_Association_Brandset__c 
                                                    WHERE FS_Installation__c!= null AND FS_Installation__c in : installationIds ]){
       
       if(installationAndAsociationBrandsetMap.containskey(association.FS_Installation__c)){
          installationAndAsociationBrandsetMap.get(association.FS_Installation__c).add(association);
       }
       else{
          installationAndAsociationBrandsetMap.put(association.FS_Installation__c,new List<FS_Association_Brandset__c>{association});
       }
    }
    
    if(!installationAndAsociationBrandsetMap.isEmpty()){
       //Create AssociationBrandset for Dispenser
        List<FS_Association_Brandset__c> newAssociationBrandsetRecords=new List<FS_Association_Brandset__c>();
        
        for(FS_Outlet_Dispenser__c dispenserInstance :outletDispenserList){
           if(installationAndAsociationBrandsetMap.containskey(dispenserInstance.Installation__c)){
              for(FS_Association_Brandset__c association : installationAndAsociationBrandsetMap.get(dispenserInstance.Installation__c)){
                  if(association.FS_Platform__c==dispenserInstance.FS_Equip_Type__c){
                    FS_Association_Brandset__c newRecord=new FS_Association_Brandset__c();
                     newRecord.FS_NonBranded_Water__c=association.FS_NonBranded_Water__c;
                     newRecord.FS_Brandset__c=association.FS_Brandset__c;
                     newRecord.FS_Outlet_Dispenser__c=dispenserInstance.Id;
                     newRecord.FS_Platform__c=dispenserInstance.FS_Equip_Type__c;
                     newRecord.recordTypeId=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_OD).getRecordTypeId();
                     newAssociationBrandsetRecords.add(newRecord);
                  }
              }
           }
        }
       
       if(!newAssociationBrandsetRecords.isEmpty()){
           final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSOutletDispenserProcessBuilder',
                                                           Method_Name__c='createAssociationBransetForOutletDispenser',Object_Name__c='FS_Association_Brandset__c',
                                                           Error_Severity__c='High');
          FSUtil.dmlProcessorInsert(newAssociationBrandsetRecords,false,apexError);
       }       
    }   
  }
}