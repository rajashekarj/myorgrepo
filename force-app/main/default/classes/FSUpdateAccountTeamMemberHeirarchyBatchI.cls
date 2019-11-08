/******************************************************************************************
 *  Purpose : Batch class add the Account Team Members to the Account Heirarchy on Insert event
 *  Author  : Pitamber (Appirio)
 *  Date    : 04/22/2014
*******************************************************************************************/
//
// 3rd March 2015   Modified   Kirti Agarwal    Ref(S-274864/T-367311)
// Purpose : Create account team member and share records for Chain's hierarchy Accounts
//
global class FSUpdateAccountTeamMemberHeirarchyBatchI implements Database.Batchable<sObject>, Database.Stateful{

    Map<Id,List<AccountTeamMember__c>> mapAccsTeamMembers;
    /****************************************************************************
    //Intialize the batch
    /***************************************************************************/

    public FSUpdateAccountTeamMemberHeirarchyBatchI(){
    }

    /****************************************************************************
    //Start the batch and query
    /***************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> updatedHqAcc = new List<String>();
        mapAccsTeamMembers = new Map<Id,List<AccountTeamMember__c>>();
        //get the list of stored updated chain account
        List<Temp_Chain_Account__c> hqAccList = [SELECT Id, Name
                                                    FROM Temp_Chain_Account__c];
        for(Temp_Chain_Account__c acc : hqAccList) {
            updatedHqAcc.add(acc.Name);
        }

        //create map for account Id and its atm list
        for(AccountTeamMember__c atm :[SELECT UserId__c,
                                              AccountId__c,
                                              TeamMemberRole__c,
                                              AccountId__r.OwnerId
                                           FROM AccountTeamMember__c
                                           WHERE AccountId__c IN: updatedHqAcc ]) {

            if(mapAccsTeamMembers.containsKey(atm.AccountId__c)){
                mapAccsTeamMembers.get(atm.AccountId__c).add(atm);
            }else{
                mapAccsTeamMembers.put(atm.AccountId__c,new List<AccountTeamMember__c>{atm});
            }
          }

        //return all the account related to this updated chain account list
        return Database.getQueryLocator([SELECT  Id, RecordTypeId, OwnerId,
                                                 FS_Chain__c, FS_Chain__r.OwnerId,
                                                 FS_Chain__r.recordTypeId,
                                                 FS_Headquarters__c,
                                                 FS_Headquarters__r.recordTypeId,
                                                 FS_Headquarters__r.OwnerId,
                                                 FS_Headquarters__r.FS_Chain__c,
                                                 FS_Headquarters__r.FS_Chain__r.RecordTypeId,
                                                 FS_Headquarters__r.FS_Chain__r.OwnerId
                                               FROM Account
                                               WHERE FS_Headquarters__c IN :updatedHqAcc
                                               AND RecordTypeId =: FSConstants.RECORD_TYPE_OUTLET]);

    }

    /****************************************************************************
    //Process a batch
    /***************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> accountList){
         Set<Id> accountIdSet = new Set<Id>();

         //Delete Existing Share records for hierarchy accounts
         for(Account acc : (List<Account>)accountList) {
            accountIdSet.add(acc.Id);
         }
         List<Account> accList = getAccountRelatedATM(accountIdSet);
         List<AccountTeamMember__c> atmList = FSAccountTeamMemberTriggerHandler.deleteExistingShareRecords(accList);

         //Delete Existing Account Team Member for hierarchy accounts
         if(!atmList.isEmpty()) {
            delete atmList;
         }

         //Recreate Account Team Member for  hierarchy accounts.
         atmList = new List<AccountTeamMember__c>();

         Id accId ;
         for(Account acc : (List<Account>)accountList) {
            if(mapAccsTeamMembers.containsKey(acc.FS_Headquarters__c)) {
                accId = acc.FS_Headquarters__c;
            }
            if(accId != null) {
                for(AccountTeamMember__c atm : mapAccsTeamMembers.get(accId)) {
                        AccountTeamMember__c atmRec = atm.clone();
                        atmRec.AccountId__c = acc.id;
                        atmList.add(atmRec);
                }
            }
         }


         if(!atmList.isEmpty()) {
            insert atmList;
         }
         //Recreate Share records for  hierarchy accounts.
         insertShareRecords(atmList);
    }

    /****************************************************************************
    //finish the batch
    /***************************************************************************/
    global void finish(Database.BatchableContext BC){
        if([SELECT count() FROM Temp_Chain_Account__c] > 0){
           delete [SELECT Id, Name FROM Temp_Chain_Account__c];
        }
    }

    /**
    * @MethodName - insertShareRecords()
    * @Description - It is used to create share records
    * @Param - List<AccountTeamMember__c>
    * @Return - void
    * @Story/Task - S-274864/T-367311
    */
  public static void insertShareRecords(List<AccountTeamMember__c> atmList) {
    List<AccountShare> accountShareList = new List<AccountShare>();
    Set<Id> accountIdSet = new Set<Id>();

    for(AccountTeamMember__c atm : atmList){
        accountIdSet.add(atm.AccountId__c);
    }
    //map created to get the Owner Id Of Account in case of batch class
    Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, OwnerId
                                                      FROM Account
                                                      WHERE Id IN: accountIdSet]);

    for(AccountTeamMember__c atm : atmList){
         //if condition used to check account's owner Id should not equal to userId
          if(accountMap.containsKey(atm.AccountId__c) && accountMap.get(atm.AccountId__c).OwnerId != atm.UserId__c) {
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
    * @MethodName - getChainAccountRelatedATM()
    * @Description - used to get Chain account with account team member
    * @Param - Boolean
    * @Return - List<Account>
    * @Story/Task - S-274864/T-367311
    */
   public static List<Account> getAccountRelatedATM(Set<Id> accountIdSet) {
    //+ ' (SELECT Id FROM Shares Where RowCause != \'Owner\' AND RowCause != \'Rule\' ),'
    String queryStr = 'SELECT id,'
                       + ' (SELECT Id FROM Shares Where RowCause = \'Manual\' ),'
                       + ' (SELECT Id,AccountId__c,UserId__c, AccountId__r.OwnerId'
                       + ' FROM AccountTeamMembers__r)'
                       + ' FROM Account WHERE Id IN : accountIdSet';

    return database.query(queryStr);
   }

}