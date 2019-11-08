/**********************************************************************************************************
Name         : FSAccountBusinessProcess
Created By   : Infosys
Created Date : 02-Nov-2016
Usage        : This class holds the business logic of the AccountTrigger and is called from the FSAccountTrigger.
***********************************************************************************************************/
public without sharing class FSAccountBusinessProcess {
    //Before inserting methods 
    public static void beforeInsertProcess(final List<Account> newAccList,final List<Account> oldAccList,final Map<Id,Account> newAccMap,final Map<Id,Account> oldAccMap, final Boolean isInsert,final Boolean isUpdate) {
        FSAccountUpdation.inheritInvoicefieldsfromHQtoOL(newAccList,oldAccMap,isInsert,isUpdate);
        FSAccountUpdation.updateStandardShippingAddress(newAccList); 
        FSAccountAuthorizationAndPopulateFields.populateFieldsBeforeInsert(newAccList);
    }
    //Before updating methods 
    public static void beforeUpdateProcess(final List<Account> newAccList,final List<Account> oldAccList,final Map<Id,Account> newAccMap,final Map<Id,Account> oldAccMap,final  Boolean isInsert,final  Boolean isUpdate,final Map<Id, SObject> sObjectsToUpdate) {
        
        FSAccountUpdation.inheritInvoicefieldsfromHQtoOL(newAccList,oldAccMap,isInsert,isUpdate);
        FSAccountAuthorizationAndPopulateFields.setEmptyFieldsWithOldValues(oldAccMap, newAccMap, newAccList, True, sObjectsToUpdate);
        FSAccountAuthorizationAndPopulateFields.populateFieldsBeforeUpdate(oldAccMap, newAccList);
        FSAccountUpdation.updateStandardShippingAddress(newAccList);
        FSAccountUpdation.updateJETIndicatorAction(newAccList,oldAccMap);//FET 5.0 Sprint 4 :FET 145       
    }
    //After inserting methods
    public static void afterInsertProcess(final List<Account> newAccList,final List<Account> oldAccList,final Map<Id,Account> newAccMap,final Map<Id,Account> oldAccMap,final Boolean isInsert,final Boolean isUpdate,final  Boolean IsBatch) {
        FSAccountUpdation.updateAccountTeamMemberFields(newAccList, oldAccMap, Trigger.isInsert, IsBatch);
    }
    //After updating methods
    public static void afterUpdateProcess(final List<Account> newAccList,final List<Account> oldAccList,final Map<Id,Account> newAccMap,final Map<Id,Account> oldAccMap,final Boolean isInsert,final Boolean isUpdate,final  Boolean IsBatch,final Map<Id, SObject> sObjectsToUpdate) {
        FSAccountUpdation.updateSAPIDAndCustomerInvoice(newAccList, oldAccMap, Trigger.isUpdate, IsBatch);
        FSAccountUpdation.updateOutletDispenserOnAccFieldModification(oldAccMap, newAccList,IsBatch);
        FSAccountUpdation.updateInstallCompleteCountonHQ(oldAccMap, newAccList, sObjectsToUpdate);
        FSAccountUpdation.updateInstallRecordForNewShippingPostalcode(oldAccMap, newAccMap, newAccList, Trigger.isInsert, sObjectsToUpdate);
        FSAccountUpdation.insertAccountShareRecordForNewOwner(oldAccMap,newAccList);
        FSAccountUpdation.updateAccountTeamMemberFields(newAccList, oldAccMap, Trigger.isInsert, IsBatch);
    }
}