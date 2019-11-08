/****************************************************************************
Name         : FSUpdateSAPIDForAccountBatch
Created By   : Bhanuchander & Lavanya
Description  : Retrieve all the active outlet dispensers with the updated SAP ID 
and sent an updates call to Airwatch
Created Date : Nov 10, 2015

*****************************************************************************/
global with sharing class FSUpdateSAPIDForAccountBatch implements  Database.Batchable<sObject>,  Database.AllowsCallouts {
    
    // Adding set for oulet(OT)
    public Set<Id> lstAllOTAccIds = new set<Id>();
    //Added for SAP ID Acc Object
    //public Map<Id, Boolean> mapFSSAPID = new Map<Id, Boolean>();
    
    //test
    //Constructor
    //Added map of sap and set for sapid
    public FSUpdateSAPIDForAccountBatch (Set<Id> lstAllOTAccIds) {
        
        this.lstAllOTAccIds = lstAllOTAccIds;
        
        //added this.Sapid
        //this.mapFSSAPID =mapFSSAPID ;
        //this.mapChangedInvoiceCustomer = mapChangedInvoiceCustomer;
    }
    
    /****************************************************************************
//Start the batch and query
/***************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext batchCon){
        //Query locator used to get OutletDispensers which is active  
        
        String query='';
        if(Test.isRunningTest()){
            query= 'SELECT Id,Brand_Set_formula__c,FS_Soft_Ice_Adjust_Flag__c, FS_Soft_Ice_Manufacturer__c, FS_TimeZone__c, FS_ACN_NBR__c, FS_Outlet__r.ShippingCity,DMA__c, FS_IsActive__c,FS_outlet__r.id, FS_Outlet__r.Name, FS_outlet__r.ShippingCountry,FS_Dispenser_Type2__c,FS_Outlet__r.FS_Chain__r.Name, FS_Outlet__r.FS_Headquarters__r.Name, FS_outlet__r.FS_Headquarters__r.FS_ACN__c,FS_Outlet__r.ShippingState, FS_Outlet__r.ShippingStreet, FS_Outlet__r.FS_ACN__c, FS_Outlet__r.ShippingPostalCode,FS_Outlet__r.FS_Chain__r.FS_ACN__c, FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,FS_Code__c,  FS_Serial_Number2__c, Installation__r.FS_Spicy_Cherry__c,FS_SAP_ID__c, Installation__r.FS_Valid_fill_required__c,FS_Spicy_Cherry__c,FS_Equip_Type__c,Installation__r.FS_Original_Install_Date__c,FS_Equip_Sub_Type__c,FS_Country_Key__c,FS_Planned_Install_Date__c,Planned_Remove_Date__c,FS_7000_Series_Hide_Water_Button__c,FS_Water_Button__c,FS_Valid_Fill__c,FS_CE_Enabled__c,FS_FAV_MIX__c,RecordType.Name, RecordTypeId,Brands_Not_Selected__c, FS_Last_Updated_Date_Time_to_NMS__c,FS_NMS_Response__c ,Country__c,Item_code__c,Brand_Set__c,Enable_CE__c,Enable_Promo__c,Fav_Mix__c,IC_Code__c,Ownership_Type__c, FS_outlet__r.Bottler_Name__c,FS_outlet__r.Bottlers_Name__r.Name,FS_outlet__r.Bottlers_Name__c,FS_LTO__c,FS_Promo_Enabled__c, FS_Migration_to_AW_Required__c, FS_Pending_Migration_to_AW__c, FS_Migration_to_AW_Complete__c  FROM FS_Outlet_Dispenser__c WHERE  FS_Outlet__r.Id IN :lstAllOTAccIds AND FS_IsActive__c=true limit 1';
        }  else {
            query= 'SELECT Id,Brand_Set_formula__c,FS_Soft_Ice_Adjust_Flag__c, FS_Soft_Ice_Manufacturer__c, FS_TimeZone__c, FS_ACN_NBR__c, FS_Outlet__r.ShippingCity,DMA__c, FS_IsActive__c,FS_outlet__r.id, FS_Outlet__r.Name, FS_outlet__r.ShippingCountry,FS_Dispenser_Type2__c,FS_Outlet__r.FS_Chain__r.Name, FS_Outlet__r.FS_Headquarters__r.Name, FS_outlet__r.FS_Headquarters__r.FS_ACN__c,FS_Outlet__r.ShippingState, FS_Outlet__r.ShippingStreet, FS_Outlet__r.FS_ACN__c, FS_Outlet__r.ShippingPostalCode,FS_Outlet__r.FS_Chain__r.FS_ACN__c, FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,FS_Code__c, FS_Serial_Number2__c, Installation__r.FS_Spicy_Cherry__c,FS_SAP_ID__c, Installation__r.FS_Valid_fill_required__c ,FS_Spicy_Cherry__c,FS_Equip_Type__c,Installation__r.FS_Original_Install_Date__c,FS_Equip_Sub_Type__c,FS_Country_Key__c,FS_Planned_Install_Date__c,Planned_Remove_Date__c,FS_7000_Series_Hide_Water_Button__c,FS_Water_Button__c,FS_Valid_Fill__c,FS_CE_Enabled__c,FS_FAV_MIX__c,RecordType.Name, RecordTypeId,Brands_Not_Selected__c, FS_Last_Updated_Date_Time_to_NMS__c,FS_NMS_Response__c ,Country__c,Item_code__c,Brand_Set__c,Enable_CE__c,Enable_Promo__c,Fav_Mix__c,IC_Code__c,Ownership_Type__c, FS_outlet__r.Bottler_Name__c,FS_outlet__r.Bottlers_Name__c,FS_outlet__r.Bottlers_Name__r.Name,FS_LTO__c,FS_Promo_Enabled__c, FS_Migration_to_AW_Required__c, FS_Pending_Migration_to_AW__c, FS_Migration_to_AW_Complete__c FROM FS_Outlet_Dispenser__c WHERE FS_Outlet__r.Id IN :lstAllOTAccIds AND FS_IsActive__c=true';
        }
        return Database.getQueryLocator(query);
    }
    
    /****************************************************************************
//Process a batch
/***************************************************************************/
    
    global void execute(Database.BatchableContext batchCon, List<sObject> scope) {
        
        Set<Id> dispenserIds = new Set<Id>();
        List<FS_Outlet_Dispenser__c> fso = scope; 
        
        for(FS_Outlet_Dispenser__c sc:fso){
            dispenserIds.add(sc.Id);           
        }
        
        if(dispenserIds != null && dispenserIds.size() > 0){
            FSFETNMSConnector.isUpdateSAPIDBatchChange = true;
            FSFETNMSConnector.airWatchSynchronousCall(dispenserIds,null);
        } 
    }
    
    /****************************************************************************
//finish the batch
/***************************************************************************/
    
    global void finish(Database.BatchableContext batchCon) {
        
    }
    
}