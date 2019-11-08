/****************************************
Apex Class Name     : FSCIRelated_ListController
Version             : 1.0
Function            : This is a Controller class for FSCIRelated_List Component which will all the CIF on HQ Detail Page
Modification Log    :
* Developer         : Deepak Jetty   
* Date              : 15 Jan 2017               
******************************************/
public with sharing class FSCIRelated_ListController {
    private static final String BLANK='';
    private static final String STRING_NULL = null;
    private static final Integer INTEGER_NULL=null;
    private static final String DESCRIPTION = 'desc';
    public transient Schema.DescribeSObjectResult objectDescribe;
    public ApexPages.StandardSetController ssc {get; set;}
    public List<String> fieldNames {get; set;}
    public Map<String,String> fieldAlignMap {get; set;}
    public Map<String,String> nameLabelMap {get; set;}
    public Id deleteRecordId {get; set;}
    public String sortByField {get; set;}
    public Map<String,String> fieldSortDirectionMap {get; set;}
    public Integer pageNumber {get;set;}
    public String objectName {get; set;}
    public String fieldsCSV {get; set;}
    public List<String> fieldsList {get; set;}
    public String searchFieldName {get; set;}
    public String searchFieldValue {get; set;}
    public String filter {get; set;}
    public String orderByFieldName {get; set;}
    public String sortDirection {get; set;}
    public Integer pageSize {get; set;}
    public String title {get;set;}
    public String returnUrl {get;set;}
    public String moreLink {get;set;}
    public String showMoreLink {get;set;}
    public String isApprovedRecordLink {get;set;}
    public Boolean showAsStandardRelatedList {get;set;}
    
    public static object objNull()
    {return null;} 
    
    public ApexPages.StandardSetController apexSTDCntlr()
    {return null;}
    public List<sObject> getRecords(){
        if(ssc == apexSTDCntlr()){  
        //Do validation to ensure required attributes are set 
        //and attributes have correct values
        //fieldList or fieldsCSV must be defined
        Boolean validationPass = true;
        if(fieldsList== null && fieldsCSV == STRING_NULL){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'fieldList or fieldsCSV attribute must be defined.'));
            validationPass = false;
        }
        //Ensure sortDirection attribute has value of 'asc' or 'desc'
        if(sortDirection != STRING_NULL && sortDirection != 'asc' && sortDirection != DESCRIPTION){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'sortDirection attribute must have value of "asc" or "desc"'));
            validationPass = false;
        }
        
        //Proceed with returning the related list if validation passed
        if(!validationPass){
            return null;
        }else{
            //Build the query string dynamically
            String queryString = 'SELECT ';
            /*If field CSV was defined use this and also add fields to the fieldNames
            List so they can be used with Visualforce dynamic binding to define coloumns*/
            if(fieldsCSV != STRING_NULL){
                queryString += fieldsCSV;       
                fieldNames = fieldsCSV.split(',');
            }else{
                //Add fields to fieldNames list so it can be used with
                // VF dynamic binding to define coloumns
                fieldNames = fieldsList.clone();
                //Loop through list of field names in fieldList and add to query
                for(String fld : fieldsList){
                    queryString += fld + ',';
                }
                //Remove the very last comma that was added to the end
                // of the field selection part of the query string
                queryString = queryString.substring(0,queryString.length() - 1);
            }
           
            if(String.isBlank(searchFieldValue) && String.isBlank(filter)){
                queryString += ' FROM ' + objectName + ' LIMIT 0 ';
            }
            else{
                //add from object and parent criteria
                 String filterCriteria = BLANK; 
                queryString += ' FROM ' + objectName + ' WHERE ';
                if(!String.isBlank(isApprovedRecordLink))
                {
                   final String recordType ='FS Outlet';
                    final String strStatus  = 'Approved';
                  final List<ID> hqIDs = new List<ID>();
                    for(FS_Customer_Input__c fsCustInput : [Select ID FROM FS_Customer_Input__c WHERE FS_Account__r.RecordType.Name ='FS HeadQuarters' AND Status__c = :strStatus and FS_Account__c = :searchFieldValue.trim()])
                    {
                        hqIDs.add(fsCustInput.Id);
                    }
                    filterCriteria += 'FS_Account__r.RecordType.Name =:recordType  AND HQ_CIF__c IN : hqIDs';
                    queryString += filterCriteria;
                    filterCriteria ='';
                    searchFieldValue='';
                }
                
                
                if(String.isNotBlank(searchFieldValue)){
                    filterCriteria += searchFieldName + ' = \'' + searchFieldValue.trim() + '\'';
                }
                //Add any addtional filter criteria to query string if it was defined in component
               if(filter != null && filter.length() > 0 ){
                    filterCriteria += ( String.isBlank(filterCriteria) ? BLANK : ' AND ' ) + filter;             
                } 
                queryString += filterCriteria;
                //Add order by field to query if defined in component
                //If sortByField != null then user has clicked a header and sort by this field
                if(sortByField != STRING_NULL){
                    queryString += ' order by ' + sortByField;
                }else if(orderByFieldName != STRING_NULL){
                    queryString += ' order by ' + orderByFieldName;
                }
                //If sortByField != null then user has clicked a header,
                // sort based on values stored in map
                if(sortByField != STRING_NULL){
                    /*Use a map to store the sort direction for each field, on first click of header sort asc
                    and then alternate between desc*/
                    if(fieldSortDirectionMap == objNull()){
                        fieldSortDirectionMap = new Map<String,String>();                   
                    }
                    
                    String direction = BLANK;
                    
                    //check to see if field has direction defined, if not or it is asc, order by asc 
                    if(fieldSortDirectionMap.get(sortByField) == STRING_NULL || fieldSortDirectionMap.get(sortByField) == DESCRIPTION ){
                        direction = 'asc';
                        fieldSortDirectionMap.put(sortByField,'asc');
                    }else{
                        direction = DESCRIPTION;
                        fieldSortDirectionMap.put(sortByField,DESCRIPTION);
                    }
                    queryString += ' ' + direction; 
                }else if(sortDirection != STRING_NULL){
                    //Add sort direction to query if defined in component
                    queryString += ' ' + sortDirection;             
                }
                
                //Add limit clause to end of the query
                queryString += ' limit ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());  
            }      
           
            
            //Query records and setup standard set controller for pagination
            ssc = new ApexPages.StandardSetController(Database.query(queryString));
            
            //Check to see if more than 10,000 records where return, if so display warning as standard set controller can only process 10,000 recores
            if(!ssc.getCompleteResult()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There were more related records than could be processed. This is a partially complete list.'));
            }
            //Set pagination size based on value set in component
            if(pageSize != INTEGER_NULL){
                ssc.setPageSize(pageSize);
            }       
                
            /*For the fields that will be displayed identify the field type and set styleClass for
            cell alignment. Numbers, Currency, %, etc should align right in table. put in map FieldName -> class name*/
                //Get the meta data info for the fields is the related object
               final Map<String, Schema.SObjectField> fieldMap = getObjectDescribe().fields.getMap(); 
               final Map<String,String> mapReferenceFields = new Map<String,String>();
               final Map<String, Map<String, Schema.SObjectField>> mapReferenceObjectsFieldMap = new Map<String, Map<String, Schema.SObjectField>>(); 
                
                for(Schema.SObjectField field : fieldMap.values()){
                    final Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    if(fieldResult.getType() == Schema.DisplayType.Reference){
                        mapReferenceFields.put(fieldResult.getRelationshipName(), String.valueOf(fieldResult.getReferenceTo()[0]));
                    }
                }
                //For the fields in the related list populate fieldAlignMap map with the name of the correct style class. Also populate name->label map for header display
                fieldAlignMap = new Map<String,String>();
                nameLabelMap = new Map<String,String>();
                for(String fld : fieldNames){
                    fld = fld.trim();
                    if(fieldMap.containsKey(fld)){
                        populateFieldMaps(fld, fieldMap, fld);
                    }
                    else if(fld.contains('.')){
                        populateReferenceFields(fld, fld, mapReferenceFields, mapReferenceObjectsFieldMap);
                    }
                    else{
                        fieldAlignMap.put(fld,'alignLeft');
                        nameLabelMap.put(fld,fld);
                    }
                }
            }
        }
        
        calculateMoreRecords(false);
        return ssc.getRecords();
    }
    
    @TestVisible
    private void populateReferenceFields(final String fld, final String fieldName, Map<String,String> mapReferenceFields, final Map<String, Map<String, Schema.SObjectField>> mapReferenceObjectsFieldMap){
        final List<String> fieldParts = fieldName.split('\\.', 2);
        if(mapReferenceFields.containskey(fieldParts[0])){
           final String refObjectName = mapReferenceFields.get(fieldParts[0]);
            Map<String, Schema.SObjectField> refObjFieldMap;
            if(mapReferenceObjectsFieldMap.containskey(refObjectName)){
                refObjFieldMap = mapReferenceObjectsFieldMap.get(refObjectName);
            }
            else{
                refObjFieldMap = Schema.getGlobalDescribe().get(refObjectName).getDescribe().Fields.getMap();
                mapReferenceObjectsFieldMap.put(refObjectName, refObjFieldMap);
            }
            
            if(fieldParts[1].contains('.')){
                 mapReferenceFields = new Map<String,String>();
                 for(Schema.SObjectField field : refObjFieldMap.values()){
                  final  Schema.DescribeFieldResult fieldResult = field.getDescribe();
                    if(fieldResult.getType() == Schema.DisplayType.Reference){
                        mapReferenceFields.put(fieldResult.getRelationshipName(), String.valueOf(fieldResult.getReferenceTo()[0]));
                    }
                }
                populateReferenceFields(fld, fieldParts[1],  mapReferenceFields, mapReferenceObjectsFieldMap);
            }
            else{
                if(refObjFieldMap.containskey(fieldParts[1])){
                    populateFieldMaps(fld, refObjFieldMap, fieldParts[1]);
                }
                else{
                    fieldAlignMap.put(fld,'alignLeft');
                    nameLabelMap.put(fld,fld);
                }
            }
        }
    }
    
    @TestVisible
    private void populateFieldMaps(final String fld, final Map<String, Schema.SObjectField> fieldmap, final String fieldApi){
        final String fieldType = fieldmap.get(fieldApi).getDescribe().getType().name();    
        if(fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'INTEGER'){
            fieldAlignMap.put(fld,'alignRight');
        }else{
            fieldAlignMap.put(fld,'alignLeft');
        }   
        //Add to name->label map
       final String label = fieldmap.get(fieldApi).getDescribe().getLabel();
        nameLabelMap.put(fld,label);
    }
    
    
    public Boolean getShowNewButton(){
        //Display new button if user has create permission for related object
        return getObjectDescribe().isCreateable();
    }
    public Schema.DescribeSObjectResult objectDesNull()
    {return null;}
    
    public DescribeSObjectResult getObjectDescribe(){
        /*Returns object describe for list object. This is used in many places so we are using a dedicated method that only invokes 
        Schema describe calls once as these count against Apex limits. Because this method returns a DescribeSObjectResult all the get 
        methods for this object can be used directly in Visualforce: {!objectDescribe.label}*/
        if(objectDescribe == objectDesNull()){
            objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();  
        }
        return objectDescribe;
    }
    
    public void sortByFieldAction(){
        //Making ssc variable null will cause getRecords method to requery records based on new sort by field clicked by user
        ssc = FSConstants.STD_CTRL_NULL;
    }
      
    public void deleteRecord(){
        //Delete the selected object
        for(sObject obj : ssc.getRecords()){
            if(obj.get('Id') == deleteRecordId){
                delete obj;
                break;              
            }
        }
        
        /*There is no way to modify the collecton used in a standard set controller so we will make it null and call getRecord
        method. This will reload the set of records*/
        //Save the current page number so we can keep user on same page in the set after delete
        final Integer pageNumber = ssc.getPageNumber();
        //Make ssc variable null and execute get method
        ssc = FSConstants.STD_CTRL_NULL;
        getRecords();
        
        /*Set the correct page number. If record deleted was a single record on the last page set the number of pages in 
        the new set will decrease by 1, need to check for this. If the total number of pages is less than than the previous 
        page number set the current page to the previous last page - 1 */
        final Decimal rSize = ssc.getResultSize();
        final Decimal pageSize = ssc.getPageSize();
        
        if(( rSize / pageSize).round(System.RoundingMode.UP) < pageNumber){
            ssc.setPageNumber(pageNumber - 1);
        }else{
            ssc.setPageNumber(pageNumber);
        }
    }
    
    public void showMore(){
        calculateMoreRecords(true);
    }
    @TestVisible
    private void calculateMoreRecords(final Boolean isSetPageSize){
        final Integer totalRecord = ssc.getResultSize();
        final Integer pageSize1 = ssc.getPageSize();
        final Integer pageNumber = ssc.getPageNumber();
        final Integer currentRecords = pageSize1 * pageNumber;
        
        if(currentRecords < totalRecord){
            final Integer remainingRecords = totalRecord - currentRecords;
            showMoreLink = 'Show ' + (remainingRecords < pageSize1 ? remainingRecords : pageSize1) + ' more »';
            if(isSetPageSize){
                pageSize = pageSize1 + pageSize1;
                ssc.setPageSize(pageSize);
            }
        }
        else {
            showMoreLink = BLANK;
        }
    }
}