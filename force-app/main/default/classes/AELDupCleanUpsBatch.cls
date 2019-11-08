/******************************************************************************************
Name         :AELDupCleanUpsBatch (Apex Error Logger Duplicate Records Cleanup Batch)
Created Date :1st March,2017
Usage        :Batch class to remove duplicate records for Apex Error Logger

*******************************************************************************************/ 
global class AELDupCleanUpsBatch implements Database.Batchable<sObject>,Database.Stateful{

  global String query;
  /****************************************************************************
  //Start the batch
  /***************************************************************************/ 
  global Database.QueryLocator start(Database.BatchableContext bc){
    query = 'SELECT Id FROM Apex_Error_Log__c where Duplicate_Error__c= True';
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
        List<Apex_Error_Log__c> listToDelete= (List<Apex_Error_Log__c>)lstApexErrorLogger;
        
        Database.DeleteResult[] deleteRec = Database.delete(listToDelete,false);
 			for (Database.DeleteResult dr : deleteRec) {
		    	if (!dr.isSuccess()) {        
                    for(Database.Error err : dr.getErrors()) {                   
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