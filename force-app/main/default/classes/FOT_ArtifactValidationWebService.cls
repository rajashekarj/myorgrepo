/******************************
	Name         : FOT_ArtifactValidationWebService
	Created By   : Infosys
	Created Date : 06/03/2018
	Usage        : This class holds the logic of invoking A5 API REST webcallout for Artifact Validation.
	***************************/
	public class FOT_ArtifactValidationWebService {
    
     public static final String MEDIUM ='Medium';
     public static String statCode;
     public static Boolean errorCode;
     public static Boolean successCode; 
	/*****************************************************************
	Method: getArtifactValidation
	Description: getArtifactValidation method is to invoke A5 API webcallout.
	Added as part of FOT
	*********************************/ 
    public static FOT_ResponseClass getArtifactValidation(FS_Artifact__c artifact)
    {
        
        FOT_ResponseClass res=null;
        try
        {
            FOT_RawContentWrapper raw=new FOT_RawContentWrapper(artifact);
            String input=JSON.serialize(raw);
            HttpRequest req = new HttpRequest();
            req = FOT_APIWebServiceParams.setParamsVal(null,Label.FOT_CreateArtifact,'','A5');
            req.setBody(input);	
            Http http=new Http();
            
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
            system.debug('Exception on \'getArtifactValidation\' method in class \'FOT_ArtifactValidationWebService\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_ArtifactValidationWebService', 'getArtifactValidation', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            res=new FOT_ResponseClass();
            res.valid=false;
            res.hashCode='';
            res.message='API error : '+e.getMessage();
            res.textArea='';
            res.noMsg='';
            res.yesMsg='';
            return res;
        }
         catch(JSONException e)
        {
            system.debug('Exception on \'getArtifactValidation\' method in class \'FOT_ArtifactValidationWebService\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_ArtifactValidationWebService', 'getArtifactValidation', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            res=new FOT_ResponseClass();
            res.valid=false;
            res.hashCode='';
            res.message='API error : '+e.getMessage();
            res.textArea='';
            res.noMsg='';
            res.yesMsg='';
            return res;
        }
        return res;
    }
    
}