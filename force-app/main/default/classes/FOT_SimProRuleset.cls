/**************************
	Name         : FOT_SimProRuleset
	Created By   : Infosys
	Created Date : 06/03/2018
	Usage        : This class holds the logic of invoking A3 & A14 API REST webcallout(Simulation & Promotion).
	***************************/
	public class FOT_SimProRuleset {
    
    public static final String MEDIUM ='Medium';
    public static String statCode;
    public static Boolean errorCode;
    public static Boolean successCode;        
    /*****************************************************************
	Method: rulesetSimulate
	Description: rulesetSimulate method is to invoke A3 API REST callout for Simulation.
	Added as part of FOT
	*********************************/ 
    public static String rulesetSimulate(FS_Artifact_Ruleset__c ruleset)
    {
        String simStatus;
        
        HttpRequest req = new HttpRequest();
        req = FOT_APIWebServiceParams.setParamsVal(ruleset,Label.FOT_Simulate,'','A3');
        Http http=new Http();
        try
        {
            HttpResponse response=http.send(req);
            system.debug('status code rulesetSimulate '+response.getStatusCode());
            statCode = String.valueOf(response.getStatusCode());
            errorCode= Pattern.matches('40.', statCode);
            successCode= Pattern.matches('20.', statCode);
            System.debug('errorCode' + errorCode);
           
            if(successCode){
                ruleset.FS_CheckSimulate__c = false;
                update ruleset;
            }
            if(response.getStatusCode() == 400){
                simStatus = System.Label.FOT_Promote_ConError;
            }else if(errorCode){
              simStatus = System.Label.FOT_APIError_40X;   
            }else if(statCode.equals('500')){
              simStatus = System.Label.FOT_APIError_500;
            }else{
              simStatus = response.getBody();  
            }
            
        }  
        catch(CalloutException e)
        {
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProRuleset', 'rulesetSimulate', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            simStatus = 'Error while simulate Ruleset';
        }
        catch(JSONException e)
        {
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProRuleset', 'rulesetSimulate', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            simStatus = 'Error while simulate Ruleset';
        }
        return simStatus;
    }
    
    /*****************************************************************
	Method: rulesetPromote
	Description: rulesetPromote method is to invoke A14 API REST Webcallout for Promotion.
	Added as part of FOT
	*********************************/
    public static FOT_ResponseClass rulesetPromote(FS_Artifact_Ruleset__c ruleset)
    {
        FOT_ResponseClass res=null;
        //Promotion of RuleSet
        HttpRequest req = new HttpRequest();
        req = FOT_APIWebServiceParams.setParamsVal(ruleset,Label.FOT_Promote,'','A14');
        Http http=new Http();
        try
        {
            HttpResponse response=http.send(req);
            statCode = String.valueOf(response.getStatusCode());
            errorCode= Pattern.matches('40.', statCode);
            successCode= Pattern.matches('20.', statCode);
            if(successCode)
            {
                res=(FOT_ResponseClass)JSON.deserialize(response.getBody(), FOT_ResponseClass.class);
            }
            else
            {
                res=new FOT_ResponseClass();
                res.valid=false;
                res.hashCode='';
                if(errorCode){
                    res.message=System.Label.FOT_APIError_40X;
                }else if(statCode.equals('500')){
                    res.message=System.Label.FOT_APIError_500; 
                }else{
                    res.message=response.getBody();
                }
                res.textArea='';
                res.noMsg='';
                res.yesMsg='';
            }
        }  
        catch(CalloutException e)
        {            
            system.debug('Exception on \'rulesetPromote\' method in class \'FOT_SimProRuleset\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProRuleset', 'rulesetPromote', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            res=new FOT_ResponseClass();
            res.valid=false;
            res.hashCode='';
            res.message='Error:Please check the Artifacts associated to the Ruleset and try promote again.';
            res.textArea='';
            res.noMsg='';
            res.yesMsg=''; 
            return res; 
        }
        catch(JSONException e)
        {            
            system.debug('Exception on \'rulesetPromote\' method in class \'FOT_SimProRuleset\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProRuleset', 'rulesetPromote', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            res=new FOT_ResponseClass();
            res.valid=false;
            res.hashCode='';
            res.message='Error:Please check the Artifacts associated to the Ruleset and try promote again.';
            res.textArea='';
            res.noMsg='';
            res.yesMsg=''; 
            return res; 
        }
        return res;
    }
    
    /*****************************************************************
	Method: finalPromote
	Description: finalPromote method is to invoke A3 API REST Webcallout for Final Promotion.
	Added as part of FOT
	*********************************/
    public static string finalPromote(String ruleSetName, String hashcode,FS_Artifact_Ruleset__c ruleset)
    {
        boolean retRes = false;
        String finproresponse;
        //Final Promotion of RuleSet 
        HttpRequest req = new HttpRequest();
        req = FOT_APIWebServiceParams.setParamsVal(ruleset,Label.FOT_FinalPromote,hashcode,'A3');
     	
        Http http=new Http();
        try
        {
            HttpResponse response=http.send(req);
            system.debug('status code final promote '+response.getStatusCode());
            system.debug('final promote response'+response);
            system.debug('final promote response status '+response.getStatus());
            
            statCode = String.valueOf(response.getStatusCode());
            successCode= Pattern.matches('20.', statCode);
            if(successCode){
                ruleSet.FS_CheckSimulate__c = false;
                ruleSet.FS_CheckPromote__c = false;
                update ruleSet;
                retRes  = true;
                finproresponse = 'true';
            }else if( response.getStatus() == 'Bad Request' ){
                retRes  = false;
                finproresponse = 'false';
            }
            else{
                retRes  = false;
                finproresponse = 'false,'+statCode + ',' + response.getBody();
            }
            
        }  
        catch(CalloutException e)
        {
            system.debug('Exception on \'finalPromote\' method in class \'FOT_SimProRuleset\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProRuleset', 'finalPromote', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            retRes = false;
           finproresponse = 'false';
        }
        catch(JSONException e)
        {
            system.debug('Exception on \'finalPromote\' method in class \'FOT_SimProRuleset\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_SimProRuleset', 'finalPromote', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            retRes = false;
            finproresponse = 'false';
        }
        //return retRes;
        return finproresponse;
    }
}