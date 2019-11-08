/*=================================================================================================================
* Date         : 01-30-2019
* Developer    : Goutham Rapolu
* Purpose      : AuraEnabled Controller for NewEditBrandsetOverride lightning component to return Parent record ID & Delete Brandset
*=================================================================================================================
*                                 Update History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 01-30-2019 | Goutham Rapolu |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

public class NewBrandsetOverrideController {
    
    @AuraEnabled
    public static Id getHQRecordId(id brandsetId, string ObjName){
        id hqID;
        Blob afterblob = EncodingUtil.base64Decode(ObjName);
        String ObjectName = afterblob.toString();
        System.debug('decoded as: ' + afterblob.toString());
        if(brandsetId != null) {
            //Query Parent ID from Default Brandset.
            FS_Association_Brandset__c assBrandset= [select id, name,FS_Headquarters__c, FS_Installation__c, FS_Outlet_Dispenser__c from FS_Association_Brandset__c
                                                     where id =:brandsetId] ;
            hqID = null;
            //Check if Parent ID is Installation / Account.
            if(ObjectName.contains('FS_Installation__c')  || ObjectName.contains('Account_Brandsets__r')){
                    hqID = assBrandset.FS_Installation__c;
            }else if(ObjectName.contains('Account') || ObjectName.contains('FSHeadquarters__r')){
                hqID = assBrandset.FS_Headquarters__c;
            } else if(ObjectName.contains('FS_Outlet_Dispenser__c') || ObjectName.contains('OutletDispensers__r')) {
            	 hqID = assBrandset.FS_Outlet_Dispenser__c;
            }
            else if(ObjectName.contains('FS_Association_Brandset__c')){
               hqID = assBrandset.id;
            }    
        }
        return hqID;
    }
    //Check User profile to give access to record Edit/Delete.
    @AuraEnabled
    public static boolean getProfileAccess(id brandsetId, string ObjName){
        id hqID;
        Blob afterblob = EncodingUtil.base64Decode(ObjName);
        String ObjectName = afterblob.toString();
        System.debug('decoded as: ' + afterblob.toString());
        
        boolean profileHasAccess=false;
        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        
        if(string.isNotBlank(usrProfileName) && !ObjectName.contains('FS_Outlet_Dispenser__c') && !ObjectName.contains('OutletDispensers__r') 
           && (usrProfileName.contains('FS Admin PM_P') || usrProfileName.contains('FS AC_P') || usrProfileName.contains('FS PM_P') || 
               usrProfileName.contains('System Administrator') || usrProfileName.contains('FET System Admin'))){
            profileHasAccess=true;
        }
        if(string.isNotBlank(usrProfileName) && (ObjectName.contains('FS_Outlet_Dispenser__c') || ObjectName.contains('OutletDispensers__r')) 
           && (usrProfileName.contains('System Administrator') || usrProfileName.contains('FET System Admin'))){
            profileHasAccess=true;
        }
        
        
        return profileHasAccess;
    }
    
    //Check if Installation record type is New Install.
     @AuraEnabled
    public static boolean getInstallationRT(id brandsetId, string ObjName){
        Boolean RTisNewInstall = true;
        Blob afterblob = EncodingUtil.base64Decode(ObjName);
        String ObjectName = afterblob.toString();
        System.debug('decoded as: ' + afterblob.toString());
        if(brandsetId != null) {
            //Query Parent ID from Default Brandset.
            FS_Association_Brandset__c assBrandset= [select id, name,FS_Headquarters__c, FS_Installation__c, FS_IP_RecordType__c from FS_Association_Brandset__c
                                                     where id =:brandsetId] ;
            if(ObjectName.contains('FS_Installation__c') || ObjectName.contains('Account_Brandsets__r')){
                RTisNewInstall = false;
                system.debug('@@IP_New_Install_Rec_Type'+Label.IP_New_Install_Rec_Type );
                system.debug('@@assBrandset.FS_IP_RecordType__c'+assBrandset.FS_IP_RecordType__c );
                if(assBrandset.FS_IP_RecordType__c == Label.IP_New_Install_Rec_Type){
                    RTisNewInstall = true;
                }
            }
        }
        system.debug('@@RTisNewInstall'+RTisNewInstall);
        return RTisNewInstall;
    }
    //Delete Brandset.
    @AuraEnabled
    public static void deleteBrandSet(id brandsetId) {
        FS_Association_Brandset__c assBrandset= [select id, name,FS_Headquarters__c,FS_Installation__c from FS_Association_Brandset__c
                                                 where id =:brandsetId] ;
        delete assBrandset;
    }
    
    @AuraEnabled
    public static string getdecodeurl(string decodeurl){
        Blob afterblob = EncodingUtil.base64Decode(decodeurl);
        String ObjectName = afterblob.toString();
        String FinalValue = '';
        if( ObjectName.contains('Account_Brandsets__r')){
            FinalValue = 'Account_Brandsets__r';            
        }
        if (ObjectName.contains('FSHeadquarters__r')){
            FinalValue = 'FSHeadquarters__r';
        }
        if (ObjectName.contains('OutletDispensers__r')){
            FinalValue = 'OutletDispensers__r';
        }
        
        
        return FinalValue;
    }
}