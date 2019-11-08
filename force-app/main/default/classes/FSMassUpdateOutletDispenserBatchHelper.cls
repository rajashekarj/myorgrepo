/*********************************************************************************************************
Name         : FSMassUpdateOutletDispenserBatchHelper 
Created By   : Infosys Limited 
Created Date : 17-Feb-2017
Usage        : Helper for Batch class (FSMassUpdateOutletDispenserBatch) which is used for updating post Install attributes 
               on Outlet Dispenser records

***********************************************************************************************************/
public without sharing class FSMassUpdateOutletDispenserBatchHelper{
    private final static Object NULLCONSTANT=NULL;
    private final static Integer ONE=1;
    private static final String DATEVALIDATIONERRORMESSAGE='No past effective date should be used OR the effective date should be current or a future date';
    private static final String DATEREQUIREDERRORMESSAGE='Effective Date is mandatory if attributes are provided';
    private static final String VALUEREQUIREDERRORMESSAGE='Attributes are mandatory if effective date is provided';
    /** @Desc find sthe salesforce record Id of brandset records 
      * @param Set<String> brandsetNames
      * @return Map<String,Id>
      */
    
    public static Map<String,Id> retrieveBrandsetIds(Set<String> brandsetNames){
      Map<String,Id> brandsetNameAndIdMap =new Map<String,Id>();
      for(FS_Brandset__c brandset : [SELECT Id,Name FROM FS_Brandset__c WHERE Name IN:brandsetNames]){
          brandsetNameAndIdMap.put(brandset.Name,brandset.Id);
      }
      return brandsetNameAndIdMap;
    }                                                                 
    
    
    /** @Desc find sthe salesforce record Id of Installation records 
      * @param Set<String> installationNames
      * @return Map<String,Id>
      */
    
    public static Map<String,Id> retrieveInstallationIds(Set<String> installationNames){
      Map<String,Id> installationNameAndIdMap =new Map<String,Id>();
      for(FS_Installation__c installation : [SELECT Id,Name FROM FS_Installation__c WHERE Name IN:installationNames]){
          installationNameAndIdMap.put(installation.Name,installation.Id);
      }
      return installationNameAndIdMap ;
    } 
    
    
    /** @Desc find sthe salesforce record Id of dispensers in context
      * @param Set<FS_Outlet_Dispenser__c> setOfSerialNumber, List<FS_Outlet_Dispenser__c> dispensersList
      * @return List<FS_Outlet_Dispenser__c>
      */
    
    public static List<FS_Outlet_Dispenser__c> dispensersWithIdsList(Set<String> setOfSerialNumber
                                                                     ,List<FS_Outlet_Dispenser__c> dispensersList){

         List<FS_Outlet_Dispenser__c> dispensersToValidateList=new  List<FS_Outlet_Dispenser__c>(); 
         Map<String,FS_Outlet_Dispenser__c> serialNumberAndRecord=new Map<String,FS_Outlet_Dispenser__c>();
         
         
         for(FS_Outlet_Dispenser__c  dispenserObj :dispensersList){
         
            serialNumberAndRecord.put(dispenserObj.FS_Serial_Number2__c,dispenserObj); 
            Map<String, Object> fieldsToValue = dispenserObj.getPopulatedFieldsAsMap();
            
            
         }
         
         String dispenserQuery='SELECT FS_Outlet__r.ShippingCity,FS_ACN_NBR__c,Ownership_Type__c, FS_outlet__r.Bottler_Name__c,FS_7000_Series_Hide_Water_Effective_Date__c,FS_7000_Series_Brands_Option_Selections__c, FS_outlet__r.id, FS_Outlet__r.Name,';
         dispenserQuery+='FS_outlet__r.ShippingCountry,FS_Soft_Ice_Manufacturer__c, FS_TimeZone__c,FS_Soft_Ice_Adjust_Flag__c,FS_Dispenser_Type2__c, FS_Outlet__r.FS_Chain__r.Name, FS_Outlet__r.FS_Headquarters__r.Name, FS_outlet__r.FS_Headquarters__r.FS_ACN__c,';
         dispenserQuery+='FS_LTO_New__c ,FS_LTO_Effective_Date__c,Brand_Set_New__c,Brand_Set__c,Brand_Set_Effective_Date__c ,Brands_Not_Selected__c, FS_7000_Series_Hide_Water_Button_New__c,';
         dispenserQuery+='FS_Water_Button_New__c ,IC_Code__c, FS_Water_Hide_Show_Effective_Date__c , FS_CE_Enabled_New__c, FS_CE_Enabled_Effective_Date__c,FS_Dasani_New__c ,FS_Dasani_Settings_Effective_Date__c,';
         dispenserQuery+='FS_FAV_MIX_New__c ,FS_FAV_MIX_Effective_Date__c,FS_Promo_Enabled_New__c , FS_Promo_Enabled_Effective_Date__c ,FS_Spicy_Cherry_New__c ,FS_Spicy_Cherry_Effective_Date__c,FS_Valid_Fill_New__c ,';
         dispenserQuery+='FS_Valid_Fill_Settings_Effective_Date__c, FS_7000_Series_Static_Selection_New__c,FS_Brand_Selection_Value_Effective_Date__c,FS_7000_Series_Agitated_Selections_New__c,FS_7000_Series_Brands_Selection_New__c,FS_Outlet__r.ShippingState, ';
         dispenserQuery+='FS_Outlet__r.ShippingStreet, FS_Outlet__r.FS_ACN__c, FS_Outlet__r.ShippingPostalCode,FS_Outlet__r.FS_Chain__r.FS_ACN__c, FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,FS_Code__c, ';
         dispenserQuery+='FS_Serial_Number2__c,Installation__r.FS_Spicy_Cherry__c, FS_SAP_ID__c, Installation__r.FS_Valid_fill_required__c, ';
         dispenserQuery+='FS_Spicy_Cherry__c,FS_Equip_Type__c,Installation__r.FS_Original_Install_Date__c,FS_Equip_Sub_Type__c,FS_Country_Key__c,FS_Planned_Install_Date__c, Planned_Remove_Date__c,FS_7000_Series_Hide_Water_Button__c,FS_Water_Button__c,FS_Valid_Fill__c,';
         dispenserQuery+='FS_CE_Enabled__c,FS_FAV_MIX__c,FS_LTO__c,FS_Promo_Enabled__c, FS_Migration_to_AW_Required__c, FS_Pending_Migration_to_AW__c, FS_Migration_to_AW_Complete__c, RecordTypeId ';
         dispenserQuery +='FROM FS_Outlet_Dispenser__c  WHERE FS_IsActive__c=true AND FS_Serial_Number2__c IN:setOfSerialNumber '; 
              
         //Fetch record details for valid serial Numbers provided in the file 
         for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Database.query(dispenserQuery)){
         
             if(serialNumberAndRecord.containsKey(dispenserObj.FS_Serial_Number2__c)){
               FS_Outlet_Dispenser__c dispenserFromCsv=serialNumberAndRecord.get(dispenserObj.FS_Serial_Number2__c);
               Map<String, Object> fieldsToValue = dispenserFromCsv.getPopulatedFieldsAsMap();
               //Map record Id and other values to records from csv
               for(String fieldName : fieldsToValue.keySet()){
                   if(dispenserFromCsv.get(fieldName)!= NULLCONSTANT){
                    dispenserObj.put(fieldName,dispenserFromCsv.get(fieldName)); 
                   }                 
               }
               dispensersToValidateList.add(dispenserObj);   
             } 
                                               
         }
         
        
      return dispensersToValidateList;
     
    }
    
    //Method to validate effective dates for dispensers
    public static Map<Id,String> validateEffectiveDates( List<FS_Outlet_Dispenser__c> dispensersToUpdateList){
      //Collection to hold dispenser record Id and validation error message
      Map<Id,String> recordIdAndValidationErrorMessage=new  Map<Id,String>();
      
      Date todaysDate=Date.today();
      
      
      //Iterate over dispensers with valid serial numbers
      for(FS_Outlet_Dispenser__c dispenserObj : dispensersToUpdateList){
         
        //Step 1: Validation for Effective Dates earlier than today's Date       
        if((dispenserObj.FS_CE_Enabled_Effective_Date__c!=NULLCONSTANT && dispenserObj.FS_CE_Enabled_Effective_Date__c < todaysDate) 
          // || (dispenserObj.FS_FAV_MIX_Effective_Date__c!=nullConstant && dispenserObj.FS_FAV_MIX_Effective_Date__c < todaysDate)
           || (dispenserObj.FS_LTO_Effective_Date__c!=NULLCONSTANT && dispenserObj.FS_LTO_Effective_Date__c < todaysDate)
           || (dispenserObj.FS_Promo_Enabled_Effective_Date__c!=NULLCONSTANT && dispenserObj.FS_Promo_Enabled_Effective_Date__c < todaysDate)
           || (dispenserObj.FS_7000_Series_Hide_Water_Effective_Date__c!=NULLCONSTANT && dispenserObj.FS_7000_Series_Hide_Water_Effective_Date__c < todaysDate)
           || (dispenserObj.FS_Water_Hide_Show_Effective_Date__c!=NULLCONSTANT && dispenserObj.FS_Water_Hide_Show_Effective_Date__c < todaysDate)
           || (dispenserObj.FS_Dasani_Settings_Effective_Date__c!=NULLCONSTANT && dispenserObj.FS_Dasani_Settings_Effective_Date__c < todaysDate)
           || (dispenserObj.FS_Valid_Fill_Settings_Effective_Date__c!=NULLCONSTANT && dispenserObj.FS_Valid_Fill_Settings_Effective_Date__c < todaysDate)
           || (dispenserObj.FS_Brandset_Effective_Date__c!=NULLCONSTANT && dispenserObj.FS_Brandset_Effective_Date__c < todaysDate)){
              
            recordIdAndValidationErrorMessage.put(dispenserObj.Id,DATEVALIDATIONERRORMESSAGE);
        }
        
        //Step 2: Validation for Attributes when Effective Date is provided
        if(((dispenserObj.FS_Brandset_Effective_Date__c!=NULLCONSTANT && String.isBlank(dispenserObj.FS_Brandset_New__c))
            || (dispenserObj.FS_Dasani_Settings_Effective_Date__c!=NULLCONSTANT && String.isBlank(dispenserObj.FS_Dasani_New__c))
            || (dispenserObj.FS_7000_Series_Hide_Water_Effective_Date__c!=NULLCONSTANT && String.isBlank(dispenserObj.FS_7000_Series_Hide_Water_Button_New__c)) 
            || (dispenserObj.FS_Water_Hide_Show_Effective_Date__c!=NULLCONSTANT && String.isBlank(dispenserObj.FS_Water_Button_New__c))
            || (dispenserObj.FS_CE_Enabled_Effective_Date__c!=NULLCONSTANT && String.isBlank(dispenserObj.FS_CE_Enabled_New__c))
            //|| (dispenserObj.FS_FAV_MIX_Effective_Date__c!=nullConstant)
            || (dispenserObj.FS_LTO_Effective_Date__c!=NULLCONSTANT && String.isBlank(dispenserObj.FS_LTO_New__c))
            || (dispenserObj.FS_Promo_Enabled_Effective_Date__c!=NULLCONSTANT && String.isBlank(dispenserObj.FS_Promo_Enabled_New__c))
            || (dispenserObj.FS_Valid_Fill_Settings_Effective_Date__c!=NULLCONSTANT && String.isBlank(dispenserObj.FS_Valid_Fill_New__c)))
            && !recordIdAndValidationErrorMessage.containsKey(dispenserObj.Id)){
                 recordIdAndValidationErrorMessage.put(dispenserObj.Id,VALUEREQUIREDERRORMESSAGE);
        }
            
        //Step 2: Validation for Effective Dates  when attributes are provided  
        if(((dispenserObj.FS_CE_Enabled_Effective_Date__c==NULLCONSTANT && String.isNotBlank(dispenserObj.FS_CE_Enabled_New__c)) 
          // || (dispenserObj.FS_FAV_MIX_Effective_Date__c==nullConstant)
           || (dispenserObj.FS_LTO_Effective_Date__c==NULLCONSTANT && String.isNotBlank(dispenserObj.FS_LTO_New__c))
           || (dispenserObj.FS_Promo_Enabled_Effective_Date__c==NULLCONSTANT && String.isNotBlank(dispenserObj.FS_Promo_Enabled_New__c))
           || (dispenserObj.FS_7000_Series_Hide_Water_Effective_Date__c==NULLCONSTANT && String.isNotBlank(dispenserObj.FS_7000_Series_Hide_Water_Button_New__c))
           || (dispenserObj.FS_Water_Hide_Show_Effective_Date__c==NULLCONSTANT && String.isNotBlank(dispenserObj.FS_Water_Button_New__c))
           || (dispenserObj.FS_Dasani_Settings_Effective_Date__c==NULLCONSTANT && String.isNotBlank(dispenserObj.FS_Dasani_New__c))
           || (dispenserObj.FS_Valid_Fill_Settings_Effective_Date__c==NULLCONSTANT && String.isNotBlank(dispenserObj.FS_Valid_Fill_New__c))
           || (dispenserObj.FS_Brandset_Effective_Date__c==NULLCONSTANT && String.isNotBlank(dispenserObj.FS_Brandset_New__c)))
           && !recordIdAndValidationErrorMessage.containsKey(dispenserObj.Id)){
                recordIdAndValidationErrorMessage.put(dispenserObj.Id,DATEREQUIREDERRORMESSAGE);            
        }
          
      }
      return recordIdAndValidationErrorMessage;
    }
    
    
    /** @Desc create csv file for all failed records and send email to user who started the batch process
      * @param List<FS_Outlet_Dispenser__c> failedRecords, Map<Id,String> recordIdAndErrorMessage,Map<Id,String> recordIdAndFieldErrors
      * @return void
      */
    
    public static void formCSVfileForFailedRecords(Id holderId, List<FS_Outlet_Dispenser__c> failedRecords,
                                                   Map<Id,String> recordIdAndErrorMessage,
                                                   String csvFileName,Integer totalBatches){
      String csvAsString;
      String csvHeader = 'Id,SerialNumber,Outlet ACN,ErrorMessage\n';
      for(FS_Outlet_Dispenser__c failedRecord : failedRecords){
          if(totalBatches==ONE){
             String hyperLinkedRecord=createHyperlinkedColumData(failedRecord.Id);
             csvHeader +=hyperLinkedRecord+','+failedRecord.FS_Serial_Number2__c+','+failedRecord.FS_ACN_NBR__c+ ','+recordIdAndErrorMessage.get(failedRecord.Id)+'\n';
          }
          else{
             csvHeader +=failedRecord.Id+','+failedRecord.FS_Serial_Number2__c+','+failedRecord.FS_ACN_NBR__c+ ','+recordIdAndErrorMessage.get(failedRecord.Id)+'\n';
          }
      }
      csvAsString=csvHeader;
            
      Blob csvBlob = Blob.valueOf(csvAsString);
      
      createSuccessFailureAttachments(csvFileName,holderId,csvBlob );
     
    }
    
    public static void formCSVfileForSuccessRecords(Id holderId, List<FS_Outlet_Dispenser__c> successRecords,
                                                    String csvFileName,Integer totalBatches){
      String csvAsString;
      String csvHeader = 'Id,SerialNumber,Outlet ACN\n';
      for(FS_Outlet_Dispenser__c successRecord : successRecords){
          if(totalBatches==ONE){
             String hyperLinkedRecord=createHyperlinkedColumData(successRecord.Id);
             csvHeader +=hyperLinkedRecord+','+successRecord.FS_Serial_Number2__c+','+successRecord.FS_ACN_NBR__c +'\n';
          }
          else{
             csvHeader +=successRecord.Id+','+successRecord.FS_Serial_Number2__c+','+successRecord.FS_ACN_NBR__c +'\n';
          }    
          
      }
      csvAsString=csvHeader;
            
      Blob csvBlob = Blob.valueOf(csvAsString);
      
      createSuccessFailureAttachments(csvFileName,holderId,csvBlob);
      
    }
    
     public static String createHyperlinkedColumData(String columnData){
       String urltext=URL.getSalesforceBaseUrl().toExternalForm() + '/' + columnData;
       String hyperLinkedRecord='=HYPERLINK('+'"'+ urltext+'"'+','+'"'+ columnData+'"'+')';
       hyperLinkedRecord=hyperLinkedRecord.escapeCsv();
      return  hyperLinkedRecord;
    }
    
    public static void createSuccessFailureAttachments(String csvFileName,Id holderId,Blob csvBlob){
       Attachment attch =new Attachment();
       attch.body = csvBlob ;
       attch.parentId = holderId;
       attch.Name=csvFileName; 
      insert attch;
    }
    
}