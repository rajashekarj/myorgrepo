//
// (c) 2015 Appirio, Inc.
//
// Test Class for FSSellingActivityHandler class
//
// January 7th, 2015   Sidhant Agarwal     Ref No. I-144960
//
@isTest
private class FSSellingActivityHandlerTest {
    static User user, user1, user2; 
    static testMethod void createdDateAndByTest() {
        List<User> lstUserToInsert = new List<User>();
        Decimal avgDispenser;
        Selling_Activity__c activityObject;
        user = FSTestUtil.createUser(null,0,FSConstants.systemAdmin, false);
        lstUserToInsert.add(user);
        user1 = FSTestUtil.createUser(null,1,FSConstants.systemAdmin, false);
        lstUserToInsert.add(user1);
        user2 = FSTestUtil.createUser(null,2,FSConstants.systemAdmin, false);
        lstUserToInsert.add(user2);
        insert lstUserToInsert;
        
        system.runAs(user){
             Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
       
       disableTriggerSetting.name='FSSellingActivityHandler';
       disableTriggerSetting.IsActive__c=false;
       disableTriggerSetting.Trigger_Name__c='FSSellingActivity' ; 
       insert disableTriggerSetting;   
            Account accountHQ1 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
            Selling_Activity_Market__c marketActivityObject = new Selling_Activity_Market__c();
            marketActivityObject.Name='test';
            marketActivityObject.Dispenser_Model__c='7000';
            marketActivityObject.Market_Activation_Date__c = System.today().addDays(4);
            insert marketActivityObject;
            
            activityObject=new Selling_Activity__c();
            activityObject.Market_Name__c = marketActivityObject.Id;
            activityObject.FS_Of_Outlets_For_Launch__c=10;
            activityObject.Disp_Configuration__c='Extended Splash plate no legs';
            activityObject.Average_Dispenser__c = 10;
            activityObject.FS_Headquarter__c=accountHQ1.Id;
            activityObject.Selling_Status__c='Pre-sold';
            activityObject.Requested_Accelerated_Market_Activation__c=System.today().addDays(2);
            insert activityObject;
            
            avgDispenser = activityObject.Average_Dispenser__c;
            
        }
        system.runAs(user2) {
            activityObject.Average_Dispenser__c = 2;
            activityObject.Selling_Status__c='Accepted';
            update activityObject;
            
            
            Test.startTest();
            system.assertNotEquals(activityObject.Average_Dispenser__c,avgDispenser);
            Test.stopTest();
        }
    } 
     static testMethod void createdDateAndByTest1() {
        List<User> lstUserToInsert = new List<User>();
        Decimal avgDispenser;
        Selling_Activity__c activityObject;
        user = FSTestUtil.createUser(null,0,FSConstants.systemAdmin, false);
        lstUserToInsert.add(user);
        user1 = FSTestUtil.createUser(null,1,FSConstants.systemAdmin, false);
        lstUserToInsert.add(user1);
        user2 = FSTestUtil.createUser(null,2,FSConstants.systemAdmin, false);
        lstUserToInsert.add(user2);
        insert lstUserToInsert;
        
        system.runAs(user){
             Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
       			disableTriggerSetting.name='FSSellingActivityHandler';
       			disableTriggerSetting.IsActive__c=true;
       			disableTriggerSetting.Trigger_Name__c='FSSellingActivity' ; 
       			insert disableTriggerSetting;   
            
            Account accountHQ1 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
            Selling_Activity_Market__c marketActivityObject = new Selling_Activity_Market__c();
            marketActivityObject.Name='test';
            marketActivityObject.Dispenser_Model__c='7000';
            marketActivityObject.Market_Activation_Date__c = System.today().addDays(4);
            insert marketActivityObject;
            
            activityObject=new Selling_Activity__c();
            activityObject.Market_Name__c = marketActivityObject.Id;
            activityObject.FS_Of_Outlets_For_Launch__c=10;
            activityObject.Disp_Configuration__c='Extended Splash plate no legs';
            activityObject.Average_Dispenser__c = 10;
            activityObject.FS_Headquarter__c=accountHQ1.Id;
            activityObject.Selling_Status__c='Pre-sold';
            activityObject.Requested_Accelerated_Market_Activation__c=System.today().addDays(2);
            insert activityObject;
            
            avgDispenser = activityObject.Average_Dispenser__c;
            
        }
        system.runAs(user2) {
            activityObject.Average_Dispenser__c = 2;
            activityObject.Selling_Status__c='Accepted';
            update activityObject;
            
            
            Test.startTest();
            system.assertNotEquals(activityObject.Average_Dispenser__c,avgDispenser);
            Test.stopTest();
        }
    }   

     /*       @testSetup  
     static void mytestSetup() {
       Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
       
       disableTriggerSetting.name='FSSellingActivityHandler';
       disableTriggerSetting.IsActive__c=true;
       disableTriggerSetting.Trigger_Name__c='FSSellingActivity' ; 
       insert disableTriggerSetting;   
      }  */        
}