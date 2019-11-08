public class FSInstallationRelatedButtonsController {
 
    @AuraEnabled
    public static id getEpId(){
        String EPName = Dummy_Execution_Plan_del__c.getInstance().ExecutionPlan_Name__c;
        FS_Execution_Plan__c eprec = [select id,name from FS_Execution_Plan__c where name like :('%' + EPName + '%') limit 1];
        return eprec.id;
    }
    @AuraEnabled
    public static boolean getProfileAccess(){
        boolean profileHasAccess=false;
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        if(string.isNotBlank(usrProfileName) && (usrProfileName.contains('FS Admin PM_P') || usrProfileName.contains('FS AC_P') || usrProfileName.contains('FS PM_P') || usrProfileName.contains('System Administrator') || usrProfileName.contains('FET System Admin'))){
            profileHasAccess=true;
        }
        return profileHasAccess;
    }
}