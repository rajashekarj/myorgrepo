/** Class used to update Enable Consumer Engagement,Favorite Mix,Promotion Enabled to YES
*  TASK0882385 --CCSN request
*  Created By: FET Support
*/
global without sharing class FSCEAttributesUpdates implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Static Id recTypeChain=getObjectRecordTypeId(Account.sObjectType,'FS Chain');
    public Static Id recTypeHQ=getObjectRecordTypeId(Account.sObjectType,'FS Headquarters');
    public Static Id recTypeOutlet=getObjectRecordTypeId(Account.sObjectType,'FS Outlet');
    
    public String ObjectType;
    
    global FSCEAttributesUpdates(String ObjectType){
        
        this.ObjectType=ObjectType;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(ObjectType=='Account') 
            return Database.getQueryLocator([SELECT Id,Name,FS_CE_Enabled__c,FS_FAV_MIX__c,FS_Promo_Enabled__c FROM Account WHERE (RecordTypeId=:recTypeChain OR RecordTypeId=:recTypeHQ OR RecordTypeId=:recTypeOutlet) AND (FS_CE_Enabled__c!='Yes' OR FS_FAV_MIX__c!='Yes' OR FS_Promo_Enabled__c!='Yes')]);
        
        if(ObjectType=='FS_Installation__c')  //To Be done for all Open Installation
            return Database.getQueryLocator([SELECT Id,Name,FS_CE_Enabled__c,FS_FAV_MIX__c,FS_Promo_Enabled__c FROM FS_Installation__c WHERE (FS_Overall_Status__c!='' AND FS_Overall_Status__c!=:FSConstants.IPCOMPLETE AND FS_Overall_Status__c!=:FSConstants.IPCANCELLED )]);
        
        if(ObjectType=='FS_Outlet_Dispenser__c')  
            //return Database.getQueryLocator([SELECT Id, Name, FS_CE_Enabled__c, FS_FAV_MIX__c, FS_Promo_Enabled__c FROM FS_Outlet_Dispenser__c WHERE FS_IsActive__c=TRUE AND (FS_CE_Enabled__c!='Yes' OR FS_FAV_MIX__c!='Yes' OR FS_Promo_Enabled__c!='Yes')]);
            return Database.getQueryLocator([SELECT Id, Name,FS_CE_Enabled__c,FS_FAV_MIX__c,FS_Promo_Enabled__c, FS_Migration_to_AW_Required__c , FS_Pending_Migration_to_AW__c, FS_Migration_to_AW_Complete__c FROM FS_Outlet_Dispenser__c WHERE FS_IsActive__c=TRUE]);
        return null;
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(ObjectType);
        List<Sobject> sObjectsToUpdate=new List<Sobject>();
        
        if(ObjectType=='FS_Outlet_Dispenser__c'){
            for(SObject obj : scope){
                
                SObject record= sObjectType.newSObject(obj.Id);
                record.put('FS_CE_Enabled__c','Yes');
                //record.put('FS_FAV_MIX__c','Yes');
                record.put('FS_Promo_Enabled__c','Yes');
                record.put('FS_Migration_to_AW_Required__c',TRUE );
                record.put('FS_Pending_Migration_to_AW__c',TRUE );
                record.put('FS_Migration_to_AW_Complete__c',FALSE);
                sObjectsToUpdate.add(record);
            }
        }
        
        Database.update(sObjectsToUpdate,false);
        
        system.debug('Records In Batch'+sObjectsToUpdate);
    }
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new FS_Data_Migration_8k_9k(),1);
    }
    
    public static Id getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
        //Generate a map of tokens for all the Record Types for the desired object
        Map<String,Schema.RecordTypeInfo> rtMapByName = sObjectType.getDescribe().getRecordTypeInfosByName();
        //Retrieve the record type id by name
        return rtMapByName.get(recordTypeName).getRecordTypeId();
    }
}