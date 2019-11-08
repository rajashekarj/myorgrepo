/**************************************************************************************
Apex Class Name     : FS_CaseRecordTypeController
Function            : This class is created for displaying list of Case Record Types on clicking 'New' button.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sai            8/26/2019          LM RecordType will be routed Custom LWC components others Will be routed to Standard Layout    
*************************************************************************************/

public with sharing class FS_CaseRecordTypeController {
    public static final String PROJECT_NAME = 'Freestyle Support 2019';
    public static final String FS_CASERECORDTYPECONTROLLER = 'FS_CaseRecordTypeController';
    public static final String NA = 'NA';
    public static final String MEDIUM = 'MEDIUM';
    public static final String CASE_OBJECT = 'Case';
    public static final String RECENTLY_VIEWED_LISTVIEW = 'Recently Viewed Cases';
    /*****************************************************************************************
    	Method : getCaseRecordTypeList
    	Description : Method for fetching all the Record Types from case object.
    ******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getCaseRecordTypeList() {
        List<RecordType> caseRecordTypesList1 = New List<RecordType>();
        List<RecordType> caseRecordTypesList2 = New List<RecordType>();
        try{
            List<String> recId1 = new List<String>();
            List<String> recId2 = new List<String>();
            for(RecordTypeInfo allRecTy : Case.SObjectType.getDescribe().getRecordTypeInfos())
            {
                if(allRecTy.isAvailable() && allRecTy.getName()!='Master') 
                { 
                    if(allRecTy.isDefaultRecordTypeMapping()){
                		recId1.add(allRecTy.getName());        
                    }else{
                       recId2.add(allRecTy.getName());
                    }
                }
            }
            caseRecordTypesList1 = [select Name,Description from RecordType where sObjectType=:CASE_OBJECT And Name IN: recId1 ];
            if(!recId2.isEmpty()){
             caseRecordTypesList2 = [select Name,Description from RecordType where sObjectType=:CASE_OBJECT And Name IN: recId2 ]; 
            }
            caseRecordTypesList1.addAll(caseRecordTypesList2);
        }
        catch(system.EmailException ex){system.debug('system.EmailException : ' + ex.getMessage());ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_CASERECORDTYPECONTROLLER,'getCaseRecordTypeList',NA,MEDIUM,ex,NA);}
        return caseRecordTypesList1;
    }
    /*****************************************************************************************
    	Method : getCaseListViewID
    	Description : Method for fetching 'Recently Viewed Cases' list view Id from the case object.
    ******************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ListView> getCaseListViewID() {
        List<ListView> caseListView = New List<ListView>();
        try{
            caseListView = [SELECT Id FROM ListView WHERE SobjectType=:CASE_OBJECT and Name =: RECENTLY_VIEWED_LISTVIEW];
       }
        catch(system.EmailException ex){system.debug('system.EmailException : ' + ex.getMessage());ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_CASERECORDTYPECONTROLLER,'getCaseListViewID',NA,MEDIUM,ex,NA);}
        return caseListView;
    }
}