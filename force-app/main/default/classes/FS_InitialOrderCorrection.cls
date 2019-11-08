global class FS_InitialOrderCorrection implements Database.Batchable<sObject>,Database.Stateful {
   global String query;
   
   global FS_InitialOrderCorrection (String q) {
       query = q;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
       query='select FS_Installation__c,FS_CPO_Notes__c,FS_Order_Processed_By_form__c,FS_Order_Processed_DataTime__c'+ 
                  ' from FS_Initial_Order__c WHERE FS_Order_Processed__c=true and LastModifiedDate=LAST_N_DAYS:45'; 
       system.debug('The SOQL is '+query );
       return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<FS_initial_order__c> scope) {
        Map<Id,FS_Initial_Order__c>  mapper=new Map<Id,FS_Initial_Order__c>();
        Set<Id> installIds=new Set<Id>();

        for(FS_initial_order__c  a : scope) {
           mapper.put(a.FS_Installation__c,a);
           installIds.add(a.FS_Installation__c);
        } 
        
        system.debug('Install Id'+ installIds.size());
        List<FS_Installation__c> installList=[select FS_CPO_Notes__c,FS_Order_Processed_By__c,FS_Order_Processed_Data_Time__c FROM FS_Installation__c where id in:installIds 
                                               AND FS_Order_Processed_By__c = NULL ];
        for(FS_Installation__c  inst : installList){
           if(inst.FS_CPO_Notes__c!=mapper.get(inst.id).FS_CPO_Notes__c)
           inst.FS_CPO_Notes__c=mapper.get(inst.id).FS_CPO_Notes__c;
           
           if(inst.FS_Order_Processed_By__c!=mapper.get(inst.id).FS_Order_Processed_By_form__c)
           inst.FS_Order_Processed_By__c=mapper.get(inst.id).FS_Order_Processed_By_form__c;
           
           if(inst.FS_Order_Processed_Data_Time__c!=mapper.get(inst.id).FS_Order_Processed_DataTime__c)
           inst.FS_Order_Processed_Data_Time__c=mapper.get(inst.id).FS_Order_Processed_DataTime__c;
        }
        system.debug('Install size  '+ installList.size());
        try{
           update installList;
        }
        catch(Exception exp) {
            System.debug('Exception occurred while correcting Initial Order Data- '+exp);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
      
    }
}