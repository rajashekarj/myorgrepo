/*********************************************************************************************************
Name         : FOT_SimProRulesetSimulateMock
Created By   : Infosys Limited 
Created Date : 12-may-2017
Usage        : Simulation Mock Class for FOT_SimProRuleset

***********************************************************************************************************/
@isTest
global class FOT_SimProRulesetSimulateMock implements HttpCalloutMock{
     public integer statusCode;
    public FOT_SimProRulesetSimulateMock(Integer statusCode) {
        this.statusCode = statusCode;
    }
    global HTTPResponse respond(HTTPRequest req) {
        
        FOT_API__mdt api=[select Authorization__c from FOT_API__mdt where DeveloperName='A3'];
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Authorization', api.Authorization__c);
        res.setBody('Processing');
         if(statusCode==200)
        {
        res.setStatusCode(Integer.valueOf(System.Label.FOT_Success_Code));
        }
        else if(statusCode==500){
           res.setStatusCode(500);
        }
        else{
            res.setStatusCode(400); 
        }
        return res;
    }
}