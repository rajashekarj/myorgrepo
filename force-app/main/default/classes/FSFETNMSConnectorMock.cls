/***************************************************************************
 Name         : FSFETNMSConnectorMock
 Created By   : Infosys Limited
 Description  : This class contains the logic to mock HTTP callout for FSFETNMSConnectorTest class
 Created Date : 24-OCT-2017
****************************************************************************/
@isTest
global class FSFETNMSConnectorMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"response": ["created"]}');
        response.setStatusCode(200);
        return response; 
    }
}