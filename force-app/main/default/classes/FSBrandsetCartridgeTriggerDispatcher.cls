/***************************************************************************
 Name         : FSBrandsetCartridgeTriggerDispatcher 
 Created By   : Infosys Limited
 Description  : Dispatcher for FSBrandsetCartridgeTrigger to set context variables and send trigger context variables 
                and a collection variable to hold all sobjects to be update in the same context
                to methods based on type of trigger event
 Created Date : 15-FEB-2017
****************************************************************************/
public class FSBrandsetCartridgeTriggerDispatcher extends TriggerClass{

  public static Boolean isBeforeInsertProcessing = false; 
  public static Map<Id,Sobject> sObjectsToUpdate= new Map<Id,Sobject>(); 
  
  /*****************************************************************
  Method: fSBrandsetCartridgeTriggerDispatcher
  Description: Constructor
  *******************************************************************/
  public fSBrandsetCartridgeTriggerDispatcher (final sObject obj, final Boolean isBefore, final Boolean isDelete, final Boolean isAfter,
    final Boolean isInsert, final Boolean isUpdate, final Boolean isExecuting,
    final List<sObject> newList, final Map<ID,sObject> newmap, final List<sObject>
    oldList, final Map<ID,sObject> oldmap){
        super(obj, isBefore, isDelete, isAfter, isInsert, isUpdate, isExecuting,
        newList, newmap, oldList, oldmap);
        this.MainEntry();
   }
    
    /*****************************************************************
  	Method: MainEntry
  	Description: overriding the mainentry method of superclass
	*******************************************************************/
    public override void MainEntry(){
       super.MainEntry(); // set appropriate execution context
             
          if(isBefore && isInsert && !isBeforeInsertProcessing){
            isBeforeInsertProcessing = true;
              
            FSBrandsetCartridgeTriggerHandler.beforeInsertProcess((List<FS_Brandsets_Cartridges__c>)newList,
                                                                 (List<FS_Brandsets_Cartridges__c>)oldList,
                                                                 (Map<Id,FS_Brandsets_Cartridges__c>)newMap,
                                                                 (Map<Id,FS_Brandsets_Cartridges__c>)oldMap,
                                                                 IsInsert,IsUpdate,System.isBatch(),sObjectsToUpdate);
            isBeforeInsertProcessing = false;                                                     
          }
       //As of now, this functionality is put on hold-need further confirmation to enable this
      /* if(IsAfter){
          if(IsInsert && !isAfterInsertProcessing){
            isAfterInsertProcessing=true;
            FSBrandsetCartridgeTriggerHandler.afterInsertProcess((List<FS_Brandsets_Cartridges__c>)newList,
                                                                 (List<FS_Brandsets_Cartridges__c>)oldList,
                                                                 (Map<Id,FS_Brandsets_Cartridges__c>)newMap,
                                                                 (Map<Id,FS_Brandsets_Cartridges__c>)oldMap,
                                                                 IsInsert,IsUpdate,System.isBatch(),sObjectsToUpdate);                                       
            isAfterInsertProcessing=false;
          }
       }*/
         /* if(IsUpdate && !isAfterUpdateProcessing){
             isAfterUpdateProcessing=true;
             //Call Handler FSBrandsetCartridgeTriggerHandler
             isAfterUpdateProcessing=false;                                                    
          }
       }*/
       
       
       updateSobjects();
    }
    

    /*****************************************************************
  	Method: updateSobjects
  	Description:Method to update all records that are to be update as a part of business logic in the trigger context.
    			It is placed in this class so that the update happens after all functionality are executed for the trigger object 
    			and avoid new trigger context inside current trigger context.
	*******************************************************************/
    public void updateSobjects(){    
       if(!sObjectsToUpdate.isEmpty()){
           final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSBrandsetCartridgeTriggerDispatcher',Method_Name__c='updateSobjects',Object_Name__c='FS_Brandsets_Cartridges__c',Error_Severity__c='High');
          FSUtil.dmlProcessorUpdate(sObjectsToUpdate.values(),true,apexError);
       }
    }
    
}