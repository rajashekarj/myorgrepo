@isTest
public class FOT_TargetArtifactListController_test {
    private static Account accchain,bottler,outlet,accHQ;
    private static  String ROLLINGBACK ='Rollback';
    private static  String ACTUAL ='Actual';
    private static  String TARGET ='Target';
    private static  String BASE ='Base';
    private static  String DRYRUN ='Dry Run';
    private static  String MEDIUM ='Medium';
    @TestSetup
    static void CreateRecords(){
        FSTestFactory.lstPlatform(); 
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
         //Create Headquarters
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        outlet = FSTestUtil.createAccountOutlet('Test Outlet',FSConstants.RECORD_TYPE_OUTLET,accHQ.id, true);
        FS_Outlet_Dispenser__c outletDispenser1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outlet.id,null,true);
      
        
        final List<FS_TargetArtifact__c> lstTrgtArtifact=new List<FS_TargetArtifact__c> ();
        
         final FS_TargetArtifact__c trgtArtifact=new FS_TargetArtifact__c();
        trgtArtifact.Name='TrgtAtt';
        trgtArtifact.RecordTypeId=Schema.SObjectType.FS_TargetArtifact__c.getRecordTypeInfosByName().get('Rollback').getRecordTypeId();
        trgtArtifact.FS_Artifact_Type__c='Bundle';
        trgtArtifact.FS_ODRecID__c = outletDispenser1.Id;
        lstTrgtArtifact.add(trgtArtifact);
    
       /* final FS_TargetArtifact__c trgtArtifact1=new FS_TargetArtifact__c();
        trgtArtifact1.Name='TrgtAtt1';
        trgtArtifact1.RecordTypeId=Schema.SObjectType.FS_TargetArtifact__c.getRecordTypeInfosByName().get('Actual').getRecordTypeId();
        trgtArtifact1.FS_Artifact_Type__c='Settings';
        trgtArtifact1.FS_ODRecID__c = outletDispenser2.Id;
        lstTrgtArtifact.add(trgtArtifact1);*/
    
    insert lstTrgtArtifact;
        
    }
    
    
     @istest
    static void testMethod1()
    {
        FS_Outlet_Dispenser__c Od = [Select Id FROM FS_Outlet_Dispenser__c];
         List<String> RecTypeList = New List<String>();
       RecTypeList.add(ROLLINGBACK);
       RecTypeList.add(ACTUAL);
        test.startTest();
        List<FS_TargetArtifact__c> lstTrgtArtifact=new List<FS_TargetArtifact__c> ();
        List<String> picklistValues=new  List<String>();
       
       FOT_TargetArtifactListController.getTargetArtifacts(Od.id, RecTypeList);
       FOT_TargetArtifactListController.getTargetArtifactsOnLoad(Od.id);
       picklistValues =FOT_TargetArtifactListController.getPiklistValues();
       system.assertEquals(6, picklistValues.size());
        test.stopTest();
    }
     @istest
    static void testMethod2()
    {
        FS_Outlet_Dispenser__c Od = [Select Id FROM FS_Outlet_Dispenser__c];
         List<String> RecTypeList = New List<String>();
      RecTypeList.add('');
      // RecTypeList.add(ACTUAL);
        test.startTest();
        List<FS_TargetArtifact__c> lstTrgtArtifact=[Select Id,Name FROM FS_TargetArtifact__c WHERE Name='TrgtAtt'];
     
        List<String> picklistValues=new  List<String>();
        try{ 
            FOT_TargetArtifactListController.getTargetArtifacts(Od.id, RecTypeList);
           }
        catch(QueryException e){
            system.debug('error');
        }
      
         try{ 
           FOT_TargetArtifactListController.getTargetArtifactsOnLoad(Od.id);
           }
        catch(QueryException e){
            system.debug('error');
        }
      
       
       picklistValues =FOT_TargetArtifactListController.getPiklistValues();
       system.assertEquals(6, picklistValues.size());
        test.stopTest();
    }

}