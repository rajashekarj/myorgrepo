global class FSupdateTransactionDataHelperBatch implements Database.Batchable<sObject>
{

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
        String query = 'SELECT Id,Name,Phone FROM Account ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        system.debug('commit');
        for ( Account a : scope)
        {
           a.Phone='123';
        }
        update scope;
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}

/*Commenting Initial Order SAP Data Object related lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0

global class FSupdateTransactionDataHelperBatch implements  Database.Batchable<sObject>, Database.Stateful{ 
 global String Query;
 public final String rectype7000='7000 Series';
 public final String rectype8K9K='8000 OR 9000 Series';
 public String recTypeTransactionData=FSUtil.getObjectRecordTypeId(FS_Initial_Order_SAP_Data__c.SObjectType,'Initial Order Transaction Data');
 public Set<Id> io7000=new Set<Id>();
 public Set<Id> io8K9K=new Set<Id>();
 public Map<String,FS_Initial_Order_SAP_Data__c> masterDataMap7000=new Map<String,FS_Initial_Order_SAP_Data__c>();
 public Map<String,FS_Initial_Order_SAP_Data__c> masterDataMap8000OR9000=new Map<String,FS_Initial_Order_SAP_Data__c>();
 public List<FS_Initial_Order_SAP_Data__c> sapTransaction8K9KListtoBeUpdated =new List<FS_Initial_Order_SAP_Data__c>();
 public List<FS_Initial_Order_SAP_Data__c> sapTransaction7000ListtoBeUpdated =new List<FS_Initial_Order_SAP_Data__c>();
 Set<FS_Initial_Order_SAP_Data__c> tobeUpdatedSet=new Set<FS_Initial_Order_SAP_Data__c>();
 List<FS_Initial_Order_SAP_Data__c> finaltobeUpdatedList=new List<FS_Initial_Order_SAP_Data__c>();
 public Set<String> io7000SAPName=new Set<String>();
 public Set<String> io8K9KSAPname=new Set<String>();
 
 //Constructor
   public FSupdateTransactionDataHelperBatch (Set<Id> io7000,Set<Id> io8K9K,Map<String,FS_Initial_Order_SAP_Data__c> masterDataMap7000,Map<String,FS_Initial_Order_SAP_Data__c> masterDataMap8000OR9000) {
     this.io7000 = io7000;
     this.io8K9K = io8K9K;
     this.masterDataMap7000 = masterDataMap7000;
     this.masterDataMap8000OR9000 = masterDataMap8000OR9000;
   }
global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> tempList7K=new List<String>();
        List<String> tempList8K9k=new List<String>();
        
        if(masterDataMap7000.size()>0){
            for(String mapVal7k :masterDataMap7000.keySet() ){
                 List <string>sapName=mapVal7k.split(':');
                 tempList7K.addAll(sapName);
            }
        
            for(Integer i=0;i<tempList7K.size();i++){
              if (math.mod(i, 2)==0 ) {
               io7000SAPName.add(tempList7K[i]);
              }  
            }
        }
        
        if(masterDataMap8000OR9000.size()>0){
            for(String mapVal8k9k :masterDataMap8000OR9000.keySet() ){
                 List <string>sapName=mapVal8k9k.split(':');
                 tempList8K9k.addAll(sapName);
            }
        
            for(Integer i=0;i<tempList8K9k.size();i++){
              if (math.mod(i, 2)==0 ) {
               io8K9KSAPname.add(tempList8K9k[i]);
              }  
            }
        }
        
         Query='';
         if(io8K9K.size()>0){
           Query='SELECT Name,Cartridge_Name__c,Cost_per_Unit__c,Days_In_Stock__c,FS_7000_Package_Days_Capacity_1000__c,Initial_Order__c, '+
           'FS_Package_Days_Capacity_Pepper_1000__c,Slots_8k9k__c  FROM FS_Initial_Order_SAP_Data__c WHERE Master_Data__c = false AND RecordtYpeId=:recTypeTransactionData '+
            ' AND FS_Type__c=:rectype8K9K AND Initial_Order__r.id in : io8K9K AND Initial_Order__r.FS_Order_Processed__c=false AND Name in:io8K9KSAPname ';
         }
         if(io7000.size()>0){
           Query='SELECT Name,Cartridge_Name__c,Cost_per_Unit__c,Days_In_Stock__c,FS_7000_Package_Days_Capacity_1000__c,Initial_Order__c '+
            'FROM FS_Initial_Order_SAP_Data__c WHERE Master_Data__c = false AND RecordtYpeId=:recTypeTransactionData '+
            ' AND FS_Type__c=:rectype7000 AND Initial_Order__r.id in : io7000 AND Initial_Order__r.FS_Order_Processed__c=false AND Name in:io7000SAPName';
         }
         system.debug('@@@Query' + Query);
        return Database.getQueryLocator(Query);

    }

    /***************************************************************************
    //Process a batch
    /**************************************************************************/
  /*  global void execute(Database.BatchableContext BC, List<sObject> sapTransactionList){
      
      system.debug('result Size'+sapTransactionList.size());
      if(io8K9K.size()>0){
        for(FS_Initial_Order_SAP_Data__c sapTransData :  (List<FS_Initial_Order_SAP_Data__c>)sapTransactionList){
        if(masterDataMap8000OR9000.containsKey(sapTransData.Name+':'+sapTransData.Cartridge_Name__c)){
          if(sapTransData.Cost_per_Unit__c!=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Cost_per_Unit__c){
            sapTransData.Cost_per_Unit__c=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Cost_per_Unit__c;
            sapTransaction8K9KListtoBeUpdated.add(sapTransData);
          }
          if(sapTransData.Days_In_Stock__c!=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Days_In_Stock__c){
            sapTransData.Days_In_Stock__c=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Days_In_Stock__c;
            sapTransaction8K9KListtoBeUpdated.add(sapTransData);
          }
          if(sapTransData.FS_7000_Package_Days_Capacity_1000__c!=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).FS_7000_Package_Days_Capacity_1000__c){
            sapTransData.FS_7000_Package_Days_Capacity_1000__c=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).FS_7000_Package_Days_Capacity_1000__c;
            sapTransaction8K9KListtoBeUpdated.add(sapTransData);
          }
          if(sapTransData.FS_Package_Days_Capacity_Pepper_1000__c!=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).FS_Package_Days_Capacity_Pepper_1000__c){
            sapTransData.FS_Package_Days_Capacity_Pepper_1000__c=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).FS_Package_Days_Capacity_Pepper_1000__c;
            sapTransaction8K9KListtoBeUpdated.add(sapTransData);
          }
          if(sapTransData.Slots_8k9k__c!=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Slots_8k9k__c){
            sapTransData.Slots_8k9k__c=masterDataMap8000OR9000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Slots_8k9k__c;
            sapTransaction8K9KListtoBeUpdated.add(sapTransData);
          }
         }
        } 
        
      }
      
      
      if(io7000.size()>0){
        for(FS_Initial_Order_SAP_Data__c sapTransData : (List<FS_Initial_Order_SAP_Data__c>)sapTransactionList){
        if(masterDataMap7000.containsKey(sapTransData.Name+':'+sapTransData.Cartridge_Name__c)){
          if(sapTransData.Cost_per_Unit__c!=masterDataMap7000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Cost_per_Unit__c){
            sapTransData.Cost_per_Unit__c=masterDataMap7000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Cost_per_Unit__c;
            sapTransaction7000ListtoBeUpdated.add(sapTransData);
          }
          if(sapTransData.Days_In_Stock__c!=masterDataMap7000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Days_In_Stock__c){
            sapTransData.Days_In_Stock__c=masterDataMap7000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).Days_In_Stock__c;
            sapTransaction7000ListtoBeUpdated.add(sapTransData);
          }
          if(sapTransData.FS_7000_Package_Days_Capacity_1000__c!=masterDataMap7000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).FS_7000_Package_Days_Capacity_1000__c){
            sapTransData.FS_7000_Package_Days_Capacity_1000__c=masterDataMap7000.get(sapTransData.Name + ':' + sapTransData.Cartridge_Name__c).FS_7000_Package_Days_Capacity_1000__c;
            sapTransaction7000ListtoBeUpdated.add(sapTransData);
          }
         }
        }
      }
       
        if(sapTransaction7000ListtoBeUpdated.size()>0){
         tobeUpdatedSet.addAll(sapTransaction7000ListtoBeUpdated);
         finaltobeUpdatedList.addAll(tobeUpdatedSet);
         system.debug('Number of 7000 records'+sapTransaction7000ListtoBeUpdated.size()); 
         system.debug('Number of 7000 records final Size'+finaltobeUpdatedList.size());
         system.debug('Number of 7000 records final '+finaltobeUpdatedList.size());
        }
        else if(sapTransaction8K9KListtoBeUpdated.size()>0){
         tobeUpdatedSet.addAll(sapTransaction8K9KListtoBeUpdated);
         finaltobeUpdatedList.addAll(tobeUpdatedSet); 
         system.debug('Number of 8k9k records'+sapTransaction8K9KListtoBeUpdated.size()); 
         system.debug('Number of 8k9k records final Size'+finaltobeUpdatedList.size());
         system.debug('Number of 8k9k records final '+finaltobeUpdatedList.size());
        }
        
         SavePoint sp;
        try{
           sp = Database.setSavePoint();
           if(finaltobeUpdatedList.size()>0){
              update finaltobeUpdatedList; 
           }
       }
       catch(Exception e){
         Database.rollback(sp);
         system.debug('An exception has occurred while updating 8K9K Series'+e);
       }  
        
        
        
    }*/

     /****************************************************************************
    //finish the batch
    /***************************************************************************/
  /*  global void finish(Database.BatchableContext BC){
        
    }
} */