/********************************************************************************************************* 
Name         : FSUtil
Created By   : Pallavi Sharma (Appiro)
Created Date : 23 - Sep - 2013
Usage        : Utility class for common code
Modified By	 : Venkat-- EDO2 Project
Modified By	 : Venkat-- FET 5.0 Project
***********************************************************************************************************/
public with sharing class FSUtil {       
    
    public static Map<String , Schema.DescribeSObjectResult> mapSobjDescribe ;     
     Public static list<FS_Outlet_Dispenser__c> odList;
    /*** @desc Method to prepares select query for object types, 
     			pulls all fields using describe Calls		 
		 * @param String objectType- Name of the Object
		 * @return String
		 */    
    public static String getSelectQuery(final String objectType){
        String csv = FSConstants.BLANKVALUE;
        for(String field : Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap().keyset()){
            csv += field + ',';
        }
        csv = csv.substring(0, csv.lastIndexOf(','));
        return 'Select ' + csv + ' From ' + objectType;
    }
    
    /*** @desc Method to get Id of an Email Template		 
		 * @param String templateName- Name of the Email Template
		 * @return Id
		 */  
    public static Id getEmailTemplateId(final String templateName){
        Id tempId;
        List<EmailTemplate> emailTempList=new List<EmailTemplate>();
        //checks Template name is null or not
        if(isNotNullOrBlank(templateName)){
            emailTempList=[Select Id From EmailTemplate where DeveloperName = :templateName LIMIT 1];
        }
        //for(EmailTemplate eTemp:emailTempList){
        if(!emailTempList.isEmpty()){
            tempId =  emailTempList[0].Id;             
        }
        return tempId;
    }
    
    //----------------------------------------------------------------------------------------------------------------
    //Method to update field value in any sObject
    //Param : sObject sObj -> sObject instanse for which value need to be updated
    //Param : String sObjectName -> sObject Name 
    //Param : String field -> sObject Field Name in which value need to be updated
    //Param : object value -> value for field
    //----------------------------------------------------------------------------------------------------------------
    public static void putValueInField(final sObject sObj, final String sObjectName ,final String field,final object value){
        if(mapSobjDescribe == FSConstants.NULLVALUE ){
            mapSobjDescribe = new Map<String , Schema.DescribeSObjectResult>();
        }
        if(!mapSobjDescribe.containsKey(sObjectName)){
            final Schema.DescribeSObjectResult sobjectDescribe = FSConstants.GLOBAL_MAP.get(sObjectName).getDescribe();
            mapSobjDescribe.put(sObjectName ,sobjectDescribe );
        }
        final Map<String, Schema.SObjectField> fieldMap = mapSobjDescribe.get(sObjectName).fields.getMap();
        final Schema.Describefieldresult fieldDescribe = fieldMap.get(field).getDescribe();
        final Boolean isUpdate = fieldDescribe.isUpdateable() ? true : false;
        final Boolean isCreate = sObj.Id == FSConstants.NULLVALUE && fieldDescribe.isCreateable() ? true : false;
        if( isUpdate || isCreate) {
            sObj.put(field , value);
        }        
    }
     /*** @desc Method to Check Access level on operation of user on Specified Object		 
		 * @param String sObjectName- Name of the object
		 * @param String accessName- Name of the Access 
		 * @return Boolean
		 */     
    public static Boolean checkAccessForSobject(final String sObjectName , final String accessName){
        Boolean isAccessible; 
        final Schema.DescribeSObjectResult sobjectDescribe = FSConstants.GLOBAL_MAP.get(sObjectName).getDescribe();
        if(accessName.equals( FSConstants.ACCESS_IS_CREATABLE)){
            isAccessible = sobjectDescribe.isCreateable();
        }
        else if(accessName.equals( FSConstants.ACCESS_IS_DELETABLE)){
            isAccessible = sobjectDescribe.isDeletable();
        }
        else if(accessName.equals( FSConstants.ACCESS_IS_UPDATEABLE)){
            isAccessible = sobjectDescribe.isUpdateable();
        }
        else if(accessName.equals(FSConstants.ACCESS_IS_UNDELETABLE)){
            isAccessible = sobjectDescribe.isUndeletable();
        }
        return isAccessible;
    }
    
    /*** @desc Method checks wheather String is Blank/NULL		 
		 * @param String str- String value to be checked
		 * @return Boolean
		 */ 
    public static Boolean isNotNullOrBlank(final String str){
        Boolean blankCheck=false;
        if(str != FSConstants.NULLVALUE && str.trim() != FSConstants.BLANKVALUE ){
            blankCheck=true;
        }
        return blankCheck;
    }
    
    /*** @desc Method to convert a String value to decimal value		 
		 * @param String str- String value to be changed to decimal
		 * @return Decimal
		 */ 
    public static Decimal toDecimal(final String str){
        Decimal decValue;
        try{
            if(str != FSConstants.NULLVALUE && str.trim() != FSConstants.BLANKVALUE){
                decValue = Decimal.valueOf(str);
            }
        }
        catch(Exception ex){ decValue = FSConstants.DECIMALNULL; }
        return decValue;
    }
    
    /*** @desc Method to converts a decimal Value to String type 		 
		 * @param Decimal decValue- Decimal value to be changed to String
		 * @return String
		 */ 
    public static String decimalToString(final Decimal decValue){
        String strValue = FSConstants.BLANKVALUE;
        if(decValue != FSConstants.NULLVALUE){
            try{
                strValue = String.valueOf(decValue);
            }
            catch(Exception ex){ strValue = FSConstants.BLANKVALUE; }
        }
        return strValue;
    }
     /*** @desc Method to get Required Fields for Customer Input type object
		 * @return List<String>
		 */     
    public static List<String> lstRequiredFields{
        get{
            final List<String> lst= new List<String>();
            for(Schema.FieldSetMember field : Schema.getGlobalDescribe().get('FS_Customer_Input_Type__c').getDescribe().FieldSets.getMap().get('FS_Required_Fields').getFields()){
                lst.add(field.getFieldPath());
            }
            return lst;
        }
    }
    
    /*** @desc Method to Get Required Fields to display double astrik from Customer Input type object
		 * @return List<String>
		 */ 
    public static List<String> lstRequiredFieldsForDoubleAstrik{
        get{
            final List<String> lst = new List<String>();
            for(Schema.FieldSetMember field : Schema.getGlobalDescribe().get('FS_Customer_Input_Type__c').getDescribe().FieldSets.getMap().get('Required_Fields_Double_Astrik').getFields()){
                lst.add(field.getFieldPath());
            }
            return lst;
        }
    } 
    
     /*** @desc Method to Replace the special characters with Blank value in the String Passed 		 
		 * @param String input- String Value to perform the operation
		 * @return String
		 */     
    public static String cleanSpecialCharacters(final String input){
        final List<String> characterList=new List<String>
        {'|','?','*','\\',FSConstants.SLASH,'>','<',FSConstants.COLON,';',']','[','{','}','\'','"'};
        String retStr;
        if(input != FSConstants.NULLVALUE){
            retStr = input;
            for(String specChar:characterList){
                if(specChar==FSConstants.SLASH){
                	retStr = retStr.replace(FSConstants.SLASH,FSConstants.HYPHEN);  
                }
                else{
                    retStr = retStr.replace(specChar,' ');
                }
            }
        }
        return retStr;
    }
    
    /*** @desc Method to Sent the report after the Batch process Complete	 
		 * @param Database.BatchableContext batchContext- Batch context object value		 
		 */  
    public static void sendBatchReport(final Database.BatchableContext batchContext) {
        final AsyncApexJob apexJob = 
            [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
             TotalJobItems, ApexClass.name, CreatedBy.Email
             FROM AsyncApexJob WHERE Id = :batchContext.getJobId()];
        
        // Send an email to the Apex job's submitter        
        //   notifying of job completion. 
        final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        final String[] toAddresses = new String[] {apexJob.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch:' + apexJob.ApexClass.name + ', MarketId Realignment, Status: ' + apexJob.Status);
        mail.setPlainTextBody('The Batch job processed ' + apexJob.TotalJobItems + ' batches with ' + apexJob.NumberOfErrors + ' errors');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }    
    
    /*** @desc Method to Insert List of records records with Error logger functionality
		 * @param List<Sobject> sObjectList- List of records of Sobject type
		 * @param Boolean allOrNone- Boolean Value to give true/false value while performing Insert
		 * @param Apex_Error_Log__c errorrec- Apex error logger object record to provide Parameters
		 * @return Boolean
		 */    
    public static Boolean dmlProcessorInsert(final List<Sobject> sObjectList,final Boolean allOrNone,
                                             final Apex_Error_Log__c errorRec){
    	Boolean success=false;
       try{
        	System.Database.insert(sObjectList,allOrNone);
            success=true;
        }
        catch(DMLException dmlExp){
       		 ApexErrorLogger.addApexErrorLog(errorRec.Application_Name__c,errorRec.Class_Name__c, errorRec.Method_Name__c,
                                             errorRec.Object_Name__c,errorRec.Error_Severity__c,dmlExp,dmlExp.getMessage());
        
        }       
        return success;
	}
    
    /*** @desc Method to Update List of records records with Error logger functionality
		 * @param List<Sobject> sObjectList- List of records of Sobject type
		 * @param Boolean allOrNone- Boolean Value to give true/false value while performing Update
		 * @param Apex_Error_Log__c errorrec- Apex error logger object record to provide Parameters
		 * @return Boolean
		 */
    public static Boolean dmlProcessorUpdate(final List<Sobject> sObjectList,final Boolean allOrNone,
                                             final Apex_Error_Log__c errorRec){
    	Boolean success=false;
        try{
        	System.Database.update(sObjectList,allOrNone);
            success=true;
         }
        catch(DMLException dmlExp){
        	ApexErrorLogger.addApexErrorLog(errorRec.Application_Name__c,errorRec.Class_Name__c, errorRec.Method_Name__c,
                                             errorRec.Object_Name__c,errorRec.Error_Severity__c,dmlExp,dmlExp.getMessage());
         }        
        return success;
	}
    
    /*** @desc Method to Upsert List of records records with Error logger functionality
		 * @param List<Sobject> sObjectList- List of records of Sobject type
		 * @param Boolean allOrNone- Boolean Value to give true/false value while performing Upsert
		 * @param Apex_Error_Log__c errorrec- Apex error logger object record to provide Parameters
		 * @return Boolean
		 */
    public static Boolean dmlProcessorUpsert(final List<Sobject> sObjectList,final Boolean allOrNone,
                                             final Apex_Error_Log__c errorRec){
    	Boolean success=false;
        try{
            System.Database.upsert(sObjectList,allOrNone);
            success=true;
         }
        catch(DMLException dmlExp){
            ApexErrorLogger.addApexErrorLog(errorRec.Application_Name__c,errorRec.Class_Name__c, errorRec.Method_Name__c,
                                             errorRec.Object_Name__c,errorRec.Error_Severity__c,dmlExp,dmlExp.getMessage());
         }        
        return success;
	}
    
    /*** @desc Method to Delete List of records records with Error logger functionality
		 * @param List<Sobject> sObjectList- List of records of Sobject type
		 * @param Boolean allOrNone- Boolean Value to give true/false value while performing Delete
		 * @param Apex_Error_Log__c errorrec- Apex error logger object record to provide Parameters
		 * @return Boolean
		 */
    public static Boolean dmlProcessorDelete(final List<Sobject> sObjectList,final Boolean allOrNone,
                                             final Apex_Error_Log__c errorRec){
     	Boolean success=false;
        try{
        	System.Database.delete(sObjectList,allOrNone);
            success=true;
          }
         catch(DMLException dmlExp){
             ApexErrorLogger.addApexErrorLog(errorRec.Application_Name__c,errorRec.Class_Name__c, errorRec.Method_Name__c,
                                             errorRec.Object_Name__c,errorRec.Error_Severity__c,dmlExp,dmlExp.getMessage());           
          }        
         return success;
	}
        
    /** @desc returns the map of Recordtype Name and Id as key and value for provided Object
	  * @param SObjectType $sObjectType- salesforce ObjectApi
	  * @return return Map<String,Id> 
	*/
    public static Map<String,Id>  getObjectRecordTypeNameAndId(final SObjectType sObjectType){
        final Map<String,Id> mapRecTypeNameId = new Map<String,Id>();
        //Generate a map of tokens for all the Record Types for the desired object
        final Map<String,Schema.RecordTypeInfo> rtMapByName = sObjectType.getDescribe().getRecordTypeInfosByName();
        for(Schema.RecordTypeInfo recInfo  : rtMapByName.values()){
            mapRecTypeNameId.put(recInfo.getName(),recInfo.getRecordTypeId());
        }
        //Retrieve the record type id by name
        return mapRecTypeNameId;
    }
    
    
    /** @desc returns the map of Recordtype Id and name as key and value for provided Object
	  * @param SObjectType $sObjectType- salesforce ObjectApi
	  * @return return Map<Id,String> 
	*/
    public static Map<Id,String>  getObjectRecordTypeIdAndNAme(final SObjectType sObjectType){
        final Map<Id,String> mapRecTypeIdName = new Map<Id,String>();
        //Generate a map of tokens for all the Record Types for the desired object
        final Map<String,Schema.RecordTypeInfo> rtMapByName = sObjectType.getDescribe().getRecordTypeInfosByName();
        for(Schema.RecordTypeInfo recInfo  : rtMapByName.values()){
            mapRecTypeIdName.put(recInfo.getRecordTypeId(),recInfo.getName());
        }
        //Retrieve the record type id by name
        return mapRecTypeIdName;
    }
    
    /** @desc return recordTypeId based on object and RecordTypeName
	  * @param SObjectType $sObjectType- salesforce ObjectApi
	  * @param String $recordTypeName- object RecordType Name
	  * @return Id 
	*/
    public static Id getObjectRecordTypeId(final SObjectType sObjectType,final String recordTypeName){
        //Generate a map of tokens for all the Record Types for the desired object
        final Map<String,Schema.RecordTypeInfo> rtMapByName = sObjectType.getDescribe().getRecordTypeInfosByName();
        //Retrieve the record type id by name
        return rtMapByName.get(recordTypeName).getRecordTypeId();
    }
    
    /*** @desc appends zeroes to left of a string
		* @param String $originalString- input string to be appended with zero
		* @param Integer $length- number of position to be padded with zero
		* @return String
	*/ 
    public static String leftPadWithZeroes(final String originalString,final Integer length) {
        String paddedString = originalString;
        if(isNotNullOrBlank(originalString)){
            while (paddedString.length() < length) {
                paddedString = '0' + paddedString;
            }
        }
        return paddedString;
    } 
    
    
    /* ** @Description -parses the string to Date 
     	* @param String dateTimeString- String value to convert to Date value  	
		* @Return - Date
	*/
    public static Date dateParserHelper(final String dateTimeString){
        String year;
        String month;
        String day;
        String hour='00';
        String minute='00';        
        String[] dateString;
        String[] timeString;
        Date parsedDate=FSConstants.DATE_NULL;
        Boolean conditionCheck=true;
        try{
            if(dateTimeString!=null && dateTimeString !=FSConstants.BLANKVALUE){
                final String[] datetimeSplit=dateTimeString.split(' ');
                if(datetimeSplit!=FSConstants.NULLVALUE && datetimeSplit.size()>1){
                    dateString=datetimeSplit[0].Split(FSConstants.SLASH);
                    timeString=datetimeSplit[1].Split(FSConstants.COLON);
                    final Integer yearInt=Integer.valueOF(dateString[2]);
                    if(dateString[2].length()==4  && yearInt>1700 && yearInt<4000){
                        year=dateString[2];                        
                    }else { conditionCheck=false; } 
                    final Integer dayInt=Integer.valueOF(dateString[1]);
                    if(conditionCheck && dateString[1].isNumeric() && dayInt<=31 && dayInt>0){
                        day = dateString[1];
                    }else{ conditionCheck=false;   }
                    final Integer monthInt=Integer.valueOF(dateString[0]);
                    if(conditionCheck && dateString[0].isNumeric() && monthInt<=12 && monthInt>0){
                        month = dateString[0];
                    }else{ conditionCheck=false;    }    
                    if(conditionCheck && timeString[0].isNumeric() && timeString[1].isNumeric()){                                            
                        hour=timeString[0];
                        minute =timeString[1];
                    }
                }else{
                    dateString=dateTimeString.Split(FSConstants.SLASH);
                    year = dateString[2];
                    month = dateString[0];
                    day = dateString[1];                                        
                }
                if(conditionCheck){
                    final String stringDateTime = year + FSConstants.HYPHEN + month + FSConstants.HYPHEN + day + ' ' + hour + FSConstants.COLON 
                        + minute +  FSConstants.COLON + '00';
                    final String stringDate =  year + FSConstants.HYPHEN + month + FSConstants.HYPHEN + day;
                    parsedDate=Date.valueof(stringDate); 
                }
            }
        }catch(Exception ex){
        } 
        return parsedDate;
    }
    
    /*** @Description -send mail to with an attachment
     * @param Boolean hasAttachment- value to check mail has attachment or Not
     * @param List<Attachment> attachmentList- List of Attchments to send with the Mail
     * @param String subject - subject of the email
     * @Param String emailbody- body of the Email
     * @List<String> recepients- List of recepients that mail should sent
		* @Return - Boolean
	*/
    public static Boolean sendMail(final Boolean hasAttachment,final List<Attachment> attachmentList,
                                   final String subject,final String emailBody,final List<String> recepients) {
        
        final Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setToAddresses( recepients );
        mail.setPlainTextBody(emailBody);
        
        // Create the email attachment 
        final List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
        Messaging.EmailFileAttachment attachment=null;
        if(hasAttachment){
            for(Attachment file : attachmentList){
                attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(file.Name);
                attachment.setBody(file.Body);
                efaList.add(attachment);
            } 
            mail.setFileAttachments(efaList); 
        }       
        final Messaging.SendEmailResult [] res = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        return res[0].isSuccess();
    }
    
    /* ** @Description -returns describe information for a SObject
     * @param SObjectType sObjType- sobject api name
		* @Return - Schema.DescribeSObjectResult
	*/
    public static Schema.DescribeSObjectResult getDescribeResultForSobject(final SObjectType sObjType){
        return sObjType.getDescribe();
    }
    
    /* ** @Description -returns picklist values for a field for a SObject
     * @param SObjectType sObjType- sobject name
     * @param String fieldAPIName- field API name 
		* @Return -  List<Schema.PicklistEntry>
	*/
    public static List<Schema.PicklistEntry> getFieldPicklistValues(final SObjectType sObjType,final String fieldAPIName){
        
        final Schema.DescribeSObjectResult sObjectResult=sObjType.getDescribe();        
        final Schema.DescribeFieldResult fieldResult=sObjectResult.fields.getMap().get(fieldAPIName).getDescribe();        
        return fieldResult.getPicklistValues();        
    }
    
    
    /*** @Description -returns number of rows in csv file including the header
     * @param Blob csvFile- CSV file
		* @Return - Integer 
	*/
    public static Integer calculateNumberOfRowsInCSVFile(final Blob csvFile){
        final String csvAsString=csvFile.toString(); 
        final String[] numberOfrows=csvAsString.split('\n');
        return numberOfrows.size();
    }
    
   /*** @Description -method will send an Email
     * @param String subject - subject of the email
     * @Param String emailbody- body of the Email
     * @param Boolean htmlBody-condition to place HTML body in the email or Plain text body
     * @List<String> recepientsEmail- List of recepients that mail should sent
		* @Return - Messaging.SingleEmailMessage
	*/
    public static Messaging.SingleEmailMessage sendEmail(final List<String> recepientsEmail,final String subject,
                                                         final String body,final Boolean htmlBody){
        final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        if(!recepientsEmail.isEmpty()){ 
            mail.setToAddresses(recepientsEmail); 
        }    
        mail.setSubject(subject);     
        if(htmlBody){
            mail.setHtmlBody(body);
        }else{
            mail.setPlainTextBody(body);
        }   
        return mail;
    }
    // SO creation when SP needs to go out chnages to "YES"
  public static List<FS_Service_Order__c> createServiceOrder(list<String> outletZIPs,Map<ID,FS_Flavor_Change_Head__c> flavorChangeHeadOutletMap){
      
        //Integer zero=0;
        Integer five=5;
        string spYesString='Yes';
        odList=new list<FS_Outlet_Dispenser__c> ();
        //Creation of service orders based on spAlignedZip codes
        Map<String,FS_SP_Aligned_Zip__c> spAlignedZip7000SeriesBasesdOnZip=new Map<String,FS_SP_Aligned_Zip__c>();
        Map<String,FS_SP_Aligned_Zip__c> spAlignedZip8K9K91KSeriesBasesdOnZip=new Map<String,FS_SP_Aligned_Zip__c>();
    	Map<String,FS_SP_Aligned_Zip__c> spAlignedZip6K65KSeriesBasesdOnZip=new Map<String,FS_SP_Aligned_Zip__c>();
      
        //Form Collection based on ZipCode:
        for(FS_SP_Aligned_Zip__c sp7000 : FSServiceProviderHelper.get7000SPAlignedZip(outletZIPs)){
            spAlignedZip7000SeriesBasesdOnZip.put(sp7000.FS_Zip_Code__c,sp7000);
        }           
        for(FS_SP_Aligned_Zip__c sp8K9K91K : FSServiceProviderHelper.get80009000SPAlignedZip(outletZIPs)){
            spAlignedZip8K9K91KSeriesBasesdOnZip.put(sp8K9K91K.FS_Zip_Code__c,sp8K9K91K);
        }
      	for(FS_SP_Aligned_Zip__c sp6K65K : FSServiceProviderHelper.get60006050SPAlignedZip(outletZIPs)){
            spAlignedZip6K65KSeriesBasesdOnZip.put(sp6K65K.FS_Zip_Code__c,sp6K65K);
        }
        List<FS_Service_Order__c> serviceOrderList=new List<FS_Service_Order__c>();
        for(FS_Flavor_Change_Head__c FCOutletheader:[SELECT Id,FS_Outlet_Postal_ZIP__c,FS_SP_go_out__c,isWaterDasani__c from FS_Flavor_Change_Head__c WHERE  Id=:flavorChangeHeadOutletMap.values()]){
            if(FCOutletheader.FS_SP_go_out__c==spYesString){
                FS_Service_Order__c serviceOrder=new FS_Service_Order__c();
                serviceOrder.FS_Flavor_Change_Header__c=FCOutletheader.id;
                if(FCOutletheader.FS_Outlet_Postal_ZIP__c!=FSConstants.NULLVALUE){
                    String zipCode=FCOutletheader.FS_Outlet_Postal_ZIP__c;
                    if(zipcode.length() > five) {
                        zipCode = zipcode.substring(0,5);
                    }else{
                        zipCode = zipcode;
                    }
                    
                    if(spAlignedZip7000SeriesBasesdOnZip.containsKey(zipCode) && spAlignedZip7000SeriesBasesdOnZip.get(zipCode)!=null){
                        FS_SP_Aligned_Zip__c  spObj=spAlignedZip7000SeriesBasesdOnZip.get(zipCode);
                        serviceOrder.FS_Service_Provider__c=spObj.FS_Service_Provider__c;                    
                        serviceOrder.FS_Market_Activation_Date__c=spObj.FS_Selling_Market_Activation_Date__c;
                        serviceOrder.FS_Market__c=spObj.FS_Selling_Activity_Market__r.Name;
                        serviceOrder.FS_SP_Code__c=spObj.FS_SP_Code__c;
                    }
                    if(spAlignedZip8K9K91KSeriesBasesdOnZip.containsKey(zipCode) && spAlignedZip8K9K91KSeriesBasesdOnZip.get(zipCode)!=null){
                        FS_SP_Aligned_Zip__c  spObj=spAlignedZip8K9K91KSeriesBasesdOnZip.get(zipCode);
                        serviceOrder.FS_Other_Service_Provider__c=spObj.FS_Service_Provider__c;            
                        serviceOrder.FS_Other_Market_Activation_Date__c=spObj.FS_Selling_Market_Activation_Date__c;
                        serviceOrder.FS_Other_Market__c=spObj.FS_Selling_Activity_Market__r.Name;
                        serviceOrder.FS_Other_SP_Code__c=spObj.FS_SP_Code__c;
                    } 
                    if(spAlignedZip6K65KSeriesBasesdOnZip.containsKey(zipCode) && spAlignedZip6K65KSeriesBasesdOnZip.get(zipCode)!=null){
                        FS_SP_Aligned_Zip__c  spObj=spAlignedZip6K65KSeriesBasesdOnZip.get(zipCode);
                        serviceOrder.FS_New_Service_Provider__c=spObj.FS_Service_Provider__c;            
                        serviceOrder.FS_New_Market_Activation_Date__c=spObj.FS_Selling_Market_Activation_Date__c;
                        serviceOrder.FS_New_Market__c=spObj.FS_Selling_Activity_Market__r.Name;
                        serviceOrder.FS_New_SP_Code__c=spObj.FS_SP_Code__c;
                    } 
                }  
                serviceOrderList.add(serviceOrder);
            }
        }
      return serviceOrderList;
  }
    
     /*****************************************************************
  	Method: checkPlatformValues
  	Description: checkPlatformValues method to find to out the added values and removed values from a multi select picklist	
	New:Added this method as part of FET 4.0
	Modified:As part of FET 5.0 to make it generic for to find which values removed and which values added in picklist
	*******************************************************************/   
  
    public static Map<Set<String>,Set<String>> checkPlatformValues(final Id recordId,final String newValue,final String oldValue){
        
        final Set<String> oldPickSet=new Set<String>();
        final Set<String> newPickSet=new Set<String>();
        final Set<String> mainSet=new Set<String>();
        final Set<String> delSet=new Set<String>();
        
        List<String> newPickList=new List<String>();
        List<String> oldPickList=new List<String>();
        
        final Map<Set<String>,Set<String>> platformMap=new Map<Set<String>,Set<String>>();
        //Checking the new record platform value is NULL or not
        if(newValue!=FSConstants.NULLVALUE){
            //Splitting the picklist value with comma seperated
            newPickList=newValue.split(';');
            //Adding the All list values into a Set to remove duplicate values
            newPickSet.addAll(newPickList);
            //Checking the old record platform value is NULL or not
            if(oldValue!=FSConstants.NULLVALUE){
                //Splitting the picklist value with comma seperated
                oldPickList=oldValue.split(';');
                //Adding the All list values into a Set to remove duplicate values
                oldPickSet.addAll(oldPickList);
				//Iterating New List values and checking value present in Old value or not
                for(String pick:newPickList){                    
                    if(!oldPickSet.contains(pick)){
                        //storing platform values which are present in new List and Not in Old List
                        mainSet.add(pick);                        
                    }
                }
                //Iterating Old List values and checking value present in New value or not
                for(String old:oldPickList){
                    if(!newPickSet.contains(old)){
                        //storing platform values which are present in old List and Not in New List
                        delSet.add(recordId+old);                                    
                    }
                }
            }
            else{  
                //adding all values in main Set if Previous platform field is null
                mainSet.addAll(newPickList);               
            }
        }
        else{
            if(oldValue!=FSConstants.NULLVALUE){
                oldPickList=oldValue.split(';');
                //adding all values in del Set if New platform field is null
                for(String old:oldPickList){
                    delSet.add(recordId+old);
                } 
            }
        }
        //Storing the Mainset and Sel Set in Map and returing it back
        platformMap.put(mainSet,delSet);     
        return platformMap;        
    }
    
    /*** @desc returns Profile details for a profile  
		* @param String $profileName- name of the profile
		* @return Profile 
		*/
    public static String getProfileName(){
        Id profileId = UserInfo.getProfileId();
		String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        return profileName;
    } 
        /*** @desc returns User Id details for a 'FreeStyle Admin' User  
		* @param String $Id- Id of the User
		* @return User Id
		*/
    Public static Id getFreeStyleUserId(){
        Id freeStyleId;
        try{
         freeStyleId = [Select Id from User where Name=: Label.USER_NAME Limit 1].Id;
        }
        catch(Exception ex){ freeStyleId = FSConstants.ID_NULL;}
        return freeStyleId;
    }
    
}