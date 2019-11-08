/*
Testcalss for updatingACNRecordtypeBatch
Author: Srinivas bolneni
*/

@isTest
private class updatingACNRecordtypeBatchTest{

 static testmethod void UpdatingAccountACN(){
 
  Account acc = new account();
   acc.Name='Testaccount1';
   acc.FS_ACN__c='  0000086903';
   acc.CCR_ACN_RecordType_Id__c='000086903-012i0000000xHOuAAM';
   acc.AutorabitExtId__c ='001i000000X0hlKAAR';
   insert acc;
   Account acc1 = new account();
   acc1.Name='Testaccount2';
   acc1.FS_ACN__c='000086903';
   acc1.CCR_ACN_RecordType_Id__c= '00086903-012i0000000xHOuAAM';
   acc1.AutorabitExtId__c ='001i000000X0hlKAAR';
   insert acc1;
   List<account> acclist =[Select id,FS_ACN__c,Recordtypeid, CCR_ACN_RecordType_Id__c from Account where FS_ACN__c!=null];
   
   Test.startTest();
   updatingACNRecordtypeBatch batchInst =new updatingACNRecordtypeBatch();
   Database.executebatch(batchInst,2);
   Test.stopTest();
 }
}