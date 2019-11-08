global without sharing class FSBatchUpdateActivationDTInstall implements Database.Batchable<sObject> {
    
    String query;
    Map<string,Date> MarketActivationNameDateMap; 
    Set<String> marketNameSet;
    
    public FSBatchUpdateActivationDTInstall(String query,Set<String> marketNameSet,Map<string,Date> MarketActivationNameDateMap){
        this.query=query;
        this.marketNameSet=marketNameSet;
        this.MarketActivationNameDateMap=MarketActivationNameDateMap;
    } 
    /****************************************************************************
//Start the batch
/***************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc){     
        if(Test.isRunningTest()){
            query += ' LIMIT 10';
        }
        System.debug('@query-'+query);
        return Database.getQueryLocator(query);
        
    }	
    /****************************************************************************
// Execute Batch
/***************************************************************************/    
    global void execute(Database.BatchableContext bc, List<FS_Installation__c> lstRecords){  
       
        for(FS_Installation__c openInstall :lstRecords){                           
            openInstall.FS_Install_Date_Validation_Bypass_Check__c=true;            
        } 
        if(!lstRecords.isEmpty()){            
            Database.Update(lstRecords,false);           
        }                
    }   
    /****************************************************************************
//finish the batch
/***************************************************************************/
    global void finish(Database.BatchableContext BC){
        
    }
}