/***************************************************************************
 Name         : FSFlavorChangeHeaderTriggerHandler
 Created By   : Infosys Limited
 Description  : FSFlavorChangeHeaderTriggerHandler to call context wise methods (Business logic) 
 Created Date : 23-JAN-2017
************************ ****************************************************/
public class FSFlavorChangeHeaderTriggerHandler{

    //Method that calls business logic in before update context
    public static void beforeUpdateProcess(final List<FS_Flavor_Change_Head__c> newList,final List<FS_Flavor_Change_Head__c> oldList,
                                           final Map<Id,FS_Flavor_Change_Head__c> newMap,final Map<Id,FS_Flavor_Change_Head__c> oldMap, 
                                           final Boolean isInsert, final Boolean isUpdate,final Boolean isBatch,final Map<Id, SObject> sObjectsToUpdate){
                   FSFlavorChangeHeaderBusinessProcess.alert4DaysBeforeSchedule(newList,newMap,oldMap);
                  
                           
    }
    
    //Method that calls business logic in after insert context
    /*public static void afterInsertProcess(List<FS_Flavor_Change_Head__c> newList,List<FS_Flavor_Change_Head__c> oldList,
                                           Map<Id,FS_Flavor_Change_Head__c> newMap,Map<Id,FS_Flavor_Change_Head__c> oldMap, 
                                           Boolean isInsert, Boolean isUpdate,Boolean isBatch,Map<Id, SObject> sObjectsToUpdate){
                    FSFlavorChangeHeaderBusinessProcess.insertRelatedRecords(newMap,sObjectsToUpdate);                       
        
    }*/
    /*********************Code is Commented because there is no functionality in these trigger context**********************************/
    
    //Method that calls business logic in after update context
    public static void afterUpdateProcess(final List<FS_Flavor_Change_Head__c> newList,final List<FS_Flavor_Change_Head__c> oldList,
                                           final Map<Id,FS_Flavor_Change_Head__c> newMap,final Map<Id,FS_Flavor_Change_Head__c> oldMap, 
                                           final Boolean isInsert, final Boolean isUpdate,final Boolean isBatch,final Map<Id, SObject> sObjectsToUpdate){         
          
         FSFlavorChangeHeaderBusinessProcess.updateChildHeaders(newList,oldMap);
         FSFlavorChangeHeaderBusinessProcess.createTaskAlertsForSSUser(newList,newMap,oldMap);
         FSFlavorChangeHeaderBusinessProcess.updateRelatedRecords(newList,oldMap,sObjectsToUpdate); 
         FSFlavorChangeHeaderBusinessProcess.createServiceOrder(newMap);                                       
    }
}