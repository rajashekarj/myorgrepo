// //
// (c) 2014 Appirio, Inc.
// BatchForErrorHandling
//
// 29 Dec 2014     Deepti Maheshwari    Original(Ref:S-273620)
/*
updated by      :Operational Capacity Support   
Date            :20th Sep 2016
Reqirement      : Resend when status code is not 200 or 202.
Purpose         : For retrying records that failed to be sent to Airwatch for 400 and 404 status code from the http request. 
****************************************************************************************************************************/
global without sharing class BatchForErrorHandling implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //Status Codes of Error Logs that is to be retried
        List<String> statusCodes = new List<String>();
        for(HttpStatusCodes__c sc: HttpStatusCodes__c.getAll().values()){ //Custom Setting(HttpStatusCodes) Stores the http status codes
            statusCodes.add(sc.Name);
        }
        
        String qry = 'SELECT Id, Outlet_Dispenser__c, Outlet_Dispenser__r.FS_Last_Updated_Date_Time_to_NMS__c, Outlet_Dispenser__r.FS_NMS_Response__c, Error_Code__c,Error_Message__c, ' 
                  + ' FS_Serial_Number_Asset_Tag__c, Request_Message__c, Resend__c,Resend_Counter__c, ServiceName__c ' 
              + ' FROM Service_Message_Error_Log__c ' 
              + ' WHERE Resend__c = true ' 
              + ' AND Outlet_Dispenser__r.FS_IsActive__c = true '
              + ' AND Error_Code__c IN:statusCodes ';  //added condition to filter records based on error code
              
        return Database.getQueryLocator(qry);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        HttpResponse response;
        List<Service_Message_Error_Log__c> beList = (List<Service_Message_Error_Log__c>)scope;
        List<Service_Message_Error_Log__c> listToUpdate = new List<Service_Message_Error_Log__c>();
        Set<Id> setDispenserIds = new Set<Id>();
        FOT_API__mdt serviceDetails = [select api_key__c,Authorization__c,Content_Type__c,End_Point__c FROM FOT_API__mdt WHERE DeveloperName='A11'];
        Map<String, Error_Message_Resend_Counter__c> mapNameCounter = Error_Message_Resend_Counter__c.getAll();
        Error_Message_Resend_Counter__c resendNumber;
        if(mapNameCounter.containsKey('Service Message Error')) {
          resendNumber = mapNameCounter.get('Service Message Error');
        } 

        for(Service_Message_Error_Log__c item : beList) {
            setDispenserIds.add(item.Outlet_Dispenser__c);
        }
    
        Map<Id, FS_Outlet_Dispenser__c> mapIdDispenser = new Map<Id, FS_Outlet_Dispenser__c>([SELECT Id, FS_Last_Updated_Date_Time_to_NMS__c, FS_NMS_Response__c 
                                                    FROM FS_Outlet_Dispenser__c 
                                                  WHERE Id IN :setDispenserIds]);
        Map<Id, FS_Outlet_Dispenser__c> mapErrorLogIdDispenser = new Map<Id, FS_Outlet_Dispenser__c>();
    
        for(Service_Message_Error_Log__c item : beList) {
          if(mapIdDispenser.containsKey(item.Outlet_Dispenser__c) && mapIdDispenser.get(item.Outlet_Dispenser__c) != null) {
            mapErrorLogIdDispenser.put(Item.Id, mapIdDispenser.get(item.Outlet_Dispenser__c));
          }
        }
    
        for(Service_Message_Error_Log__c item : beList) {

            response = callServiceForMessageLogs(item, serviceDetails);
            
            if(resendnumber != null && resendnumber.Resend_Number__c < item.Resend_Counter__c) {
               item.Resend__c = false;
            }
            
            if(mapErrorLogIdDispenser.containsKey(item.Id)) {
              mapIdDispenser.get(mapErrorLogIdDispenser.get(item.Id).Id).FS_Last_Updated_Date_Time_to_NMS__c = System.now();
              if(response != null) {
                mapIdDispenser.get(mapErrorLogIdDispenser.get(item.Id).Id).FS_NMS_Response__c = String.valueOf(response.getStatusCode())+'-'+ response.getStatus();
              } else {
                mapIdDispenser.get(mapErrorLogIdDispenser.get(item.Id).Id).FS_NMS_Response__c = 'Response not received in Expected Time Limit.';
              }
              mapIdDispenser.put(mapErrorLogIdDispenser.get(item.Id).Id,mapIdDispenser.get(mapErrorLogIdDispenser.get(item.Id).Id));
            }
            
            listToUpdate.add(item);
        }
        if(listToUpdate.size() > 0) {
            update listToUpdate;
        }
        
        if(mapIdDispenser != null && mapIdDispenser.values().size() > 0) {
            update mapIdDispenser.values();
        }
    }

    private HttpResponse callServiceForMessageLogs(Service_Message_Error_Log__c errorLog, FOT_API__mdt serviceDetail){
        HTTPRequest request = new HttpRequest();
        Http httpCon = new Http();
        HttpResponse response;
        String bodystr;
    
        try{
            request.setEndpoint(serviceDetail.End_Point__c);
            System.debug('this is end point '+serviceDetail.End_Point__c);
            request.setHeader('Content-Type', 'application/xml');
            request.setHeader('Authorization', serviceDetail.Authorization__c);
            request.setHeader('X-KO-HOST', errorLog.FS_Serial_Number_Asset_Tag__c);
            bodystr = errorLog.Request_Message__c;
            system.debug('Body string : ' + bodystr);
            request.setBody(bodystr);
            request.setMethod('POST');
            request.setTimeout(120000);
       
            //if(!Test.isRunningTest()) {
              response = httpCon.send(request);
              if(response !=null && response.getStatusCode() == 200){
                system.debug('Request executed successfully');
                errorLog.resend__c = false;
              } else {
               system.debug('Request failed');
               
               if(!String.valueOf(response.getStatusCode()).contains('200') || !String.valueOf(response.getStatusCode()).contains('202')) 
               errorLog.resend__c = true;
               
               if (errorLog.Resend_Counter__c==null){errorLog.Resend_Counter__c =0;}
               
               errorLog.Resend_Counter__c = errorLog.Resend_Counter__c + 1;
             }
            //}
        }catch(CalloutException ex){
            System.debug('No callout');
            errorLog.resend__c = true;
            if (errorLog.Resend_Counter__c==null){
             errorLog.Resend_Counter__c =0;
             }
            errorLog.Resend_Counter__c = errorLog.Resend_Counter__c + 1;
        }
        
        return response;
    }
    
    global void finish(Database.BatchableContext BC){

    }

}