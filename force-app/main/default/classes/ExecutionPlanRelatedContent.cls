/*********************************************************************************
 Author       :   Dipika (Appirio Offshore)
 Created Date :   April 9,2013
 Task         :   T-128538
 Description  :   Controller class for OpportunityRelatedContent page
                  
*********************************************************************************/
public class ExecutionPlanRelatedContent {
   
    public FS_Execution_Plan__c ep{get;set;}
    //public List<ContentVersion> relatedContenVersionDocuments{get;set;}
    public List<FeedItem> feedItems{get;set;}
    //public String selectedContent{get;set;}
    
    //constructor
    public ExecutionPlanRelatedContent(ApexPages.StandardController controller){
        ep = (FS_Execution_plan__c)controller.getRecord();
        ep = [SELECT ID,FS_Headquarters__c From FS_Execution_Plan__c Where Id=:ep.id];
        prepareFeedItemList();
    }
    
    /*&preparing list of related contents
    public void prepareContentVersionList(){
        relatedContenVersionDocuments = new List<ContentVersion>();
        for(ContentVersion version : [Select c.ID,c.Title, c.LastModifiedDate,ownerId, 
                                      c.CreatedDate,owner.name,contentDocumentId,contentDocument.Title 
                                      From ContentVersion c  
                                      where campaign__c = :opp.CampaignId 
                                      and isLatest = true and campaign__c!=null order by Title]){
            relatedContenVersionDocuments.add(version);
        }
    }*/
    
    
    //preparing list of related attachment
    public void prepareFeedItemList(){
        FeedItems = new List<FeedItem>();
        for(FeedItem att : [Select Id ,ParentId, Title, LastModifiedDate,
                              CreatedDate, RELATEDRECORDID From FeedItem 
                              where ParentId = :ep.FS_Headquarters__c  
                              and ParentId!=null 
                              and Type = 'ContentPost' order by Title]){
            FeedItems.add(att);
        }
    }
    
}