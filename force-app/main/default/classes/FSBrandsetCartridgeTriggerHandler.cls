/***************************************************************************
Name         : FSBrandsetCartridgeTriggerHandler
Created By   : Infosys Limited
Description  : FSBrandsetCartridgeTriggerHandler to call context wise methods (Business logic) 
Created Date : 15-FEB-2017
****************************************************************************/
public class FSBrandsetCartridgeTriggerHandler{
    
    
    //Method that calls business logic in before insert context
    public static void beforeInsertProcess(final List<FS_Brandsets_Cartridges__c> newList,final List<FS_Brandsets_Cartridges__c> oldList,
                                           final Map<Id,FS_Brandsets_Cartridges__c> newMap,final Map<Id,FS_Brandsets_Cartridges__c> oldMap, 
                                           final Boolean isInsert, final Boolean isUpdate,final Boolean isBatch,final Map<Id, SObject> sObjectsToUpdate){
                                               
                                               FSBrandsetCartridgeBusinessProcess.updateCartridgeAWFlag(newList,sObjectsToUpdate); 
                                           }
    
}