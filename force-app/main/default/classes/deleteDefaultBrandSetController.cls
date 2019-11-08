public class deleteDefaultBrandSetController {
	public static String accId {get; set;}
    String retUrl;
    public Boolean parentrecordChk {get; set;}
    String usrProfileName {get; set;}
    public static String hqId {get; set;}
    public deleteDefaultBrandSetController(ApexPages.StandardController controller) {
        system.debug('in Constructor ');
        system.debug('!!!!' + ApexPages.currentPage().getUrl());
        
        retUrl = ApexPages.currentPage().getUrl();
        String [] listaccId= retUrl.split('&id=',2);
        accid=listaccId[1].subString(0,15);
        parentrecordChk = true;
        id recid = id.valueof(accid);
        String sObjName = recid.getSObjectType().getDescribe().getName();
        system.debug('sObjName:' +sObjName);

        //usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
    }
    
    public void deleteBrandSet()
    {
        system.debug('inside delete method');
        system.debug('brandsetId '+accID );
        List<FS_Association_Brandset__c> deleteBs = [select id,name,FS_Headquarters__c,FS_Installation__c,FS_Outlet_Dispenser__c,LastModifiedById from FS_Association_Brandset__c where id = :accid];
        
        If(deleteBs[0].FS_Headquarters__c != null)
        {
            system.debug('inside delete if');
            hqId = deleteBs[0].FS_Headquarters__c;
            delete deleteBs;
            
        }
        else
        {
            parentrecordChk = false;
            
        }
    }
    
    
}