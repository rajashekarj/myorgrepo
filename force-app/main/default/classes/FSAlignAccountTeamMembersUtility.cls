/******************************************************************************************
 *  Purpose : Utility class to update Account and account team members.
 *  Author  : Mohit Parnami
 *  Date    : 15/10/2013
*******************************************************************************************/ 
global class FSAlignAccountTeamMembersUtility {
    
    //--------------------------------------------------------------------------------------------------
    // Method to update account's owner , account team members and MarketAccountTeamJunction__c object.
    //--------------------------------------------------------------------------------------------------
    public static void alignAccountTeam(List<Account> accountList, Boolean isInsertContext){
        
        //delete existing account team members only in case of update as there will be no account team member in insert context.
        if(isInsertContext){
            deleteAccountTeamMembers(accountList);          
        }        
        
        //calling Method thats create a map between market Id and set of Account
        Map<String, List<Account>> mapMarketIdtoAcc = createMapMarketIdtoAcc(accountList);
        Map<Id, List<AccountTeamMember>> mapMrktIdToAccTeamMember = new Map<Id, List<AccountTeamMember>>();       
        
        //calling Method that creates new Account Team members with users same as that of market's parent user until market.FS_Parent_ID_Value__c!= null.
        alignAccountTeamMembers(mapMarketIdtoAcc, mapMrktIdToAccTeamMember, 1);
        
        //calling Method that preapares a list of Accouts to update from a map having set of accounts as a values to update.
        saveData( mapMarketIdtoAcc, mapMrktIdToAccTeamMember);
    }
    
    private static void saveData(Map<String, List<Account>> mapMarketIdtoAcc, Map<Id, List<AccountTeamMember>> mapMrktIdToAccTeamMember){
        List<Account> accountsToUpdate = new List<Account>();
        for(List<Account> lst : mapMarketIdtoAcc.values()){
            accountsToUpdate.addAll(lst);
        }
        if(FSUtil.checkAccessForSobject('Account', FSConstants.ACCESS_IS_UPDATEABLE)){
         update accountsToUpdate;
        }
        
         
        List<AccountTeamMember> atmsToUpdate = new List<AccountTeamMember>();
        for(Id marketId : mapMrktIdToAccTeamMember.keyset()){
            atmsToUpdate.addAll(mapMrktIdToAccTeamMember.get(marketId));
        }
        if(FSUtil.checkAccessForSobject('AccountTeamMember', FSConstants.ACCESS_IS_CREATABLE)){
          insert atmsToUpdate;
        }
        
        List<MarketAccountTeamJunction__c> accTeamMemberListJuncToInsert = new List<MarketAccountTeamJunction__c>();
        for(Id marketId : mapMrktIdToAccTeamMember.keyset()){
            for(AccountTeamMember atm : mapMrktIdToAccTeamMember.get(marketId)){
                MarketAccountTeamJunction__c marketTeamJunction = new MarketAccountTeamJunction__c();
                marketTeamJunction.Market__c = marketId;
                marketTeamJunction.AccountTeamMemberIds__c = atm.Id;
                accTeamMemberListJuncToInsert.add(marketTeamJunction);
            }            
        }
        if(FSUtil.checkAccessForSobject('MarketAccountTeamJunction__c', FSConstants.ACCESS_IS_CREATABLE)){
          insert accTeamMemberListJuncToInsert;
        }
    }
    
    
    public static void deleteAccountTeamMembers(List<Account> accountList){
        List<AccountTeamMember> accountTeamMembers = [Select Id,AccountId From AccountTeamMember Where AccountId IN : accountList];
        Set<String> accountTeamMemberIds = new Set<String>();
        for(AccountTeamMember atm : accountTeamMembers){
            accountTeamMemberIds.add((String)atm.Id);
        }
      
      if(FSUtil.checkAccessForSobject('MarketAccountTeamJunction__c', FSConstants.ACCESS_IS_DELETABLE)){
          delete [select Id,AccountTeamMemberIds__c From MarketAccountTeamJunction__c Where AccountTeamMemberIds__c IN: accountTeamMemberIds];
      }
      if(FSUtil.checkAccessForSobject('AccountTeamMember' , FSConstants.ACCESS_IS_DELETABLE)){
          delete accountTeamMembers;
      }
    }
  
  //-----------------------------------------------------------------------------------------------------------------------------
  // Method to create new Account Team members with users same as that of market's parent user until market.FS_Parent_ID_Value__c!= null.
  //------------------------------------------------------------------------------------------------------------------------------
  private static void alignAccountTeamMembers(Map<String, List<Account>> mapMarketIdtoAcc, Map<Id, List<AccountTeamMember>> mapMrktIdToAccTeamMember,  Integer iterationLevel){
    Map<String, List<Account>> mapParentIdToAcc = new Map<String, List<Account>>();
        for(FS_Market_ID__c mrkt : [Select Id, FS_Market_ID_Value__c, FS_Parent_ID_Value__c, FS_User__c from FS_Market_ID__c where FS_Market_ID_Value__c IN: mapMarketIdtoAcc.keySet() AND FS_User__r.isactive = true]){
           system.debug('alignAccountTeamMembers ==== mrkt == ' + mrkt);
           for(Account account: mapMarketIdtoAcc.get(mrkt.FS_Market_ID_Value__c)){                                  
               if(mrkt.FS_User__c != null){
                   if(iterationLevel == 1){ 
                        //Set the account owner (1st level only)
                        account.OwnerId = mrkt.FS_User__c;  
                   }else {
                        //Creating account team member (all levels beyond 1st)
                        AccountTeamMember teamMember = new AccountTeamMember();
                        teamMember.UserId = mrkt.FS_User__c; 
                        teamMember.AccountId = account.Id;
                        teamMember.TeamMemberRole = 'Sales Leadership';
                        
                        //map to maintain market Id and and List of related accountTeamMembers. 
                        if(!mapMrktIdToAccTeamMember.containsKey(mrkt.Id)){
                            mapMrktIdToAccTeamMember.put(mrkt.Id, new List<AccountTeamMember>());
                        }
                        mapMrktIdToAccTeamMember.get(mrkt.Id).add(teamMember);
                    }
                }
                // Gather list of the parent-id and their accounts (for later recursion) 
                if(mrkt.FS_Parent_ID_Value__c != null && mrkt.FS_Parent_ID_Value__c != mrkt.FS_Market_ID_Value__c){
                    if(!mapParentIdToAcc.containsKey(mrkt.FS_Parent_ID_Value__c)){
                        mapParentIdToAcc.put(mrkt.FS_Parent_ID_Value__c, new List<Account>());
                    }
                    mapParentIdToAcc.get(mrkt.FS_Parent_ID_Value__c).add(account);
                }                
            }           
        }
        //Recursion if market parent exsists.
        if(mapParentIdToAcc.size() > 0 && iterationLevel < 10){
            alignAccountTeamMembers(mapParentIdToAcc, mapMrktIdToAccTeamMember, iterationLevel + 1);
        }       
  }
  
  
  //--------------------------------------------------------------------------------------
    // Method to create a map between market Id and set of Account
    //--------------------------------------------------------------------------------------  
     private static Map<String, List<Account>> createMapMarketIdtoAcc(List<Account> accountList){       
        Map<String, List<Account>> mapMktToAccountsToUpdate = new Map<String, List<Account>>();
        for(Account acc : accountList){
            system.debug('createMapMarketIdtoAcc ==  '+  acc.FS_Market_ID__c);
            if(acc.FS_Market_ID__c != null && acc.FS_Market_ID__c != ''){
                if(!mapMktToAccountsToUpdate.containsKey(acc.FS_Market_ID__c)){
                    mapMktToAccountsToUpdate.put(acc.FS_Market_ID__c, new List<Account>());  
                }
                acc.FS_Revenue_Center__c = FSRevenueCenterUtil.lookupRevenueCenter(acc.FS_Market_ID__c);
                system.debug('*********** Revenue Center *************** ' + FSRevenueCenterUtil.lookupRevenueCenter(acc.FS_Market_ID__c));
                mapMktToAccountsToUpdate.get(acc.FS_Market_ID__c).add(acc);
            }
        }
        return mapMktToAccountsToUpdate;
    }

    //----------------------------------------------------------------------------------------------
        //Future Method to be called from Trigger.
        //----------------------------------------------------------------------------------------------  
    @future
    public static void alignAccountTeamFromTrigger(Set<Id> accountIdLst, Boolean isInsert){
        List<Account> accountList = [Select Id, FS_Market_ID__c, OwnerId From Account Where Id IN: accountIdLst];
        if(accountList.size() > 0){
            alignAccountTeam(accountList, !isInsert);
        }
    }

}