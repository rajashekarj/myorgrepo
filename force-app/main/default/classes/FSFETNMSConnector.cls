/***************************************************************************
 Name         : FSFETNMSConnector
 Created By   : Infosys Limited
 Description  : This class contains the logic to make AirWatch call from FET using HTTP
 Created Date : 16-OCT-2017
****************************************************************************/
public with sharing class FSFETNMSConnector {
     
    private static List<Service_Message_Error_Log__c> errorList = new List<Service_Message_Error_Log__c>();
    private static Map<String,FS_Outlet_Dispenser__c> serialNumberMap = new Map<String,FS_Outlet_Dispenser__c> ();
    private static Map<Id, FS_Outlet_Dispenser__c> mapIdOutletDispenser = new Map<Id,FS_Outlet_Dispenser__c> ();
    //public static Map<Id,FS_OD_Settings__c> SettingsMap ;
    public static Boolean isUpdateSAPIDBatchChange=false;
    public static final Id INTODRECORDTYPE=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType,Label.INT_OD_RECORD_TYPE);
    public static Map<Id, FS_Outlet_Dispenser__c> mapIdDispenser;
    private static final String DELETECALL='MasterDataDelete';
    private static final String CHANGECALL='MasterDataChange';
    private static final String APPLICATION='FET';
    private static final String CLASSNAME='FSFETNMSConnector';
    private static final String OBJECTNAME='OutletDispenser';
    private static final String AWSYNCMETHOD='airWatchSynchronousCall';
	private static final String INITIATEAWMETHOD='initiateAirWatchCall';
	private static final String DELETEMETHOD='deleteMasterAssetData';
	private static final String EXECUTEMETHOD='Execute';
    private static final String MEDIUMSEVERITY='Medium';
    private static final Object NULLOBJ=NULL;
    private static final String HASH='#';
    /*
    * @methodName: airWatchSynchronousCall
    * @parameter : Set<Id> lstOutletDispensersID,Map<Id, String> mapDispenserIdstrDispenserAttrChange
    * @return Type: void
    * @description: Method receives the Outlet dispenser information and sends the information to airwatch via HTTP calls synchronously
    */
    public static void airWatchSynchronousCall(final Set<Id> lstOutletDispensersID,final Map<Id, String> mapDispenserIdstrDispenserAttrChange){
        
        final List<FSFETNMSConnectorHelper.MasterDataRequest> awDataSetList = new List<FSFETNMSConnectorHelper.MasterDataRequest>();
        final Platform_Type_ctrl__c equipmentList= Platform_Type_ctrl__c.getValues('EquipmentTypeCheckForNMSUpdateCall'); 
        final Platform_Type_ctrl__c waterHideCheck= Platform_Type_ctrl__c.getValues('WaterHideCheck');
        final Platform_Type_ctrl__c platformTypeBrands = Platform_Type_ctrl__c.getInstance('updateBrands');
        List<FS_Outlet_Dispenser__c> dispenserList =new List<FS_Outlet_Dispenser__c>();
        try{
            dispenserList = [SELECT Id, FS_Outlet__r.ShippingCity,FS_IsActive__c, FS_outlet__r.id, FS_Outlet__r.Name, FS_outlet__r.ShippingCountry,FS_Dispenser_Type2__c,
                                                      FS_Outlet__r.FS_Chain__r.Name, FS_Outlet__r.FS_Headquarters__r.Name, FS_outlet__r.FS_Headquarters__r.FS_ACN__c,
                                                      FS_Outlet__r.ShippingState, FS_Outlet__r.ShippingStreet, FS_Outlet__r.FS_ACN__c, FS_Outlet__r.ShippingPostalCode,
                                                      FS_Outlet__r.FS_Chain__r.FS_ACN__c, FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,
                                                      FS_SAP_ID__c,DMA__c,FS_Serial_Number2__c,Installation__r.FS_Valid_fill_required__c,
                                                 	  FS_Equip_Type__c,Installation__r.FS_Original_Install_Date__c,FS_Equip_Sub_Type__c,FS_Country_Key__c,
                                                      FS_7000_Series_Hide_Water_Button__c,FS_Water_Button__c,FS_Valid_Fill__c,Ownership_Type__c, FS_outlet__r.Bottler_Name__c,FS_outlet__r.Bottlers_Name__c,FS_outlet__r.Bottlers_Name__r.Name,
                                                      Hide_Water_Dispenser__c,FS_CE_Enabled__c,FS_FAV_MIX__c,RecordType.Name, RecordTypeID,Country__c,Item_code__c,
                                                      Brand_Set__c,Brand_Set_formula__c,Enable_CE__c,Enable_Promo__c,Fav_Mix__c,Brands_Not_Selected__c, FS_Last_Updated_Date_Time_to_NMS__c,FS_NMS_Response__c,
                                                      FS_LTO__c,FS_Promo_Enabled__c, FS_ACN_NBR__c, FS_Migration_to_AW_Required__c, FS_Pending_Migration_to_AW__c, FS_Migration_to_AW_Complete__c,
                                                      (select id,Operating_System__c from OD_Editable_Settings__r),FS_Calculated_Time_Zone__c FROM FS_Outlet_Dispenser__c 
                                                      WHERE id in :lstOutletDispensersID and FS_IsActive__c = true];//FS_TimeZone__c
        }
        catch(QueryException queryEX){
            ApexErrorLogger.addAELPayload(APPLICATION, CLASSNAME,AWSYNCMETHOD,OBJECTNAME,MEDIUMSEVERITY,queryEX.getMessage());  
        }  
        
        
        if(!dispenserList.isEmpty()){
            for(FS_Outlet_Dispenser__c dispenser : dispenserList){
            //Create Map of SerialNumber and OD record
            serialNumberMap.put(FSUtil.cleanSpecialCharacters(dispenser.FS_Serial_Number2__c+HASH+dispenser.FS_ACN_NBR__c),dispenser);
            mapIdOutletDispenser.put(dispenser.Id, dispenser);
            final FSFETNMSConnectorHelper.MasterDataRequest awData = populateCommonRequestData(dispenser);
            awData.strAttrChange = '';
            if(mapDispenserIdstrDispenserAttrChange != NULLOBJ
               && mapDispenserIdstrDispenserAttrChange.containsKey(dispenser.Id) ) {
                   awData.strAttrChange = mapDispenserIdstrDispenserAttrChange.get(dispenser.Id);
               }
            
            if(dispenser.RecordTypeId == INTODRECORDTYPE){   
                awData.OutletCountry = dispenser.FS_Country_Key__c;
                if(isUpdateSAPIDBatchChange) {
                    awData.strAttrChange = 'Dispenser';
                }
                awData.setHideWater(dispenser.FS_Water_Button__c);
                //awData.setHideWater(dispenser.Hide_Water_Dispenser__c);   
                if(dispenser.Brand_Set_formula__c != NULLOBJ){
                    awData.AttributesSelected = dispenser.Brand_Set_formula__c + ',';
                }   
                if(dispenser.Brands_Not_Selected__c != NULLOBJ){
                    awData.AttributesNotSelected = dispenser.Brands_Not_Selected__c + ',';
                }
                if(dispenser.Ownership_Type__c == FSConstants.Bottler){
                    awData.SourceSystem = dispenser.FS_outlet__r.Bottlers_Name__r.Name;
                }else{
                    awData.SourceSystem = dispenser.Ownership_Type__c;
                }
                awData.setPlatform(dispenser.FS_Equip_Type__c);                                
                awDataSetList.add(awData);
            }else{               
                if( (!string.isEmpty(dispenser.FS_Equip_Type__c) && equipmentList.Platforms__c.contains(dispenser.FS_Equip_Type__c)) || 
                   (dispenser.FS_Migration_to_AW_Required__c && dispenser.FS_Pending_Migration_to_AW__c) || 
                   (!dispenser.FS_Migration_to_AW_Required__c)) {
                       if(isUpdateSAPIDBatchChange!= NULLOBJ && isUpdateSAPIDBatchChange) {
                           awData.strAttrChange = 'Dispenser';
                       }
                       awData.setDmaValue(dispenser.DMA__c);
                       awData.setHideWater(dispenser.FS_Water_Button__c);
                       //awData.setHideWater(dispenser.Hide_Water_Dispenser__c);
                       
                       if(dispenser.FS_Country_Key__c == NULLOBJ){
                           awData.OutletCountry = 'US';
                       }else{
                           awData.OutletCountry = dispenser.FS_Country_Key__c;
                       }
                       awData.setModel(dispenser.FS_Dispenser_Type2__c);                            
                       awData.setPlatform(dispenser.FS_Equip_Type__c);
                       //Modified as part of FET-7.1 FNF 504. Updating logic using custom setting                    
                       
                       if(!string.isEmpty(dispenser.FS_Equip_Type__c) && platformTypeBrands.Platforms__c.contains(dispenser.FS_Equip_Type__c))
                       {
							awData.setAttributesNotSelected(dispenser.FS_7000_Series_Agitated_Brands_Selection__c,dispenser.FS_7000_Series_Static_Brands_Selections__c);
							awData.setAttributesSelected(dispenser.FS_7000_Series_Agitated_Brands_Selection__c,dispenser.FS_7000_Series_Static_Brands_Selections__c);
                       }
                       awData.SourceSystem = 'CCR';                
                       awDataSetList.add(awData);
                   }
            	}
        	}
        	initiateAirWatchCall(serialNumberMap,awDataSetList,CHANGECALL);
        }        
    }
    /*
    * @methodName: airWatchAsynchronousCall
    * @parameter : Set<Id> lstOutletDispensersID,Map<Id, String> mapDispenserIdstrDispenserAttrChange
    * @return Type: void
    * @description: Future Method receives the Outlet dispenser information asynchronously and based on the input, calls the synchronous airwatch method
    */
    @Future(callout=true)
    public static void airWatchAsynchronousCall(final Set<Id> lstOutletDispensersID,final Map<Id, String> mapDispenserIdstrDispenserAttrChange){
        Set<Id> setDispenserIds = new Set<Id>();
        if(mapDispenserIdstrDispenserAttrChange != NULLOBJ && !mapDispenserIdstrDispenserAttrChange.isEmpty()) {
            setDispenserIds = mapDispenserIdstrDispenserAttrChange.keySet();
            airWatchSynchronousCall(setDispenserIds, mapDispenserIdstrDispenserAttrChange);
        }
        else{
            airWatchSynchronousCall(lstOutletDispensersID, mapDispenserIdstrDispenserAttrChange);
        }  
    }
    /*
    * @methodName: populateCommonRequestData
    * @parameter : FS_Outlet_Dispenser__c
    * @return Type: void
    * @description: Utility method to populate commonly used data
    */
    private static FSFETNMSConnectorHelper.MasterDataRequest populateCommonRequestData(final FS_Outlet_Dispenser__c dispenser){
        final FSFETNMSConnectorHelper.MasterDataRequest awData = new FSFETNMSConnectorHelper.MasterDataRequest();
        awData.setOutletCity (dispenser.FS_Outlet__r.ShippingCity);
        awData.setDmaValue(dispenser.DMA__c);
        awData.setOutletId(dispenser.FS_outlet__r.FS_ACN__c);
        awData.setOutletACN (dispenser.FS_ACN_NBR__c); //added outletACN
        awData.setOutletName(dispenser.FS_Outlet__r.Name);
        awData.setSAPShipToNumber(dispenser.FS_SAP_ID__c);
        awData.setChainName (dispenser.FS_Outlet__r.FS_Chain__r.Name);
        awData.setHQName(dispenser.FS_Outlet__r.FS_Headquarters__r.Name);
        awData.setHQACN (dispenser.FS_outlet__r.FS_Headquarters__r.FS_ACN__c);
        awData.setChainACN(dispenser.FS_outlet__r.FS_Chain__r.FS_ACN__c);
        //fet-international D-03011 
        if(dispenser.FS_Outlet__r.ShippingState==NULLOBJ){
            awData.setOutletState('-');
        }
        else{
            awData.setOutletState(dispenser.FS_Outlet__r.ShippingState);
        }               
        awData.setOutletStreetAddress(dispenser.FS_Outlet__r.ShippingStreet);
        awData.setOutletZipOrPostalCode(dispenser.FS_Outlet__r.ShippingPostalCode);
        awData.setSerialNumber(dispenser.FS_Serial_Number2__c);
        awData.setValidfill(dispenser.FS_Valid_Fill__c);
        awData.setModel(dispenser.FS_Dispenser_Type2__c);  
        awData.setCEEnabled (dispenser.FS_CE_Enabled__c);        
        awData.setLTO(dispenser.FS_LTO__c);                       
       // awData.setFavoriteOrMix(dispenser.FS_FAV_MIX__c);
        awData.setPromoEnabled(dispenser.FS_Promo_Enabled__c);
        
        //Fet-International D-03012 - BottlerName as SourceSystem
        if(dispenser.Ownership_Type__c == FSConstants.Bottler){
            awData.SourceSystem = dispenser.FS_outlet__r.Bottlers_Name__r.Name;
        }else{
            awData.SourceSystem = dispenser.Ownership_Type__c;
        }
       
        for(FS_OD_SettingsReadOnly__c settings: dispenser.OD_Editable_Settings__r)
        {
            awData.operatingSystem = settings.Operating_System__c;
        }
        
        return awData;
    }
    
    /*
    * @methodName: initiateAirWatchCall
    * @parameter : Map<String,FS_Outlet_Dispenser__c> serialNumberMap,List<FSFETNMSConnectorHelper.MasterDataRequest> awDataSetList,string serviceDetailName
    * @return Type: void
    * @description: Method initiates the execute service method based on the inputs provided
    */
    public static void initiateAirWatchCall(final Map<String,FS_Outlet_Dispenser__c> serialNumberMap,final List<FSFETNMSConnectorHelper.MasterDataRequest> awDataSetList,final string serviceDetailName){
        
        
        if(!awDataSetList.isEmpty()){
            for(FSFETNMSConnectorHelper.MasterDataRequest awDataSet : awDataSetList){
                if(awDataSet.SerialNumber != NULLOBJ){       
                    executeService(awDataSet,serviceDetailName);                 
                }
            }
            if(!errorList.isEmpty()){
                try{
                    insert errorList;
                }
                catch(DMLException dmlEX){
                    ApexErrorLogger.addAELPayload(APPLICATION, CLASSNAME,INITIATEAWMETHOD,OBJECTNAME,MEDIUMSEVERITY,dmlEX.getMessage());
                }
            }
        }  
    }
    /*
    * @methodName: deleteMasterAssetData
    * @parameter : Set<Id> setOutletDispenserIds
    * @return Type: void
    * @description: Method sends the deleting request to airwatch on the outlet dispensers that needs to be deleted
    */
    @Future(callout=true)
    public static void deleteMasterAssetData (final Set<Id> setOutletDispenserIds) {
        final List<FSFETNMSConnectorHelper.MasterDataRequest> awDataSetList = new List<FSFETNMSConnectorHelper.MasterDataRequest>();
        try{
            mapIdDispenser = new Map<Id, FS_Outlet_Dispenser__c>([SELECT Id, FS_Serial_Number2__c, FS_ACN_NBR__c, FS_Last_Updated_Date_Time_to_NMS__c, FS_NMS_Response__c  
                                                                                              FROM FS_Outlet_Dispenser__c WHERE Id IN :setOutletDispenserIds]);
            for(FS_Outlet_Dispenser__c obj : mapIdDispenser.values()) {
            final FSFETNMSConnectorHelper.MasterDataRequest awData = new FSFETNMSConnectorHelper.MasterDataRequest();
            awData.SerialNumber=obj.FS_Serial_Number2__c;
            awData.OutletACN= obj.FS_ACN_NBR__c;
            awData.OutletId= obj.Id;
            
            awDataSetList.add(awData);
        	}
        	initiateAirWatchCall(serialNumberMap,awDataSetList,DELETECALL);
        }
        catch(QueryException queryEX){
            ApexErrorLogger.addAELPayload(APPLICATION, CLASSNAME,DELETEMETHOD,OBJECTNAME,MEDIUMSEVERITY,queryEX.getMessage());  
        }          
    }
    /*
    * @methodName: executeService
    * @parameter : FSFETNMSConnectorHelper.MasterDataRequest awDataSet, OutboundServiceDetails__c serviceDetail
    * @return Type: void
    * @description: Method contains the logic to establish connection to Airwatch and send the request, 
    * 				then process the response and write the response to OD fields
    */
    private static void executeService(final FSFETNMSConnectorHelper.MasterDataRequest awDataSet,final String serviceDetailName){
        HTTPRequest request = new HttpRequest();
        final Http httpCon = new Http();
        HttpResponse response;
        String bodystr;
        
        try{
            if(errorList != NULLOBJ){
                errorList.clear();
            }
            request = FOT_APIWebServiceParams.setParamsVal(null,Label.FET_NMSConnector,'','A11');
           // request.setEndpoint(serviceDetail.End_Point__c); 
          //  request.setHeader('Content-Type', 'application/xml');
           //   request.setHeader(serviceDetail.HeaderParamName__c, serviceDetail.HeaderParamValue__c);
            
            // Pass Serial Number in Request Header
            if(awDataSet != NULLOBJ && awDataSet.SerialNumber != NULLOBJ) {
                request.setHeader('X-KO-HOST', awDataSet.SerialNumber);
            } else {
                request.setHeader('X-KO-HOST', '');
            }
            // Pass AW or AW_CMS in Request Header
            if(serviceDetailName.equalsIgnoreCase('FSFETNMSConnectorHelper.MasterDataRequest')) {
                request.setHeader('X-KO-ACTION', 'AW_CMS');
            } else if(serviceDetailName.equalsIgnoreCase(CHANGECALL) 
                      && (awDataSet.strAttrChange != NULLOBJ && (awDataSet.strAttrChange.equalsIgnoreCase('Dispenser') || awDataSet.strAttrChange.equalsIgnoreCase('Both'))) ) {
                          request.setHeader('X-KO-ACTION', 'AW_CMS');
                      } else if(serviceDetailName.equalsIgnoreCase(CHANGECALL) && (awDataSet.strAttrChange != NULLOBJ && awDataSet.strAttrChange.equalsIgnoreCase('Flavor'))) {
                          request.setHeader('X-KO-ACTION', 'AW');
                      } else {
                          request.setHeader('X-KO-ACTION', 'AW_CMS');
                      }
            
            bodystr = FSFETNMSConnectorHelper.toXML(awDataSet,serviceDetailName);
            request.setBody(bodystr);
        //    request.setMethod('POST');
        //    request.setTimeout(120000);
        	system.debug('Request- '+request);
            system.debug('Request Header Content-Type- '+request.getHeader('Content-Type'));
            system.debug('Request Header X-KO-HOST- '+request.getHeader('X-KO-HOST'));
            system.debug('Request Header X-KO-ACTION- '+request.getHeader('X-KO-ACTION'));
            system.debug('Request Body- '+request.getBody()); 
            response = httpCon.send(request);             
            if(response !=NULLOBJ && response.getStatusCode() == 200) {
                if(serialNumberMap.containsKey(awDataSet.SerialNumber+HASH+awDataSet.OutletACN) && serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN) != NULLOBJ) {
                    serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).FS_Last_Updated_Date_Time_to_NMS__c = System.now();
                    serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).FS_NMS_Response__c = String.valueOf(response.getStatusCode())+'-'+ response.getStatus();
                    serialNumberMap.put(awDataSet.SerialNumber+HASH+awDataSet.OutletACN,serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN));
                }
            } else {
                
                if(serialNumberMap.containsKey(awDataSet.SerialNumber+HASH+awDataSet.OutletACN) && serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN) != NULLOBJ) {
                    
                    serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).FS_Last_Updated_Date_Time_to_NMS__c = System.now();
                    if(response !=NULLOBJ) {
                        serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).FS_NMS_Response__c = String.valueOf(response.getStatusCode())+'-'+ response.getStatus();
                    } else {
                        serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).FS_NMS_Response__c = 'Response not received in Expected Time Limit.';
                    }
                    serialNumberMap.put(awDataSet.SerialNumber+HASH+awDataSet.OutletACN,serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN));
                 }
                    if(response !=NULLOBJ && (!String.valueOf(response.getStatusCode()).contains('200') && !String.valueOf(response.getStatusCode()).contains('202'))){
                        final Service_Message_Error_Log__c errorMessage = new Service_Message_Error_Log__c();
                        if(!serialNumberMap.isEmpty()){
                            errorMessage.Outlet_Dispenser__c = serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).Id;
                        }                        
                        errorMessage.Error_Code__c = String.valueOf(response.getStatusCode());
                        errorMessage.Error_Message__c = response.getStatus();
                        errorMessage.Request_Message__c = bodystr;
                        errorMessage.ServiceName__c = serviceDetailName;
                        errorMessage.FS_Serial_Number_Asset_Tag__c = awDataSet.SerialNumber;
                        errorMessage.Error_Line_Number__c = 0;
                        errorMessage.Error_Stack_Trace__c = 'Not an Exception';
                        if(response.getBody() != NULLOBJ){
                            errorMessage.Response_Body__c = response.getBody();
                        }                            
                        else{
                            errorMessage.Response_Body__c = 'No Response Body';
                        }   
                        errorList.add(errorMessage);
                        for(Service_Message_Error_Log__c errorlog : errorList){
                            errorlog.Resend__c = true;
                        }
                    }
            }
            
            if(!request.getBody().contains('HQACN')){
                throw new ErrPayloadException();
            }
        }catch(ErrPayloadException exPayload){   
            ApexErrorLogger.addAELPayload(APPLICATION, CLASSNAME,EXECUTEMETHOD,OBJECTNAME,MEDIUMSEVERITY,request.getBody());
        }catch(CalloutException ex) {
            final Service_Message_Error_Log__c errorMessage = new Service_Message_Error_Log__c();
            
            errorMessage.Error_Line_Number__c = ex.getLineNumber();
            errorMessage.Error_Stack_Trace__c = ex.getStackTraceString();
            
            if(serialNumberMap.containsKey(awDataSet.SerialNumber+HASH+awDataSet.OutletACN) && serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN) != NULLOBJ) {
                errorMessage.Outlet_Dispenser__c = serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).Id;
                
                serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).FS_Last_Updated_Date_Time_to_NMS__c = System.now();
                if(response != NULLOBJ) {
                    serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).FS_NMS_Response__c = String.valueOf(response.getStatusCode())+'-'+ response.getStatus();
                    if(response.getBody() != NULLOBJ){
                        errorMessage.Response_Body__c = response.getBody();
                    }
                    else{
                        errorMessage.Response_Body__c = 'No Response Body';
                    }
                } else {
                    serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN).FS_NMS_Response__c = 'Response not received in Expected Time Limit.';
                }
                serialNumberMap.put(awDataSet.SerialNumber+HASH+awDataSet.OutletACN,serialNumberMap.get(awDataSet.SerialNumber+HASH+awDataSet.OutletACN));
             }
            //Extract the error code from the exception message string and store in error code field
            final Matcher matcher = Pattern.compile('\\d+').matcher(ex.getMessage());
            if(matcher!=NULLOBJ && matcher.find()){
                errorMessage.Error_Code__c = matcher.group();
            }			
            
            errorMessage.Request_Message__c = bodystr;
            errorMessage.Error_Message__c = ex.getMessage();
            errorMessage.ServiceName__c = serviceDetailName;
            errorMessage.Resend__c = true;
            errorMessage.FS_Serial_Number_Asset_Tag__c = awDataSet.SerialNumber;
            errorList.add(errorMessage);
        }
        
    }    
    public class ErrPayloadException extends Exception{}
    
}