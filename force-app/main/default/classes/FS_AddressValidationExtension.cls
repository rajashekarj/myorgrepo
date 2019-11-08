/************************************
Name         : FS_AddressValidationExtension
Created By   : Vinay Badakannavar
Description  : Controller class for Fs_addressvalidator
Created Date : May 03, 2017
**************************************/

public class FS_AddressValidationExtension
{
    public ApexPages.standardController stdCntlr;
    
    public Account address = new Account();
    public static final String KEY=Label.Google_Geocode_api_key_value; // Key for Calling geocode api
    public final List<Google_Messages__c> errorMsgs = Google_Messages__c.getall().values();//Custom setting for displaying error msgs based on response
    public string validateAdd {get; set;}
    public string readAddress {get;set;}
    public  double lat {get;set;}
    public  double lon {get;set;}
    public static string readAddTest {get;set;}
    public static double latTest {get;set;}
    public static double lonTest {get;set;}
    public static string tempAdd {get;set;}
    public double prevLat{get;set;}
    public double prevLong{get;set;}
    public ID recordID{get;set;}
    public Boolean statusFlag {get;set;}
    public String streetNumb{get;set;}
    public String streetRoute{get;set;}
    public string country{get;set;}
    public string postalCode{get;set;}
    public string state{get;set;}
    public string city{get;set;} 
    public string phone {get;set;} 
    public string fax {get;set;} 
    public  list<String> long_name {get;set;} 
    public  List<String> short_name {get;set;} 
    public  List<string> typeVal {set;get;}
    public  List<String> types {get;set;}
    public Boolean refreshPage{get;set;}
    public list<double> location {get;set;} 
    public String oldAddress{get;set;}
    
    public FS_AddressValidationExtension(final ApexPages.StandardController controller) 
    {
        refreshPage=false;
        statusFlag=false;
        recordID=controller.getId();
        stdCntlr=controller;
        address = (Account)controller.getrecord();
        oldAddress='';
        final Account recordDetails=[Select ID,Fs_Latitude__c,Fs_Longitude__c,FS_Shipping_Street_Int__c from Account where ID=:recordID];      
        
        readAddress = ' ';
        if(address.FS_Shipping_Street_Int__c != FSConstants.STRING_NULL)
        {
            readAddress  =  readAddress + address.FS_Shipping_Street_Int__c ;
        }
        
        if(address.FS_Shipping_City_Int__c != FSConstants.STRING_NULL)
        {
            readAddress  =  readAddress + FSConstants.BLANK + address.FS_Shipping_City_Int__c ;
        }
        
        if(address.FS_Shipping_State_Province_INT__c != FSConstants.STRING_NULL)
        {
            readAddress  =  readAddress + FSConstants.BLANK + address.FS_Shipping_State_Province_INT__c ;
        }
        
        if(address.FS_Shipping_Country_Int__c != FSConstants.STRING_NULL)
        {
            readAddress  =  readAddress + FSConstants.BLANK + address.FS_Shipping_Country_Int__c ;
        }
        
        if(address.FS_Shipping_Zip_Postal_Code_Int__c != FSConstants.STRING_NULL)
        {
            readAddress  =  readAddress + FSConstants.BLANK +address.FS_Shipping_Zip_Postal_Code_Int__c ;
        }
        readAddTest=readAddress;
        readAddress = readAddress.replace('\r\n', FSConstants.BLANK);
        readAddress = readAddress.replace('\n',FSConstants.BLANK);
        readAddress = readAddress.replace('\r', FSConstants.BLANK);
        oldAddress=readAddress;
        phone=address.Phone;
        fax=address.Fax;
        prevLat=recordDetails.Fs_Latitude__c; // To retain the values on click of cancel.
        prevLong=recordDetails.Fs_Longitude__c;
        validateAdd=readAddress;
        lat=recordDetails.Fs_Latitude__c;
        lon=recordDetails.Fs_Longitude__c; 
        //To locate on Map after 1st step of outlet creation based on country selection.
        
        if(Test.isRunningTest())
        {
            initialMappingTest();
        }
        else
        {
            initialMapping();
        }
        
    }
    
    //Method for Validation of the entered address
    
    public PageReference validate() 
    {
        string tempAddress=readAddress;
        validateAdd=readAddress; // Used to test whether the entered address is validated before saving
        tempAddress = tempAddress.replace(FSConstants.BLANK,FSConstants.PLUS);
        tempAddress = tempAddress.replace('\n',FSConstants.PLUS);
        try
        {
            final HttpResponse objresponse=FS_AddressValidationHelper.request(KEY,tempAddress);
            final string jsonStr1 = objresponse.getBody();
            final Map <String, Object> root1 = (Map <String, Object>) JSON.deserializeUntyped(jsonStr1); 
            
            system.debug('Address Validation Response Body : '+ jsonStr1);
            system.debug('Address Validation Deserialized Response Body : '+ root1);
            
            if(objresponse.getStatusCode()==FSConstants.STATUS_400)
            {
                
                for (Google_Messages__c errorValue :errorMsgs)
                {
                    if(errorValue.Error_type__c==FSConstants.STATUS_ST_400)
                    {
                        statusFlag = false;   
                        final ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.WARNING,errorValue.Error_Message__c);
                        ApexPages.addmessage(myMsg);
                    }
                }
            }
            
            if(objresponse.getStatusCode() == FSConstants.STATUS_200)
            {
                long_Name=new List<string>();
                short_Name=new List<string>();
                typeVal=new List<string>();
                
                final string jsonStr = objresponse.getBody();
                final Map <String, Object> root = (Map <String, Object>) JSON.deserializeUntyped(jsonStr); 
                final Map<String,String> googleMsg = new Map<String,String>();
                
                for (Google_Messages__c errorValue :errorMsgs)
                {
                    googleMsg.put(errorValue.Error_type__c, errorValue.Error_Message__c);               
                    if(errorValue.Error_type__c==root.get(FSConstants.STATUS))
                    {
                        statusFlag = false;   
                        final ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.WARNING,errorValue.Error_Message__c);
                        ApexPages.addmessage(myMsg);
                    }
                }
                if (root.get(FSConstants.STATUS)==FSConstants.STATUS_OK)
                {
                    city=FSConstants.BLANK;
                    streetNumb=FSConstants.BLANK;
                    streetRoute=FSConstants.BLANK;
                    country=FSConstants.BLANK;
                    state=FSConstants.BLANK;
                    postalCode=FSConstants.BLANK;
                    location = new List<double>();
                    
                    final List<Object> lstCustomers = (List<Object>)root.get('results');
                    final Map <String, Object> addressComponent = (Map <String, Object>)lstCustomers.get(0);
                    final List<Object> addressValue = (List<Object>)addressComponent.get('address_components'); 
                    
                    final Boolean value = (Boolean)addressComponent.get('partial_match'); 
                    location = FS_AddressValidationHelper.geolocation(KEY, tempAddress); //Latitude and Longitude retrieval
                    if(location!=FSConstants.INT_NULL)
                    {
                        if(value==FSConstants.BOOL_VAL)
                        {
                            ApexPages.getMessages().clear();
                            final ApexPages.Message myMsg1 = new  ApexPages.Message(ApexPages.Severity.WARNING,googleMsg.get('Partial match'));
                            ApexPages.addmessage(myMsg1);
                        } 
                        else
                        {
                            final ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,googleMsg.get('Validation Successful'));
                            ApexPages.addmessage(myMsg);
                            
                        }    
                        lat=location.get(0);
                        lon=location.get(1);
                        statusFlag=true;
                        
                    }
                    
                    
                    
                    // Call for Address components retrievel 
                    FS_AddressValidationHelper.wrapperClass compValues = new FS_AddressValidationHelper.wrapperClass();
                    compValues = FS_AddressValidationHelper.addressRetrieval(objresponse, addressValue);
                    
                    if(compValues!=null)
                    {
                        long_Name.addAll(compValues.longName);
                        short_name.addall(compValues.shortName);
                        typeVal.addAll(compvalues.type_Val);
                        addressMapping1(long_name,short_name,typeVal);
                    }
                }
                
            }
        }
        catch(exception ex)
        {
            final ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.WARNING,ex.getMessage());
            ApexPages.addmessage(myMsg);
            ApexErrorLogger.addApexErrorLog('FET International_R1_2017','FS_AddressValidationExtension','validate',FSConstants.NOT_APPLICABLE,'Medium',ex,FSConstants.NOT_APPLICABLE);
        }
        return null;
    }
    
    
    // Mapping of the retrieved components to the respective fields
    public void addressMapping1(final List<String> longName,final List<String> shortName,final List<String> addressValues)
    {
        
        List<String> cityValues = new String[10];
        List<String> stateValues= new String[5];
        //List<String> cityValues = new List<String>();
        for(Integer count=0;count<typeVal.size();count++)
        {
            if(typeVal[count]==FSConstants.ST_NUM)
            {
                
                streetNumb=FS_AddressValidationHelper.replaceChar(long_name[count]);
                
            }
            else if(typeVal[count]==FSConstants.ROUTE)
            {
                streetRoute=FS_AddressValidationHelper.replaceChar(long_name[count]);
            }
            else if(typeVal[count]==FSConstants.CNTY_POL)
            {
                country=short_name[count];
            }
            else if(typeVal[count]==FSConstants.POSTAL_CODE)
            {
                postalCode=FS_AddressValidationHelper.replaceChar(long_name[count]);
            }
            else if(typeVal[count]==FSConstants.ADMIN_L1)
            {
                stateValues.add(0,short_name[count]); 
            }
            
            else if(typeVal[count]==FSConstants.POSTAL_TOWN) // Priority order for city mapping
            {   
                cityValues[0]=long_name[count];
                
            }
            else if(typeVal[count]==FSConstants.LOCALITY)
            {      
                cityValues[1]=long_name[count];
                stateValues.add(2,short_name[count]);
            }                                    
            else if(typeVal[count]==FSConstants.ADMIN_L2)
            {       
                cityValues[2]=long_name[count];
                stateValues.add(1,short_name[count]);
                
            }
            else if(typeVal[count]==FSConstants.POL_SUB_SUBL_L1) 
            {   
                cityValues[3]=long_name[count];
                
            } 
            else if(typeVal[count]==FSConstants.NGHBR_POL )
            {          
                cityValues[4]=long_name[count];
                
            } 
            else if(typeVal[count]==FSConstants.POSTAL_TOWN_P)
            {                 
                cityValues[5]=long_name[count];
                
                
            }
            else if(typeVal[count]==FSConstants.ADMIN_L3)
            {                 
                cityValues[6]=long_name[count];
                
            }
            else if(typeVal[count]==FSConstants.ADMIN_L4)
            {                   
                cityValues[7]=long_name[count];
                
            }
            
            
        }
        system.debug('cityValues'+cityValues);
        //Mapping of city based on the priority of components
        for (String var:cityValues)
        {
            if(city==FSConstants.BLANK && var !=null)
            {
                city=FS_AddressValidationHelper.replaceChar(var);
            }
        }
        //Mapping of state based on the priority of components
        for (String var:stateValues)
        {
            if(state==FSConstants.BLANK && var !=null)
            {
                state=FS_AddressValidationHelper.replaceChar(var);
            }
        }
        
        address.Fs_Latitude__c=lat;
        address.Fs_Longitude__c=lon;
        
    } 
     public void addressMapping2(final List<String> longName,final List<String> shortName,final List<String> addressValues)
    {
        
        List<String> cityValues = new String[10];
        List<String> stateValues= new String[5];
        //List<String> cityValues = new List<String>();
        for(Integer count=0;count<typeVal.size();count++)
        {
            if(typeVal[count]==FSConstants.ST_NUM)
            {
                
                streetNumb=FS_AddressValidationHelper.replaceChar(long_name[count]);
                
            }
            else if(typeVal[count]==FSConstants.ROUTE)
            {
                streetRoute=FS_AddressValidationHelper.replaceChar(long_name[count]);
            }
            else if(typeVal[count]==FSConstants.CNTY_POL)
            {
                country=short_name[count];
            }
            else if(typeVal[count]==FSConstants.POSTAL_CODE)
            {
                postalCode=FS_AddressValidationHelper.replaceChar(long_name[count]);
            }
            else if(typeVal[count]==FSConstants.ADMIN_L1)
            {
                stateValues.add(0,short_name[count]); 
            }
            
            else if(typeVal[count]==FSConstants.POSTAL_TOWN) // Priority order for city mapping
            {   
                cityValues[0]=long_name[count];
                
            }
            else if(typeVal[count]==FSConstants.LOCALITY)
            {      
                cityValues[2]=long_name[count];
                stateValues.add(2,short_name[count]);
            }
            else if(typeVal[count]==FSConstants.ADMIN_L2)
            {       
                cityValues[3]=long_name[count];
                stateValues.add(1,short_name[count]);
                
            }
            else if(typeVal[count]==FSConstants.POL_SUB_SUBL_L1) 
            {   
                cityValues[1]=long_name[count];
                
            }  
            else if(typeVal[count]==FSConstants.NGHBR_POL )
            {          
                cityValues[4]=long_name[count];
                
            } 
            else if(typeVal[count]==FSConstants.POSTAL_TOWN_P)
            {                 
                cityValues[5]=long_name[count];
            }
            else if(typeVal[count]==FSConstants.ADMIN_L3)
            {                 
                cityValues[6]=long_name[count];
                
            }
            else if(typeVal[count]==FSConstants.ADMIN_L4)
            {                   
                cityValues[7]=long_name[count];
                
            }
            
            
        }
        system.debug('cityValues'+cityValues);
        //Mapping of city based on the priority of components
        for (String var:cityValues)
        {
            if(city==FSConstants.BLANK && var !=null)
            {
                city=FS_AddressValidationHelper.replaceChar(var);
            }
        }
        //Mapping of state based on the priority of components
        for (String var:stateValues)
        {
            if(state==FSConstants.BLANK && var !=null)
            {
                state=FS_AddressValidationHelper.replaceChar(var);
            }
        }
        
        address.Fs_Latitude__c=lat;
        address.Fs_Longitude__c=lon;
        
    } 
    
    //For Updation of the valid Outlet Address
    Public pageReference save()
    {
        final Map<String,String> googleMsg = new Map<String,String>();
        for (Google_Messages__c errorValue :errorMsgs)
        {
            googleMsg.put(errorValue.Error_type__c, errorValue.Error_Message__c);   
        }
        
        if( statusFlag && validateAdd==readAddress)
        {      
            
            address.FS_Shipping_City_Int__c=city;
            address.Fs_Latitude__c=lat;
            address.Fs_Longitude__c=lon;
            address.FS_Shipping_Street_Int__c =streetNumb+FSConstants.BLANK+streetRoute ;
            address.FS_Shipping_State_Province_INT__c = state;
            address.FS_Shipping_Country_Int__c = country;
            address.FS_Shipping_Zip_Postal_Code_Int__c = postalCode;
            address.FS_Is_Address_Validated__c='Yes';
            address.FS_Address_Validated_On__c=datetime.now();
            try
            {
                update address;
                refreshPage=true;
            }
            catch(DMLException ex)
            {
                final ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.WARNING,googleMsg.get('Save not successful'));
                ApexPages.addmessage(myMsg);
                ApexErrorLogger.addApexErrorLog('FET International_R1_2017','FS_AddressValidationExtension','save',FSConstants.NOT_APPLICABLE,'Medium',ex,FSConstants.NOT_APPLICABLE);
                
            }
            statusFlag = false;
        }
        
        else if (validateAdd==readAddress && (phone!=address.Phone || fax!=address.Fax))
        {  
            try
            {
                update address;
                refreshPage=true;
            }
            catch(DMLException ex)
            {
                final ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.WARNING,googleMsg.get('Save not successful'));
                ApexPages.addmessage(myMsg);
                ApexErrorLogger.addApexErrorLog('FET International_R1_2017','FS_AddressValidationExtension','save',FSConstants.NOT_APPLICABLE,'Medium',ex,FSConstants.NOT_APPLICABLE);
                
            }
            
        }
        else
        {
            final ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.WARNING,googleMsg.get('Validate before save'));
            ApexPages.addmessage(myMsg);
            
        }
        
        
        return null;
    }
    

    //Method for test class execution
    @future(callout=true)
    public static void initialMappingTest()
    {
        tempAdd= readAddTest.replace(FSConstants.BLANK,FSConstants.PLUS);
        tempAdd= tempAdd.replace('\n',FSConstants.PLUS);
        list<double> location =new list<double>();
        location = FS_AddressValidationHelper.geolocation(KEY, tempAdd);
        if(!location.isEmpty())
        {
            latTest=location.get(0);
            lonTest=location.get(1);
        }
        
    }
    //Method for Initial Map Pointer after 1st step of Outlet creation
    public void initialMapping()
    {
        String localAdd= readAddress.replace(FSConstants.BLANK,FSConstants.PLUS);
        localAdd= localAdd.replace('\n',FSConstants.PLUS);
        list<double> location =new list<double>();
        location = FS_AddressValidationHelper.geolocation(KEY, localAdd);
        if(!location.isEmpty())
        {
            lat=location.get(0);
            lon=location.get(1);
        }
        System.debug('lat and Long '+lat+FSConstants.BLANK+lon);
    }
    
    public PageReference doCancel()
    {       
        readAddress=oldAddress;
        lat=prevLat;
        lon=prevLong;               
        return null	;
    }
    
}