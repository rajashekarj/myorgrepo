/*********************************************************************************************************
Name         : FOT_SimProRulesetPromoteMock
Created By   : Infosys Limited 
Created Date : 12-may-2017
Usage        : Promotion Mock Class for FOT_SimProRuleset

***********************************************************************************************************/
@isTest
global class FOT_SimProRulesetPromoteMock implements HttpCalloutMock{
    public integer statusCode;
    public FOT_SimProRulesetPromoteMock(Integer statusCode) {
        this.statusCode = statusCode;
    }
    global HTTPResponse respond(HTTPRequest req) {
        
        FOT_API__mdt api=[select Authorization__c from FOT_API__mdt where DeveloperName='A3'];
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Authorization', api.Authorization__c);
        if(statusCode==200)
        {
            res.setBody('{"valid":true,"hashCode":"375130806","message":"Warning this will promote 1 Artifacts Changes and impact 0 DispenserOD recordsSummary of dispenser changes:Old New  Count","textArea":"\\{"Artifacts to be updated":[],"Artifacts to be added":[],"Artifacts to be deleted":[]\\}","noMsg":"Don\'t promote","yesMsg":"Promote 1 artifacts changes"}');
           // res.setBody(body.unescapeEcmaScript());
        }
        else
        {
            res.setBody('Bad request');           
        }
        if(statusCode==200){
        res.setStatusCode(statusCode);
        }
        else if(statusCode==500){
           res.setStatusCode(statusCode);
        }
        return res;
    }
    
}