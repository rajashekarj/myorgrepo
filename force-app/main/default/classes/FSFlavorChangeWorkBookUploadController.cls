/*********************************************************************************************************
Name         : FSFlavorChangeWorkBookUploadController 
Created By   : Infosys Limited 
Created Date : 14-Feb-2017
Usage        : Extension for FSFlavorChangeWorkBookUpload, Which is used for Falvor Change workbook upload

***********************************************************************************************************/
public with sharing class FSFlavorChangeWorkBookUploadController {

    public transient Blob csvFileBody { get; set; }

    public String csvFileName { get; set; }
    public Id batchJobId{get;set;}
    public Id parentId{get;set;}
    public Boolean pageHasErrors{get;set;}
    
    public Id accountId{get;set;}
    public String accountACN{get;set;}
    
    public FSFlavorChangeWorkBookUploadController(){
        accountID= Apexpages.currentPage().getParameters().get('parentRecordId');
        accountACN=  Apexpages.currentPage().getParameters().get('customerACN');
    }
    public PageReference backToPrevious(){
     PageReference pageRef;
     
      pageRef=new pagereference('/'+accountID);

     return pageRef;
     
    }
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
                    FS_WorkBook_Holder__c holder = new FS_WorkBook_Holder__c (FS_WorkBook_Name__c='Flavor Change WorkBook',
                                                                              FS_Description__c='File uploaded by: '+UserInfo.getName()
                                                                              + ' on ' + Datetime.now().format() );
                    insert holder;
                    
                    //Insert attachment for each Upload
                    attch.parentId = holder.Id;
                    attch.Name=csvFileName; 
                    insert attch;
                    
                    parentId=holder.Id;
                    
                    Integer numberOfrows=FSUtil.calculateNumberOfRowsInCSVFile(attch.body);
                        holder.FS_Total_Number_of_Records__c=numberOfrows-1;           
                    update holder;
                    
                    pageHasErrors=false;
                    
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'File Uploaded Successfully'));
               }
               else{
                pageHasErrors=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Wrong file format detected, please ensure that a UTF-8 encoded CSV file format is utilized'));
              }
            }
            
        }
        catch(Exception ex){
            pageHasErrors=true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error while uploading file.'+ex.getMessage()));
            ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateOutletDispenserController ','uploadFile','Error while uploading file','Medium',ex,'NA');
        }
        
        return null;
    }
    
    
    public pagereference callBatch(){
      batchJobId=Database.executeBatch(new FSMassUpdateFlavorChangeBatch(parentId,accountID,accountACN),200);
      PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
      pageRef.setRedirect(true);
      return pageRef;
   }
   
   
}