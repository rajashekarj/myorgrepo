/*********************************************************************************************************
Name         : FSFlavorChangeOD
Created By   : Infosys Limited 
Created Date : 23-Dec-2016
Usage        : Extension for FSFlavorChangeOD, Displays list of Flavor Changes that are approved to OD level

***********************************************************************************************************/

public class FSFlavorChangeOD {

    public FS_Outlet_Dispenser__c outletDispenser{set;get;}
    
    public FSFlavorChangeOD(ApexPages.standardController controller){
         outletDispenser= (FS_Outlet_Dispenser__c) controller.getRecord();
         
    }
    
    public List<FS_Flavor_Change_New__c> getFlavorChanges(){
        return [SELECT ID,name,FS_New_Brandset__c,FS_New_Brandset__r.name,FS_New_Brandset__r.FS_Brandset_number__c,
                FS_BS_Effective_Date__c,FS_Hide_Show_Water_Button__c,
                FS_WA_Effective_Date__c FROM FS_Flavor_Change_New__c WHERE FS_Final_Approval__c=true AND 
                FS_Outlet_Dispenser__c =:outletDispenser.Id ORDER BY  LastModifiedDate DESC];
    }
}