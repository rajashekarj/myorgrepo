// 
// (c) 2014 Appirio, Inc.
// BatchForInstallationDateToWS
//
// 26 Dec 2014     Ashish Goyal(JDC)       Original(Ref: S-273619)
//
global without sharing class BatchForInstallationDateToWS implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String qry = 'SELECT Id, IsDailyUpdated__c FROM FS_Installation__c WHERE IsDailyUpdated__c = true';
        return Database.getQueryLocator(qry);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<FS_Installation__c> beList = (List<FS_Installation__c>)scope;
        List<FS_Installation__c> listToUpdate = new List<FS_Installation__c>();
        Set<Id> setOfInstallationsId = new Set<Id>();
        
        for(FS_Installation__c item : beList) {
            setOfInstallationsId.add(item.Id);
            item.IsDailyUpdated__c = false;
            listToUpdate.add(item);         
        }
        
        if(setOfInstallationsId.size() > 0){
            FSFETNMSConnector.isUpdateSAPIDBatchChange=true;
            FSFETNMSConnector.airWatchSynchronousCall(setOfInstallationsId,null);
            
            update listToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC){
        
    }

}