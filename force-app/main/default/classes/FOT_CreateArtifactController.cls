/****************************************************************************************
    Apex Class Name     : FOT_CreateArtifactController
    Version             : 1.0
    Function            : This is a Controller class for FOT_CreateArtifact Component which will handle Artifact Creation.
						  
    Modification Log    :
    * Developer         : Infosys   
    * Date              : 26 Feb 2018               
    ******************************************************************************************/
	public without sharing class FOT_CreateArtifactController {
    /*****************************************************************
    Method: saveArtifact
    Description: This method is to insert new Artifact record.
    Added as part of FOT
    *********************************/
    @AuraEnabled
    public static ID saveArtifact(FS_Artifact__c artifact){
        try
        {
            if(artifact!=null)
            {
                insert artifact;
                FS_Artifact_Ruleset__c ruleSet =[Select Id,Last_Promote_Status__c,FS_CheckSimulate__c,FS_CheckPromote__c from FS_Artifact_Ruleset__c where Id =: artifact.FS_Ruleset__c];
                ruleSet.FS_CheckSimulate__c = true;
                ruleSet.FS_CheckPromote__c = true;
                update ruleSet;
                system.debug('Last_Promote_Status__c'+ruleSet.Last_Promote_Status__c);
            }
            return artifact.Id;
        }
        catch(QueryException e)
        {
            System.debug('Exception on \'saveArtifact\' method in class \'FOT_CreateArtifactController\' '+ e.getMessage());
            return null;
        }
    }
    
    /*****************************************************************
    Method: ArtifactTypeList
    Description: This method is to get picklist values of 'Artifact Type' field.
    Added as part of FOT
    *********************************/
    @AuraEnabled
    public static List<String> ArtifactTypeList()
    {
        try
        {
            List<String> cList= new List<String>();
            Schema.DescribeFieldResult fieldResult;
            fieldResult = FS_Artifact__c.FS_Artifact_Type__c.getDescribe();
            List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
            cList.add('--None--');
            for(Schema.PicklistEntry p:pickList)
            {   
                cList.add(p.getValue());
            }
            return cList;
        }
        catch(Exception e)
        {
            System.debug('Exception on \'ArtifactTypeList\' method in class \'FOT_CreateArtifactController\' ' + e.getMessage());
            return null;
        }
    }
    
    /*****************************************************************
    Method: dependArtifactTypeList
    Description: This method is to get picklist values of 'Dependency Artifact Type' field.
    Added as part of FOT
    *********************************/
    @AuraEnabled
    public static List<String> dependArtifactTypeList()
    {
        try
        {
            List<String> cList= new List<String>();
            Schema.DescribeFieldResult fieldResult;
            fieldResult = FS_Artifact__c.FS_Dependency_Artifact_Type__c.getDescribe();
            List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
            cList.add('--None--');
            for(Schema.PicklistEntry p:pickList)
            {   
                cList.add(p.getValue());
            }
            return cList;
        }
        catch(Exception e)
        {
            System.debug('Exception on \'dependArtifactTypeList\' method in class \'FOT_CreateArtifactController\' ' + e.getMessage());
            return null;
        }
    }
        /*****************************************************************
    Method: secDependArtifactTypeList
    Description: This method is to get picklist values of 'Dependency Artifact Type' field.
    Added as part of FOT
    *********************************/
    @AuraEnabled
    public static List<String> secDependArtifactTypeList()
    {
        try
        {
            List<String> cList= new List<String>();
            Schema.DescribeFieldResult fieldResult;
            fieldResult = FS_Artifact__c.Second_Dependency_Artifact_Type__c.getDescribe();
            List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
            cList.add('--None--');
            for(Schema.PicklistEntry p:pickList)
            {   
                cList.add(p.getValue());
            }
            return cList;
        }
        catch(Exception e)
        {
            System.debug('Exception on \'secDependArtifactTypeList\' method in class \'FOT_CreateArtifactController\' ' + e.getMessage());
            return null;
        }
    }
    
    /*****************************************************************
    Method: actionWebCallout
    Description: This method is to invoke the webservice callout for Artifact validation.
    Added as part of FOT
    *********************************/
    @AuraEnabled
    public static FOT_ResponseClass actionWebCallout(FS_Artifact__c artObj)
    {   
        FOT_ResponseClass res=null;
        if(artObj!=null)
        { 
            res=FOT_ArtifactValidationWebService.getArtifactValidation(artObj);
        }
        return res; 
    }
    
     @AuraEnabled
        public static FS_Artifact_Ruleset__c getRuleset(){
            System.debug('Check value');
            FS_Artifact_Ruleset__c check = new FS_Artifact_Ruleset__c();
            check = [select Id,Name FROM FS_Artifact_Ruleset__c limit 1];
            system.debug('Value is ' + check);
            return check;
        }
    /*****************************************************************
    Method: actionArtifactType
    Description: This method is to check for 'Artifact Type' value of the Artifact record associated with Ruleset.
    Added as part of FOT
    *********************************/
    @AuraEnabled
    public static String actionArtifactType(Id ruleset){
        String artifactType='';
        try
        {   if(ruleset!=null)
        	{
            	FS_Artifact_Ruleset__c rulesetAT=[SELECT (select name,FS_Artifact_Type__c from Artifacts__r) FROM FS_Artifact_Ruleset__c where id=:ruleset];
            	List<FS_Artifact__c> artifactList=rulesetAT.Artifacts__r;
            	if(artifactList.size()>0)
            	{
               		artifactType=artifactList[0].FS_Artifact_Type__c;
            	} 
        	}
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'actionArtifactType\' method in class \'FOT_CreateArtifactController\' '+e.getMessage());
        }
        return artifactType;
    }
    
    /*****************************************************************
    Method: actionLabel
    Description: This method is to get 'FS_Ruleset__c' field label name.
    Added as part of FOT
    *********************************/
    @AuraEnabled
    public static String actionLabel()
    {
        String label;
        label=  Schema.FS_Artifact__c.fields.FS_Ruleset__c.getDescribe().getLabel();
        return label;
    }    
     
    /*
    @AuraEnabled
    public static String uploadRuleToAWS_S3(String fileContent,String ruleSetFileName)
    {
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String key = Label.FOT_S3_Access_Key;
        String secret = Label.FOT_S3_Secret_Key;
        String bucketname = Label.FOT_S3_Bucket;
        String host = 's3-'+ Label.FOT_S3_Bucket_Region+'.amazonaws.com'; 
        String method = 'PUT';
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://' + bucketname + '.' + host + '/'+ Label.FOT_S3_Bucket_Folder + '/'+ ruleSetFileName);
        req.setHeader('Host', bucketname + '.' + host);
        req.setHeader('Content-Length', String.valueOf(fileContent.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type', 'text/plain');
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read');
        req.setBody(fileContent);
         
        String stringToSign = 'PUT\n\n' +
        'text/plain' + '\n' +
        formattedDateString + '\n' +
        '/' + bucketname + '/' + Label.FOT_S3_Bucket_Folder + '/'+ ruleSetFileName;
 		String urlLi = 'https://'+ bucketname + '.s3.amazonaws.com/'+ Label.FOT_S3_Bucket_Folder + '/' + ruleSetFileName; 
        System.debug('urlLiurlLi' + urlLi);
        
        String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signed;
        req.setHeader('Authorization',authHeader);
        String decoded = EncodingUtil.urlDecode(encodedStringToSign , 'UTF-8');
         
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('*Resp:' + res.getBody());
        System.debug('*Resp:' + String.ValueOF(res.getBody()));
        System.debug('RESPONSE STRING: ' + res.toString());
        System.debug('RESPONSE STATUS: ' + res.getStatus());
        System.debug('STATUS_CODE: ' + res.getStatusCode());  
        return urlLi;
    } */
    
}