/**************************
	Name         : FOT_EditArtifactController
	Created By   : Infosys
	Created Date : 03/02/2018
	Usage        : This class holds the logic for Edit,View and ViewEdit lightning component.
	***************************/
	public without sharing class FOT_EditArtifactController {
    
    public static final String MEDIUM ='Medium';
    
    /*****************************************************************
	Method: actionPublishArtifact
	Description: actionPublishArtifact method is to fetch Published Artifact record Id.
	Added as part of FOT
	*********************************/  
    @AuraEnabled
    public static Id actionPublishArtifact(Id recordId){
        
        Id publishId = null;
        try
        {
            if(recordId!=null)
            {
                FS_Artifact__c artifact = [Select id,Name,Record_Type__c,RecordType.Name,FS_Published_Artifact__c from FS_Artifact__c where Id =: recordId Limit 1];
                if(artifact.RecordType.Name == System.Label.FOT_DryRun && artifact.FS_Published_Artifact__c != null){
                    publishId = artifact.FS_Published_Artifact__c;
                }else if(artifact.RecordType.Name == System.Label.FOT_Published){
                    artifact = [Select id,Name,Record_Type__c from FS_Artifact__c where FS_Published_Artifact__c =: recordId limit 1];
                    publishId = artifact.Id;
                }
            }
            
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'actionPublishArtifact\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'actionPublishArtifact', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
        }
        return publishId; 
    }
    
    /*****************************************************************
	Method: checkDelete
	Description: checkDelete method is to enable the Delete button.
	Added as part of FOT
	*********************************/ 
    @AuraEnabled
    public static boolean checkDelete(Id recordId){
        Id publishId = null;
        boolean isDelete = false;
        try
        {
            if(recordId!=null)
            {
                FS_Artifact__c artifact = [Select id,FS_Enabled__c,Name,Record_Type__c,RecordType.Name,FS_Published_Artifact__c,FS_Published_Artifact__r.FS_Enabled__c from FS_Artifact__c where Id =: recordId Limit 1];
                if(artifact.RecordType.Name == System.Label.FOT_DryRun )
                {
                    if(artifact.FS_Published_Artifact__c != null)
                    {
                        if(artifact.FS_Enabled__c == false && artifact.FS_Published_Artifact__r.FS_Enabled__c == false){
                            isDelete = true;  
                        }                        
                    }
                    else
                    {
                        if(artifact.FS_Enabled__c == false){
                            isDelete = true;
                        }
                    }
                }
                
                if(artifact.RecordType.Name == System.Label.FOT_Published)
                {
                    FS_Artifact__c dryrunartifact = [Select id,Name,FS_Enabled__c,Record_Type__c from FS_Artifact__c where FS_Published_Artifact__c =: recordId limit 1];
                    if(artifact.FS_Enabled__c == false && dryrunartifact.FS_Enabled__c == false){
                        isDelete = true;  
                    }   
                }
            }
            
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'checkDelete\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'checkDelete', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
        }
        return isDelete; 
    }
    
    /*****************************************************************
	Method: actionRTArtifact
	Description: actionRTArtifact method is to get the record type name of the Artifact.
	Added as part of FOT
	*********************************/ 
    @AuraEnabled
    public static String actionRTArtifact(Id recordId){
        String recordTypeName=null;
        try
        {
            if(recordId!=null)
            {
                FS_Artifact__c artifact = [Select id,Name,Record_Type__c,RecordType.Name from FS_Artifact__c where Id =: recordId];
                recordTypeName=artifact.RecordType.Name; 
            } 
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'actionRTArtifact\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'actionRTArtifact', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
        }
        return recordTypeName;
    }
    
 /*   @AuraEnabled
    public static String actionValidArtifact(Id recordId){
        FS_Artifact__c artifact = [Select id,Name,IsValid__c from FS_Artifact__c where Id =: recordId];
        return artifact.IsValid__c; 
    }*/
    
    /*****************************************************************
	Method: recordDetails
	Description: recordDetails method is to fetch all the required fields from the Artifact record.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static FS_Artifact__c recordDetails(Id recordId){
        FS_Artifact__c artifact=null;
        if(recordId!=null)
        {
            artifact = [SELECT Id,Record_Type__c,FOT_Rule_S3_Path__c,Second_Dependency_Artifact_Type__c,Second_Dependency_Break_Version__c,Second_Dependency_Min_Version__c,RecordType.Name, RecordTypeId, Name,Context__c, DependancyBreakVersion__c, FS_Artifact_Type__c, FS_Dependency_Artifact_Type__c, FS_Dependency_M_in_Version__c, FS_Deployment_Group_Rule__c, FS_Enabled__c, FS_Overide_Group_Rule__c, FS_Rank__c, FS_Rule__c, FS_Ruleset__r.Name, FS_S3Path__c, FS_UUID__c, FS_Version__c,Settings_Update__c,CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name,FS_Published_Artifact__c, FS_Published_Artifact__r.FS_Enabled__c FROM FS_Artifact__c where Id =: recordId];   
        }
        return artifact;
    }
    
    /*****************************************************************
	Method: getArtifactTypeValues
	Description: getArtifactTypeValues method is to get the 'Artifact Type' field picklist values.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static List<String> getArtifactTypeValues(){
        try
        {
            List<String> artifactTypeList=new List<String>();
            Schema.DescribeFieldResult fieldResult=FS_Artifact__c.FS_Artifact_Type__c.getDescribe();
            List<Schema.PicklistEntry> pickList=fieldResult.getPicklistValues();
            
            for(Schema.PicklistEntry p:pickList){
                artifactTypeList.add(p.getValue());
            }
            return artifactTypeList;
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'getArtifactTypeValues\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'getArtifactTypeValues', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            return null;
        }  
    }
    
    /*****************************************************************
	Method: deleteArtifact
	Description: deleteArtifact method is to check whether the Artifact record deletion is successful.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static boolean deleteArtifact(Id recordId){
        FS_Artifact__c artifact=null;
        boolean isDelete = false; 
        try{
            artifact = [Select id,Name,FS_Ruleset__c from FS_Artifact__c where Id =: recordId];
            delete artifact;
            isDelete = true; 
        }
        catch(QueryException e){
            system.debug('Exception on \'deleteArtifact\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'deleteArtifact', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            isDelete =false;
        }
        return isDelete;
    }
    
    
    /*****************************************************************
	Method: getDependArtifactTypeValues
	Description: getDependArtifactTypeValues method is to get 'Dependency Artifact Type' field picklist values.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static List<String> getDependArtifactTypeValues(){
        try{
            List<String> dependArtifactTypeList=new List<String>();
            
            Schema.DescribeFieldResult fieldResult=FS_Artifact__c.FS_Dependency_Artifact_Type__c.getDescribe();
            List<Schema.PicklistEntry> pickList=fieldResult.getPicklistValues();
            
            for(Schema.PicklistEntry p:pickList){
                dependArtifactTypeList.add(p.getValue());
            } 
            return dependArtifactTypeList;
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'getDependArtifactTypeValues\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'getDependArtifactTypeValues', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            return null;
        }    
    }
    
    
           /*****************************************************************
	Method: getDependArtifactTypeValues
	Description: getDependArtifactTypeValues method is to get 'Dependency Artifact Type' field picklist values.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static List<String> getSecondDependArtifactTypeValues(){
        try{
            List<String> secDependArtifactTypeList=new List<String>();
            
            Schema.DescribeFieldResult fieldResult=FS_Artifact__c.Second_Dependency_Artifact_Type__c.getDescribe();
            List<Schema.PicklistEntry> pickList=fieldResult.getPicklistValues();
            secDependArtifactTypeList.add('--None--');
            for(Schema.PicklistEntry p:pickList){
                secDependArtifactTypeList.add(p.getValue());
            } 
            return secDependArtifactTypeList;
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'getSecondDependArtifactTypeValues\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'getSecondDependArtifactTypeValues', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
            return null;
        }    
    }
        
    /*****************************************************************
	Method: updateArtifact
	Description: updateArtifact method is to update the Artifact record and a check to enable 'Simulate' & 'Promote' buttons on Ruleset record. 
	Added as part of FOT
	*********************************/
    @AuraEnabled 
    public static FS_Artifact__c updateArtifact(FS_Artifact__c artObj, Boolean valchange){
        FS_Artifact__c artifactObj=null;
        try
        {
            if(artObj!=null)
            {
                artifactObj = artObj;
                update artifactObj;
                
                FS_Artifact_Ruleset__c ruleSet =[Select Id,FS_CheckSimulate__c,FS_CheckPromote__c from FS_Artifact_Ruleset__c where Id =: artifactObj.FS_Ruleset__c];
                if(valchange){
                    if(ruleSet.FS_CheckSimulate__c == false ){
                        ruleSet.FS_CheckSimulate__c = true;           
                    }
                    if(ruleSet.FS_CheckPromote__c == false ){            
                        ruleSet.FS_CheckPromote__c = true;
                    }
                } 
                update ruleSet; 
            }  
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'updateArtifact\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'updateArtifact', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
        }
        return artObj;
    }
    
    /*****************************************************************
	Method: actionWebCall
	Description: actionWebCall method is to invoke A5 API webcall for validation. 
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static FOT_ResponseClass actionWebCall(FS_Artifact__c artifactRec){ 
        FOT_ResponseClass res=null;
        System.debug('artifactRec' + artifactRec.FS_Overide_Group_Rule__c);
        if(artifactRec !=null)
        {
            res=FOT_ArtifactValidationWebService.getArtifactValidation(artifactRec);
        } 
        System.debug('Response Value is::' + res);
        return res;   
    }
    
    /*****************************************************************
	Method: userProfileAccess
	Description: userProfileAccess method is to get logged-in user's profile name.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static string userProfileAccess(){
        User usr=[select profile.name from user where id=:userinfo.getUserId()];
        return usr.profile.name;
    }
      
    /*****************************************************************
	Method: actionLabel
	Description: actionLabel method is to get 'FS_Ruleset__c' field label name.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static String actionLabel()
    {
        String label;
        label=  Schema.FS_Artifact__c.fields.FS_Ruleset__c.getDescribe().getLabel();
        return label;
    }
       
    /*****************************************************************
	Method: actionPublishActive
	Description: actionPublishActive method is to check for Active Publish Artifact.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static Boolean actionPublishActive(Id recordId)
    {
        boolean isActive=false;
        try
        {
            if(recordId!=null)
            {
                FS_Artifact__c publishArtifact= [Select id,FS_Enabled__c from FS_Artifact__c where Id =: recordId];
                if(publishArtifact.FS_Enabled__c)
                {
                    isActive=true;
                }  
            }
            
        }
        catch(QueryException e)
        {
            system.debug('Exception on \'actionPublishActive\' method in class \'FOT_EditArtifactController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_EditArtifactController', 'actionPublishActive', 'FS_Artifact__c',MEDIUM, e,e.getMessage());
        }
        return isActive;
    }
      
        @AuraEnabled
        public static String uploadRuleToAWS_S3(String fileContent,String ruleSetFileName)
        {      
            FOT_S3_Credentials__mdt s3Creditals;
            try{
                s3Creditals = [Select FOT_S3_Access_Key__c,FOT_Host__c,FOT_S3_Bucket__c,FOT_S3_Folder__c,FOT_S3_Region__c,FOT_S3_Secret_Key__c from FOT_S3_Credentials__mdt Limit 1];}
            catch(Exception e){
                return 'Error';}
            String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');          
            HttpRequest req = new HttpRequest();
            req.setMethod('PUT');
            req.setEndpoint('https://' + s3Creditals.FOT_S3_Bucket__c + '.' + s3Creditals.FOT_Host__c + '/'+ s3Creditals.FOT_S3_Folder__c + '/'+  ruleSetFileName);
            req.setHeader('Host', s3Creditals.FOT_S3_Bucket__c + '.' + s3Creditals.FOT_Host__c);
            req.setHeader('Content-Length', String.valueOf(fileContent.length()));
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', 'text/plain');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Date', formattedDateString);
            req.setHeader('ACL', 'public-read');
            req.setBody(fileContent);
            String stringToSign = 'PUT\n\n' +'text/plain' + '\n' +formattedDateString + '\n' +
                '/' + s3Creditals.FOT_S3_Bucket__c + '/' + s3Creditals.FOT_S3_Folder__c + '/'  + ruleSetFileName;
            String urlLi = 'https://'+ s3Creditals.FOT_S3_Bucket__c +'.'+s3Creditals.FOT_Host__c+'/' + s3Creditals.FOT_S3_Folder__c + '/'+ ruleSetFileName; 
            String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
            Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(s3Creditals.FOT_S3_Secret_Key__c));
            String signed = EncodingUtil.base64Encode(mac);
            String authHeader = 'AWS' + ' ' + s3Creditals.FOT_S3_Access_Key__c + ':' + signed;
            req.setHeader('Authorization',authHeader);
            String decoded = EncodingUtil.urlDecode(encodedStringToSign , 'UTF-8');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() != 200){
                urlLi = 'Error';
            }
            return urlLi;
        } 
        
        @AuraEnabled
        public static String viewRuleFileFromAWS_S3(String s3FileName){
            FOT_S3_Credentials__mdt s3Creditals;
            try{
             s3Creditals = [Select FOT_S3_Access_Key__c,FOT_View_S3_File_Duration__c,FOT_S3_Bucket__c,FOT_S3_Folder__c,FOT_S3_Region__c,FOT_S3_Secret_Key__c from FOT_S3_Credentials__mdt Limit 1];}
            catch(Exception e){
                return 'Error';}
            Datetime now = DateTime.now();
            Decimal s3ViewDuration = s3Creditals.FOT_View_S3_File_Duration__c;            
            Datetime expireson = now.AddSeconds(s3ViewDuration.intValue()); // Lifespan of the link
            Long lExpires = expireson.getTime()/1000;
            String stringtosign = 'GET\n\n\n'+lExpires+'\n/'+s3Creditals.FOT_S3_Bucket__c+'/'+ s3Creditals.FOT_S3_Folder__c + '/'+s3FileName;
            String signingKey = EncodingUtil.base64Encode(Blob.valueOf(s3Creditals.FOT_S3_Secret_Key__c));
            Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(stringtosign),blob.valueof(s3Creditals.FOT_S3_Secret_Key__c)); 
            String signed= EncodingUtil.base64Encode(mac);     
            String codedsigned = EncodingUtil.urlEncode(signed,'UTF-8');
            String url = 'http://'+s3Creditals.FOT_S3_Bucket__c+'.s3.amazonaws.com/'+ s3Creditals.FOT_S3_Folder__c + '/' + s3FileName+'?AWSAccessKeyId='+s3Creditals.FOT_S3_Access_Key__c+
                '&Expires='+lExpires+'&Signature='+signed;
            return url;
        }
}