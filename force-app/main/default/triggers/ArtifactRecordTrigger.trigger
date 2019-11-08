/**************************
Name         : ArtifactRecordTrigger
Created By   : Infosys
Created Date : 06/03/2018
Usage        : This trigger gets fired on any action on FS_Artifact__c record.
***************************/
trigger ArtifactRecordTrigger on FS_Artifact__c (after insert, after update, before delete,before insert, after delete) 
{
    
    Id recordTypeId = Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Dry Run').getRecordTypeId();
    Id publishrecordTypeId = Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Published').getRecordTypeId();
    Set<Id> artifactIdSet = new set<Id>();
    Set<Id> rulesetIdList = new set<Id>();
    List<FS_Artifact_Ruleset__c> rulesetList = new List<FS_Artifact_Ruleset__c>();
    List<FS_Artifact__c> artifactsToUpdate = new List<FS_Artifact__c>();
    Boolean checkNoArtifacts = true;
    FOT_ArtifactRecordTriggerHandler handler=new FOT_ArtifactRecordTriggerHandler();
    Boolean checkRank=false;
    
    String profileName = FSUtil.getProfileName();
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FOT_ArtifactRecordTriggerHandler');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        
        If(Trigger.isAfter)
        {
            If((Trigger.isupdate || Trigger.isinsert) && checkRecursive.runOnce() && profileName <> 'MDM API User')
            {            
                for(FS_Artifact__c art: Trigger.new)
                {
                    System.debug('After trigger - Artifact Name :'+art.Name+ ', Artifact record Rank : ' + art.FS_Rank__c);
                    if(Trigger.isupdate)
                    {
                        FS_Artifact__c oldArt = Trigger.oldMap.get(art.id); 
                        if((art.RecordTypeId == recordTypeId) && (oldArt.FS_Rank__c != art.FS_Rank__c)){
                            system.debug('Artifact old Rank :'  +oldArt.FS_Rank__c);
                            if(oldArt.FS_Rank__c<art.FS_Rank__c )
                            {
                                checkRank=true;
                            }
                            else
                            {
                                checkRank=false;
                            }
                            artifactIdSet.add(art.id);
                            rulesetIdList.add(art.FS_Ruleset__c);
                        }
                    }
                    else if(art.RecordTypeId == recordTypeId){
                        artifactIdSet.add(art.id);
                        rulesetIdList.add(art.FS_Ruleset__c);
                    }
                }
                artifactsToUpdate=handler.checkRankInsertUpdate(rulesetIdList,checkRank);
            }
            
            If(Trigger.isdelete)
            {
                artifactsToUpdate=handler.afterDeleteCheck(Trigger.old);
            }
        }
        
        If(Trigger.isBefore)
        {
            if(Trigger.isInsert){
                handler.beforeInsertCheck(Trigger.new,Trigger.oldMap);
                for(FS_Artifact__c artBefore:Trigger.new)
                {
                    System.debug('Artifact Before Insert:: '+artBefore.Name + ', Artifact Before Insert Rank : ' +artBefore.FS_Rank__c);
                }
            }
            If(Trigger.isdelete)
            {
                handler.beforeDeleteCheck(Trigger.old,Trigger.oldMap);
            }
        }
    }
    //FET 7.0 FNF-823 BPE changes
    try{
        if(!artifactsToUpdate.isEmpty()){                 update artifactsToUpdate;         }
    }
    catch(Exception e){
        ApexErrorLogger.addApexErrorLog(FSconstants.FET,'ArtifactRecordTrigger','artifactsToUpdate','artifactsToUpdate',FSConstants.MediumPriority,e,FSConstants.NA);
    } 
    //FET 7.0 FNF-823 BPE changes
}