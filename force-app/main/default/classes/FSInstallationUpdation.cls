/**************************
Name         : FSInstallationUpdation 
Created By   : Infosys
Created Date : 12/08/2016   
Usage        : This class holds the business logic of the InstallationTrigger
******************************/
public without sharing class FSInstallationUpdation{        
    
    public static boolean platformCheckOnce=true;
    //FET 7.0 FNF-462     
    public static boolean updateAMOACOMPLETEFromCase = false;
    public static boolean updateCaseIdInstall = false;
    public static boolean updateCaseAMSOnPendToNewOL = false;
    //FET 7.0 FNF-462
    public static final String FSInstallationUpdation = 'FSInstallationUpdation';
    public static final String SendEmailUpdateCaseAMSOnPendToNewOL = 'sendEmailUpdateCaseAMSOnPendToNewOL';
    
    public static final ID ipRecTypeRelocationO4W = FSInstallationValidateAndSet.ipRecTypeRelocationO4W;
    /**@desc: Set Overall_Status2__c  
*@param Trigger context variables(Trigger.new,Trigger.old,
Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate)
*@return void
*/
    public static void updateOverallStatus(final List<FS_Installation__c> newList,final Map<Id,FS_Installation__c> oldMap){
        
        //Criteria Block
        for(FS_Installation__c install : newList){
            
            if(install.RecordTypeId == FSInstallationValidateAndSet.ipNewRecType && oldMap.get(install.Id).Overall_Status2__c==install.Overall_Status2__c){                    
                
                if(install.FS_Survey_Install_Cancelled__c ) {                       
                    install.Overall_Status2__c = FSConstants.IPCANCELLED ;
                    
                } else if(install.FS_Survey_Install_On_Hold__c) {
                    install.Overall_Status2__c = FSConstants.onHolds;
                    
                } else if( install.FS_Davaco_SA_Status__c == FSConstants.SA_STATUSPENDING ) {
                    install.Overall_Status2__c = FSConstants.SAPending;
                    
                } else if( install.FS_Davaco_SA_Status__c == FSConstants.SA_STATUSSCHED ) {
                    install.Overall_Status2__c = FSConstants.SAschedule;
                    
                } else if(install.FS_Davaco_SA_Status__c == FSConstants.SA_COMPLETE &&  install.FS_Execution_Plan_Final_Approval_PM__c !=FSConstants.IPEPAPPROVED) {
                    install.Overall_Status2__c = FSConstants.SAComplete;
                    
                } else if(install.FS_Davaco_SA_Status__c == FSConstants.SA_COMPLETE && !install.FS_Execution_Plan_100_Complete__c ) {
                    install.Overall_Status2__c = FSConstants.SAComplete ;
                    //FET 5.0 New Transaction Status Equipment Booked
                } else if(install.FS_Davaco_SA_Status__c == FSConstants.SA_COMPLETE && install.FS_Equipment_Booked__c  
                          /*&& install.FS_Survey_Status__c == FSConstants.SPSURVEY*/// Removed as part of FNF-843
                          && install.FS_Installation_Status__c == FSConstants.SA_PENDING) {
                              install.Overall_Status2__c = FSConstants.EQUIPMENTBOOKED;
                              
                          } else if(install.FS_Davaco_SA_Status__c == FSConstants.SA_COMPLETE && 
                                    /*&& install.FS_Survey_Status__c == FSConstants.SPSURVEY*/// Removed as part of FNF-843 
                                    install.FS_Installation_Status__c == FSConstants.SA_PENDING && install.FS_Execution_Plan_100_Complete__c && !install.FS_Pending_for_Reschedule__c) {
                                        install.Overall_Status2__c = FSConstants.x1ReadySchedule ;
                                        
                                    } else if(install.FS_Davaco_SA_Status__c == FSConstants.SA_COMPLETE && install.FS_Installation_Status__c == FSConstants.SA_PENDING &&
                                              install.FS_Pending_for_Reschedule__c) {
                                                  install.Overall_Status2__c =  FSConstants.x3PendingSchedu ;
                                                  
                                              } else if(install.FS_Davaco_SA_Status__c == FSConstants.SA_COMPLETE  && install.FS_Installation_Status__c == FSConstants.x4InstallSchedule &&
                                                        !install.FS_Pending_for_Reschedule__c && install.FS_Execution_Plan_100_Complete__c && !install.FS_Platform_Change_Check__c ) {
                                                            install.Overall_Status2__c = FSConstants.x4InstallSchedule ;
                                                            
                                                        } else if(install.FS_Davaco_SA_Status__c == FSConstants.SA_COMPLETE && install.FS_Installation_Status__c == FSConstants.IPCOMPLETE) {
                                                            install.Overall_Status2__c = FSConstants.IPCOMPLETE ;
                                                        }                                                          
            } 
        }
    }
    
    
    /*****************************************************************
Method: updatePIAOverallStatus
Description: updatePIAOverallStatus method is to updated transaction status on PIA 
Added as part of FET 5.0, //Sprint 7 - 595/597/598/599
*******************************************************************/  
   
    public static void updatePIAOverallStatus(final List<FS_Installation__c> newList,final Map<Id,FS_Installation__c> oldMap){
        //Criteria Block
        final Set<Id> installId=new Set<Id>();
        //FET-1249 Changes Start
        List<FS_Outlet_Dispenser__c> odRecList=new List<FS_Outlet_Dispenser__c>();
        //FET-1249 Changes End         
        for(FS_Installation__c install : newList){            
            if(install.RecordTypeId != FSInstallationValidateAndSet.ipNewRecType ){
                installId.add(install.id);
            }
        }
        
        Map<Id,FS_Installation__c> installMap =new Map<Id,FS_Installation__c>
            ([select id,name,(select id,FS_Equip_Type__c,Relocated_Installation__c from Outlet_Dispensers1__r), (select id,FS_Equip_Type__c,FS_Other_PIA_Installation__c from Outlet_Dispensers2__r) from FS_Installation__c where id IN:installId]);       
       
        
        for(FS_Installation__c install : newList){
            //FET-1249 Changes Start to Store list of OD for the PIA based on Record type From 2 lookup fields
            odRecList=installMap.containsKey(install.Id)?(install.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation?installMap.get(install.Id).Outlet_Dispensers1__r:installMap.get(install.Id).Outlet_Dispensers2__r):new List<FS_Outlet_Dispenser__c>();
            //FET-1249 Changes END
            if(install.RecordTypeId != FSInstallationValidateAndSet.ipNewRecType && oldMap.get(install.Id).Overall_Status2__c==install.Overall_Status2__c){                    
                if(install.FS_Cancelled_oH__c==FSConstants.IPCANCELLED){
                    install.Overall_Status2__c=FSConstants.IPCANCELLED;
                    
                } else if(install.FS_Cancelled_oH__c==FSConstants.onHolds){
                    install.Overall_Status2__c=FSConstants.onHolds;
                    
                } 
                if((install.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRemoval || install.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeReplacement ) &&
                   (install.FS_Cancelled_oH__c==FSConstants.NULLVALUE || oldMap.get(install.Id).Overall_Status2__c==FSConstants.STATUS_COMPLETE) &&
                   install.FS_Activity_Complete__c && install.FS_Equipment_Booked__c && install.FS_Scheduled_Install_Date__c!=FSConstants.NULLVALUE && 
                   install.FS_Install_Doc__c!=FSConstants.NULLVALUE){
                       install.Overall_Status2__c=FSConstants.STATUS_COMPLETE;
                       
                   } else if(install.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation  &&
                             (install.FS_Cancelled_oH__c==FSConstants.NULLVALUE || oldMap.get(install.Id).Overall_Status2__c==FSConstants.STATUS_COMPLETE) &&
                             install.FS_Activity_Complete__c && install.FS_Scheduled_Install_Date__c!=FSConstants.NULLVALUE && install.FS_relocation_new_outlet_Complete__c && 
                             install.FS_Relocation_from_old_outlet_to_SP_is__c && install.FS_Install_Reconnect_Date__c!=FSConstants.NULLVALUE && install.FS_Remove_Disconnect_Date__c!=null && 
                             install.FS_Install_Doc__c!=FSConstants.NULLVALUE && install.FS_Disposition_of_Dispenser_Upon_Removal__c==FSConstants.dispBackatLocation){
                                 install.Overall_Status2__c=FSConstants.STATUS_COMPLETE;
                                 //FET 7.0 FNF-462 updating criteria w.r.t new AMOA status picklist                      
                             } else if(install.RecordTypeId==ipRecTypeRelocationO4W  && 
                             (install.FS_Cancelled_oH__c==FSConstants.NULLVALUE || oldMap.get(install.Id).Overall_Status2__c==FSConstants.STATUS_COMPLETE) &&  
                             install.FS_Activity_Complete__c && install.FS_Scheduled_Install_Date__c!=FSConstants.NULLVALUE && 
                             install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOACOMPLETE && install.FS_Relocation_from_old_outlet_to_SP_is__c && 
                             install.FS_Install_Doc__c!=FSConstants.NULLVALUE && install.FS_Disposition_of_Dispenser_Upon_Removal__c==FSConstants.removedAndShipped){
                                 install.Overall_Status2__c=FSConstants.STATUS_COMPLETE;
                                 
                             } else if(install.FS_Cancelled_oH__c==FSConstants.NULLVALUE && install.RecordTypeId==ipRecTypeRelocationO4W && 
                             install.FS_Original_Install_Date__c!=null && install.FS_Relocation_from_old_outlet_to_SP_is__c && (install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOAREMOVAL || 
                             install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOASUBMIT) && (install.FS_Disposition_of_Dispenser_Upon_Removal__c==FsConstants.removedAndTakenTOSp || 
                             install.FS_Disposition_of_Dispenser_Upon_Removal__c== FSConstants.disconnctedAndBackroom)){
                                 install.Overall_Status2__c=FsConstants.PIA_PENDINGTONEWOUTLET;
                                 if(install.FS_IsPendingToNewOutlet__c != FSConstants.BOOL_VAL && install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOASUBMIT){
                                     install.FS_IsPendingToNewOutlet__c = FSConstants.BOOL_VAL;
                                 }
                                 //FET 7.0 FNF-462 updating criteria w.r.t new AMOA status picklist                                            
                             } else if(install.FS_Cancelled_oH__c==FSConstants.NULLVALUE && install.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation && 
                             install.FS_Original_Install_Date__c!=null &&  install.FS_Relocation_from_old_outlet_to_SP_is__c && install.FS_Install_Reconnect_Date__c==FSConstants.NULLVALUE && 
                             !install.FS_relocation_new_outlet_Complete__c && (install.FS_Disposition_of_Dispenser_Upon_Removal__c==FsConstants.removedAndTakenTOSp || 
                             install.FS_Disposition_of_Dispenser_Upon_Removal__c==FSConstants.disconnctedAndBackroom)){
                                 install.Overall_Status2__c=FSConstants.PIA_pendingINSTALLRECONNECT;
                                 
                             } else if(install.FS_Cancelled_oH__c==FSConstants.NULLVALUE && !install.FS_Activity_Complete__c && install.FS_Scheduled_Install_Date__c!=FSConstants.NULLVALUE){
                                 install.Overall_Status2__c=FSConstants.x4InstallSchedule;
                                 
                             } else if(install.FS_Cancelled_oH__c==FSConstants.NULLVALUE && install.FS_Pending_for_Reschedule__c && install.FS_Original_Install_Date__c!=FSConstants.NULLVALUE && 
                             install.FS_Scheduled_Install_Date__c==FSConstants.NULLVALUE){
                                 install.Overall_Status2__c=FSConstants.x3PendingSchedu;
                                 
                             } else if(install.FS_Cancelled_oH__c==FSConstants.NULLVALUE && install.FS_Outlet__c!=FSConstants.NULLVALUE && install.FS_Entering_COM__c!=FSConstants.NULLVALUE && 
                             install.FS_PM_Execution__c!=FSConstants.NULLVALUE && install.FS_Scope_of_Work__c!=FSConstants.NULLVALUE && 
                             install.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE && install.FS_Reason_Code__c!=FSConstants.NULLVALUE && 
                             install.FS_Sub_Reason_Code__c!=FSConstants.NULLVALUE){
                                 install.Overall_Status2__c=FSConstants.x1ReadySchedule;
                             } 
                //FET-1249 Changes Start Checking the OD rec List Empty or Not to show Error message when IP is Cancelled 
                if(install.RecordTypeId != FSInstallationValidateAndSet.ipNewRecType && install.Overall_Status2__c==FSConstants.IPCANCELLED && !odRecList.isEmpty() ){
                    install.addError(Label.IP_Disp_Sec_Cancel_Error);
                }  
                //FET-1249 Changes End
            }    
            if(installMap.ContainsKey(install.Id) && install.RecordTypeId != FSInstallationValidateAndSet.ipNewRecType && oldMap.get(install.Id).Type_of_Dispenser_Platform__c!=install.Type_of_Dispenser_Platform__c){
                install.FS_DispRequested1__c=install.FS_Platform1__c!=FSConstants.NULLVALUE?FSConstants.ZERO:null;
                install.FS_DispRequested2__c=install.FS_Platform2__c!=FSConstants.NULLVALUE?FSConstants.ZERO:null;
                install.FS_DispRequested3__c=install.FS_Platform3__c!=FSConstants.NULLVALUE?FSConstants.ZERO:null;
                
                //FET-1249 Changes Start iterating the List of OD records based on the PIA record               
                for(FS_Outlet_Dispenser__c odRec:odRecList){
                    //FET-1249 Changes End
                    if(install.FS_Platform1__c!=FSConstants.NULLVALUE && odRec.FS_Equip_Type__c==install.FS_Platform1__c){
                        install.FS_DispRequested1__c=(install.FS_DispRequested1__c!=FSConstants.NULLVALUE && install.FS_DispRequested1__c!=FSConstants.ZERO)?install.FS_DispRequested1__c+FSConstants.NUM_1:FSConstants.NUM_1;
                    }
                    else if(install.FS_Platform2__c!=FSConstants.NULLVALUE && odRec.FS_Equip_Type__c==install.FS_Platform2__c){
                        install.FS_DispRequested2__c=(install.FS_DispRequested2__c!=FSConstants.NULLVALUE && install.FS_DispRequested2__c!=FSConstants.ZERO)?install.FS_DispRequested2__c+FSConstants.NUM_1:FSConstants.NUM_1;
                    }
                    else if(install.FS_Platform3__c!=FSConstants.NULLVALUE && odRec.FS_Equip_Type__c==install.FS_Platform3__c){
                        install.FS_DispRequested3__c=(install.FS_DispRequested3__c!=FSConstants.NULLVALUE && install.FS_DispRequested3__c!=FSConstants.ZERO)?install.FS_DispRequested3__c+FSConstants.NUM_1:FSConstants.NUM_1;
                    } 
                }
            }
        }            
    }   
    
    /**@desc: Updated Installation's Outlet Latest Installation Status
*@param Trigger context variables(Trigger.new,Trigger.oldMap,
Trigger.isInsert,Trigger.isUpdate) and 
Map<Id, Sobject> sobjectsToUpdate
*@return void
*/
    public static void updateOutletWithLatestInstallationStatus(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap,
                                                                final Boolean isInsert,final Boolean isUpdate,final Map<Id, Sobject> sobjectsToUpdate){
                                                                    //Collection to hold Installation's Outlet Id
                                                                    final Set<Id> setOutletId = new Set<Id>();
                                                                    //Collection to hold Outlet Id and Installation Status
                                                                    final Map<Id, String> outletAndInstallationStatusMap = new Map<Id, String>();
                                                                    //Criteria block
                                                                    for(FS_Installation__c installationInstance: newInstallList){
                                                                        if(installationInstance.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && 
                                                                           installationInstance.Overall_Status2__c!=FSConstants.IPCOMPLETE  && installationInstance.Overall_Status2__c!=FSConstants.IPCANCELLED 
                                                                           && ((isInsert && installationInstance.FS_Outlet__c!=null) || 
                                                                               (isUpdate && installationInstance.FS_Outlet__c!=oldInstallMap.get(installationInstance.Id).FS_Outlet__c))){
                                                                                   setOutletId.add(installationInstance.FS_Outlet__c);
                                                                                   outletAndInstallationStatusMap.put(installationInstance.FS_Outlet__c,installationInstance.Overall_Status2__c);
                                                                               }      
                                                                    }  
                                                                    //Set Installation Status value to Outlet
                                                                    if(!setOutletId.isEmpty()){
                                                                        for(Account outletAccount :[SELECT Id, Name, Latest_Installation_Status__c FROM Account WHERE Id IN :setOutletId]){
                                                                            if(sObjectsToUpdate.containskey(outletAccount.Id)){
                                                                                final Account accObj=(Account)sObjectsToUpdate.get(outletAccount.Id);
                                                                                accObj.Latest_Installation_Status__c =outletAndInstallationStatusMap.get(outletAccount.Id);
                                                                                sObjectsToUpdate.put(accObj.Id,accObj);
                                                                            }else{
                                                                                sObjectsToUpdate.put(outletAccount.Id,new Account(Id=outletAccount.Id,Latest_Installation_Status__c =outletAndInstallationStatusMap.get(outletAccount.Id)));
                                                                            }
                                                                        }
                                                                    }
                                                                }

    //FET 5.0-M
    /**@desc: UpdatePlatformFields(platform1,platform2,platform3) based on 
*the multiselect platform type picklist
*@param Trigger context variables(Trigger.new)
*@return void
*/
    public static void updatePlatformFields(final List<FS_Installation__c> newList){ 
        //Iterate through the instllations
        String platform=FSConstants.BLANKVALUE;
        string existPlatform=FSConstants.BLANKVALUE;
        for(FS_Installation__c install: newList){
            platform=install.Type_of_Dispenser_Platform__c;
            existPlatform=FSConstants.BLANKVALUE;
            if(string.isNotBlank(platform)){                  
                List<string> platformList=new List<string>();
                final List<Integer> platformIntList=new List<Integer>();
                //Make the platform null if the platform is removed from the multiselect picklist(dispenser platform type)        
                if(string.isNotBlank(install.FS_Platform1__c) && !platform.contains(install.FS_Platform1__c)){ 
                    install.FS_Platform1__c=FSConstants.BLANKVALUE;
                    install.FS_Mrkt_ActiveDate1__c=FSConstants.DATE_NULL;
                    install.FS_DispRequested1__c=FSConstants.DECIMALNULL;                         
                    install.FS_DispOrder1__c=FSConstants.DECIMALNULL;                         
                }
                if(string.isNotBlank(install.FS_Platform2__c) && !platform.contains(install.FS_Platform2__c)){
                    install.FS_Platform2__c=FSConstants.BLANKVALUE;
                    install.FS_Mrkt_ActiveDate2__c=FSConstants.DATE_NULL;
                    install.FS_DispRequested2__c=FSConstants.DECIMALNULL;                         
                    install.FS_DispOrder2__c=FSConstants.DECIMALNULL;                        
                }
                if(string.isNotBlank(install.FS_Platform3__c) && !platform.contains(install.FS_Platform3__c)){
                    install.FS_Platform3__c=FSConstants.BLANKVALUE;
                    install.FS_Mrkt_ActiveDate3__c=FSConstants.DATE_NULL;
                    install.FS_DispRequested3__c=FSConstants.DECIMALNULL;                         
                    install.FS_DispOrder3__c=FSConstants.DECIMALNULL;                         
                }
                try{
                    //identify the existing platforms and add it to a string to avoid duplicates
                    existPlatform=install.FS_Platform1__c+install.FS_Platform2__c+install.FS_Platform3__c;
                    platformList=platform.split(FSConstants.SEMICOLON);                
                    for(string platformType:platformList){   
                        if(string.isNotBlank(platformType)){                          
                            platformIntList.add(Integer.valueOf(platformType));
                        }                  
                    } 
                    platformIntList.sort();
                }
                Catch(StringException ex){
                 ApexErrorLogger.addApexErrorLog(FSConstants.FET,FSInstallationUpdation,SendEmailUpdateCaseAMSOnPendToNewOL,FSConstants.NA,FSConstants.MediumPriority,ex,FSConstants.NA);
                    
                }
                //The newly added platform will be added to the blank platform field and existing ones will be ignored
                //The Dispensers requested and Planned top ice fields will be filled with 0
                if(!platformIntList.isEmpty()){                      
                    for(Integer platformInt:platformIntList){                          
                        //the platform should be blank and the new platform value should not be present in other platform fields
                        if(string.isBlank(install.FS_Platform1__c) && !existPlatform.contains(string.valueOf(platformInt))){                              
                            install.FS_Platform1__c=string.valueOf(platformInt);
                            install.FS_DispRequested1__c=FSConstants.ZERO;                              
                        }
                        else if(string.isBlank(install.FS_Platform2__c) && !existPlatform.contains(string.valueOf(platformInt))){
                            install.FS_Platform2__c=string.valueOf(platformInt);
                            install.FS_DispRequested2__c=FSConstants.ZERO;                                      
                        }
                        else if(string.isBlank(install.FS_Platform3__c) && !existPlatform.contains(string.valueOf(platformInt))){
                            install.FS_Platform3__c=string.valueOf(platformInt);
                            install.FS_DispRequested3__c=FSConstants.ZERO;                                      
                        }
                    }
                }
            }   
        }
    }
    //FET 5.0-M
    /**@desc: checkPlatformOnEPandInstall method checks whether the platforms selected on Installation are available on the 
parent Execution Plan. If the platforms are not available on the execution plan, an error will be thrown
*@param Trigger context variables(Trigger.new)
*@return void
*/
    public static void checkPlatformOnEPandInstall(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap,final Map<Id, Sobject> sobjectsToUpdate){
        
        final Set<ID> epIDSet = new Set<ID>();
        final Set<ID> installIDSet = new Set<ID>();
        if(platformCheckOnce){
            for(FS_Installation__c inst:newInstallList){
                if(inst.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && inst.Type_of_Dispenser_Platform__c!=oldInstallMap.get(Inst.Id).Type_of_Dispenser_Platform__c || 
                inst.Platform_change_approved__c!=oldInstallMap.get(Inst.Id).Platform_change_approved__c){
                    epIDSet.add(inst.FS_Execution_Plan__c);                 
                    installIDSet.add(inst.id);
                }
            }
            final Map<Id,FS_Execution_Plan__c> epWithinstallList=new Map<Id,FS_Execution_Plan__c>(
                [SELECT Id,FS_Platform_change_approved__c,FS_Platform_Type__c,(select id,Type_of_Dispenser_Platform__c from Outlet_Info_Summary__r) from FS_Execution_Plan__c where Id IN:epIDSet]);       
            try{
                for(FS_Installation__c installationInstance: newInstallList){              
                    if(installIDSet.contains(installationInstance.id)){
                        
                        List<String> platformListInstall=new List<String>();
                        List<String> platformListEP=new List<String>();
                        final Set<string> allIpPlatformSet=new Set<String>();
                        Boolean epAndIpNotInSync=false;
                        
                        final FS_Execution_Plan__c epItem=epWithinstallList.get(installationInstance.FS_Execution_Plan__c);
                        if(epItem.FS_Platform_Type__c!=FSConstants.NULLVALUE){
                            platformListEP= epItem.FS_Platform_Type__c.split(FSConstants.SEMICOLON);
                        }
                        if(installationInstance.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){
                            platformListInstall=installationInstance.Type_of_Dispenser_Platform__c.split(FSConstants.SEMICOLON);
                            allIpPlatformSet.addAll(platformListInstall);
                        }
                        
                        for(FS_Installation__c install:epItem.Outlet_Info_Summary__r){
                            if(install.Id!=installationInstance.Id){
                                List<String> platformInstallList=new List<String>(); 
                                if(install.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){
                                    platformInstallList=install.Type_of_Dispenser_Platform__c.split(FSConstants.SEMICOLON);
                                    allIpPlatformSet.addAll(platformInstallList);
                                }
                            }                  
                        }                    
                        for(String platform: platformListInstall){
                            if(!epItem.FS_Platform_Type__c.contains(platform) && !installationInstance.Platform_change_approved__C){
                                installationInstance.Platform_change_approved__C.addError(Label.IP_PlatformType_Sync_Error);
                            }
                            if(!epItem.FS_Platform_Type__c.contains(platform) && installationInstance.Platform_change_approved__C && !epAndIpNotInSync){
                                epAndIpNotInSync=true;
                            }                                        
                        }                   
                        for(string platform: platformListEP){ 
                            if(!allIpPlatformSet.contains(platform) && !installationInstance.Platform_change_approved__C){
                                installationInstance.Platform_change_approved__c.addError(Label.IP_PlatformType_Sync_Error);
                            }                                                                
                        }                   
                        installationInstance.FS_Platform_Change_Check__c=epAndIpNotInSync;
                        installationInstance.Platform_change_approved__C=false;
                        platformCheckOnce=false;
                    }
                }
            }
            catch(Exception Ex){
                ApexErrorLogger.addApexErrorLog(FSConstants.FET,FSInstallationUpdation,SendEmailUpdateCaseAMSOnPendToNewOL,FSConstants.NA,FSConstants.MediumPriority,ex,FSConstants.NA);
                
            }
        }
    }
    /*****************************End of checkPlatformOnEPandInstall method******************************************/
    
    /**@desc: updateEpPlatformCheck method checks whether the platforms selected on Installation are available on the 
parent Execution Plan. If the platforms are not available on the execution plan, an error will be thrown
*@param Trigger context variables(Trigger.new)
*@return void
*/
    public static void updateEpPlatformCheck(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap,final Map<Id, Sobject> sobjectsToUpdate){ 
        final Set<ID> epIDSet = new Set<ID>();                
        
        for(FS_Installation__c inst:newInstallList){
            if(inst.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && inst.Type_of_Dispenser_Platform__c!=oldInstallMap.get(Inst.Id).Type_of_Dispenser_Platform__c){
                epIDSet.add(inst.FS_Execution_Plan__c);          
            }
        }
        for(Id epId:epIDSet){            
            if(sobjectsToUpdate.containsKey(epId)){
                final FS_Execution_Plan__c exeObj = (FS_Execution_Plan__c)sObjectsToUpdate.get(epId);
                exeObj.FS_Platform_change_approved__c=true;
                sobjectsToUpdate.put(epId, exeObj);
            }
            else{
                sobjectsToUpdate.put(epId, new FS_Execution_Plan__c(Id=epId,FS_Platform_change_approved__c=true));
            }            
        }        
    }
    /*****************************End of checkPlatformOnEPandInstall method******************************************/
    
    /**@desc: Updated FS_Local_Time__c (Local Time) to show 
organisation time based on EDT with daylight saving
*@param Trigger context variables(Trigger.new)
*@return void
*/
    public static void updateLocaltimeFieldInstallation(final List<FS_Installation__c> newInstallList){  
        Datetime dateValue=DateTime.now(); 
        // Eastern Daylight Saving Time Check 
        if(DateTime.now().month()== 1 || DateTime.now().month()== 2 || DateTime.now().month()== 3 
           || DateTime.now().month()== 11 || DateTime.now().month()== 12) {
               dateValue= DateTime.now().addHours(-5); 
           } else {
               dateValue= DateTime.now().addHours(-4); 
           }
        final String srcString=String.valueof(dateValue.formatGMT('YYYY-MM-dd hh:mm:ss a'));
        for(FS_Installation__c installationInstance: newInstallList){
            installationInstance.FS_Send_email_to_footprint__c=false; //Footprint default
            installationInstance.FS_Local_Time__c=srcString;
        }
    }
    /**@desc: Updated Installation's Execution Plan Status  
to 'In Progress' or 'On-Hold'
*@param List<FS_Installation__c> newInstallList and 
Map<Id,FS_Installation__c> oldInstallMap
*@return void
*/
    public static void updateExecutionPlanStatus(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap,final Map<Id, Sobject> sobjectsToUpdate){
        //Collection variable to store records to be processed, that meet the criteria
        final List<FS_Installation__c> installationsToBeProcessed=new List<FS_Installation__c>();
        //Collection variable to store execution plan Ids of intallation records 
        //to be processed that meet the criteria
        final Set<Id> executionPlanIds=new Set<Id>();         
        //Criteria Check Block
        for(FS_Installation__c installationInstance : newInstallList){
            if(installationInstance.recordTypeId==FSInstallationValidateAndSet.ipNewRecType && !String.isBlank(installationInstance.Overall_Status2__c) 
               && installationInstance.Overall_Status2__c!=oldInstallMap.get(installationInstance.Id).Overall_Status2__c){
                   installationsToBeProcessed.add(installationInstance);
                   if(installationInstance.FS_Execution_Plan__c!=FSConstants.NULLVALUE){
                       executionPlanIds.add(installationInstance.FS_Execution_Plan__c);
                   }
               }
            else {
                return;
            }
        }
        //Business Logic Start
        if(!installationsToBeProcessed.isEmpty() && !executionPlanIds.isEmpty()){
            //Collection variable to store all Installation under the execution Plan
            final List<FS_Installation__c> allInstallationsUnderExecutionPlanList=new List<FS_Installation__c>();
            //Collection variable to store all Installation that have Overall_Status2__c 
            //as PENDING or 'Scheduled' under the execution Plan
            final List<FS_Installation__c> installationInProgressList=new List<FS_Installation__c>();
            //Collection variable to store all Installation that have
            // Overall_Status2__c as ON_HOLD under the execution Plan
            final List<FS_Installation__c> installationOnHoldList=new List<FS_Installation__c>();
            //Retrieve all Installations under the current Installation's Execution Plan
            for(FS_Execution_Plan__c executionInstance: [SELECT Name ,(SELECT Name,Overall_Status2__c,FS_Execution_Plan__c,FS_Overall_Status__c,FS_Installation_Status__c FROM Outlet_Info_Summary__r ) FROM FS_Execution_Plan__c where id in:executionPlanIds]){
                for(FS_Installation__c  installationInstance :executionInstance.Outlet_Info_Summary__r){
                    allInstallationsUnderExecutionPlanList.add(installationInstance);
                    if(installationInstance.FS_Overall_Status__c==FSConstants.onHolds) {
                        installationOnHoldList.add(installationInstance);
                    }
                    if(!String.isBlank(installationInstance.FS_Overall_Status__c) && 
                       (installationInstance.FS_Overall_Status__c.contains(FSConstants.SA_PENDING)
                        || installationInstance.FS_Overall_Status__c.contains('Schedul')
                        || installationInstance.FS_Overall_Status__c == FSConstants.SAComplete
                        || installationInstance.FS_Overall_Status__c == FSConstants.EQUIPMENTBOOKED)) {
                            installationInProgressList.add(installationInstance);
                        }
                } 
            }
            //Count of Installation records based on Overall Status
            final Integer totalTnstallaionUnderEP=allInstallationsUnderExecutionPlanList.size();
            final Integer totalOnHoldTnstallaionUnderEP=installationOnHoldList.size();
            final Integer totalInprogressTnstallaionUnderEP=installationInProgressList.size();
            if(totalInprogressTnstallaionUnderEP>=FSConstants.NUM_1){
                //Collection to Store Execution Plan Ids that are to be 
                //updated to 'In Progress' Status
                final  Set<Id> executionPlanWithInprogressStatus=new Set<Id>();
                for(FS_Installation__c  installationInstance :installationInProgressList){
                    executionPlanWithInprogressStatus.add(installationInstance.FS_Execution_Plan__c);
                }
                if(!executionPlanWithInprogressStatus.isEmpty()){
                    for(Id executionPlanId : executionPlanWithInprogressStatus){
                        if(sObjectsToUpdate.containskey(executionPlanId)){
                            final FS_Execution_Plan__c executionPlanObj=(FS_Execution_Plan__c)sObjectsToUpdate.get(executionPlanId);
                            executionPlanObj.FS_Execution_Plan_Status__c=FSConstants.EP_INPROGRESS;
                            executionPlanObj.FS_Execution_Completion_Date__c=null;
                            executionPlanObj.FS_Equipment_Package_Insert_Check__c=true;
                            sObjectsToUpdate.put(executionPlanObj.Id,executionPlanObj);
                        }else{
                            sObjectsToUpdate.put(executionPlanId,new FS_Execution_Plan__c(Id=executionPlanId,
                                                                                          FS_Execution_Plan_Status__c=FSConstants.EP_INPROGRESS,
                                                                                          FS_Execution_Completion_Date__c=null,
                                                                                          FS_Equipment_Package_Insert_Check__c=true));
                        }
                    }
                }
            }
            else if(totalOnHoldTnstallaionUnderEP==totalTnstallaionUnderEP){
                //Collection to Store Execution Plan Ids that are to 
                //be updated to 'On Hold' Status
                final Set<Id> executionPlanWithOnHoldStatus=new Set<Id>();
                for(FS_Installation__c  installationInstance :installationOnHoldList){
                    executionPlanWithOnHoldStatus.add(installationInstance.FS_Execution_Plan__c);
                }
                if(!executionPlanWithOnHoldStatus.isEmpty()){
                    for(Id executionPlanId : executionPlanWithOnHoldStatus){
                        if(sObjectsToUpdate.containskey(executionPlanId)){
                            final FS_Execution_Plan__c executionPlanObj=(FS_Execution_Plan__c)sObjectsToUpdate.get(executionPlanId);
                            executionPlanObj.FS_Execution_Plan_Status__c=FSConstants.EP_ONHOLD;
                            executionPlanObj.FS_Execution_Completion_Date__c=null;
                            executionPlanObj.FS_Equipment_Package_Insert_Check__c=true;
                            sObjectsToUpdate.put(executionPlanObj.Id,executionPlanObj);
                        }
                        else{
                            sObjectsToUpdate.put(executionPlanId,new FS_Execution_Plan__c(Id=executionPlanId,
                                                                                          FS_Execution_Plan_Status__c=FSConstants.EP_ONHOLD,
                                                                                          FS_Execution_Completion_Date__c=null,
                                                                                          FS_Equipment_Package_Insert_Check__c=true));
                        } 
                    } 
                }  
            }
        }
    }
    /**@desc: Updated Outlet's Latest Installation Status
when a Installation is Deleted
*@param List<FS_Installation__c> oldInstallList and 
Map<Id, Sobject> sobjectsToUpdate
*@return void
*/ 
    public static void updateOutletWithLatestInstallationStatusOnDelete(final List<FS_Installation__c> oldInstallList,final Map<Id, Sobject> sobjectsToUpdate){
        //Collection to Store Deleted Installation's Outlet Id and Overall Status
        final Map<Id,String> mapOfOutletIdAndOverallStatus=new Map<Id,String>();
        //Iterate over the deleted Installation records
        for(FS_Installation__c installationInstance : oldInstallList){            
            mapOfOutletIdAndOverallStatus.put(installationInstance.FS_Outlet__c, installationInstance.Overall_Status2__c);
        }         
        //Business logic Start
        if(!mapOfOutletIdAndOverallStatus.isEmpty()){
            Integer totalNumberOfInstallations=0;
            //Retreive the latest Installation details under the 
            //deleted Installation's Outlet based on last Modified date
            for(FS_Installation__c  installationInstance : [SELECT Id, Overall_Status2__c,FS_Outlet__c FROM FS_Installation__c WHERE FS_Outlet__c in:mapOfOutletIdAndOverallStatus.keySet() AND
                                                            RecordTypeId=:FSInstallationValidateAndSet.ipNewRecType  ORDER BY LastModifiedDate DESC limit 1]){
                                                                final Id outletId= installationInstance.FS_Outlet__c;                                              
                                                                if(sObjectsToUpdate.containskey(outletId)){
                                                                    final Account accObj=(Account)sObjectsToUpdate.get(outletId);
                                                                    accObj.Latest_Installation_Status__c =mapOfOutletIdAndOverallStatus.get(outletId);
                                                                    sObjectsToUpdate.put(accObj.Id,accObj);
                                                                }else{
                                                                    sObjectsToUpdate.put(outletId,new Account(Id=outletId,Latest_Installation_Status__c =mapOfOutletIdAndOverallStatus.get(outletId)));
                                                                }
                                                                totalNumberOfInstallations++;                                                
                                                            } 
            //Set blank value if no Intallations were found
            if(totalNumberOfInstallations==FSConstants.ZERO){
                for(Id outletId : mapOfOutletIdAndOverallStatus.keySet()){
                    if(sObjectsToUpdate.containskey(outletId )){
                        final Account accObj=(Account)sObjectsToUpdate.get(outletId);
                        accObj.Latest_Installation_Status__c =FSConstants.BLANKVALUE;
                        sObjectsToUpdate.put(accObj.Id,accObj);
                    }
                    else{
                        sObjectsToUpdate.put(outletId,new Account(Id=outletId,Latest_Installation_Status__c=FSConstants.BLANKVALUE));
                    }
                }
            }
        }
    }  
    
    /**@desc: to updated Installation count field on Account
*@param - Trigger context variables(Trigger.old,Trigger.new,
Trigger.isInsert) and Map<Id, Sobject> sobjectsToUpdate
*@return void
*/
    public static void updateOutletFieldsOnInsertDelete(final List<FS_Installation__c> oldList,final List<FS_Installation__c> newList,final Boolean isInsert,final Boolean isUpdate,final Map<Id, Sobject> sobjectsToUpdate){
        final map<id,Account> mapIdAccount = new map<id,Account>{};
            List<FS_Installation__c> lstInstallation;//collection to store old/new list of Installation 
        if(isInsert || isUpdate){
            lstInstallation = newList;
        }
        else{
            lstInstallation = oldList;
        }
        for(FS_Installation__c install : lstInstallation){
            mapIdAccount.put(install.FS_Outlet__c,new Account(id=install.FS_Outlet__c,FS_of_Installations__c=0,FS_No_of_Completed_Installs__c=0,FS_of_total_Installs__c=0));
        }
        
        List<FS_installation__c> installQueried=[Select FS_Outlet__c,Recordtypeid, Overall_Status2__c from fs_installation__c where FS_Outlet__c in :mapIdAccount.keySet()];
        
        for (FS_installation__c install : installQueried ){            
            if (install.Overall_Status2__c==FSConstants.IPCOMPLETE) {
                mapIdAccount.get(install.FS_Outlet__c).FS_No_of_Completed_Installs__c+=1;
            }
            else if (install.Overall_Status2__c!=FSConstants.IPCOMPLETE && install.Overall_Status2__c!=FSConstants.IPCANCELLED){
                mapIdAccount.get(install.FS_Outlet__c).FS_of_Installations__c+=1;
            }            
            mapIdAccount.get(install.FS_Outlet__c).FS_of_total_Installs__c+=1;
        }
        
        //OCR1 Req to bypass Bottler by srini
        //FSConstants.BypassOrderDelivery =true;
        //Add to the sObject Collection to Update
        for(Account acc : mapIdAccount.values()){
            if(sObjectsToUpdate.containskey(acc.Id)){
                final Account accObj=(Account)sObjectsToUpdate.get(acc.Id);
                accObj.FS_of_Installations__c=acc.FS_of_Installations__c;
                accObj.FS_No_of_Completed_Installs__c=acc.FS_No_of_Completed_Installs__c;
                accObj.FS_of_total_Installs__c=acc.FS_of_total_Installs__c;
                sObjectsToUpdate.put(accObj.Id,accObj);
            }else{
                sObjectsToUpdate.put(acc.Id,new Account(Id=acc.Id,FS_of_Installations__c=acc.FS_of_Installations__c,
                                                        FS_No_of_Completed_Installs__c=acc.FS_No_of_Completed_Installs__c,
                                                        FS_of_total_Installs__c=acc.FS_of_total_Installs__c));
            }
        }
    }
    /**@desc: to updated FS_IP_Equipment_Package__c fields
*@param - Trigger context variables(Trigger.new,Trigger.newMap,
Trigger.oldMap,Trigger.isUpdate,Trigger.isInsert) and
Map<Id, Sobject> sobjectsToUpdate
*@return void
*/
    public Static void equipmentPackageWorkflowUpdate(final List<FS_Installation__c> installList,final Map<Id,FS_Installation__c> newMap,final Map<Id,FS_Installation__c> oldMap,final  Boolean isUpdate,final Boolean isInsert,final Map<Id, Sobject> sobjectsToUpdate){        
        
        final Map<String,FS_IP_Equipment_Package__c> installEQPMap=new Map<String,FS_IP_Equipment_Package__c>();
        
        //criteria block to add records in installEquipPckgMap
        for(FS_IP_Equipment_Package__c eqpInstall:
            [SELECT ID,FS_Platform_Type__c,FS_Installation__c,FS_Installation__r.FS_Outlet__r.ShippingState,FS_Notification_for_Hawaii_Install_fla__c,FS_Onboarding_Readiness__c,FS_Valid_Fill_QTY__c,FS_Valid_Fill_Notification_Flag__c FROM FS_IP_Equipment_Package__c WHERE FS_Installation__c in :newMap.keySet()]){
                 installEQPMap.put(eqpInstall.FS_Installation__c+eqpInstall.FS_Platform_Type__c,eqpInstall);
             } 
        //process block to validate and set fields and add records in collection
        for(FS_Installation__c inst: installList){
            if(inst.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE && 
               (isInsert || (isUpdate && (oldMap.get(inst.Id).FS_Overall_Status__c!=inst.FS_Overall_Status__c || 
                                          oldMap.get(inst.Id).FS_Scheduled_Install_Date__c!=inst.FS_Scheduled_Install_Date__c || 
                                          oldMap.get(inst.Id).FS_Onboarding_Readiness__c!=inst.FS_Onboarding_Readiness__c)))){
                                              final List<String> platformList=inst.Type_of_Dispenser_Platform__c.split(FSConstants.SEMICOLON);
                                              for(String platform:platformList){
                                                  if(installEQPMap.ContainsKey(inst.Id+platform)){
                                                      Boolean recordUpdate=false;
                                                      final FS_IP_Equipment_Package__c eqp=installEQPMap.get(inst.Id+platform);
                                                      if(isUpdate && eqp.FS_Valid_Fill_QTY__c>FSConstants.ZERO && (oldMap.get(inst.id).FS_Overall_Status__c!=inst.FS_Overall_Status__c || oldMap.get(inst.id).FS_Scheduled_Install_Date__c!=inst.FS_Scheduled_Install_Date__c)){
                                                          eqp.FS_Valid_Fill_Notification_Flag__c=eqp.FS_Valid_Fill_Notification_Flag__c?false:true;
                                                          recordUpdate=true;                       
                                                      }  
                                                      if(isInsert || (isUpdate && oldMap.get(inst.id).FS_Onboarding_Readiness__c!=inst.FS_Onboarding_Readiness__c)){
                                                          eqp.FS_Onboarding_Readiness__c=inst.FS_Onboarding_Readiness__c;
                                                          recordUpdate=true;                            
                                                      }
                                                      if(inst.FS_Overall_Status__c==FSConstants.x4InstallSchedule && inst.FS_Scheduled_Install_Date__c!=null && eqp.FS_Installation__r.FS_Outlet__r.ShippingState=='HI'){
                                                          eqp.FS_Notification_for_Hawaii_Install_fla__c=true;
                                                          recordUpdate=true;
                                                      }
                                                      
                                                      if(recordUpdate){
                                                          FS_IP_Equipment_Package__c equip;
                                                          if(sObjectsToUpdate.containskey(eqp.Id)){
                                                              equip=(FS_IP_Equipment_Package__c)sObjectsToUpdate.get(eqp.Id);
                                                          }else{
                                                              equip=new FS_IP_Equipment_Package__c(id=eqp.Id); 
                                                          }
                                                          equip.FS_Valid_Fill_Notification_Flag__c=eqp.FS_Valid_Fill_Notification_Flag__c;
                                                          equip.FS_Notification_for_Hawaii_Install_fla__c=eqp.FS_Notification_for_Hawaii_Install_fla__c;
                                                          equip.FS_Onboarding_Readiness__c=eqp.FS_Onboarding_Readiness__c;
                                                          sObjectsToUpdate.put(eqp.Id,equip);                           
                                                      }                      
                                                  }
                                              }
                                          }
        }      
    }
    /**@desc: to set Install date field values from outlet 
and This method is for making installation rush while creation OCR2
*@param - Trigger context variables(Trigger.new)
*@return void
*/
    public static void updateRushInstallation(final List<FS_Installation__c> newList){
        //process block to get business days and updated Rush install field        
        for(FS_Installation__c instal:newList)  { 
            //FET4.0
            //FET 5.1 528 removed record type check for new install
            if(instal.FS_Original_Install_Date__c!=null){
                //Calling above method for checking business days 
                //and updated rush install check box
                FSInstallationValidateAndSet.setInstallDateAndCalculateElapseDays(instal,true,null);              
            }
            /*
if(instal.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeReplacement && instal.FS_Install_Reconnect_Date__c!=null){                
FSInstallationValidateAndSet.setInstallDateAndCalculateElapseDaysReplacement(instal,true,null);
}*/
        }
    }
    /**@desc: to updated the first install date on outlet
*@param - Trigger context variables(Trigger.new) and 
Map<Id, Sobject> sobjectsToUpdate
*@return void
*/
    //This method used to updating the first
    // install date on outlet -OCR2
    public static void updateFirstInstallDate(final List<FS_Installation__c> newList,final  Map<Id, Sobject> sobjectsToUpdate){
        final Set<Id> installationIds=new Set<Id>();//to hold installation Ids
        Date tempDate=null;//to store first install date    
        final List<id> outletids = new List<id>();//to hold outlet ids
        List<Account> accList = new List<Account>();//to hold account details
        final List<FS_Installation__c> installations = new List<FS_Installation__c>();//to hold installation details
        final Map<string,List<FS_Installation__c>> installationsMAP = new Map<string,List<FS_Installation__c>>();
        //to hold installation details unfiltered on FS_Scheduled_Install_Date__c and FS_Install_Reconnect_Date__c
        List<FS_Installation__c> allInstallations = new List<FS_Installation__c>();
        //process block to add records to collections 
        for(FS_Installation__c instal :newList){
            outletids.add(instal.FS_Outlet__c);
            installationIds.add(instal.id);
        }                   
        accList =[Select Id, First_Install_Date1__c From Account Where Id In :outletids];
        allInstallations=[select Id,Name,RecordType.name,FS_Outlet__c,FS_New_Outlet__c,Blended_Install_Date__c,FS_Scheduled_Install_Date__c,FS_Install_Reconnect_Date__c from FS_Installation__c 
                          where Overall_Status2__c = :FSConstants.IPCOMPLETE AND id In :installationIds];
        
        for(FS_Installation__c install: allInstallations){
            if(install.FS_Scheduled_Install_Date__c!=null){
                installations.add(install);
                if(installationsMAP.containskey(install.FS_Outlet__c)){
                    installationsMAP.get(install.FS_Outlet__c).add(install);
                }else{
                    List<FS_Installation__c> fsIList = New List<FS_Installation__c>();
                    fsIList.add(install);
                    installationsMAP.put(install.FS_Outlet__c,fsIList);
                }                
            }
        }
        //Criteria block to set First Install date        
        for(Account acc:accList){            
            if(installationsMAP.containskey(acc.Id)){
                for(FS_Installation__c install: installationsMAP.get(acc.Id)){
                    if(acc.First_Install_Date1__c!=FSConstants.NULLVALUE){
                        if(acc.First_Install_Date1__c > install.Blended_Install_Date__c){
                            tempDate= install.Blended_Install_Date__c; 
                        }
                        else{
                            tempDate =acc.First_Install_Date1__c ;
                        }
                    }else{
                        tempDate=  install.Blended_Install_Date__c;  
                    } 
                }
                acc.First_Install_Date1__c=tempDate;                               
            }                                 
        }        
        //process block to updated the First Install date field
        if(!accList.isEmpty()){                                                                           
            for(Account acc: accList){
                if(sObjectsToUpdate.containskey(acc.Id)){
                    final Account accObj = (Account)sObjectsToUpdate.get(acc.Id);
                    accObj.First_Install_Date1__c=acc.First_Install_Date1__c;
                    sObjectsToUpdate.put(accObj.id,accObj);
                }else{
                    sObjectsToUpdate.put(acc.Id,new Account(Id=acc.Id, First_Install_Date1__c=acc.First_Install_Date1__c));
                }
            }
        }
    }
    /**@desc: to validate the fields, throw errors
and set the values of Installation object.
*@param - Trigger context variables(Trigger.new,Trigger.oldMap,
Trigger.isUpdate,Trigger.isInsert)
*@return void
*/
    public static void updateSPReconnectDisconnect(final List<FS_Installation__c> newList,final  Map<Id, FS_Installation__c> oldMap,final  Boolean isUpdate,final  Boolean isInsert){ 
        final Set<Id> setOutletIds = new Set<Id>();//to hold outlet Ids
        //Criteria block to validate if the field values
        // are proper and add outletIds to collection
        for(FS_Installation__c inst : newList){
            if((isUpdate && oldMap.get(inst.Id).FS_SP__c != inst.FS_SP__c && !inst.SP_Override__c && oldMap.get(inst.Id).FS_SP_Disconnect_Reconnect_Override_Flag__c==inst.FS_SP_Disconnect_Reconnect_Override_Flag__c)||
               (isInsert && inst.FS_SP__c !=FSConstants.NULLVALUE &&  !inst.SP_Override__c )){
                   //FET 5.0 US 6.1 changed error message as SP disconnect label changed
                   inst.SP_Override__c.addError(Label.SP_error_message_on_Installation);
               }
            if(inst.Recordtypeid==FSInstallationValidateAndSet.ipRecTypeRelocation &&( (isUpdate   && oldMap.get(inst.Id).FS_SP_Reconnect__c != inst.FS_SP_Reconnect__c 
                                                                                        && !inst.FS_SP_Reconnect_Override__c&& oldMap.get(inst.Id).FS_SP_Disconnect_Reconnect_Override_Flag__c==inst.FS_SP_Disconnect_Reconnect_Override_Flag__c)
                                                                                      ||(isInsert && inst.FS_SP_Reconnect__c !=FSConstants.NULLVALUE && !inst.FS_SP_Reconnect_Override__c ))){
                                                                                          inst.FS_SP_Reconnect_Override__c.addError('To Enter \'SP Reconnect\' manually you have to check \'SP Reconnect Override\' Checkbox');
                                                                                      }  
            //FET 5.0 US 2,removed the record type checking for all record types in OR condition
            if(inst.FS_Outlet__c != FSConstants.NULLVALUE){
                setOutletIds.add(inst.FS_Outlet__c);                                
            }
            if(inst.Recordtypeid==FSInstallationValidateAndSet.ipRecTypeRelocation && inst.FS_New_Outlet__c != FSConstants.NULLVALUE){
                setOutletIds.add(inst.FS_New_Outlet__c);
            }
        }
        //process block to set field values of Installation object
        if(!setOutletIds.isEmpty()){
            FSInstallationValidateAndSet.populateSPReconnectDisconnect(newList, oldMap, isUpdate, setOutletIds);
        }
    }
    /**@desc: to updated Installation count field on Account
*@param - Trigger context variables(Trigger.new,Trigger.oldMap)
and List<FS_Installation__c> installList, 
Map<Id, Sobject> sobjectsToUpdate
*@return void
*/    
    public static void renewOutletFieldsOnUpdate(final List<FS_Installation__c> newList,final Map<Id,FS_Installation__c> oldMap,final Map<Id, Sobject> sobjectsToUpdate){
        
        List<Account> lstAccount = new List<Account>();//collection to hold the Account fields
        final Map<Id, List<FS_Installation__c>> mapOutletInstallation = new Map<Id, List<FS_Installation__c>>();//to hold outlet Id
        Set<String> tempSetRelocStatuses = new Set<String>();//Latest Relocation Status updated on New Outlet
        final Map<Id, Set<String>> mapNewOutletIdStatuses = new Map<Id, Set<String>>();//to hold new outlet status
        final Map<String, Integer> mapOutletIdCompletedInstalls = new Map<String, Integer>();//to store outlet id and number of installations
        final List<FS_Installation__c> installList = new List<FS_Installation__c>();//to hold records that need to be processed
        final Set<id> recordTypeSet=new Set<id>();//to store the recordTypeIds to use in soql query for performance
        recordTypeSet.add(FSInstallationValidateAndSet.ipRecTypeRelocation);
        recordTypeSet.add(FSInstallationValidateAndSet.ipRecTypeRemoval);
        recordTypeSet.add(FSInstallationValidateAndSet.ipRecTypeReplacement);
        
        //criteria block to get proper records
        for(FS_Installation__c inst: newList){
            if((inst.FS_Survey_Install_Cancelled__c!=oldMap.get(inst.id).FS_Survey_Install_Cancelled__c
                || inst.FS_Scheduled_Install_Date__c!=oldMap.get(inst.id).FS_Scheduled_Install_Date__c
                || inst.Overall_Status2__c!=oldMap.get(inst.id).Overall_Status2__c
                || inst.FS_Eq_SS_Dispenser_QTY__c!=oldMap.get(inst.id).FS_Eq_SS_Dispenser_QTY__c
                || inst.FS_Eq_CS_Dispenser_QTY__c!=oldMap.get(inst.id).FS_Eq_CS_Dispenser_QTY__c
                || inst.FS_Spicy_Cherry__c!=oldMap.get(inst.id).FS_Spicy_Cherry__c
                || inst.FS_7000S_Dispenser_QTY__c!=oldMap.get(inst.id).FS_7000S_Dispenser_QTY__c
                || inst.FS_7000_Series_Agitated_Brands_Selection__c!=oldMap.get(inst.id).FS_7000_Series_Agitated_Brands_Selection__c
                || inst.FS_7000_Series_Statics_Brands_Selection__c!=oldMap.get(inst.id).FS_7000_Series_Statics_Brands_Selection__c) && inst.FS_Outlet__c!=null){
                    installList.add(inst);
                } 
        }
        //criteria block to add records to collections
        if(!installList.isEmpty()){
            for(FS_Installation__c install: installList){
                if(!mapOutletInstallation.containsKey(install.FS_Outlet__c)){   
                    mapOutletInstallation.put(install.FS_Outlet__c, new List<FS_Installation__c>());
                }
                if(mapOutletInstallation.get(install.FS_Outlet__c)!=FSConstants.NULLVALUE){
                    mapOutletInstallation.get(install.FS_Outlet__c).add(install); 
                }
                //add records with new Outlet and Relocation status
                if(install.RecordTypeId == FSInstallationValidateAndSet.ipRecTypeRelocation 
                   && install.FS_New_Outlet__c != null 
                   && install.FS_Outlet__c != install.FS_New_Outlet__c) {
                       if(mapNewOutletIdStatuses.containsKey(install.FS_New_Outlet__c)) {
                           tempSetRelocStatuses = mapNewOutletIdStatuses.get(install.FS_New_Outlet__c);
                           tempSetRelocStatuses.add(install.Overall_Status2__c);
                           mapNewOutletIdStatuses.put(install.FS_New_Outlet__c, tempSetRelocStatuses);
                       } else {
                           mapNewOutletIdStatuses.put(install.FS_New_Outlet__c, new Set<String>{install.Overall_Status2__c});
                       }
                   }
                //add records to map
                mapOutletIdCompletedInstalls.put(install.FS_Outlet__c, 0);            
            }
            
            
            //collection to hold outlet Ids and number of installations
            final List<AggregateResult> listOutletCounts = [SELECT FS_Outlet__c, COUNT(Id) installs FROM FS_Installation__c WHERE RecordTypeId NOT IN :recordTypeSet
                                                            AND Overall_Status2__c = :FSConstants.IPCOMPLETE  
                                                            AND FS_Outlet__c IN :mapOutletIdCompletedInstalls.keySet() GROUP BY FS_Outlet__c];
            String tempId;//temporary variable to store outlet Id
            //process block to add records to collection
            for(AggregateResult ar : listOutletCounts) {
                tempId = (String) ar.get('FS_Outlet__c');
                if(mapOutletIdCompletedInstalls.containsKey(tempId)) {
                    mapOutletIdCompletedInstalls.put(tempId, Integer.valueOf(ar.get('installs')));
                }
            }        
            //Defect 1672: The existing implementation works only 
            //for a single Installation under an Outlet.
            //Because everytime this method is executed counter
            // variables are initialized to Zero. 
            //Adding code to take care of earlier value .
            //For more than One Installation Scenario.
            Map<Id,Account> mapOfOutletRecords=new Map<Id,Account>();//to store Account fields
            mapOfOutletRecords=new Map<Id,Account>([select Latest_Relocation_Status__c, FS_Survey_Install_Cancelled__c,FS_Installs_Complete__c,
                                                    FS_of_Dr_Pepper_Changes__c,FS_of_Show_Water_Changes__c,FS_of_Hide_Dasani_Changes__c,
                                                    FS_of_Pibb_Changes__c ,FS_of_Hide_Water_Changes__c,FS_of_Show_Dasani_Changes__c from Account 
                                                    where id IN :mapOutletInstallation.keySet() OR  Id IN :mapNewOutletIdStatuses.keySet()]);
            String temp;//to store Relocation status
            //process to store Latest Relocation Status
            for(Account objNewOutlet : mapOfOutletRecords.values()) {
                if(mapNewOutletIdStatuses.containsKey(objNewOutlet.Id)) {
                    temp = FSConstants.BLANKVALUE;
                    for(String strStatus : mapNewOutletIdStatuses.get(objNewOutlet.Id)) {
                        temp +=  strStatus ;
                    }
                    objNewOutlet.Latest_Relocation_Status__c = temp;   
                    lstAccount.add(objNewOutlet);
                }
            } 
            //calling the function to set the fields of Account
            lstAccount=FSInstallationValidateAndSet.setAccountFields(mapOutletInstallation,mapOutletIdCompletedInstalls,mapOfOutletRecords,lstAccount);
            //updated Account records
            if(!lstAccount.isEmpty()){
                for(Account acc : lstAccount){
                    if(sObjectsToUpdate.containskey(acc.Id)){                    
                        final Account accObj=populateAccountFields(acc,(Account)sObjectsToUpdate.get(acc.Id));
                        sObjectsToUpdate.put(acc.Id,accObj);
                    }
                    else{
                        final Account accObj=populateAccountFields(acc,new Account(Id=acc.Id));
                        sObjectsToUpdate.put(acc.Id,accObj);
                    }
                }
            }
        }
    }
    
    public static Account populateAccountFields(Account acc,Account accObj){
        accObj.Latest_Relocation_Status__c=acc.Latest_Relocation_Status__c;
        accObj.FS_of_Self_Serve_Installations2__c=acc.FS_of_Self_Serve_Installations2__c;
        accObj.FS_of_Crew_Serve_Installations2__c=acc.FS_of_Crew_Serve_Installations2__c;
        accObj.FS_of_7000_Series_Installations__c=acc.FS_of_7000_Series_Installations__c;
        accObj.FS_Max_Installation_Date__c=acc.FS_Max_Installation_Date__c;
        accObj.FS_Survey_Install_Cancelled__c=acc.FS_Survey_Install_Cancelled__c;
        accObj.FS_Installs_Complete__c=acc.FS_Installs_Complete__c;
        accObj.FS_of_Dr_Pepper_Changes__c=acc.FS_of_Dr_Pepper_Changes__c;
        accobj.FS_of_Pibb_Changes__c=acc.FS_of_Pibb_Changes__c;
        accobj.FS_of_Hide_Water_Changes__c=acc.FS_of_Hide_Water_Changes__c;
        accobj.FS_of_Show_Water_Changes__c=acc.FS_of_Show_Water_Changes__c;
        accobj.FS_of_Hide_Dasani_Changes__c=acc.FS_of_Hide_Dasani_Changes__c;
        accobj.FS_of_Show_Dasani_Changes__c=acc.FS_of_Show_Dasani_Changes__c;
        return accObj;
    }
    
    
    //FET 5.0 
    /*Clear all approval process field values 
when platform type multiselect picklist is changed for an Installation record*/
    
    public static void resetApprovalsOnPlatformChange(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap){       
        
        //iterating the Installation list
        for(FS_Installation__c install:newInstallList){
            Set<String> mainList=new Set<String>(); 
            Map<Set<String>,Set<String>> platformMap=new Map<Set<String>,Set<String>>();
            if(install.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && install.Type_of_Dispenser_Platform__c!=oldInstallMap.get(install.Id).Type_of_Dispenser_Platform__c){
                if(oldInstallMap.get(install.Id).FS_Overall_Status__c==FSConstants.x4InstallSchedule ){
                    install.FS_Platform_Type_change_CDM__c = !(install.FS_Platform_Type_change_CDM__c);
                }
                platformMap=FSUtil.checkPlatformValues(install.Id,install.Type_of_Dispenser_Platform__c,oldInstallMap.get(install.Id).Type_of_Dispenser_Platform__c);
                for(Set<String> main:platformMap.keySet()){
                    mainList=main;
                }
            }
            if(!mainList.isEmpty()){
                //COM User Notification
                if(install.FS_Execution_Plan_Final_Approval_PM__c==FSConstants.IPEPAPPROVED){install.FS_Platform_Type_Approve_Check__c=!(install.FS_Platform_Type_Approve_Check__c);
                                                                                            }   
                
                //Reset all approval fields 
                install.FS_Approval_request_submitted_by__c=FSConstants.ID_NULL;
                install.FS_Approval_request_submitted_date_time__c=FSConstants.DATETIME_NULL;
                install.FS_Approved_by__c=FSConstants.ID_NULL;
                install.FS_Approved_by_date_time__c=FSConstants.DATETIME_NULL;
                install.FS_Execution_Plan_Final_Approval_PM__c=FSConstants.STR_NULL;
                install.FS_Ready_For_PM_Approval__c=false;               
            }
        }          
    }
    
    //FET 5.0 
    /*Updated platform on initial order when platform change on installation*/    
    public static void updateInitialOrderPlatform(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap,Map<id,sobject> sobjectsToUpdate){
        Decimal quantityValue; 
        //Map to hold initial order records for update
        final Map<id,FS_Initial_Order__c> listIOUpdate=new Map<id,FS_Initial_Order__c>();
        //Fetch initial order related to Installation and creting Map with initial order
        final List<FS_Initial_Order__c> listInitialOrder =  [SELECT Id,FS_Installation__c FROM FS_Initial_Order__c
                                                             WHERE FS_Installation__c in :oldInstallMap.keySet()];
        //Map to link Installation and initial Order records
        final Map<id,FS_Initial_Order__c> instInitialOrderMap= new Map<id,FS_Initial_Order__c>();
        final Map<id,List<FS_Initial_Order__c>> instIONotesMap= new Map<id,List<FS_Initial_Order__c>>();
        for(FS_Initial_Order__c io:listInitialOrder){
            instInitialOrderMap.put(io.FS_Installation__c,io);
            if(instIONotesMap.containsKey(io.FS_Installation__c)){
                List<FS_Initial_Order__c> ioList=instIONotesMap.get(io.FS_Installation__c);
                ioList.add(io);
                instIONotesMap.put(io.FS_Installation__c,ioList);                
            }
            else{
                instIONotesMap.put(io.FS_Installation__c,new List<FS_Initial_Order__c>{io});
            }
        }        
        //iterating the Installation list
        for(FS_Installation__c install:newInstallList){
            FS_Installation__c oldIP=oldInstallMap.get(install.Id);
            if(instIONotesMap.containsKey(install.Id) && 
               (install.FS_Readiness_Notes__c!=oldIP.FS_Readiness_Notes__c || install.FS_Install_Notes_Comments__c!=oldIP.FS_Install_Notes_Comments__c)){
                   for(FS_Initial_Order__c io:instIONotesMap.get(install.Id)){
                       if(sObjectsToUpdate.containskey(io.Id)){                    
                           final FS_Initial_Order__c ioObj=(FS_Initial_Order__c)sObjectsToUpdate.get(io.Id);
                           ioObj.FS_InstallNotesComments_text__c=install.FS_Install_Notes_Comments__c;
                           ioObj.FS_Readiness_Notes__c=install.FS_Readiness_Notes__c;
                           sObjectsToUpdate.put(io.Id,ioObj);
                       }
                       else{
                           sObjectsToUpdate.put(io.Id,new FS_Initial_Order__c(id=io.Id,FS_InstallNotesComments_text__c=install.FS_Install_Notes_Comments__c,FS_Readiness_Notes__c=install.FS_Readiness_Notes__c));
                       }
                   }                   
               }            
            if((install.FS_DispOrder1__c!=oldIP.FS_DispOrder1__c || install.FS_DispOrder2__c!=oldIP.FS_DispOrder2__c
                || install.FS_DispOrder3__c!=oldIP.FS_DispOrder3__c) && instInitialOrderMap.containsKey(install.Id) ){
                    quantityValue=0;
                    quantityValue+=install.FS_DispOrder1__c != FSConstants.NULLVALUE? install.FS_DispOrder1__c : 0;
                    quantityValue+=install.FS_DispOrder2__c != FSConstants.NULLVALUE? install.FS_DispOrder2__c : 0;
                    quantityValue+=install.FS_DispOrder3__c != FSConstants.NULLVALUE? install.FS_DispOrder3__c : 0;
                    FS_Initial_order__c ioRec=instInitialOrderMap.get(install.Id);
                    
                    if(sObjectsToUpdate.containskey(ioRec.Id)){                    
                        final FS_Initial_Order__c ioObj=(FS_Initial_Order__c)sObjectsToUpdate.get(ioRec.Id);
                        ioRec.FS_Number_of_Freestyle_Dispensers__c=quantityValue;
                        sObjectsToUpdate.put(ioRec.Id,ioRec);
                    }
                    else{
                        sObjectsToUpdate.put(ioRec.Id,new FS_Initial_Order__c(id=ioRec.Id,FS_Number_of_Freestyle_Dispensers__c=quantityValue));
                    }                   
                }
        }               
    }      
    
    /*****************************************************************
Method: updateOutletsForJETIndicator
Description: updateOutletsForJETIndicator method to outlet records when ever there is a New Install created or Platform type changed    
New:Added as part FET 5.0 Sprint 4 :FET 145 
Modified: FET 5.1 Sprint 8: 663; 664
*******************************************************************/
    public static void updateOutletsForJETIndicator(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldMap ,final Boolean isInsert,final Map<Id, Sobject> sobjectsToUpdate) {
        //Set to store Outlet record Ids
        final Set<Id> outletIdSet=new Set<Id>();
        
        for(FS_Installation__c install:newInstallList){            
            if(isInsert || (!isInsert && install.Type_of_Dispenser_Platform__c!=oldMap.get(install.Id).Type_of_Dispenser_Platform__c) ||
               (!isInsert && (oldMap.get(install.Id).FS_DispRequested1__c!=install.FS_DispRequested1__c || oldMap.get(install.Id).FS_DispRequested2__c!=install.FS_DispRequested2__c || oldMap.get(install.Id).FS_DispRequested3__c!=install.FS_DispRequested3__c))){                     
                   outletIdSet.add(install.FS_Outlet__c);
               }                       
        } 
        //Updating the Outlet records with the date time stamp value
        for(Id outletId:outletIdSet){
            if(sObjectsToUpdate.containskey(outletId)){
                final Account accObj=(Account)sObjectsToUpdate.get(outletId);
                accObj.FS_JET_UpdateDateTime__c=system.now();
                sObjectsToUpdate.put(outletId,accObj);                    
            }else{                    
                sObjectsToUpdate.put(outletId,new Account(Id=outletId,FS_JET_UpdateDateTime__c=system.now()));
            }
        }
    }
    
    /*
New method to updated  OD for Valid Fill fields
*/
    Public static void updateODValidFillFields(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> newInstallMap,final Map<Id,FS_Installation__c> oldInstallMap,final Map<Id, Sobject> sobjectsToUpdate){
        final Set<Id> instId = new Set<Id>();
        List<FS_Outlet_Dispenser__c> updateOD=new List<FS_Outlet_Dispenser__c>();
        //FNF-190 changes to remove Market fields copy from IP to OD
        FSInstallationCreateEPIPAndMails.footprintEmailrunonce=true;
        for(FS_Installation__c install:newInstallList){
            //Check for Valid Fill fields change and IP status 'Sechedule' or Pending Reschedule'   
            if(install.FS_Valid_fill_required__c != oldInstallMap.get(install.id).FS_Valid_fill_required__c
               && (install.Overall_Status2__c ==  FSConstants.x3PendingSchedu || install.Overall_Status2__c ==FSConstants.x4InstallSchedule||install.Overall_Status2__c ==FSConstants.x1ReadySchedule))
            {
                instId.add(install.Id);
            }                       
        }
        
        for(FS_Outlet_Dispenser__c od:[select id,Installation__c,FS_Valid_Fill__c from FS_Outlet_Dispenser__c where Installation__c!=null and Installation__c in:instId]){
            //Updated Valid Fill attributes on OD from Installation
            od.FS_Valid_Fill__c = newInstallMap.get(od.Installation__c).FS_Valid_fill_required__c;           
            //Add OD to update
            sObjectsToUpdate.put(od.id,od);
        }       
    }
    
    /*****************************************************************
Method: ValidateAMOAStatus
Description: ValidateAMOAStatus method is to check conditions on 'Asset Tracking Form (AMOA) Status' 
Added as part of FET 7.0, //Sprint 1 - FNF-462
*******************************************************************/  
    public static void ValidateAMOAStatus(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap){
        if(!updateAMOACOMPLETEFromCase){
            String userProfileName = FSUtil.getProfileName();  
            Set<ID> submittedInstallID = New Set<ID>();
            for(FS_Installation__c install:newInstallList){
                if(install.recordtypeid == ipRecTypeRelocationO4W){
                    if(install.FS_Asset_Tracking_Form_AMOA_Status__c != oldInstallMap.get(install.id).FS_Asset_Tracking_Form_AMOA_Status__c
                       && install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOASUBMIT ){
                           submittedInstallID.add(install.id);
                       }
                    if(install.FS_Asset_Tracking_Form_AMOA_Status__c != oldInstallMap.get(install.id).FS_Asset_Tracking_Form_AMOA_Status__c
                       && install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOACOMPLETE &&  userProfileName != FSConstants.USER_POFILE_FETADMIN){
                           install.FS_Asset_Tracking_Form_AMOA_Status__c.adderror(Label.FS_Asset_Tracking_Form_Status);
                       }  
                }                                
            }  
            if(!submittedInstallID.ISEMPTY()){
                validateAMOAFileName(newInstallList, submittedInstallID, false);
            }
        }
    }

/*****************************************************************
Method: sendEmailUpdateCaseAMSOnPendToNewOL
Description: sendEmailUpdateCaseAMSOnPendToNewOL method is to check conditions as per FNF-459 on RO4W 
             and Send Email to AMS and Add casecomments.
Added as part of FET 7.0, //Sprint 1 - FNF-459
*******************************************************************/ 
    public static void sendEmailUpdateCaseAMSOnPendToNewOL(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap,final Map<Id,FS_Installation__c> newInstallMap, final Map<Id, Sobject> sobjectsToUpdate){
        try{
            if(!updateCaseAMSOnPendToNewOL){                
                Set<ID> amsInstallID = New Set<ID>();
                List<Case> caseList = new List<Case>();
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                Id emailTempId = [select id from EmailTemplate where DeveloperName =: FSConstants.EMAILTMP_FOR_JDE_RO4W].id;
                List<ContentDocumentLink> caseCdList = new List<ContentDocumentLink>();
                List<CaseComment> amsCCList = new List<CaseComment>();
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                for(FS_Installation__c install:newInstallList){
                    if(install.recordtypeid == ipRecTypeRelocationO4W){
                        if(install.FS_Did_BAST_initiate_this_RO4W__c == FSConstants.YES && install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOASUBMIT && 
                           install.Overall_Status2__c == FSConstants.PIA_PENDINGTONEWOUTLET && 
                           install.FS_IsPendingToNewOutlet__c == FSConstants.BOOL_VAL && install.FS_IsPendingToNewOutlet__c != oldInstallMap.get(install.id).FS_IsPendingToNewOutlet__c){
                               amsInstallID.add(install.id);
                           }  
                    }                                
                }
                if(!amsInstallID.ISEMPTY()){
                    Map<Id, ContentDocumentLink> cdlMap= validateAMOAFileName(newInstallList, amsInstallID, true);
                    if(!cdlMap.isEmpty()){
                        for(Id ipId  : cdlMap.keySet()){
                            caseList.add(new case(id=newInstallMap.get(ipId).FS_related_case_id__c,FS_Related_Installation__c=ipId ));
                        }
                        cdlList = cloneContentDocumentLink(cdlMap,caseList);
                        if(!cdlList.isEmpty()){
                            upsert cdlList;
                        }                       
                        for(Id ipId  : cdlMap.keySet()){
                            CaseComment cc = new CaseComment(ParentId = newInstallMap.get(ipId).FS_related_case_id__c,CommentBody = FSConstants.CASECOMMENT_JDE,CreatedById=FSUtil.getFreeStyleUserId());
                            amsCCList.add(cc);
                            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTempId, null, ipId);
                            email.setToAddresses(getEmailAddresses());
                            emails.add(email);
                        }
                        if(!amsCCList.isEmpty()){
                            insert amsCCList;
                        }
                        if(!emails.isEmpty()){
                            Messaging.sendEmail(emails); 
                        }                                             
                        set<id> caseIdSet=new Set<id>();
                        for(Case ca : caseList){                           
                            caseIdSet.add(ca.Id);                           
                        }
                        if(!caseIdSet.IsEmpty()){
                            updateCaseRecToJDEAMS(caseIdSet);
                        }
                    }
                    updateCaseAMSOnPendToNewOL = true;
                }
            }
        }catch(Exception ex){
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,FSInstallationUpdation,SendEmailUpdateCaseAMSOnPendToNewOL,FSConstants.NA,FSConstants.MediumPriority,ex,FSConstants.NA);
        }
    }
    /*****************************************************************
Method: updateCaseRecToJDEAMS
Description: updateCaseRecToJDEAMS method Updating Case Sub Status to JDE AMS ON HOLD and initiate Assignment rules
Added as part of FET 7.0, Defect - FNF-990
*******************************************************************/ 
    
    @future
    public static void updateCaseRecToJDEAMS(set<id> caseIdSet){
        List<Case> caseRecList = new List<Case>();        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;       
        for(Id caseId:caseIdSet){            
            Case caseRec = new Case(id=caseId,LM_Sub_Status__c = FSConstants.JDE_AMS_ON_HOLD);            
            caseRec.setOptions(dmo);
            caseRecList.add(caseRec);            
        }
        if(!caseRecList.isEmpty()){           
            Database.update(caseRecList); 
        }
        
    }
/*****************************************************************
Method: getEmailAddresses
Description: getEmailAddresses method to get the emailIds of users from public group 'FS RO4W AMOA Receipents'
Added as part of FET 7.0, //Sprint 1 - FNF-459
*******************************************************************/     
    public static List<String> getEmailAddresses(){
        List<String> mailToAddresses = new List<String>();
        List<Id> idList = new List<Id>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name =: FSConstants.RO4W_AMOA_GROUP];
        for (GroupMember gm : g.groupMembers) {
            idList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :idList];
        for(User u : usr) {
            mailToAddresses.add(u.email);
        }
        return mailToAddresses;
    }
/*****************************************************************
Method: validateAMOAFileName
Description: ValidateAMOAFileName method is to check AMOA file name format 
Added as part of FET 7.0, //Sprint 1 - FNF-462
*******************************************************************/     
    public static Map<Id, ContentDocumentLink> validateAMOAFileName(final List<FS_Installation__c> newInstallList,final Set<Id> ParentRecID, final boolean bypasserror){
        Map<Id, ContentDocumentLink> cdlMap = new Map<Id, ContentDocumentLink>();
        Map<id,List<ContentDocumentLink>> cdlistMap = new Map<id,List<ContentDocumentLink>>();
        Map<id,List<ContentDocumentLink>> installCDmap = new Map<id,List<ContentDocumentLink>>();
        
        for(ContentDocumentLink cd:[select id,LinkedEntityId,ContentDocumentId,ContentDocument.title,ContentDocument.CreatedDate,ContentDocument.LatestPublishedVersion.VersionData,
                                    ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId IN:ParentRecID ORDER BY ContentDocument.CreatedDate asc]){
                    if(installCDmap.containsKey(cd.LinkedEntityId)){
                        List<ContentDocumentLink> cdList = installCDmap.get(cd.LinkedEntityId);
                        cdList.add(cd);
                        installCDmap.put(cd.LinkedEntityId,cdlist);                
                    }
                    else{
                        installCDmap.put(cd.LinkedEntityId,new List<ContentDocumentLink>{cd});
                    }                     
                }
                
                for(FS_Installation__c install:newInstallList){
            if(ParentRecID.contains(install.id)){
                if(installCDmap.containskey(install.id)){
                    List<ContentDocumentLink> cdl = installCDmap.get(install.id);
                    for(ContentDocumentLink cd:cdl){
                        String[] labelstring = cd.ContentDocument.title.split(FSConstants.BLANK);
                        if(labelstring.Size() == FSConstants.FIVE && labelstring[0].toUpperCase() == FSConstants.AMOA && labelstring[1].toUpperCase() == FSConstants.FROMTEXT &&
                           labelstring[2].length() == FSConstants.TEN && labelstring[3].toUpperCase() == FSConstants.to && labelstring[4].length() == FSConstants.TEN &&
                           labelstring[2].isNumeric() && labelstring[4].isNumeric()){
                               cdlMap.put(install.id,cd);
                           }  
                    }
                    if(!cdlMap.containskey(install.id) && !bypasserror){
                        install.adderror(label.FS_AMOA_Naming_Convention);
                    }
                }else if(!bypasserror){
                    install.FS_Asset_Tracking_Form_AMOA_Status__c.adderror(label.FS_Attach_AMOA_error);
                }
            }
        } 
        return cdlMap;
    } 
    
    /*****************************************************************
Method: checkRO4WCase
Description: checkRO4WCase method is to check if the  FS_Freestyle_Support_Tool_Case__c is valid case#
Added as part of FET 7.0, //Sprint 1 - FNF-462 
*******************************************************************/     
    public static void checkRO4WCase(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap, Boolean isInsert){
        if(!updateCaseIdInstall){
            Set<string> casenoset = new Set<string>();
            MAP<string, Case> caseMAP = new MAP<string, Case>();
            Set<id> installID = new Set<id>();
            string profilename = FSUtil.getProfileName();
            for(FS_Installation__c install:newInstallList){
                if(install.recordtypeid == ipRecTypeRelocationO4W){
                    if( install.FS_Did_BAST_initiate_this_RO4W__c == FSConstants.NO && profilename != FSConstants.USER_POFILE_FETADMIN &&
                       ((isInsert && install.FS_Freestyle_Support_Tool_Case__c != FSConstants.STR_NULL) ||
                        (!isInsert && install.FS_Freestyle_Support_Tool_Case__c != oldInstallMap.get(install.id).FS_Freestyle_Support_Tool_Case__c ))){
                            install.FS_Freestyle_Support_Tool_Case__c.adderror(label.FS_Case_If_initiated_by_BAST);
                            break;
                        }
                    if( install.FS_Freestyle_Support_Tool_Case__c != FSConstants.STR_NULL && 
                       (isInsert || install.FS_Freestyle_Support_Tool_Case__c != oldInstallMap.get(install.id).FS_Freestyle_Support_Tool_Case__c )){
                           casenoset.add(install.FS_Freestyle_Support_Tool_Case__c);
                           if(!isInsert)
                           {
                               installID.add(install.id);
                           }
                       }
                }
            }
            if(!casenoset.ISEMPTY()){
                for(case caserec:[select id,status,CaseNumber FROM Case WHERE CaseNumber IN:casenoset]){
                    caseMAP.put(caserec.CaseNumber,caserec);
                }
                for(FS_Installation__c install: newInstallList){
                    if((isInsert || installID.contains(install.id)) && !caseMAP.containskey(install.FS_Freestyle_Support_Tool_Case__c)){
                        install.FS_Freestyle_Support_Tool_Case__c.adderror(label.FS_Case_no_not_Valid);
                    }else{
                        install.FS_related_case_id__c = caseMAP.get(install.FS_Freestyle_Support_Tool_Case__c).id;
                        install.Freestyle_Support_Tool_Case_Status__c=caseMAP.get(install.FS_Freestyle_Support_Tool_Case__c).status;
                    }
                }
            }
        }     
    }
    
    /*****************************************************************
Method: createRO4WCase
Description: createRO4WCase method is to Autocreate Case and 
Added as part of FET 7.0, //Sprint 1 - FNF-364
*******************************************************************/     
    public static void createRO4WCase(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap, final Map<Id, Sobject> sobjectsToUpdate){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        if(!updateCaseIdInstall){            
            Set<ID> installIDforCase = New Set<ID>();
            List<FS_Installation__c> installListforCase = new List<FS_Installation__c>();
            List<Case> autoCaseCreate = new List<Case>();
            Map<String,Case> autoCaseCreateMAP = new Map<String,Case>();
            Id caseLMRecordtypeId = FSConstants.RECORD_TYPE_CASE;
            String toACN = FSConstants.BLANK;
            Map<id, case> fromACNcase = new Map<id, case>();            
            Case autoCase;
            List<CaseToOutletdispenser__c> caseODlist = new List<CaseToOutletdispenser__c>();
            CaseToOutletdispenser__c caseOD;
            for(FS_Installation__c install:newInstallList){
                
                if(install.recordtypeid == ipRecTypeRelocationO4W && //oldInstallMap.get(install.id).Overall_Status2__c !=  install.Overall_Status2__c &&
                   install.Overall_Status2__c == FSConstants.PIA_PENDINGTONEWOUTLET && install.FS_Did_BAST_initiate_this_RO4W__c == FSConstants.NO && 
                   install.FS_Asset_Tracking_Form_AMOA_Status__c == FSConstants.AMOASUBMIT && install.FS_Freestyle_Support_Tool_Case__c == FSConstants.NULLVALUE){
                       
                       installIDforCase.add(install.id);
                       installListforCase.add(install);
                       if(install.FS_To_Outlet_Information__c != FSConstants.NULLVALUE){
                           toACN = install.FS_To_Outlet_Information__c.substring(5,15);
                       }
                       autoCase = new Case();
                       autoCase.setOptions(dmo);
                       autoCase.RecordTypeId = caseLMRecordtypeId;
                       // Updated Status to ASSIGNED and Sub-status to JDE_AMS_ON_HOLD 
                       // Changes done as part of Freestyle Support Migration FNF-993
                       autoCase.Status = FSConstants.STATUS_ASSIGNED;
                       autoCase.LM_Sub_Status__c = FSConstants.JDE_AMS_ON_HOLD;
                       
                       autoCase.FS_New_Case_Type__c = FSConstants.ACCOUNT_TEAM_INITIATED_AMOA;
                       autoCase.Issue_Name__c = FSConstants.AMOA + FSConstants.BLANK + FSConstants.FORSTRING + FSConstants.BLANK 
                           + toACN;
                       autoCase.Priority = FSConstants.MediumPriority;
                       autoCase.From_Account__c = install.FS_Outlet__c;
                       autoCase.To_Account__c = install.FS_To_Outlet_Name__c; 
                       autoCase.FS_Related_Installation__c = install.id;
                       autoCase.Related_Installation_Name__c = install.name;
                       autoCase.Related_Installation_ID__c = install.id;
                       autoCaseCreate.add(autoCase);
                   }
                
            }
            if(!autoCaseCreate.ISEMPTY()){
                updateCaseIdInstall = True;                
                Insert autoCaseCreate;
                Map<id,FS_Installation__c> installMap = new Map<id,FS_Installation__c>([select id,(select id from Outlet_Dispensers2__r) from FS_Installation__c where id in:installIDforCase]);
                
                for(case cs:autoCaseCreate){
                    if(installMap.containskey(cs.FS_Related_Installation__c)){
                        for(FS_Outlet_Dispenser__c odRec:installMap.get(cs.FS_Related_Installation__c).Outlet_Dispensers2__r){
                            caseOD = new CaseToOutletdispenser__c();
                            caseOD.Case__c = cs.id;
                            caseOD.Outlet_Dispenser__c = odRec.id;
                            caseOD.FS_CaseType__c = FSConstants.LM_CASE_TYPE;
                            caseODlist.add(caseOD);
                        }
                    }
                }
                if(!caseODlist.ISEMPTY()){
                    insert caseODlist;
                }
                Map<Id, ContentDocumentLink> cdlMap = validateAMOAFileName(newInstallList, installIDforCase, true);
                
                List<ContentDocumentLink> cloneContentDocumentLink = cloneContentDocumentLink(cdlMap, autoCaseCreate);
                if(!cloneContentDocumentLink.ISEMPTY()){
                    insert cloneContentDocumentLink;
                }
                
                for(Case autoCaserec: autoCaseCreate){
                    autoCaseCreateMAP.put(autoCaserec.Related_Installation_ID__c, autoCaserec);
                }
                
                Map<id,Case> caseMap = new Map<id,Case>([select id, CaseNumber,status from Case where Related_Installation_ID__c in:installIDforCase]);

                for(FS_Installation__c install:installListforCase){
                    if(autoCaseCreateMAP.containskey(install.id) && caseMap.containskey(autoCaseCreateMAP.get(install.id).id)){
                       case caserec = autoCaseCreateMAP.get(install.id);
                       case exCaseRec = caseMap.get(caserec.id);
                         if(sObjectsToUpdate.containskey(install.Id)){
                            final FS_Installation__c installObj=(FS_Installation__c)sObjectsToUpdate.get(install.Id);
                            installObj.FS_Freestyle_Support_Tool_Case__c = exCaseRec.CaseNumber;
                            installObj.FS_related_case_id__c = caserec.id;
                            installObj.Freestyle_Support_Tool_Case_Status__c = exCaseRec.status;
                            sObjectsToUpdate.put(install.Id,installObj);
                        }else{
                            sObjectsToUpdate.put(install.Id,new FS_Installation__c(Id=install.Id,FS_Freestyle_Support_Tool_Case__c = exCaseRec.CaseNumber,
                            FS_related_case_id__c = caserec.id,Freestyle_Support_Tool_Case_Status__c = exCaseRec.status));
                        }
                        
                    }  
                }
            }
        }     
    }
    
    /*****************************************************************
Method: cloneContentDocumentLink
Description: cloneContentDocumentLink method clone file frmo related RO4W record to Case record 
Added as part of FET 7.0, //Sprint 1 - FNF-364
*******************************************************************/
    public static List<ContentDocumentLink> cloneContentDocumentLink (final Map<Id, ContentDocumentLink> cdlMap, final List<Case> CaseRecList){
        List<ContentDocumentLink> cdlListtoInsert = new List<ContentDocumentLink>();
        
        for(Case caseRec: CaseRecList){
            if(cdlMap.containskey(caseRec.FS_Related_Installation__c)){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl = cdlMap.get(caseRec.FS_Related_Installation__c).clone();
                cdl.LinkedEntityId = caseRec.id;
                cdl.ShareType = FSConstants.CONTDOC_SHARETYPE;
                cdlListtoInsert.add(cdl);
            }
        }
        return cdlListtoInsert;
    } 
         /*****************************************************************
Method: checkDispenserSelectionManadatory
Description: Make Dispenser selection mandatory on Post Installation records 
Added as part of FET 7.0, //Sprint 2 - FNF-747
*******************************************************************/  
    public static void checkDispenserSelectionManadatory(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldMap,final Boolean isUpdate){
        
        List<FS_Installation__c> requiredInstallList = new List<FS_Installation__c>();
        List<String> installationPlatformTypes;
        FS_Outlet_Dispenser__c outletDispenser = new FS_Outlet_Dispenser__c();
        Set<id> instIds = new Set<id>();
        Set<id> instHavingDispensersSelectedIds = new Set<id>();
        Map<id,Decimal> installationDispenserCount = new Map<id,Decimal>();
        Map<id,List<FS_Outlet_Dispenser__c>> installationDispenserMap = new Map<id,List<FS_Outlet_Dispenser__c>>();
        id selectedId;
        Set<String> dispenserPlatformTypes;
        List<FS_Outlet_Dispenser__c> oD;
        for(FS_Installation__c ins : newInstallList){
            //fetching and storing the installations and thier ids which is PIA recordtype and required transaction status as per FNF-747
            if((ins.recordTypeID != FSInstallationValidateAndSet.ipNewRecType) && FSConstants.TRANSACTION_STATUS.contains(ins.Overall_Status2__c) && (oldMap.get(ins.Id).Overall_Status2__c!=ins.Overall_Status2__c) ){
                
                instIds.add(ins.Id);
                requiredInstallList.add(ins);
            }
        }
        if(!instIds.isEmpty()){
            //fetching and storing the installation id and the count of outlet dispensers
            for(FS_Installation__c ins : 
                [select id,RecordTypeId,FS_Outlet__r.nb_Outlet_Dispensers__c,(select id,FS_Equip_Type__c,Relocated_Installation__c from Outlet_Dispensers1__r) ,(select id,FS_Equip_Type__c,FS_Other_PIA_Installation__c from Outlet_Dispensers2__r)
                 from FS_Installation__c where id in :instIds] ){
                     List<FS_Outlet_Dispenser__c> odRecList=new List<FS_Outlet_Dispenser__c>();            
                     odRecList=ins.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation?ins.Outlet_Dispensers1__r:ins.Outlet_Dispensers2__r;
                     if(!odRecList.isEmpty()){
                         installationDispenserMap.put(ins.id,odRecList);
                     }
                     
                     Decimal dCount= ins.FS_Outlet__r.nb_Outlet_Dispensers__c;
                     installationDispenserCount.put(ins.id,dCount);
                     
                 }
            for(FS_Installation__c install:requiredInstallList){
                installationPlatformTypes = new List<String>();
                //fetching and storing multiple platform types selected in particular installation
                if(install.Type_of_Dispenser_Platform__c != null){
                    installationPlatformTypes.addAll(install.Type_of_Dispenser_Platform__c.split(FSConstants.SEMICOLON));
                }                
                //Checking second condition FNF-747
                if( installationDispenserCount.get(install.id) > FSConstants.COUNTZERO && !installationDispenserMap.containsKey(install.id)){
                    install.addError(Label.FS_DispenserSection_Not_Empty);                    
                }
                
                //Checking Third condition FNF-747
                if( installationDispenserCount.get(install.id) == FSConstants.COUNTZERO){
                    install.addError(Label.FS_DispenserSection_Empty);                   
                }
                oD = new List<FS_Outlet_Dispenser__c>();
                if(installationDispenserMap.containsKey(install.id) && installationDispenserMap.get(install.id) != null){
                    oD.addAll(installationDispenserMap.get(install.id));
                    //Checking for platform mismatch FNF-747
                    dispenserPlatformTypes = new Set<String>();
                    for(FS_Outlet_Dispenser__c outletDisp : oD){  
                        dispenserPlatformTypes.add(outletDisp.FS_Equip_Type__c);
                        if(!installationPlatformTypes.contains(outletDisp.FS_Equip_Type__c)){
                            install.addError(Label.FS_PlatForm_Type_Mismatch);                            
                            break;
                        }
                     }
                    //Checking if the Platform Types that are selected under IP contains the OD selected of that Platform Type.
                    if(!dispenserPlatformTypes.isEmpty()){
                        for(String plat:installationPlatformTypes){    
                            if(!dispenserPlatformTypes.contains(plat))
                            {         
                                install.addError(Label.FS_PlatForm_Type_Mismatch);
                                break;
                            } 
                            
                        }
                    }                       
                    
                }
            }
        }    
        
    }
    /*****************************End of checkDispenserSelectionManadatory method******************************************/
       /*****************************************************************
Method: workflowRuleFieldUpdates
Description: workflowRuleFieldUpdates Method contains Workflow Field update functionalities
            Inactivated some workflows and added logic inside this method to avoid 101 SOQL
Added as part of FET 7.0
*******************************************************************/  
    public static void workflowRuleFieldUpdates(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldMap,final Boolean isInsert){
        FS_Installation__c oldRec;
        for(FS_Installation__c install:newInstallList){
            if(!isInsert){
                oldRec= oldMap.get(install.Id);
            }
            //FS_Post_Install Activity Completed Date
            if((isInsert || install.FS_Activity_Complete__c!=oldRec.FS_Activity_Complete__c) && install.FS_Activity_Complete__c){
                install.FS_PostInstal_Activity_Completed_Date__c=system.now();
            }
            //FS_Updating_Installation in new outlet complete Date
            if((isInsert || install.FS_relocation_new_outlet_Complete__c!=oldRec.FS_relocation_new_outlet_Complete__c) && install.FS_relocation_new_outlet_Complete__c){
                install.FS_InstallationNew_outlet_Complete_date__c=system.now();
            }
            //FS_Updating_Removal_Old to new_date
            if((isInsert || install.FS_Relocation_from_old_outlet_to_SP_is__c!=oldRec.FS_Relocation_from_old_outlet_to_SP_is__c) && install.FS_Relocation_from_old_outlet_to_SP_is__c ){
                install.FS_Removal_from_old_Outlet_to_SP_Date__c=system.now();
            }
            //FS_Updating_AMOA Completed Date/Time
            if((isInsert || install.FS_Asset_Tracking_Form_AMOA_Status__c!=oldRec.FS_Asset_Tracking_Form_AMOA_Status__c) && install.FS_Asset_Tracking_Form_AMOA_Status__c==FSConstants.AMOACOMPLETE){
                install.FS_AMOA_Completed_Date_Time__c=system.now();
            }
            //FS_Updating_AMOA Submitted Date/Time
            if((isInsert || install.FS_Asset_Tracking_Form_AMOA_Status__c!=oldRec.FS_Asset_Tracking_Form_AMOA_Status__c) && 
               (install.FS_Asset_Tracking_Form_AMOA_Status__c==FSConstants.AMOASUBMIT || install.FS_Asset_Tracking_Form_AMOA_Status__c==FSConstants.AMOAREMOVAL)){

                install.FS_AMOA_Submitted_Date_Time__c=system.now();
            }
            //Date whn changed from 4 install Sheduled
            if((isInsert || install.Overall_Status2__c!=oldRec.Overall_Status2__c)  && install.Overall_Status2__c== FSConstants.IPCOMPLETE){
                install.FSDate_whn_chagd_from_4_install_Sheduled__c=system.today();
            }
        }
    }
        
}