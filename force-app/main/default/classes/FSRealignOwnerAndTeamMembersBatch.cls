/******************************************************************************************
 *  Purpose : Batch class to create Account Team Members.
 *  Author  : Mohit Parnami
 *  Date    : 15/10/2013
*******************************************************************************************/ 
global class FSRealignOwnerAndTeamMembersBatch  implements Database.Batchable<sObject>,  Database.Stateful{
        
        global String Query;
        /****************************************************************************
        //Intialize the batch
        /***************************************************************************/ 
    public FSRealignOwnerAndTeamMembersBatch(){
            query = 'Select Id, FS_Market_ID__c, OwnerId From Account';
                if(system.Test.isRunningTest()){
                    query += ' LIMIT 150';
                }
                system.debug('==Query ==' + query);
            }
     
    /****************************************************************************
    //Start the batch annd query cases according to filters added
    /***************************************************************************/ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    /****************************************************************************
    //Process a batch
    /***************************************************************************/ 
    global void execute(Database.BatchableContext BC, List<sObject> lstAccount){
        List<Account> accountList =  (List<Account>) lstAccount;
        FSAlignAccountTeamMembersUtility.alignAccountTeam(accountList, false); 
    }
    
    /****************************************************************************
    //finish the batch 
    /***************************************************************************/ 
    global void finish(Database.BatchableContext BC){
        
    }
}