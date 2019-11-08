public class FSExecutionPlanInlineWarningController {
    FS_Execution_Plan__c exePlan;
    public boolean displayErrorSync {get; set;}
    
    public FSExecutionPlanInlineWarningController(ApexPages.StandardController controller){
        exePlan = (FS_Execution_Plan__c) controller.getRecord();        
        displayErrorSync=false;        
    }
    public void checkSyncValues(){
        Map<Id,FS_Execution_Plan__c> epWithinstallList=new Map<Id,FS_Execution_Plan__c>(
            [SELECT Id,FS_Platform_Type__c, (select id,Type_of_Dispenser_Platform__c from Outlet_Info_Summary__r where recordtypeId=:FSInstallationValidateAndSet.ipNewRecType)
             from FS_Execution_Plan__c where Id =:exePlan.Id]);
        
        Set<string> allIpPlatformSet=new Set<String>();
        List<String> epPlatformList=new List<String>();      
        
        FS_Execution_Plan__c exPlan=epWithinstallList.get(exePlan.Id);
        if(exPlan.FS_Platform_Type__c!=null){                
            epPlatformList = exPlan.FS_Platform_Type__c.split(';');
        }
        for(FS_Installation__c installationInstance:exPlan.Outlet_Info_Summary__r){
            List<String> platformListInstall=new List<String>();
            if(installationInstance.Type_of_Dispenser_Platform__c!=null){
                platformListInstall=installationInstance.Type_of_Dispenser_Platform__c.split(';');
                allIpPlatformSet.addAll(platformListInstall);
            }
        }        
        for(string platform: epPlatformList){                    
            if(!allIpPlatformSet.contains(platform)){
                displayErrorSync=true;
            }                                
        }                
        for(string platform: allIpPlatformSet){                    
            if(exPlan.FS_Platform_Type__c==null || !exPlan.FS_Platform_Type__c.contains(platform)){
                displayErrorSync=true;
            }                               
        }
    }
}