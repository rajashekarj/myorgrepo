/*********************************************************************************************************
Name         : FSMassUpdateFlavorChangeBatch 
Created By   : Infosys Limited 
Created Date : 15-Feb-2017
Usage        : Batch class which is used to update flavor change records
*********************************  ** ************************************************************************/
global class FSMassUpdateFlavorChangeBatch implements  Database.Batchable<String>{
    @TestVisible
    private static final String NEWLINE='\n';
    @TestVisible
    private static final String COMMA=',';
    private static final string ACSTRING='AC/PC email Id';
    private static final string PMSTRING='PM email Id';
    private static final string COMSTRING='COM email Id';
    private static final Integer ACN=0;
    private static final Integer PLATFORM=1;
    private static final Integer SERIALNO=2;
    private static final Integer CURRENTBRANDSET=3;
    private static final Integer NEWBRANDSET=4;
    private static final Integer BSEFFECTIVEDATE=5;
    private static final Integer HIDESHOWWATER=6;
    private static final Integer WATEREFFECTIVEDATE=7;
    //private static final Integer HIDESHOWDASANI=8;
    //private static final Integer DASANEFFECTDATE=9;
    private static final Integer PUNGENTCHNG=8;
    private static final Integer PAYTYPE=9;
    private static final Integer FCREQUESTDATE=10;
    private static final Integer PRODUCTHNDLBY=11;
    private static final Integer SPGOOUT=12;
    private static final Integer DATEPRODUCTAVAIL=13;
    private static final Integer NDOAPPROVAL=14;
    private static final Integer CDMSETUP=15;
    private static final Integer ESTIMATEDFCDATE=16;
    private static final Integer CUSTOMERNOTE=17;
    private static final Integer POMACTION=18;
    private static final Integer ORDERPROCESSED=19;
    private static final Integer ACUSER=20;
	private static final Integer ACUSERNAME=21;
    private static final Integer PROJECTID=22;
    private static final Integer PROJECTDESCRIPTION=23;
    private static final Integer PMUSER=24;
	private static final Integer PMUSERNAME=25;
    private static final Integer COMUSER=26;
	private static final Integer COMUSERNAME=27;
    private static final Integer SCHEDULEDDATE=28;
    private static final Integer ORDERMETHOD=29;
    private static final Integer DELIVERYMETHOD=30;
    private static final Integer ONE=1;
    private static final string SUCCESSCSVNAME='Success Records.csv';
    public static final string SHARETYPE = 'I';
    public static final string VISIBILITY = 'AllUsers';
    //@TestVisible
    //private final Map<Integer,String> fieldApiOrderMap;
    
    public final static Object NULLOBJ = null;
    public Id parentId;
    public Map<String,Id> brandsetNameAndIdMap;
    public Id accountId{get;set;}
    public String accountACN{get;set;}
   
    
    public FSMassUpdateFlavorChangeBatch (final Id parentId,final Id accountId,final String accountACN){
         
        this.accountId=accountId;
        this.accountACN=accountACN;
        this.parentId=parentId;
        
        //Map of Column index and corresponding field API of csv headers
        /*fieldApiOrderMap =new Map<Integer,String>();
        for(FS_FlavorChangeFileColumnDetails__mdt metaDataRecord:  [SELECT Label,FS_Field_API__c,FS_Column_Index__c FROM 
                                                                 FS_FlavorChangeFileColumnDetails__mdt WHERE Label!=NULL order by FS_Column_Index__c]){
                                                                 
          fieldApiOrderMap.put(Integer.valueOf(metaDataRecord.FS_Column_Index__c),metaDataRecord.FS_Field_API__c);
        }*/       
    }
    
    global Iterable<String> start(Database.BatchableContext batchCtx){
    
       final Attachment attach=[SELECT Id,Body,Name from Attachment where parentId=:parentId AND createdById=:UserInfo.getUserId() order by createdDate DESC limit 1];
       return new FSRowIterator(attach.Body.toString(),attach.Name);
    }
    
    
    global void execute(final Database.BatchableContext batchCtx, final List<String> scope){
        
      final set<string> dispenserSerialNumberSet= new set<string>();
      final set<string> outletAcnSet=new set<string>();
      final set<String> newBrandsetSet=new set<string>();
      final Set<string> platformSet=new set<string>();
      final Set<string> aCUserSet=new set<string>();
     // final Set<string> pmUserSet=new set<string>();
     // final Set<string> comUserSet=new set<string>();
    
        
      List<FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper> detailWrapperList=new List<FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper>();
      string excelHeader='';
        /*****Itearation of Iterable Start***************************************************************/
        
        
      for(String item : scope){   
          String comments='';
          if(string.isNotBlank(item) && item.contains('"')){
              comments=item.substringBetween('"');
              item=item.replace(comments,'');            
          }
          final String[]  columnData=item.split(COMMA);
          //To update Scheduled Date for Water/Dasani
          Boolean dateChecker = false;
          String scheduledDateWD;
         final FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper detailFlavorWrapperItem=new FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper();
            for(Integer column=0;column<31;column++){
              
              //Column data
              String cellData =columnData[column];
              cellData = cellData ==null ? '' : cellData.trim();
              if(column==ACN){
                  
                 detailFlavorWrapperItem.outletACN=cellData;
                  if(!cellData.containsIgnoreCase('ACN')){
                      outletAcnSet.add(cellData);
                  }
                  
              }
              if(column==PLATFORM){  
                 detailFlavorWrapperItem.platform=cellData;
                  if(!cellData.containsIgnoreCase('Platform')){
                      platformSet.add(cellData);
                  }
              }
              if(column==SERIALNO){
                 detailFlavorWrapperItem.serialNumber=cellData;
                  if(!cellData.containsIgnoreCase('Serial')){
                      dispenserSerialNumberSet.add(cellData);
                  }
              }
              if(column==CURRENTBRANDSET){
                 detailFlavorWrapperItem.currentbrandset=cellData;
              }
              if(column==NEWBRANDSET){
                 detailFlavorWrapperItem.newBrandset=cellData;
				 if(String.isBlank(cellData))
				 {
					 dateChecker=true;
				 }
                  if(!cellData.containsIgnoreCase('future brandset')){
                      newBrandsetSet.add(cellData);
                  }                 
              }
              if(column==BSEFFECTIVEDATE){
                 detailFlavorWrapperItem.brandsetEffectiveDate=cellData;
              }
              if(column==HIDESHOWWATER){
                 detailFlavorWrapperItem.waterHideData=cellData;
              }
                //OCR Changes
              if(column==WATEREFFECTIVEDATE){
                 detailFlavorWrapperItem.waterHideEffectvieDate=cellData;
				 
				 if(!String.isBlank(cellData) && dateChecker )
				 {
					scheduledDateWD=cellData;
				 }
				 
				 
              }
              /*
              if(column==HIDESHOWDASANI){
                 detailFlavorWrapperItem.dasaniData=cellData;
              }
               //OCR Changes
              if(column==DASANEFFECTDATE){
                 detailFlavorWrapperItem.dasaniDataEffectvieDate=cellData;
				 
				 if(!String.isBlank(cellData) && dateChecker && String.isBlank(scheduledDateWD) )
				 {
					scheduledDateWD=cellData;
				 }
				 
				 
				 
              }*/
              if(column==PUNGENTCHNG){
                 detailFlavorWrapperItem.pungentChangeIndicator=cellData;
              }
              if(column==PAYTYPE){
                 detailFlavorWrapperItem.customerPayorAccountPay=cellData;
              }
              if(column==FCREQUESTDATE){
                 detailFlavorWrapperItem.requestedDate=cellData;
              }
              if(column==PRODUCTHNDLBY){
                 detailFlavorWrapperItem.productOrderHandeledBy=cellData;
              }
              if(column==SPGOOUT){
                 detailFlavorWrapperItem.spNeedToGoOut=cellData;
              }
              if(column==DATEPRODUCTAVAIL){
                 detailFlavorWrapperItem.dateProductidAvaliableInDC=cellData;
              }
              if(column==NDOAPPROVAL){
                 detailFlavorWrapperItem.NDOapprovalCheck=cellData;
              }
              if(column==CDMSETUP){
                 detailFlavorWrapperItem.CDMSetupComplete=cellData;
              } 
              if(column==ESTIMATEDFCDATE){
                 detailFlavorWrapperItem.estimatedFlavorChangeDate=cellData;
              }
              if(column==CUSTOMERNOTE){
                  if(string.isNotBlank(comments)){
                      detailFlavorWrapperItem.customerServiceNotes='"'+comments+'"';
                  }
                  else{
                      detailFlavorWrapperItem.customerServiceNotes=cellData;
                  }
                 
              }
              if(column==POMACTION){
                 detailFlavorWrapperItem.POMActionsComplete=cellData;
              } 
              if(column==ORDERPROCESSED){
                 detailFlavorWrapperItem.orderProcessed=cellData;
              } 
              if(column==ACUSER){
                  if(!ACSTRING.equals(cellData)){
                      aCUserSet.add(cellData);
                  }                  
                 detailFlavorWrapperItem.aCUser=cellData;
              }
              if(column==ACUSERNAME){
                  
                 detailFlavorWrapperItem.aCUserName=cellData;              
              }
              if(column==PROJECTID){
                 detailFlavorWrapperItem.projectID=cellData;
              }
              if(column==PROJECTDESCRIPTION){
                 detailFlavorWrapperItem.projectDescription=cellData;
              }
              if(column==PMUSER){
                 if(!PMSTRING.equals(cellData)){
                      aCUserSet.add(cellData);
                 }
                 detailFlavorWrapperItem.pmUser=cellData;
              }
              if(column==PMUSERNAME){
                 
                 detailFlavorWrapperItem.pmUserName=cellData;
              }
              if(column==COMUSER){
                 if(!COMSTRING.equals(cellData)){
                      aCUserSet.add(cellData);
                 }
                 detailFlavorWrapperItem.comUser=cellData;
              }
              if(column==COMUSERNAME){
                
                 detailFlavorWrapperItem.comUserName=cellData;
              }
              if(column==SCHEDULEDDATE){
				  if(dateChecker)
				  {
						detailFlavorWrapperItem.scheduledDate=scheduledDateWD;
				  }
				  else
				  {
					  detailFlavorWrapperItem.scheduledDate=cellData;
				  }
                 
				 
              }
              if(column==ORDERMETHOD){
                 detailFlavorWrapperItem.orderMethod=cellData;
              }
              if(column==DELIVERYMETHOD){
                 detailFlavorWrapperItem.deliveryMethod=cellData;
              }
            }          
              detailWrapperList.add(detailFlavorWrapperItem);
      }     
        //preparing an excel header to write into the excel file
        excelHeader='outlet ACN (blended in case of relocations),dispenser platform type,serial number,Current Brandset,future brandset,effective date,Future Non branded water,future effective date non branded water,Pungent Change Indicator,Customer pay / account pay,Requested Date,Flavor Change Initial Order handled by?,SP needs to go out,Date product is available at DC,NDO approval checkbox,CDM Setup complete,Estimated Flavor Change Date,Customer Support Notes,POM actions complete,Order Processed,AC/PC email Id,AC/PC Name,Project ID,Project Description,PM email Id,PM Name,COM email Id,COM Name,Scheduled Date,Order Method,Delivery Method';
        detailWrapperList.remove(0);
        //Sending the list for validation and getting the validated list in return
        detailWrapperList=FSMassUpdateFlavorChangeBatchHelper.validation(detailWrapperList,accountId,accountACN,dispenserSerialNumberSet,newBrandsetSet,outletAcnSet,platformSet,aCUserSet);
        
        //This method is used to create the flavor changes lines and headers and service providers
        system.debug('AAAA'+detailWrapperList);
        FSMassUpdateFlavorChangeBatchHelper.createFlavorChanges(detailWrapperList,accountId,parentId);
        
        string successCSV=excelHeader+NEWLINE;
        string errorCSV=excelHeader+COMMA+'Validation Error'+NEWLINE;
        string container='';
        for(FSMassUpdateFlavorChangeBatchHelper.detailFlavorChangeWrapper detailFlavorChangeWrapper:detailWrapperList){
            
            container=detailFlavorChangeWrapper.outletACN+COMMA+detailFlavorChangeWrapper.platform+COMMA+
                            detailFlavorChangeWrapper.serialNumber+COMMA+
                            detailFlavorChangeWrapper.currentbrandset+COMMA+detailFlavorChangeWrapper.newBrandset+COMMA+
                            detailFlavorChangeWrapper.brandsetEffectiveDate+COMMA+
                            detailFlavorChangeWrapper.waterHideData+COMMA+detailFlavorChangeWrapper.waterHideEffectvieDate+COMMA+
                            //detailFlavorChangeWrapper.dasaniData+COMMA+detailFlavorChangeWrapper.dasaniDataEffectvieDate+COMMA+
                            detailFlavorChangeWrapper.pungentChangeIndicator+COMMA+detailFlavorChangeWrapper.customerPayorAccountPay+COMMA+
                            detailFlavorChangeWrapper.requestedDate+COMMA+detailFlavorChangeWrapper.productOrderHandeledBy+COMMA+
                            detailFlavorChangeWrapper.spNeedToGoOut+COMMA+detailFlavorChangeWrapper.dateProductidAvaliableInDC+COMMA+
                            detailFlavorChangeWrapper.NDOapprovalCheck+COMMA+detailFlavorChangeWrapper.CDMSetupComplete+COMMA+
                            detailFlavorChangeWrapper.estimatedFlavorChangeDate+COMMA+detailFlavorChangeWrapper.customerServiceNotes+COMMA+
                            detailFlavorChangeWrapper.POMActionsComplete+COMMA+
                			detailFlavorChangeWrapper.orderProcessed+COMMA+                			
                			detailFlavorChangeWrapper.aCUser+COMMA+
                			detailFlavorChangeWrapper.aCUserName+COMMA+
                			detailFlavorChangeWrapper.projectID+COMMA+detailFlavorChangeWrapper.projectDescription+COMMA+
                			detailFlavorChangeWrapper.pmUser+COMMA+detailFlavorChangeWrapper.pmUserName+COMMA+
                			detailFlavorChangeWrapper.comUser+COMMA+detailFlavorChangeWrapper.comUserName+COMMA+
                			detailFlavorChangeWrapper.scheduledDate+COMMA+
                			detailFlavorChangeWrapper.orderMethod+COMMA+detailFlavorChangeWrapper.deliveryMethod;
            system.debug('container:-'+container);
            
            if(detailFlavorChangeWrapper.validationPassed){
                successCSV+=container+NEWLINE;
            }
            else{
                errorCSV+=container+','+detailFlavorChangeWrapper.validationErrorMessage+NEWLINE;
            }
        }
        
        if(!string.isEmpty(successCSV)){
            final Blob successCsvBlob = Blob.valueOf(successCSV);
            FSMassUpdateFlavorChangeBatchHelper.createSuccessFailureAttachments('Success Records.csv',parentId,successCsvBlob);
        }
        if(!string.isEmpty(errorCSV) || !errorCSV.equals(excelHeader+NEWLINE)){
            final Blob errorCsvBlob = Blob.valueOf(errorCSV);
            FSMassUpdateFlavorChangeBatchHelper.createSuccessFailureAttachments('Failed Records.csv',parentId,errorCsvBlob);
        }
        
    }   
    
    
    
    public void finish(Database.BatchableContext batchCtx){
    
      final AsyncApexJob batchJobDetails=[SELECT Id,TotalJobItems FROM AsyncApexJob WHERE Id=: batchCtx.getJobId()];
      
      final FS_WorkBook_Holder__c workbookRec= [SELECT id,name,FS_WorkBook_Name__c,FS_FCHeaderId__r.Id FROM FS_WorkBook_Holder__c WHERE FS_FCHeaderId__c!=null AND LastModifiedById=:UserInfo.getUserId() ORDER BY createdDate DESC LIMIT 1];
      
        if(batchJobDetails.TotalJobItems > ONE){
         
         
         /*****Count successfull rows and update holder -------------Start---------*******************************/
         FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c (Id=parentId,FS_Total_Number_of_Success_Records__c=0,
                                                                 FS_Total_Number_of_Failed_Records__c=0);
                                                                 
         for(Attachment attach : [SELECT Id,Body,Name from Attachment where parentId=:parentId  
                                          AND  Name IN ('Success Records.csv','Failed Records.csv')]){
               
               if(attach.Name==SUCCESSCSVNAME){
                   final Integer successCount=FSUtil.calculateNumberOfRowsInCSVFile(attach.body);
                   if(successCount>ONE){
                      holder.FS_Total_Number_of_Success_Records__c+=successCount-1;
                   }
                   
               }
               else{
                  final Integer failureCount=FSUtil.calculateNumberOfRowsInCSVFile(attach.body);
                  if(failureCount>ONE){
                    holder.FS_Total_Number_of_Failed_Records__c+=failureCount-1;
                  }
              }
                  
         }
         update holder;
         
         /*****Count successfull rows and update holder -------------End---------*******************************/
         
         /***Process and merge success csv files -- start-- ********************************************/
         List<String> fileNames =new List<String>{'Success Records.csv'};
         String attachmentQuery='SELECT Id,Body,Name from Attachment where parentId=:parentId ';
                 attachmentQuery +='AND Name IN: fileNames ';
         Database.executeBatch(new FSFlavorAttachmentMergerBatch (parentId,fileNames,attachmentQuery,'All Success Records.csv'),200);
         /***Process and merge success csv files -- End-- ********************************************/
         
         /***Process and merge failure csv files -- start-- ********************************************/
         fileNames =new List<String>{'Failed Records.csv'};
         Database.executeBatch(new FSFlavorAttachmentMergerBatch (parentId,fileNames,attachmentQuery,'All Failed Records.csv'),200);
         /***Process and merge failure csv files -- End-- ********************************************/
		system.debug('batchJobDetails.TotalJobItems :-'+batchJobDetails.TotalJobItems );
      }
      else{
         final List<Attachment> attachmentList=[SELECT Id,Body,Name from Attachment where parentId=:parentId  
                                          AND  Name IN ('Success Records.csv','Failed Records.csv')];
         
         /*****Count successfull rows and update holder -------------Start---------*******************************/
         final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c (Id=parentId,
                                                                 FS_Total_Batches__c=batchJobDetails.TotalJobItems);
           
         for(Attachment attach : attachmentList){
               
               if(attach.Name==SUCCESSCSVNAME){
                   final Integer successCount=FSUtil.calculateNumberOfRowsInCSVFile(attach.body);
                   holder.FS_Total_Number_of_Success_Records__c=successCount-1;
                   
               }
               else{
                  final Integer failureCount=FSUtil.calculateNumberOfRowsInCSVFile(attach.body);
                  holder.FS_Total_Number_of_Failed_Records__c=failureCount-1;
                  
              }
                  
         }
           
        update holder;
        /*****Count successfull rows and update holder -------------End---------******************************/
      }
        if(workbookRec!=NULLOBJ){           
        
        final Attachment fcAttachment=[SELECT Id,Body,Name from Attachment where parentId=:workbookRec.Id AND Name NOT IN ('All Success Records.csv','All Failed Records.csv','Success Records.csv','Failed Records.csv') LIMIT 1];
        final Attachment fcAttach=new Attachment();
        fcAttach.Name=fcAttachment.Name;
        fcAttach.Body=fcAttachment.Body;
        fcAttach.ParentId=workbookRec.FS_FCHeaderId__c;
        insert fcAttach;
        Try{
            //Create ContentVersion
            ContentVersion v = new ContentVersion();
            v.versionData = fcAttachment.Body;
            v.title = fcAttachment.Name;
            v.pathOnClient ='/'+fcAttachment.Name;
            insert v;
            
            //Get the ContentDocumentId
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:v.Id].ContentDocumentId;
            
            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = id.valueof(workbookRec.FS_FCHeaderId__c);
            cDe.ShareType = SHARETYPE; // Inferred permission, checkout description of ContentDocumentLink object for more details
            cDe.Visibility = VISIBILITY; //Visibility to All Users
            insert cDe;
            
        }catch(exception e){
            ApexErrorLogger.addApexErrorLog('FET','FSMassUpdateFlavorChangeBatch','finish','FS_Flavor_Change_Head__c','HIGH',e,e.getMessage());
        }
      }
    }
}