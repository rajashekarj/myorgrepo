/***********************************************************************************************************
Name         : FOT_ArtifactValidationWebServiceResMock
Created By   : Infosys Limited 
Created Date : 12-may-2017
Usage        : Validation Mock Class for FOT_ArtifactValidationWebService

***********************************************************************************************************/
@isTest
global class FOT_ArtifactValidationWebServiceResMock implements HttpCalloutMock{
    public integer returnedStatusCode;
   public FOT_ArtifactValidationWebServiceResMock(Integer returnedStatusCode) {
        this.returnedStatusCode = returnedStatusCode;
    }
    global HTTPResponse respond(HTTPRequest req) {
        
        FOT_API__mdt api=[select Content_Type__c,Authorization__c from FOT_API__mdt where DeveloperName='A5'];
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', api.Content_Type__c);
        res.setHeader('Authorization', api.Authorization__c);
        req.setTimeout(200);
        res.setStatusCode(returnedStatusCode);
        if(returnedStatusCode==Integer.valueOf(System.Label.FOT_Success_Code))
        {
             res.setBody('{"valid":true"hashCode":"Not relavent","message":"Your rule and group applies to 0 dispensers without regard for other artifacts in ruleset. * Count based on cache of dispenser data from 03/28/2018 02:51:23 AM. * This count is also without regards for do not update flag","textArea":"","noMsg":"No","yesMsg":"Yes"}');
        }
       else
       {
           res.setBody('Bad request');
       }
        return res;
    }   

}