/**********************************************************************************************************
Name         : FsODTriggerBusinessPorcess
Created By   : Infosys
Created Date : 04-OCT-2017
Usage        : This class holds the business logic of the OutletDispenserTrigger and is called from the Fs_OD_Trigger.
***********************************************************************************************************/

public with sharing class FsODTriggerBusinessPorcess {
    
    
    //Before Insert Methods
    //POpulate fields,Link brandset,Link Installation
    public static void OnBeforeInsertProcess(){        
        FsODTriggerHandler.populateDispenserOnInsert();
        FsODTriggerHandler.dispLocationOnInsert();
    }
    //After Insert  Methods
    //Send Create call to AW after insert 
    public static  void OnAfterInsertProcess(){
        FsODTriggerHandler.callAddService();
        //FsODTriggerHandler.updateBrandsetonOD();
        FsODTriggerHandler.createSettings();
         //Link Installation to OD 
        FsodTriggerHelper.linkInstODBeforeInsert();
        FsODTriggerHandler.createABForOD();
       
    }
    //Before Update Methods
    //POpulate fields,Link brandset,Link Installation
    public static void OnBeforeUpdateProcess(){
        FsODTriggerHandler.populateDispenserOnUpdate();
    }
    //After Update Methods
    //Send update call to AW,Delete call ,Update shipping form 
    public static void OnAfterUpdateProcess(){
            FsODTriggerHandler.callUpdateService();
            FsODTriggerHandler.deleteCall();
            FsODTriggerHandler.updateShippingFormStatus();
            FsODTriggerHandler.notifyBottDispDeliverInt();
        	FsODTriggerHandler.populateDispLocation();
        	//FsODTriggerHandler.updateBrandsetonOD();
    }
    
    public static void onBeforeDeleteODs() {
        FsODTriggerHandler.deleteRelatedRecords();
    }
}