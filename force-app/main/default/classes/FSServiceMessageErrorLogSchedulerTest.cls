/**************************************************************************************
Apex Class Name     : FSServiceMessageErrorLogSchedulerTest
Version             : 1.0
Function            : This test class is for FSServiceMessageErrorLogScheduler Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
*-------------------------------------------------------------------------------------                 
* Infosys             09/09/              Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
**************************************************************************************/
//Created on 9th Sep. FSServiceMessageErrorLogScheduler never had a test class until now
@isTest
public class FSServiceMessageErrorLogSchedulerTest {
    @testSetup
    static void createTestData() {
        
        //create platform type custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        //Custom Setting Values
        List<HttpStatusCodes__c> statusCodeList=new List<HttpStatusCodes__c>();
        
        HttpStatusCodes__c sc2=new HttpStatusCodes__c(Name='204');
        statusCodeList.add(sc2);
        HttpStatusCodes__c sc3=new HttpStatusCodes__c(Name='400');
        statusCodeList.add(sc3);
        HttpStatusCodes__c sc4=new HttpStatusCodes__c(Name='401');
        statusCodeList.add(sc4);
        HttpStatusCodes__c sc5=new HttpStatusCodes__c(Name='500');
        statusCodeList.add(sc5);
        HttpStatusCodes__c sc6=new HttpStatusCodes__c(Name='502');
        statusCodeList.add(sc6);
        HttpStatusCodes__c sc7=new HttpStatusCodes__c(Name='503');
        statusCodeList.add(sc7);
        HttpStatusCodes__c sc8=new HttpStatusCodes__c(Name='504');
        statusCodeList.add(sc8);
        
        insert statusCodeList;
        
        List<Error_Message_Resend_Counter__c> errormessageResendCounterList=new List<Error_Message_Resend_Counter__c>();
        Error_Message_Resend_Counter__c resendCounterInstance1= new Error_Message_Resend_Counter__c ();
        resendCounterInstance1.Name='FSServiceMessageErrorBatchSize';
        resendCounterInstance1.Resend_Number__c=1;
        errormessageResendCounterList.add(resendCounterInstance1);
        
        Error_Message_Resend_Counter__c resendCounterInstance2= new Error_Message_Resend_Counter__c ();
        resendCounterInstance2.Name='Service Message Error';
        resendCounterInstance2.Resend_Number__c=1;
        errormessageResendCounterList.add(resendCounterInstance2);
        insert errormessageResendCounterList;
    }
    
    static testMethod void testScheduler(){
        
        List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSAccountBusinessProcess','FSInstallationBusinessProcess','FSExecutionPlanTriggerHandler'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
        //set mock callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        //Create Chain
        Account accChain=FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        Account accHQ=FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c=accChain.Id;
        insert accHQ;
        
        Account accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,false);
        accOutlet.FS_Chain__c=accChain.Id;
        insert accOutlet;
        //EP of 8k type
        FS_Execution_Plan__c executionPlan8k=FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id,true);
        //IP of 8k type
        FS_Installation__c  installation8k=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan8k.Id,accOutlet.Id,true);      
        
        //for 200 Recods
        //Od recordType:8000
        Id od8kRecType=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(FSConstants.RT_NAME_CCNA_OD).getRecordTypeId();
        List<FS_Outlet_Dispenser__c > outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        outletDispenserList=FSTestFactory.createTestOutletDispenser(installation8k.Id,accOutlet.Id,od8kRecType,true,1,null);        
        
        //Insert Service error log records
        List<Service_Message_Error_Log__c > serviceErrorLogs=new List<Service_Message_Error_Log__c >();
        for(FS_Outlet_Dispenser__c od : outletDispenserList){
            Service_Message_Error_Log__c errorLog=new Service_Message_Error_Log__c ();
            errorLog.Outlet_Dispenser__c=od.Id;
            errorLog.FS_Serial_Number_Asset_Tag__c=od.FS_Serial_Number2__c;
            errorLog.ServiceName__c='MasterDataCreate';
            errorLog.Resend__c=true;
            errorLog.Error_Code__c='400';
            errorLog.Request_Message__c='no body';
            serviceErrorLogs.add(errorLog);
        }
        insert serviceErrorLogs;
        
        
        Test.startTest();
        try{
            String cronExp = '0 0 23 * * ?';
            FSServiceMessageErrorLogScheduler scheObj = new FSServiceMessageErrorLogScheduler();
            String jobId = system.schedule('Test Scheduler Job', cronExp, scheObj);
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(cronExp,ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        }catch(exception e) {}
        Test.stopTest();
        
    }
    
    static testMethod void testSchedulerfailure(){
         List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSAccountBusinessProcess','FSInstallationBusinessProcess','FSExecutionPlanTriggerHandler'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
        //set mock callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMockFailure());
        
        //Create Chain
        Account accChain=FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        Account accHQ=FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c=accChain.Id;
        insert accHQ;
        
        Account accOutlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,false);
        accOutlet.FS_Chain__c=accChain.Id;
        insert accOutlet;
        //EP of 8k type
        FS_Execution_Plan__c executionPlan8k=FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id,true);
        //IP of 8k type
        FS_Installation__c  installation8k=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan8k.Id,accOutlet.Id,true);      
        
        //for 200 Recods
        //Od recordType:8000
        Id od8kRecType=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(FSConstants.RT_NAME_CCNA_OD).getRecordTypeId();
        List<FS_Outlet_Dispenser__c > outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        outletDispenserList=FSTestFactory.createTestOutletDispenser(installation8k.Id,accOutlet.Id,od8kRecType,true,1,null);        
        
        //Insert Service error log records
        List<Service_Message_Error_Log__c > serviceErrorLogs=new List<Service_Message_Error_Log__c >();
        for(FS_Outlet_Dispenser__c od : outletDispenserList){
            Service_Message_Error_Log__c errorLog=new Service_Message_Error_Log__c ();
            errorLog.Outlet_Dispenser__c=od.Id;
            errorLog.FS_Serial_Number_Asset_Tag__c=od.FS_Serial_Number2__c;
            errorLog.ServiceName__c='MasterDataCreate';
            errorLog.Resend__c=true;
            errorLog.Error_Code__c='400';
            errorLog.Request_Message__c='no body';
            serviceErrorLogs.add(errorLog);
        }
        insert serviceErrorLogs;
        
        
        Test.startTest();
        try{
            
            Id jobId = DataBase.executeBatch(new BatchForErrorHandling(),200);
            system.assert(jobId != null);
        }catch(exception e) {}
        Test.stopTest();
    }
    
}