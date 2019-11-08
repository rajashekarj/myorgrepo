global class FSMarketAccountTeamBatch implements Database.Batchable<sObject> {

   global final Map<String, MarketAccountTeamJunction__c> mapmarketJunctionWithAtm;
   global final Map<Id,FS_Market_ID__c> modifiedMarkets;
    
   global FSMarketAccountTeamBatch(Map<String, MarketAccountTeamJunction__c> m, Map<Id,FS_Market_ID__c> mm) {
       mapmarketJunctionWithAtm = m;
       modifiedMarkets = mm;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){            
       return Database.getQueryLocator([Select UserId ,TeamMemberRole,AccountId From AccountTeamMember Where Id IN : mapmarketJunctionWithAtm.keyset()]);
   }
   
   global void execute(Database.BatchableContext BC, List<AccountTeamMember> scope){
        Map<Id,AccountTeamMember> atmToInsert = new Map<Id,AccountTeamMember>();        
        List<AccountTeamMember> atmToDelete = new List<AccountTeamMember>();
        for(AccountTeamMember atm : scope) {
            AccountTeamMember newATM = atm.clone();
            newATM.UserId = modifiedMarkets.get(mapmarketJunctionWithAtm.get(atm.Id).Market__c).FS_User__c;
            atmToInsert.put(atm.Id,newATM);
            atmToDelete.add(atm);
        }      
                   
        List<MarketAccountTeamJunction__c> marketJunctionsToInsert = new List<MarketAccountTeamJunction__c>();
        for(Id atmId : atmToInsert.keyset()){
            marketJunctionsToInsert.add(new MarketAccountTeamJunction__c(AccountTeamMemberIds__c = atmToInsert.get(atmId).Id,
                                                                         Market__c = mapmarketJunctionWithAtm.get(atmId).Market__c));                                                                         
        }   
        system.debug('===atmToDelete=== ' + atmToDelete.size() + '===atmToInsert=== ' + atmToInsert.size());
        system.debug('===marketJunctionsToInsert=== ' + marketJunctionsToInsert.size() + ', ===marketJunctionToDelete=== '+ mapmarketJunctionWithAtm.size());
        
        insert atmToInsert.values();
        delete atmToDelete;
        insert marketJunctionsToInsert;
        delete mapmarketJunctionWithAtm.values();
   }

   global void finish(Database.BatchableContext BC){
       if (!Test.isRunningTest()){
       FSUtil.sendBatchReport(BC);
       }
   }
}