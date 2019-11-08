/****************************************
Name         : FSOutletAddressValidationBatch
Created By   : Vinay Badakannavar
Description  : Batch class to validate existing address outlet addresses
Created Date : May 03, 2017
**************************************/

global class FSOutletAddressValidationBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    public Id outletRecordId;
    public List<Account> successOlts = new List<Account>();
    public List<Account> failedOlts = new List<Account>();
    public List<String> result = new List<String>();
    public list<String> long_name {get;set;} 
    public List<String> short_name {get;set;} 
    public List<string> typeVal {set;get;}
    
    
    public FSOutletAddressValidationBatch ()
    {
        final Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        final Schema.RecordTypeInfo rtByName =  rtMapByName.get(Label.INTERNATIONAL_OUTLET_RECORD_TYPE);
        system.debug('RecordTypeInfo'+rtByName);
        outletRecordId = rtByName.getRecordTypeId();
    }
    
    public Database.QueryLocator start(final Database.BatchableContext batchCont){
        final String querySize=Label.Query_Limit_Batch;
        final Boolean flag = true;
        final string query = 'SELECT Id,Name, FS_Address_Validation_Error__c,FS_Shipping_City_Int__c, FS_Is_Address_Validated__c,FS_Shipping_Street_Int__c,FS_Shipping_State_Province_INT__c,FS_Shipping_Country_Int__c,FS_Shipping_Zip_Postal_Code_Int__c, Fs_Latitude__c,Fs_Longitude__c FROM Account where RecordTypeId =\''+outletRecordId+'\'and BOE_Migrated_Outlet__c = true and FS_Address_Validation_Error__c=null and Fs_Latitude__c = null limit '+querySize;
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
                    while (parser.nextToken() != null) 
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
                        
                    }
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
            final Database.SaveResult[] saveRes= Database.update(updateOutlets, false);
            for(Integer i=0;i<saveRes.size();i++)
            {
                if(saveRes[i].isSuccess()){
                    system.debug('Updated records'+saveRes[i]);
                }
            }
            successOlts.addAll(successOutlets);
            failedOlts.addAll(failedOutlets);
        }catch(DMLexception exp){
            system.debug('batchUpdateAccountGeoLocation exception:' + exp.getMessage());
            ApexErrorLogger.addApexErrorLog('FET International_R1_2017','FSOutletAddressValidationBatch','execute','NA','Medium',exp,'NA');
        }         
        
    }  
    
    //Finish
    public void finish(final Database.BatchableContext batchCont){
        
        String finalstr = FSConstants.HEADER;
        String finalstr1 = FSConstants.HEADER1 ;
        for(Account acc: failedOlts)
        {
            final string recordString = '"'+acc.id+'","'+acc.Name+'"\n';
            finalstr = finalstr +recordString;
            system.debug('failed string in loop:' +finalstr);
        }
        for(Account acc: successOlts)
        {
            final string recordString1 = '"'+acc.id+'","'+acc.Name+'"\n';
            finalstr1 = finalstr1 +recordString1;
            system.debug('success string in loop:' +finalstr1);
        }
        //FS_AddressValidationHelper.sendEmail(successOlts,failedOlts,finalstr,finalstr1);
    }  
    
    
}