/***************************************************************************
 Name         : FSFETNMSConnectorHelper
 Created By   : Infosys Limited
 Description  : FSFETNMSConnectorHelper is a helper class to FSFETNMSConnector class and contains an inner class and a toXML method
 Created Date : 16-OCT-2017
****************************************************************************/
public class FSFETNMSConnectorHelper{
    
    private static Map<String,String> fetDataMap = null;
    
    /* @className: MasterDataRequest
    * @description: Master class for creating AW Data with the help of FETAW Datamapping custom setting
    */
    public Class MasterDataRequest{        
        public String strAttrChange{get; set;}
        String OutletDispenserId{get;set;}
        public String SerialNumber{get;set;}
        String NumberOfDispenser{get;set;}
        public String OutletACN{get;set;} // added outletACN
        public String OutletId{get;set;}
        String OutletName{get;set;}
        String OutletStreetAddress{get;set;}
        String OutletCity{get;set;}
        String OutletState{get;set;}
        public String OutletCountry{get;set;}
        String OutletZipOrPostalCode{get;set;}
        String SAPShipToNumber{get;set;}
        String HQACN{get;set;}
        String HQName{get;set;}
        String ChainACN{get;set;}
        String ChainName{get;set;}
        String Model{get;set;}
        public String Platform{get;set;}
        public String SourceSystem{get;set;}
        String DMA{get;set;}
        String HideWater {get;set;}
        String Validfill{get;set;}
        String CEEnabled{get;set;}
        //String FavoriteOrMix{get;set;}
        String LTO{get;set;}
        String PromoEnabled{get;set;}
        public String AttributesSelected{get;set;}
        public String AttributesNotSelected{get;set;}
        public String operatingSystem{get;set;}
        List<FS_FET_Airwatch_Data_Mapping__c> fetAWDataList;
        
        
         //Default constructor which creates Key Value pairs for FET AW Datamapping
        public MasterDataRequest(){
           //Map used in setter methods
            fetDataMap=new Map<String,String>();
            //getting List of values  from FET Airwatch Data Mapping custom setting
            fetAWDataList = FS_FET_Airwatch_Data_Mapping__c.getall().values();
            for(FS_FET_Airwatch_Data_Mapping__c fetAWData: fetAWDataList){
                fetDataMap.put(fetAWData.FS_Field_name__c+fetAWData.FS_FET_Value__c,fetAWData.FS_Airwatch_Value__c);
            }    
        }
       //setter mehtods for AW attributes
        public void setstrAttrChange(String strAttrChange){
           this.strAttrChange=strAttrChange;           
        }
        public void setOutletDispenserId(String OutletDispenserId){
            OutletDispenserId=FSUtil.cleanSpecialCharacters(OutletDispenserId);
                this.OutletDispenserId=OutletDispenserId;           
        }
        public void setSerialNumber(String SerialNumber){           
                this.SerialNumber=SerialNumber;         
        }
        public void setDmaValue(String DMA){
	            this.DMA=DMA;
        }
        public void setOutletACN(String OutletACN){
                OutletACN=FSUtil.cleanSpecialCharacters(OutletACN);
                this.OutletACN=OutletACN;           
        }
        public void setOutletId(String OutletId){
                OutletId=FSUtil.cleanSpecialCharacters(OutletId);
                this.OutletId=OutletId;         
        }
        public void setOutletName(String OutletName){
                OutletName=FSUtil.cleanSpecialCharacters(OutletName);
                this.OutletName=OutletName;         
        }
         public void setOutletStreetAddress(String OutletStreetAddress){
                OutletStreetAddress=FSUtil.cleanSpecialCharacters(OutletStreetAddress);
                this.OutletStreetAddress=OutletStreetAddress;           
        }
         public void setOutletCity(String OutletCity){
                OutletCity=FSUtil.cleanSpecialCharacters(OutletCity);
                this.OutletCity=OutletCity;         
        }
         public void setOutletState(String OutletState){
                OutletState=FSUtil.cleanSpecialCharacters(OutletState);
                this.OutletState=OutletState;           
        }
         public void setOutletCountry(String OutletCountry){                
                this.OutletCountry=OutletCountry;           
        }
         public void setOutletZipOrPostalCode(String OutletZipOrPostalCode){
                OutletZipOrPostalCode=FSUtil.cleanSpecialCharacters(OutletZipOrPostalCode);
                this.OutletZipOrPostalCode=OutletZipOrPostalCode;           
        }
         public void setSAPShipToNumber(String SAPShipToNumber){
                SAPShipToNumber=FSUtil.cleanSpecialCharacters(SAPShipToNumber);
                this.SAPShipToNumber=SAPShipToNumber;           
        }
        public void setHQACN(String HQACN){ 
                HQACN=FSUtil.cleanSpecialCharacters(HQACN);
                this.HQACN=HQACN;           
        }
        public void setHQName(String HQName){   
                HQName=FSUtil.cleanSpecialCharacters(HQName);
                this.HQName=HQName;         
        }
        
        public void setChainACN(String ChainACN){   
                ChainACN=FSUtil.cleanSpecialCharacters(ChainACN);
                this.ChainACN=ChainACN;           
        }
        public void setChainName(String ChainName){ 
                ChainName=FSUtil.cleanSpecialCharacters(ChainName);
                this.ChainName=ChainName;           
        }
        public void setPlatform(String Platform){           
                this.Platform=Platform;         
        }
        
        public void setoperatingSystem(String operatingSystem)
        {
            	this.operatingSystem = operatingSystem;
        }
  
        //setter methods which gets values from FET AW custom setting
        public void setLTO(String LTO){
            if(LTO!=null && LTO!='' && fetDataMap.containsKey('FS_LTO__c'+LTO)){                     
                    this.LTO=fetDataMap.get('FS_LTO__c'+LTO);                 
            }else{
                this.LTO=LTO;
            }
        }

        public void setModel(String Model){
            if(Model!=null && Model!='' && fetDataMap.containsKey('FS_Model__c'+Model)){                     
                    Model=fetDataMap.get('FS_Model__c'+Model);                
            }else{
                Model=Model;
            }
            this.Model=FSUtil.cleanSpecialCharacters(Model);
        } 
        public void setHideWater(String HideWater){            
            if(HideWater!=null && HideWater!='' && fetDataMap.containsKey('FS_Water_Button__c'+HideWater)){                       
                   HideWater=fetDataMap.get('FS_Water_Button__c'+HideWater);                   
            }else{
                HideWater=HideWater;
            }
            this.HideWater=FSUtil.cleanSpecialCharacters(HideWater);
        } 
        
         public void setCEEnabled(String CEEnabled){
            if(CEEnabled!=null && CEEnabled!='' && fetDataMap.containsKey('FS_CE_Enabled__c'+CEEnabled)){                     
                    CEEnabled=fetDataMap.get('FS_CE_Enabled__c'+CEEnabled);                 
            }else{
                CEEnabled=CEEnabled;
            }
             this.CEEnabled=FSUtil.cleanSpecialCharacters(CEEnabled);
        }
         /*public void setFavoriteOrMix(String FavoriteOrMix){
            if(FavoriteOrMix!=null && FavoriteOrMix!='' && fetDataMap.containsKey('FS_FAV_MIX__c'+FavoriteOrMix)){                     
                    FavoriteOrMix=fetDataMap.get('FS_FAV_MIX__c'+FavoriteOrMix);                 
            }else{
                FavoriteOrMix=FavoriteOrMix;
            }
             this.FavoriteOrMix=FSUtil.cleanSpecialCharacters(FavoriteOrMix);
        }*/
         public void setPromoEnabled(String PromoEnabled){             
            if(PromoEnabled!=null && PromoEnabled!='' && fetDataMap.containsKey('FS_Promo_Enabled__c'+PromoEnabled)){                     
                    PromoEnabled=fetDataMap.get('FS_Promo_Enabled__c'+PromoEnabled);                    
            }else{
                PromoEnabled=PromoEnabled;
            }
             this.PromoEnabled=FSUtil.cleanSpecialCharacters(PromoEnabled);
        }

        public void setValidFill(String ValidFill){            
            if(ValidFill!=null && ValidFill!='' && fetDataMap.containsKey('FS_Valid_Fill__c'+ValidFill)){                     
                    this.ValidFill=fetDataMap.get('FS_Valid_Fill__c'+ValidFill);                 
            }else{
                this.ValidFill=ValidFill;
            }
            this.validFill=FSUtil.cleanSpecialCharacters(this.ValidFill);
        }
        
        
        
        //Selected Agitated and Static Brands are send to Airwatch as  AttributedSelected  
        public void setAttributesSelected(String agitatedBrandSelection,String staticBrandSelection){ 
            //The ';' values are replaced with ',' from the multiselect picklist
              if(agitatedBrandSelection != null && !agitatedBrandSelection.contains(FSConstants.naTo80009000S)){                  
                        AttributesSelected = agitatedBrandSelection.replace(';',',') + ',';                        
              }              
              if(staticBrandSelection != null && !staticBrandSelection.contains(FSConstants.naTo80009000S)){
                    if(AttributesSelected != null){
                            AttributesSelected = AttributesSelected + staticBrandSelection.replace(';',',') + ',';
                            
                    }else{
                            AttributesSelected =staticBrandSelection.replace(';',',') + ',';
                        }
                }            
                if(AttributesSelected!=null){
                //To simplefy our functionality A FET-AW Brandnew Map is created to set the FET brand values with AW brand values 
                  Map<String,String> fetAWBrandValueMap=new Map<String,String>();
                        for(FS_FET_Airwatch_Data_Mapping__c  fetAWData:fetAWDataList){
                            if(fetAWData.FS_Field_name__c=='FS_7000_Series_Agitated_Brands_Selection__c' || fetAWData.FS_Field_name__c=='FS_7000_Series_Static_Brands_Selections__c'){
                                fetAWBrandValueMap.put(fetAWData.FS_FET_Value__c,fetAWData.FS_Airwatch_Value__c);                       
                                }
                        }                       
                        String[] AttributesSelectedList=new List<String>();
                        //All the brand values are made as an array list by sliting with delimiter ',' 
                        AttributesSelectedList=AttributesSelected.split(',');           
                        AttributesSelected=''; 
                        //replacing the FET Brand value with AW Value
                        for(String selectedValue:AttributesSelectedList){
                            if(fetAWBrandValueMap.containsKey(selectedValue)){
                             AttributesSelected=AttributesSelected+fetAWBrandValueMap.get(selectedValue)+',';  
                            }                       
                        }
                    //remove the tailing commas 
                    AttributesSelected=AttributesSelected.removeEnd(',');
                }
            AttributesSelected=FSUtil.cleanSpecialCharacters(AttributesSelected);
            this.AttributesSelected=AttributesSelected; 
            System.debug('**AttributedSelected'+this.AttributesSelected);
        }
        
        
       //unSelected Agitated and Static Brands are send to Airwatch as  AttributedNotSelected 
        public void setAttributesNotSelected(String agitatedBrandSelection,String staticBrandSelection){
            AttributesNotSelected='';
            //Create a AttributesNotSelected string by picking all the not selected values  from agitated and static brand
              Schema.DescribeFieldResult agitatedBrandPicklist =FS_Outlet_Dispenser__c.FS_7000_Series_Agitated_Brands_Selection__c.getDescribe();
                List<Schema.PicklistEntry> agitatedBrandPicklistValues = agitatedBrandPicklist.getPicklistValues();
                for(Schema.PicklistEntry picklist : agitatedBrandPicklistValues){
                    if(agitatedBrandSelection != null   && !agitatedBrandSelection.contains(picklist.getValue())
                                                        && picklist.getValue() != FSConstants.naTo80009000S){                        
                            AttributesNotSelected =AttributesNotSelected +picklist.getValue() + ',';
                        
                    }else if(agitatedBrandSelection == null && picklist.getValue() != FSConstants.naTo80009000S){                        
                            AttributesNotSelected=AttributesNotSelected+picklist.getValue() + ',';                        
                    }
                }                                
            Schema.DescribeFieldResult staticBrandPicklist =FS_Outlet_Dispenser__c.FS_7000_Series_Static_Brands_Selections__c.getDescribe();
                List<Schema.PicklistEntry> staticBrandPicklistValues = staticBrandPicklist.getPicklistValues();
                for(Schema.PicklistEntry picklist : staticBrandPicklistValues){
                    if(staticBrandSelection != null && !staticBrandSelection.contains(picklist.getValue())
                                                    && picklist.getValue() != FSConstants.naTo80009000S){                        
                            AttributesNotSelected=AttributesNotSelected+picklist.getValue()+ ',';
                     }else if(staticBrandSelection== null   && picklist.getValue() != FSConstants.naTo80009000S){
                        AttributesNotSelected=AttributesNotSelected+picklist.getValue()+ ',';                           
                    }
                }
                if(AttributesNotSelected!=null){
                     //To simplefy our functionality A FET-AW Brandnew Map is created to set the FET brand values with AW brand values
                        Map<String,String> fetAWBrandValueMap=new Map<String,String>();
                        for(FS_FET_Airwatch_Data_Mapping__c  fetAWData:fetAWDataList){
                            if(fetAWData.FS_Field_name__c=='FS_7000_Series_Agitated_Brands_Selection__c' || fetAWData.FS_Field_name__c=='FS_7000_Series_Static_Brands_Selections__c'){
                                fetAWBrandValueMap.put(fetAWData.FS_FET_Value__c,fetAWData.FS_Airwatch_Value__c);                       
                                }                       
                        }                       
                        String[] AttributesNotSelectedList=new List<String>();
                    //All the brand values are made as an array list by sliting with delimiter ','
                        AttributesNotSelectedList=AttributesNotSelected.split(',');         
                        AttributesNotSelected=''; 
                      //replacing the FET Brand value with AW Value
                        for(String notSelectedValue:AttributesNotSelectedList){
                            if(fetAWBrandValueMap.containsKey(notSelectedValue)){
                                AttributesNotSelected=AttributesNotSelected+fetAWBrandValueMap.get(notSelectedValue)+',';  
                            }                     
                        }
                    //remove the tailing commas 
                    AttributesNotSelected=AttributesNotSelected.removeEnd(','); 
                 }
                AttributesNotSelected=FSUtil.cleanSpecialCharacters(AttributesNotSelected);
                this.AttributesNotSelected=AttributesNotSelected;  
                System.debug('**AttributedNotSelected'+this.AttributesNotSelected);
        }
         //end of changes done for OCR-1 by Praveen Sahu
    }
    /*
    * @methodName: toXml
    * @parameter : MasterDataRequest requestObject,String serviceName
    * @return Type: String
    * @description: Method converts request object into XML format and returns the XML string
    */
    public static String toXml(MasterDataRequest requestObject,String serviceName){
        DOM.Document doc = new DOM.Document();
        String xsi = 'urn:na.ko.com:esb:freestyle:schemas:masterdata';
        dom.XmlNode envelope = doc.createRootElement(serviceName, null, null);

        envelope.setAttribute('xmlns', xsi);

          if(requestObject.SerialNumber != null){
            envelope.addChildElement('SerialNumber', null, null).addTextNode(requestObject.SerialNumber);
         }else{
            envelope.addChildElement('SerialNumber', null, null);
         }
         system.debug('The OutletACN is '+requestObject.OutletACN);
         if(serviceName == 'MasterDataDelete'){
            if(requestObject.OutletACN != null){
                envelope.addChildElement('OutletId', null, null).addTextNode(requestObject.OutletACN);
             }else{
                envelope.addChildElement('OutletId', null, null);
             }  
         }
         if(serviceName != 'MasterDataDelete'){
             if(requestObject.SerialNumber == null){
                 if(requestObject.NumberOfDispenser != null){
                    envelope.addChildElement('NumberOfDispenser', null, null).addTextNode(requestObject.NumberOfDispenser);
                 }else{
                    envelope.addChildElement('NumberOfDispenser', null, null);
                 }
             }
             if(requestObject.OutletId != null){
                envelope.addChildElement('OutletId', null, null).addTextNode(requestObject.OutletId);
             }else{
                envelope.addChildElement('OutletId', null, null);
             }
             if(requestObject.DMA != null){
	            envelope.addChildElement('DMA',null, null).addTextNode(requestObject.DMA);
	         }else{
	             envelope.addChildElement('DMA',null, null);
	         }
             if(requestObject.OutletName != null){
                envelope.addChildElement('OutletName', null, null).addTextNode(requestObject.OutletName);
             }else{
                envelope.addChildElement('OutletName', null, null);
             }
             if(requestObject.OutletStreetAddress != null){
                envelope.addChildElement('OutletStreetAddress', null, null).addTextNode(requestObject.OutletStreetAddress);
             }else{
                envelope.addChildElement('OutletStreetAddress', null, null);
             }
             if(requestObject.OutletCity != null){
                envelope.addChildElement('OutletCity', null, null).addTextNode(requestObject.OutletCity);
             }else{
                envelope.addChildElement('OutletCity', null, null);
             }
             if(requestObject.OutletState != null){
                envelope.addChildElement('OutletState', null, null).addTextNode(requestObject.OutletState);
             }else{
                envelope.addChildElement('OutletState', null, null);
             }
             if(requestObject.OutletCountry != null){
                envelope.addChildElement('OutletCountry', null, null).addTextNode(requestObject.OutletCountry);
             }else{
                envelope.addChildElement('OutletCountry', null, null);
             }
             if(requestObject.OutletZipOrPostalCode != null){
                envelope.addChildElement('OutletZipOrPostalCode', null, null).addTextNode(requestObject.OutletZipOrPostalCode);
             }else{
                envelope.addChildElement('OutletZipOrPostalCode', null, null);
             }
             if(requestObject.SAPShipToNumber != null){
                envelope.addChildElement('SAPShipToNumber', null, null).addTextNode(requestObject.SAPShipToNumber);
             }else{
                envelope.addChildElement('SAPShipToNumber', null, null);
             }
             if(requestObject.HQACN != null){
                envelope.addChildElement('HQACN', null, null).addTextNode(requestObject.HQACN);
             }else{
                envelope.addChildElement('HQACN', null, null);
             }
             if(requestObject.HQName != null){
                envelope.addChildElement('HQName', null, null).addTextNode(requestObject.HQName);
             }else{
                envelope.addChildElement('HQName', null, null);
             }
             if(requestObject.ChainACN != null){
                envelope.addChildElement('ChainACN', null, null).addTextNode(requestObject.ChainACN);
             }else{
                envelope.addChildElement('ChainACN', null, null);
             }
             if(requestObject.ChainName != null){
                envelope.addChildElement('ChainName', null, null).addTextNode(requestObject.ChainName);
             }else{
                envelope.addChildElement('ChainName', null, null);
             }
             if(requestObject.Model != null){
                envelope.addChildElement('Model', null, null).addTextNode(requestObject.Model);
             }else{
                envelope.addChildElement('Model', null, null);
             }
             if(requestObject.Platform != null){
                envelope.addChildElement('Platform', null, null).addTextNode(requestObject.Platform);
             }else{
                envelope.addChildElement('Platform', null, null);
             }

             if(requestObject.SourceSystem != null){
                envelope.addChildElement('SourceSystem', null, null).addTextNode(requestObject.SourceSystem);
             }else{
                envelope.addChildElement('SourceSystem', null, null);
             }

             if(requestObject.HideWater != null){
                envelope.addChildElement('HideWater', null, null).addTextNode(requestObject.HideWater);
             }else{
                envelope.addChildElement('HideWater', null, null);
             }
             if(requestObject.Validfill != null){
                envelope.addChildElement('Validfill', null, null).addTextNode(requestObject.Validfill);
             }else{
                envelope.addChildElement('Validfill', null, null);
             }

             if(requestObject.CEEnabled != null){
                envelope.addChildElement('CEEnabled', null, null).addTextNode(requestObject.CEEnabled);
             }else{
                envelope.addChildElement('CEEnabled', null, null);
             }

             /*if(requestObject.FavoriteOrMix != null){
                envelope.addChildElement('FavoriteOrMix', null, null).addTextNode(requestObject.FavoriteOrMix);
             }else{
                envelope.addChildElement('FavoriteOrMix', null, null);
             }*/

             if(requestObject.LTO != null){
                envelope.addChildElement('LTO', null, null).addTextNode(requestObject.LTO);
             }else{
                envelope.addChildElement('LTO', null, null);
             }

             if(requestObject.PromoEnabled != null){
                envelope.addChildElement('PromoEnabled', null, null).addTextNode(requestObject.PromoEnabled);
             }else{
                envelope.addChildElement('PromoEnabled', null, null);
             }

             if(requestObject.AttributesSelected != null){
                envelope.addChildElement('AttributesSelected', null, null).addTextNode(requestObject.AttributesSelected);
             }else{
                envelope.addChildElement('AttributesSelected', null, null);
             }

             if(requestObject.AttributesNotSelected != null){
                envelope.addChildElement('AttributesNotSelected', null, null).addTextNode(requestObject.AttributesNotSelected);
             }else{
                envelope.addChildElement('AttributesNotSelected', null, null);
             }
             
             if(requestObject.operatingSystem != null){
                envelope.addChildElement('operatingSystem', null, null).addTextNode(requestObject.operatingSystem);
             }else{
                envelope.addChildElement('operatingSystem', null, null);
             }
         }
         String returnStr;
         if(doc.toXmlString().indexOf('xml version') != -1){
            returnStr = doc.toXmlString().replace('<?xml version="1.0" encoding="UTF-8"?>', '');
         }
         return returnStr;
    }
}