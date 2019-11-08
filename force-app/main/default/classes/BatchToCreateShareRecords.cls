global without sharing class BatchToCreateShareRecords implements Database.Batchable<sObject>{
    public Set<String> countries;
    public Set<String> bottlers;
    public Set<Id> userIds;
    public String qry;
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(countries != null && countries.size() > 0){
            qry = 'SELECT id, name,ownerId,ShippingCountry,Bottler_Name__c FROM Account WHERE shippingCountry in :countries';                
        }
        if(bottlers != null && bottlers.size() > 0){
            qry += ' and bottler_Name__c in :bottlers ';
        }
        
        qry += ' AND RecordTypeID in (\'' + FSConstants.RECORD_TYPE_OUTLET + '\','; 
        qry += '\'' + FSConstants.RECORD_TYPE_HQ + '\',';
        qry += '\'' + FSConstants.RECORD_TYPE_CHAIN + '\')';
        if(Test.isRunningTest()){
            qry +=' LIMIT 100';
        }
        return Database.getQueryLocator(qry);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
               
            List<Account> accList = (List<Account>) scope;
            String accessLevel = 'Read';
            List<AccountShare> accountShareList = new List<AccountShare>();
            List<User> users = [SELECT dispenser_read_edit__c,Dispenser_Country__c, Ownership__c, Ownership_Type__c, id From User where Id in :userIds ];
            for(User usr : users){
                if(usr.dispenser_read_edit__c != null){
                    accessLevel = usr.dispenser_read_edit__c;
                }
                for(Account acc : accList){
                    if(usr.Ownership_Type__c == FSConstants.BusinessUnit){
                        if(usr.Dispenser_Country__c != null
                        && acc.ShippingCountry != null
                        && usr.Dispenser_Country__c.contains(acc.ShippingCountry)
                        && usr.Ownership__c == null
                        && (acc.Bottler_Name__c == null || acc.Bottler_Name__c == '')){
                            system.debug('Access Level : ' + accessLevel);
                            AccountShare accShare = new AccountShare(userOrGroupId = usr.id,AccountId = acc.id,AccountAccessLevel = accessLevel,opportunityAccessLevel = 'Read');
                          
                            accountShareList.add(accShare);
                        }
                    }else if(usr.Ownership_Type__c == FSConstants.bottler){
                        if(usr.Dispenser_Country__c != null
                        && acc.ShippingCountry != null
                        && usr.Ownership__c != null
                        && acc.Bottler_Name__c != null
                        && usr.Ownership__c.contains(acc.Bottler_Name__c)
                        && usr.Dispenser_Country__c.contains(acc.shippingCountry)){
                            system.debug('Access Level : ' + accessLevel);
                            AccountShare accShare = new AccountShare();
                            accShare.userOrGroupId = usr.id;
                            accShare.AccountId = acc.id;
                            accShare.AccountAccessLevel = accessLevel;
                            accShare.opportunityAccessLevel = 'Read';
                            accountShareList.add(accShare);
                        }
                    }
                }
            }
            if(accountShareList.size() > 0){
                List<Database.SaveResult> sr = Database.insert(accountShareList, false);
            }                   
        
    }

    
    global void finish(Database.BatchableContext BC){

    }

}