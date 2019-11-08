/*********************************************************************************************************
    Name         : FsodTriggerHandler
    Created By   : Infosys
    Created Date : 04-OCT-2017
    Usage        : This class holds the common business logic of the Outletdispenser where fields are set and is called from the FSODBusinessProcess.
    Methods      : 
    ***********************************************************************************************************/

    public with sharing class FsODTriggerHandler{
        
        //Create instance of helper class
        FsodTriggerHelper helper = new FsodTriggerHelper();
        public static List<FS_Outlet_Dispenser__c> odWithBsEffToday=new List<FS_Outlet_Dispenser__c>(); 
        private static boolean var1=true;
        
        public static string inProc= 'In Process';
        public static string dispDeliver='Dispenser Delivered';
          
         /** @Desc - Before inser process logic 
        * @param - Trigger context variables(Trigger.new)
        * @Return - void
        */
        public static void populateDispenserOnInsert(){
            system.debug('Before populateDispenserOnInsert:-'+Limits.getQueries());
            for(FS_Outlet_Dispenser__c dispenser:(List<FS_Outlet_Dispenser__c>)Trigger.new){
                    //Populate active date
                    FsodTriggerHelper.populateActiveDate(dispenser);
                    //check Effective date
                    FsodTriggerHelper.CheckEffectiveDate(dispenser);
                    //Populate Record type
                    FsodTriggerHelper.populateRecordType(dispenser);
                    //Populate status in case of international dispensers coming from SAP.
                    FsodTriggerHelper.populateStatus(dispenser);
                    //Populate send-create request
                    FsodTriggerHelper.populateSendCreateRequest(dispenser);
                    if(dispenser.FS_Brandset_Effective_Date__c!=NULL && dispenser.FS_Brandset_Effective_Date__c==Date.today()){
                        odWithBsEffToday.add(dispenser);
                    }
                    if(dispenser.FS_showHideWater_Effective_date__c!=NULL && dispenser.FS_showHideWater_Effective_date__c==Date.today()){
                        odWithBsEffToday.add(dispenser);
                    }
                    
            }
            
            //Copy brandset to OD
            FsodTriggerHelper.copyBrandsetToOd(odWithBsEffToday);
            //Deactivate already exist OD with serial number
            FsodTriggerHelper.deactivateOdWithSameSerialNumber();
            //Update Equipment type - Recordtype 
            FsodTriggerHelper.UpdateRecordTypeJDUEqupType();
            //Update Platform/Equipment type for International OD
            FsodTriggerHelper.platformForInt();
            //Link Installation to OD 
            FsodTriggerHelper.linkInstODBeforeInsert();
            //Populate brandset from Installation
            FsodTriggerHelper.populateBrandsFromInst(Trigger.isUpdate,(Map<id,fs_outlet_dispenser__c>)Trigger.newMap,(Map<id,fs_outlet_dispenser__c>)Trigger.oldMap);
            //Populate Dispenser type from IP_Technician_Instructions
            //FsodTriggerHelper.popDispenserTypeFromIPTI();
            //Populate OD Code field from FS_IP_Equipment_Package__c
            FsodTriggerHelper.popCodeFieldFromIPEP();
            
            //Populate Marketing fields
                    FsodTriggerHelper.populateMarketingFields(trigger.new);
            system.debug('After populateDispenserOnInsert:-'+Limits.getQueries());
        }
        
        //Before Update
         /** @Desc - Before update process logic 
        * @param - Trigger context variables(Trigger.new)
        * @Return - void
        */
        public static void populateDispenserOnUpdate(){
            system.debug('Before populateDispenserOnUpdate:-'+Limits.getQueries());
            for(FS_Outlet_Dispenser__c dispenser:(List<FS_Outlet_Dispenser__c>)Trigger.new){
                    //Populate active date
                    FsodTriggerHelper.populateActiveDate(dispenser);
                    //check Effective date
                    FsodTriggerHelper.CheckEffectiveDate(dispenser);
                    //Populate Record type
                    FsodTriggerHelper.populateRecordType(dispenser);
                    //Populate send-create request
                    FsodTriggerHelper.populateSendCreateRequest(dispenser);
                    // International - scenarios
                    FsodTriggerHelper.populateIntOD(dispenser);    
                    //FET 4.0
                    System.debug('Brandset effective date' +dispenser.FS_Brandset_Effective_Date__c );
                    if(dispenser.FS_Brandset_Effective_Date__c!=NULL && dispenser.FS_Brandset_Effective_Date__c==Date.today()){
                        odWithBsEffToday.add(dispenser);
                    }
                    if(dispenser.FS_showHideWater_Effective_date__c!=NULL && dispenser.FS_showHideWater_Effective_date__c==Date.today()){
                        odWithBsEffToday.add(dispenser);
                    }
            }
            
            //Copy brandset to OD
            FsodTriggerHelper.copyBrandsetToOd(odWithBsEffToday);
            //Deactivate already exist OD with serial number
            FsodTriggerHelper.deactivateOdWithSameSerialNumber();
            //Update OD attributes
            FSUpdateOutletDispenserAttributes.updateOutletDispenserAttributes((List<FS_Outlet_Dispenser__c>)Trigger.New); 
            //Update Equipment type - Recordtype 
            FsodTriggerHelper.UpdateRecordTypeJDUEqupType();
            //Update Platform/Equipment type for International OD
            FsodTriggerHelper.platformForInt();
            //Populate brandset from Installation
            FsodTriggerHelper.populateBrandsFromInst(Trigger.isUpdate,(Map<id,fs_outlet_dispenser__c>)Trigger.newMap,(Map<id,fs_outlet_dispenser__c>)Trigger.oldMap);
            //Populate Dispenser type from IP_Technician_Instructions
            //FsodTriggerHelper.popDispenserTypeFromIPTI();
            //Populate OD Code field from FS_IP_Equipment_Package__c
            FsodTriggerHelper.popCodeFieldFromIPEP();
            system.debug('After populateDispenserOnUpdate:-'+Limits.getQueries());
        }
        
        /** @Desc - Send create request to AW on After Insert 
        * @param - Trigger context variables(Trigger.new)
        * @Return - void
        */
        public static void callAddService(){
            system.debug('Before callAddService:-'+Limits.getQueries());
            Set<Id> dispenser_Ids_Create = new Set<ID>();
            List<FS_Outlet_Dispenser__c> dispenserList = (List<FS_Outlet_Dispenser__c>)Trigger.new ;
            Set<Id> dispenserListId = new Set<Id>();
            for(FS_Outlet_Dispenser__c ODL: (List<FS_Outlet_Dispenser__c>)Trigger.new)
            {
                dispenserListId.add(ODL.FS_Outlet__c);            
            }
            for(FS_Outlet_Dispenser__c dispenser : (List<FS_Outlet_Dispenser__c>)Trigger.new){
                if(FsODTriggerHelper.odRecTypeInternational   == dispenser.RecordTypeId){
                    if(!dispenser.Is_DefaultOutlet__c && 
                        (FSConstants.dispenserStatusAssigned == dispenser.FS_Status__c || dispenser.Send_Create_Request__c)){            
                                dispenser_Ids_Create.add(dispenser.id);
                    }
                }else{
                    dispenser_Ids_Create.add(dispenser.id);
                }
            }
            
            if(!dispenser_Ids_Create.isEmpty()){
                /**Record Splitter module Start******************************/
                //Records to be processed will be divided into chunks and processed separately to avoid callout limits
                Integer recordChunkSize=Integer.valueOf(Label.recordChunkSize);
                //Split the List to as many as with recordChunkSize elements in each List
                List<List<Object>> splittedList=FSRecordSplitterToAvoidGovernorLimits.processRecords(new List<Id>(dispenser_Ids_Create),recordChunkSize);
                for(List<Object> splitListRecord: splittedList){
                    Set<Id> createOds=new Set<Id>();
                    for(Object obj : splitListRecord){
                        createOds.add((Id)obj);
                    }
                        
                    FSFETNMSConnector.airWatchAsynchronousCall(createOds,NULL); 
                }
                /**Record Splitter module End******************************/ 
            } 
            system.debug('After callAddService:-'+Limits.getQueries());
        }
        /** @Desc - Send update request to AW on After Update 
        * @param - Trigger context variables(Trigger.new)
        * @Return - void
        */
        public static void callUpdateService(){
            system.debug('Before callUpdateService:-'+Limits.getQueries());
            String  strDispenserAttrChange= 'None';
            Set<Id> dispenserIds = new Set<Id>();
            Map<Id, String> mapDispenserIdstrDispenserAttrChange = new Map<Id, String>();
            Set<Id> dispenserIds_CREATE = new Set<Id>(); //Send as a CREATE request if checkbox is selected on the outlet dispenser
            String integrationUserId = FSConstants.getIntegrationUserID();
            Map<Id,FS_Outlet_Dispenser__c> oldMap = (Map<Id,FS_Outlet_Dispenser__c>)Trigger.oldMap;
            for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Trigger.new){
                if(!dispenserObj.Is_DefaultOutlet__c ){   
                    if(dispenserObj.Send_Create_Request__c && !oldMap.get(dispenserObj.id).Send_Create_Request__c) {
                        if(dispenserObj.FS_IsActive__c ) {
                            dispenserIds_CREATE.add(dispenserObj.id);
                        } else if(!dispenserObj.FS_IsActive__c && LABEL.INCLUDE_INACTIVE_DISPENSERS_FOR_NMS.equalsIgnoreCase('TRUE')) {
                            dispenserIds_CREATE.add(dispenserObj.id);   
                        }   
                        
                    }else{                
                        if(FsODTriggerHelper.odRecTypeInternational  == dispenserObj.RecordTypeId) {
                            String OD_reg_Status=Label.OD_Register_Status;
                            if((dispenserObj.Send_Create_Request__c && dispenserObj.LastModifiedById != integrationUserId) 
                                && (OD_reg_Status.contains(dispenserObj.FS_Status__c)||dispenserObj.FS_Status__c==Label.Assigned_to_Outlet 
                                && dispenserObj.FS_Status__c!='New')) {
                                mapDispenserIdstrDispenserAttrChange=FsODTriggerHelper.attributeChange(dispenserObj,mapDispenserIdstrDispenserAttrChange);
                            }
                        }else{
                                mapDispenserIdstrDispenserAttrChange=FsODTriggerHelper.attributeChange(dispenserObj,mapDispenserIdstrDispenserAttrChange);
                            }
                    }
                 }
              }
            
            if(mapDispenserIdstrDispenserAttrChange!=null) {
                if (var1 && !System.isFuture() && !System.isBatch()){               
                    /**Record Splitter module Start******************************/
                    //Records to be processed will be divided into chunks and processed separately to avoid callout limits
                    Integer recordChunkSize=Integer.valueOf(Label.recordChunkSize);
                    Map<Object, Object> formattedMap = new Map<Object, Object>(); 
                    //Convert Map<Id,String> to Map<Object,Object>                
                    for(Id  keys: mapDispenserIdstrDispenserAttrChange.keySet()){
                        formattedMap.put((Object)keys,(Object)mapDispenserIdstrDispenserAttrChange.get(keys));
                    } 
                    // Split the Map to as many as with recordChunkSize elements in each map
                    List<Map<Object,Object>> splittedMap=FSRecordSplitterToAvoidGovernorLimits.processRecords(formattedMap,recordChunkSize);
                    if(!splittedMap.isEmpty()){
                        for(Map<Object,Object> splitMapRecord: splittedMap){
                            Map<Id, String> mapDispenserIdstrDispenserAttrChangeOriginal = new Map<Id, String>();
                            for(Object obj : splitMapRecord.keySet()){
                                mapDispenserIdstrDispenserAttrChangeOriginal.put((Id)obj,(String)splitMapRecord.get(obj));
                            }   
                            FSFETNMSConnector.airWatchAsynchronousCall(NULL,mapDispenserIdstrDispenserAttrChangeOriginal); 
                        }
                    }
                    /**Record Splitter module End******************************/ 
                } 
            }   
            
            if(dispenserIds_CREATE != null && !dispenserIds_CREATE.isEmpty()){
                /**Record Splitter module Start******************************/
                //Records to be processed will be divided into chunks and processed separately to avoid callout limits
                Integer recordChunkSize=Integer.valueOf(Label.recordChunkSize);
                // Split the List to as many as with recordChunkSize elements in each List
                List<List<Object>> splittedList=FSRecordSplitterToAvoidGovernorLimits.processRecords(new List<Id>(dispenserIds_CREATE),recordChunkSize);
                for(List<Object> splitListRecord: splittedList){
                    Set<Id> createOds=new Set<Id>();
                    
                    for(Object obj : splitListRecord){
                        createOds.add((Id)obj);
                    }
                    FSFETNMSConnector.airWatchAsynchronousCall(createOds,NULL);
                }
                /**Record Splitter module End******************************/             
            } 
            system.debug('After callUpdateService:-'+Limits.getQueries());
        }
        /** @Desc - Send delete request to AW on After Update  
        * @param - Trigger context variables(Trigger.new)
        * @Return - void
        */
        public static void deleteCall(){
            system.debug('Before deleteCall:-'+Limits.getQueries());
            Map<Id,FS_Outlet_Dispenser__c> oldMap = (Map<Id,FS_Outlet_Dispenser__c>)Trigger.oldMap;
            Set<Id> setOutletDispenserIds = new Set<Id>();
            Map<String,String> numberList = new map<String,String>();
            Platform_Type_ctrl__c platformList= Platform_Type_ctrl__c.getValues('all_Platform');
            for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Trigger.new) { 
                if(FsODTriggerHelper.odRecTypeInternational == dispenserObj.RecordTypeId){
                    if(dispenserObj.FS_Serial_Number2__c != null   
                        && dispenserObj.FS_ACN_NBR__c != null
                        && dispenserObj.FS_Status__c =='Removed From Outlet' 
                        && dispenserObj.FS_Status__c !=oldMap.get(dispenserObj.Id).FS_Status__c 
                        && !dispenserObj.FS_IsActive__c && dispenserObj.FS_IsActive__c !=oldMap.get(dispenserObj.Id).FS_IsActive__c
                        && !dispenserObj.Is_DefaultOutlet__c ){                             
                            setOutletDispenserIds.add(dispenserObj.Id);              
                        }
                }else{
                    if(dispenserObj.FS_Serial_Number2__c != null   
                        && dispenserObj.FS_ACN_NBR__c != null
                        && dispenserObj.FS_Status__c != 'Enrolled' 
                        && (dispenserObj.FS_Equip_Type__c!=null && platformList.Platforms__c.contains(dispenserObj.FS_Equip_Type__c))
                        && (oldMap.containsKey(dispenserObj.Id) && oldMap.get(dispenserObj.Id).FS_IsActive__c && !dispenserObj.FS_IsActive__c)){
                            setOutletDispenserIds.add(dispenserObj.Id);                   
                        } 
                }
                        
            }       
            if(setOutletDispenserIds != null && !setOutletDispenserIds.isEmpty()) {
                FsODTriggerHelper.deleteUnenrolledDispensers(setOutletDispenserIds);
            }
            system.debug('After deleteCall:-'+Limits.getQueries());
        }
        /** @Desc - Update shipping form status based on OD   
        * @param - Trigger context variables(Trigger.new,Trigger.oldMap)
        * @Return - void
        */
        public static void updateShippingFormStatus(){
            system.debug('Before updateShippingFormStatus:-'+Limits.getQueries());
            Map<String, Shipping_Form__c> shippingFormMapToUpdate = new Map<String, Shipping_Form__c>();
            Map<Id,FS_Outlet_Dispenser__c> oldMap = (Map<Id,FS_Outlet_Dispenser__c>)Trigger.oldMap;
            Set<ID> shippingFormSet = new Set<ID>(); 
            for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Trigger.new){  
                
                if(dispenserObj.Shipping_Form__c != FsODTriggerHelper.nullValue()){
                    shippingFormSet.add(dispenserObj.Shipping_Form__c);  
                }
            }
            Map<Id, Shipping_Form__c> shippingFormMap = new Map<Id, Shipping_Form__c>([SELECT FS_Status__c, id , (SELECT id, FS_Status__c FROM Outlet_Dispensers__r) 
                                                                                       FROM Shipping_Form__c WHERE id in :shippingFormSet]);
            
            for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Trigger.new){ 
                if(FsODTriggerHelper.odRecTypeInternational == dispenserObj.RecordTypeId){
                    if(dispenserObj.FS_Status__c != oldMap.get(dispenserObj.id).FS_Status__c 
                       && oldMap.get(dispenserObj.id).FS_Status__c == 'New'){
                           if(shippingFormMap!=FsODTriggerHelper.nullValue()){
                               if(dispenserObj.Shipping_Form__c != FsODTriggerHelper.nullValue()){
                                   Shipping_Form__c tempForm = shippingFormMap.get(dispenserObj.Shipping_Form__c);
                                   if(tempForm.FS_Status__c != inProc 
                                      ||  tempForm.FS_Status__c != 'Complete'){
                                          tempForm.FS_Status__c = inProc;
                                          if(!shippingFormMapToUpdate.containsKey(tempForm.id)){
                                              shippingFormMapToUpdate.put(tempForm.id, tempform); 
                                            }
                                    }
                               }
                           }
                       }
                    //If dispenser is delivered then update status to 'Complete'
                    boolean isDispenserDelivered = false;
                    if(dispenserObj.FS_Status__c != oldMap.get(dispenserObj.id).FS_Status__c){
                        if(shippingFormMap != null && dispenserObj.Shipping_Form__c != null){
                            Shipping_Form__c tempForm = shippingFormMap.get(dispenserObj.Shipping_Form__c);
                            if(tempForm != null && tempForm.Outlet_Dispensers__r != null){
                            for(FS_Outlet_Dispenser__c dispenser : tempForm.Outlet_Dispensers__r){
                                if(dispenser.FS_Status__c != dispDeliver){
                                    isDispenserDelivered = true; 
                                }
                            }
                            }
                            if(tempForm != null && !isDispenserDelivered){
                                tempForm.FS_Status__c = 'Complete';
                                if(!shippingFormMapToUpdate.containsKey(tempForm.id)){
                                    shippingFormMapToUpdate.put(tempForm.id, tempform); 
                                }
                            }
                            
                        }
                    }
                }   
            }
            if(!shippingFormMapToUpdate.isEmpty()){
                update shippingFormMapToUpdate.values();
            }
            system.debug('After updateShippingFormStatus:-'+Limits.getQueries());
        }
            /** @Desc - Send Notification to bottler contact when
                        OD status is updated to Dispenser Delivered  
            * @param - Trigger context variables(Trigger.new)
            * @Return - void
            */
          public static void notifyBottDispDeliverInt(){
              system.debug('Before notifyBottDispDeliverInt:-'+Limits.getQueries());
            Set<Id> dispenserIds = new Set<Id>();
            Map<Id,FS_Outlet_Dispenser__c> oldMap = (Map<Id,FS_Outlet_Dispenser__c>)Trigger.oldMap;
            for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Trigger.new){
                if( FsODTriggerHelper.odRecTypeInternational == dispenserObj.RecordTypeId){
                    if(dispenserObj.FS_Status__c == dispDeliver && oldMap.get(dispenserObj.id).FS_Status__c !=dispenserObj.FS_Status__c ){
                        dispenserIds.add(dispenserObj.Id);
                        
                    }
                }
            }
              //Moved Send email method outside the For Loop 06/08
              if(!dispenserIds.ISEMPTY()){FsODTriggerHelper.sendEmailContact(dispenserIds);}
              
              system.debug('After notifyBottDispDeliverInt:-'+Limits.getQueries());
        } 
        public static void populateDispLocation() {
            FsodTriggerHelper.populateDispenserLocation();
        }
   public static void updateBrandsetonOD(){
    system.debug('Before updateBrandsetonOD:-'+Limits.getQueries());
    //FSOutletDispenserTriggerHandler.isExecuting=true;
    final List<FS_Outlet_Dispenser__c> dispenserRecordsToUpdate=new List<FS_Outlet_Dispenser__c>();
    final Set<Id> odSet=new Set<Id>();
    final Map<Id,FS_Association_Brandset__c> dispenserAndAssociationBrandsetMap=new Map<Id,FS_Association_Brandset__c>();
    for(SObject oD:Trigger.New){
        FS_Outlet_Dispenser__c oD2=(FS_Outlet_Dispenser__c)oD;
        odSet.add(oD.Id);
    }
    List<FS_Association_Brandset__c> assoBrandsetList=[SELECT Id,FS_Brandset__c,FS_Outlet_Dispenser__c FROM FS_Association_Brandset__c WHERE FS_Outlet_Dispenser__c IN:odSet];
    for(FS_Association_Brandset__c assoBrand:assoBrandsetList){
        dispenserAndAssociationBrandsetMap.put(assoBrand.FS_Outlet_Dispenser__c,assoBrand);
    }
    List<FS_Outlet_Dispenser__c> odToBeUpdatedOld=[SELECT Id,FS_Brandset__c FROM FS_Outlet_Dispenser__c WHERE Id=:odSet];
    for( FS_Outlet_Dispenser__c outletDispenser : odToBeUpdatedOld){
         if(dispenserAndAssociationBrandsetMap.containsKey(outletDispenser.Id)){
             final FS_Association_Brandset__c assoBrandset=dispenserAndAssociationBrandsetMap.get(outletDispenser.Id);
             if(assoBrandset.FS_Brandset__c!=NULL && assoBrandset.FS_Brandset__c!=outletDispenser.FS_Brandset__c){
                outletDispenser.FS_Brandset__c=assoBrandset.FS_Brandset__c;
                dispenserRecordsToUpdate.add(outletDispenser);
             }
         }
    }
    update dispenserRecordsToUpdate;
       system.debug('After updateBrandsetonOD:-'+Limits.getQueries());
  }
            /** @Desc - Create an odSetting record and odSetting read-only record
             *          when an outlet dispenser is created.  
            * @param - Trigger context variables(Trigger.new)
            * @Return - void
            */
       public static void createSettings()
        {
            List<FS_OD_Settings__c> editableOdSettingList = new List<FS_OD_Settings__c>();
            List<FS_OD_SettingsReadOnly__c> readOnlyOdSettingList = new List<FS_OD_SettingsReadOnly__c>();
            
            for(SObject dispenser: Trigger.new)
            {
                FS_Outlet_Dispenser__c dispenser2 = (FS_Outlet_Dispenser__c)dispenser;
                FS_OD_Settings__c editableOdSetting = new FS_OD_Settings__c(); 
                FS_OD_SettingsReadOnly__c readOnlyOdSetting = new FS_OD_SettingsReadOnly__c();
                
                readOnlyOdSetting.FS_OD_RecId__c = dispenser2.id;
                editableOdSetting.FS_OD_RecId__c = dispenser2.id;
                
                editableOdSettingList.add(editableOdSetting);
                readOnlyOdSettingList.add(readOnlyOdSetting);
            }
            Insert editableOdSettingList;
            Insert readOnlyOdSettingList;
        } 
        
        public static void createABForOD(){
            List<FS_Association_Brandset__c> newAssociationBrandsetRecords=new List<FS_Association_Brandset__c>();
            for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Trigger.new){
                if(dispenserObj.recordTypeId!=FsODTriggerHelper.odRecTypeInternational){
                    if(dispenserObj.Installation__C==null){
                        FS_Association_Brandset__c newRecord=new FS_Association_Brandset__c();
                        newRecord.FS_Outlet_Dispenser__c=dispenserObj.Id;
                        newRecord.FS_Platform__c=dispenserObj.FS_Equip_Type__c;
                        newRecord.recordTypeId=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_OD).getRecordTypeId();
                        newAssociationBrandsetRecords.add(newRecord);
                    }
                }
            }
            
            if(!newAssociationBrandsetRecords.isEmpty()){
                insert newAssociationBrandsetRecords;
            }  
        }
        
        public static void deleteRelatedRecords() {
            List<FS_Outlet_Dispenser__c> dispensers = (List<FS_Outlet_Dispenser__c>)Trigger.old;            
            List<FS_TargetArtifact__c> targetArtifacts = new List<FS_TargetArtifact__c>([SELECT id FROM FS_TargetArtifact__c WHERE FS_ODRecID__c in :dispensers]);
            
            system.debug('Found: ' + dispensers[0].Id + ' , ' + targetArtifacts.size() + ' Target Artifacts, ' + dispensers.size() + ' dispensers');
            
            if(targetArtifacts.size() > 0) {
                delete targetArtifacts;
            }
        }
        
        public static void dispLocationOnInsert () {
            FsodTriggerHelper.DispenserLocationonOnInsert();
        }
        
}