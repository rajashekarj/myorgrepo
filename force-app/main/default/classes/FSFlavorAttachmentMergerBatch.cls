/*********************************************************************************************************
Name         : FSFlavorAttachmentMergerBatch
Created By   : Infosys Limited 
Created Date : 03-MAR-2017
Usage        : Batch class which is used to merge two or more attachments

***********************************************************************************************************/
global class FSFlavorAttachmentMergerBatch implements  Database.Batchable<String>,Database.Stateful{
   
    public Id parentId;
    public List<String> fileNames;
    public String mergedFileName;
    public String attachmentQuery;
    public Integer totalNumberOfBatches=0;
    public String csvHeader='';
    public String csvRows='';
    public static final Integer TWO=2;
  /*****************************************************************
  Method: FSFlavorAttachmentMergerBatch
  Description: Constructor
  *******************************************************************/
    public FSFlavorAttachmentMergerBatch(Id parentId,List<String> fileNames,String  attachmentQuery,String mergedFileName){
         
        this.parentId=parentId;
        this.fileNames=fileNames;
        this.attachmentQuery=attachmentQuery;
        this.mergedFileName=mergedFileName;
        
       
    }
    /*****************************************************************
  	Method: start
  	Description: Start method of batch class
	*******************************************************************/   
    global Iterable<String> start(Database.BatchableContext BatchCtx){
       
       List<Attachment> attachmentList= (List<Attachment>)Database.query(attachmentQuery);
       String csvAsString='';
       for(Attachment csvAttachment : attachmentList){
           csvAsString+= 'New File' +','+csvAttachment.Body.toString();
       }
       return new FSRowIterator(csvAsString,'Merged File');
    }
    
    /*****************************************************************
  	Method: execute
  	Description: execute method of batch class
	*******************************************************************/  
    global void execute(Database.BatchableContext BatchCtx, List<String> scope){
     
     //Counter for first occurence of header values
     Integer counter=0;

     /*****Itearation of Iterable Start***************************************************************/
      for(String item : scope){
         if(item.contains('New File') && item.contains('Merged File')){
           if(totalNumberOfBatches==0 && counter==0){
                String[]  headerNames=item.split(',');
                Integer numberOfColums=headerNames.size();
                for(Integer i=1;i<numberOfColums-1 ;i++){
                   csvHeader +=headerNames[i]+',';
                }
                csvHeader =csvHeader.removeEnd(',')+ '\n';
            }
            counter++;
            
         }
         else{
            String[]  columnData=item.split(',');
            Integer numberOfColums=columnData.size();
            for(Integer i=0;i<numberOfColums-1 ;i++){
                    csvRows +=columnData[i]+',';  
            }
            csvRows =csvRows.removeEnd(',')+ '\n';
         }
         
      }
      
      totalNumberOfBatches++;
      
    } 
    
    
    /*****************************************************************
  	Method: finish
  	Description: finish method of batch class
	*******************************************************************/   
    
    public void finish(Database.BatchableContext BatchCtx){
      String mergedFile= csvHeader+csvRows ;
      Blob csvBlob = Blob.valueOf(mergedFile);
      FSMassUpdateFlavorChangeBatchHelper.createSuccessFailureAttachments(mergedFileName,parentId,csvBlob );
      
      List<Attachment> attachmentList=[SELECT Id,Body,Name from Attachment where parentId=:parentId  
                                      AND  Name IN ('All Success Records.csv','All Failed Records.csv')];
     
     //Update Number of Batches. Used in criteria to send Email                                     
     if(attachmentList.size()==TWO){   
         FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c (Id=parentId,FS_Total_Batches__c=totalNumberOfBatches);                           
         Database.update(holder,true);  
     }                     
    }
}