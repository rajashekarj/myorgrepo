global  class BatchTest implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    public Id outletRecordId;
    public List<Account> successOlts = new List<Account>();
    public List<Account> failedOlts = new List<Account>();
    public List<String> result = new List<String>();
    public list<String> long_name {get;set;} 
    public List<String> short_name {get;set;} 
    public List<string> typeVal {set;get;}
    
    public String streetNumb{get;set;}
    public String streetRoute{get;set;}
    public string country{get;set;}
    public string postalCode{get;set;}
    public string state{get;set;}
    public string city{get;set;} 
    public string phone {get;set;} 
    public string fax {get;set;} 
   	public  double lat {get;set;}
    public  double lon {get;set;}
    
    
    public BatchTest()
    {
        final Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        final Schema.RecordTypeInfo rtByName =  rtMapByName.get(Label.INTERNATIONAL_OUTLET_RECORD_TYPE);
        system.debug('RecordTypeInfo'+rtByName);
        outletRecordId = rtByName.getRecordTypeId();
    }
    
    public Database.QueryLocator start(final Database.BatchableContext batchCont){
        final String querySize=Label.Query_Limit_Batch;
        final String Id='0011800000WZD59AAH';
        final String country = 'US';
        final Boolean flag = true;
        final string query = 'SELECT Id,Name, FS_Address_Validation_Error__c,FS_Shipping_City_Int__c, FS_Is_Address_Validated__c, FS_Shipping_Street_Int__c,FS_Shipping_State_Province_INT__c,FS_Shipping_Country_Int__c,FS_Shipping_Zip_Postal_Code_Int__c, Fs_Latitude__c,Fs_Longitude__c FROM Account where FS_Shipping_Country_Int__c=\''+country+'\' and BOE_Migrated_Outlet__c = true and RecordTypeId =\''+outletRecordId+'\' ';
            
            //FS_Address_Validation_Error__c=null and Fs_Latitude__c = null limit '+querySize;
        //final string query = 'SELECT Id,Name, FS_Address_Validation_Error__c,FS_Shipping_City_Int__c, FS_Is_Address_Validated__c,FS_Shipping_Street_Int__c,FS_Shipping_State_Province_INT__c,FS_Shipping_Country_Int__c,FS_Shipping_Zip_Postal_Code_Int__c, Fs_Latitude__c,Fs_Longitude__c FROM Account where RecordTypeId =\''+outletRecordId+'\'order by lastmodifieddate desc limit 20 '; 
        return Database.getQueryLocator(query);
    }

    //Execute
    public void execute(final Database.BatchableContext batchCont, final List<Account> scope){
        final List<Account> successOutlets = new List<Account>();
        final List<Account> failedOutlets = new List<Account>();
        final List<Account> updateOutlets = new List<Account>();
        String readAddress;
        system.debug('scope size'+scope.size());
        
        for(Account outlet : scope)
        { 
            readAddress = '';
            
            if(outlet.FS_Shipping_Street_Int__c != FSConstants.STRING_NULL)
            {
                readAddress  =  readAddress + outlet.FS_Shipping_Street_Int__c ;
            }
            if(outlet.FS_Shipping_City_Int__c != FSConstants.STRING_NULL)
            {
                readAddress  =  readAddress + FSConstants.COMMA + outlet.FS_Shipping_City_Int__c ;
            }
            if(outlet.FS_Shipping_State_Province_INT__c != FSConstants.STRING_NULL)
            {
                readAddress  =  readAddress + FSConstants.COMMA + outlet.FS_Shipping_State_Province_INT__c ;
            }
            if(outlet.FS_Shipping_Country_Int__c != FSConstants.STRING_NULL)
            {
                readAddress  =  readAddress + FSConstants.COMMA + outlet.FS_Shipping_Country_Int__c ;
            }
            
            System.debug('readAddress value'+readAddress);
            readAddress = readAddress.replace(' ', '+');
            readAddress= readAddress.replace('\n', '+');
            final String key=Label.Google_Geocode_api_key_value;
            final List<Google_Messages__c> mcs = Google_Messages__c.getall().values();
            System.debug('readAddress value after replace'+readAddress);
            final HttpResponse objresponse=FS_AddressValidationHelper.request(key,readAddress);
            System.debug('JSON '+objresponse);
            if(objresponse.getStatusCode() == FSConstants.STATUS_200)
            {
                long_name=new List<string>();
                short_name=new list<string>();
                typeVal=new List<String>();
                final JSONParser parser = JSON.createParser(objresponse.getBody());
                final string jsonStr = objresponse.getBody();
                final Map <String, Object> root = (Map <String, Object>) JSON.deserializeUntyped(jsonStr); 
                system.debug('Root values'+root+' Status values===='+root.get(FSConstants.STATUS));
                if (root.get(FSConstants.STATUS)==FSConstants.OKAY)
                {
                   /* while (parser.nextToken() != null) 
                    {                        
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&(parser.getText() == 'location'))
                        {
                            parser.nextToken(); // object start
                            while (parser.nextToken() != JSONToken.END_OBJECT)
                            {
                                final String txt = parser.getText();
                                parser.nextToken();
                                if (txt == FSConstants.LAT_TEXT)
                                {
                                    outlet.Fs_Latitude__c = parser.getDoubleValue();
                                }    
                                else if (txt == FSConstants.LON_TEXT)
                                {
                                    outlet.Fs_Longitude__c = parser.getDoubleValue();
                                } 
                            } 
                        }
                        
                    }

                  */
					final List<Object> lstCustomers = (List<Object>)root.get('results');
                    final Map <String, Object> addressComponent = (Map <String, Object>)lstCustomers.get(0);
                    final List<Object> addressValue = (List<Object>)addressComponent.get('address_components'); 
                    // For State mapping 
                    FS_AddressValidationHelper.wrapperClass compValues = new FS_AddressValidationHelper.wrapperClass();
                    compValues = FS_AddressValidationHelper.addressRetrieval(objresponse, addressValue);
                    
                    if(compValues!=null)
                    {
                        long_Name.addAll(compValues.longName);
                        short_name.addall(compValues.shortName);
                        typeVal.addAll(compvalues.type_Val);
                        addressMapping(long_name,short_name,typeVal);
                    }
                    
                    system.debug('Long Val:'+long_name+'Short Val:'+short_name+'Type Val:'+typeval);
                    for(Integer count=0;count<typeVal.size();count++)
                    {
                        if(typeVal[count]==FSConstants.ADMIN_L1)
                        {
                            
                            outlet.FS_Shipping_State_Province_INT__c = FS_AddressValidationHelper.replaceChar(short_name[count]);
                            
                        }
                    }
                    
                    outlet.FS_Is_Address_Validated__c='Yes';
                    outlet.FS_Address_Validated_On__c=datetime.now();
                    outlet.FS_Address_Validation_Error__c=' ';
                    outlet.FS_Shipping_Street_Int__c=streetNumb+' '+streetRoute;
                    outlet.FS_Shipping_City_Int__c=city;
                    outlet.FS_Shipping_Country_Int__c=country;
                    outlet.FS_Shipping_State_Province_INT__c=state;
                    outlet.FS_Shipping_Zip_Postal_Code_Int__c=postalCode;
                    successOutlets.add(outlet);
                }
                else
                {
                    
                    for (Google_Messages__c errorValue :mcs)
                    {
                        
                        if(errorValue.Error_type__c==root.get(FSConstants.STATUS))
                        {
                            
                            outlet.FS_Address_Validation_Error__c =errorValue.Error_Message__c;
                            outlet.FS_Is_Address_Validated__c='No';
                            failedOutlets.add(outlet);
                        }
                    }
                }
                
            }
            else if (objresponse.getStatusCode() == FSConstants.STATUS_400)
            {
                System.debug('Invalid address');
                outlet.FS_Address_Validation_Error__c = 'Invalid address';
                outlet.FS_Is_Address_Validated__c='No';
                failedOutlets.add(outlet);
            }
        }         
        
        try{
            
            updateOutlets.addAll(successOutlets);
            updateOutlets.addall(failedOutlets);
            /*final Database.SaveResult[] saveRes= Database.update(updateOutlets, false);
            for(Integer i=0;i<saveRes.size();i++)
            {
                if(saveRes[i].isSuccess()){
                    system.debug('Updated records'+saveRes[i]);
                }
            }*/
            successOlts.addAll(successOutlets);
            failedOlts.addAll(failedOutlets);
        }catch(DMLexception exp){
            system.debug('batchUpdateAccountGeoLocation exception:' + exp.getMessage());
            ApexErrorLogger.addApexErrorLog('FET International_R1_2017','FSOutletAddressValidationBatch','execute','NA','Medium',exp,'NA');
        }         
        
    }  
    
    
 // Mapping of the retrieved components to the respective fields
    public void addressMapping(final List<String> longName,final List<String> shortName,final List<String> addressValues)
    {
        System.debug('@@@@@@@@'+longName);
        System.debug('@@@@@@@@'+shortName);
        System.debug('@@@@@@@@'+addressValues);
        
        List<String> cityValues = new String[10];
        List<String> stateValues= new String[5];
        //List<String> cityValues = new List<String>();
        String CityVals = '';
        streetNumb = '';
    	streetRoute = '';
        country = '';
		postalCode = '';
		state = '';
		city = '';
        for(Integer count=0;count<addressValues.size();count++)
        {
            if(addressValues[count]==FSConstants.ST_NUM)
            {
                
                streetNumb=FS_AddressValidationHelper.replaceChar(long_name[count]);
                
            }
            else if(addressValues[count]==FSConstants.ROUTE)
            {
                streetRoute=FS_AddressValidationHelper.replaceChar(long_name[count]);
            }
            else if(addressValues[count]==FSConstants.CNTY_POL)
            {
                country=short_name[count];
            }
            else if(addressValues[count]==FSConstants.POSTAL_CODE)
            {
                postalCode=FS_AddressValidationHelper.replaceChar(long_name[count]);
            }
            else if(addressValues[count]==FSConstants.ADMIN_L1)
            {
                stateValues.add(0,short_name[count]); 
            }
            
            else if(addressValues[count]==FSConstants.POSTAL_TOWN) // Priority order for city mapping
            {   
                cityValues[0]=long_name[count];
                
            }
            else if(addressValues[count]==FSConstants.LOCALITY)
            {      
                cityValues[2]=long_name[count];
                stateValues.add(2,short_name[count]);
            }
            else if(addressValues[count]==FSConstants.ADMIN_L2)
            {       
                cityValues[3]=long_name[count];
                stateValues.add(1,short_name[count]);
                
            }
            else if(addressValues[count]==FSConstants.POL_SUB_SUBL_L1) 
            {   
                cityValues[1]=long_name[count];
                
            }  
            else if(addressValues[count]==FSConstants.NGHBR_POL )
            {          
                cityValues[4]=long_name[count];
                
            } 
            else if(addressValues[count]==FSConstants.POSTAL_TOWN_P)
            {                 
                cityValues[5]=long_name[count];
            }
            else if(addressValues[count]==FSConstants.ADMIN_L3)
            {                 
                cityValues[6]=long_name[count];
                
            }
            else if(addressValues[count]==FSConstants.ADMIN_L4)
            {                   
                cityValues[7]=long_name[count];
                
            }
            
            
               
          }
       /* system.debug('cityValues'+cityValues);
        //Mapping of city based on the priority of components
        */
        system.debug('@@@@@@@@'+cityValues);
        for (String var:cityValues)
        {
            if(city=='' && var !=null)
            {
                
                city=FS_AddressValidationHelper.replaceChar(var);
                System.debug(city);
            }
        }
        //Mapping of state based on the priority of components
        System.debug('@@@@@@@@'+stateValues);
        for (String var:stateValues)
        {
            if(state=='' && var !=null)
            {
                state=FS_AddressValidationHelper.replaceChar(var);
            }
        }
        
        //address.Fs_Latitude__c=lat;
        //address.Fs_Longitude__c=lon;
        
    } 
    
    
    //Finish
    public void finish(final Database.BatchableContext batchCont){
        
        String finalstr = 'Record Id, Name, Street, City, State, Country, Postal Code \n';
        String finalstr1 = 'Record Id, Name, Street, City, State, Country, Postal Code \n' ;
        for(Account acc: failedOlts)
        {
            final string recordString = '"'+acc.id+'","'+acc.Name+'"\n';
            finalstr = finalstr +recordString;
            system.debug('failed string in loop:' +finalstr);
        }
        for(Account acc: successOlts)
        {
            final string recordString1 = '"'+acc.id+'","'+acc.Name+'","'+acc.FS_Shipping_Street_Int__c+'","'+acc.FS_Shipping_City_Int__c+'","'+acc.FS_Shipping_State_Province_INT__c+'","'+acc.FS_Shipping_Country_Int__c+'","'+acc.FS_Shipping_Zip_Postal_Code_Int__c+'"\n';
            finalstr1 = finalstr1 +recordString1;
            system.debug('success string in loop:' +finalstr1);
        }
        ToSendEmail.sendEmail(successOlts,failedOlts,finalstr,finalstr1);
    }  
    
    
}