/******************************************************************************************
 *  Purpose : Batch class to populate Revenue Center for Chains, HeadQuarters and Outlets with a MarketID.
 *  Author  : Infosys 
 *  Date    : 18/05/2015
*******************************************************************************************/ 
global class FSRevenueCentersForCustomersBatch  implements Database.Batchable<sObject>{
        
     
   
    global Database.QueryLocator start(final Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,FS_Market_ID__c,FS_Revenue_Center__c from Account where FS_Market_ID__c!='' and FS_Revenue_Center__c='no match' and (RecordTypeId=:FSConstants.RECORD_TYPE_CHAIN OR RecordTypeId=:FSConstants.RECORD_TYPE_HQ OR RecordTypeId=:FSConstants.RECORD_TYPE_OUTLET)]);
    }
    
    /****************************************************************************
    //Process a batch
    /***************************************************************************/ 
    global void execute(final Database.BatchableContext BC, final List<sObject> lstAccount){
        final List<Account> accountList =  (List<Account>) lstAccount;
        
        final List<Account> toUpdateAccountList=new List<Account>();
        for(Account acc : accountList){
           acc.FS_Revenue_Center__c=FSRevenueCenterUtil.lookupRevenueCenter(acc.FS_Market_ID__c);
           toUpdateAccountList.add(acc);
        }
        
        if(toUpdateAccountList.size()>0) update toUpdateAccountList;
    }
    
    /****************************************************************************
    //finish the batch 
    /***************************************************************************/ 
    global void finish(final Database.BatchableContext BC){
        
    }
}