/**************************************************************************************
Apex Class Name     : FSPlatformDetailsInstallationExtension
Version             : 1.0
Function            : This is an Extension class for FSPlatformDetailsInstallation VF, which display the platform Details and 
					 their specific field information of New Install record
Modification Log    :
* Developer         :    Date              Description
* ---------------------------------------------------------------------------- 
* Venkata FET 5.0	  01/05/2018		  Original  Version
*************************************************************************************/
public class FSPlatformDetailsInstallationExtension {    
    
    public Map<String,FS_Installation__c> mapInstallRecords{get;set;}
    public List<String> platformList{get;set;}
    
    
    public FSPlatformDetailsInstallationExtension(final ApexPages.StandardController stdController) {        
        // getting Installation record from controller
        final FS_Installation__c currentInstall = (FS_Installation__c) stdController.getRecord();
        // Instance of Installation
        FS_Installation__c installRecord=new FS_Installation__c();
        //Map to store Platform Name and Installation Instance
        mapInstallRecords=new Map<String,FS_Installation__c>();
        //Installation Instance to store data specific to Platform
        FS_Installation__c newInstall;  
        //Top Mount IceMaker Map  Sprint 5 - 507
        Map<String,FS_IP_Equipment_Package__c> eqpMap=new Map<String,FS_IP_Equipment_Package__c>();
        // List to Store Platform Names
        platformList=new List<String>{'Platform 1','Platform 2','Platform 3'};
            // Querying the installation record with required details to show 
            installRecord=[SELECT Id,RecordType.name,FS_Platform1__c,FS_Platform2__c,FS_Platform3__c,Type_of_Dispenser_Platform__c,FS_DispRequested1__c,FS_DispRequested2__c, 
                           FS_DispRequested3__c,FS_DispOrder1__c,FS_DispOrder2__c,FS_DispOrder3__c,FS_Mrkt_ActiveDate1__c,FS_Mrkt_ActiveDate2__c,FS_Mrkt_ActiveDate3__c,
                           FS_Scheduled_Install_Date__c,FS_Market_Activation_override__c,FS_Mrkt_Override1__c,FS_Mrkt_Override2__c,FS_Mrkt_Override3__c
                           FROM FS_Installation__c WHERE Id=:currentInstall.Id limit 1];
        //Sprint 5 - 507
        for(FS_IP_Equipment_Package__c eqp:[select id,name,FS_Platform_Type__c,FS_Installation__c,FS_Planned_Topmount_Icemakers__c from FS_IP_Equipment_Package__c where FS_Installation__c=:currentInstall.Id]){
            eqpMap.put(eqp.FS_Platform_Type__c, eqp);
        }
        
        // Checking Platform 1 value of Installation record Null or Not
        if(installRecord.FS_Platform1__c!=FSConstants.NULLVALUE){
            //Sprint 5 - 507
            Decimal topMount;
            topMount=eqpMap.containsKey(installRecord.FS_Platform1__c)?eqpMap.get(installRecord.FS_Platform1__c).FS_Planned_Topmount_Icemakers__c:null;                
            
            newInstall=new FS_Installation__c(FS_Platform1__c=installRecord.FS_Platform1__c,FS_Mrkt_ActiveDate1__c=installRecord.FS_Mrkt_ActiveDate1__c,
                                              FS_DispRequested1__c=installRecord.FS_DispRequested1__c,FS_DispOrder2__c=topMount,
                                              FS_DispOrder1__c=installRecord.FS_DispOrder1__c,FS_Market_Activation_override__c=installRecord.FS_Mrkt_Override1__c);
        }
        else{
            newInstall=new FS_Installation__c();
        }                
        mapInstallRecords.put(platformList[0], newInstall);
        // Checking Platform 2 value of Installation record Null or Not
        if(installRecord.FS_Platform2__c!=FSConstants.NULLVALUE){
            //Sprint 5 - 507
            Decimal topMount;
            topMount=eqpMap.containsKey(installRecord.FS_Platform2__c)?eqpMap.get(installRecord.FS_Platform2__c).FS_Planned_Topmount_Icemakers__c:null;                
            
            newInstall=new FS_Installation__c(FS_Platform1__c=installRecord.FS_Platform2__c,FS_Mrkt_ActiveDate1__c=installRecord.FS_Mrkt_ActiveDate2__c,
                                              FS_DispRequested1__c=installRecord.FS_DispRequested2__c,FS_DispOrder2__c=topMount,
                                              FS_DispOrder1__c=installRecord.FS_DispOrder2__c,FS_Market_Activation_override__c=installRecord.FS_Mrkt_Override2__c);
        }
        else{
            newInstall=new FS_Installation__c();
        }
        mapInstallRecords.put(platformList[1], newInstall);
        // Checking Platform 3 value of Installation record Null or Not
        if(installRecord.FS_Platform3__c!=FSConstants.NULLVALUE){ 
            //Sprint 5 - 507
            Decimal topMount;
            topMount=eqpMap.containsKey(installRecord.FS_Platform3__c)?eqpMap.get(installRecord.FS_Platform3__c).FS_Planned_Topmount_Icemakers__c:null;                
            
            newInstall=new FS_Installation__c(FS_Platform1__c=installRecord.FS_Platform3__c,FS_Mrkt_ActiveDate1__c=installRecord.FS_Mrkt_ActiveDate3__c,
                                              FS_DispRequested1__c=installRecord.FS_DispRequested3__c,FS_DispOrder2__c=topMount,
                                              FS_DispOrder1__c=installRecord.FS_DispOrder3__c,FS_Market_Activation_override__c=installRecord.FS_Mrkt_Override3__c);
        }
        else{
            newInstall=new FS_Installation__c();
        }            
        mapInstallRecords.put(platformList[2], newInstall);     
    }   
}