global class FS_LinkPHHeadQtrToOutletBatchCorrector2 implements Database.Batchable<sObject>,Database.Stateful {

public Map<Id,String> placeHolderHQName2=new Map<Id,String>();
public List<String> placeHolderHQNameList=new List<String>();
public Map<Id,Account> headQtrAccounts;
public List<Account> resultList=new List<Account>();
public Id accHQRecordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Headquarters').getRecordTypeId();
   
   global FS_LinkPHHeadQtrToOutletBatchCorrector2 (Map<Id,String> placeHolderHQName) {
     
       placeHolderHQName2= placeHolderHQName;
       placeHolderHQNameList.addAll(placeHolderHQName2.values());
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
       String query='select Id,Name,FS_SAP_ID__c from Account where RecordtypeId=:accHQRecordtypeId and (NOT FS_Chain__r.Name LIKE \'%' +'CH\') '+
        ' and FS_SAP_ID__c in:placeHolderHQNameList';
       system.debug('The SOQL is '+query );
       return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accList=new List<Account>();
        headQtrAccounts = new Map<Id, Account>(scope);
        Map<String,Id> headQtrNameId=new Map<String,Id>();
        
        for(Account acc:headQtrAccounts.values()){
          headQtrNameId.put(acc.FS_SAP_ID__c,acc.Id);
        }
        
       for(String outletId: placeHolderHQName2.keySet()){
          String outletSuffix=placeHolderHQName2.get(outletId);
          if(headQtrNameId.containsKey(outletSuffix)){
             Account outletInstance=new Account(Id=outletId); 
                 outletInstance.FS_Headquarters__c=headQtrNameId.get(outletSuffix);
                 accList.add(outletInstance);
             
          }
       }
       resultList.addAll(accList);
        
        try{
           if(accList.size()>0)
            update accList;
        }
        catch(Exception e){
         system.debug('Exception Occured while updating Account Batch'+e);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
      AsyncApexJob job= [SELECT Createdby.Email,CreatedbyId FROM AsyncApexJob WHERE Id =:BC.getJobId()];
      
      Messaging.SingleEmailMessage mailNotificationStartBatch = new Messaging.SingleEmailMessage(); 
      
       Integer size=resultList.size();
       system.debug('final List Size: '+size);
       mailNotificationStartBatch.setSubject('List of Accounts Total Size'+size);
       String allaccounts='';
       for(Account acc: resultList){
          allaccounts=String.valueOf(acc.Id)+':' + String.valueOf(acc.FS_Headquarters__c)+';'+allaccounts;
       }
       mailNotificationStartBatch.setPlainTextBody(allaccounts);
       mailNotificationStartBatch.setTargetObjectId(job.CreatedById);
       mailNotificationStartBatch.saveAsActivity = false;
      
       Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailNotificationStartBatch});
       system.debug('Email Sent Successfull for corrector '+result.get(0).isSuccess());
    }
}