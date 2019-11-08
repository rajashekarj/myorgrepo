@isTest
public class FSPaginationCustomIterableTest {
    public static string valId='id';
    public static String testVal='test';
    public Static Id RECTYPEHQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Headquarters');
    public static CIF_Header__c cifHead;
    @testSetup
    private static void loadTestData(){
        Integer numb=0;
        FSTestFactory.createTestDisableTriggerSetting();
        final List<Account> hqCustomerList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        final List<Account> outletCustList= FSTestFactory.createTestAccount(false,20,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        for(Account acc:outletCustList){
            acc.FS_Headquarters__c = hqCustomerList.get(0).id;
            acc.FS_ACN__c = '0001673'+numb;
            numb++;
        }
        Insert outletCustList;
        //Create cifHead
        cifHead = new CIF_Header__c();
        cifHead.Name =hqCustomerList[0].name+' V.0';
        cifHead.FS_Version__c = 10.02;
        cifHead.FS_HQ__c=hqCustomerList[0].id;
        insert cifHead;
    } 
    private static testMethod void testPageinationNext(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        system.runas(sysAdmin)
        {
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        FSPaginationCustomIterable pageNation;
        List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        
        controller.onLoad();
        pageNation  = new FSPaginationCustomIterable(controller.lstOutlet);
        pageNation.setPageSize=10;
        pageWrpOutlet=pageNation.next();
        system.assertEquals(pageWrpOutlet.size(),10);
        pageWrpOutlet=pageNation.next();
        //  final Integer pageInd=pageNation.PageIndex;
        // final Integer offset=pageNation.Offset;
        // final Integer lNumber=pageNation.LNumber;
        // final Integer uNumber=pageNation.UNumber;
        pageWrpOutlet=pageNation.next();
        }
        Test.stopTest();
    } 
    private static testMethod void testPageinationPrevious(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterable pageNation;
        List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        pageNation  = new FSPaginationCustomIterable(controller.lstOutlet);
        pageNation.setPageSize=10;
        system.assertEquals(pageWrpOutlet.size(),0);
        Test.stopTest();
        }
    }
    private static testMethod void testPageinationLast(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterable pageNation;
        List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        pageNation  = new FSPaginationCustomIterable(controller.lstOutlet);
        pageNation.setPageSize=10;
        pageWrpOutlet=pageNation.last();
        system.assertEquals(pageWrpOutlet.size(),10);
        Test.stopTest();
        }
    } 
    private static testMethod void testPageinationFirst(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterable pageNation;
        List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        pageNation  = new FSPaginationCustomIterable(controller.lstOutlet);
        pageNation.setPageSize=10;
        pageWrpOutlet=pageNation.next();
        pageWrpOutlet=pageNation.next();
        pageWrpOutlet=pageNation.first();
        system.assertEquals(pageWrpOutlet.size(),10);
        Test.stopTest();
        }
    }
    private static testMethod void testPageinationGoTo(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
         cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterable pageNation;
        List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        pageNation  = new FSPaginationCustomIterable(controller.lstOutlet);
        pageNation.setPageSize=10;
        //pageWrpOutlet=pageNation.goToPage(10,20);
        system.assertNotEquals(pageWrpOutlet.size(),10);
        Test.stopTest();
        }
    }    
    private static testMethod void testPageinationGoToINS(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
         cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterable pageNation;
        List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        pageNation  = new FSPaginationCustomIterable(controller.lstOutlet);
        pageNation.setPageSize=10;
        pageWrpOutlet=pageNation.goToPage(10,20);
        Test.stopTest();
        }
    } 
    //
    //
    private static testMethod void testPageinationGoTo1(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterableAlerts pageNation;
        List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        Task task1 = new Task();
        insert task1;
        list<task> tsk = new list<task>();
        tsk.add(task1);
        pageNation  = new FSPaginationCustomIterableAlerts(tsk);
        pageNation.setPageSize=10;
        // tsk=pageNation.goToPage(10,20);
        tsk=pageNation.first();  
        tsk=pageNation.Last(); 
        tsk=pageNation.next();
        pageNation.getPageCount();
        system.assertEquals(pageWrpOutlet.size(),0);
        Test.stopTest();
        }
    }    
    
    private static testMethod void testPageinationGoTo2(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterableAlerts pageNation;
        List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        controller.onLoad();
        Task task1 = new Task();
        insert task1;
        list<task> tsk = new list<task>();
        tsk.add(task1);
        pageNation  = new FSPaginationCustomIterableAlerts(tsk);
        pageNation.setPageSize=2;
        
        tsk=pageNation.first();  
        tsk=pageNation.Last(); 
        tsk=pageNation.next();
        pageNation.getPageCount();
        system.assertEquals(pageWrpOutlet.size(),0);
        Test.stopTest();
        }
    }  
    private static testMethod void testPageinationGoTo3(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterableAlerts pageNation;
      //  List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
       	ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        List<task> taskVal=new List<task>();
        task task2;
        for(integer i=0;i<=20;i++)
        { 
            task2 = new task();
            task2.Description=testVal;
            taskVal.add(task2);
            
        }
        insert taskVal;
        list<task> tsk = new list<task>();
        tsk.add(task2);
        pageNation  = new FSPaginationCustomIterableAlerts(taskVal);
        
        pageNation.numb=25;
        taskVal=pageNation.previous();
        
        Test.stopTest();
        system.assertNotEquals(pageNation.numb,25);
        }
    }  
    private static testMethod void testPageinationGoTo4(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterableAlerts pageNation;
    //    List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        
    //    Task task1 = new Task();
        
        List<task> taskVal=new List<task>();
        task task2;
        for(integer i=0;i<=20;i++)
        { 
            task2 = new task();
            task2.Description=testVal;
            taskVal.add(task2);
            
        }
        insert taskVal;
        list<task> tsk = new list<task>();
        tsk.add(task2);
        pageNation  = new FSPaginationCustomIterableAlerts(taskVal);
        pageNation.setPageSize=1;
        tsk=pageNation.goToPage(1,1);
        pageNation.numb=25;
        //taskVal=pageNation.previous();
        
        Test.stopTest();
        system.assertEquals(pageNation.numb,25);
        }
    }  
    private static testMethod void testPageinationGoTo5(){
        FSPaginationCustomIterableAlerts pageNation;
   //     List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
       ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        List<task> taskVal=new List<task>();
        task task2;
        for(integer i=0;i<=10;i++)
        { 
            task2 = new task();
            task2.Description=testVal;
            taskVal.add(task2);
            
        }
        insert taskVal;
        list<task> tsk = new list<task>();
        tsk.add(task2);
        pageNation  = new FSPaginationCustomIterableAlerts(taskVal);
        pageNation.setPageSize=5;
        
        pageNation.numb=10;
        taskVal=pageNation.first(); 
        taskVal=pageNation.next();
        Test.stopTest();
        system.assertEquals(pageNation.numb,10);
        }
    }  
    private static testMethod void testPageinationGoTo6(){
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        system.runas(sysAdmin)
        {
        FSPaginationCustomIterableAlerts pageNation;
   //     List<WrpOutlet> pageWrpOutlet = new List<WrpOutlet>();
        Test.startTest();
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:RECTYPEHQ limit 1];
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('Accid', parentRecord.Id);
        
       	final ApexPages.StandardController stdcon = new ApexPages.standardController(cifHead);
     	final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdcon);
        
        List<task> taskVal=new List<task>();
        task task2;
        for(integer i=0;i<=10;i++)
        { 
            task2 = new task();
            task2.Description=testVal;
            taskVal.add(task2);
            
        }
        insert taskVal;
        list<task> tsk = new list<task>();
        tsk.add(task2);
        pageNation  = new FSPaginationCustomIterableAlerts(taskVal);
        pageNation.setPageSize=5;
        
        pageNation.numb=11;
        taskVal=pageNation.previous();
        
        Test.stopTest();
        system.assertNotEquals(pageNation.numb,0);
        }
    }  
    
}