public class FOT_ShowHideController {
    public static final String MEDIUM ='Medium';
	
    /*****************************************************************
	Method: ShowHideRecordDetails
	Description: ShowHideDetails method is to get OD setting record details associated to OD.
	Added as part of FOT
	*********************************/
    @AuraEnabled
    public static List<FS_OD_Show_Hide__c> ShowHideRecordDetails(id recordId){
        
        final id showHideId; 
		List<FS_OD_Show_Hide__c> showHideRec= new List<FS_OD_Show_Hide__c>();
        try
        {
            if(recordId!=null)
            {
                showHideRec = [Select id,beverage_id__c,show_hide_setting__c,Name,FS_ODRecID__c from FS_OD_Show_Hide__c where FS_ODRecID__c =: recordId];
            } 
        }
        catch(QueryException e){ApexErrorLogger.addApexErrorLog('FOT', 'FOT_ShowHideController', 'ShowHideRecordDetails', 'FS_OD_Show_Hide__c',MEDIUM, e,e.getMessage());      }
        return showHideRec;
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
}