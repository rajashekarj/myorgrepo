/**************************
	Name         : FOT_ArtifactRecordTriggerHandler
	Created By   : Infosys
	Created Date : 06/03/2018
	Usage        : This is a handler for ArtifactRecordTrigger.
	***************************/
	public class FOT_ArtifactRecordTriggerHandler 
	{
    List<FS_Artifact_Ruleset__c> rulesetList = new List<FS_Artifact_Ruleset__c>();
    List<FS_Artifact__c> artifactsToUpdate = new List<FS_Artifact__c>();
    Id recordTypeId = Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Dry Run').getRecordTypeId();
    Id publishrecordTypeId = Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Published').getRecordTypeId();
    /*****************************************************************
	Method: checkRankInsertUpdate
	Description: This method is holds logic for insert and update event.
	Added as part of FOT
	*********************************/ 
    public List<FS_Artifact__c> checkRankInsertUpdate(Set<Id> ruleSetId,boolean checkRank)
    {     
        if(!ruleSetId.isEmpty())
        {
            if(checkRank)
            {
                rulesetList = [select Id,name,(select Id,name,FS_Rank__c,CreatedDate from Artifacts__r where RecordType.Name ='Dry Run' order by FS_Rank__c asc, LastModifiedDate asc) from FS_Artifact_Ruleset__c where Id in :ruleSetId];
            }
           else
           {
               rulesetList = [select Id,name,(select Id,name,FS_Rank__c,CreatedDate from Artifacts__r where RecordType.Name ='Dry Run' order by FS_Rank__c asc, LastModifiedDate desc) from FS_Artifact_Ruleset__c where Id in :ruleSetId];
           }
           // rulesetList = [select Id,name,(select Id,name,FS_Rank__c,CreatedDate from Artifacts__r where RecordType.Name ='Dry Run' order by FS_Rank__c asc, LastModifiedDate desc) from FS_Artifact_Ruleset__c where Id in :ruleSetId];
            integer i = 1; 
            //re-arranging the ranking of Artifacts associated with RuleSet on Insert and Update operation.
            for(FS_Artifact_Ruleset__c ruleset: rulesetList)
            {
                for(FS_Artifact__c artifactToSet: ruleset.Artifacts__r)
                {
                    artifactToSet.FS_Rank__c = i;
                    i++;
                    artifactsToUpdate.add(artifactToSet);
                }
                i = 1;
            }
        }
        return artifactsToUpdate;
    }
    
    /*****************************************************************
	Method: beforeDeleteCheck
	Description: This method holds logic for before delete event.
	Added as part of FOT
	*********************************/ 
    public void beforeDeleteCheck(List<FS_Artifact__c> oldArtifactList,Map<id,FS_Artifact__c> artifactMap)
    {        
        Set<Id> publishIdSet=new Set<Id>();
        List<FS_Artifact__c> publishArtifact=new List<FS_Artifact__c>();
  
        //to delete Published Artifact on deleting Dry Run Artifact
        for(FS_Artifact__c art:oldArtifactList)
        {
            if(art.RecordTypeId == recordTypeId && art.FS_Published_Artifact__c!=null)
            {
                publishIdSet.add(art.FS_Published_Artifact__c);
            }
        }
        if(publishIdSet.size()>0)
        {
            publishArtifact=[select id from FS_Artifact__c where id in :publishIdSet];
        }
        if(publishArtifact.size()>0)
        {
            delete publishArtifact;
        }
    }
     /*****************************************************************
	Method: beforeInsertCheck
	Description: This method set seprate related list for both Dryrun and Published artifact on Rulesets.
	Added as part of FOT
	*********************************/  
        public void beforeInsertCheck(List<FS_Artifact__c> newArtifactList,Map<id,FS_Artifact__c> artifactMap){
        
        for(FS_Artifact__c art:newArtifactList)
        {
            if(art.RecordTypeId == recordTypeId)
            {
                art.FOT_DryRun_Artifact__c = art.FS_Ruleset__c;
                art.FOT_Publish_Artifact__c  = null;
            }else if(art.RecordTypeId == publishrecordTypeId){
                art.FOT_Publish_Artifact__c  = art.FS_Ruleset__c;
                art.FOT_DryRun_Artifact__c = null;
            }
        }  
    }
    /*****************************************************************
	Method: afterDeleteCheck
	Description: This method holds logic for after delete event.
	Added as part of FOT
	*********************************/    
    public List<FS_Artifact__c> afterDeleteCheck(List<FS_Artifact__c> oldArtifactList)
    {
        Boolean checkNoArtifacts = true;
        Set<Id> artifactIdSet = new set<Id>();
        Set<Id> rulesetIdList = new set<Id>();
        List<FS_Artifact_Ruleset__c> rulesetPublishList = new List<FS_Artifact_Ruleset__c>();
        
        User usr=[select profile.name from user where id=:userinfo.getUserId()];
        
        for(FS_Artifact__c art:oldArtifactList)
        {
            if(art.RecordTypeId == recordTypeId){
                artifactIdSet.add(art.id);
                rulesetIdList.add(art.FS_Ruleset__c);
            }
        }
        
        rulesetList = [select Id,name,(select Id,name,FS_Rank__c,CreatedDate from Artifacts__r where RecordType.Name ='Dry Run' order by FS_Rank__c) from FS_Artifact_Ruleset__c where Id in :rulesetIdList];
        rulesetPublishList = [select Id,name,(select Id,name,FS_Rank__c,CreatedDate from Artifacts__r where RecordType.Name ='Published' order by FS_Rank__c) from FS_Artifact_Ruleset__c where Id in :rulesetIdList];
        integer i = 1;
        //re-arranging of Dry Run Artifact ranking on deletion of record
        for(FS_Artifact_Ruleset__c ruleset: rulesetList)
        {
            for(FS_Artifact__c artifactToSet: ruleset.Artifacts__r)
            {
                artifactToSet.FS_Rank__c = i;
                i++; 
                artifactsToUpdate.add(artifactToSet);
                checkNoArtifacts = false;
            }
            i = 1;
        }
          //re-arranging of Published Artifact ranking on deletion of record
        if(rulesetPublishList.size()>0)
        {
            for(FS_Artifact_Ruleset__c ruleset: rulesetPublishList)
            {
                for(FS_Artifact__c artifactToSet: ruleset.Artifacts__r)
                {
                    artifactToSet.FS_Rank__c = i;
                    i++;
                    artifactsToUpdate.add(artifactToSet);
                    checkNoArtifacts = false;
                }
                i = 1;
            }            
        }
        
        //to delete RuleSet when no Artifacts are present
        if(rulesetList.size()==1 && checkNoArtifacts)
            delete rulesetList;
        
        return artifactsToUpdate;
    }
}