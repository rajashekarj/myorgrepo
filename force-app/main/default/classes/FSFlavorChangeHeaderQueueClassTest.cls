/**************************************************************************
 Name         : FSFlavorChangeHeaderQueueClassTest
 Created By   : Infosys Limited
 Description  : Test class for FSFlavorChangeHeaderQueueClass 
 Created Date : 23-JAN-2017
***************************************************************************/


@isTest
Private class FSFlavorChangeHeaderQueueClassTest {
   
    private static set<ID> recordIdSet = new set<ID>();
     
    private static testMethod void testData()
    {    
        final Id devRecoTypeId = Schema.SObjectType.FS_Flavor_Change_Head__c.getRecordTypeInfosByName().get('FS Flavor Change Chain HQ').getRecordTypeId();
        final List<FS_Flavor_Change_Head__c> fcHeadList=new List<FS_Flavor_Change_Head__c>();
        
        final List<Account> accListForAssignment=FSTestFactory.accListCreate();
        for(Account accVar:accListForAssignment){
            final FS_Flavor_Change_Head__c fcHead=new FS_Flavor_Change_Head__c();
            fcHead.RecordTypeId=devRecoTypeId;
            fcHead.FS_CDM_Setup_Complete__c=false;
            fcHead.FS_FC_Type__c='Workflow Flavor Change';
            fcHead.FS_HQ_Chain__c=accVar.Id;
            fcHeadList.add(fcHead);
        }
        Insert fcHeadList;
        for(FS_Flavor_Change_Head__c fcVar:fcHeadList){
            recordIdSet.add(fcVar.Id);
        }
        
        Test.startTest();
        final FSFlavorChangeHeaderQueueClass hqClass = new FSFlavorChangeHeaderQueueClass(recordIdSet);
        final ID jobID = System.enqueueJob(hqClass);
        Test.stopTest();
            
    }
}