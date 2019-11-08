@istest
private class FS_InitialOrderCorrectionTest{
    
    static testmethod void testBatchProcess(){
        Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        Account headQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        Account  outlet=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headQuarterAcc.Id,true);
        FS_Execution_Plan__c executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headQuarterAcc.Id, true);
        FS_Installation__c installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id, outlet.id, true);   
        
        Test.startTest(); //FET 7.0 FNF-823
        FS_Initial_Order__c ioRec = new FS_Initial_Order__c();
        ioRec.FS_Installation__c =installation.id ;
        ioRec.name = 'testIo';        
        ioRec.FS_Order_Processed__c=true;        
        ioRec.recordtypeid= Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get(FSConstants.NEWINITIALORDER).getRecordTypeId();
        insert ioRec;
        installation.FS_CPO_Notes__c='testing1';
        installation.FS_Order_Processed_By__c=null;
        installation.FS_Order_Processed_Data_Time__c=null;
        update installation;
        String query='select FS_Installation__c,FS_CPO_Notes__c,FS_Order_Processed_by__c,FS_Order_Processed_DataTime__c'+ 
            ' from FS_Initial_Order__c WHERE FS_Order_Processed__c=true and LastModifiedDate  = THIS_WEEK'; 
        system.debug('The SOQL is '+query );
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FS_InitialOrderCorrection  c = new FS_InitialOrderCorrection(query);
            Database.executeBatch(c);
        }
          Test.stopTest(); //FET 7.0 FNF-823
        system.assert([select id,FS_Order_Processed_By__c from FS_Installation__c where id=:installation.id].FS_Order_Processed_By__c != null);
        system.assertEquals([select id,FS_CPO_Notes__c from FS_Installation__c where id=:installation.id].FS_CPO_Notes__c,Null);
      
    }
}