/***************************************************************************
 Name         : AccountTrigger
 Created By   : Mohit Parnami
 Description  : Handler class of FSMarketTrigger
 Created Date : June 27, 2014         
****************************************************************************/
public without sharing class FSMarketTriggerHandler {
    
    //----------------------------------------------------------------------------
    // Executes After Update
    //----------------------------------------------------------------------------
    public static void afterUpdate() {
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = p.name;
        if(pname != 'API User') {
            system.debug('In FSMarketTriggerHandler.updateAccountTeamMember');
            updateAccountTeamMember();
        }
    }
    
    //-----------------------------------------------------------------------------------------------
    // Method to update Accounts owner and insert new market Acount Team junctions 
    //-----------------------------------------------------------------------------------------------
    private static void updateAccountTeamMember(){
        Map<Id, FS_Market_ID__c> oldMap = (Map<Id, FS_Market_ID__c>)Trigger.oldMap;
        List<FS_Market_ID__c> newMarkets = (List<FS_Market_ID__c>) Trigger.new ;
        
        Map<Id,FS_Market_ID__c> maodifiedMarkets = new Map<Id,FS_Market_ID__c>();
        Map<String, FS_Market_ID__c> mapMarketIdToMarket = new Map<String, FS_Market_ID__c>();
        
        
        //to update accounts
        for(FS_Market_ID__c market : newMarkets){
        
            if(oldMap == null || market.FS_User__c != oldMap.get(market.Id).FS_User__c){
                maodifiedMarkets.put(market.Id,market);
                mapMarketIdToMarket.put(market.FS_Market_ID_Value__c, market);
            }
        }
                
        String queryString= 'Select Id, OwnerId ,FS_Market_ID__c From Account Where FS_Market_ID__c IN ';
        FSMarketIDBatch batch = new FSMarketIDBatch(mapMarketIdToMarket);
        Database.executeBatch(batch);
                
        //to update MarketTeamJunction and Account team Members
        //Commented out as per J-F's request
        /*Map<String,MarketAccountTeamJunction__c> mapmarketJunctionWithAtm = new Map<String,MarketAccountTeamJunction__c>(); 
        for(MarketAccountTeamJunction__c marketATMJunc : [Select Id,AccountTeamMemberIds__c, Market__c 
                                                          From MarketAccountTeamJunction__c 
                                                          Where Market__c IN: maodifiedMarkets.keySet()]){
            mapmarketJunctionWithAtm.put(marketATMJunc.AccountTeamMemberIds__c ,marketATMJunc);
        }
        system.debug('===maodifiedMarkets size=== ' + maodifiedMarkets.size() + '===mapmarketJunctionWithAtm size===' + mapmarketJunctionWithAtm.size());
        FSMarketAccountTeamBatch teamBatch = new FSMarketAccountTeamBatch(mapmarketJunctionWithAtm, maodifiedMarkets);
        Database.executeBatch(teamBatch);*/
    }
    
}