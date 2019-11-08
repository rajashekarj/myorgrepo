/*
Copying flavor changes the copy to low levels from Chain to HQ
Author: Srinivas B
Date:05/04/2015
*/
global class FSBatchCopyChaintoHq implements  Database.Batchable<sObject>, Database.Stateful{

   public String recId;
   public Flavor_Change__c fc;
   public FS_Post_Install_Marketing__c PM;
   public FS_Valid_Fill__c VF;
     //Create a Set for  HQ to store outlets having installations  and Outlet Dispensers records 
    Set<Id> HQIdSet=new Set<Id>();     
     
 
   //Constructor
   public FSBatchCopyChaintoHq (String recId,Flavor_Change__c fc,FS_Post_Install_Marketing__c PM,FS_Valid_Fill__c VF) {
     this.recId = recId;
     this.fc=fc;
     this.PM=PM;
     this.VF=VF;
    
   }

   /****************************************************************************
    //Start the batch and query
    /***************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
         
        return Database.getQueryLocator([Select Id From Account where FS_Chain__c =: recId And RecordType.Name = :FSConstants.RECORD_TYPE_NAME_HQ ]); 

    }

    /****************************************************************************
    //Process a batch
    /***************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> Hqlist){
          //List of new FC to be inserted into HQ related list
    List<Flavor_Change__c> lstClonedFCHQ= new List<Flavor_Change__c>();
    
    //List of new FC to be inserted into HQ related list
    List<FS_Post_Install_Marketing__c> lstClonedMarketingHQ= new List<FS_Post_Install_Marketing__c>();
    
    //List of new VF to be inserted into HQ
    List<FS_Valid_Fill__c> lstClonedValidFillHQ = new List<FS_Valid_Fill__c>();
         
        for(Account acc : (List<Account>)Hqlist){
          if(fc!=null){  
          Flavor_Change__c newFC =  fc.clone();
          newFC.FS_Outlet_HQ_Chain__c = acc.Id;          
          newFC.FS_RcdIDForCncl__c=fc.id;
          lstClonedFCHQ.add(newFC);
          HQIdSet.add(acc.id);
          } 
         if(PM!=null){  
          FS_Post_Install_Marketing__c newPIM =  PM.clone();
          newPIM.FS_Account__c = acc.Id;
          newPIM.FS_RcdIDForCncl__c=PM.Id;
          lstClonedMarketingHQ.add(newPIM);
          HQIdSet.add(acc.id);
          } 
         if(VF!=null){  
         FS_Valid_Fill__c newVF =  VF.clone();
          newVF.FS_Outlet__c  = acc.Id;
          lstClonedValidFillHQ.add(newVF);
          HQIdSet.add(acc.id);
          } 
          
        }
         try{
         insert lstClonedFCHQ;
         insert lstClonedMarketingHQ;
         insert lstClonedValidFillHQ;
         }
         Catch(Exception ex)
         {      
         }
 
    }

     /****************************************************************************
    //finish the batch
    /***************************************************************************/
    global void finish(Database.BatchableContext BC){
   
    if(!HQIdSet.isEmpty()){
    if(FC!=null)
        Database.Executebatch(new FSBatchCopyHqtoOutlet(null,fc,null,null,HQIdSet),200 );
    if(PM!=null)
        Database.Executebatch(new FSBatchCopyHqtoOutlet(null,null,PM,null,HQIdSet),200 );
    if(VF!=null)
        Database.Executebatch(new FSBatchCopyHqtoOutlet(null,null,null,VF,HQIdSet),200 );
     }
     

    }

}