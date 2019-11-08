/*************************************************************************************************** 
Name         : FSHistoryTrackingTest
Usage        : Unit test coverage of FSHistoryTracking
***************************************************************************************************/
@isTest 
private class FSHistoryTrackingTest {
    static testMethod void  HistoryTrackingTest(){
        
        List< FS_Tracking_History__c> itemList=new List<FS_Tracking_History__c>(); 
        
        Case parentCase = new Case(Subject='Test Controller Acct Case');
        parentCase.Issue_Name__c = 'Issue Name';
        
        insert parentCase;
        
        FS_Tracking_History__c item = new FS_Tracking_History__c();       
        item.CreatedById = Userinfo.getUserId();
        item.CreatedDate = System.today();
        item.Object_Name__c = 'Case';
        item.Field__c = 'Status';      
        item.Old_Value__c = 'New';
        item.New_Value__c = 'Complete';
        item.Parent_Id__c = parentCase.id;
        itemList.add(item);
        
        
        FS_Tracking_History__c item2 = new FS_Tracking_History__c();       
        item2.CreatedById = Userinfo.getUserId();
        item2.CreatedDate = System.today();
        item2.Object_Name__c = 'Case';
        item2.Field__c = 'AssignmentOwner';      
        item2.Old_Value__c = 'Joe';
        item2.New_Value__c = 'Bob';
        item2.Parent_Id__c = parentCase.id;
        
        itemList.add(item2);
        
        insert itemList;  
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.startTest();   
            ApexPages.StandardController stdCaseController = new ApexPages.StandardController(parentCase);
            FSHistoryTracking caseController = new FSHistoryTracking(stdCaseController);
            system.assertEquals(2,caseController.HistoryItems.size());
            Test.stopTest();
        }
    }
}