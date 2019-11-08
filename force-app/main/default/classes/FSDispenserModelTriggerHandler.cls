/******************************************************************************************
*  Purpose : FSDispenserModelTriggerHandler class to perform updates on International Outlet Dispenser when corresponding Dispenser Model Values are updated.
*  Author  : Lavanya Valluru
*  Date    : November 02, 2016
*******************************************************************************************/ 
public class FSDispenserModelTriggerHandler {
    
    public static void updateOD(Map<Id,Dispenser_Model__c> oldMapDM, Map<Id,Dispenser_Model__c> newMapDM){      
        Map<Id,Dispenser_Model__c> toUpdateODMap = new Map<Id,Dispenser_Model__c>();    
        
        for(Dispenser_Model__c dispModel:newMapDM.values()){
            if(oldMapDM.containsKey(dispModel.id) 
               && (dispModel.Dispenser_Type__c!=oldMapDM.get(dispModel.id).Dispenser_Type__c 
                   || dispModel.Dispenser_Type1__c!=oldMapDM.get(dispModel.id).Dispenser_Type1__c)){
                       toUpdateODMap.put(dispModel.id,dispModel);
                   }
        }
        database.executebatch(new FsUpdateODofDispModelBatch(toUpdateODMap),100);
        
    }
}