/******************************************************************************************
Name         :AELDupCheckBatch (Apex Error Logger Duplicate Check Batch)
Created Date :22nd Feb,2017
Usage        :Batch class to Mark duplicate records for Apex Error Logger

*******************************************************************************************/ 
global class AELDupCheckBatch implements Database.Batchable<sObject>,Database.Stateful{

  global String query;
  public Set<String>  uniqueRecordsSet=new Set<String>();
    
  /****************************************************************************
  //Intialize the batch
  /***************************************************************************/    
   public AELDupCheckBatch(){
       List<Apex_Error_Log__c> aELList = [select id,Class_Name__c,Method_Name__c,Error_Line_Number__c from Apex_Error_Log__c where Unique_Error__c=true];   
       if(!aELList.isEmpty() && aELList != null){
            For(Apex_Error_Log__c ael:aELList){
                String unq=ael.Class_Name__c + ael.Method_Name__c + ael.Error_Line_Number__c;
                uniqueRecordsSet.add(unq);
            }
        }
   }

  /****************************************************************************
  //Start the batch
  /***************************************************************************/ 
  global Database.QueryLocator start(Database.BatchableContext bc){
    query = 'Select Id, Name, Application_Name__c,Class_Name__c,Error_Line_Number__c,Error_Message__c,' +
        'Error_Number__c,Duplicate_Error__c,Unique_Error__c,Error_Severity__c,Error_Stack_Trace__c,' +
        'Error_Status__c,Exception_Type__c,Method_Name__c,Notes__c,Object_Name__c FROM Apex_Error_Log__c where Unique_Error__c= false and Duplicate_Error__c=false' ;
    
      
      
    if(system.Test.isRunningTest()){
      query += ' LIMIT 100';
    }
    system.debug('Apex Error Logger Query' + query);
    return Database.getQueryLocator(query);
  }
  
  /****************************************************************************
  // Execute Batch 
  /***************************************************************************/ 
    global void execute(Database.BatchableContext bc, List<sObject> lstApexErrorLogger){
        //Set<String> uniqueRecordsSet=AELDupCheckBatch1();
        List<Apex_Error_Log__c> listToUpdate= new List<Apex_Error_Log__c>();
        
        for(Apex_Error_Log__c ael:(List<Apex_Error_Log__c>)lstApexErrorLogger){
            String unqStr= ael.Class_Name__c + ael.Method_Name__c + ael.Error_Line_Number__c;
            if(!uniqueRecordsSet.isEmpty()){
                if( uniqueRecordsSet.contains(unqStr)){
                    ael.Duplicate_Error__c = true;
                }else{
                    ael.Unique_Error__c=true;
                    uniqueRecordsSet.add(unqStr);
                }
            }else{
                 ael.Unique_Error__c=true;
                 uniqueRecordsSet.add(unqStr);
            }
			
            listToUpdate.add(ael);
        }
        
        
            Database.SaveResult[] updateRec = Database.update(listToUpdate);
 			for (Database.SaveResult sr : updateRec) {
		    	if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {                   
                        System.debug('The following error has occurred.' +err.getStatusCode() + ': ' + err.getMessage());
                    }
            	}
			}
    }
    /****************************************************************************
    //finish the batch 
    /***************************************************************************/ 
    global void finish(Database.BatchableContext BC) {  
        // Use this object(AsyncApexJob) to query Apex batch jobs in your organization.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
           TotalJobItems, CreatedBy.Email
           FROM AsyncApexJob WHERE Id =
           :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Action Required : Apex Error Logger Dup Check Failed');
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        //Sending the mail in case of failure updates
        if( a.NumberOfErrors>0 ){
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
    }
  }