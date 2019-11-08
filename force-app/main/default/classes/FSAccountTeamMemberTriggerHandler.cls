/***************************************************************************
 Name         : FSAccountTeamMemberTriggerHandler
 Created By   : Sonal Shrivastava
 Description  : Handler class of FSAccountTeamMemberTrigger
 Created Date : Nov 06, 2013
 Reference    : T-208042
****************************************************************************/
//
// 3rd March 2015   Modified   Kirti Agarwal    Ref(T-367311)
// Purpose : Create/delete share records for Chain Account on insert/update/delete
//
public without sharing class FSAccountTeamMemberTriggerHandler {
    public static boolean insertFlag = false;
    public static boolean deleteFlag = false;
    public static boolean orginatedFromChain = false;

  //----------------------------------------------------------------------------
  // Method called on Before Insert
  //----------------------------------------------------------------------------
  public static void beforeInsert(List<AccountTeamMember__c> newList){

  }

  //----------------------------------------------------------------------------
  // Method called on After Insert
  //----------------------------------------------------------------------------
  public static void afterInsert(List<AccountTeamMember__c> newList){
     
      FSConstants.BypassupdateAccountTeamMember = true;
    updateAccountTeamMember();
    copyAccountMembersOnOutletLookups(newList);
  }

  //----------------------------------------------------------------------------
  // Method called on After Delete
  //----------------------------------------------------------------------------
  public static void afterDelete(List<AccountTeamMember__c> oldList){
   updateAccountTeamMember();
  }

  //----------------------------------------------------------------------------
  // Method called on After Delete
  //----------------------------------------------------------------------------
  public static void afterUpdate(Map<ID, AccountTeamMember__c> oldMap, List<AccountTeamMember__c> newList){
           
      if(FSConstants.BypassupdateAccountTeamMember == false)
      {
          copyAccountMembersOnOutletLookups(newList);
      }
  }

 /**
    * @MethodName - updateAccountTeamMember()
    * @Description - It is used to create/delete share records for HQ and its chain account
    * @Return - void
    * @Story/Task - S-274864/T-367312
    */
  public static void updateAccountTeamMember(){
    Set<Id> accountIdSet = new Set<Id>();
    Map<Id,Id> hqAndChainMap = new Map<Id,Id>();
    Boolean isTriggerDelete =  Trigger.isDelete;
    List<AccountTeamMember__c> atmList;
    //idenify account team member updated or deleted
    if(!isTriggerDelete) {
       atmList = Trigger.new;
    }else {
       atmList = Trigger.old ;
    }

    //create set of AccountId related to ATM
    for(AccountTeamMember__c atm : atmList){
        accountIdSet.add(atm.AccountId__c);
    }
     Set<Id> accountHQIdSet=new Set<Id>();
    /* for(Account acc: [SELECT Id FROM Account where FS_Chain__c in: accountIdSet and RecordtypeId=:FSConstants.RECORD_TYPE_HQ ]){
        if(acc.Id!=null)
        accountHQIdSet.add(acc.Id);
     }*/
      Map<id,Account> accMapDetails = new Map<Id,Account>([SELECT Id FROM Account where FS_Chain__c in: accountIdSet and RecordtypeId=:FSConstants.RECORD_TYPE_HQ]);
    accountHQIdSet =  accMapDetails.keySet();
      //create set of AccountId related to ATM
    //hqAndChainMap = createShareRecordsForHQAccount(accountIdSet);
    if(accountHQIdSet.size()>0){
      orginatedFromChain=true;
      hqAndChainMap = createShareRecordsForHQAccount(accountHQIdSet);
    }
    
    if(!hqAndChainMap.isEmpty()) {
        if(!isTriggerDelete) {
           createShareRecordForChainAccount(hqAndChainMap);
        }else {
          deleteShareRecordForChainAccount(hqAndChainMap);
        }
    }
    if(!isTriggerDelete && accountIdSet.size()>0 && orginatedFromChain==false)
    createOutletAccountTeamMemberRecord(accountIdSet); //FET 2.1 Warranty defect 1678 
   
  }
  
  public static void createOutletAccountTeamMemberRecord(Set<Id> accountIdSet){
       
    Set<Id> accountHQForOutletIdSet=new Set<Id>();
    Set<Id> accountOutletIdSet=new Set<Id>();
    List<AccountTeamMember__c> insertOutletAccount=new List<AccountTeamMember__c>();
   /* for(Account acc: [SELECT Id FROM Account where Id in: accountIdSet and RecordtypeId=:FSConstants.RECORD_TYPE_HQ ]){
        if(acc.Id!=null)
        accountHQForOutletIdSet.add(acc.Id);
     }*/
    Map<Id, Account> hqAccountMap = new Map<Id, Account>([ SELECT Id FROM Account where Id in: accountIdSet and RecordtypeId=:FSConstants.RECORD_TYPE_HQ]);
    accountHQForOutletIdSet = hqAccountMap.keySet();

     if(accountHQForOutletIdSet.size()>0){
        for(Account acc: [SELECT Id FROM Account where FS_Headquarters__c in: accountHQForOutletIdSet and RecordtypeId=:FSConstants.RECORD_TYPE_OUTLET  ]){
            if(acc.Id!=null)
            accountOutletIdSet.add(acc.Id);
      }
     }
    
     if(accountOutletIdSet.size()>0){
            for(AccountTeamMember__c atm : (List<AccountTeamMember__c>)Trigger.New) {
            for(Id accOutletId: accountOutletIdSet){
               AccountTeamMember__c atmCloned = atm.clone();
               atmCloned.AccountID__c = accOutletId;
               insertOutletAccount.add(atmCloned);
          }  
        }   
     }
     //Modified as part of defect fix 3740, May 23,2017 
     if(insertOutletAccount.size()>0 && insertOutletAccount.size() < 10000 ){
       insert insertOutletAccount;
     }
      else if(insertOutletAccount.size()>0){
         Database.executeBatch(new FSAccountTeamMemberOutletsBatch(Trigger.New), 2000); 
      }
  }

 /**
    * @MethodName - createShareRecordForChainAccount()
    * @Description - It is used to create share records for Chain
    * @Param - Map<Id, Id>
    * @Return - void
    * @Story/Task - S-274864/T-367312
    */
  public static void createShareRecordForChainAccount(Map<Id, Id> HqAndChainAccountId) {
    List<Id> accountIdSet = HqAndChainAccountId.values();
    Set<Id> uniqueAccountIdSet = new Set<Id>(HqAndChainAccountId.values()); //FET 2.1 defect 1678
    List<AccountTeamMember__c> insertHQAccount = new List<AccountTeamMember__c>(); //FET 2.1 defect 1678
    //List<Id> chainAccList = new List<Id>();
    //method used to get chain account with Account team member
    Map<Id,Account> chainMap = getChainAccountRelatedATM(accountIdSet, FSConstants.RECORD_TYPE_CHAIN);
    List<AccountTeamMember__c> updateChainATM = new List<AccountTeamMember__c>();
    List<AccountTeamMember__c> insertChainAccount = new List<AccountTeamMember__c>();
    Map<Id, List<Id>> chainAccountAndUserMap = new Map<Id, List<Id>>();
    Id chainAccount;
    boolean isExist;
    for(AccountTeamMember__c atm : (List<AccountTeamMember__c>)Trigger.New) {
        chainAccount = null;
        
        if(HqAndChainAccountId.containsKey(atm.AccountId__c)) {
           chainAccount = HqAndChainAccountId.get(atm.AccountId__c);
           //chainAccList.add(chainAccount);
        }
        if(chainAccount != null && chainMap.containsKey(chainAccount)) {
            isExist = false;
            for(AccountTeamMember__c chainAtm : chainMap.get(chainAccount).AccountTeamMembers__r) {                
                if(chainAtm.UserId__c == atm.UserId__c) {
                    if(chainAtm.count__c == 0 || chainAtm.count__c == null){
                        chainAtm.count__c = 1;
                    }else{
                        chainAtm.count__c += 1;
                    }
                    updateChainATM.add(chainAtm);
                    isExist = true;
                }                
            }
            
            if(!isExist){
                    AccountTeamMember__c atmCloned = atm.clone();
                    atmCloned.AccountID__c = chainAccount;
                    atmCloned.count__c = 1;
                    insertChainAccount.add(atmCloned);
                    if(!chainAccountAndUserMap.containsKey(chainAccount)) {
                        chainAccountAndUserMap.put(chainAccount,new List<Id>{atm.UserId__c});
                    }else{
                        List<Id> userIDs = chainAccountAndUserMap.get(chainAccount);
                        userIDs.add(atm.UserId__c);
                        chainAccountAndUserMap.put(chainAccount,userIDs);
                    }
             }
             
        }
         //Insert HQ As a part of defect fix. //FET 2.1 defect 1678 
         for(Id accHQId: HqAndChainAccountId.keySet()){
           AccountTeamMember__c atmCloned = atm.clone();
           atmCloned.AccountID__c = accHQId;
           insertHQAccount.add(atmCloned);
         }
    }
    if(!updateChainATM.isEmpty()) {
        update updateChainATM;
    }
     if(!insertChainAccount.isEmpty()) {
        insert insertChainAccount;
    }
    if(!insertHQAccount.isEmpty()) { //FET 2.1 defect 1678 
        insert insertHQAccount;
    }
    

    List<AccountShare> accountShareList = new List<AccountShare>();
    for(Id accId : chainAccountAndUserMap.keyset()){
        for(Id userId : chainAccountAndUserMap.get(accId)) {
            if(chainMap.get(accId).OwnerId != userId) {
                accountShareList.add(new AccountShare(AccountAccessLevel = 'Edit',
                                                  OpportunityAccessLevel = 'Edit',
                                                  AccountId = accId,
                                                  UserOrGroupId = userId
                                                  ));
            }
        }
    }

     if(!accountShareList.isEmpty()) {
        insert accountShareList;
    }
    /*chainMap = getChainAccountRelatedATM(chainAccList, FSConstants.RECORD_TYPE_CHAIN);
     //method used to delete existing share records(Only Manual share records)
    List<AccountTeamMember__c> atmList = deleteExistingShareRecords(chainMap.values());
    if(!atmList.isEmpty()) {
      //method used to insert share records
      insertShareRecords(atmList);
    }*/
  }



/**
    * @MethodName - deleteShareRecordForChainAccount()
    * @Description - It is used to delete share records for Chain
    * @Param - Map<Id, Id>
    * @Return - void
    * @Story/Task - S-274864/T-367312
    */
   public static void deleteShareRecordForChainAccount(Map<Id, Id> HqAndChainAccountId) {
    List<Id> accountIdSet = HqAndChainAccountId.values();
    List<Id> chainAccList = new List<Id>();
    //method used to get chain account with Account team member
     Map<Id,Account> chainMap = getChainAccountRelatedATM(accountIdSet, FSConstants.RECORD_TYPE_CHAIN);
    List<AccountTeamMember__c> updateChainATM = new List<AccountTeamMember__c>();
     List<AccountTeamMember__c> deleteChainATM = new List<AccountTeamMember__c>();
     Map<Id, List<Id>> chainAccountAndUserMap = new Map<Id, List<Id>>();
    Id chainAccount;
    for(AccountTeamMember__c atm : (List<AccountTeamMember__c>)Trigger.old) {
        chainAccount = null;
        if(HqAndChainAccountId.containsKey(atm.AccountId__c)) {
           chainAccount = HqAndChainAccountId.get(atm.AccountId__c);
           chainAccList.add(chainAccount);
        }
        if(chainAccount != null && chainMap.containsKey(chainAccount)) {
            for(AccountTeamMember__c chainAtm : chainMap.get(chainAccount).AccountTeamMembers__r) {
                if(chainAtm.UserId__c == atm.UserId__c && chainAtm.count__c > 1) {
                    chainAtm.count__c -= 1;
                    updateChainATM.add(chainAtm);
                }else if(chainAtm.UserId__c == atm.UserId__c) {
                    deleteChainATM.add(chainAtm);
                     if(!chainAccountAndUserMap.containsKey(chainAccount)) {
                        chainAccountAndUserMap.put(chainAccount,new List<Id>{atm.UserId__c});
                    }else{
                        List<Id> userIDs = chainAccountAndUserMap.get(chainAccount);
                        userIDs.add(atm.UserId__c);
                        chainAccountAndUserMap.put(chainAccount,userIDs);
                    }
                }
            }
        }
    }
    if(!updateChainATM.isEmpty()) {
        update updateChainATM;
    }
    if(!deleteChainATM.isEmpty()) {
        delete deleteChainATM;
    }


    List<AccountShare> deleteAccountShareList = new List<AccountShare>();
    for(Id accId : chainAccountAndUserMap.keyset()){
        for(Id userId : chainAccountAndUserMap.get(accId)) {
            for(AccountShare share : chainMap.get(accId).Shares) {
              if(share.UserOrGroupId == userId) {
                deleteAccountShareList.add(share);
              }
            }
        }
    }
     if(!deleteAccountShareList.isEmpty()) {
        delete deleteAccountShareList;
    }
    /*chainMap = getChainAccountRelatedATM(chainAccList, FSConstants.RECORD_TYPE_CHAIN);
     //method used to delete existing share records(Only Manual share records)
    List<AccountTeamMember__c> atmList = deleteExistingShareRecords(chainMap.values());
    if(!atmList.isEmpty()) {
      //method used to insert share records
      insertShareRecords(atmList);
    }*/
  }

   /**
    * @MethodName - createShareRecordsForHQAccount()
    * @Description - It is used to create/delete share records for chain Account
    * @Param - List<AccountTeamMember__c>
    * @Return - void
    * @Story/Task - S-274864/T-367311
    */
  public static Map<Id,Id> createShareRecordsForHQAccount(set<Id> accountIdSet) {
    List<AccountTeamMember__c> atmList = new List<AccountTeamMember__c>();
    Map<Id,Id> hqAndChainMap = new Map<Id,Id>();
    //method used to get chain account with Account team member
    List<Account> accountList = getAccountRelatedATM(accountIdSet, FSConstants.RECORD_TYPE_HQ);
    //method used to delete existing share records(Only Manual share records)
    atmList = deleteExistingShareRecords(accountList);

    //this block used to create temp record for chain account
    accountIdSet = new Set<Id>();
    for(Account acc: accountList) {
        accountIdSet.add(acc.id);
        if(acc.FS_Chain__c != null) {
          hqAndChainMap.put(acc.Id, acc.FS_Chain__c);
        }
    }
    if(!accountIdSet.isEmpty()) {
      createTempHQAccount(accountIdSet);
    }

    if(!atmList.isEmpty()) {
      //method used to insert share records
      insertShareRecords(atmList);
    }

    return hqAndChainMap;
  }

   /**
    * @MethodName - getAccountRelatedATM()
    * @Description - used to get account with account team member
    * @Param - Boolean
    * @Return - List<Account>
    * @Story/Task - S-274864/T-367311
    */
   private static List<Account> getAccountRelatedATM(set<Id> accountIdSet,Id recordTypeId) {
    String queryStr = 'SELECT id,FS_Chain__c,OwnerId,'
                       + ' (SELECT Id,AccountId,UserOrGroupId FROM Shares Where RowCause = \'Manual\'),'
                       + ' (SELECT Id,AccountId__c,UserId__c, AccountId__r.OwnerId,Count__c'
                       + ' FROM AccountTeamMembers__r where UserId__r.IsActive = true)'
                       + ' FROM Account WHERE Id IN : accountIdSet'
                       + ' AND RecordTypeId = \''+ recordTypeId + '\'';

    return database.query(queryStr);
   }

    /**
    * @MethodName - getChainAccountRelatedATM()
    * @Description - used to get Chain account with account team member
    * @Param - Boolean
    * @Return - List<Account>
    * @Story/Task - S-274864/T-367312
    */
   private static Map<Id, Account> getChainAccountRelatedATM(List<Id> accountIdSet,Id recordTypeId) {
    Map<Id, Account> chainAccountMap = new Map<Id, Account>([SELECT id,FS_Chain__c,OwnerId,
                        (SELECT Id,AccountId,UserOrGroupId FROM Shares Where RowCause = 'Manual'),
                       (SELECT Id,AccountId__c,UserId__c, AccountId__r.OwnerId,Count__c
                        FROM AccountTeamMembers__r where UserId__r.IsActive = true)
                        FROM Account WHERE Id IN : accountIdSet
                        AND RecordTypeId =: recordTypeId]);

    return chainAccountMap;
   }

   /**
    * @MethodName - deleteExistingShareRecords()
    * @Description - It is used to delete share records for chain Account
    * @Param - List<Account>
    * @Return - List<AccountTeamMember__c>
    * @Story/Task - S-274864/T-367311
    */
  public static List<AccountTeamMember__c> deleteExistingShareRecords(List<Account> accountList) {
    List<AccountShare> accountShareList = new List<AccountShare>();
    List<AccountTeamMember__c> atmList = new List<AccountTeamMember__c>();

    for(Account acc : accountList) {
          accountShareList.addAll(acc.Shares);
          atmList.addAll(acc.AccountTeamMembers__r);
    }

    if(!accountShareList.isEmpty()) {
        delete accountShareList;
    }
    return atmList;
  }

  /**
    * @MethodName - insertShareRecords()
    * @Description - It is used to create share records for chain Account
    * @Param - List<AccountTeamMember__c>
    * @Return - void
    * @Story/Task - S-274864/T-367311
    */
  public static void insertShareRecords(List<AccountTeamMember__c> atmList) {
    List<AccountShare> accountShareList = new List<AccountShare>();
    for(AccountTeamMember__c atm : atmList){
         //if condition used to check account's owner Id should not equal to userId
          if(atm.AccountId__r.OwnerId != atm.UserId__c) {
            accountShareList.add(new AccountShare(AccountAccessLevel = 'Edit',
                                                  OpportunityAccessLevel = 'Edit',
                                                  AccountId = atm.AccountId__c,
                                                  UserOrGroupId = atm.UserId__c
                                                  ));
          }
    }

    if(!accountShareList.isEmpty()) {
        insert accountShareList;
    }
   
  }

  /**
    * @MethodName - createTempHQAccount()
    * @Description - It is used to delete share records for chain Account
    * @Param - Set<Id>
    * @Story/Task - S-274864/T-367311
    */
   private static void createTempHQAccount(Set<Id> accountIdSet) {
     List<Temp_Chain_Account__c> tempAccountList = new List<Temp_Chain_Account__c>();
     Map<Id, Id> HqMap = new Map<Id, Id>();
     List<Temp_Chain_Account__c> tempAccList = [SELECT Id, Name
                                                FROM Temp_Chain_Account__c
                                                WHERE Name IN: accountIdSet];
     //loop used to avoid duplicate records
     for(Temp_Chain_Account__c temp : tempAccList) {
        HqMap.put(temp.Name, temp.Id);
     }

     for(Id accId : accountIdSet) {
        if(!HqMap.containsKey(accId)){
          tempAccountList.add(new Temp_Chain_Account__c(Name = String.valueOf(accId)));
        }
     }
    
     insert tempAccountList;
   }

  //----------------------------------------------------------------------------
  // T-217392: Method to copy all account team members to outlet lookups
  //----------------------------------------------------------------------------
  private static void copyAccountMembersOnOutletLookups (List<AccountTeamMember__c> newList) {
    List<Account> outletList = new List<Account>();
    Set<Id> accountIds = new Set<Id>();
    String TEAMROLE_COM = 'COM';
    String TEAMROLE_PIC = 'PIC';
    Account acc;
    for (AccountTeamMember__c atm : newList) {
        if (atm.UserId__c <> null && atm.AccountId__c <> null) {
            acc = new Account(ID = atm.AccountId__c);
            if(!accountIds.contains(atm.AccountId__c)) {
                accountIds.add(atm.AccountId__c);
                if (atm.TeamMemberRole__c == TEAMROLE_COM) {
                    acc.FS_COM__c = atm.UserId__c;
                    outletList.add(acc);
                } else if (atm.TeamMemberRole__c == TEAMROLE_PIC) {
                    acc.FS_PIC__c = atm.UserId__c;
                    outletList.add(acc);
                }
            }
        }
    }

    if (!outletList.isEmpty()) {
        update outletList;
    }
  }
}