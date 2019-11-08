/*********************************************************************************************************
Name         : FSSendEmailWhenFileProcessingIsComplete
Created By   : Infosys Limited
Created Date : 27-Feb-2017
Usage        : Class is Invoked by Process Builder to Send Email When File Processing is Complete
***********************************************************************************************************/
public with sharing class FSSendEmailWhenFileProcessingIsComplete{

@InvocableMethod(label='Send Email When File Processing is Complete' description='sendSuccessAndFailureAttachments')
  
  public static void sendSuccessAndFailureAttachments(List<FS_WorkBook_Holder__c> workBookHolderList) {
     
     Map<Id,FS_WorkBook_Holder__c> workBookHolderMap=new Map<Id,FS_WorkBook_Holder__c>(workBookHolderList);
     Set<Id> parentIdsWhenMerged=new Set<Id>();   
     Set<Id> parentIdsNoMerge=new Set<Id>();
     String attachmentName='';
     for(FS_WorkBook_Holder__c holder : workBookHolderList){
         //Final attachment as a result of merged.
         if(holder.FS_Total_Batches__c>1){
            parentIdsWhenMerged.add(holder.Id);
         }
         //attachment as a result for total batches=1
         else if(holder.FS_Total_Batches__c==1){
            parentIdsNoMerge.add(holder.Id);
         }
     } 
    //Query to fetch the actual attachment name and use it in the email body later.
     List<Attachment> attachmentWithName=[SELECT Id,Name,parentId from Attachment where parentId=:workBookHolderList[0].id
                                          AND  Name NOT IN ('All Success Records.csv','All Failed Records.csv','Success Records.csv','Failed Records.csv') LIMIT 1];
     
     if(!attachmentWithName.isEmpty()){
        attachmentName=attachmentWithName[0].Name;
     }
      
      if(!parentIdsWhenMerged.isEmpty()){
       List<Attachment> attachmentList=[SELECT Id,Body,Name,parentId from Attachment where parentId in: parentIdsWhenMerged
                                          AND  Name IN ('All Success Records.csv','All Failed Records.csv')];
                                    
       formEmailBodyAndSendEmail(parentIdsWhenMerged,attachmentList,workBookHolderMap,attachmentName); 
     }
     if(!parentIdsNoMerge.isEmpty()){
        List<Attachment> attachmentList=[SELECT Id,Body,Name from Attachment where parentId in: parentIdsNoMerge
                                          AND  Name IN ('Success Records.csv','Failed Records.csv')];
        
        formEmailBodyAndSendEmail(parentIdsNoMerge,attachmentList,workBookHolderMap,attachmentName);                                  
     } 
  }
  
  public static void formEmailBodyAndSendEmail(Set<Id> parentIds,List<Attachment> attachmentList,Map<Id,FS_WorkBook_Holder__c> workBookHolderMap,string attachmentName){
      
      String subject='';
      String emailBody='Hi '+ UserInfo.getFirstName() +' ,'+ '\n\n';
      Integer totalNoOfRecords=0;
      String totalNumberOfRecords='';
      String totalNumberFailures='';
      String totalNumberSuccess='';
      String flavorChangeHeaderId='';
      for(Id parentId : parentIds){
          
          totalNumberOfRecords= String.valueOf((workBookHolderMap.get(parentId).FS_Total_Number_of_Records__c).intValue());
          totalNumberSuccess= String.valueOf((workBookHolderMap.get(parentId).FS_Total_Number_of_Success_Records__c).intValue());
          totalNumberFailures= String.valueOf((workBookHolderMap.get(parentId).FS_Total_Number_of_Failed_Records__c).intValue());
          if(workBookHolderMap.get(parentId).FS_FCHeaderId__c!=null){
              flavorChangeHeaderId=String.valueOf(workBookHolderMap.get(parentId).FS_FCHeaderId__c);
          }          
              
          if(workBookHolderMap.get(parentId).FS_WorkBook_Name__c.containsIgnoreCase('Dispenser')){
            subject='Dispensers Mass Update Status';
          }
          if(workBookHolderMap.get(parentId).FS_WorkBook_Name__c.containsIgnoreCase('Flavor')){
              subject='Flavor Change Upload Status';
          }
      } 
      totalNoOfRecords=Integer.valueOf(totalNumberSuccess)+Integer.valueOf(totalNumberFailures);
      emailBody+='The uploaded file has been processed successfully.'+ '\n\n';
      emailBody+='File Name  :-  '+attachmentName+ '\n';
      //emailBody+='Total No of Records    = '+totalNumberOfRecords+ '\n';
      emailBody+='Total No of Records    = '+totalNoOfRecords+ '\n';
      emailBody+='No of Success Records = '+totalNumberSuccess+'\n';
      emailBody+='No of Failure Records  = '+totalNumberFailures+'\n';
      if(subject.containsIgnoreCase('Flavor') && string.isNotEmpty(flavorChangeHeaderId)){
              //emailBody+='The header created under this upload can be accessed by clicking on the link:- '+Label.FSOrgURL+flavorChangeHeaderId;
              emailBody+='\n The header created under this upload can be accessed by clicking on the link:- https://'+URL.getSalesforceBaseUrl().getHost()+'/'+flavorChangeHeaderId;
          }
      
      //Send email with attachment
      FSUtil.sendMail(true,attachmentList,subject,emailBody,new List<String>{UserInfo.getUserEmail()});    
  }
}