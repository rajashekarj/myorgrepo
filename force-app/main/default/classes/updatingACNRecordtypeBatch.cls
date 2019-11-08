global class updatingACNRecordtypeBatch implements Database.Batchable<sObject>,Database.Stateful{

   Map<Id, String> errorMap = new Map<Id, String>();
    Map<Id, SObject> IdToSObjectMap =  new Map<Id, SObject>();


/****************************************************************************
  //Start the batch
  /***************************************************************************/ 
global Database.QueryLocator start(Database.BatchableContext bc){


return Database.getQueryLocator([Select id,FS_ACN__c,Recordtypeid, CCR_ACN_RecordType_Id__c from Account where FS_ACN__c!=null and CCR_ACN_RecordType_Id__c like '%xho%' and AutorabitExtId__c!=null]);
 //return Database.getQueryLocator([Select id,FS_ACN__c,Recordtypeid, CCR_ACN_RecordType_Id__c from Account where FS_ACN__c!=null limit 30]);
}


  /****************************************************************************
  // Execute Batch 
  /***************************************************************************/ 
global void execute(Database.BatchableContext bc, List<sObject> scope){

List<Account> accountsTobeUpdated=new List<Account>();
Map<id,Account> accountupdateMap = new Map<id,Account>();
Map<Id,Account> accountMap=new Map<Id,Account>((List<Account>)scope);
string Acn;
System.debug('account map*****'+accountMap);

for(Account acc1:  (List<Account>)scope){
        if(accountMap.containskey(acc1.id))
        {
        Acn =accountMap.get(acc1.id).FS_ACN__c;

                if(Acn.length()==10)      
                {
                //Acn = Acn.substring(1, Acn.length() - 1);
                Acn = Acn.substring(1);
                }
                else{
                Acn =accountMap.get(acc1.id).FS_ACN__c;
                }
              acc1.CCR_ACN_RecordType_Id__c=Acn+'-'+accountMap.get(acc1.id).Recordtypeid;
              accountsTobeUpdated.add(acc1);
            // accountupdateMap.put(acc1.id,acc1);
              //System.debug('Accounts to be updated count '+accountupdateMap.size());
         
        }
     }
       system.debug('accountsTobeUpdated*****'+accountsTobeUpdated.size());
        
          if(accountsTobeUpdated.size() > 0) {
            List<Database.SaveResult> dsrs = Database.Update(accountsTobeUpdated, false);
          //  List<Database.SaveResult> dsrs = Database.update(accountupdateMap.values(),false);
            
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                System.debug('test1***'+errorMap);
                    String errMsg = dsr.getErrors()[0].getMessage();
                    errorMap.put(accountsTobeUpdated[index].Id, errMsg);
                    IdToSObjectMap.put(accountsTobeUpdated[index].Id, accountsTobeUpdated[index]);
                }
                index++;
            }
            System.debug('errorMap1***'+errorMap);
            accountsTobeUpdated.clear();
          } 
     
      //  try{
            //if(accountsTobeUpdated.size()>0)
            //{
            //update accountsTobeUpdated;
            //}
    //  }
        //catch(exception ex){
        
        //}

}


  /****************************************************************************
  //finish the batch 
  /***************************************************************************/ 
  global void finish(Database.BatchableContext BC) {
  System.debug('errorMap***'+errorMap);
  System.debug('errorMapSize***'+errorMap.size());
        if(!errorMap.isEmpty()){
           
            
            String finalstr = 'Id, Name, Error \n';
            
            for(Id id  : errorMap.keySet())
            {
                string err = errorMap.get(id);
                Account acct = (Account) IdToSObjectMap.get(id);
                //string recordString = '"'+id+'","'+acct.Name+'","'+acct.FS_ACN__c+'","'+acct.Recordtypeid+'","'+err+'"\n';
                string recordString = '"'+acct.id+'"\n';
                
                finalstr = finalstr +recordString;
                
            } 
 
           
   system.debug('..error string..' + finalstr );
        
        
    }
        
  }

}