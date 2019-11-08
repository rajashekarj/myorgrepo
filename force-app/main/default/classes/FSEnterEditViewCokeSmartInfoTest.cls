/************
Name         : FSEnterEditViewCokeSmartInfoTest
Created By   : Pallavi Sharma (Appiro)
Created Date : 18 - Sep - 2013
Usage        : Unit test coverage of FSEnterEditViewCokeSmartInfoController
*********/

@isTest 
private class FSEnterEditViewCokeSmartInfoTest {
    
    public static FS_Execution_Plan__c executionPlan;
   
    //Create Test data
    private static void createTestData(){       
        
        FSTestFactory.createTestDisableTriggerSetting();
        final List<account> headquarters = new list<account>();
        final Account accHeadQtr = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        
        final Account accHeadQtr1 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHeadQtr1.Invoice_Customer__c='Yes';
        accHeadQtr1.FS_Payment_Type__c='Yes';
        
        final Account accHeadQtr2 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHeadQtr2.Invoice_Customer__c='No';
        accHeadQtr2.FS_Payment_Type__c='No';        
           
        headquarters.add(accHeadQtr);
        headquarters.add(accHeadQtr1);
        headquarters.add(accHeadQtr2);
        
        insert headquarters;
        
        final List<Account> outletList=new List<Account>();
        final List<FS_Installation__c> installList=new List<FS_Installation__c>();
        
        final Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.Id, false);       
        outletList.add(accOutlet);
        
        final Account accOutlet1 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr1.Id, false);        
        outletList.add(accOutlet1);
        
        final Account accOutlet2 = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr2.Id, false);        
        outletList.add(accOutlet2);        
        insert outletList;
        
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHeadQtr.Id, true);
        final FS_Installation__c installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,accOutlet.Id,false);
        final FS_Installation__c installation1 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,accOutlet1.Id,false);
        final FS_Installation__c installation2 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,accOutlet2.Id,false);
        
        installList.add(installation);
        installList.add(installation1);
        installList.add(installation2);
        insert installList;    
    }
   //Test Method    
    private static testMethod void  testUnit(){
        final User sysAdminUser=FSTestUtil.createUser(null, 1, FSConstants.systemAdmin, true);
        system.runAs(sysAdminUser){
            Test.startTest();
            createTestData();      
            final Pagereference pg_Ref = Page.FSEnterEditView_CokeSmart_Info;
            Test.setCurrentPage(pg_Ref);
            
            //Initialize Page paramteres
            pg_Ref.getParameters().put('executionplanid', executionPlan.Id);
            
            final FSEnterEditViewCokeSmartInfoController cokeSmart = new FSEnterEditViewCokeSmartInfoController();       
            
            cokeSmart.selectedFillDown = 'VMS';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'Channel';
            cokeSmart.fillDown();            
            
            cokeSmart.selectedFillDown = 'Delivery';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'ProgramPaymentMethod';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'ChannelName';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'PaymentMethod';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'BillToAddress';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'BillToCity';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'BILLTOCOUNTRY';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'BillToState';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'BillToZip';
            cokeSmart.fillDown();
            
            cokeSmart.selectedFillDown = 'RemovingAll';
            cokeSmart.fillDown();
            
            cokesmart.selectedFillDown = 'All';
            cokeSmart.fillDown();   
            cokeSmart.closePopup();
            cokeSmart.showPopup();
            
            cokeSmart.saveOutletInfo();
            system.assertEquals(executionPlan.Id,cokeSmart.executionPlan); 
            
            Test.stopTest();
        }
    }
    
    //Test Method for Cancel   
    private static testMethod void  testCancelMethod(){
        final User sysAdminUser=FSTestUtil.createUser(null, 1, FSConstants.systemAdmin, true);
        system.runAs(sysAdminUser){
            Test.startTest();
            createTestData();      
            final Pagereference pg_Ref = Page.FSEnterEditView_CokeSmart_Info;
            Test.setCurrentPage(pg_Ref);
            
            //Initialize Page paramteres
            pg_Ref.getParameters().put('executionplanid', executionPlan.Id);
            
            final FSEnterEditViewCokeSmartInfoController cokeSmart = new FSEnterEditViewCokeSmartInfoController();       
             
            //testing cancel method            
			 cokeSmart.cancel();            
            system.assertEquals(executionPlan.Id,cokeSmart.executionPlan);
            
            Test.stopTest();
        }
    }   
}