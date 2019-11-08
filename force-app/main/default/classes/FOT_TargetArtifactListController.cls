/*****************************************************************
Name         : FOT_TargetArtifactListController
Created By   : Infosys
Created Date : 05-May-2018
Usage        : This class holds the logic for FOT_Target_Artifact_DataTable lightning component.
******************************************************************/
public class FOT_TargetArtifactListController {
    
    public static final String ROLLINGBACK ='Rollback';
    public static final String ACTUAL ='Actual';
    public static final String TARGET ='Target';
    public static final String BASE ='Base';
    public static final String DRYRUN ='Dry Run';
    public static final String MEDIUM ='Medium';

/*****************************************************************
Method: getTargetArtifacts
Description: getTargetArtifacts method is to fetch all required fields of FS_TargetArtifact__c record.
Added as part of FOT
******************************************************************/
    @AuraEnabled
    public static List<TgtArtiWrapper> getTargetArtifacts(id recordId, List<String> RecordTypeList) {
        
        If(RecordTypeList[0] == '')
        {
            RecordTypeList.add(ROLLINGBACK);
            RecordTypeList.add(ACTUAL);
            RecordTypeList.add(TARGET);
        }
        
        //Fetch all the records from targetArtifacts object for the selected recordtypes
        List<FS_TargetArtifact__c> targetArtifacts = new List<FS_TargetArtifact__c>();
        try{
            targetArtifacts = [SELECT Id, Name, RecordType.name,FS_Artifact_Type__c,FS_ODRecID__c,FS_Rule_Set__c FROM FS_TargetArtifact__c where FS_ODRecID__c =: recordId and RecordType.name in :RecordTypeList];
        }
        
        catch(QueryException e){
            system.debug('Exception on \'getTargetArtifacts\' method in class \'FOT_TargetArtifactListController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_TargetArtifactListController', 'getTargetArtifacts', 'FS_TargetArtifact__c',MEDIUM, e,e.getMessage());
        }
        
        return getTargerArtifactRecrods(targetArtifacts);
    }


/*****************************************************************
Method: getTargetArtifactsOnLoad
Description: getTargetArtifactsOnLoad method is to fetch all required fields of FS_TargetArtifact__c record.
Added as part of FOT
******************************************************************/
    @AuraEnabled
    public static List<TgtArtiWrapper> getTargetArtifactsOnLoad(id recordId) {
        List<String> ArtiRecrdTypes = new List<String>();
        ArtiRecrdTypes.add(BASE);
        ArtiRecrdTypes.add(DRYRUN);
        
        //Fetch all the records from targetArtifacts object on load
        List<FS_TargetArtifact__c> targetArtifacts = new List<FS_TargetArtifact__c>();
        try{
            targetArtifacts = [SELECT Id, Name, RecordType.name,FS_Artifact_Type__c,FS_ODRecID__c,FS_Rule_Set__c FROM FS_TargetArtifact__c where FS_ODRecID__c =: recordId and RecordType.name NOT IN :ArtiRecrdTypes ];
        }
        
        catch(QueryException e){
            system.debug('Exception on \'getTargetArtifactsOnLoad\' method in class \'FOT_TargetArtifactListController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_TargetArtifactListController', 'getTargetArtifactsOnLoad', 'FS_TargetArtifact__c',MEDIUM, e,e.getMessage());
        }
        
        
        return getTargerArtifactRecrods(targetArtifacts);
    }
 
/*****************************************************************
Class: TgtArtiWrapper
Description: TgtArtiWrapper is a wrapper class to hold the fields displayed on the lightning dataTable.
Added as part of FOT
******************************************************************/
    public class TgtArtiWrapper {
        @AuraEnabled public String RcrdType;
        @AuraEnabled public String Ruleset;
        @AuraEnabled public String name;
        @AuraEnabled public String ArtifactType;
    }

/*****************************************************************
Method: getTargerArtifactRecrods
Description: getTargerArtifactRecrods method is to build the list of wrapper class  
for the retrieved targerArtifact records and return the list.
Added as part of FOT
******************************************************************/
    
    @AuraEnabled
    public static List<TgtArtiWrapper> getTargerArtifactRecrods(List<FS_TargetArtifact__c> targetArtifacts){
        List<TgtArtiWrapper> TgtArtiObjList = new List<TgtArtiWrapper>();
        for(FS_TargetArtifact__c TgtArti :targetArtifacts){
            TgtArtiWrapper TgtArtiObj = new TgtArtiWrapper();
            TgtArtiObj.RcrdType = TgtArti.RecordType.name;
            TgtArtiObj.Ruleset = TgtArti.FS_Rule_Set__c;
            TgtArtiObj.name = TgtArti.Name;
            TgtArtiObj.ArtifactType = TgtArti.FS_Artifact_Type__c;
            TgtArtiObjList.add(TgtArtiObj);    
        }
        return TgtArtiObjList;
    }
    
/*****************************************************************
Method: getPiklistValues
Description: getPiklistValues is to retrieve all the picklist values of FS_TargetArtifact__c object from RecordType object.
Added as part of FOT
******************************************************************/
    @AuraEnabled
    public static List <String> getPiklistValues() {
        List<String> plValues = new List<String>();
        
        //Fetch all the recordtypes of FS_TargetArtifact__c object from RecordType table
        List<RecordType> rtList = new List<RecordType>();
        try{
            rtList = [SELECT Id,Name FROM RecordType WHERE SobjectType='FS_TargetArtifact__c'];
        }
        
		catch(QueryException e){
            system.debug('Exception on \'getPiklistValues\' method in class \'FOT_TargetArtifactListController\' '+e.getMessage());
            ApexErrorLogger.addApexErrorLog('FOT', 'FOT_TargetArtifactListController', 'getPiklistValues', 'RecordType',MEDIUM, e,e.getMessage());
        }
        
        for(RecordType rt: rtList)
        {
            plValues.add(rt.Name);
        }
        plValues.sort(); //Sort the list of recordTypes
        return plValues; //Return list of sorted recordTypes
    }
    
}