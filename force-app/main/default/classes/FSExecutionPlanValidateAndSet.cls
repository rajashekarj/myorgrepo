/**************************************************************************************
Apex Class Name     : FSExecutionPlanValidateAndSet
Version             : 1.0
Function            : This is a Helper class for FSExecutionPlanTriggerHandler class, which have the record type Id fetching 
						functionality as well as picklist value change cheking functionality
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkat             01/12/2017          Original Version
* Venkat			 20/12/2017		 	Updated as part of FET 5.0
*************************************************************************************/


public class FSExecutionPlanValidateAndSet { 
    public static final String EQUIPPACK='Equipment Package';
    public static final String TECHINST='Technician Instruction';
    public static Id epRecTypeExecutionPlan;
    public static Id epTIrecType;
    public static Id epEPrecType;
    
    public static Map<Id,String> mapofRecordtypIdAndRecordTypeName= new Map<Id,String>();
    public static Map<String,Id> mapofExecutionPlanRecordtypNameAndRecordTypeId= new Map<String,Id>();   
    //FET 5.0
    //Static block to assign RecordTypeId to variables of Execution plan, Equipment Package and Technician Instrcution objects
    //to reuse the variable for Recordtypeid in other places.  
    static{        
        final ID referID=null;
        if(epRecTypeExecutionPlan==referID){
            epRecTypeExecutionPlan=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.sObjectType,FSConstants.EXECUTIONPLAN);
        }
        if(epEPrecType==referID){
            epEPrecType=FSUtil.getObjectRecordTypeId(FS_EP_Equipment_Package__c.sObjectType,EQUIPPACK); 
        }
        if(epTIrecType==referID){
            epTIrecType=FSUtil.getObjectRecordTypeId(FS_EP_Technician_Instructions__c.sObjectType,TECHINST); 
        } 
        
        mapofRecordtypIdAndRecordTypeName.put(epRecTypeExecutionPlan,FSConstants.EXECUTIONPLAN);
        mapofRecordtypIdAndRecordTypeName.put(epEPrecType,EQUIPPACK);
        mapofRecordtypIdAndRecordTypeName.put(epTIrecType,TECHINST);
        
        mapofExecutionPlanRecordtypNameAndRecordTypeId.put(FSConstants.EXECUTIONPLAN,epRecTypeExecutionPlan);  
        mapofExecutionPlanRecordtypNameAndRecordTypeId.put(EQUIPPACK,epEPrecType);
        mapofExecutionPlanRecordtypNameAndRecordTypeId.put(TECHINST,epTIrecType);           
    }
    //FET 5.0
    
   
     /*****************************************************************
  	Method: updateLocalTime
  	Description: updateLocalTime  method to update a date time field of each record every time it is created/updated
				Added this method as part of FET 4.0
	*******************************************************************/   
    public static void updateLocalTime(final List<FS_Execution_Plan__c> newList){
        
        Datetime dateValue=DateTime.now(); 
        // Eastern Daylight Saving Time Check 
        if(DateTime.now().month()== 1 || DateTime.now().month()== 2 || DateTime.now().month()== 3 
           || DateTime.now().month()== 11 || DateTime.now().month()== 12) {
               dateValue= DateTime.now().addHours(-5); 
           } else {
               dateValue= DateTime.now().addHours(-4); 
           }
        final String srcString=String.valueof(dateValue.formatGMT('YYYY-MM-dd hh:mm:ss a'));
        for(FS_Execution_Plan__c execution:newList){
            execution.FS_Local_Time__c=srcString;
        }        
    }  
     /*****************************************************************
  	Method: taskAllocation
  	Description: taskAllocation  method to create task for the COM user when ever EP gets created
				Added this method as part of FET 4.0
	*******************************************************************/   
    public static void taskAllocation(final List<FS_Execution_Plan__c> newList, final Map<Id, FS_Execution_Plan__c> oldMap){
        
        final List<Task> epTaskList= new List<Task>();        
        for(FS_Execution_Plan__c EP :newList){
            if(EP.CreatedDate!=FSConstants.NULLVALUE && EP.FS_Back_up_COM__c != FSConstants.NULLVALUE ){
                final Task epTask = new Task();
                epTask.OwnerId = EP.FS_Back_up_COM__c;
                epTask.Subject = 'EP Created';
                epTask.Status = 'Not Started';
                epTask.Priority = 'Normal';
                epTask.WhatId = EP.Id;
                epTask.FS_Action__c='Details Needed';
                epTask.IsReminderSet=false;
                
                epTaskList.add(epTask);
            }
        }
        if(!epTaskList.isEmpty()){
            //Creating error logger instance with required information
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSExecutionPlanValidateAndSet',
                                                           Method_Name__c='taskAllocation',Object_Name__c='Task',
                                                           Error_Severity__c=FSConstants.MediumPriority);
            //Upserting New Task Records after Execution Plan record creation
            FSUtil.dmlProcessorUpsert(epTaskList,true,apexError);            
        }        
    }     
}