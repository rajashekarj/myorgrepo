/**
 * Created By   : Satyanarayan Choudhary(JDC Developer)
 * Description  : test class for FSExecutionPlanContactTriggerHandler
 		*/
@isTest
private class FSExecutionPlanContactTriggerHandlerTest {
 
    static testMethod void testCopyExecutionPlanContactsToOutlet() {
        
        final List<Account> accList=new List<Account>();
        
        final User sysAdminUser=FSTestUtil.createUser(null, 1, FSConstants.USER_POFILE_SYSADMIN, true);
        system.runAs(sysAdminUser){
        Test.startTest();
        // create test data
        Account acc = new Account(Name = 'Test Account',RecordTypeId = FSConstants.RECORD_TYPE_OUTLET);
        accList.add(acc);
            
        final Account hqAcc = new Account(Name = 'Test HQ Account',RecordTypeId = FSConstants.RECORD_TYPE_HQ);
        accList.add(hqAcc);
        
        insert accList;
            
        final Account contactAcc = new Account(Name = 'Contact Account',RecordTypeId = FSConstants.RECORD_TYPE_OUTLET);
        insert contactAcc;
        final Contact testCon1 = new Contact(LastName = 'Test Contact',AccountId = contactAcc.Id,FS_Execution_Plan_Role__c = 'Site Assessment Contact;Coke Smart Admin User;Installation Contact');
        insert testCon1;
        
        final FS_Execution_Plan_Contact__c epCon1 = new FS_Execution_Plan_Contact__c(FS_Execution_Plan_Contact__c = testCon1.Id, Outlet__c = contactAcc.Id);
        insert epCon1;
        
        // verify functionality
       	acc= [Select Id, FS_Site_Assessment_Contact__c FROM Account WHERE Id = :contactAcc.Id];
        System.assertEquals(acc.FS_Site_Assessment_Contact__c,testCon1.Id);
        update epcon1;
        Test.stopTest();
        }
        
    }
            @testSetup  
     static void mytestSetup() {
       final Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
       
       disableTriggerSetting.name='FSExecutionPlanContactTriggerHandler';
       disableTriggerSetting.IsActive__c=true;
       disableTriggerSetting.Trigger_Name__c='FSExecutionPlanContactTrigger' ; 
       insert disableTriggerSetting;   
      }    
}