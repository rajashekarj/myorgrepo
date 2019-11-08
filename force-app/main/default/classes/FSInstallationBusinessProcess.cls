/*****************************
Name         : FSInstallationBusinessProcess
Created By   : Infosys
Created Date : 12/05/2016 
Usage        : This class holds the business logic of the InstallationTrigger
*****************************/
public class FSInstallationBusinessProcess{
    public static Boolean runRescheduleOnce=true;
    public static Boolean checkCreateVFClass=true;
    //calling all validation and updated methods for beforeInsert process
    public static void beforeInsertProcess(final List<FS_Installation__c> newList,final List<FS_Installation__c> oldList,final Map<Id,FS_Installation__c> newMap,final Map<Id,FS_Installation__c> oldMap,final Boolean isInsert,final Boolean isUpdate,final Map<Id, Sobject> sobjectsToUpdate) {
        FSInstallationUpdation.checkRO4WCase(newList,oldMap,isInsert);//FET 7.0 FNF-462
        FSInstallationUpdation.updateLocaltimeFieldInstallation(newList);
        FSInstallationValidateAndSet.validationForInstallDateCheck(newList,oldMap,isInsert);
        FSInstallationUpdation.updateSPReconnectDisconnect(newList,oldMap,isUpdate,isInsert);
        FSInstallationUpdation.updateOutletWithLatestInstallationStatus(newList,oldMap,isInsert,isUpdate,sobjectsToUpdate);
        FSInstallationUpdation.updateRushInstallation(newList);//FET4.0
        FSInstallationCreateEPIPAndMails.updatePlatformTrackingFields(newList,oldMap,isUpdate);//FET 5.0
        //FET 7.0 Added some workflow field update logic and Inactivated the Workflows
        FSInstallationUpdation.workflowRuleFieldUpdates(newList,oldMap,isInsert); 
    }
    //calling all validation and updated methods for beforeUpdate process
    public static void beforeUpdateProcess(final List<FS_Installation__c> newList,final List<FS_Installation__c> oldList,final Map<Id,FS_Installation__c> newMap,final Map<Id,FS_Installation__c> oldMap,final Boolean isInsert,final Boolean isUpdate,final Map<Id, Sobject> sobjectsToUpdate) {
        FSInstallationUpdation.updateLocaltimeFieldInstallation(newList);
        if(runRescheduleOnce){
              
            FSInstallationUpdation.checkRO4WCase(newList,oldMap,isInsert);//FET 7.0 FNF-462
            FSInstallationUpdation.ValidateAMOAStatus(newList,oldMap);//FET 7.0 FNF-462
            FSInstallationUpdation.resetApprovalsOnPlatformChange(newList,oldMap);
            FSInstallationUpdation.updatePlatformFields(newList);//FET 5.0        
            FSInstallationUpdation.checkPlatformOnEPandInstall(newList,oldMap,sobjectsToUpdate);//FET 5.0
            FSInstallationUpdation.updateSPReconnectDisconnect(newList,oldMap,isUpdate,isInsert);
            FSInstallationValidateAndSet.validationForInstallDateCheck(newList,oldMap,isInsert);        
            FSInstallationValidateAndSet.setIsDailyUpdatedField(newList,newMap,oldMap);
            FSInstallationUpdation.updateOverallStatus(newList,oldMap);  
            FSInstallationUpdation.updatePIAOverallStatus(newList,oldMap);  
            FSInstallationUpdation.checkDispenserSelectionManadatory(newList,oldmap,isUpdate);//FET 7.0 FNF-747      
            FSInstallationUpdation.updateOutletWithLatestInstallationStatus(newList,oldMap,isInsert,isUpdate,sobjectsToUpdate);
            FSInstallationValidateAndSet.setRushInstallationOnUpdate(newList,oldMap);       
            FSInstallationValidateAndSet.validateRushInstallationReason(newMap,oldMap); 
            FSInstallationValidateAndSet.validateBrandsetDateCheck(newList,oldMap,newMap);//FET4.0       
            FSInstallationCreateEPIPAndMails.updatePlatformTrackingFields(newList,oldMap,isUpdate);//FET 5.0
            FSInstallationCreateEPIPAndMails.updateBrandStatusInstall(newList,oldMap);//FET 5.0
            FSInstallationCreateEPIPAndMails.sendEmailtoFootprint(newList,oldList,
                                                                  newMap,oldMap,isInsert,isUpdate,sobjectsToUpdate);
            //FET 7.0 Added some workflow field update logic and Inactivated the Workflows
            FSInstallationUpdation.workflowRuleFieldUpdates(newList,oldMap,isInsert); 
        }
        
    }
    //calling all updates and email notification methods for afterInsert process
    public static void afterInsertProcess(final List<FS_Installation__c> newList,final List<FS_Installation__c> oldList,final Map<Id,FS_Installation__c> newMap,final Map<Id,FS_Installation__c> oldMap,final Boolean isInsert,final Boolean isUpdate,final Map<Id, Sobject> sobjectsToUpdate) {
        FSInstallationCreateEPIPAndMails.updateOutletFromCIF(newList,newMap,sobjectsToUpdate);//FET 5.0
        FSInstallationUpdation.updateFirstInstallDate(newList,sobjectsToUpdate);        
        FSInstallationCreateEPIPAndMails.createEquipmentPackageAndTechnicianInstruction(newList,newMap);
        FSInstallationUpdation.updateOutletFieldsOnInsertDelete(oldList,newList,isInsert,isUpdate,sobjectsToUpdate);
        FSInstallationCreateEPIPAndMails.sendEmailNotificationToServiceProviderContacts(newList,newMap,oldMap,isInsert,isUpdate);
        FSInstallationCreateEPIPAndMails.createAssociateBrandset(newList,newMap,oldMap);//FET4.0        
        FSInstallationCreateEPIPAndMails.sendEmailNotificationToServiceProviderContacts1(newList,newMap,oldMap,isInsert,isUpdate);//FET4.0         
        FSInstallationUpdation.updateOutletsForJETIndicator(newList,oldMap,isInsert,sobjectsToUpdate); //FET 5.0 Sprint 4 :FET 145
    }
    //calling all updates and email notification methods for afterInsert process
    public static void afterUpdateProcess(final List<FS_Installation__c> newList,final List<FS_Installation__c> oldList,final Map<Id,FS_Installation__c> newMap,final Map<Id,FS_Installation__c> oldMap,final Boolean isInsert,final Boolean isUpdate,final Map<Id, Sobject> sobjectsToUpdate) {
        if(runRescheduleOnce){
            FSInstallationUpdation.updateFirstInstallDate(newList,sobjectsToUpdate);
            //FET 5.1 636
            FSInstallationUpdation.updateOutletFieldsOnInsertDelete(oldList,newList,isInsert,isUpdate,sobjectsToUpdate);
            FSInstallationUpdation.updateOutletWithLatestInstallationStatus(newList,oldMap,isInsert,isUpdate,sobjectsToUpdate);                                                             
            FSInstallationCreateEPIPAndMails.sendEmailNotificationToServiceProviderContacts(newList,newMap,oldMap,isInsert,isUpdate);               
            FSInstallationUpdation.renewOutletFieldsOnUpdate(newlist,oldMap,sobjectsToUpdate);
            FSInstallationUpdation.updateExecutionPlanStatus(newList,oldMap,sobjectsToUpdate);
            FSInstallationCreateEPIPAndMails.updateEQPAssociateBrandAndTI(newList,oldMap,newMap);//FET 5.0
            FSInstallationCreateEPIPAndMails.sinkABRecordsToPlatformDetails(newList,oldMap);
            FSInstallationCreateEPIPAndMails.ancillaryEQPOnReplacementUpdate(newList,oldMap,newMap);//FET4.0  
            FSInstallationUpdation.equipmentPackageWorkflowUpdate(newList,newMap,oldMap,isUpdate,isInsert,sobjectsToUpdate);
            FSInstallationCreateEPIPAndMails.sendEmailNotificationToServiceProviderContacts1(newList,newMap,oldMap,isInsert,isUpdate);//FET4.0                                     
            FSInstallationUpdation.updateEpPlatformCheck(newList,oldMap,sobjectsToUpdate);        
            FSInstallationUpdation.updateInitialOrderPlatform(newList,oldMap,sobjectsToUpdate); //FET 5.0
            FSInstallationUpdation.updateOutletsForJETIndicator(newList,oldMap,isInsert,sobjectsToUpdate); //FET 5.0 Sprint 4 :FET 145        
            FSInstallationUpdation.updateODValidFillFields(newList,newMap,oldMap,sobjectsToUpdate);//POC - FET5.1 Sprint8
            FSInstallationUpdation.sendEmailUpdateCaseAMSOnPendToNewOL(newList,oldMap,newMap,sobjectsToUpdate); //FET 7.0 FNF-459
            FSInstallationUpdation.createRO4WCase(newList,oldMap,sobjectsToUpdate);//FET 7.0 FNF-364
        }
        system.debug('After Update COunt'+limits.getQueries());
    }    
    
    //updates methods from afterdeleteProcess
    public static void afterDeleteProcess(final List<FS_Installation__c> newList,final List<FS_Installation__c> oldList,final Map<Id,FS_Installation__c> newMap,final Map<Id,FS_Installation__c> oldMap,final Boolean isInsert,final Boolean isUpdate,final Map<Id, Sobject> sobjectsToUpdate) {
        FSInstallationUpdation.updateOutletFieldsOnInsertDelete(oldList,newList,isInsert,isUpdate,sobjectsToUpdate);
        FSInstallationUpdation.updateOutletWithLatestInstallationStatusOnDelete(oldList,sobjectsToUpdate);
    }                                                                                            
}