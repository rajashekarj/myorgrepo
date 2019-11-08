// dummy codes are updated from line no 3 to 23

global class FSupdateTransactionDataBatch7000Series implements Database.Batchable<sObject>
{

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
        String query = 'SELECT Id,Name,Phone FROM Account ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        system.debug('commit');
        for ( Account a : scope)
        {
           a.Phone='123';
        }
        update scope;
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}

/*Commenting below lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0

//Class to update transaction data of existing 7000 series Initial Order

global class FSupdateTransactionDataBatch7000Series implements Database.Batchable<sObject>,Database.Stateful {

global String query;
   
   global FSupdateTransactionDataBatch7000Series (String q) {
       query = q;
   }
   
  global Database.QueryLocator start(Database.BatchableContext BC) {
       Id RecortypeId7k = Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('7000 Series').getRecordTypeId();
       Id RecortypeIdRelocation7k = Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('Relocation 7000 Series').getRecordTypeId();   
       Id transactionDecortypeId=Schema.SObjectType.FS_Initial_Order_SAP_Data__c.getRecordTypeInfosByName().get('Initial Order Transaction Data').getRecordTypeId();
       query ='SELECT FS_Type__c from FS_Initial_Order_SAP_Data__c where Master_Data__c=false and recordtypeid =:transactionDecortypeId and (Initial_Order__r.RecordtypeId =:RecortypeId7k OR Initial_Order__r.RecordtypeId=:RecortypeIdRelocation7k)';
       system.debug('The SOQL is '+query );
       return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<FS_Initial_Order_SAP_Data__c> scope) {
        try {
         List <FS_Initial_Order_SAP_Data__c>  SAPtransData = new list <FS_Initial_Order_SAP_Data__c>();
         for(FS_Initial_Order_SAP_Data__c a : scope) {
            a.FS_Type__c ='7000 Series';
            SAPtransData.add(a);
         }
         system.debug('Updated DAta Size'+SAPtransData.size());
         Database.update(SAPtransData, true);  
        } catch(Exception exp) {
            System.debug('Exception occurred- '+exp);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
    
    } 
} */