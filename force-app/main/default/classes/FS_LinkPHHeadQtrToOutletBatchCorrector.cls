global class FS_LinkPHHeadQtrToOutletBatchCorrector implements Database.Batchable<sObject>,Database.Stateful {

global String query;
public Map<Id,String> placeHolderHQName=new Map<Id,String>();
public Id accOutletRecordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId();
   
   global FS_LinkPHHeadQtrToOutletBatchCorrector (String q) {
     
       query = q;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
       
       query='select Id,Name,FS_SAP_ID__c  from Account where RecordTypeId=:accOutletRecordtypeId and FS_Headquarters__c=null and FS_Chain__c!=null and (NOT FS_Chain__r.Name LIKE \'%' +'CH\')';
       system.debug('The SOQL is '+query );
       return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accList=new List<Account>();
        for(Account acc: scope){
           placeHolderHQName.put(acc.Id,acc.FS_SAP_ID__c+'PH');
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
      Database.executeBatch(new FS_LinkPHHeadQtrToOutletBatchCorrector2(placeHolderHQName));
    }
}