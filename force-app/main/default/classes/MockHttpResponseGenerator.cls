@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
      
        String response ='{ \"results\" : [ { \"address_components\" : [ { \"long_name\" : \"High Street\", \"short_name\" : \"High St\", \"types\" : [ \"route\" ] },{ \"long_name\" : \"High Street\", \"short_name\" : \"High St\", \"types\" : [ \"street_number\" ] }, { \"long_name\" : \"Hastings\", \"short_name\" : \"Hastings\", \"types\" : [ \"postal_town\" ] }, { \"long_name\" : \"East Sussex\", \"short_name\" : \"East Sussex\", \"types\" : [ \"administrative_area_level_3\", \"political\" ] },{ \"long_name\" : \"East Sussex\", \"short_name\" : \"East Sussex\", \"types\" : [ \"administrative_area_level_2\", \"political\" ] },{ \"long_name\" : \"East Sussex\", \"short_name\" : \"East Sussex\", \"types\" : [ \"administrative_area_level_1\", \"political\" ] },{ \"long_name\" : \"East Sussex\", \"short_name\" : \"East Sussex\", \"types\" : [ \"administrative_area_level_4\", \"political\" ] },{ \"long_name\" : \"England\", \"short_name\" : \"England\", \"types\" : [ \"postaltown\", \"political\" ] }, { \"long_name\" : \"England\", \"short_name\" : \"England\", \"types\" : [ \"neighborhood\", \"political\" ] },{ \"long_name\" : \"England\", \"short_name\" : \"England\", \"types\" : [ \"politicalsublocality\", \"sublocality_level_1\" ] },{ \"long_name\" : \"England\", \"short_name\" : \"England\", \"types\" : [ \"locality\", \"political\" ] }, { \"long_name\" : \"United Kingdom\", \"short_name\" : \"IN\", \"types\" : [ \"country\", \"political\" ] }, { \"long_name\" : \"TN34 3ES\", \"short_name\" : \"TN34 3ES\", \"types\" : [ \"postal_code\" ] } ], \"formatted_address\" : \"High St, Hastings TN34 3ES, UK\", \"geometry\" : { \"bounds\" : { \"northeast\" : { \"lat\" : 50.8601041, \"lng\" : 0.5957329 }, \"southwest\" : { \"lat\" : 50.8559061, \"lng\" : 0.5906163 } }, \"location\" : { \"lat\" : 50.85830319999999, \"lng\" : 0.5924594 }, \"location_type\" : \"GEOMETRIC_CENTER\", \"viewport\" : { \"northeast\" : { \"lat\" : 50.8601041, \"lng\" : 0.5957329 }, \"southwest\" : { \"lat\" : 50.8559061, \"lng\" : 0.5906163 } } }, \"partial_match\" : true, \"place_id\" : \"ChIJ-Ws929sa30cRKgsMNVkPyws\", \"types\" : [ \"route\" ] } ], \"status\" : \"OK\" }';
     
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        System.assertEquals('GET',req.getMethod());
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }
}