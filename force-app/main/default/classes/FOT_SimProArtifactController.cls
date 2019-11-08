/**************************
Name         : FOT_SimProArtifactController
Created By   : Infosys
Created Date : 06/03/2018
Usage        : This class holds the logic for FOT_SimProArtifacts lightning component.
***************************/
public class FOT_SimProArtifactController {
    
    public static final String MEDIUM ='Medium';
    private static final String SUCCESSFULL = 'Successful';
/*****************************************************************
Method: recordDetails
Description: recordDetails method is to fetch all required fields of FS_Artifact_Ruleset__c record.
Added as part of FOT
*********************************/ 
    @AuraEnabled
    public static FS_Artifact_Ruleset__c recordDetails(Id recordId){
        FS_Artifact_Ruleset__c ruleSet=null;
        try
        {
            if(recordId!=null)
            {
                ruleSet = [Select id,Name,Last_Promote_Status__c,Last_Promote_Updated__c,Last_Simulation_Status__c, 
                           Last_Simulation_Updated__c from FS_Artifact_Ruleset__c where Id =: recordId];
            }
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'recordDetails\' method in class \'FOT_SimProArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProArtifactController', 'recordDetails', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
        }
        return ruleSet; 
    }
    
    /*****************************************************************
Method: getRuleSetName
Description: getRuleSetName method is to get Ruleset record Name .
Added as part of FOT
*********************************/
    @AuraEnabled
    public static String getRuleSetName(Id recordId){
        String ruleSetname=null;
        try
        {
            if(recordId!=null)
            {
                FS_Artifact_Ruleset__c ruleset=[SELECT Id,Name FROM FS_Artifact_Ruleset__c where id =:recordId]; 
                ruleSetname=ruleset.Name;
            }  
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'getRuleSetName\' method in class \'FOT_SimProArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProArtifactController', 'getRuleSetName', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
        }
        return ruleSetname;
    }
    
    /*****************************************************************
Method: userProfileAccess
Description: userProfileAccess method is to get logged-in user profile name.
Added as part of FOT
*********************************/
    @AuraEnabled
    public static string userProfileAccess(){
        system.debug('user id '+userinfo.getUserId());
        User usr=[select profile.name from user where id=:userinfo.getUserId()];
        return usr.profile.name;
    }
    
    /*****************************************************************
Method: simulateRuleset
Description: simulateRuleset method is to invoke A3 API REST webcallout.
Added as part of FOT
*********************************/
    @AuraEnabled
    public static String simulateRuleset(Id recordId){
        String simStatus=null;
        if(recordId!=null)
        {
            FS_Artifact_Ruleset__c ruleset=[SELECT Name,Last_Simulation_Status__c FROM FS_Artifact_Ruleset__c where id =:recordId];  
            simStatus=FOT_SimProRuleset.rulesetSimulate(ruleset);
        }
        System.debug('Check Status for Simulate' + simStatus);
        return simStatus;
    }
    
    
    /*****************************************************************
Method: promoteRuleset
Description: promoteRuleset method is to invoke A14 API REST webcallout.
Added as part of FOT
*********************************/
    @AuraEnabled
    public static FOT_ResponseClass  promoteRuleset(Id recordId){
        FOT_ResponseClass res= null;
        if(recordId!=null)
        {
            boolean isEnabled=false;
            FS_Artifact_Ruleset__c ruleset=[SELECT Name,Last_Simulation_Status__c,(SELECT FS_Enabled__c FROM Artifacts__r) FROM FS_Artifact_Ruleset__c where id =:recordId];
            res=  FOT_SimProRuleset.rulesetPromote(ruleset); 
        }
        return res;
    }
    
    /*****************************************************************
Method: finalPromote
Description: finalPromote method is to invoke A3 API REST webcallout for Final promotion .
Added as part of FOT
*********************************/
    @AuraEnabled
    public static string finalPromote(String ruleSetName, String hashcode,Id recordId){		
        //boolean finalRes = false;
        string finalRes = 'false';
        List<FS_Artifact__c> artiList=new List<FS_Artifact__c>();
        if(recordId!=null)
        {
            FS_Artifact_Ruleset__c ruleset=[SELECT Name,(select FS_Artifact_Type__c,FS_UUID__c,name from Artifacts__r) FROM FS_Artifact_Ruleset__c where id =:recordId];
            finalRes = FOT_SimProRuleset.finalPromote(rulesetName,hashcode,ruleset);
        }
        System.debug('Value of final Promote' + finalRes);
        return finalRes;
    }
    
    /*****************************************************************
Method: recordArifactDetails
Description: recordArifactDetails method is to retrieve the required fields from FS_Artifact_Ruleset__c record.
Added as part of FOT
*********************************/
    @AuraEnabled
    public static Map<String,Boolean> recordArifactDetails(Id recordId){
        Boolean isEnabled= false;
        Map<String,Boolean> Mymap = new Map<String,Boolean>();
        try
        {
            if(recordId!=null)
            {
                FS_Artifact_Ruleset__c ruleset=[SELECT Name,FS_CheckSimulate__c,Last_Promote_Status__c,FS_CheckPromote__c,Last_Simulation_Status__c,(SELECT Id,FS_Enabled__c FROM Artifacts__r) FROM FS_Artifact_Ruleset__c where id =:recordId ];
                if(ruleset.Artifacts__r.size()>0){
                    if(ruleset.FS_CheckSimulate__c || (ruleset.Last_Simulation_Status__c == null && ruleset.Last_Promote_Status__c != SUCCESSFULL)||(ruleset.Last_Simulation_Status__c != SUCCESSFULL && ruleset.Last_Simulation_Status__c != null)){
                        System.debug('CheckSimulate is true');
                        Mymap.put('checkSimulate',true);    
                    }
                    
                    if(ruleset.FS_CheckPromote__c || ruleset.Last_Promote_Status__c == null ||(ruleset.Last_Promote_Status__c != SUCCESSFULL && ruleset.Last_Promote_Status__c!= null)){
                        System.debug('CheckPromote is true');
                        Mymap.put('checkPromote',true);    
                    }
                }               
            }
            
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'recordArifactDetails\' method in class \'FOT_SimProArtifactController\' '+e.getMessage()); 
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProArtifactController', 'recordArifactDetails', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
        }
        return Mymap;
    }
}