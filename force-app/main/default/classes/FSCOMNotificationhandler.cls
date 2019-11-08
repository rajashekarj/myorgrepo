/*********************************************************************************
 Author		 	 	: INFOSYS
     Apex Class Name 	: FSCOMNotificationhandler
 Version         	: 1.0
 Function        	: This is a handler class for CIF trigger 'FSCOMNotifications'
 Modification Log   :
 Developer           		      Date             Description
 ________________________________________________________________ 
 Venkata Phaneendra Yammanuru     13th Jan 2017    Original Version

**********************************************************************************/
public with sharing class FSCOMNotificationhandler { 
    public static Boolean check=false;
    public static Boolean mapMethodCheck=false;//OCR
    public static final String SITEACTION='Site assessment disposition provided. Action may be needed';
    public static final String COMACTION='Site Assessment is Completed';
    public static final String SECOND='Second ';
    public static final String OPEN='Open';
    public static final String FUP='FUP Needed';
    public static final String NORMAL='Normal';
    public static final String SURVEYRESULT='Survey Results Back';
    public static final Object NULLVALUE=null; 
    
   /**************************************************************************
    Method      	: beforeUpdate
	Description 	: Method to populate default Brandset from Headquarters 
					  before updating the CIF record
    **************************************************************************/
    public static void beforeUpdate(List<FS_CIF__c> updatedCIFs,Map<Id, FS_CIF__c> oldMap,Map<Id, FS_CIF__c> newMap){
        final List<FS_CIF__c> cifUpdatedList=new List<FS_CIF__c>();
        final Set<Id> cifHeadIds=new Set<Id>();
        final Map<String,String> cifHeadHQMap=new Map<String,String>();
        final Map<String,FS_Association_Brandset__c> hqBrandsetMap=new Map<String,FS_Association_Brandset__c>();
        final Set<ID> cifHeadID = new Set<ID>();
        final Set<ID> cifOlHqs = new Set<ID>();
        final Map<id,CIF_Header__c> cifHeadMap=new Map<id,CIF_Header__c>();
        final Map<id,Account> accOLMap=new Map<id,Account>();
        
        for(FS_CIF__c cif : updatedCIFs){cifHeadID.add(cif.CIF_Head__c);}
         for(CIF_Header__c headCIF:[SELECT ID,FS_HQ__c FROM CIF_Header__c where ID IN:cifHeadID])      {
                 cifHeadMap.put(headCIF.Id,headCIF);
             }
        
		for(FS_CIF__c cif : updatedCIFs){cifOlHqs.add(cif.FS_Account__c);}
        
        for(Account acc:[SELECT ID,FS_Headquarters__c FROM Account  where Id IN:cifOlHqs])
             {
                 accOLMap.put(acc.Id,acc);
             }
        
        for(FS_CIF__c cif:updatedCIFs){
            if(cif.FS_Platform1__c!=oldMap.get(cif.Id).FS_Platform1__c || cif.FS_Platform2__c!=oldMap.get(cif.Id).FS_Platform2__c || cif.FS_Platform3__c!=oldMap.get(cif.Id).FS_Platform3__c){
                cifUpdatedList.add(cif);
                cifHeadIds.add(cif.FS_Headquarters__c);
                cifHeadHQMap.put(cif.Id,cif.FS_Headquarters__c);
            }

            if(cif.FS_Customer_s_disposition_after_review__c == 'Cancelled' && oldMap.get(cif.Id).FS_Customer_s_disposition_after_review__c != 'Cancelled' && accOLMap.get(cif.FS_Account__c).FS_Headquarters__c != cifHeadMap.get(cif.CIF_Head__c).FS_HQ__c){
                cif.FS_Contractor_Contact__c=null;
                cif.FS_Outlet_Contact__c=null;
                cif.FS_On_Boarding_Contact__c=null;
                cif.FS_Select_Site_assessment_contact__c=null;
                cif.FS_Training_Customer_Contact__c=null;
                cif.FS_Water_Filter_Contact__c=null;
                cif.FS_Water_Filter_Contact_Name__c=null;
                cif.Water_Filter_Installer_Name__c=null;
                cif.FS_Order_Administrator__c=null;
                cif.FS_Order_Standard_User__c=null;
            }
        }
        for(FS_Association_Brandset__c brand:[select id,FS_Brandset__c,FS_Headquarters__c,FS_Platform__c from FS_Association_Brandset__c where FS_Headquarters__c IN:cifHeadIds]){
            hqBrandsetMap.put(brand.FS_Headquarters__c+brand.FS_Platform__c, brand);
        }
        for(FS_CIF__c cif:cifUpdatedList){
            if(cifHeadHQMap.containsKey(cif.Id)){
                if(cif.FS_Platform1__c!=oldMap.get(cif.Id).FS_Platform1__c && cif.FS_Platform1__c!=NULLVALUE){
                    if(hqBrandsetMap.containsKey(cifHeadHQMap.get(cif.Id)+cif.FS_Platform1__c)){
                        cif.FS_Brandset1__c=hqBrandsetMap.get(cifHeadHQMap.get(cif.Id)+cif.FS_Platform1__c).FS_Brandset__c;   
                    }
                    else{
                        cif.FS_Brandset1__c=null;
                    }
                }
                if(cif.FS_Platform2__c!=oldMap.get(cif.Id).FS_Platform2__c && cif.FS_Platform2__c!=NULLVALUE){
                    if(hqBrandsetMap.containsKey(cifHeadHQMap.get(cif.Id)+cif.FS_Platform2__c)){
                        cif.FS_Brandset2__c=hqBrandsetMap.get(cifHeadHQMap.get(cif.Id)+cif.FS_Platform2__c).FS_Brandset__c;
                    }
                    else{
                        cif.FS_Brandset2__c=null;
                    }                                      
                }
                if(cif.FS_Platform3__c!=oldMap.get(cif.Id).FS_Platform3__c && cif.FS_Platform3__c!=NULLVALUE){
                    if(hqBrandsetMap.containsKey(cifHeadHQMap.get(cif.Id)+cif.FS_Platform3__c)){
                        cif.FS_Brandset3__c=hqBrandsetMap.get(cifHeadHQMap.get(cif.Id)+cif.FS_Platform3__c).FS_Brandset__c;
                    }
                    else{
                        cif.FS_Brandset3__c=null;
                    }                              
                }
            }
        }       
    }
    
    
    /**************************************************************************
    Method      	: afterUpdate
	Description 	: Method contains validations for email notifation and 
					  task creation
    **************************************************************************/
    public static void afterUpdate(List<FS_CIF__c> updatedCIFs,Map<Id, FS_CIF__c> oldMap,Map<Id, FS_CIF__c> newMap) {   
        System.debug('After Update Trigger');
        if(!check){            
             final List<Messaging.SingleEmailMessage> allMail=new List<Messaging.SingleEmailMessage>();    
             final Set<ID> cifHeadID = new Set<ID>();
             final List<Task> cifTaskList= new List<Task>();
             final Map<id,CIF_Header__c> cifHeadMap=new Map<id,CIF_Header__c>();
             final Map<id,FS_CIF__c> cifMap=new Map<id,FS_CIF__c>();
            
             for(FS_CIF__c cif : updatedCIFs){cifHeadID.add(cif.CIF_Head__c);}
             for(CIF_Header__c headCIF:[SELECT ID,FS_CIF_Number__c,FS_HQ__c,FS_HQ__r.Name,FSCOM__c,FS_Sales_Rep_Name__c,FS_FPS__r.email,FS_FPS__r.name,FSCOM__r.UserID__r.Email,FSCOM__r.UserID__r.Name,FS_Sales_Rep_Name__r.UserID__r.Email,FS_Sales_Rep_Name__r.UserID__r.Name,FSCOM__r.UserID__c FROM CIF_Header__c where ID IN:cifHeadID])
             {
                 cifHeadMap.put(headCIF.Id,headCIF);
             }
            
             for(FS_CIF__c cif:[select Id,Name,FS_Account__c,FS_Account__r.Name,FS_Account__r.FS_ACN__c from FS_CIF__c where Id IN :newMap.keySet()])
            
             {
                 cifMap.put(cif.Id,cif);
             }    
            System.debug('Size of updatedCIFs');
             for(FS_CIF__c cif : updatedCIFs){  
                 System.debug('updatedCIFsupdatedCIFs' + updatedCIFs.size());
                 if(oldMap != null && cif.FS_Customer_s_disposition_after_review__c != oldMap.get(cif.id).FS_Customer_s_disposition_after_review__c &&
                    cif.FS_Customer_s_disposition_after_review__c =='Approved by Customer' && cifHeadMap.containsKey(cif.CIF_Head__c)){                        
                    	System.debug('Check debug values::');
                        final CIF_Header__c cifHd=cifHeadMap.get(cif.CIF_Head__c);                            
                     //   if(cifHd.FSCOM__r.UserID__c==userinfo.getUserId()){
                            if(cifHd.id==cif.CIF_Head__c && cifHd.FS_FPS__c!=null){  
                                // string mailBody = getEmailBody(cifMap,cifHd, cif.Id,SITEACTION,true);    
                               // final Messaging.SingleEmailMessage mail=FsCIF_SendEmail_Helper.sendEmail(cifHd.FS_FPS__r.Email,cifHd.FS_FPS__c,SITEACTION,mailBody);                    
                                final Task addTask=createTask(cifHd.FS_FPS__c,'Survey Approved',OPEN,NORMAL,cif.Id,'Create EP');              
                                cifTaskList.add(addTask);
                              //  allMail.add(mail);                      
                            }
                            if(cifHd.id==cif.CIF_Head__c &&cifHd.FS_Sales_Rep_Name__c!=null){  
                                string mailBody = getEmailBody(cifMap,cifHd, cif.Id,SITEACTION,true);    
                                final Messaging.SingleEmailMessage mail=FsCIF_SendEmail_Helper.sendEmail(cifHd.FS_Sales_Rep_Name__r.UserID__r.Email,cifHd.FS_Sales_Rep_Name__r.UserID__c,SITEACTION,mailBody);
                                allMail.add(mail);
                            }
                        	if(cifHd.id==cif.CIF_Head__c &&cifHd.FSCOM__c!=null){  
                                string mailBody = getEmailBody(cifMap,cifHd, cif.Id,SITEACTION,true);    
                                final Messaging.SingleEmailMessage mail=FsCIF_SendEmail_Helper.sendEmail(cifHd.FSCOM__r.UserID__r.Email,cifHd.FSCOM__r.UserID__c,SITEACTION,mailBody);
                                allMail.add(mail);
                            }
                      //  }
                        
                    }
                
                 if(oldMap != null && (cif.FS_SA_Completed_Date__c != oldMap.get(cif.id).FS_SA_Completed_Date__c || 
                    cif.FS_Second_Site_Assessment_Completed_Date__c != oldMap.get(cif.id).FS_Second_Site_Assessment_Completed_Date__c) && 
                    cifHeadMap.containsKey(cif.CIF_Head__c) && cif.FS_What_type_of_Site_Assessment__c != 'SA Not Required - OSM approval required for local market'){
                   
                        final CIF_Header__c cifHd=cifHeadMap.get(cif.CIF_Head__c);                        
                        
                       //Home Page Alert for FPS User
                       if(cifHd.id==cif.CIF_Head__c && cifHd.FS_FPS__c!=null && cif.FS_SA_Completed_Date__c != oldMap.get(cif.id).FS_SA_Completed_Date__c){  
                             final Task addTask=createTask(cifHd.FS_FPS__c,SURVEYRESULT,OPEN,NORMAL,cif.Id,FUP);                  
                             cifTaskList.add(addTask);                            
                          }                        
                       if(cifHd.id==cif.CIF_Head__c && cifHd.FS_FPS__c!=null && 
                           	 cif.FS_Second_Site_Assessment_Completed_Date__c != oldMap.get(cif.id).FS_Second_Site_Assessment_Completed_Date__c){                     
                           	 final Task addTask=createTask(cifHd.FS_FPS__c,SURVEYRESULT,OPEN,NORMAL,cif.Id,FUP);                  
                             cifTaskList.add(addTask);                            
                          }
                        
                        //Email Notification to Sales Lead            
                       if(cifHd.id==cif.CIF_Head__c && cifHd.FS_Sales_Rep_Name__c!=null){ 
                            if(cif.FS_SA_Completed_Date__c != oldMap.get(cif.id).FS_SA_Completed_Date__c){
                                string mailBody = getEmailBody(cifMap,cifHd, cif.Id,COMACTION,false);        
                                final Messaging.SingleEmailMessage mail=FsCIF_SendEmail_Helper.sendEmail(cifHd.FS_Sales_Rep_Name__r.UserID__r.Email,cifHd.FS_Sales_Rep_Name__r.UserID__c,COMACTION,mailBody); 
                                allMail.add(mail);  
                            }
                            if(cif.FS_Second_Site_Assessment_Completed_Date__c != oldMap.get(cif.id).FS_Second_Site_Assessment_Completed_Date__c){
                                string mailBody = getEmailBody(cifMap,cifHd, cif.Id,SECOND+COMACTION,false);    
                                final Messaging.SingleEmailMessage mail=FsCIF_SendEmail_Helper.sendEmail(cifHd.FS_Sales_Rep_Name__r.UserID__r.Email,cifHd.FS_Sales_Rep_Name__r.UserID__c,SECOND+COMACTION,mailBody); 
                                allMail.add(mail);  
                            }                            
                        }  
                    }
                 // OCR Changes Defect# : 4034  Send Email Notification for Rush Install.
                  if(oldMap != null && cif.FS_Perf_Site_Assessment__c != oldMap.get(cif.id).FS_Perf_Site_Assessment__c && 
                    cif.FS_Perf_Site_Assessment__c == 'Yes' && cifHeadMap.containsKey(cif.CIF_Head__c) && 
                    (cif.FS_What_type_of_Site_Assessment__c == System.Label.RushSiteAssessGFEBidProposal || 
                     cif.FS_What_type_of_Site_Assessment__c == System.Label.RushSiteAssessmentOnly || 
                     cif.FS_What_type_of_Site_Assessment__c == System.Label.RushNewConstructionSA )){
                         final CIF_Header__c cifHd=cifHeadMap.get(cif.CIF_Head__c);                            
                         FsCIF_SendEmail_Helper.rushInstNotify(cifHd.FS_CIF_Number__c,cif.CIF_Head__c);
                         check=true;
                             }
            }
            if(!cifTaskList.isEmpty()){
                check=true;
                upsert cifTaskList;
            }            
            if(!allMail.isEmpty()){
                check=true;
                final Messaging.SendEmailResult[] results = Messaging.SendEmail(allMail,true);
                               
            }
             //OCR
            if(!mapMethodCheck){                
                mapMethodCheck=true;                
                mapCIFDavacoToIP(updatedCIFs,oldMap,newMap);
            }
            //OCR
        }        
    }
    
    /****************************************************************************
    Method      	: getEmailBody
	Description 	: Method to set Email body for the email Alerts
    *****************************************************************************/
    
    private static string  getEmailBody(Map<Id,FS_CIF__c> cifMap, CIF_Header__c cifhead,Id cifId,string subject,Boolean body){
        string mailBody = '';
        if(body)
        {
         if(cifMap.containsKey(cifId)){
                mailBody=mailbody+'<b>Account Information</b>:<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +cifhead.FS_HQ__c +'">'
                    + cifhead.FS_HQ__r.Name+'</a>' +'<br>';
                mailBody=mailBody+'<b>CIF</b> :<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +cifhead.Id +'">'
                    + cifMap.get(cifId).Name+'</a>' +'<br>';
                mailBody=mailBody+'<b>Outlet details</b> :<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +cifMap.get(cifId).FS_Account__c +'">'
                    + cifMap.get(cifId).FS_Account__r.Name+'</a>' +'<br>';
                mailBody=mailBody+'If approved, please ensure all mandatory fields / sections are completed and proceed with creation of execution plan';
               
            } 
        }
        else{
            mailBody = '<b>Outlet details</b>:'+'<br><br>'+'Outlet ACN   :'+cifMap.get(cifId).FS_Account__r.FS_ACN__c+'<br>'+'Outlet Name :'+cifMap.get(cifId).FS_Account__r.Name+'<br>';
             if(subject.equals(COMACTION)){
                    mailBody = mailBody+COMACTION;
                }
             else if(subject.equals(SECOND+COMACTION)){
                 	mailBody = mailBody+SECOND+COMACTION; 
                }
            }   
             return mailbody;
    }
    
    /**************************************************************************
    Method      	: createTask
	Description 	: Method to create task
    **************************************************************************/
    private static Task createTask(Id owner,String subject,String status,String priority,Id whatId,String action){
        final Task newTask=new Task();
        newTask.ownerId=owner;
        newTask.subject=subject;
        newTask.status=status;
        newTask.priority=priority;
        newTask.whatId=whatId;
        newTask.FS_Action__c=action;        
        newTask.IsReminderSet=false;        
        return newTask;
    }
     
    //OCR
    /**************************************************************************
    Method      	: populateCIFToIP
	Description 	: Method to copy down CIF level Davaco field changes to installation
    **************************************************************************/
  	@future
    public static void populateCIFToIP(Set<Id> cifIdSet,Set<Id> installIdSet){
        final List<FS_Installation__c> installList=new List<FS_Installation__c>();
        final Map<Id,FS_CIF__C> cifLineMap=new Map<Id,FS_CIF__C>();        
        try{
            if(!cifIdSet.isEmpty()){
                for(FS_CIF__C cif:[select id,name,FS_Installation__c,FS_SA_Scheduled_On_Date__c,FS_SA_Completed_Date__c,
                                   FS_SA_Scheduled_Contacted_Date__c,FS_SA_Scheduled_By__c,FS_SA_Unable_to_Complete_Reason__c,
                                   FS_SA_Rescheduled_On_Date__c,FS_SA_Rescheduled_Reason__c,FS_Second_SA_Rescheduled_Date__c,
                                   FS_Second_SA_Rescheduled_Reason__c,FS_Site_Prep_Contract_Received__c,FS_Date_GFE_Posted__c,
                                   FS_Second_SA_Scheduled_Date__c,FS_Second_Site_Assessment_Completed_Date__c,
                                   FS_Second_SA_Scheduled_Contacted_Date__c,FS_Second_SA_Scheduled_By__c,FS_Second_SA_Incomplete_reason__c
                                   from FS_CIF__C where id IN:cifIdSet]){
                 	cifLineMap.put(cif.Id, cif);
                                   }            	
                for(FS_Installation__c install:[select id,name,FS_CIF__C,FS_SA_Scheduled_On_Date__c,FS_SA_Completed_Date__c,
                                                FS_SA_Scheduled_Contacted_Date__c,FS_SA_Scheduled_By__c,FS_SA_Unable_to_Complete_Reason__c,
                                                FS_SA_Rescheduled_On_Date__c,FS_SA_Rescheduled_Reason__c,FS_Second_SA_Rescheduled_Date__c,
                                                FS_Second_SA_Rescheduled_Reason__c,FS_Site_Prep_Contract_Received__c,FS_Date_GFE_Posted__c,FS_Second_SA_Scheduled_Contacted_Date__c,
                                                X2nd_SA_Scheduled_On_Date__c,X2nd_SA_Completed_Date__c,FS_Second_SA_Scheduled_By__c,FS_Second_SA_Incomplete_reason__c
                                                from FS_Installation__c where FS_CIF__C IN:cifIdSet and FS_Overall_Status__c!=:FSConstants.IPCOMPLETE and FS_Overall_Status__c!=:FSConstants.IPCANCELLED ]){
                	if(cifLineMap.containsKey(install.FS_CIF__C)){
                        final FS_CIF__C cifItem=cifLineMap.get(install.FS_CIF__C);
                        install.FS_SA_Scheduled_On_Date__c=cifItem.FS_SA_Scheduled_On_Date__c;
                        install.FS_SA_Completed_Date__c=cifItem.FS_SA_Completed_Date__c;
                        install.FS_SA_Scheduled_Contacted_Date__c=cifItem.FS_SA_Scheduled_Contacted_Date__c;
                        install.FS_SA_Scheduled_By__c=cifItem.FS_SA_Scheduled_By__c;
                        install.FS_SA_Unable_to_Complete_Reason__c=cifItem.FS_SA_Unable_to_Complete_Reason__c;
                        install.FS_SA_Rescheduled_On_Date__c=cifItem.FS_SA_Rescheduled_On_Date__c;
                        install.FS_SA_Rescheduled_Reason__c=cifItem.FS_SA_Rescheduled_Reason__c;
                        install.FS_Second_SA_Rescheduled_Date__c=cifItem.FS_Second_SA_Rescheduled_Date__c;
                        install.FS_Second_SA_Rescheduled_Reason__c=cifItem.FS_Second_SA_Rescheduled_Reason__c;
                        install.FS_Site_Prep_Contract_Received__c=cifItem.FS_Site_Prep_Contract_Received__c;
                        install.FS_Date_GFE_Posted__c=cifItem.FS_Date_GFE_Posted__c;
                        install.X2nd_SA_Scheduled_On_Date__c=cifItem.FS_Second_SA_Scheduled_Date__c;
                        install.X2nd_SA_Completed_Date__c=cifItem.FS_Second_Site_Assessment_Completed_Date__c;
                        install.FS_Second_SA_Scheduled_Contacted_Date__c  =cifItem.FS_Second_SA_Scheduled_Contacted_Date__c;
                        install.FS_Second_SA_Scheduled_By__c=cifItem.FS_Second_SA_Scheduled_By__c;
                        install.FS_Second_SA_Incomplete_reason__c=cifItem.FS_Second_SA_Incomplete_reason__c;
                        installList.add(install);                                                    
                     }
            	}            	
            	if(!installList.isEmpty()){
                	update installList;
            	}
        	}
        }
        catch(DMLException e){          
            system.debug('Exception '+e.getLineNumber()+'error'+e);
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSCOMNotificationhandler','populateCIFToIP','FS_Installation__c',FSConstants.MediumPriority,e,e.getMessage());            
        }
    }
    /**************************************************************************
    Method      	: mapCIFDavacoToIP
	Description 	: Method to Validate CIF Davaco field changes after EP got created
    **************************************************************************/
    public static void mapCIFDavacoToIP(List<FS_CIF__c> updatedCIFsList,Map<Id, FS_CIF__c> oldMapCIF,Map<Id, FS_CIF__c> newMap){                
        final Set<Id> installIdSet=new Set<Id>();
        final Set<Id> cifIdSet=new Set<Id>();        
        
        for(FS_CIF__c cifLine:updatedCIFsList){
            if(cifLine.FS_Installation__c!=NULLVALUE && (cifLine.FS_SA_Scheduled_On_Date__c!=oldMapCIF.get(cifLine.Id).FS_SA_Scheduled_On_Date__c ||
                                                         cifLine.FS_SA_Completed_Date__c!=oldMapCIF.get(cifLine.Id).FS_SA_Completed_Date__c || 
                                                         cifLine.FS_SA_Scheduled_Contacted_Date__c!=oldMapCIF.get(cifLine.Id).FS_SA_Scheduled_Contacted_Date__c ||
                                                         cifLine.FS_SA_Scheduled_By__c!=oldMapCIF.get(cifLine.Id).FS_SA_Scheduled_By__c || 
                                                         cifLine.FS_SA_Unable_to_Complete_Reason__c!=oldMapCIF.get(cifLine.Id).FS_SA_Unable_to_Complete_Reason__c ||
                                                         cifLine.FS_SA_Rescheduled_On_Date__c!=oldMapCIF.get(cifLine.Id).FS_SA_Rescheduled_On_Date__c || 
                                                         cifLine.FS_SA_Rescheduled_Reason__c!=oldMapCIF.get(cifLine.Id).FS_SA_Rescheduled_Reason__c ||
                                                         cifLine.FS_Second_SA_Rescheduled_Date__c!=oldMapCIF.get(cifLine.Id).FS_SA_Rescheduled_On_Date__c || 
                                                         cifLine.FS_Second_SA_Rescheduled_Reason__c!=oldMapCIF.get(cifLine.Id).FS_Second_SA_Rescheduled_Reason__c || 
                                                         cifLine.FS_Site_Prep_Contract_Received__c!=oldMapCIF.get(cifLine.Id).FS_Site_Prep_Contract_Received__c || 
                                                         cifLine.FS_Date_GFE_Posted__c!=oldMapCIF.get(cifLine.Id).FS_Date_GFE_Posted__c || cifLine.FS_Second_SA_Scheduled_Date__c!=oldMapCIF.get(cifLine.Id).FS_Second_SA_Scheduled_Date__c ||
                                                         cifLine.FS_Second_Site_Assessment_Completed_Date__c!=oldMapCIF.get(cifLine.Id).FS_Second_Site_Assessment_Completed_Date__c || 
                                                         cifLine.FS_Second_SA_Scheduled_Contacted_Date__c!=oldMapCIF.get(cifLine.Id).FS_Second_SA_Scheduled_Contacted_Date__c || 
                                                         cifLine.FS_Second_SA_Scheduled_By__c!=oldMapCIF.get(cifLine.Id).FS_Second_SA_Scheduled_By__c || 
                                                         cifLine.FS_Second_SA_Incomplete_reason__c!=oldMapCIF.get(cifLine.Id).FS_Second_SA_Incomplete_reason__c)) {
           installIdSet.add(cifLine.FS_Installation__c);                   
           cifIdSet.add(cifLine.Id);
           }
        } 
        system.debug('cifIdSet 340-->?'+cifIdSet);
        if(!cifIdSet.isEmpty()){
            populateCIFToIP(cifIdSet,installIdSet);
        }        
    }      
    //OCR      
}