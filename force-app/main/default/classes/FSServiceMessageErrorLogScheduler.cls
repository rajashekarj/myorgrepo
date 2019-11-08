//
// 13-Apr-2016 [Rahul, Infosys Ltd]
//
// Purpose : Schedule Service Message Error Log records for Re-processing
//
global class FSServiceMessageErrorLogScheduler implements Schedulable {

   //method used to call the batch class
   global void execute(SchedulableContext SC) {
              Integer batchSize = 1;
              Map<String, Error_Message_Resend_Counter__c> mapNameCounter = Error_Message_Resend_Counter__c.getAll();
              Error_Message_Resend_Counter__c resendNumber;
              if(mapNameCounter.containsKey('FSServiceMessageErrorBatchSize')) {
                  batchSize  = (Integer) mapNameCounter.get('FSServiceMessageErrorBatchSize').Resend_Number__c;
              }
              
              Database.executeBatch(new BatchForErrorHandling(), batchSize);
   }

}