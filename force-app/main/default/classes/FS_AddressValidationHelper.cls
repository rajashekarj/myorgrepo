/*************************************
Name         : FS_AddressValidationHelper
Created By   : Vinay Badakannavar
Description  : Helper class for FS_AddressValidationExtension
Created Date : June 14, 2017
**************************************/
Public class FS_AddressValidationHelper
{
    public static FS_AddressValidationExtension controller1;
    public static List<double> coordinates = new List<double>();
    public static final String END_POINT_URL=Label.FS_Geocode_Endpoint_URL;
    public static List<String> types {get;set;}
    public static list<String> long_name {get;set;} 
    public static List<String> short_name {get;set;} 
    public static List<string> typeVal {set;get;}
  
    
    // Method to make HTTP req and get the response
    // from Google Geocode API
    public static HttpResponse request(final String key, final String tempAddress)
    {
        
        final HttpRequest objrequest = new HttpRequest();
        objrequest.setEndpoint(END_POINT_URL+tempAddress+'&key='+key+'&language=en&region=US');
        objrequest.setMethod('GET');
        objrequest.setCompressed(false);            
        objrequest.setHeader('Encoding','iso-8859-1');
        objrequest.setTimeout(120000);//max timeout
        return new http().send(objrequest);
        
    }
    
    // Method for Extracting Latitude and Longitude
    public static list<double> geolocation(final String key, final String tempAddress)
    {
        if(request(key,tempAddress)!=null)
        {
            final HttpResponse objresponse=request(key,tempAddress);
            final JSONParser parser2 =JSON.createParser(objresponse.getBody());
            while (parser2.nextToken() != null) 
            {                        
                if ((parser2.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser2.getText() == 'location'))
                {
                    parser2.nextToken(); // object start
                    while (parser2.nextToken() != JSONToken.END_OBJECT)
                    {
                        final String txt = parser2.getText();
                        parser2.nextToken();
                        if (txt ==FSConstants.LAT)
                        {
                            coordinates.add(parser2.getDoubleValue());
                        }    
                        else if (txt == FSConstants.LON)
                        {
                            coordinates.add(parser2.getDoubleValue());
                        } 
                        
                    } 
                }
                
            }
            
             return coordinates;
        }
       return null;
    }
    /*
    // Method used by Batch class for sending email
    // of success and failure records
    public static void sendEmail(final List<Account> successOlts,final List<Account> failedOlts,final String finalstr,final String finalstr1,final String str,final String str1,final String str5)
    {
        final Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        final blob csvBlob = Blob.valueOf(finalstr);
        
        csvAttc.setFileName(FSConstants.CSVNAME);
        csvAttc.setBody(csvBlob);
        
        final Messaging.EmailFileAttachment csvAttc1 = new Messaging.EmailFileAttachment();
        final blob csvBlob1 = Blob.valueOf(finalstr1);
        
        csvAttc1.setFileName(FSConstants.CSVNAME1);
        csvAttc1.setBody(csvBlob1);
        final String[] toAddresses = new list<string>();
        
        final Messaging.EmailFileAttachment csvAttc3 = new Messaging.EmailFileAttachment();
        final blob csvBlob3 = Blob.valueOf(str);
        
        csvAttc3.setFileName('City Fields');
        csvAttc3.setBody(csvBlob3);
        //final String[] toAddresses = new list<string>();
        final Messaging.EmailFileAttachment csvAttc4 = new Messaging.EmailFileAttachment();
        final blob csvBlob4 = Blob.valueOf(str1);
        
        csvAttc4.setFileName('Full Address');
        csvAttc4.setBody(csvBlob4);
        
        final Messaging.EmailFileAttachment csvAttc5 = new Messaging.EmailFileAttachment();
        final blob csvBlob5 = Blob.valueOf(str5);
        
        csvAttc5.setFileName('Revised City');
        csvAttc5.setBody(csvBlob5);
        
        final Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        final string userEmail = userinfo.getUserEmail();
        toaddresses.add(userEmail);
        
        email.setSubject(FSConstants.SUBJECT);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Hi, PFA list of Outlets processed in batch job');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc,csvAttc1,csvAttc3,csvAttc4,csvAttc5});
        final Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        for(Messaging.SendEmailResult res:result)
        {
            if (res.success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + res.errors[0].message);
            } 
        }
        
    }*/
    
     //Method for retrieving address components from the response based on the type.
    public static wrapperClass addressRetrieval( final HttpResponse objresponse, final List<Object> addressValue )
    {
        long_name=new List<string>();
        short_name=new list<string>();
        typeVal=new List<String>();  
        
         
       // List<List<string>> returnValue=new List<List<string>>();
        final JSONParser parser = JSON.createParser(objresponse.getBody());
        
        for(Integer numb=0;numb<addressValue.size();numb++)
        {
            while (parser.nextToken() != JSONToken.END_OBJECT) 
            {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) 
                {
                    final String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) 
                    {
                        if (text == FSConstants.LNG_NAME)
                        {
                            long_name.add(parser.getText());    
                        } 
                        if (text == FSConstants.SRT_NAME) 
                        {
                            short_name.add(parser.getText());
                        }
                        if (text == FSConstants.TYPES_STG)
                        {
                            types = new List<String>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) 
                            {
                                
                                types.add(parser.getText());
                            }
                            if(types.size()>FSConstants.NUM_1)
                            {
                                if(types.size() == FSConstants.NUM_2){ typeVal.add(types[0]+types[1]);}
                                if(types.size() == FSConstants.NUM_3){ typeVal.add(types[0]+types[1]+types[2]);}                                
                            }
                            else
                            {   
                                typeVal.addAll(types);
                            }
                        } 
                    }
                }
            }
        }
      
       wrapperClass wrpObj = new wrapperClass();
        
        wrpObj.longName = new List<String>();
        wrpObj.shortName = new List<String>();
        wrpObj.type_Val = new List<String>();
        wrpObj.longName.addall(long_name);
        wrpObj.shortName.addall(short_name);
        wrpObj.type_Val.addall(typeVal);
      
        return wrpObj;
    }
    
     
    
    //Wrapper class for returning multiple lists
    public class  wrapperClass
    {
        public  list<String> longName {get;set;} 
        public  List<String> shortName {get;set;} 
        public  List<string> type_Val {set;get;} 
    }
    
      //Method for replacement of special characters
    public static string replaceChar(String input)                                
    {
        String specialChar = 'ÀÂÇÉÈÊËÎÏÛÔàáâãåāçèéēêëîìïīíòôóøōõûūúù';
        String normalChar  = 'AACEEEEIIUOaaaaaaceeeeeiiiiioooooouuuu';
        String result = '';                 
        for (Integer i = 0 ; i < input.length() ; i++) {       
            String charIndex = input.substring(i, i+1);
            Integer idx = specialChar.indexOf(charIndex );
            if (idx != -1){
                result += normalChar.substring(idx, idx+1);
            } else {
                result += charIndex ;
            }
        }
		
		String specialChar1 = 'ßäöüÄÖÜ';
        String normalChar1  = 'ssaeoeueAeOeUe';
		String result1='';
		for (Integer i = 0 ; i < result.length() ; i++) {
            String charIndex1 = result.substring(i, i+1);
            Integer idx = specialChar1.indexOf(charIndex1);
            if (idx != -1){
                result1 += normalChar1.substring(idx*2,(idx*2)+2);
            } else {
                result1 += charIndex1 ;
            }
        }
		return result1;
        
    }
    

}