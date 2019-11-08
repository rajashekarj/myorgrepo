public class FS_InstallationWarningAuraController {   
    @AuraEnabled public boolean displayError {get; set;}
    @AuraEnabled public boolean displayErrorSync {get; set;}
    @AuraEnabled public boolean IP_I4W_ReconnectDate {get; set;}
    @AuraEnabled public boolean dispSecError {get; set;}
    @AuraEnabled public FS_Installation__c installation {get; set;}
    @AuraEnabled public String recordTypeName {get; set;}
    
    public FS_InstallationWarningAuraController(){
       
    }   
    
    @AuraEnabled
    public static FS_InstallationWarningAuraController checkBrandsetAndSyncValues(id RecID){
        
          
       // FS_Installation__c install1;
        FS_Installation__c installation;
        FS_InstallationWarningAuraController objectCnt = new FS_InstallationWarningAuraController();
        
        installation=[select id,name,RecordTypeId,FS_Execution_Plan__c,FS_Disconnect_Final_Date__c,Type_of_Dispenser_Platform__c,FS_Install_Reconnect_Date__c,
                      FS_Scheduled_Install_Date__c,Overall_Status2__c,FS_Relocation_from_old_outlet_to_SP_is__c,
                      FS_Installation__c.RecordType.Name,
                      (select id,FS_Equip_Type__c,Relocated_Installation__c from Outlet_Dispensers1__r),
                      (select id,FS_Equip_Type__c,FS_Other_PIA_Installation__c from Outlet_Dispensers2__r) from FS_Installation__c where Id=:RecID];
        objectCnt.displayError=false;
        objectCnt.displayErrorSync=false;
        objectCnt.IP_I4W_ReconnectDate=false;
        objectCnt.dispSecError=false;
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
                    objectCnt.displayError=true;
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
                        objectCnt.displayErrorSync=true;
                    }
                }
                for(string platform: platformsEP){ 
                    if(!allIpPlatformSet.contains(platform)){
                        objectCnt.displayErrorSync=true;
                    }
                }
            }
            if (installation.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation
                && installation.FS_Relocation_from_old_outlet_to_SP_is__c
                && installation.FS_Scheduled_Install_Date__c == installation.FS_Disconnect_Final_Date__c
                && installation.FS_Install_Reconnect_Date__c < installation.FS_Disconnect_Final_Date__c 
               ) {
                   objectCnt.IP_I4W_ReconnectDate=true;
               }
               /*   Commenting as part of  FNF-747 change : to remove the warning message for all PIA records*/
          /*  if(installation.RecordTypeId!=FSInstallationValidateAndSet.ipNewRecType && installation.Overall_Status2__c!=FSConstants.IPCANCELLED ){
                final Set<String> equipTypeSet=new Set<String>();
                List<String> equipTypeList=new List<String>();
                List<FS_Outlet_Dispenser__c> odRecList=new List<FS_Outlet_Dispenser__c>();            
                odRecList=installation.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation?installation.Outlet_Dispensers1__r:installation.Outlet_Dispensers2__r;
                
                for(FS_Outlet_Dispenser__c od:odRecList){ 
                    //FET-1249 Changes END
                    equipTypeSet.add(od.FS_Equip_Type__c);
                }
                equipTypeList.addAll(equipTypeSet);
                system.debug('equipTypeList'+equipTypeList);
                system.debug('platformsInstall'+platformsInstall);
                for(String plat:equipTypeList){       if(!platformsInstall.contains(plat)){     objectCnt.dispSecError=true;  }  }
                for(String plat:platformsInstall){    if(!equipTypeList.contains(plat)){        objectCnt.dispSecError=true;  }  }
                
            }*/
            
        }
        objectCnt.recordTypeName = installation.RecordType.Name;
        objectCnt.installation = installation;
        return objectCnt;
    }   
    
    
}