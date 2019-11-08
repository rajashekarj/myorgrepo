/*
Cancel Post Install Marketing form on all levels
Author: Praveen Sahu
Date:05/06/2015
*/
global class FSBatchCancelPostInsMrkt implements  Database.Batchable<sObject>, Database.Stateful{

// defining  the cancel variables
   public String cancelId;
   Public String pmid;
   
   // defining and initallizing  the installation set  
   public Set<Id> setInstallationIds = new Set<Id>();
   
   //Constructor
   public FSBatchCancelPostInsMrkt(String cancelId) {
     this.cancelId = cancelId;
     this.pmid=cancelId;
   }
   
     /****************************************************************************
    //Start the batch and query
    /***************************************************************************/
    
     global Database.QueryLocator start(Database.BatchableContext BC){
       //SOQL to get the Record ID for cancel field
     
           cancelid=[Select FS_RcdIDForCncl__c,FS_Installation__c From FS_Post_Install_Marketing__c Where Id=:cancelId].FS_RcdIDForCncl__c;                      
           //SOQL Which returns the list of all the post install marketing  records having Same Record ID for cancel       
          return Database.getQueryLocator([Select Id,FS_Cncl_Post_Install_Marketting_fields__c,FS_Installation__c,FS_RcdIDForCncl__c From FS_Post_Install_Marketing__c Where FS_RcdIDForCncl__c=:cancelId AND FS_RcdIDForCncl__c!='']);

   }

    /****************************************************************************
    //Process a batch
    /***************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> postInstallList){
    //Definig and initallizing list for canceling Post install marketing
    List<FS_Post_Install_Marketing__c> lstClonedMarketing= new List<FS_Post_Install_Marketing__c>();
     //Definig temp  list  post install marketing
    List<FS_Post_Install_Marketing__c > PMlist;
     //Set for canceling Post install marketing
    Set<Id> IDSet=new Set<Id>(); 
     For(FS_Post_Install_Marketing__c pmi:(List<FS_Post_Install_Marketing__c >)postInstallList){
     //adding the Post install marketing ids to set
       IDSet.add(pmi.id);
     }  
     //Quering all the Post install marketing list with all the fields 
     PMlist=Database.query(FSUtil.getSelectQuery('FS_Post_Install_Marketing__c') + ' where id=:IDSet');
         //Iterating the Post install marketing list
     for(FS_Post_Install_Marketing__c poMarketing :PMlist){
      //making the is canceled check box field to true
         poMarketing.FS_Cncl_Post_Install_Marketting_fields__c=true; 
           //adding the Post install marketing to cancel list 
         lstClonedMarketing.add(poMarketing);
          
          
         //Cheking whether the installation related field in null or not
         if(poMarketing.FS_Installation__c != null){
          //creating installation id set for passing to Outlet dispenser to cancel the Marketing fields fields
            setInstallationIds.add(poMarketing.FS_Installation__c);
         }
        }
        
        try{
        //updating the cancelled Post install marketing records
         Update lstClonedMarketing;
         }
         Catch(Exception ex)
         {      
         }

 
    }

     /****************************************************************************
    //finish the batch
    /***************************************************************************/
    global void finish(Database.BatchableContext BC){     
        ///Calling  clear Post install marketing batch to clear  values in Outlet dispenser   
        Database.executeBatch(New FSBatchClearPostInsMrktOD(pmid, setInstallationIds),200);
    }
    

}