@isTest
private class FS_LinkPHHeadQtrToOutletBatchTest{
    
    static testMethod void  BatchCOrrectorType2(){
        //Insert Chain Account
        Account chainAcc= FSTestUtil.createTestAccount('Corrector Chain',FSConstants.RECORD_TYPE_CHAIN,false);    
        chainAcc.FS_SAP_ID__c = '6666666666';
        chainAcc.FS_ACN__c= '7777777777';
        chainAcc.FS_Payment_Type__c='No';
        chainAcc.Invoice_Customer__c='No';
        insert chainAcc; 
        
        //Insert Outlet Account 200 records
        List<Account> accOutletList=new List<Account>(); 
        for(Integer i=1;i<=50;i++){
            Account accOutlet= FSTestUtil.createAccountOutlet('Test Outlet '+i,FSConstants.RECORD_TYPE_OUTLET,null,false);
            accOutlet.FS_Chain__c=chainAcc.Id;
            accOutlet.FS_SAP_ID__c='11223344'+i+i;
            accOutlet.FS_ACN__c='55667788'+i+i;
            accOutletList.add(accOutlet);
        } 
        
        insert accOutletList;
        
        //Insert HQ Account 200 records
        List<Account> accHQList=new List<Account>();
        for(Integer i=1;i<=50;i++){
            Account accHQ= FSTestUtil.createTestAccount('Test Headquarters'+i,FSConstants.RECORD_TYPE_HQ,false);
            accHQ.FS_Chain__c=chainAcc.Id;
            accHQ.FS_SAP_ID__c='11223344'+i+i+'PH';
            accHQ.FS_ACN__c='55667788'+i+i+'PH';
            accHQList.add(accHQ);
        } 
        
        insert accHQList;
        
        FS_LinkPHHeadQtrToOutletBatchCorrector  batch=new FS_LinkPHHeadQtrToOutletBatchCorrector('test');
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
        system.assertEquals(50,accOutletList.size());
        system.assertEquals(50,accHQList.size());
        
        Map<Id,Id> outletHQMap=new Map<Id,Id>();
        Map<Id,String> outletHQSAP=new Map<Id,String>();
        Map<Id,String> HQSAP=new Map<Id,String>();
        
        List<Account> linkedAccount=[select FS_SAP_ID__c,FS_Headquarters__c,FS_Headquarters__r.FS_SAP_ID__c from Account where RecordTypeId =:FSConstants.RECORD_TYPE_OUTLET];
        
        for(Account acc:  linkedAccount){
            outletHQMap.put(acc.Id,acc.FS_Headquarters__c);
            outletHQSAP.put(acc.Id,acc.FS_Headquarters__r.FS_SAP_ID__c);
        }
        
        for(Integer i=0;i<50;i++){
            //Check HQ is linked to Outlet
            if(outletHQMap.containskey(accOutletList[i].Id))
                system.assert(linkedAccount[i].FS_Headquarters__c==outletHQMap.get(accOutletList[i].Id));
            
            //Check SAP ID of HQ is SAP ID of Outlet +'PH'
            if(outletHQSAP.containskey(accOutletList[i].Id)){
                String suffix=accOutletList[i].FS_SAP_ID__c+'PH';
                system.assert(suffix==outletHQSAP.get(accOutletList[i].Id));
            }
            
        }
        
    }
    
}