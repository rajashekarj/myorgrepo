/*
*This is class is called when Initial Order SAP Data of Master Data type 
*for both 7k and 8k OR 9K  is updated. Ranjan Kumar Saha FET 2.1
*/

public class FSupdateTransactionDataHelper{
  public static String codeCoverage = 'For Coveragege'; 
 /*Commenting Initial Order SAP Data Object related lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0
 public static String recTypeTransactionData=FSUtil.getObjectRecordTypeId(FS_Initial_Order_SAP_Data__c.SObjectType,'Initial Order Transaction Data');
 
 public static void updateTransactionData(List<FS_Initial_Order_SAP_Data__c> listValues, Map<Id,FS_Initial_Order_SAP_Data__c> mapValues){
   List<FS_Initial_Order_SAP_Data__c> masterData7000=new List<FS_Initial_Order_SAP_Data__c>();
   Map<String,FS_Initial_Order_SAP_Data__c> masterDataMap7000=new Map<String,FS_Initial_Order_SAP_Data__c>();
   List<FS_Initial_Order_SAP_Data__c> masterData8000OR9000=new List<FS_Initial_Order_SAP_Data__c>();
   Map<String,FS_Initial_Order_SAP_Data__c> masterDataMap8000OR9000=new Map<String,FS_Initial_Order_SAP_Data__c>();
   for(FS_Initial_Order_SAP_Data__c sapdata: listValues){
      if(sapdata.FS_Type__c=='7000 Series'){
         masterData7000.add(sapdata);
         masterDataMap7000.put(sapdata.Name+ ':' + sapdata.Cartridge_Name__c,sapdata);
      }
      else if(sapdata.FS_Type__c=='8000 OR 9000 Series'){
         masterData8000OR9000.add(sapdata);
         masterDataMap8000OR9000.put(sapdata.Name+':'+sapdata.Cartridge_Name__c,sapdata);
      }
   }
	final id io7kSeries=Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('7000 Series').getRecordTypeId();
	final id io7kReplSeries=Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('Relocation 7000 Series').getRecordTypeId();
	final id io8k9kSeries=Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('Relocation (O4W)').getRecordTypeId();
	final id io8k9kReplSeries=Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('Relocation (O4W)').getRecordTypeId();
   system.debug('List 7000'+masterData7000);
   system.debug('map 7000'+masterDataMap7000);
   system.debug('List 8k9k'+masterData8000OR9000);
   system.debug('map 8k9k'+masterDataMap8000OR9000);
   Set<Id> io7000=new Set<Id>();
   Set<Id> io8K9K=new Set<Id>();
   if(masterData7000.size()>0 && !masterData7000.isEmpty()){
     for(List<FS_Initial_Order__c > ioList : [select id from  FS_Initial_Order__c where FS_Order_Processed__c=false and (RecordTypeid=:io7kSeries OR RecordTypeid=:io7kReplSeries)]){
        for(FS_Initial_Order__c io: ioList ){
           io7000.add(io.id);
        }
     }
   }
   
   if(masterData8000OR9000.size()>0 && !masterData8000OR9000.isEmpty()){
     for(List<FS_Initial_Order__c > ioList : [select id from  FS_Initial_Order__c where FS_Order_Processed__c=false and (RecordTypeid=:io8k9kSeries OR RecordType.Name=:io8k9kReplSeries)]){
        for(FS_Initial_Order__c io: ioList ){
           io8K9K.add(io.id);
        }
     }
   }
   //Update Transaction Data for 7000 and 8000 OR 9000
     if(io7000.size()>0 || io8K9K.size()>0){
        Database.executeBatch(new FSupdateTransactionDataHelperBatch(io7000, io8K9K, masterDataMap7000, masterDataMap8000OR9000));
                                     
     }
   
 }*/
}