/*
Copying flavor changes the copy to low levels from Hq to Outlets
Author: Srinivas B
Date:05/04/2015
*/
global class FSBatchCopyHqtoOutlet implements  Database.Batchable<sObject>, Database.Stateful{

   public String recId;
   public Flavor_Change__c fc;
  
   public FS_Post_Install_Marketing__c PM;
   public FS_Valid_Fill__c VF;
     //Create a Set for  HQ to store outlets having installations  and Outlet Dispensers records 
    Set<Id> HQIdSet;
       
     
 
   //Create a Set for  outlet to store outlets having installations  and Outlet Dispensers records 
    Set<Id> outltIdSet=new Set<Id>();

   //Constructor
   public FSBatchCopyHqtoOutlet (String recId,Flavor_Change__c fc,FS_Post_Install_Marketing__c PM,FS_Valid_Fill__c VF,Set<Id> HQIdSet) {
     this.recId = recId;
     this.fc=fc;
     this.HQIdSet=HQIdSet;
     this.fc=fc;
     this.PM=PM;
     this.VF=VF;       
    
   }
   
     /****************************************************************************
    //Start the batch and query
    /***************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
     if(HQIdSet == null){
        HQIdSet = new Set<Id>();
        HQIdSet.add(recId);
     }
           
        return Database.getQueryLocator([Select Id  From Account where FS_Headquarters__c =: HQIdSet And RecordType.Name = :FSConstants.RECORD_TYPE_NAME_OUTLET]); 
      
    }

    /****************************************************************************
    //Process a batch
    /***************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> outletList){
     //List of new FC to be inserted into Outlet related list
    List<Flavor_Change__c> lstClonedFCOutlet= new List<Flavor_Change__c>();
    
    //List of new Marketing to be inserted into outlet related list
    List<FS_Post_Install_Marketing__c> lstClonedMarketOutlet = new List<FS_Post_Install_Marketing__c>();
    
     //List of new VF to be inserted into outlet
    List<FS_Valid_Fill__c> lstClonedValidFilloutlt = new List<FS_Valid_Fill__c>();
        for(Account acc : (List<Account>)outletList){
        if(fc!=null){
         Flavor_Change__c newFC =  fc.clone();
         newFC.FS_Outlet_HQ_Chain__c = acc.Id;
         newFC.FS_RcdIDForCncl__c=fc.id;
         lstClonedFCOutlet.add(newFC);
         outltIdSet.add(acc.id);
         }    
        if(PM!=null){
         FS_Post_Install_Marketing__c newPIM =  PM.clone();
          newPIM.FS_Account__c = acc.Id;
          newPIM.FS_RcdIDForCncl__c=PM.id;
          lstClonedMarketOutlet.add(newPIM);
          outltIdSet.add(acc.id);
        } 
        if(VF!=null){
          FS_Valid_Fill__c newVF = VF.clone();
              newVF.FS_Outlet__c  = acc.Id;                                 
              lstClonedValidFilloutlt.add(newVF);
              outltIdSet.add(acc.id);
         } 
        }
         try{
         insert lstClonedFCOutlet;
         insert lstClonedMarketOutlet;
         insert lstClonedValidFilloutlt;
         }
         Catch(Exception ex){
         
         }
 
    }

     /****************************************************************************
    //finish the batch
    /***************************************************************************/
    global void finish(Database.BatchableContext BC){
   
    if(!outltIdSet.isEmpty()){
        if(PM!=null)
        Database.Executebatch(new FSBatchCopyOutletToOD(null,null,PM,null,outltIdSet),100 );
        if(VF!=null)
        Database.Executebatch(new FSBatchCopyOutletToOD(null,null,null,VF,outltIdSet),100 );

 
    }
    }

}