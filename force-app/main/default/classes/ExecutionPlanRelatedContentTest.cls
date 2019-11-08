/*************************************************************************************************** 
Name         : ExecutionPlanRelatedContentTest
Created By   : Sunil(Appiro)
Created Date : Dec 16, 2013
Usage        : Unit test coverage of ExecutionPlanRelatedContent
***************************************************************************************************/
@isTest 
private class ExecutionPlanRelatedContentTest{
    //------------------------------------------------------------------------------------------------
    // Unit Test Method 1
    //------------------------------------------------------------------------------------------------
    private static testMethod void  testUnit(){
        // Create Chain Account
        final Account accChain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
               
        // Create Headquarter Account
        final Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
		      
        // Create Outlets
        final Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet.FS_Approved_For_Execution_Plan__c = true;
        accOutlet.FS_Chain__c = accChain.Id;
        accOutlet.FS_Headquarters__c = accHQ.Id;  
        accOutlet.FS_ACN__c = 'outletACN';
        insert accOutlet;        
        
        // Create Execution Plan
        final FS_Execution_Plan__c excPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id, true);      
        // Create Installation
        FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,excPlan.Id, accOutlet.Id, true);
          
        //Create FeedItem
        final FeedItem feeditem = new FeedItem();
       // final List<FeedItem> feeditem = new List<FeedItem>();
        feeditem.Title = 'Feeditem';
        feeditem.ParentId = accHQ.Id;
        feeditem.Type ='ContentPost';
        feeditem.ContentFileName = 'Newfile';
        feeditem.ContentData = blob.toPDF('This is a test string');
        insert feeditem;     
        
                        
        Test.startTest();
        // Initialize Page paramteres
        System.currentPageReference().getParameters().put('id', excPlan.Id);
        final apexpages.Standardcontroller standCon = new apexpages.Standardcontroller(excPlan);
        final ExecutionPlanRelatedContent obj = new ExecutionPlanRelatedContent(standCon);
        obj.prepareFeedItemList();
        
        // Verify Results
        System.assert(obj.feedItems != null);
        Test.stopTest();
    }
}