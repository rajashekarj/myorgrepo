public class FSOutletContactsRelatedController {
  
    @AuraEnabled
    public static String getPhone(id outletid){
        String phoneNo;
        if(outletid != null) {
            Account acc= [select id, phone from Account where id =:outletid LIMIT 1] ;
            phoneNo = acc.Phone;
        }
        system.debug('phone no:-'+phoneNo);
        return phoneNo;
    }
    @AuraEnabled
    public static Id getHqId(id outletid){
        Id hqId;
        if(outletid != null) {
            Account acc= [select id, FS_Headquarters__c from Account where id =:outletid LIMIT 1] ;
            hqId = acc.FS_Headquarters__c;
        }
        return hqId;
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