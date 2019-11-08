@istest
private class FSupdateTransDataBatch7000SeriesTest{
    /*Commenting Initial Order SAP Data Object related lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0
    static Account headQuarterAcc;
    static Account Outlet;
 private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    static FS_Execution_Plan__c executionPlan;
    
    static FS_Installation__c installation;
    static testmethod void batchTest7000Series(){
        
        HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        Outlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id,true);
        
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.x8000SeriesRecType,HeadQuarterAcc.Id, true);
        System.debug('EP record is '+executionPlan );       
        
        installation = FSTestUtil.createInstallationAcc(FSConstants.x8000SeriesRecType,executionPlan.Id, Outlet.id, true); 
        
        
        FS_Initial_Order__c IO = new FS_Initial_Order__c();
        IO.FS_Installation__c =installation.id ;
        IO.name = 'testIo';
        IO.recordtypeid= Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('7000 Series').getRecordTypeId() ;
        
        Test.startTest();
        
        insert IO;
        
        Id transactionDecortypeId=Schema.SObjectType.FS_Initial_Order_SAP_Data__c.getRecordTypeInfosByName().get('Initial Order Transaction Data').getRecordTypeId(); 
        
        FS_Initial_Order_SAP_Data__c  sapData =new FS_Initial_Order_SAP_Data__c (RecordtypeId=transactionDecortypeId,Initial_Order__c=IO.id);
        insert sapData;
        
        Id RecortypeId7k = Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('7000 Series').getRecordTypeId();
        Id RecortypeIdRelocation7k = Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('Relocation 7000 Series').getRecordTypeId();   
        
        String query ='SELECT FS_Type__c from FS_Initial_Order_SAP_Data__c where Master_Data__c=false and recordtypeid =:transactionDecortypeId and (Initial_Order__r.RecordtypeId =:RecortypeId7k OR Initial_Order__r.RecordtypeId=:RecortypeIdRelocation7k)';
        
        List<FS_Initial_Order_SAP_Data__c> initialOrderLst = [SELECT FS_Type__c from FS_Initial_Order_SAP_Data__c where Master_Data__c=false and recordtypeid =:transactionDecortypeId and (Initial_Order__r.RecordtypeId =:RecortypeId7k OR Initial_Order__r.RecordtypeId=:RecortypeIdRelocation7k)];
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){

        FSupdateTransactionDataBatch7000Series c = new FSupdateTransactionDataBatch7000Series(query);
        Database.QueryLocator ql = c.start(null);
		c.execute(null,initialOrderLst);
		c.Finish(null);
}
        Test.stopTest();
        
        
    }
    
    static testmethod void batchTest7000RelocationSeries(){
        
        HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        Outlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id,true);
        
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.x8000SeriesRecType,HeadQuarterAcc.Id, true);
        System.debug('EP record is '+executionPlan );       
        
        installation = FSTestUtil.createInstallationAcc(FSConstants.x8000SeriesRecType,executionPlan.Id, Outlet.id, true);
      
        FS_Initial_Order__c IO = new FS_Initial_Order__c();
        IO.FS_Installation__c =installation.id ;
        IO.name = 'testIo R';
        IO.recordtypeid= Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('Relocation 7000 Series').getRecordTypeId() ;
        
        Test.startTest();
        
        insert IO;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){

        Id transactionDecortypeId=Schema.SObjectType.FS_Initial_Order_SAP_Data__c.getRecordTypeInfosByName().get('Initial Order Transaction Data').getRecordTypeId(); 
        FS_Initial_Order_SAP_Data__c  sapData =new FS_Initial_Order_SAP_Data__c (RecordtypeId=transactionDecortypeId,Initial_Order__c=IO.id);
        insert sapData;
        
        Id RecortypeId7k = Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('7000 Series').getRecordTypeId();
        Id RecortypeIdRelocation7k = Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('Relocation 7000 Series').getRecordTypeId();   
        
        String query ='SELECT FS_Type__c from FS_Initial_Order_SAP_Data__c where Master_Data__c=false and recordtypeid =:transactionDecortypeId and (Initial_Order__r.RecordtypeId =:RecortypeId7k OR Initial_Order__r.RecordtypeId=:RecortypeIdRelocation7k)';
        
        List<FS_Initial_Order_SAP_Data__c> initialOrderLst = [SELECT FS_Type__c from FS_Initial_Order_SAP_Data__c where Master_Data__c=false and recordtypeid =:transactionDecortypeId and (Initial_Order__r.RecordtypeId =:RecortypeId7k OR Initial_Order__r.RecordtypeId=:RecortypeIdRelocation7k)];
        
        FSupdateTransactionDataBatch7000Series c = new FSupdateTransactionDataBatch7000Series(query);
        Database.QueryLocator ql = c.start(null);
		c.execute(null,initialOrderLst);
		c.Finish(null);
}
        Test.stopTest();      
        
    }*/
}