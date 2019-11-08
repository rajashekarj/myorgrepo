@isTest
Class BatchForInstallationDateToWSTest{
    static Account accchain,accHQ,accOutlet;
    static FS_Execution_Plan__c executionPlan;
    
    
    Static testMethod void createtestData(){       
        
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);        
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);   
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,true);
        Map<String,Id> EPRecTyMap=new Map<String,Id>();
        List<Recordtype> EPRecordTyList=[Select id,name from RecordType where SobjectType='FS_Execution_Plan__c'];
        for(Recordtype EPRecTyp:EPRecordTyList ){
            EPRecTyMap.put(EPRecTyp.name,EPRecTyp.Id);
        }
        executionPlan=new FS_Execution_Plan__c();
        executionPlan.FS_Headquarters__c= accHQ.Id;
        executionPlan.recordtypeid=EPRecTyMap.get('Execution Plan');
        insert executionPlan;
        FS_Installation__c Installation1= new FS_Installation__c();
        Installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id, false );
        Installation1.IsDailyUpdated__c =true;
        insert Installation1;
    }
    Static testMethod void BatchForInstallationDateToWS_Test(){
        createtestData();
        Test.StartTest();
        database.executebatch(new BatchForInstallationDateToWS(),1);
        Test.stopTest();
        
    }
}