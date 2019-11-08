public class FS_CokesmartRegistrationEmailHelper{
 public static void afterInsert(){
    Set<Id> setOfWhatIds = new Set<Id>();
   
   for(Task taskObj : (List<Task>)Trigger.New){
      if(taskObj.Subject != null && taskObj.WhatId != null && taskObj.Subject.startsWith('Email') && String.valueOf(taskObj.WhatId).startsWith('001')){
         setOfWhatIds.add(taskObj.WhatId);
      }
   }
   
   List<Account> accList=new List<Account>();
   accList=[select id,FS_Cokesmart_Registration_Email_Sent__c from Account where id in:setOfWhatIds];
   
   
   for(Account acc: accList){
       if(acc.FS_Cokesmart_Registration_Email_Sent__c==null || acc.FS_Cokesmart_Registration_Email_Sent__c == ''){
           acc.FS_Cokesmart_Registration_Email_Sent__c = 'Notification #1 sent';
       }else if(acc.FS_Cokesmart_Registration_Email_Sent__c == 'Notification #1 sent'){
           acc.FS_Cokesmart_Registration_Email_Sent__c = 'Notification #1 and 2 sent';
       }else{
           acc.FS_Cokesmart_Registration_Email_Sent__c = 'Notification #1 and 2 and 3 sent';
       }
   }
   
   update accList;
 }
}