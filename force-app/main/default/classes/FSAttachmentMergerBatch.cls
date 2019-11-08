/*********************************************************************************************************
Name         : FSAttachmentMergerBatch
Created By   : Infosys Limited 
Created Date : 24-Feb-2017
Usage        : Batch class which is used to merge two or more attachments

***********************************************************************************************************/
global class FSAttachmentMergerBatch implements  Database.Batchable<String>,Database.Stateful{
   
    public Id parentId;
    public List<String> fileNames;
    public String mergedFileName;
    public String attachmentQuery;
    public Integer totalNumberOfBatches=0;
    public Integer initialValue=0;
    public String csvHeader='';
    public String csvRows='';
    private final static Integer TWO=2;
    /*****************************************************************
  	Method: FSAttachmentMergerBatch
  	Description: Constructor
	*******************************************************************/
    public FSAttachmentMergerBatch(Id parentId,List<String> fileNames,String  attachmentQuery,String mergedFileName){
         
        this.parentId=parentId;
        this.fileNames=fileNames;
        this.attachmentQuery=attachmentQuery;
        this.mergedFileName=mergedFileName;
        
       
    }
    /*****************************************************************
  	Method: start
  	Description: Start method of batch class
	*******************************************************************/
    global Iterable<String> start(Database.BatchableContext batchContext){
       
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
    global void execute(Database.BatchableContext batchContext, List<String> scope){
     
     //Counter for first occurence of header values
     Integer counter=0;
        String newFile='New File';
        String mergedFile='Merged File';
        String comma=',';

     /*****Itearation of Iterable Start***************************************************************/
      for(String item : scope){
         if(item.contains(newFile) && item.contains(mergedFile)){
           if(totalNumberOfBatches==initialValue && counter==initialValue){
                String[]  headerNames=item.split(comma);
                Integer numberOfColums=headerNames.size();
                for(Integer i=1;i<numberOfColums-1 ;i++){
                   csvHeader +=headerNames[i]+comma;
                }
                csvHeader =csvHeader.removeEnd(comma)+ '\n';
            }
            counter++;
            
         }
         else{
            String[]  columnData=item.split(comma);
            Integer numberOfColums=columnData.size();
            for(Integer i=0;i<numberOfColums-1 ;i++){
                if(i==initialValue){
                  String recordId=columnData[i];
                  String hyperLinkedRecord=FSMassUpdateOutletDispenserBatchHelper.createHyperlinkedColumData(recordId);
                  csvRows +=hyperLinkedRecord+comma;
                }
                else{
                  csvRows +=columnData[i]+comma;
                }
                   
            }
            csvRows =csvRows.removeEnd(comma)+ '\n';
         }
         
      }
      
      totalNumberOfBatches++;
      
    } 
    
    
    
    /*****************************************************************
  	Method: finish
  	Description: finish method of batch class
	*******************************************************************/
    public void finish(Database.BatchableContext batchContext){
      String successRecord='All Success Records.csv';
        String failRecord='All Failed Records.csv';
      String mergedFile= csvHeader+csvRows ;
      Blob csvBlob = Blob.valueOf(mergedFile);
      FSMassUpdateOutletDispenserBatchHelper.createSuccessFailureAttachments(mergedFileName,parentId,csvBlob );
      
      List<Attachment> attachmentList=[SELECT Id,Body,Name from Attachment where parentId=:parentId  
                                      AND  Name IN (:successRecord,:failRecord)];
     
     //Update Number of Batches. Used in criteria to send Email                                     
     if(attachmentList.size()==TWO){   
         FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c (Id=parentId,FS_Total_Batches__c=totalNumberOfBatches);                           
         Database.update(holder,true);  
     }
     
     
                        
    }
}