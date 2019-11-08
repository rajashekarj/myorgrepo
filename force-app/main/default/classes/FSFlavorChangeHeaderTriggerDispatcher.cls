/***************************************************************************
 Name         : FSFlavorChangeHeaderTriggerDispatcher 
 Created By   : Infosys Limited
 Description  : Dispatcher for FSFlavorChangeHeaderTrigger to set context variables and send trigger context variables 
                and a collection variable to hold all sobjects to be update in the same context
                to methods based on type of trigger event
 Created Date : 25-JAN-2017
****************************************************************************/
public class FSFlavorChangeHeaderTriggerDispatcher extends TriggerClass{

  //private static Boolean isBeforeInsertProcessing = false; 
  private static Boolean isBeforeUpdateProcessing = false;
  //private static Boolean isAfterInsertProcessing = false;
  private static Boolean isAfterUpdateProcessing = false;   
  
  @TestVisible private static Map<Id,Sobject> sObjectsToUpdate= new Map<Id,Sobject>(); 
  
  public FSFlavorChangeHeaderTriggerDispatcher (final sObject obj, final Boolean isBefore, final Boolean isDelete, final Boolean isAfter,
    final Boolean isInsert, final Boolean isUpdate, final Boolean isExecuting,
    final List<sObject> newList, final Map<ID,sObject> newmap, final List<sObject>
    oldList, final Map<ID,sObject> oldmap){
        super(obj, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting,
        newList, newmap, oldList, oldmap);
        this.MainEntry();
   }
    
    
    public override void MainEntry(){
    
       super.MainEntry(); // set appropriate execution context
       
       
       if(isBefore && isUpdate && !isBeforeUpdateProcessing){
            isBeforeUpdateProcessing=true;
             
             FSFlavorChangeHeaderTriggerHandler.beforeUpdateProcess((List<FS_Flavor_Change_Head__c>)newList,
                                                                (List<FS_Flavor_Change_Head__c>)oldList,
                                                                (Map<Id,FS_Flavor_Change_Head__c>)newMap,
                                                                (Map<Id,FS_Flavor_Change_Head__c>)oldMap,
                                                                isInsert,isUpdate,System.isBatch(),sObjectsToUpdate);
            isBeforeUpdateProcessing =false;
          
       }
       
       
       if(isAfter && isUpdate && !isAfterUpdateProcessing){
             isAfterUpdateProcessing=false;  
             
             FSFlavorChangeHeaderTriggerHandler.afterUpdateProcess((List<FS_Flavor_Change_Head__c>)newList,
                                                                (List<FS_Flavor_Change_Head__c>)oldList,
                                                                (Map<Id,FS_Flavor_Change_Head__c>)newMap,
                                                                (Map<Id,FS_Flavor_Change_Head__c>)oldMap,
                                                                isInsert,isUpdate,System.isBatch(),sObjectsToUpdate);
             isAfterUpdateProcessing=true;
       }
       
      
         updateSobjects();
        
       
    }
    
    //Method to update all records that are to be update as a part of business logic in the trigger context.
    //It is placed in this class so that the update happens after all functionality are executed for the trigger object 
    //and avoid new trigger context inside current trigger context.
    public void updateSobjects(){
    
       if(!sObjectsToUpdate.isEmpty()){
         
         final List<Sobject> listToUpdate=sObjectsToUpdate.values();
         //done to reduce chunking
         listToUpdate.sort();
         
         final Set<String> listOfObjectNames=new  Set<String>();
         
         for(Id recordId : sObjectsToUpdate.keySet()){
            final Schema.SObjectType objType = recordId.getSObjectType();
            listOfObjectNames.add(objType.getDescribe().getName());
         }
         
         final String objectNames=String.join(new List<String>(listOfObjectNames), ',');
         final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSFlavorChangeHeaderTriggerHandler',
                                                           Method_Name__c='updateSobjects',Object_Name__c=objectNames,
                                                           Error_Severity__c='High');
         FSUtil.dmlProcessorUpdate(listToUpdate,true,apexError);
       }
    }    
}