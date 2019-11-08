/********************************************************************************************************* 
Name         : FSFeedItemHandlerTest
Created By   : Pallavi Sharma (Appiro)
Created Date : 24 - Sep - 2013
Usage        : Unit test coverage of FSFeedItemHandler
***********************************************************************************************************/
@isTest 
private class FSFeedItemHandlerTest {
    //Headquarter Account
    static Account accHeadQtr; 
    static Account accChain;
    
    //Create Test Data
    static void createTestData(){
        accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        accHeadQtr = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHeadQtr.FS_Chain__c = accChain.Id;
        insert accHeadQtr;
    }
  
  //Test Method  
    static testMethod void  testUnit(){
        createTestData();
        Test.startTest();
        //Create Feed Item for Chain Account
        FeedItem fi = new FeedItem();
        fi.Title = 'test';
        fi.Body = 'test body';
        fi.ParentId = accChain.Id;
        insert fi;
        
        List<FeedItem> lstFeedItem = [Select title From FeedItem Where ParentId =: accHeadQtr.Id];
        system.assertEquals(lstFeedItem.size(), 1);
        
        //Delete FeedItem of chain
        delete fi;
        
        List<FeedItem> lstDeletedFeedItem = [Select title From FeedItem Where ParentId =: accHeadQtr.Id];
        system.assertEquals(lstDeletedFeedItem.size(), 0);
        Test.stopTest();
    }
            @testSetup  
     static void mytestSetup() {
       Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
       
       disableTriggerSetting.name='FSFeedItemHandler';
       disableTriggerSetting.IsActive__c=true;
       disableTriggerSetting.Trigger_Name__c='FSCopyToHeadquarter' ; 
       insert disableTriggerSetting;   
      }    
      
}