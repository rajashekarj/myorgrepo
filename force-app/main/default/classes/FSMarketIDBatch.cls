global class FSMarketIDBatch implements Database.Batchable<sObject> {

    global final Map<String, FS_Market_ID__c> marketIdToMarket;
    global final List<String> listMarketIDs;
    global list <RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Account' and Name IN (:FSConstants.RECORD_TYPE_NAME_CHAIN, :FSConstants.RECORD_TYPE_NAME_HQ, :FSConstants.RECORD_TYPE_NAME_OUTLET)]; // Suhas created to change the sharing rules conflicting SFTK and FET
  
    global FSMarketIDBatch(Map<String, FS_Market_ID__c> m) {
       marketIdToMarket = m;
    }
    
    /*global FSMarketIDBatch(List<String> listMarketIDs) { //Commenting out as their is no invocation based on this signature
       //marketIdToMarket = m;
       listMarketIDs = listMarketIDs;
    }*/

   global Database.QueryLocator start(Database.BatchableContext BC) {
    
        Database.QueryLocator ql;
        if(marketIdToMarket != null && marketIdToMarket.size() > 0) {
            ql = Database.getQueryLocator(
                   [Select Id, OwnerId ,FS_Market_ID__c From Account Where FS_Market_ID__c IN  :marketIdToMarket.keySet() and account.recordtypeid in :Rectype ] //Suhas modified this SOQL
                   );
        }  /*else if (listMarketIDs != null && listMarketIDs.size() > 0) {
            ql = Database.getQueryLocator(
                   [Select Id, OwnerId ,FS_Market_ID__c From Account Where FS_Market_ID__c IN  :listMarketIDs and account.recordtypeid in :Rectype ] //Suhas modified this SOQL
                   );
        }*/          
       
       return ql;
   }
   
   global void execute(Database.BatchableContext BC, List<Account> scope){
    
        try {
            
            for(Account a : scope) {
                a.OwnerId = marketIdToMarket.get(a.FS_Market_ID__c).FS_User__c;
            }      
            Database.SaveResult[] srList = Database.update(scope,false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                System.debug('Account ID- '+sr.getId());
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated Account.');
                    
                } // Operation failed, so get all errors 
                else {for(Database.Error err : sr.getErrors()) {System.debug(err.getStatusCode() + ': ' + err.getMessage());System.debug('Account fields that affected this error: ' + err.getFields());}}
            }
            
        }catch(Exception exp){ System.debug('Exception occurred in the Market ID Batch- '+exp);}
      
      
   }

   global void finish(Database.BatchableContext BC){
   if (!Test.isRunningTest())  FSUtil.sendBatchReport(BC);
       
   }
}