global class FS_HQSpicyCherryAgreementBatchCorrector implements Database.Batchable<sObject>,Database.Stateful {

global String query;
   
   global FS_HQSpicyCherryAgreementBatchCorrector (String q) {
     
       query = q;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
       Id accRecordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Headquarters').getRecordTypeId();
      String spicyCherryValue='Dr. Pepper/Diet Dr. Pepper';
       query='select FS_Spicy_Cherry_Agreement_for_this_HQ__c,Name from Account where FS_Spicy_Cherry_Agreement_for_this_HQ__c=:spicyCherryValue'+
             ' and RecordtypeId=:accRecordtypeId'; 
       system.debug('The SOQL is '+query );
       return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Integer count=0;
        List<Account> accList=new List<Account>();
        for(Account acc: scope){
           acc.FS_Spicy_Cherry_Agreement_for_this_HQ__c='Dr Pepper/Diet Dr Pepper';
           accList.add(acc);
        }
        system.debug('Total size'+accList.size());
        system.debug('Sample Records'+accList);
        try{
          update accList;
        }
        catch(Exception e){
         system.debug('Exception Occured while updating Account Batch'+e);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
      
    }
}