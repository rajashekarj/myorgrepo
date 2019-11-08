/*********************************************************************************************************
Name         : FSMassUpdateOutletDispenserController 
Created By   : Infosys Limited 
Created Date : 10-Jan-2017
Usage        : Extension for FSMassUpdateOutletDispenserPage, which is used to update post Install attributes on Outlet Dispenser

***********************************************************************************************************/
public with sharing class FSMassUpdateOutletDispenserController {
    
    public transient Blob csvFileBody { get; set; }

    public String csvFileName { get; set; }
    public Id batchJobId{get;set;}
    public Id parentId{get;set;}
    public Boolean pageHasErrors{get;set;}
    
     public PageReference uploadFile() {
        try{
            if(String.isBlank(csvFileName)){
              pageHasErrors=true;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'A UTF-8 encoded CSV file is needed when utilizing the upload button functionality'));
            }
            else{
                if(csvFileName.endsWith('.csv')){
                    Attachment attch =new Attachment();
                    attch.body = csvFileBody ;
                
                    //Insert holder Record for each Upload
                    FS_WorkBook_Holder__c holder = new FS_WorkBook_Holder__c (FS_WorkBook_Name__c='Dispenser WorkBook',
                                                                              FS_Description__c='File uploaded by: '+UserInfo.getName()
                                                                              + ' on ' + Datetime.now().format() );
                    insert holder;
                    
                    //Insert attachment for each Upload
                    attch.parentId = holder.Id;
                    attch.Name=csvFileName; 
                    Database.insert(attch,true);
                    
                    parentId=holder.Id;
                    
                    Integer numberOfrows=FSUtil.calculateNumberOfRowsInCSVFile(attch.body);
                    holder.FS_Total_Number_of_Records__c=numberOfrows-1;
                    Database.update(holder,true);
                    
                    pageHasErrors=false;
                    
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'File Uploaded Successfully'));
              }
              else{
                pageHasErrors=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Wrong file format detected, please ensure that a UTF-8 encoded CSV file format is utilized'));
              }
            }  
        }
        catch(dmlException ex){
           pageHasErrors=true;
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error while uploading file.'+ex.getMessage()));
           ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateOutletDispenserController ','uploadFile','Error while uploading file','Medium',ex,ex.getMessage());
        }
        
        return null;
    }
    
   
    
    public pagereference callBatch(){
      batchJobId=Database.executeBatch(new FSMassUpdateOutletDispenserBatch(parentId),200);
      PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
      pageRef.setRedirect(true);
      return pageRef;
      
   }
   
}