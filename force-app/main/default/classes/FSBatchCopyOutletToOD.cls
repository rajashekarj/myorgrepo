/*
Copying flavor changes the copy to low levels from Hq to Outlets
Author: Srinivas B
Date:05/04/2015.

Modified: Neel 9/28/2018 As part of FET 5.2 FFET 1302. Enable 9100 platform type on valid fill.
*/
global class FSBatchCopyOutletToOD implements  Database.Batchable<sObject>, Database.Stateful , Database.AllowsCallouts {
    
    public String recId;
    public Flavor_Change__c fc;
    public FS_Post_Install_Marketing__c pm;
    public FS_Valid_Fill__c vf; 
    Public Set <Id> disId = new Set<Id>(); 
    global String validFill7k=Schema.SObjectType.FS_Valid_Fill__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_7k).getRecordTypeId();
    global String validFill8k=Schema.SObjectType.FS_Valid_Fill__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_8k).getRecordTypeId();
    global String validFill9k=Schema.SObjectType.FS_Valid_Fill__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_9k).getRecordTypeId();
    global String validFill91k=Schema.SObjectType.FS_Valid_Fill__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_91k).getRecordTypeId();
    
    Set<Id> outletIdSet;
    
    Map<Id,RecordType> validfillMap=new Map<Id,RecordType>([Select id,name from RecordType where SobjectType='FS_Valid_Fill__c']);
    
    //Constructor
    public FSBatchCopyOutletToOD(String recId,Flavor_Change__c fc,FS_Post_Install_Marketing__c pm,FS_Valid_Fill__c vf,Set<Id> outletIdSet) {
        this.recId = recId;
        this.fc=fc;
        this.outletIdSet=outletIdSet;
        this.pm=pm;
        this.vf=vf;   
        
        
    }
    
    /****************************************************************************
//Start the batch and query
/***************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        // For Active Dispensers
        Set<Boolean> setActiveInactiveDispensers = new Set<Boolean>();
        
        
        setActiveInactiveDispensers.add(true);    
        if(Label.INCLUDE_INACTIVE_DISPENSERS_FOR_NMS.equalsIgnoreCase('TRUE')) {
            // For Inactive Dispensers
            setActiveInactiveDispensers.add(false);
        } 
        
        if(recId!=null){
            outletIdSet=new Set<Id>();
            outletIdSet.add(recId);
        }     
        
        
        return Database.getQueryLocator([SELECT FS_Outlet__r.ShippingCity, FS_outlet__r.id, FS_Outlet__r.Name, FS_outlet__r.ShippingCountry,FS_Dispenser_Type2__c,
                                         FS_Outlet__r.FS_Chain__r.Name, FS_Outlet__r.FS_Headquarters__r.Name, FS_outlet__r.FS_Headquarters__r.FS_ACN__c,
                                         FS_Outlet__r.ShippingState, FS_Outlet__r.ShippingStreet, FS_Outlet__r.FS_ACN__c, FS_Outlet__r.ShippingPostalCode,
                                         FS_Outlet__r.FS_Chain__r.FS_ACN__c, FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,
                                         FS_Code__c,FS_Serial_Number2__c,Installation__r.FS_Spicy_Cherry__c, FS_Outlet__c,
                                         FS_SAP_ID__c, Installation__r.FS_Valid_fill_required__c,FS_Spicy_Cherry__c,FS_Equip_Type__c,Installation__r.FS_Original_Install_Date__c,FS_Equip_Sub_Type__c,Brand_Set_Effective_Date__c,
                                         FS_FAV_MIX_Effective_Date__c,FS_Water_Hide_Show_Effective_Date__c,FS_Valid_Fill_Settings_Effective_Date__c,
                                         Planned_Remove_Date__c,FS_CE_Enabled_New__c,FS_LTO_New__c,FS_Promo_Enabled_New__c,FS_7000_Series_Hide_Water_Effective_Date__c,
                                         FS_Promo_Enabled_Effective_Date__c,FS_CE_Enabled_Effective_Date__c,FS_CE_Enabled__c,
                                         FS_Brand_Selection_Value_Effective_Date__c,FS_7000_Series_Static_Selection_New__c,
                                         FS_LTO_Effective_Date__c,RecordTypeId,FS_7000_Series_Hide_Water_Button__c,FS_Water_Button__c,FS_Valid_Fill__c
                                         FROM FS_Outlet_Dispenser__c 
                                         WHERE FS_Outlet__c=: outletIdSet AND FS_IsActive__c IN :setActiveInactiveDispensers ]);                          
        
    }
    
    /****************************************************************************
//Process a batch
/***************************************************************************/
    global void execute(Database.BatchableContext bc, List<sObject> odList){
        //Creating FC list to clone in Outlet dispenser related list
        List<Flavor_Change__c> lstClndFCOutletDisp = new List<Flavor_Change__c>();
        
        //Creating list of Outlet Dispenser
        List<FS_Outlet_Dispenser__c>  listOD = new List<FS_Outlet_Dispenser__c>();
        List<FS_Outlet_Dispenser__c>  listODCurrentDate = new List<FS_Outlet_Dispenser__c>();
        
        //Creating FC list to clone in Outlet dispenser related list
        List<FS_Post_Install_Marketing__c> lstClndMrktoutletDisp = new List<FS_Post_Install_Marketing__c>();
        
        List<FS_Valid_Fill__c> lstClndVFOutletDisp = new List<FS_Valid_Fill__c>();
        
        for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)odList){
             
            if(pm!=null){
            //Coping marketing fields to od
            od.FS_CE_Enabled_New__c=pm.FS_Enable_Consumer_Engagement__c;
            od.FS_CE_Enabled_Effective_Date__c=pm.FS_Enable_CE_Effective_Date__c;
            //od.FS_FAV_MIX_New__c=pm.FS_FAV_MIX__c;
            //od.FS_FAV_MIX_Effective_Date__c=pm.FS_FAV_MIX_Effective_Date__c;
            od.FS_LTO_New__c=pm.FS_LTO__c;            
            od.FS_LTO_Effective_Date__c=pm.FS_LTO_Effective_Date__c;
            od.FS_Promo_Enabled_New__c=pm.FS_Promo_Enabled__c;
            od.FS_Promo_Enabled_Effective_Date__c=pm.FS_Promo_Enabled_Effective_Date__c;
            //coping Install Marketing related list
            FS_Post_Install_Marketing__c newPIM =  pm.clone();     
            newPIM.FS_Outlet_Dispenser__c=od.id;
            newPIM.FS_RcdIDForCncl__c=pm.id;
            newPIM.FS_Account__c=null;
            newPIM.FS_Installation__c=null;
            lstClndMrktoutletDisp.add(newPIM);
            
            listOD.add(od);
            boolean isCurrentDate = FsODTriggerHelper.CheckEffectiveDate(od);
            if(isCurrentDate){
            listODCurrentDate.add(od);
            }
            }
            if(vf!=null){
                //Check for od Equipment type and ValidFill record type match
                if((od.FS_Equip_Type__c==FSConstants.RECTYPE_7k && vf.recordtypeID==validFill7k) || (od.FS_Equip_Type__c==FSConstants.RECTYPE_8k && vf.recordtypeID==validFill8k) ||
                   (od.FS_Equip_Type__c==FSConstants.RECTYPE_91k && vf.recordtypeID==validFill91k) || (od.FS_Equip_Type__c==FSConstants.RECTYPE_9k && vf.recordtypeID==validFill9k)){              
                       //coping Outlet dispenser Valid related list
                       FS_Valid_Fill__c newVF =  vf.clone();     
                       newVF.FS_Outlet_Dispenser__c=od.id;
                       newVF.FS_Outlet__c=null;
                       newVF.FS_Installation__c=null;
                       od.FS_Valid_Fill_New__c=vf.Valid_Fill_Request_Approval_Status__c;
                       od.FS_Valid_Fill_Settings_Effective_Date__c=vf.FS_Valid_Fill_Effective_Date__c;
                       lstClndVFOutletDisp.add(newVF);
                       
                       listOD.add(od);
                       boolean isCurrentDate = FsODTriggerHelper.CheckEffectiveDate(od);
                       if(isCurrentDate){
                           listODCurrentDate.add(od);
                       }
                   }   
            }
        }
        
        try{
            if(listODCurrentDate != null && listODCurrentDate.size() > 0){
                FSFETNMSConnector.isUpdateSAPIDBatchChange=true;
                SET<Id>  setODCurrentDate = new SET<Id>();
                for(FS_Outlet_Dispenser__c od1 :listODCurrentDate)
                {
                    setODCurrentDate.add(od1.Id);
                }
                FSFETNMSConnector.airWatchSynchronousCall(setODCurrentDate,null); // This will update the Airwatch.
            }
            insert lstClndFCOutletDisp;    //insert Outlet Dispenser related Flavor Changes object
            insert lstClndMrktoutletDisp;  //insert Outlet Dispenser related Marketing Fields object
            insert lstClndVFOutletDisp;    //insert Outlet Dispenser related Vallid Fill object
            Update listOD;
        }
        catch(Exception ex)
        { 
            System.debug('The following exception has occurred: ' + ex.getMessage());
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSBatchCopyOutletToOD','Execute','Outlet Dispense',FSConstants.MediumPriority,ex,'NA');
            
        }
    }
    
    /****************************************************************************
//finish the batch
/***************************************************************************/
    global void finish(Database.BatchableContext bc){
        
        
        
    }
    
    
}