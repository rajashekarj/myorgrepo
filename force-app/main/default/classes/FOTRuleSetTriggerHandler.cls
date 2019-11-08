/**************************
    Name         : FOTRuleSetTriggerHandler
    Created By   : Infosys
    Created Date : 21/03/2018
    Usage        : This is a handler for FOTArtifactRuleSetTrigger.
    ***************************/
    public class FOTRuleSetTriggerHandler {
        
    public static final String REQUESTSENTTORE ='Request sent to Rules Engine';
        
    /*****************************************************************
    Method: beforeDelete
    Description: This method holds logic for before delete event.
    Added as part of FOT
    *********************************/ 
    public static void beforeDelete(List<FS_Artifact_Ruleset__c> ruleSetList,Map<id,FS_Artifact_Ruleset__c> ruleSetMap){
        
        boolean isDelete = true;
        
        Map<Id,FS_Artifact_Ruleset__c> ruleSets = new Map<Id,FS_Artifact_Ruleset__c>([select Id,name,(select Id,name,FS_Enabled__c from Artifacts__r) from FS_Artifact_Ruleset__c where Id in :ruleSetMap.keySet()]);
        
        for(FS_Artifact_Ruleset__c ruleset: ruleSetList)
        {
            for(FS_Artifact__c artifactToSet : ruleSets.get(ruleset.id).Artifacts__r)
            {
                if(artifactToSet.FS_Enabled__c){
                    isDelete = false; 
                    break;
                }
            }
            //to prevent deletion of Active Artifact.
            if(!isDelete)
            {
                ruleset.addError('Can\'t delete the Ruleset as there are active artifacts associated to it.'); 
            }else if(ruleset.Last_Simulation_Status__c == REQUESTSENTTORE || ruleset.Last_Promote_Status__c == REQUESTSENTTORE){
                ruleset.addError('A simulation or promotion is in progress. Please wait until that process is completed before deleting this ruleset.');
            }
        }
        
    }
    
    
    /*****************************************************************
    Method: beforeInsert
    Description: This method holds logic for before insert event.
    Added as part of FOT
    *********************************/ 
    public static void beforeInsert(List<FS_Artifact_Ruleset__c> ruleSetList,Map<id,FS_Artifact_Ruleset__c> ruleSetMap){
        Set<String> rulNames = new Set<String>();
        Set<String> rulNamesCheck = new Set<String>();
        for(FS_Artifact_Ruleset__c ruleName: ruleSetList){
            rulNames.add(ruleName.Name); 
        }
        for(FS_Artifact_Ruleset__c ruleName: [Select Id,Name from FS_Artifact_Ruleset__c where Name IN: rulNames]){
            rulNamesCheck.add(ruleName.Name);
        }
        
        //to prevent creation of duplicate RuleSet Name
        for(FS_Artifact_Ruleset__c ruleName: ruleSetList){
            if(rulNamesCheck.contains(ruleName.Name)){
                ruleName.addError('Ruleset Name already exists, please enter different Ruleset Name.');
            }
        }
    }
        
    public static void beforeUpdate(List<FS_Artifact_Ruleset__c> ruleSetList,Map<id,FS_Artifact_Ruleset__c> ruleSetMap,Map<id,FS_Artifact_Ruleset__c> ruleSetOldMap){
        for(FS_Artifact_Ruleset__c ruleName: ruleSetList){
            if(ruleName.Last_Simulation_Status__c == System.Label.FOT_SimProInProgress)
            {
                ruleName.Last_Simulation_Status__c = System.Label.FOT_SimProRequestSentStatus;
            }
            if(ruleName.Last_Promote_Status__c == System.Label.FOT_SimProInProgress)
            {
                ruleName.Last_Promote_Status__c = System.Label.FOT_SimProRequestSentStatus;
            }
            if(ruleSetOldMap.get(ruleName.id).Last_Promote_Status__c != ruleSetMap.get(ruleName.id).Last_Promote_Status__c   && ruleName.Last_Promote_Status__c == 'Failure'){
                ruleName.FS_CheckSimulate__c = true;
            }
            
            if(ruleSetOldMap.get(ruleName.id).Last_Simulation_Status__c != ruleSetMap.get(ruleName.id).Last_Simulation_Status__c && ruleName.Last_Simulation_Status__c == 'Successful'){
                ruleName.FS_CheckSimulate__c = false;
            }
        }
    }
}