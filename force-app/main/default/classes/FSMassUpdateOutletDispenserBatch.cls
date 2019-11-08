/*********************************************************************************************************
Name         : FSMassUpdateOutletDispenserBatch 
Created By   : Infosys Limited 
Created Date : 10-Jan-2017
Usage        : Batch class which is used to update post Install attributes on Outlet Dispenser records

***********************************************************************************************************/
global class FSMassUpdateOutletDispenserBatch implements  Database.Batchable<String>,Database.Stateful,Database.AllowsCallouts{
    
    @TestVisible
    private Map<Integer,String> fieldApiOrderMap;
    
    @TestVisible
    private Map<Integer,Schema.DisplayType> fieldApiTypeMap;
        
    public Id parentId;
    public List<String> dispenserTobeSentToAirwatch=new List<String> ();
    
    @TestVisible
    private final static String FAILUREFILENAME='Failed Records.csv';
    @TestVisible
    private final static String SUCCESSFILENAME='Success Records.csv';
    @TestVisible
    private final static String ALLFAILUREFILENAME='All Failed Records.csv';
    @TestVisible
    private final static String ALLSUCCESSFILENAME='All Success Records.csv';
    @TestVisible
    private final static Integer NOOFCOLUMNS=24;
    @TestVisible
    private final static Integer ONE=1;
    @TestVisible
    private final static Object NULLOBJ = null;
    @TestVisible
    private final static String INSTALLATIONAPI='Installation__c';
    @TestVisible
    private final static String BRANDSETAPI='FS_Brandset_New__c';
    
        
    public FSMassUpdateOutletDispenserBatch (Id parentId){
         
        this.parentId=parentId;
        
        //Map of Column index and corresponding field API of csv headers
        fieldApiOrderMap =new Map<Integer,String>();
        
        for(FSPostInstallAttributesColumns__mdt metaDataRecord:  [SELECT Label,FS_Field_API__c,FS_Column_Index__c FROM 
                                                                 FSPostInstallAttributesColumns__mdt order by FS_Column_Index__c]){
                                                                 
          fieldApiOrderMap.put(Integer.valueOf(metaDataRecord.FS_Column_Index__c),metaDataRecord.FS_Field_API__c); 
          
        }
        
        
         Map<String, SObjectField> outletDispenserFields =FSUtil.getDescribeResultForSobject(FS_Outlet_Dispenser__c.SObjectType).fields.getMap();
         
        //Map of Column Index and datatype of corresponding field's API of the csv header
        fieldApiTypeMap = new Map<Integer,Schema.DisplayType>();
        
        for(Integer index: fieldApiOrderMap.keySet()){
           Schema.DescribeFieldResult fieldResults=outletDispenserFields.get(fieldApiOrderMap.get(index)).getDescribe();
           fieldApiTypeMap.put(index,fieldResults.getType()); 
        }
        
    }
    
    global Iterable<String> start(Database.BatchableContext batchContext){
    
       Attachment attach=[SELECT Id,Body,Name from Attachment where parentId=:parentId AND createdById=:UserInfo.getUserId() order by createdDate DESC limit 1];
       return new FSRowIterator(attach.Body.toString(),attach.Name);
    }
    
    
    global void execute(Database.BatchableContext batchContext, List<String> scope){
     
      List<FS_Outlet_Dispenser__c> dispensersList=new List<FS_Outlet_Dispenser__c>();  //List elements without record Id
      List<FS_Outlet_Dispenser__c> dispensersToValidateList=new  List<FS_Outlet_Dispenser__c>(); //List elements with record Id as key
      
      //Collection to hold Installation's Name
      Set<String> installationNames=new Set<String>();
      
      //Collection to hold Installation's Name and Id
      Map<String,Id> installationNameAndIdMap =new Map<String,Id>();
      
      //Collection to hold Brandset's Name
      Set<String> brandsetNames=new Set<String>();
      
      //Collection to hold Brandset's Name and Id
      Map<String,Id> brandsetNameAndIdMap =new Map<String,Id>();
      
      /*************Iterate over Iterable to get fields of type REFERENCE Start ***********************/
      for(String item : scope){ 
         
         String[]  columnData=item.split(',');
         
         for(Integer i=0;i<NOOFCOLUMNS;i++){
              
              Schema.DisplayType fieldTypeEnum= fieldApiTypeMap.get(i);
              
              if(fieldTypeEnum==Schema.DisplayType.REFERENCE){
                //Column data
                String cellData =columnData[i];
                cellData = String.isNotBlank(cellData) ? cellData.trim() : cellData;
                  
                if(fieldApiOrderMap.get(i)==INSTALLATIONAPI){
                   if(String.isNotBlank(cellData)){
                     installationNames.add(cellData);  
                   }
                }
                else if(fieldApiOrderMap.get(i)==BRANDSETAPI && String.isNotBlank(cellData)){
                    brandsetNames.add(cellData);
                }
              }
          }  
      }    
     
      installationNameAndIdMap=FSMassUpdateOutletDispenserBatchHelper.retrieveInstallationIds(installationNames);
      
      brandsetNameAndIdMap=FSMassUpdateOutletDispenserBatchHelper.retrieveBrandsetIds(brandsetNames);
      
      /*************Iterate over Iterable to get fields of type REFERENCE End***********************/
      
      
      /*****Itearation of Iterable Start***************************************************************/
      for(String item : scope){    
              
         String[]  columnData=item.split(',');
            
            FS_Outlet_Dispenser__c dispenserObj= new FS_Outlet_Dispenser__c();
            
            for(Integer i=0;i<NOOFCOLUMNS;i++){
            
              Schema.DisplayType fieldTypeEnum= fieldApiTypeMap.get(i);
              
              //Column data
              String cellData =columnData[i];
              cellData = String.isNotBlank(cellData) ? cellData.trim() : cellData;
              
              //Parse Date fields
              if(fieldTypeEnum==Schema.DisplayType.DATE){
                String columnDate=(cellData.contains('/')) ? cellData  : null;
                dispenserObj.put(fieldApiOrderMap.get(i),FSUtil.dateParserHelper(columnDate));  
              }
              else if(fieldTypeEnum==Schema.DisplayType.REFERENCE){
                  system.debug(brandsetNameAndIdMap.containsKey(cellData));
                if(fieldApiOrderMap.get(i)=='FS_Brandset_New__c' && brandsetNameAndIdMap.containsKey(cellData)){
                      dispenserObj.put(fieldApiOrderMap.get(i),brandsetNameAndIdMap.get(cellData)); 
                }
                if(fieldApiOrderMap.get(i)=='Installation__c' && installationNameAndIdMap.containsKey(cellData)){
                      dispenserObj.put(fieldApiOrderMap.get(i),installationNameAndIdMap.get(cellData)); 
                }
              }
              else{
              //Parse Other fields
                   if(fieldApiOrderMap.get(i)!='FS_Equip_Type__c'  
                        && fieldApiOrderMap.get(i)!='FS_Dispenser_Type2__c'    //Skip these fields from update
                        && fieldApiOrderMap.get(i)!='FS_IsActive__c'
                        && fieldApiOrderMap.get(i)!='FS_Status__c' && String.isNotBlank(cellData)){ 
                            dispenserObj.put(fieldApiOrderMap.get(i),cellData);
                   }
              }
              
            }
            
            dispensersList.add(dispenserObj);
           
      }   
      /*****Itearation of Iterable End***************************************************************/      
     
     
     //Set of Serial Numbers from the csv file
     Set<String> setOfSerialNumber=new Set<String>();
     for(FS_Outlet_Dispenser__c  dispenserObj :dispensersList ){
        if(dispenserObj.FS_Serial_Number2__c!=NULLOBJ){
          setOfSerialNumber.add(dispenserObj.FS_Serial_Number2__c);
        }
     }
     
     
     if(!setOfSerialNumber.isEmpty()){
     
         //Dispenser records with Salesforce Record Id
         dispensersToValidateList=FSMassUpdateOutletDispenserBatchHelper.dispensersWithIdsList(setOfSerialNumber,dispensersList);
         
         //Collection to hold record Id that failed to update along with the reason of failure
         Map<Id,String> recordIdAndErrorMessage=new  Map<Id,String>();
        
         //Collection to hold record Id that failed to update
         List <FS_Outlet_Dispenser__c> failedRecords=new List <FS_Outlet_Dispenser__c>();
         
         //Collection to hold record Id that were successfully updated
         List <FS_Outlet_Dispenser__c> successRecords=new List <FS_Outlet_Dispenser__c>();
         
         if(!dispensersToValidateList.isEmpty()){
             
             //Collection to hold records to update after custom validation
             List<FS_Outlet_Dispenser__c> dispensersToUpdateList=new  List<FS_Outlet_Dispenser__c>(); 
             
             /********************Process Records the failed custom validation Start*******************/
              recordIdAndErrorMessage=FSMassUpdateOutletDispenserBatchHelper.validateEffectiveDates(dispensersToValidateList);
                            
              for(FS_Outlet_Dispenser__c dispenserObj  : dispensersToValidateList){
                 if(recordIdAndErrorMessage.containsKey(dispenserObj.Id)){
                    failedRecords.add(dispenserObj);
                 }
                 else{
                    dispensersToUpdateList.add(dispenserObj);
                 }
              }
             /********************Process Records the failed custom validation End*******************/
             
             
             /********************Process Records the passed  custom validation Start*******************/
             if(!dispensersToUpdateList.isEmpty()){
                 
                //Update Outlet Dispenser Records
                 Database.SaveResult[] updateResults =Database.update(dispensersToUpdateList,false);
                 
                 Integer updateResultSize=updateResults.size();
                 
                 for(Integer i=0;i<updateResultSize;i++){
                 
                    if(updateResults.get(i).isSuccess()){
                       successRecords.add(dispensersToUpdateList.get(i));
                       dispenserTobeSentToAirwatch.add(dispensersToUpdateList.get(i).FS_Serial_Number2__c);
                    }
                    else{
                        // DML operation failed
                        String failedDMLMessage='';
                        for(Database.Error error : updateResults.get(i).getErrors()){
                             failedDMLMessage+= '[' +error.getMessage() +']';
                        } 
                        
                        failedRecords.add(dispensersToUpdateList.get(i));
                        
                        recordIdAndErrorMessage.put(dispensersToUpdateList.get(i).Id,failedDMLMessage);
                    }
                
                }
             }
             /********************Process Records the passed custom validation End*******************/
             
             AsyncApexJob batchJobDetails=[SELECT Id,TotalJobItems FROM AsyncApexJob WHERE Id=: batchContext.getJobId()];
              
           /*******Process failed Outlet Dispenser Records Start**************************************/    
            if(!failedRecords.isEmpty()){
             
              FSMassUpdateOutletDispenserBatchHelper.formCSVfileForFailedRecords(parentId,failedRecords,
                                                                                 recordIdAndErrorMessage,
                                                                                 FAILUREFILENAME,
                                                                                 batchJobDetails.TotalJobItems);
            }  
            /*******Process failed Outlet Dispenser Records End**************************************/
            
            /*******Process Successfull  Outlet Dispenser Records Start**************************************/  
            if(!successRecords.isEmpty()){
            
              
              FSMassUpdateOutletDispenserBatchHelper.formCSVfileForSuccessRecords(parentId,successRecords,
                                                                                  SUCCESSFILENAME,
                                                                                  batchJobDetails.TotalJobItems);
              
                            
            }
            /*******Process Successfull  Outlet Dispenser Records End**************************************/ 
          } 
     }
    } 
    
    
    
    
    public void finish(Database.BatchableContext batchContext){
      
      
      AsyncApexJob batchJobDetails=[SELECT Id,TotalJobItems FROM AsyncApexJob WHERE Id=: batchContext.getJobId()];
      
      /*Below criteria can't be tested in test class due to this error:
      System.UnexpectedException: No more than one executeBatch can be called from within a testmethod. 
      Please make sure the iterable returned from your start method matches the batch size, 
      resulting in one executeBatch invocation.*/
      List<String> fileNames=new List<String>();
      
      if(batchJobDetails.TotalJobItems > ONE || Test.isRunningTest()){
         
         
         /*****Count successfull rows and update holder -------------Start---------*******************************/
         FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c (Id=parentId,FS_Total_Number_of_Success_Records__c=0,
                                                                 FS_Total_Number_of_Failed_Records__c=0);
         fileNames=new List<String>{SUCCESSFILENAME,FAILUREFILENAME}; 
                                                                
         for(Attachment attach : [SELECT Id,Body,Name from Attachment where parentId=:parentId  
                                          AND  Name IN:fileNames]){
               if(attach.Name==SUCCESSFILENAME){
                   Integer successCount=FSUtil.calculateNumberOfRowsInCSVFile(attach.body);
                   if(successCount>ONE){
                      holder.FS_Total_Number_of_Success_Records__c+=successCount-1;
                   }
                   
               }
               else{
                  Integer failureCount=FSUtil.calculateNumberOfRowsInCSVFile(attach.body);
                  if(failureCount>ONE){
                    holder.FS_Total_Number_of_Failed_Records__c+=failureCount-1;
                  }
              }
                  
         }
         Database.update(holder,true);
         
         /*****Count successfull rows and update holder -------------End---------*******************************/
         
         /***Process and merge success csv files -- start-- ********************************************/
         fileNames =new List<String>{SUCCESSFILENAME};
         String attachmentQuery='SELECT Id,Body,Name from Attachment where parentId=:parentId ';
                 attachmentQuery +=' AND Name IN: fileNames ';
         Database.executeBatch(new FSAttachmentMergerBatch (parentId,fileNames,attachmentQuery,ALLSUCCESSFILENAME),200);
         /***Process and merge success csv files -- End-- ********************************************/
         
         /***Process and merge failure csv files -- start-- ********************************************/
         fileNames =new List<String>{FAILUREFILENAME};
         Database.executeBatch(new FSAttachmentMergerBatch (parentId,fileNames,attachmentQuery,ALLFAILUREFILENAME),200);
         /***Process and merge failure csv files -- End-- ********************************************/
      }
      else{
         fileNames=new List<String>{SUCCESSFILENAME,FAILUREFILENAME};
         
         List<Attachment> attachmentList=[SELECT Id,Body,Name from Attachment where parentId=:parentId  
                                          AND  Name IN:fileNames];
         
         /*****Count successfull rows and update holder -------------Start---------*******************************/
         FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c (Id=parentId,
                                                                 FS_Total_Batches__c=batchJobDetails.TotalJobItems);
           
         for(Attachment attach : attachmentList){
               
               if(attach.Name==SUCCESSFILENAME){
                   Integer successCount=FSUtil.calculateNumberOfRowsInCSVFile(attach.body);
                   holder.FS_Total_Number_of_Success_Records__c=successCount-1;
                   
               }
               else{
                  Integer failureCount=FSUtil.calculateNumberOfRowsInCSVFile(attach.body);
                  holder.FS_Total_Number_of_Failed_Records__c=failureCount-1;
                  
              }
                  
         }
           
        Database.update(holder,true);
        /*****Count successfull rows and update holder -------------End---------*******************************/
      }
      
      //call airwatch batch
      Database.executeBatch(new FSMassUpdateOutletDispenserAirwatchBatch(dispenserTobeSentToAirwatch));
    }
}