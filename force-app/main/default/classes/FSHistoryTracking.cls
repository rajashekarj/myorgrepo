/*********************************************************************************
 Author       :   J-F Ille
 Created Date :   January 20,2016
 Description  :   Controller class for FS History Tracking page
                  
*********************************************************************************/
public class FSHistoryTracking {
   
    public List<FS_Tracking_History__c> HistoryItems{get;set;}    
  
    //constructor    
    public FSHistoryTracking (final ApexPages.StandardController controller){
        try {
            final String oid = controller.getRecord().Id;
            HistoryItems = new List<FS_Tracking_History__c>();
            final Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            
            for(FS_Tracking_History__c item : [Select CreatedById, CreatedBy.Name, CreatedDate, Field__c, New_Value__c, Object_Name__c,Old_Value__c 
                                               FROM FS_Tracking_History__c 
                                               WHERE Parent_Id__c = :oid ORDER BY CreatedDate DESC]){
                String label;
                if(item.Object_Name__c != '' && item.Field__c != 'created') {                
                    final Schema.SObjectType leadSchema = schemaMap.get(item.Object_Name__c);
                    final SObjectField itemFS = leadSchema.getDescribe().fields.getMap().get(item.Field__c);
                    if(itemFS != null) {
                        label = itemFS.getDescribe().getLabel();
                    }
                    else {
                        label = item.Field__c;
                    }
                    item.Field__c = 'Changed ' + label + ' from ' + item.Old_Value__c + ' to ' + item.New_Value__c;
                }
                            
                HistoryItems.add(item);
            }
        }
    catch(Exception e) {
        System.debug('The following exception has occurred at line: ' + e.getLineNumber() + ' , ' + e.getMessage());   
    }
   }
}