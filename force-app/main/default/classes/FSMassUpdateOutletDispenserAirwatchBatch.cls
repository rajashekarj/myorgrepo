/*********************************************************************************************************
Name         : FSMassUpdateOutletDispenserAirwatchBatch 
Created By   : Infosys Limited 
Created Date : 10-Jan-2017
Usage        : Batch class which is used for updating airwatch after update post Install attributes on Outlet Dispenser records

***********************************************************************************************************/
global class FSMassUpdateOutletDispenserAirwatchBatch implements  Database.batchable <sobject>,Database.Stateful,Database.AllowsCallouts{
    
    public List<String> setOfSerialNumber=new List<String> ();
        
    public FSMassUpdateOutletDispenserAirwatchBatch (List<String> setOfSerialNumber){
       this.setOfSerialNumber=setOfSerialNumber;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext batchContext){
    return Database.getQueryLocator('SELECT FS_Outlet__r.ShippingCity,FS_ACN_NBR__c,Ownership_Type__c, FS_outlet__r.Bottler_Name__c,FS_7000_Series_Hide_Water_Effective_Date__c,FS_7000_Series_Brands_Option_Selections__c, FS_outlet__r.id, FS_Outlet__r.Name,'
         +'FS_outlet__r.ShippingCountry,FS_Soft_Ice_Manufacturer__c, FS_TimeZone__c,FS_Soft_Ice_Adjust_Flag__c,FS_Dispenser_Type2__c, FS_Outlet__r.FS_Chain__r.Name, FS_Outlet__r.FS_Headquarters__r.Name, FS_outlet__r.FS_Headquarters__r.FS_ACN__c,'
         +'FS_LTO_New__c ,FS_LTO_Effective_Date__c,Brand_Set_New__c,Brand_Set__c,Brand_Set_Effective_Date__c ,Brands_Not_Selected__c, FS_7000_Series_Hide_Water_Button_New__c,'
         +'FS_Water_Button_New__c ,IC_Code__c, FS_Water_Hide_Show_Effective_Date__c , FS_CE_Enabled_New__c, FS_CE_Enabled_Effective_Date__c,FS_Dasani_New__c ,FS_Dasani_Settings_Effective_Date__c,'
         +'FS_FAV_MIX_New__c ,FS_FAV_MIX_Effective_Date__c,FS_Promo_Enabled_New__c , FS_Promo_Enabled_Effective_Date__c ,FS_Spicy_Cherry_New__c ,FS_Spicy_Cherry_Effective_Date__c,FS_Valid_Fill_New__c ,'
         +'FS_Valid_Fill_Settings_Effective_Date__c, FS_7000_Series_Static_Selection_New__c,FS_Brand_Selection_Value_Effective_Date__c,FS_7000_Series_Agitated_Selections_New__c,FS_7000_Series_Brands_Selection_New__c,FS_Outlet__r.ShippingState, '
         +'FS_Outlet__r.ShippingStreet, FS_Outlet__r.FS_ACN__c, FS_Outlet__r.ShippingPostalCode,FS_Outlet__r.FS_Chain__r.FS_ACN__c, FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,FS_Code__c, '
         +'FS_Serial_Number2__c,Installation__r.FS_Spicy_Cherry__c, FS_SAP_ID__c, Installation__r.FS_Valid_fill_required__c,'
         +'FS_Spicy_Cherry__c,FS_Equip_Type__c,Installation__r.FS_Original_Install_Date__c,FS_Equip_Sub_Type__c,FS_Country_Key__c,FS_Planned_Install_Date__c, Planned_Remove_Date__c,FS_7000_Series_Hide_Water_Button__c,FS_Water_Button__c,FS_Valid_Fill__c,'
         +'FS_CE_Enabled__c,FS_FAV_MIX__c,FS_LTO__c,FS_Promo_Enabled__c, FS_Migration_to_AW_Required__c, FS_Pending_Migration_to_AW__c, FS_Migration_to_AW_Complete__c, RecordTypeId '
         +'FROM FS_Outlet_Dispenser__c  WHERE FS_IsActive__c=true AND FS_Serial_Number2__c IN:setOfSerialNumber '); 
    }
    
    
    global void execute(Database.BatchableContext batchContext, List<sObject> scope){
        Set<Id> setOdId=new Set<Id>();
        for(FS_Outlet_Dispenser__c oDispRecord:(List<FS_Outlet_Dispenser__c>)scope){
            setOdId.add(oDispRecord.id);
        }
        FSFETNMSConnector.isUpdateSAPIDBatchChange = true;
       //Send to Airwatch
       FSFETNMSConnector.airWatchSynchronousCall(setOdId,null);
          
     }
    
    //this is finish method
    public void finish(Database.BatchableContext batchContext){
      		system.debug('finish method of FSMassUpdateOutletDispenserAirwatchBatch'); 
    }
}