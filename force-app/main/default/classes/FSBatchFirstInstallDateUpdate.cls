global class FSBatchFirstInstallDateUpdate implements  Database.Batchable<sObject>{
    
    global String Query;
    global Id outletRecordId;
    global Id relocationRecordId;
    global Id rNewRecordId;
    
    /****************************************************************************
//Initialize the batch
/***************************************************************************/
    public FSBatchFirstInstallDateUpdate(){
        
        //Account record type map
        Map<String,Schema.RecordTypeInfo> rtMapByNameAcc = Schema.SObjectType.Account.getRecordTypeInfosByName();
        //Installation Record type map
        Map<String,Schema.RecordTypeInfo> rtMapByNameIns = Schema.SObjectType.Fs_Installation__c.getRecordTypeInfosByName();       
        
        //Outlet Record Id
        Schema.RecordTypeInfo rtByName1 =  rtMapByNameAcc.get(FSConstants.OUTLET_RECORD_TYPE);
        outletRecordId = rtByName1.getRecordTypeId();
        
        //Installation Record Id(Relocation and Regular)
        
        Schema.RecordTypeInfo rtByName2 =  rtMapByNameIns.get(Label.IP_Relocation_I4W_Rec_Type);
        relocationRecordId = rtByName2.getRecordTypeId();
        //FET 5.0 regular Installation default record type "New Install"
        Schema.RecordTypeInfo rtByName3 =  rtMapByNameIns.get(FSConstants.NEWINSTALLATION);
        rNewRecordId=rtByName3.getRecordTypeId();
        //FET 5.0 regular Installation default record type "New Install"
        
    }
    
    /****************************************************************************
//Start the batch
/***************************************************************************/ 
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        query = 'select Id,Name,First_Install_Date1__c,FS_ACN__C FROM Account WHERE RecordTypeId = \'' + outletRecordId + '\'  '
            + ' AND ShippingCountry = \'US\' ';
        
        if(system.Test.isRunningTest()){
            query += ' LIMIT 100';
        }
        system.debug('@@@Query' + query);
        return Database.getQueryLocator(query);        
    }
    
    /****************************************************************************
// Execute Batch 
/***************************************************************************/
    
    global void execute(Database.BatchableContext BC, List<sObject> AccountList){
        System.debug('In Execution');
        List<string> blendedAcn =new  List<string>(); 
        map<string,id> acnIDAccountMap=new map<string,id>();
        //Get the ACN into the list to query installations 
        for(Account acc:(List<account>)AccountList){
            if(acc.FS_ACN__c != null ){
                blendedAcn.add(acc.FS_ACN__C);
            }
            acnIDAccountMap.put(acc.FS_ACN__C,acc.id);
        }
        
        //Get all Completed Instllations where the respective date is not null for the given list of accounts
        
        //FET 5.0 regular Installation default record type "New Install"
        List<FS_Installation__c > instList=[select Blended_Install_Date__c,Blended_ACN__c from FS_Installation__c where
                                            ((RecordTypeId =:rNewRecordId AND Overall_Status2__c =: FSConstants.IPCOMPLETE  AND FS_Scheduled_Install_Date__c!=null)                                                
                                             OR                                                
                                             (RecordTypeId =:relocationRecordId AND Overall_Status2__c =: FSConstants.IPCOMPLETE 
                                              AND FS_Install_Reconnect_Date__c != null)) AND Blended_ACN__c  in :blendedAcn ];      
        //FET 5.0 regular Installation default record type "New Install"
        //Map to retain the Installation which has the first installation for each account
        Map<String,FS_Installation__c> InstBlendedMap=new Map<String,FS_Installation__c>();
        
        for(FS_Installation__c install:instList){
            //Check if Key already in map
            if(InstBlendedMap.containsKey(install.Blended_ACN__c)){
                //Fetch the mapping record to compare with new record
                FS_Installation__c tempInst = InstBlendedMap.get(install.Blended_ACN__c);
                if(install.Blended_Install_Date__c!=null && tempInst.Blended_Install_Date__c>install.Blended_Install_Date__c){
                    //Override the Mapped Installation for given Account as the Installation has least Install date
                    InstBlendedMap.put(install.Blended_ACN__c,install);
                }
            }else {
                if(install.Blended_Install_Date__c!=null)
                    //for first record into map for the given account
                    InstBlendedMap.put(install.Blended_ACN__c,install);
            } 
        }
        List<Account> accList=new List<Account>();
        //For the given list of Outlets check the if the map has least date and assign that to outlet
        for(String key:InstBlendedMap.keyset())
        {
            Account acc=new Account();
            acc.id=acnIDAccountMap.get(key);
            acc.First_Install_Date1__c=InstBlendedMap.get(key).Blended_Install_Date__c;
            accList.add(acc);
        }
        try{
            update accList;
        }
        catch(exception ex){
            system.debug('There are issues in the batch class');
        }        
    }
    
    /****************************************************************************
//finish the batch 
/***************************************************************************/ 
    global void finish(Database.BatchableContext BC){
        // Finish Batch Logic
        
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          from AsyncApexJob where Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail1=new Messaging.SingleEmailMessage();
        String[] toadd=new String[]{'hnaladala@coca-cola.com'};
            mail1.setToAddresses(toadd);
        mail1.setSubject('FET Batch: First Install Date Update');
        mail1.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                               ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.singleEmailMessage[]{mail1});
    }   
}