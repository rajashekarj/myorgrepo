//FS_InstallationwarningController
public class FS_InstallationWarningController {
    
    FS_Installation__c install;
    FS_Installation__c installation;
    public boolean displayError {get; set;}
    public boolean displayErrorSync {get; set;}
    public boolean IP_I4W_ReconnectDate {get; set;}
    public boolean dispSecError {get; set;}
    
    public FS_InstallationWarningController(final ApexPages.StandardController controller){
        install = (FS_Installation__c) controller.getRecord();
        
        //FET-1249 Changes Start to fetch OD records linked to Relocation / Other PIA lookups using Inner query     
        installation=[select id,name,RecordTypeId,FS_Execution_Plan__c,FS_Disconnect_Final_Date__c,Type_of_Dispenser_Platform__c,FS_Install_Reconnect_Date__c,
                      FS_Scheduled_Install_Date__c,Overall_Status2__c,FS_Relocation_from_old_outlet_to_SP_is__c,
                      (select id,FS_Equip_Type__c,Relocated_Installation__c from Outlet_Dispensers1__r),
                      (select id,FS_Equip_Type__c,FS_Other_PIA_Installation__c from Outlet_Dispensers2__r) from FS_Installation__c where Id=:install.Id];
       //FET-1249 Changes END
        displayError=false;
        displayErrorSync=false;
        IP_I4W_ReconnectDate=false;
        dispSecError=false;
    }
    public void checkBrandsetAndSyncValues(){
        if(installation.Overall_Status2__c!=FSConstants.IPCANCELLED){
        
        List<String> platformsInstall=new List<String>();
        if(installation.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){
            platformsInstall=installation.Type_of_Dispenser_Platform__c.split(';');
        }
        
        final List<FS_Association_Brandset__c> assBrandsets =[SELECT FS_Brandset__c, FS_NonBranded_Water__c FROM FS_Association_Brandset__c WHERE FS_Installation__c =: installation.id];
        final Map<Id,FS_Execution_Plan__c> epWithinstallList=new Map<Id,FS_Execution_Plan__c>(
            [SELECT Id,FS_Platform_Type__c, (select id,Type_of_Dispenser_Platform__c from Outlet_Info_Summary__r where recordtypeId=:FSInstallationValidateAndSet.ipNewRecType)
             from FS_Execution_Plan__c where Id =:installation.FS_Execution_Plan__c]);
        
        for (FS_Association_Brandset__c brandset : assBrandsets){
            if (brandset.FS_Brandset__c==FSConstants.ID_NULL || brandset.FS_NonBranded_Water__c==FSConstants.STR_NULL){
                displayError=true;
            }
        }
        if(installation.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && installation.Type_of_Dispenser_Platform__c!=FSConstants.STR_NULL){
            final Set<string> allIpPlatformSet=new Set<String>();            
            List<String> platformsEP=new List<String>();
            
            
            final FS_Execution_Plan__c epItem=epWithinstallList.get(installation.FS_Execution_Plan__c);
            if(epItem.FS_Platform_Type__c!=FSConstants.NULLVALUE){
                platformsEP= epItem.FS_Platform_Type__c.split(';');
            }
            if(!platformsInstall.isEmpty() ){
                allIpPlatformSet.addAll(platformsInstall);
            }
            for(FS_Installation__c install:epItem.Outlet_Info_Summary__r){
                if(install.Id!=installation.Id && install.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){                   
                    final List<String> platformIPList=install.Type_of_Dispenser_Platform__c.split(';');
                    allIpPlatformSet.addAll(platformIPList);                    
                }                  
            }
            for(String platform: platformsInstall){
                if(epItem.FS_Platform_Type__c==FSConstants.NULLVALUE || !epItem.FS_Platform_Type__c.contains(platform)){
                    displayErrorSync=true;
                }
            }
            for(string platform: platformsEP){ 
                if(!allIpPlatformSet.contains(platform)){
                    displayErrorSync=true;
                }
            }
        }
        if (install.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation
            && installation.FS_Relocation_from_old_outlet_to_SP_is__c
            && installation.FS_Scheduled_Install_Date__c == installation.FS_Disconnect_Final_Date__c
            && installation.FS_Install_Reconnect_Date__c < installation.FS_Disconnect_Final_Date__c 
           ) {
               IP_I4W_ReconnectDate=true;
           }
           
           // Commenting as part of  FNF-747 change : to remove the warning message for all PIA records
      /*  if(installation.RecordTypeId!=FSInstallationValidateAndSet.ipNewRecType && installation.Overall_Status2__c!=FSConstants.IPCANCELLED ){
            final Set<String> equipTypeSet=new Set<String>();
            List<String> equipTypeList=new List<String>();
            //FET-1249 Changes Start to Store list of OD for the PIA based on Record type From 2 lookup fields
            List<FS_Outlet_Dispenser__c> odRecList=new List<FS_Outlet_Dispenser__c>();            
            odRecList=installation.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation?installation.Outlet_Dispensers1__r:installation.Outlet_Dispensers2__r;
            
            for(FS_Outlet_Dispenser__c od:odRecList){ 
                //FET-1249 Changes END
                equipTypeSet.add(od.FS_Equip_Type__c);
            }
            equipTypeList.addAll(equipTypeSet);
            
            for(String plat:equipTypeList){    	  if(!platformsInstall.contains(plat)){  	dispSecError=true;  }  }
            for(String plat:platformsInstall){    if(!equipTypeList.contains(plat)){  		dispSecError=true;  }  }
            
        }*/
    }}
}