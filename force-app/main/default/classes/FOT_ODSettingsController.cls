public class FOT_ODSettingsController {
    public static final String MEDIUM ='Medium';
	
    /*****************************************************************
	Method: ODSettingsRecordDetails
	Description: ODSettingsRecordDetails method is to get OD setting record details associated to OD.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static id ODSettingsRecordDetails(id recordId){
        
        final id odsettingsId; 
        try
        {
            if(recordId!=null)
            {
                FS_OD_Settings__c odSettings = [Select id,Name,FS_OD_RecId__c from FS_OD_Settings__c where FS_OD_RecId__c =: recordId Limit 1];
                odsettingsId = odSettings.Id;
            } 
        }
        catch(QueryException e){ApexErrorLogger.addApexErrorLog('FOT', 'FOT_ODSettingsController', 'ODSettingsRecordView', 'FS_OD_Settings__c',MEDIUM, e,e.getMessage());      }
        return odsettingsId;
    }
    
     /*****************************************************************
	Method: userProfileAccess
	Description: userProfileAccess method is to get logged-in user's profile name.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static string userProfileAccess(){
        User usr=[select profile.name from user where id=:userinfo.getUserId()];
        return usr.profile.name;
    }
    
    /*****************************************************************
	Method: ODEDitableSettingsRecordDetails
	Description: ODEDitableSettingsRecordDetails method is to get OD setting record details associated to OD.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static id ODEDitableSettingsRecordDetails(id recordId){
        system.debug('--- recordId from class --- '+recordId);
        //id recordId  = ApexPages.CurrentPage().getparameters().get('id');
       final id odsettingsId; 
        try
        {
            if(recordId!=null)
            {
                FS_OD_SettingsReadOnly__c odSettings = [Select id,Name,FS_OD_RecId__c from FS_OD_SettingsReadOnly__c where FS_OD_RecId__c =: recordId Limit 1];
                odsettingsId = odSettings.Id;
            }
        }
        catch(QueryException e)
        {ApexErrorLogger.addApexErrorLog('FOT', 'FOT_ODSettingsController', 'ODSettingsRecordView', 'FS_OD_Settings__c',MEDIUM, e,e.getMessage());        }
        
        
        system.debug('--- odsettingsId from readonly setting class --- '+odsettingsId);
        return odsettingsId;
    }
}