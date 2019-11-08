global without sharing class FsPostInstalltionDMBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global String query;
    public static final Integer INT_FIVE = 5;
    global String relocateO4W=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('Relocation (O4W)').getRecordTypeId();
    global String relocate=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('Relocation (I4W)').getRecordTypeId();
    global String removal=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('Removal').getRecordTypeId();
    global String replace=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('Replacement').getRecordTypeId();
    global String newInstall=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get('New Install').getRecordTypeId();
    global String complete='Complete';
    global String cancel='Cancelled';
    
    
    /****************************************************************************
//Start the batch
/***************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        final Set<Id> recordTypeIds=new Set<Id>();   
        //recordTypeIds.add(relocate);  recordTypeIds.add(removal); recordTypeIds.add(replace); recordTypeIds.add(relocateO4W);
        recordTypeIds.add(newInstall);
        
        String qry = 'Select id,name,recordtypeId,FS_Outlet__c,Overall_Status2__c,FS_Outlet__r.ShippingPostalCode,Type_of_Dispenser_Platform__c,FS_Market_Text__c,FS_SP__c,'+
            'FS_Scope_of_Work__c,FS_Type_of_Dispenser_Platform__c,SP_Override__c '+
            'from FS_Installation__c WHERE RecordTypeId IN:recordTypeIds and Overall_Status2__c!=:complete and Overall_Status2__c!=:cancel';
        
        return Database.getQueryLocator(qry);
    }
    
    
    
    global void execute(Database.BatchableContext BC, List<sObject> lstIP){
        String zipCode;
        final Set<String> postalCodeList = new Set<String>();
        final Map<String,FS_SP_Aligned_Zip__c> spZipMap=new Map<String,FS_SP_Aligned_Zip__c>();
        final List<FS_Installation__c> ipListUpdate=new List<FS_Installation__c>();
        final Set<Id> outletIdSet=new Set<Id>(); 
        final Map<Id, String> outletMap = new Map<Id, String>(); 
        
        for(FS_Installation__c install:(List<FS_Installation__c>)lstIP){
            if(install.FS_Outlet__c!=FSConstants.NULLVALUE){
                outletIdSet.add(install.FS_Outlet__c);
                if(install.FS_Outlet__r.ShippingPostalCode != null  && install.FS_Outlet__r.ShippingPostalCode != '') {                    
                    if(install.FS_Outlet__r.ShippingPostalCode.length() > INT_FIVE) {  zipCode = install.FS_Outlet__r.ShippingPostalCode.substring(FSConstants.ZERO,INT_FIVE);   }                    
                    else{ zipCode = install.FS_Outlet__r.ShippingPostalCode;        }                    
                    postalCodeList.add(zipCode);
                    outletMap.put(install.FS_Outlet__c, zipCode);
                }                
            }
        }
        
        //Fetch Sp aligned zip records based on ZIP codes
        if(!postalCodeList.isEmpty()){
            for(FS_SP_Aligned_Zip__c alignedZip: [SELECT FS_Platform_Type__c, FS_Zip_Code__c, FS_Service_Provider__c,FS_Selling_Market_Activation_Date__c,FS_Market__c,FS_Selling_Activity_Market__r.Name FROM FS_SP_Aligned_Zip__c WHERE FS_Zip_Code__c IN : postalCodeList]){
                
                spZipMap.put(alignedZip.FS_Zip_Code__c+alignedZip.FS_Platform_Type__c,alignedZip);
                spZipMap.put(alignedZip.FS_Zip_Code__c,alignedZip);
            }    
        } 
        
        for(FS_Installation__c install:(List<FS_Installation__c>)lstIP){
            if(install.FS_Outlet__c!=null && outletMap.containskey(install.FS_Outlet__c) && spZipMap.containsKey(outletMap.get(install.FS_Outlet__c))){                                                    
                   if(!install.SP_Override__c){
                    install.FS_SP__c=spZipMap.get(outletMap.get(install.FS_Outlet__c)).FS_Service_Provider__c;
                } 
            }
            else{
                install.FS_SP__c=FSConstants.ID_NULL;
            } 
            ipListUpdate.add(install);
        }              
         if(!ipListUpdate.isEmpty()){            
            final List<Database.SaveResult> resList = Database.update(ipListUpdate,false);
            errorCheckMethod(resList,ipListUpdate,'ipListUpdate','FS_Installation__c');
        }
    }
    
    /*****************************************************************
Method: errorCheckMethod
Description: errorCheckMethod method is used to create Apex error loger records.
to know the details of failed insert/update records while batch processing
*******************************************************************/
    public void errorCheckMethod(final List<Database.SaveResult> resList,final List<sObject> ipList,final String listName,final String objectName){
        
        final List<Apex_Error_Log__c> apexErrorList=new List<Apex_Error_Log__c>();
        for(Integer i=0; i < ipList.size() ; i++){
            final Database.SaveResult res = resList.get(i);
            if(!res.isSuccess()){
                for(Database.Error error : res.getErrors()){
                    apexErrorList.add(new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FsPostInstalltionDMBatch',Method_Name__c='errorCheckMethod',Object_Name__c=objectName,Error_Severity__c=FSConstants.MediumPriority,Notes__c=listName+FSConstants.HYPHEN+error.getMessage()+FSConstants.HYPHEN+ ipList[i].Id));                    
                }
            }            
        }
        if(!apexErrorList.isEmpty()){  insert apexErrorList;    }
    }
    
    
    global void finish(Database.BatchableContext BC){
        
    }
}