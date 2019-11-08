@isTest
public class AELDupCheckBatchTest {
    static testmethod void createApexLogger(){
        Apex_Error_Log__c aEL1 = new Apex_Error_Log__c ();
        aEL1.Method_Name__c ='Test Method';
        aEL1.Error_Line_Number__c = 3.0;
        aEL1.Error_Message__c = 'Test Message';
        aEL1.Error_Severity__c = 'Critical';
        aEL1.Object_Name__c = 'Test Object';
        aEL1.Unique_Error__c = true;
        Insert aEL1;
        
        Apex_Error_Log__c aEL2 = new Apex_Error_Log__c ();
        aEL2.Class_Name__c='Test Class';
        aEL2.Method_Name__c='Test Method';
        aEL2.Error_Line_Number__c = 3.0;
        ael2.Error_Message__c= 'Test Message';
        ael2.Error_Severity__c = 'Critical';
        ael2.Object_Name__c = 'Test Object';
        Insert aEL2;
        
        Test.startTest();
    		Database.executeBatch(new AELDupCheckBatch());
  		Test.stopTest();
	}
}