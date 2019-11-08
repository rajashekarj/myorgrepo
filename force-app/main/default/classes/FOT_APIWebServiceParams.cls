/**************************
	Name         : FOT_APIWebServiceParams
	Created By   : Infosys
	Created Date : 05/11/2018
	Usage        : Helper Class to set the paramters for webcallout(Simulation & Promotion).
	***************************/
public class FOT_APIWebServiceParams {
    /*****************************************************************
    Method: setParamsVal
    Description: This method is to set the params for A14 and A3 API REST webcallout.   
    *********************************/
    public static HttpRequest setParamsVal(FS_Artifact_Ruleset__c ruleset,String operType,String hashCode,String apiName){
        RestContext.request = new RestRequest();
        HttpRequest req = new HttpRequest();
        string newRulesetName;
        string rulesetName;
        if(ruleset != null){
           rulesetName= ruleset.Name;
           newRulesetName= rulesetName.replace(' ','%20'); 
        }
        String url;
        FOT_API__mdt api=[select Content_Type__c,End_Point__c,Authorization__c,api_key__c from FOT_API__mdt where DeveloperName=:apiName ];
        url=api.End_Point__c;
        if(operType == Label.FOT_Simulate){
             req.setMethod('GET');
            RestContext.request.params.put('?ruleSet',newRulesetName);
            RestContext.request.params.put('cmd','simulate');
        }else if(operType == Label.FOT_FinalPromote){
            req.setMethod('GET');
            RestContext.request.params.put('?ruleSet',newRulesetName);
            RestContext.request.params.put('hashCode',hashcode);
            RestContext.request.params.put('cmd','promote');
        }else if(operType == Label.FOT_Promote){
             req.setMethod('GET');
             RestContext.request.params.put('?ruleSet',newRulesetName);
        }else if(operType == Label.FET_NMSConnector){
             req.setMethod('POST');
             req.setHeader('Content-Type', api.Content_Type__c);
        }else if(operType == Label.FOT_CreateArtifact){
            req.setMethod('POST');
             req.setHeader('Content-Type', api.Content_Type__c);
        }
        for(String str:RestContext.request.params.keyset())
        {
            url+=str+'='+RestContext.request.params.get(str)+'&';
        }
        url=url.removeEnd('&');
        req.setHeader('Authorization', api.Authorization__c);
        req.setHeader('x-api-key', api.api_key__c);
        req.setEndpoint(url);
       
        req.setTimeout(Integer.valueOf(System.Label.FOT_WebCallTimeOut));
        return req;
    }
}