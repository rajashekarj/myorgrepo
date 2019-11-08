@isTest
public class FS_ReplacementDMTest {
	@testSetup
    static void setup() {
        Id outletId = [SELECT Id FROM RecordType WHERE Name = 'FS Outlet'].Id;
        Id newInstallId = [SELECT Id FROM RecordType WHERE Name = 'New Install' AND SObjectType = 'FS_Installation__c'].Id;
        Id epId = [SELECT Id FROM RecordType WHERE Name = 'Execution Plan'].Id;
        Account[] customer = FSTestFactory.createTestAccount(true, 1, outletId);
        FS_Execution_Plan__c[] eps = FSTestFactory.createTestExecutionPlan(customer[0].Id, true, 2, epId);
        FS_Installation__c[] replacements = FSTestFactory.createTestInstallationPlan(eps[0].Id, customer[0].Id, true, 5, FSInstallationValidateAndSet.ipRecTypeReplacement);
        CIF_Header__c cifHead = new CIF_Header__c();
        insert cifHead;
        FSTestFactory.createTestCif(customer, cifHead.Id, 1, true);
        
        List<String> reasonCodes = new List<String>{'Platform Change', 'Change of Color', 'Bridge 9000 to 9100', 'Early Replacement 9000 to 9100', 'Condemned by Sr. Tech'};
        for(Integer i = 0; i < reasonCodes.size(); i++) {
            replacements[i].FS_Reason_Code__c = reasonCodes[i];    
        }
        update replacements;
    }
    
    static testMethod void testBatchScript() {
        Test.startTest();
        Database.executeBatch(new FS_ReplacementDMBatchScript());
        Test.stopTest();
        Set<String> picklistVals = new Set<String>{'Bridge 9000 To 9100', 'Early Replacement 9000 To 9100', 'Platform Change'};
        FS_Installation__c[] replacements = [SELECT Id, FS_Reason_Code__c, FS_Same_incoming_platform__c
                                         FROM FS_Installation__c
                                         WHERE RecordType.Name = 'Replacement'
                                         AND FS_Reason_Code__c IN ('Bridge 9000 to 9100', 'Early Replacement 9000 to 9100', 'Platform Change')
                                         ORDER BY FS_Outlet__c];
        System.assertEquals(replacements.size(), 3);
        for(FS_Installation__c replacement : replacements) {
            System.assert(picklistVals.contains(replacement.FS_Reason_Code__c));
            System.assertEquals(replacement.FS_Same_incoming_platform__c, 'No');
        }
    }
    
    static testMethod void testBatchScriptAllOthers() {
        Test.startTest();
        Database.executeBatch(new FS_ReplacementDMBatchScriptAllOthers());
        Test.stopTest();
        Set<String> picklistVals = new Set<String>{'Condemned by Sr. Tech'};
        FS_Installation__c[] replacements = [SELECT Id, FS_Reason_Code__c, FS_Same_incoming_platform__c
                                         FROM FS_Installation__c
                                         WHERE RecordType.Name = 'Replacement'
                                         AND FS_Reason_Code__c IN ('Condemned by Sr. Tech')
                                         ORDER BY FS_Outlet__c];
        System.assertEquals(replacements.size(), 1);
        for(FS_Installation__c replacement : replacements) {
            System.assert(picklistVals.contains(replacement.FS_Reason_Code__c));
            System.assertEquals(replacement.FS_Same_incoming_platform__c, 'Yes');
        }
    }
}