/***************************************************************************
Name         : FSExecutionPlanTriggerHandler
Created By   : Mohit Parnami
Description  : Handler class of FSExecutionPlanTrigger
Created Date : Nov 11, 2013

Modified By    :   Dheeraj Kumar
Modified Date: Dec 26, 2014
Related Task : T-346229
Modification Log: Venkat [FET 4.0/4.1] project perspective
Modification Log: Venkat [FET 5.0] project perspective
****************************************************************************/
public without sharing class FSExecutionPlanTriggerHandler {
    
    public static final String CLASSNAME='FSExecutionPlanTriggerHandler';
    public static final String EQPAPINAME='FS_EP_Equipment_Package__c';
    public static final String TIAPINAME='FS_EP_Technician_Instructions__c';
    public static final String METHODEQP='createEquipmentPackage';
    public static final String METHODEQPUPDATE='updateEquipmentPackage';
    public static final String METHODEQPTI='createTechInstruction';
    public static Integer valOne = 1; 
    public static String onHold = FSConstants.onHolds ;  
    public static String onCancelled = FSConstants.IPCANCELLED ; 
    private static List<FS_EP_Equipment_Package__c> equipPackgList;
    public static Boolean valueOnce=true; 
    public static Map<Id, FS_Execution_Plan__c> mapNullCheck(){  return null;  }
    public static boolean platformCheckOnce=true;
    
    public static void afterUpdate(List<FS_Execution_Plan__c> newList, Map<Id, FS_Execution_Plan__c> oldMap){          
        boolean rollupChanged = false;
        for(FS_Execution_Plan__c EP : newList){
            if(EP.FS_of_Installations__c != oldmap.get(EP.id).FS_of_Installations__c){
                rollupChanged = True;
                break;
            }    
        }
        if(!rollupChanged){
            updateExecutionPlanStatus(newList, oldMap); //Ranjan added this for FET 2.1
            updateEquipmentPackage(newlist,oldMap); //Srinivas create Equipment package
            //FET 5.0-M
            checkPlatformOnEPandInstall(newlist,oldMap);
        }
    }   
    
    public static void afterInsert(List<FS_Execution_Plan__c> newList, Map<Id, FS_Execution_Plan__c> oldMap){ 
        updateExecutionPlanStatus(newList, oldMap); //Ranjan added this for FET 2.1
        createEquipmentPackage(newlist); //Srinivas create Equipment package
        FSExecutionPlanValidateAndSet.taskAllocation(newList, oldMap);//Venkat Created for task allocation as part for FET4.0        
    }    
    
    //Venkat added as part of FET 4.0 to update date/time field for every record at every Instance
    public static void beforeUpdate(List<FS_Execution_Plan__c> newList,Map<Id,FS_Execution_Plan__c> newMap,Map<Id, FS_Execution_Plan__c> oldMap,final Boolean isUpdate){       
        boolean rollupChanged = false;
        for(FS_Execution_Plan__c EP : newList){
            if(EP.FS_of_Installations__c != oldmap.get(EP.id).FS_of_Installations__c){
                rollupChanged = true;
                break;
            }    
        }
        if(!rollupChanged){
            FSExecutionPlanValidateAndSet.updateLocalTime(newList);
            //FET 5.0-M
            checkErrorOnEPPlatform(newlist,newMap,oldMap);
            updatePlatformTrackingFields(newlist,oldMap,isUpdate);
        } 
    }
    
    //Venkat added as part of FET 4.0 to update date/time field for every record at every Instance
    public static void beforeInsert(List<FS_Execution_Plan__c> newList,Map<Id,FS_Execution_Plan__c> oldMap,final Boolean isUpdate){        
        FSExecutionPlanValidateAndSet.updateLocalTime(newList); 
        updatePlatformTrackingFields(newlist,oldMap,isUpdate);
    }     
    
    // Method for updating Execution Plan Status on change of # of Installs Complete, # of Installations Cancelled and 
    //# of Installations on Execution Plan    
    public static void updateExecutionPlanStatus(List<FS_Execution_Plan__c> newList, Map<Id, FS_Execution_Plan__c> oldMap){       
        
        final List<Id> lstEPComplete = new List<Id>();
        final List<Id> lstEPCancel = new List<Id>();
        final List<Id> lstEPInProgress = new List<Id>();
        
        for (FS_Execution_Plan__c executionPlan : newList){
            if((oldMap!=mapNullCheck()) && (executionPlan.FS_of_Installs_Complete__c!= oldMap.get(executionPlan.id).FS_of_Installs_Complete__c
                                            || executionPlan.FS_of_Installations_Cancelled__c!= oldMap.get(executionPlan.id).FS_of_Installations_Cancelled__c
                                            || executionPlan.FS_of_Installations_OnHold__c!= oldMap.get(executionPlan.id).FS_of_Installations_OnHold__c
                                            || executionPlan.FS_of_Installations_Pending__c!= oldMap.get(executionPlan.id).FS_of_Installations_Pending__c
                                            || executionPlan.FS_of_Installations_Scheduled__c!= oldMap.get(executionPlan.id).FS_of_Installations_Scheduled__c)) {
                                                if((executionPlan.FS_of_Installs_Complete__c + executionPlan.FS_of_Installations_Cancelled__c==executionPlan.FS_of_Installations__c) && executionPlan.FS_of_Installs_Complete__c!=0){ //added criteria for defect 1426
                                                    lstEPComplete.add(executionPlan.id);
                                                }
                                                else if(executionPlan.FS_of_Installations_Cancelled__c==executionPlan.FS_of_Installations__c){
                                                    lstEPCancel.add(executionPlan.id);
                                                }
                                                else if(executionPlan.FS_of_Installs_Complete__c + executionPlan.FS_of_Installations_Cancelled__c!=executionPlan.FS_of_Installations__c){ //addition for defect 1426
                                                    lstEPInProgress.add(executionPlan.id);
                                                }
                                            }
        }
        if(!lstEPComplete.isEmpty() || !lstEPCancel.isEmpty() || !lstEPInProgress.isEmpty()){
            updateRelevantStatus(lstEPComplete,lstEPCancel,lstEPInProgress);//addition for defect 1426
        }        
    }
    
    public static void updateRelevantStatus(List<Id> lstEPComplete,List<Id> lstEPCancel,List<Id> lstEPInProgress) {
        //Creating error logger instance with required information
        final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSExecutionPlanTriggerHandler',
                                                                Method_Name__c='updateRelevantStatus',Object_Name__c='FS_Execution_Plan__c',
                                                                Error_Severity__c=FSConstants.MediumPriority);
        if(!lstEPComplete.isEmpty()){
            List<FS_Execution_Plan__c > toUpdate=[SELECT FS_Execution_Completion_Date__c,FS_Execution_Plan_Status__c FROM FS_Execution_Plan__c WHERE ID in :lstEPComplete];
            for (FS_Execution_Plan__c ep: toUpdate) {
                ep.FS_Execution_Plan_Status__c= 'Complete';
                ep.FS_Execution_Completion_Date__c=System.today();
            }            
            FSUtil.dmlProcessorUpdate(toUpdate,true,apexError);
        }
        if(!lstEPCancel.isEmpty()){
            List<FS_Execution_Plan__c > toUpdate=[SELECT FS_Execution_Completion_Date__c,FS_Execution_Plan_Status__c FROM FS_Execution_Plan__c WHERE ID in :lstEPCancel];
            for (FS_Execution_Plan__c ep: toUpdate) {
                ep.FS_Execution_Plan_Status__c= 'Cancelled';
                ep.FS_Execution_Completion_Date__c=null;
            }            
            FSUtil.dmlProcessorUpdate(toUpdate,true,apexError);            
        }
        if(!lstEPInProgress.isEmpty()){ //addition for defect 1426
            List<FS_Installation__c> allIPforEP=new List<FS_Installation__c>();
            List<FS_Installation__c> InProgressIp=new List<FS_Installation__c>();
            List<FS_Installation__c> OnHoldIp=new List<FS_Installation__c>();
            List<FS_Installation__c> CancelledIp=new List<FS_Installation__c>();
            Set<Id> epIdsInProgress=new Set<Id>();
            Set<Id> epIdsOnHold=new Set<Id>();
            List<FS_Execution_Plan__c > toUpdate=[SELECT FS_Execution_Completion_Date__c,FS_Execution_Plan_Status__c,(SELECT Name,Overall_Status2__c,FS_Execution_Plan__c,FS_Overall_Status__c,FS_Installation_Status__c FROM Outlet_Info_Summary__r ) FROM FS_Execution_Plan__c WHERE ID in :lstEPInProgress];
            for (FS_Execution_Plan__c ep: toUpdate) {
                for(FS_Installation__c  inst : ep.Outlet_Info_Summary__r){
                    allIPforEP.add(inst);
                    if(inst.FS_Overall_Status__c==onHold){
                        OnHoldIp.add(inst);
                    }
                    if(inst.FS_Overall_Status__c==onCancelled){
                        CancelledIp.add(inst);
                    }
                    if(inst.FS_Overall_Status__c!=null && (inst.FS_Overall_Status__c.contains('Pending')|| inst.FS_Overall_Status__c.contains('Schedul') ||  inst.FS_Overall_Status__c==FSConstants.SAComplete || inst.FS_Overall_Status__c==FSConstants.EQUIPMENTBOOKED)){
                        InProgressIp.add(inst);
                    }
                }                
            }
            Integer totalInstallinEP=allIPforEP.size();
            Integer totalOnHoldTnstallinEP=OnHoldIp.size();
            Integer totalCancelledTnstallinEP=CancelledIp.size();
            Integer totalInprogressTnstallinEP=InProgressIp.size();
            if(totalInprogressTnstallinEP>=valOne){
                for(FS_Installation__c  inst :InProgressIp){
                    epIdsInProgress.add(inst.FS_Execution_Plan__c);
                }
            }
            if(totalOnHoldTnstallinEP>0 && totalInprogressTnstallinEP==0){
                for(FS_Installation__c  inst :OnHoldIp){
                    epIdsOnHold.add(inst.FS_Execution_Plan__c);                    
                }
            }            
            if(!epIdsOnHold.isEmpty() && epIdsInProgress.isEmpty() ){
                for (List<FS_Execution_Plan__c> epList: [SELECT FS_Execution_Completion_Date__c,FS_Execution_Plan_Status__c FROM FS_Execution_Plan__c WHERE ID in :epIdsOnHold]){
                    for(FS_Execution_Plan__c ep:epList){
                        ep.FS_Execution_Plan_Status__c= 'On-Hold';
                        ep.FS_Execution_Completion_Date__c=null;
                    }                    
                    FSUtil.dmlProcessorUpdate(epList,true,apexError);            
                }
            }
            else if(!epIdsInProgress.isEmpty()){
                for (List<FS_Execution_Plan__c> epList: [SELECT FS_Execution_Completion_Date__c,FS_Execution_Plan_Status__c FROM FS_Execution_Plan__c WHERE ID in :epIdsInProgress]){
                    for(FS_Execution_Plan__c ep:epList){
                        ep.FS_Execution_Plan_Status__c= 'In Progress';
                        ep.FS_Execution_Completion_Date__c=null;
                    }
                    FSUtil.dmlProcessorUpdate(epList,true,apexError);            
                }                
            }           
        }
    }     
    
    /*****************************************************************
Method: updateEquipmentPackage
Description: updateEquipmentPackage method is used to create/delete Equipment Package and Technician instruction 
records based on the "Platform type" field on EP
Modified this method as part of FET 4.0/4.1
Modified: FET 5.0 US-53 & US-54 to create record with default record type
*******************************************************************/  
    public static void updateEquipmentPackage(List<FS_Execution_Plan__c> newList,Map<Id, FS_Execution_Plan__c> oldMap){
        //FET 5.0
        List<FS_EP_Equipment_Package__c> equipmentPackageList=new List<FS_EP_Equipment_Package__c>();
        List<FS_Execution_Plan__c> exePlanList=new List<FS_Execution_Plan__c>();
        List<FS_EP_Equipment_Package__c> delEQPList=new List<FS_EP_Equipment_Package__c>();
        List<FS_EP_Technician_Instructions__c> delTIList=new List<FS_EP_Technician_Instructions__c>();
        
        Set<String> delSet=new Set<String>();                
        Set<Id> exePlanIdSet=new Set<Id>();
        
        Map<String,FS_EP_Equipment_Package__c> mapEQP=new Map<String,FS_EP_Equipment_Package__c>();
        Map<String,FS_EP_Technician_Instructions__c> mapTI=new Map<String,FS_EP_Technician_Instructions__c>();
        Set<String> mainSet;
        Set<String> delSetTemp;
        Map<Set<String>,Set<String>> platformMap;
        FS_EP_Equipment_Package__c epEquip;
        String platform;
        //Static variable to avoid running this process multiple times
        if(valueOnce){  
            for(FS_Execution_Plan__c ep:newList){
                //listing down Execution plan Ids which have platform type value change
                if(ep.FS_Platform_Type__c!=oldMap.get(ep.Id).FS_Platform_Type__c){
                    exePlanList.add(ep);
                    exePlanIdSet.add(ep.Id);
                }
            }
            for(FS_Execution_Plan__c ep:exePlanList){
                
                mainSet=new Set<String>();
                delSetTemp=new Set<String>();
                platformMap=new Map<Set<String>,Set<String>>();
                
                platformMap=FSUtil.checkPlatformValues(ep.Id,ep.FS_Platform_Type__c,oldMap.get(ep.Id).FS_Platform_Type__c);
                for(Set<String> main:platformMap.keySet()){
                    mainSet=main;   
                    delSetTemp=platformMap.get(mainSet);
                } 
                //iterating delSetItems and adding in main deleted set
                for(String deleteValue:delSetTemp){
                    delSet.add(deleteValue);                    
                }      
                //Iterating Main set and creating new equipment package records based on new platforms
                for(String platformValue:mainSet){
                    epEquip=new FS_EP_Equipment_Package__c();                
                    epEquip.FS_Execution_Plan__c=ep.Id;
                    epEquip.FS_Platform_Type__c=platformValue;
                    epEquip.recordtypeId=FSExecutionPlanValidateAndSet.epEPrecType;
                    equipmentPackageList.add(epEquip);
                }
                valueOnce=false;
            } 
            
            if(!delSet.isEmpty()){
                //Storing all Equipment Package records under the execution plan
                for(FS_EP_Equipment_Package__c eqp:[select Id,Name,FS_Platform_Type__c,FS_Execution_Plan__c from FS_EP_Equipment_Package__c where FS_Execution_Plan__c IN:exePlanIdSet]){
                    platform=eqp.FS_Execution_Plan__c+eqp.FS_Platform_Type__c;
                    //Storing equipment Package records based on the platform values and Execution Plan in a map
                    mapEQP.put(platform, eqp);                
                }
                //Storing all Technician Instruction records under the execution plan
                for(FS_EP_Technician_Instructions__c techInst:[select Id,Name,FS_Platform_Type__c ,Execution_Plan__c from FS_EP_Technician_Instructions__c where Execution_Plan__c IN:exePlanIdSet]){
                    platform=techInst.Execution_Plan__c+techInst.FS_Platform_Type__c;
                    //Storing Technician Instruction records based on the platform values and Execution Plan in a map
                    mapTI.put(platform, techInst);                
                }
                //iterating delSet and storing the EQP and TI records in a list which need to be deleted
                for(String delValue:delSet){
                    if(mapEQP.containsKey(delValue)){
                        delEQPList.add(mapEQP.get(delValue));
                    }
                    if(mapTI.containsKey(delValue)){
                        delTIList.add(mapTI.get(delValue));
                    }
                }                
            }       
            if(!delEQPList.isEmpty()){
                //Creating error logger instance with required information
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODEQPUPDATE,Object_Name__c=EQPAPINAME,
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorDelete(delEQPList,true,apexError);
            }
            if(!delTIList.isEmpty()){
                //Creating error logger instance with required information
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODEQPUPDATE,Object_Name__c=TIAPINAME,
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorDelete(delTIList,true,apexError);
            }
            if(!equipmentPackageList.isEmpty()){
                //Creating error logger instance with required information
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODEQPUPDATE,Object_Name__c=EQPAPINAME,
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                Boolean success=FSUtil.dmlProcessorInsert(equipmentPackageList,true,apexError);            
                //create/Insert Technician Instructions
                if(success){
                    createTechInstruction(newlist,equipmentPackageList);
                }
            }
        }
    }
    
    /*****************************************************************
Method: createEquipmentPackage
Description: createEquipmentPackage method is used to create Equipment Package and Technician instruction 
records based on the "Platform type" field on EP
Modified this method as part of FET 4.0/4.1 
Modified: FET 5.0 US-53 to create record with default record type
*******************************************************************/  
    public static void createEquipmentPackage(List<FS_Execution_Plan__c> newList){ 
        
        List<FS_EP_Equipment_Package__c> equipmentPackageList=new List<FS_EP_Equipment_Package__c>();       
        List<String> platformType=new List<String>();
        FS_EP_Equipment_Package__c epEquip;
        for(FS_Execution_Plan__c ep:newList) { 
            String options=ep.FS_Platform_Type__c;
            
            if(options!=FSConstants.NULLVALUE){
                platformType=options.split(FSConstants.SEMICOLON);
                
                for(String platform:platformType){ 
                    //creating new Equipment package records based on platform values at Execution plan
                    epEquip=new FS_EP_Equipment_Package__c();
                    epEquip.FS_Execution_Plan__c=ep.Id;
                    epEquip.FS_Platform_Type__c=platform;                
                    epEquip.recordtypeId=FSExecutionPlanValidateAndSet.epEPrecType;          
                    equipmentPackageList.add(epEquip);            
                }
            }
        }        
        if(!equipmentPackageList.isEmpty()){
            //Creating error logger instance with required information
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c=METHODEQP,Object_Name__c=EQPAPINAME,
                                                                    Error_Severity__c=FSConstants.MediumPriority);
            //Inserting New Equipment Package records
            Boolean success=FSUtil.dmlProcessorInsert(equipmentPackageList,true,apexError);            
            //create/Insert Technician Instructions
            if(success){
                createTechInstruction(newlist,equipmentPackageList);
            }
        }
    } 
    
    /*****************************************************************
Method: createTechInstruction
Description: createTechInstruction method is used to create Technician instruction 
records based on the "Platform type" field on EP
Modified this method as part of FET 4.0/4.1
Modified: FET 5.0 US-54 to create record with default record type
*******************************************************************/ 
    public static void createTechInstruction(List<FS_Execution_Plan__c> newList,List<FS_EP_Equipment_Package__c> equipmentPackageList){
        //Collection to Store the tech instruction records
        List<FS_EP_Technician_Instructions__c> technicianInstructionList=new List<FS_EP_Technician_Instructions__c>();
        FS_EP_Technician_Instructions__c epTech;
        //iterating Equipment package list,creating tech instructions
        for(FS_EP_Equipment_Package__c equipPackageInstance: equipmentPackageList){
            epTech=new FS_EP_Technician_Instructions__c();            
            epTech.Execution_Plan__c=equipPackageInstance.FS_Execution_Plan__c;
            epTech.FS_Platform_Type__c=equipPackageInstance.FS_Platform_Type__c;
            epTech.recordtypeId=FSExecutionPlanValidateAndSet.epTIrecType;
            epTech.FS_EP_Equipment_Package__c=equipPackageInstance.Id;
            technicianInstructionList.add(epTech);         
        }    
        //mapping Equipment ids to Tech Instr
        if(!technicianInstructionList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c=METHODEQPTI,Object_Name__c=TIAPINAME,
                                                                    Error_Severity__c=FSConstants.MediumPriority);
            //Inserting New Technicain Instrcution records
            Boolean success=FSUtil.dmlProcessorInsert(technicianInstructionList,true,apexError);            
            if(success){               
                //Collection to store Recordtype and Technicain Instruction Id created in this context
                Map<String,Id> techInstructionRecordId=new Map<String,Id>();
                
                for(FS_EP_Technician_Instructions__c  techInstance: technicianInstructionList){
                    techInstructionRecordId.put(techInstance.FS_Platform_Type__c+techInstance.FS_EP_Equipment_Package__c,techInstance.Id);
                }                 
                //Link Equipment Package to respective Technician Instructions
                for(FS_EP_Equipment_Package__c equipPackageInstance: equipmentPackageList){
                    if(techInstructionRecordId.containsKey(equipPackageInstance.FS_Platform_Type__c+equipPackageInstance.Id)){
                        equipPackageInstance.FS_Related_Technician_Instruction__c=techInstructionRecordId.get(equipPackageInstance.FS_Platform_Type__c+equipPackageInstance.Id);
                    }                     
                }
            }
        }
        //Creating error logger instance with required information
        final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                Method_Name__c=METHODEQPTI,Object_Name__c=EQPAPINAME,
                                                                Error_Severity__c=FSConstants.MediumPriority);
        //Updating Equipment Package records
        FSUtil.dmlProcessorUpdate(equipmentPackageList,true,apexError);            
    } 
    //FET 5.0
    
    //FET 5.0
    /*****************************************************************
Method: checkErrorOnEPPlatform
Description: checkErrorOnEPPlatform method is used to create Equipment Package and Technician instruction 
records based on the "Platform type" field on EP
Modified this method as part of FET 4.0/4.1 
Modified: FET 5.0 US-53 to create record with default record type
*******************************************************************/  
    public static void checkErrorOnEPPlatform(List<FS_Execution_Plan__c> newList,Map<Id,FS_Execution_Plan__c> newMap,Map<Id,FS_Execution_Plan__c> oldMap){ 
        if(platformCheckOnce){
            Map<Id,FS_Execution_Plan__c> epWithinstallList=new Map<Id,FS_Execution_Plan__c>(
                [SELECT Id,FS_Platform_change_approved__c,FS_Platform_Type__c, (select id,Type_of_Dispenser_Platform__c from Outlet_Info_Summary__r where recordtypeId=:FSInstallationValidateAndSet.ipNewRecType)
                 from FS_Execution_Plan__c where Id IN:oldMap.keySet()]);
            for(FS_Execution_Plan__c ep:newList) {            
                if(ep.FS_Platform_Type__c!=oldMap.get(ep.Id).FS_Platform_Type__c || ep.FS_Platform_change_approved__c!=oldMap.get(ep.Id).FS_Platform_change_approved__c){
                    
                    Set<string> allIpPlatformSet=new Set<String>();
                    List<String> epPlatformList=new List<String>();
                    Boolean epAndIpNotInSync=false;
                    
                    FS_Execution_Plan__c exPlan=epWithinstallList.get(ep.Id);
                    if(ep.FS_Platform_Type__c!=FSConstants.NULLVALUE){                
                        epPlatformList = ep.FS_Platform_Type__c.split(FSConstants.SEMICOLON);
                    }
                    for(FS_Installation__c installationInstance:exPlan.Outlet_Info_Summary__r){
                        List<String> platformListInstall=new List<String>();
                        if(installationInstance.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){
                            platformListInstall=installationInstance.Type_of_Dispenser_Platform__c.split(FSConstants.SEMICOLON);
                            allIpPlatformSet.addAll(platformListInstall);
                        }
                    }
                    system.debug('allIpPlatformSet:-'+allIpPlatformSet);
                    for(string platform: epPlatformList){                    
                        if(!allIpPlatformSet.contains(platform) && !ep.FS_Platform_change_approved__c){
                            ep.FS_Platform_change_approved__c.addError(Label.EP_PlatformType_Sync_Error);
                        }
                        if(!allIpPlatformSet.contains(platform) && ep.FS_Platform_change_approved__c && !epAndIpNotInSync){
                            epAndIpNotInSync=true;
                        }                     
                    }                
                    for(string platform: allIpPlatformSet){                    
                        if(!ep.FS_Platform_Type__c.contains(platform) && !ep.FS_Platform_change_approved__c){
                            ep.FS_Platform_change_approved__c.addError(Label.EP_PlatformType_Sync_Error);
                        }
                        if(!ep.FS_Platform_Type__c.contains(platform) && ep.FS_Platform_change_approved__c && !epAndIpNotInSync){
                            epAndIpNotInSync=true;
                        }                     
                    }
                    ep.FS_Platform_Change_Check__c=epAndIpNotInSync;                
                    ep.FS_Platform_change_approved__c=false;
                    platformCheckOnce=false;
                }            
            } 
        }
    } 
    //FET 5.0-M
    /*****************************************************************
Method: checkPlatformOnEPandInstall
Description: checkPlatformOnEPandInstall method is used to create Equipment Package and Technician instruction 
records based on the "Platform type" field on EP
Modified this method as part of FET 4.0/4.1 
Modified: FET 5.0 US-53 to create record with default record type
*******************************************************************/  
    public static void checkPlatformOnEPandInstall(List<FS_Execution_Plan__c> newList,Map<Id,FS_Execution_Plan__c> oldMap){        
        Map<Id,Integer> installAllPlatformMap=new Map<Id,Integer>();
        Set<Id> epIdSet=new Set<Id>();
        List<FS_Installation__c> installListToUpdate=new List<FS_Installation__c>();
        
        Map<Id,FS_Execution_Plan__c> epWithinstallMap=new Map<Id,FS_Execution_Plan__c>(
            [SELECT Id,name,FS_Platform_change_approved__c,FS_Platform_Type__c, 
             (select id,name,FS_Platform_Change_Check__c,Type_of_Dispenser_Platform__c,Overall_Status2__c from Outlet_Info_Summary__r where Overall_Status2__c NOT IN (:FSConstants.IPCOMPLETE, :FSConstants.IPCANCELLED ) and recordtypeId=:FSInstallationValidateAndSet.ipNewRecType)
             from FS_Execution_Plan__c where Id IN:oldMap.keySet()]);     
        
        for(FS_Execution_Plan__c ep:newList) {
            if(ep.FS_Platform_Type__c!=oldMap.get(ep.Id).FS_Platform_Type__c && epWithinstallMap.containsKey(ep.id)){
                List<String> epPlatformList = ep.FS_Platform_Type__c.split(FSConstants.SEMICOLON);
                
                for(FS_Installation__c installationInstance:epWithinstallMap.get(ep.Id).Outlet_Info_Summary__r ){
                    
                    Boolean epAndIpNotInSync=false;
                    List<String> platformListInstall=new List<String>();
                    if(installationInstance.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){
                        platformListInstall=installationInstance.Type_of_Dispenser_Platform__c.split(FSConstants.SEMICOLON);                    
                    }
                    for(String platform: platformListInstall){
                        if(!ep.FS_Platform_Type__c.contains(platform) && !epAndIpNotInSync){
                            epAndIpNotInSync=true;
                        }                                        
                    }                                     
                    installationInstance.FS_Platform_Change_Check__c=epAndIpNotInSync;
                    installListToUpdate.add(installationInstance);                    
                }
            }
        }        
        if(!installListToUpdate.isEmpty()){            
            update installListToUpdate;
        }
        
    } 
    public static void updatePlatformTrackingFields(final List<FS_Execution_Plan__c> newEPList,final Map<id,FS_Execution_Plan__c> oldEPMap,final Boolean isUpdate){
        for(FS_Execution_Plan__c exec:newEPList){
            if(!isUpdate && exec.FS_Platform_Type__c!=FSConstants.NULLVALUE){
                exec.Platform_Type_History__c=UserInfo.getName()+', '+exec.FS_Local_Time__c+' EST'+', '+exec.FS_Platform_Type__c;
            }
            if(isUpdate && exec.FS_Platform_Type__c !=oldEPMap.get(exec.Id).FS_Platform_Type__c ){                
                exec.FS_Platforms_LastModifiedBy__c=UserInfo.getName() ;
                exec.FS_Platforms_LastModifiedDate__c=system.today();
                exec.Prior_Platform_Type_Value__c=oldEPMap.get(exec.Id).FS_Platform_Type__c;
                exec.Platform_Type_History__c=UserInfo.getName()+', '+exec.FS_Local_Time__c+' EST'+', '+exec.FS_Platform_Type__c;
                if(oldEPMap.get(exec.Id).Platform_Type_History__c!=FSConstants.NULLVALUE){
                    exec.Platform_Type_History__c+='\n'+oldEPMap.get(exec.Id).Platform_Type_History__c;
                }
            }           
        }
    }
}