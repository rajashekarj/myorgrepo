/******************************
Name         : FSAccountUpdation 
Created By   : Infosys
Created Date : 02-Nov-2016
Usage        : This class holds the business logic of the AccountTrigger and 
is called from the FSAccountTrigger.
Methods      : updateInstallCompleteCountonHQ,validateHQForBrands, 
setEmptyFieldsWithOldValues,updatePaymentTypeField,
insertAccountShareRecordForNewOwner,
updateInstallRecordForNewShippingPostalcode,
updateOutletDispenserOnAccFieldModification,
updateAccountTeamMemberFields,updateSAPIDAndCustomerInvoice
updateStandardShippingAddress
*******************************/
public without sharing class FSAccountUpdation { 
    //Record type ids from utility class
    public Static Id recTypeChain=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_CHAIN);
    public Static Id recTypeHQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_HQ);
    public Static Id recTypeInternationalOutlet=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_OUTLET_INT);
    public Static Id recTypeOutlet=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_OUTLET);
    public static Map<Id,String> mapofRecordtypIdAndRecordTypeName= new Map<Id,String>();
    public static Map<String,Id> mapofRecordtypNameAndRecordTypeId= new Map<String,Id>();
    public static final Integer BATCHSIZE = 2000;//variable to hold size of a batch
    //Installation record types    
    public Static Id ipNewRecType;
    private static final String ID_NULL = null;
    public static Boolean checkSPFieldForZipCode = true;
    static{
        if(ipNewRecType==ID_NULL){
            ipNewRecType=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,FSConstants.NEWINSTALLATION);
        }       
        mapofRecordtypIdAndRecordTypeName.put(recTypeChain,FSConstants.RECORD_TYPE_NAME_CHAIN);
        mapofRecordtypIdAndRecordTypeName.put(recTypeHQ,FSConstants.RECORD_TYPE_NAME_HQ);
        mapofRecordtypIdAndRecordTypeName.put(recTypeInternationalOutlet,FSConstants.RECORD_TYPE_NAME_OUTLET_INT);
        mapofRecordtypIdAndRecordTypeName.put(recTypeOutlet,FSConstants.RECORD_TYPE_NAME_OUTLET);
        mapofRecordtypNameAndRecordTypeId.put(FSConstants.RECORD_TYPE_NAME_CHAIN,recTypeChain);
        mapofRecordtypNameAndRecordTypeId.put(FSConstants.RECORD_TYPE_NAME_HQ,recTypeHQ);
        mapofRecordtypNameAndRecordTypeId.put(FSConstants.RECORD_TYPE_NAME_OUTLET_INT,recTypeInternationalOutlet);
        mapofRecordtypNameAndRecordTypeId.put(FSConstants.RECORD_TYPE_NAME_OUTLET,recTypeOutlet);
    }
    
    /*******Business Logic for Functionalities********/
    /** @Desc - It is used to have a record of the list of headquarters 
with number of installations completed for an Account.
* @param - Trigger context variables(Trigger.oldMap,Trigger.new) and 
Map<Id, Sobject> sobjectsToUpdate
* @Return - void
*/
    public static void updateInstallCompleteCountonHQ(final Map<Id,Account> oldAccMap,final List<Account> newAccList,final Map<Id, SObject> sObjectsToUpdate){
        final Set<Id> hqIds=new Set<Id>(); //collection to hold headquarter's Ids
        //Criteria Block
        for(Account acc : newAccList){
            if((acc.RecordTypeId == recTypeOutlet || acc.RecordTypeId == recTypeInternationalOutlet) &&
               (acc.FS_Installs_Complete__c!=oldAccMap.get(acc.id).FS_Installs_Complete__c ||
                (!String.isBlank(acc.FS_Headquarters__c) && acc.FS_Headquarters__c!=oldAccMap.get(acc.id).FS_Headquarters__c))){
                    hqIds.add(acc.FS_Headquarters__c);
                }
        }
        final Map<Id,Integer> installCompleteCountHQ=new Map<Id,Integer> ();//map to hold the Id and number/sum of FS_Installs_Complete__c for the Account 
        //Criteria Block
        if(!hqIds.isEmpty()){
            final List<AggregateResult> groupedResults=[select FS_Headquarters__c hq ,SUM(FS_Installs_Complete__c) cnt from Account where (RecordtypeId=:mapofRecordtypNameAndRecordTypeId.get('FS Outlet') or RecordtypeId=:mapofRecordtypNameAndRecordTypeId.get('FS International Outlet')) and FS_Headquarters__c in:hqIds  group by FS_Headquarters__c];//INT2
            for(AggregateResult ar: groupedResults){
                installCompleteCountHQ.put((Id)ar.get('hq'),Integer.valueOf(ar.get('cnt')));
            }
        }
        //Process Block
        if(!installCompleteCountHQ.isEmpty()){
            for(Id hqId: installCompleteCountHQ.keySet()){
                if(sObjectsToUpdate.containskey(hqId)){
                    final Account accObj=(Account)sObjectsToUpdate.get(hqId);
                    accObj.FS_Installs_Complete_HQ__c=installCompleteCountHQ.get(hqId);
                    sObjectsToUpdate.put(accObj.Id,accObj);
                }
                else{
                    sObjectsToUpdate.put(hqId,new Account(Id=hqId,FS_Installs_Complete_HQ__c=installCompleteCountHQ.get(hqId)));
                }
            }
        }
    }
    /** @Desc - This method validates the Payment type and if it is modified then sets 
Payment Type of HQ account with new value and updates the Account object.
* @param - Trigger context variables(Trigger.oldMap,Trigger.new) 
and Map<Id, Sobject> sobjectsToUpdate
* @Return - void
*/  
    public static void updatePaymentTypeField(final Map<Id,Account> oldMap,final List<Account> newList,final Map<Id, SObject> sObjectsToUpdate){
        final Set<Id> setChainAccountIds = new Set<Id>();//for holding set of Chain Accounts with modified payment type
        final Set<Id> setExcludeHQIds = new Set<Id>();//for holding set of Headquarter Accounts with modified payment type
        
        //criteria block to get records which need to be processed
        for(Account acc : (List<Account>) newList){
            //Get chain accounts  if  FS_Payment_Type__c is changed
            if(acc.RecordTypeId == recTypeChain && acc.FS_Payment_Type__c != oldMap.get(acc.Id).FS_Payment_Type__c ) {
                setChainAccountIds.add(acc.Id);
            }
            //Set FS_Don_t_Use_Chain_Pmt_Type__c value to true of HQ 
            //when Payment Type is updated on HQ
            if(acc.RecordTypeId == recTypeHQ && acc.FS_Payment_Type__c != oldMap.get(acc.Id).FS_Payment_Type__c ) {
                acc.FS_Don_t_Use_Chain_Pmt_Type__c = true;
                setExcludeHQIds.add(acc.Id);
            }
        }
        //Set HQ Payment Type on the change of Chain Account
        if(!setChainAccountIds.isEmpty()){
            //Get HQ Accounts to update FS_Payment_Type__c value
            final List<Account> lstHQToUpdate = new List<Account>();
            final Map<Id, Account> mapChainHQ = new Map<Id, Account> ([Select Id, FS_Payment_Type__c,
                                                                       (Select Id, FS_Don_t_Use_Chain_Pmt_Type__c From Chains__r
                                                                        where RecordTypeId = :recTypeHQ AND FS_Don_t_Use_Chain_Pmt_Type__c = false and Id Not IN :setExcludeHQIds )
                                                                       From Account Where Id IN :setChainAccountIds]);
            //criteria to update the collection
            for(Account acc : (List<Account>) newList){
                if(mapChainHQ.containsKey(acc.Id) &&  mapChainHQ.get(acc.Id).Chains__r != null){
                    for(Account hq : mapChainHQ.get(acc.Id).Chains__r){
                        setExcludeHQIds.add(hq.Id);
                        FSUtil.putValueInField(hq, 'Account', 'FS_Payment_Type__c', acc.FS_Payment_Type__c);
                        lstHQToUpdate.add(hq);
                    }
                }
            }
            //set Payment type value to Account
            
            if((FSUtil.checkAccessForSobject('Account' , Label.ACCESS_IS_UPDATEABLE)) && !lstHQToUpdate.isEmpty()){
                for(Account acc : lstHQToUpdate){
                    if(sObjectsToUpdate.containskey(acc.Id)){
                        final Account accObj=(Account)sObjectsToUpdate.get(acc.Id);
                        accObj.FS_Payment_Type__c=acc.FS_Payment_Type__c;
                        sObjectsToUpdate.put(accObj.Id,accObj);
                    }
                    else{
                        sObjectsToUpdate.put(acc.Id,new Account(Id=acc.Id,FS_Payment_Type__c=acc.FS_Payment_Type__c));
                    }
                }
            }          
        }
    }
    /** @Desc - It is used to validate the owner of HQ/Chain/Outlet Account and if the
owner is modified then creates record for AccountShare object for new owner.
* @param - Trigger context variables(Trigger.oldMap,Trigger.new)
* @Return - void
*/
    public static void insertAccountShareRecordForNewOwner(final Map<Id,Account> oldMap,final List<Account> newList) {
        final Set<Id> accountIdSet = new Set<Id>();//to hold set of account Ids where owner of HQ/Chain/Outlet Account is changed.
        //Criteria block
        for(Account acc : (List<Account>) newList) {            
            if(acc.OwnerId != oldMap.get(acc.Id).OwnerId && ((acc.RecordTypeId == recTypeHQ) || (acc.RecordTypeId == recTypeOutlet) || (acc.RecordTypeId == recTypeChain))) {
                accountIdSet.add(acc.Id);
            }
        }
        //Process block to fetch the records and insert share records
        if(!accountIdSet.isEmpty()) {
            //to hold the list of AccountTeamMember who are the 
            //new owner of record and active user.
            final List<AccountTeamMember__c> atmList = new List<AccountTeamMember__c>();
            for(AccountTeamMember__c atm :[SELECT UserId__c, AccountId__c, AccountId__r.OwnerId
                                           FROM AccountTeamMember__c WHERE AccountId__c IN : accountIdSet and UserId__r.IsActive = true]) {
                                               atmList.add(atm);
                                           }
            //method used to insert share records(Only Manual sharing records)
            FSAccountTeamMemberTriggerHandler.insertShareRecords(atmList);
        }
    }
    /** @Desc - It is used to update the records of Installation Object where 
ShippingPostalCode of an Outlet Account is modified.
* @param - Trigger context variables
(Trigger.oldMap,Trigger.newMap,Trigger.new,Trigger.isInsert) 
and Map<Id, Sobject> sobjectsToUpdate
* @Return - void
*/
    public static void updateInstallRecordForNewShippingPostalcode(final Map<Id,Account> oldMap,final Map<Id,Account> newMap,final List<Account> newList,final Boolean isInsert,final Map<Id, SObject> sObjectsToUpdate) {
        
        //to hold the records of installation object for which corresponding
        // Account's ShippingPostalCode is modified.
        final List<FS_Installation__c> installationList = new  List<FS_Installation__c>(); 
        final Set<Id> outletAccIds = new Set<Id>();//to hold the set of accountIds where ShippingPostalCode is modified.
        //criterian block to add the records into collection
        if(checkSPFieldForZipCode) {
            checkSPFieldForZipCode = false;
            for(Account acc: (List<Account>)newList) {
                if(acc.RecordtypeId == recTypeOutlet && (acc.ShippingPostalCode != oldMap.get(acc.id).ShippingPostalCode)) {
                    outletAccIds.add(acc.Id);
                }
            }
            //check the validations and add to the sObject Collection to Update
            if(!outletAccIds.isEmpty()) {
                for(FS_Installation__c fsInst : [SELECT Id,Name, Overall_Status2__c,FS_Outlet__c FROM FS_Installation__c
                                                 WHERE FS_Outlet__c in :outletAccIds ORDER BY LastModifiedDate ]) {
                                                     installationList.add(fsInst);
                                                 }
                //placing values on dynamic sobject map for installation updates
                if(!installationList.isEmpty()) {
                    for(FS_Installation__c inst: installationList){
                        if(sObjectsToUpdate.containskey(inst.Id)){
                            final FS_Installation__c instObj=(FS_Installation__c)sObjectsToUpdate.get(inst.Id);
                            instObj.Overall_Status2__c=inst.Overall_Status2__c;
                            instObj.FS_Outlet__c=inst.FS_Outlet__c;
                            sObjectsToUpdate.put(instObj.Id,instObj);
                        }else{
                            sObjectsToUpdate.put(inst.Id,new FS_Installation__c(Id=inst.Id,Overall_Status2__c=inst.Overall_Status2__c,FS_Outlet__c=inst.FS_Outlet__c));
                        }
                    }
                }
            }
        }
    }
    /** @Description - This method is used to update the number series 
of outlet dispenser if the fields of account are modified.
* @param - Trigger context variables(Trigger.oldMap,Trigger.new)
* @Return - void
*/
    public static void updateOutletDispenserOnAccFieldModification(final Map<Id,Account> oldMap,final List<Account> newList,final Boolean IsBatch){
        final Set<Id> modifiedFieldsAccId = new Set<Id>();//to hold list of account Ids for which fields were modified
        final Map<Id, String> mapDispenserIdstrDispenserAttrChange = new Map<Id, String>();//to hold Ids and dispenser string of the outlet dispensers
        final Set<Id> hqSet = new Set<Id>();//to hold set of HQ account Ids for which name or FS_ACN__c fields were modified
        final Set<Id> chainSet = new Set<Id>();//to hold set of Chain acc Ids for which name or FS_ACN__c fields were modified
        final String OD_reg_Status=Label.OD_Register_Status;//string to hold the status(Enrolled ,Winterized ,Wakeup) of Account
        final String integrationUserId = FSConstants.getIntegrationUserID();//to fetch the integration userId
        //Process block to add records to collections
        
        System.debug('J-F inside updateOutletDispenserOnAccFieldModification');

        for(Account acc : newList){
            account oldacc = oldMap.get(acc.id);
            if(mapofRecordtypIdAndRecordTypeName.containsKey(acc.RecordTypeId)) {
                if((mapofRecordtypIdAndRecordTypeName.get(acc.RecordTypeId) == Label.OUTLET_RECORD_TYPE)||(mapofRecordtypIdAndRecordTypeName.get(acc.RecordTypeId) == Label.INTERNATIONAL_OUTLET_RECORD_TYPE)){
                    if((acc.ShippingCity != oldacc.ShippingCity) || (acc.ShippingPostalCode != oldacc.ShippingPostalCode)
                       || (acc.ShippingState != oldacc.ShippingState) || (acc.ShippingStreet != oldacc.ShippingStreet)
                       || (acc.ShippingCountry != oldacc.ShippingCountry) || (acc.Name != oldacc.name)
                       || (acc.FS_Headquarters__c!= oldacc.FS_Headquarters__c) || (acc.FS_Chain__c!= oldacc.FS_Chain__c)
                       || (acc.Bottler_Name__c!=oldacc.Bottler_Name__c) || (acc.Bottlers_Name__c!=oldacc.Bottlers_Name__c)) {
                           modifiedFieldsAccId.add(acc.id);
                       }
                       System.debug('J-F Number of Outlets: ' + modifiedFieldsAccId.size());
                } else if(mapofRecordtypIdAndRecordTypeName.get(acc.RecordTypeId) == Label.HQ_RECORD_TYPE) {
                    if((acc.Name != oldacc.name) || (acc.FS_ACN__c != oldacc.FS_ACN__c)) {
                        hqSet.add(acc.id);
                        System.debug('J-F Found change: ' + acc.Name + ', ' + oldacc.name +', ' + acc.FS_ACN__c + ', ' + oldacc.FS_ACN__c);
                    }
                }                 
                else if(mapofRecordtypIdAndRecordTypeName.get(acc.RecordTypeId) == Label.CHAIN_RECORD_TYPE && ((acc.Name != oldacc.name) || (acc.FS_ACN__c != oldacc.FS_ACN__c))) {
                    chainSet.add(acc.id);
                    System.debug(LoggingLevel.DEBUG, 'J-F Found change on Chain: ' + acc.Name + ', ' + oldacc.name + ', ' + acc.FS_ACN__c + ', ' + oldacc.FS_ACN__c);
                }                
            }
        }
        //Criteria to add ids into set
        if(!hqSet.isEmpty() || !chainSet.isEmpty()){
            for(Account acc : [SELECT name, id FROM Account WHERE FS_Headquarters__c in :hqSet OR FS_Chain__c in :chainSet]){
                modifiedFieldsAccId.add(acc.id);
            }
            System.debug(LoggingLevel.DEBUG, 'J-F Number of modifiedFieldsAccId: ' + modifiedFieldsAccId.size() + ', HQ Set size: ' + hqSet.size() + ', Chain Set Size: ' + chainSet.size());
        }
        //Process block
        if(!modifiedFieldsAccId.isEmpty()){
            final Id recordId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType,Label.INT_OD_RECORD_TYPE);
            //dispenserMap is used to hold map with details of FS_Outlet_Dispenser__c 
            //object where outlets are modified HQ or Chain accounts
            final Map<Id,FS_Outlet_Dispenser__c> dispenserMap = new Map<Id, FS_Outlet_Dispenser__c>
                ([SELECT id,name,FS_Status__c,RecordTypeId,Send_Create_Request__c,LastModifiedById FROM FS_Outlet_Dispenser__c WHERE FS_Outlet__c in : modifiedFieldsAccId]);
            for(Id idOutletDispenser : dispenserMap.keyset()) {
                if(recordId !=dispenserMap.get(idOutletDispenser).RecordTypeId){
                    mapDispenserIdstrDispenserAttrChange.put(idOutletDispenser, 'Dispenser');
                }                
                else if(recordId ==dispenserMap.get(idOutletDispenser).RecordTypeId && ((dispenserMap.get(idOutletDispenser).LastModifiedById != integrationUserId) && 
                                                                                        (OD_reg_Status.contains(dispenserMap.get(idOutletDispenser).FS_Status__c)||dispenserMap.get(idOutletDispenser).FS_Status__c==Label.Assigned_to_Outlet))){
                                                                                            mapDispenserIdstrDispenserAttrChange.put(idOutletDispenser, 'Dispenser');
                                                                                        }                
            }
            if(!dispenserMap.isEmpty() && !IsBatch) {
                /**Record Splitter module Start******************************/
                //Records to be processed will be divided into chunks and processed 
                //separately to avoid callout limits
                final Integer recordChunkSize=Integer.valueOf(Label.recordChunkSize);
                final Map<Object, Object> formattedMap = new Map<Object, Object>(); 
                //Convert Map<Id,String> to Map<Object,Object>                
                for(Id  keys: mapDispenserIdstrDispenserAttrChange.keySet()){
                    formattedMap.put((Object)keys,(Object)mapDispenserIdstrDispenserAttrChange.get(keys));
                }
                // Split the Map to as many as with recordChunkSize in each map
                final List<Map<Object,Object>> splittedMap=FSRecordSplitterToAvoidGovernorLimits.processRecords(formattedMap,recordChunkSize);
                if(!splittedMap.isEmpty() && splittedMap.size() < 51){
                    System.debug('J-F Number of splittedMap: ' + splittedMap.size());
                    for(Map<Object,Object> splitMapRecord: splittedMap){
                        final Map<Id, String> mapDispenserIdstrDispenserAttrChangeOriginal = new Map<Id, String>();
                        for(Object obj : splitMapRecord.keySet()){
                            mapDispenserIdstrDispenserAttrChangeOriginal.put((Id)obj,(String)splitMapRecord.get(obj));
                        }   
                        FSFETNMSConnector.airWatchAsynchronousCall(NULL,mapDispenserIdstrDispenserAttrChangeOriginal); 
                    }
                }
                /**Record Splitter module End******************************/
            }            
        }        
    }
    /** @Desc - This Method is used to update account's owner and Delete old 
market Account Team junction having same market Id and insert new.
* @param - Trigger context variables
(Trigger.new,Trigger.oldMap,Trigger.isInsert) and System.isbatch()
* @Return - void
*/
    public static void updateAccountTeamMemberFields(final List<Account> newList,final Map<Id,Account> oldMap,final Boolean isInsert,final Boolean IsBatch){
        final Map<Id,Account> mapAccountsUpdated = new Map<Id,Account>();//collection to hold Account details if MarketId value is changed
        //Criteria check to hold the records into collection
        for(Account acc : newList){
            if(!String.isBlank(acc.FS_Market_ID__c) && ( isInsert || oldMap.get(acc.Id).FS_Market_ID__c != acc.FS_Market_ID__c)){
                mapAccountsUpdated.put(acc.Id,new Account(Id = acc.id , FS_Market_ID__c = acc.FS_Market_ID__c));
            }
        }
        //criteria check to process the records
        if(!mapAccountsUpdated.isEmpty()){
            if(isBatch){
                FSAlignAccountTeamMembersUtility.alignAccountTeam(mapAccountsUpdated.values(), false);
            }
            else{
                FSAlignAccountTeamMembersUtility.alignAccountTeamFromTrigger(mapAccountsUpdated.keyset(), isInsert);
            }
        }
    }
    /** @Description - This Method is used to run batch to 
update SAPID and CustomerInvoice.
* @param - Trigger context variables
(Trigger.new,Trigger.oldMap,Trigger.isUpdate) and System.IsBatch()
* @Return - void
*/
    public static void updateSAPIDAndCustomerInvoice(final List<Account> newList,final Map<Id,Account> oldMap,final Boolean isUpdate,final Boolean IsBatch){
        if(isUpdate && !isBatch) {
            final Set<Id> lstAllChainAccIds = new Set<Id>();//Collection to store Chain AccountIds where fields are modified
            final Set<Id> lstAllHQAccIds = new Set<Id>();//Collection to store HQ AccountIds where fields are modified
            final Set<Id> lstAllOTAccIds = new Set<Id>();//Collection to store Outlet AccountIds where SAPID is modified
            //to hold account Id if Invoice_Customer__c is modified
            final Map<Id, Boolean> mapChangedInvoiceCustomer = new Map<Id, Boolean>();
            //to hold account Id if FS_Payment_Type__c or FS_Payment_Method__c is modified
            final Map<Id, Boolean> mapChangedProgramFee = new Map<Id, Boolean>();
            //to hold account Id if Invoice_Delivery_Method__c is updated with new value
            final Map<Id, Boolean> mapInvoiceDeliveryMethod = new Map<Id, Boolean>();
            //to hold account Id if Secondary_Email_1__c is updated with new value  
            final Map<Id, Boolean> mapSecondaryEmail1 = new Map<Id, Boolean>();
            //to hold account Id if Secondary_Email_2__c is updated with new value
            final Map<Id, Boolean> mapSecondaryEmail2 = new Map<Id, Boolean>();
            //to hold account Id if Secondary_Email_3__c is updated with new value
            final Map<Id, Boolean> mapSecondaryEmail3 = new Map<Id, Boolean>();
            //to hold account Id if Secondary_Email_4__c is updated with new value
            final Map<Id, Boolean> mapSecondaryEmail4 = new Map<Id, Boolean>(); 
            //to hold account Id if Secondary_Email_5__c is updated with new value
            final Map<Id, Boolean> mapSecondaryEmail5 = new Map<Id, Boolean>();
            //to hold account Id if FS_SAP_ID__c is updated with new value          
            final Map<Id, Boolean> mapFSSAPID = new Map<Id, Boolean>();
            //to hold the value if cartridge fee payment method is changed
            Boolean checkCarPaymentMethodChange=false;
            //to hold the value if approval cartridge fee is changes
            Boolean checkAppCarPayment=false;
            //criteria block
            for(Account acc : newList){
                // FET 4.0 change
                // included condition to check whether Cartridge payment method is updated with new value 
                account oldacc = oldMap.get(acc.id);
                if(acc.RecordTypeId  == recTypeChain
                   && (acc.Invoice_Customer__c != oldacc.Invoice_Customer__c 
                       || acc.Cokesmart_Payment_Method__c  != oldacc.Cokesmart_Payment_Method__c )) {
                           lstAllChainAccIds.add(acc.Id);
                           mapChangedInvoiceCustomer.put(acc.Id, true);
                       }
                if(acc.RecordTypeId  == recTypeHQ
                   && (acc.Invoice_Customer__c  != oldacc.Invoice_Customer__c 
                       || acc.Cokesmart_Payment_Method__c  != oldacc.Cokesmart_Payment_Method__c ))  {
                           lstAllHQAccIds.add(acc.Id);
                           mapChangedInvoiceCustomer.put(acc.Id, true);
                       }
                
                //Check for cartridge fee payment method is changing at outlet level - 
                //then update boolean variable to true and pass this variable to batch class
                //In batch class use this variable to check and update cartridge fee payment meatahod on outlet
                if(acc.RecordTypeId  == recTypeHQ && (acc.Cokesmart_Payment_Method__c  != oldacc.Cokesmart_Payment_Method__c ))  {
                    checkCarPaymentMethodChange=true;
                }
                if(acc.RecordTypeId  == recTypeHQ && (acc.Invoice_Customer__c != oldacc.Invoice_Customer__c ))  {
                    checkAppCarPayment=true;
                }   
                
                if(acc.RecordTypeId  == recTypeChain && (acc.FS_Payment_Type__c  != oldacc.FS_Payment_Type__c
                                                         || acc.FS_Payment_Method__c  != oldacc.FS_Payment_Method__c ) ) {
                                                             lstAllChainAccIds.add(acc.Id);
                                                             mapChangedProgramFee.put(acc.Id, true);
                                                         }
                if(acc.RecordTypeId  == recTypeHQ && (acc.FS_Payment_Type__c  != oldacc.FS_Payment_Type__c
                                                      || acc.FS_Payment_Method__c  != oldacc.FS_Payment_Method__c ) ) {
                                                          lstAllHQAccIds.add(acc.Id);
                                                          mapChangedProgramFee.put(acc.Id, true);
                                                      }
                if(acc.RecordTypeId  == recTypeHQ) {
                    if((acc.Invoice_Delivery_Method__c!=oldacc.Invoice_Delivery_Method__c) && (!String.isBlank(acc.Invoice_Delivery_Method__c) 
                                                                                               && oldacc.Invoice_Delivery_Method__c==null)){
                                                                                                   lstAllHQAccIds.add(acc.Id);
                                                                                                   mapInvoiceDeliveryMethod.put(acc.Id, true);
                                                                                               }
                    if((acc.Secondary_Email_1__c!=oldacc.Secondary_Email_1__c) && (!String.isBlank(acc.Secondary_Email_1__c) && oldacc.Secondary_Email_1__c==null)){
                        lstAllHQAccIds.add(acc.Id);
                        mapSecondaryEmail1.put(acc.Id, true);
                    }
                    if((acc.Secondary_Email_2__c!=oldacc.Secondary_Email_2__c) && (!String.isBlank(acc.Secondary_Email_2__c) && oldacc.Secondary_Email_2__c==null)){
                        lstAllHQAccIds.add(acc.Id);
                        mapSecondaryEmail2.put(acc.Id, true);
                    }
                    if((acc.Secondary_Email_3__c!=oldacc.Secondary_Email_3__c) && (!String.isBlank(acc.Secondary_Email_3__c) && oldacc.Secondary_Email_3__c==null)){
                        lstAllHQAccIds.add(acc.Id);
                        mapSecondaryEmail3.put(acc.Id, true);
                    }
                    if((acc.Secondary_Email_4__c!=oldacc.Secondary_Email_4__c) && (!String.isBlank(acc.Secondary_Email_4__c) && oldacc.Secondary_Email_4__c==null)){
                        lstAllHQAccIds.add(acc.Id);
                        mapSecondaryEmail4.put(acc.Id, true);
                    }
                    if((acc.Secondary_Email_5__c!=oldacc.Secondary_Email_5__c) && (!String.isBlank(acc.Secondary_Email_5__c) && oldacc.Secondary_Email_5__c==null)){
                        lstAllHQAccIds.add(acc.Id);
                        mapSecondaryEmail5.put(acc.Id, true);
                    }
                } 
                if(acc.RecordTypeId  == recTypeOutlet && ((acc.FS_SAP_ID__c!=oldacc.FS_SAP_ID__c) && (!String.isBlank(acc.FS_SAP_ID__c)))){
                    lstAllOTAccIds.add(acc.Id);
                    mapFSSAPID.put(acc.Id, true);
                }                
            }            
            if(!lstAllChainAccIds.isEmpty() ||!lstAllHQAccIds.isEmpty() ) {
                //Customer Invoice field will be updated in batch class
                Database.executeBatch( new FSUpdateInvoiceForAccountBatch(lstAllChainAccIds, lstAllHQAccIds,
                                                                          mapChangedInvoiceCustomer, mapChangedProgramFee,mapInvoiceDeliveryMethod,
                                                                          mapSecondaryEmail1,mapSecondaryEmail2,mapSecondaryEmail3,mapSecondaryEmail4,mapSecondaryEmail5,checkCarPaymentMethodChange,checkAppCarPayment), BATCHSIZE);
            }
            // Batch for SAPID calling FSUpdateSAPIDForAccountBatch class
            if(!lstAllOTAccIds.isEmpty() ) {
                //SAPID will be update in batch class
                Database.executeBatch( new FSUpdateSAPIDForAccountBatch(lstAllOTAccIds), BATCHSIZE);
            }
        }
    }
    /** @Description - This Method is used to update standard shipping address fields
from custom shipping address for international records only.
* @param - Trigger context variables(Trigger.new)
* @Return - void
*/
    public static void updateStandardShippingAddress(final List<Account> newList){
        Set<String> outletCodes = new Set<String>();
        for(FS_Outlet_Country_Codes__mdt codes:[select masterLabel from FS_Outlet_Country_Codes__mdt]){
            outletCodes.add(codes.masterLabel);
        }
        for(Account acc : (List<Account>) newList){
            if(acc.RecordTypeId==recTypeOutlet && outletCodes!=null){
                if(acc.shippingcountry==null || ( acc.shippingcountry!=null && !outletCodes.contains(acc.ShippingCountry))){
                    acc.RecordTypeId=recTypeInternationalOutlet;
                    acc.FS_Shipping_Street_Int__c = acc.shippingStreet!=null?acc.shippingStreet:acc.FS_Shipping_Street_Int__c;
                    acc.FS_Shipping_City_Int__c = acc.shippingCity!=null?acc.shippingCity:acc.FS_Shipping_City_Int__c;
                    acc.FS_Shipping_State_Province_INT__c = acc.shippingState!=null?acc.shippingState:acc.FS_Shipping_State_Province_INT__c;
                    acc.FS_Shipping_Country_Int__c = acc.shippingCountry!=null?acc.shippingCountry:acc.FS_Shipping_Country_Int__c;
                    acc.FS_Shipping_Zip_Postal_Code_Int__c = acc.ShippingPostalCode!=null?acc.ShippingPostalCode:acc.FS_Shipping_Zip_Postal_Code_Int__c;
                    
                }
            }
            //Check for 'FS International Outlet' record type  
            if(acc.RecordTypeId == recTypeInternationalOutlet){ 
                acc.shippingStreet=acc.FS_Shipping_Street_Int__c;
                acc.shippingCity=acc.FS_Shipping_City_Int__c;
                acc.shippingState=acc.FS_Shipping_State_Province_INT__c;
                acc.shippingCountry=acc.FS_Shipping_Country_Int__c;
                acc.ShippingPostalCode=acc.FS_Shipping_Zip_Postal_Code_Int__c;
            }
            
        }   
    }
    
    /** @Description - This Method is used to update SAP ID for international
records only.
* @param - Trigger context variables(Trigger.new)
* @Return - void
*/
    public static void updateAutoSAPID(final List<Account> newList){
        final Map<string,ISO_Country__c> mapCodes = ISO_Country__c.getAll();
        
        for(Account acc : (List<Account>) newList){
            //Check for FS_Inter_Outlet record type 
            
            if(acc.RecordTypeId == recTypeInternationalOutlet && mapCodes.containsKey(Acc.FS_Shipping_Country_Int__c) && Acc.FS_SAP_ID__c==null){
                
                final String countryCode=mapCodes.get(Acc.FS_Shipping_Country_Int__c).ISO_Code__c;                 
                acc.FS_SAP_ID__c=countryCode + acc.Autogenerated_SAP__c;
                acc.FS_ACN__c = countryCode + acc.Autogenerated_SAP__c;
                acc.CCR_ACN_RecordType_Id__c = acc.FS_ACN__c +'-'+ acc.recordtypeID;                
            }
        }   
    }
    public static void updateAutoSAPIDonCountryChange(final List<Account> newList){
        final Map<string,ISO_Country__c> mapCodes = ISO_Country__c.getAll();
        
        for(Account acc : (List<Account>) newList){
            //Check for FS_Inter_Outlet record type  
            if(acc.RecordTypeId == recTypeInternationalOutlet && mapCodes.containsKey(Acc.FS_Shipping_Country_Int__c) && !acc.Is_Default_FET_International_Outlet__c && acc.nb_Outlet_Dispensers__c == 0 && Acc.FS_SAP_ID__c != null){
                
                final String countryCode=mapCodes.get(Acc.FS_Shipping_Country_Int__c).ISO_Code__c;                 
                acc.FS_SAP_ID__c=countryCode + acc.Autogenerated_SAP__c;
                acc.FS_ACN__c = countryCode + acc.Autogenerated_SAP__c;
                acc.CCR_ACN_RecordType_Id__c = acc.FS_ACN__c +'-'+ acc.recordtypeID;                
            }
        }   
    }
    
    
    /*****************************************************************
Method: updateJETIndicatorAction
Description: updateJETIndicatorAction method to update JET indicator Action Needed when there is an update of Active JET field from SAP 
or Platform Type Change at Installation.	
New:Added as part FET 5.0 Sprint 4 :FET 145	
Modified: FET 5.1 Sprint 8: 663; 664
Modified: FET 7.1 Sprint 1: FNF-1018/170
*******************************************************************/
    public static void updateJETIndicatorAction(final List<Account> newList,final Map<Id,Account> oldMap){
        //Map to store Platform type respective JET indicator Value
        //FNF-157,FNF-88 Adding M series Platforms
        //FET 7.1 6000/7100 Platform Changes
        final Map<String,String> platformJETIndicatorMap=new Map<String,String>{FSConstants.RECTYPE_7k=>'MV',FSConstants.RECTYPE_8k=>'JT Crew',FSConstants.RECTYPE_9k=>'JT',FSConstants.RECTYPE_91k=>'JJ',FSConstants.RECTYPE_6k=>'JM',FSConstants.RECTYPE_65k=>'JET6',FSConstants.RECTYPE_71k=>'MT'};
            //Map to store Platform type respective JET indicator Action Needed Value
            //FNF-157 updating Map with M series for New Install
            //FET 7.1 6000/7100 Platform Changes
            final Map<String,String> platformJETActionMap=new Map<String,String>{FSConstants.RECTYPE_7k=>'Add MV',FSConstants.RECTYPE_8k=>'Add JT Crew',FSConstants.RECTYPE_9k=>'Add JT',FSConstants.RECTYPE_91k=>'Add JJ',FSConstants.RECTYPE_6k=>'Add JM',FSConstants.RECTYPE_65k=>'Add JET6',FSConstants.RECTYPE_71k=>'Add MT'};        
                //Map to store Platform type respective JET indicator Action PIA Needed Value
                //FNF-157 updating Map with M series for Post Install
                //FET 7.1 6000/7100 Platform Changes
                final Map<String,String> platformJETRemoveActionMap=new Map<String,String>{FSConstants.RECTYPE_7k=>'Remove MV',FSConstants.RECTYPE_8k=>'Remove JT Crew',FSConstants.RECTYPE_9k=>'Remove JT1',FSConstants.RECTYPE_91k=>'Remove JJ',FSConstants.RECTYPE_6k=>'Remove JM',FSConstants.RECTYPE_65k=>'Remove JET6',FSConstants.RECTYPE_71k=>'Remove MT'};        
                    //Set to store Outlet record Ids
                    final Set<Id> outletIdSet=new Set<Id>();
        //Listing only those Outlets where there a change in Active JET indicator field from SAP or Count Of Active Dispensers changed
        for(Account acc:newList){
            if(acc.RecordTypeId==recTypeOutlet && 
               (acc.FS_Active_SAP_Jet_Indicators__c!=oldMap.get(acc.Id).FS_Active_SAP_Jet_Indicators__c ||
                acc.FS_JET_UpdateDateTime__c!=oldMap.get(acc.Id).FS_JET_UpdateDateTime__c || acc.FS_Count_Total_number_of_Dispensaries__c!=oldMap.get(acc.Id).FS_Count_Total_number_of_Dispensaries__c)){
                    
                    outletIdSet.add(acc.Id);
                }
        }
        
        //fetching Outlet records and also querying List of New Insatall, Removal, Relocation (O4W) which are Open and also Active ODs
        //FET-1249 Changes Start by Changing Criteria for Fetch List of OD records which are not went for Removal /RO4W /Replacement for JET indicator Action Needed logic on PIA
        Map<Id,Account> accWithInstallMap=new Map<Id,Account>(
            [SELECT Id,(select id,FS_Equip_Type__c,FS_IsActive__c,FS_Other_PIA_Installation__c from Outlet_Dispensers__r where FS_Equip_Type__c!=null and FS_IsActive__c=true and FS_Other_PIA_Installation__c=null ),
             (select id,name,Type_of_Dispenser_Platform__c,RecordTypeId,Overall_Status2__c from Installations1__r where RecordTypeId IN (:FSInstallationValidateAndSet.ipNewRecType,:FSInstallationValidateAndSet.ipRecTypeRelocationO4W,:FSInstallationValidateAndSet.ipRecTypeRemoval) and Overall_Status2__c NOT IN (:FSConstants.IPCOMPLETE, :FSConstants.IPCANCELLED ))
             from Account where Id IN:outletIdSet]);
        
        for(Account acc:newList){            
            if(outletIdSet.contains(acc.Id) && accWithInstallMap.containsKey(acc.Id)){
                //Set to store Platforms under New Installation records in this Outlet Iteration
                final Set<String> platformSetNew=new Set<String>();
                //Set to store Platforms under PIA Installation records in this Outlet Iteration
                final Set<String> platformSetPIA=new Set<String>();
                //Set to store the JET indicators selected under Outlet by SAP
                final Set<String> jetOutletSet=new Set<String>();
                //Set to store the Equip Type of the Active ODs present under this Outlet   
                final Set<String> odEquipSet=new Set<String>();
                //String to store JET indicator Action needed for New Install
                String jetIndicatorAction='';
                //String to store JET indicator Action needed for PIA Installation
                String jetIndicatorActionPIA='';
                //Storing all JET Indicators selected by SAP under the Outlet into SET
                if(acc.FS_Active_SAP_Jet_Indicators__c!=null){
                    List<String> jetList=acc.FS_Active_SAP_Jet_Indicators__c.split(';');
                    jetOutletSet.addAll(jetList);
                }
                //Creating Instance of Account and Getting value from Map
                final Account accountRec=accWithInstallMap.get(acc.Id);
                //Storing the equip type of OD records 
                for(FS_Outlet_Dispenser__c od:accountRec.Outlet_Dispensers__r){
                    odEquipSet.add(od.FS_Equip_Type__c);
                } 
                //Iterating the installation records under the outlet
                for(FS_Installation__c install:accountRec.Installations1__r){
                    //Storing the platform type/s of New install records under the outlet
                    if(install.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && install.Type_of_Dispenser_Platform__c!=null){
                        List<String> platformList=install.Type_of_Dispenser_Platform__c.Split(';');
                        platformSetNew.addAll(platformList);
                    } 
                    //Storing the platform type/s of PIA installation records under the outlet
                    if(install.RecordTypeId!=FSInstallationValidateAndSet.ipNewRecType && install.Type_of_Dispenser_Platform__c!=null){
                        List<String> platformList=install.Type_of_Dispenser_Platform__c.Split(';');
                        platformSetPIA.addAll(platformList);
                    } 
                }
                //Iterating New Install platform set to populate JET Action Needed based on conditions
                for(String platform:platformSetNew){                   
                    if(platformJETActionMap.containsKey(platform) && (jetOutletSet.isEmpty() || (platformJETIndicatorMap.containsKey(platform) && !jetOutletSet.contains(platformJETIndicatorMap.get(platform))))){
                        jetIndicatorAction=jetIndicatorAction+platformJETActionMap.get(platform)+';'+' ';                       
                    }                    
                }
                //Iterating PIA Installation platform set to populate JET Action Needed based on conditions
                for(String platform:platformSetPIA){                   
                    if(platformJETRemoveActionMap.containsKey(platform) && !jetOutletSet.isEmpty() && platformJETIndicatorMap.containsKey(platform) && jetOutletSet.contains(platformJETIndicatorMap.get(platform)) && !odEquipSet.contains(platform) ){
                        jetIndicatorActionPIA=jetIndicatorActionPIA+platformJETRemoveActionMap.get(platform)+';'+' ';                       
                    }                    
                }
                if(!string.isBlank(jetIndicatorAction)){
                    jetIndicatorAction=jetIndicatorAction.substring(0,jetIndicatorAction.length()-2);
                }
                if(!string.isBlank(jetIndicatorActionPIA)){
                    jetIndicatorActionPIA=jetIndicatorActionPIA.substring(0,jetIndicatorActionPIA.length()-2);
                }
                //Assigning the JET indicator Action values to respective fields under the Outlet
                acc.FS_Jet_Indicator_Action_Needed__c=jetIndicatorAction;
                acc.FS_JetIndicator_ActionNeeded_PIA__c=jetIndicatorActionPIA;
            }
        }        
    }
 
    
    /************************************************************** 
*Method: InheritInvoicefieldsfromHQ_to_OL
*Description: Inherit Invoice fields from HQ to OL
*
***************************************************************/
    public static void inheritInvoicefieldsfromHQtoOL(final List<Account> newList,final Map<Id,Account> oldAccMap,Boolean isInsert,Boolean isUpdate){
        MAP<id,Account> accRecMAP = new Map<id,Account>();
        Set<id> accIDset = new Set<id>();
        Set<id> mainAccIDset = new Set<id>();
        for(Account acc:newList){
            if(acc.recordtypeId==recTypeOutlet && acc.FS_Headquarters__c!=FSConstants.NULLVALUE && (isInsert || (isUpdate && oldAccMap.get(acc.Id).FS_Headquarters__c!=acc.FS_Headquarters__c))){
                accIDset.add(acc.FS_Headquarters__c);
                mainAccIDset.add(acc.id);
            } 
               if(acc.recordtypeId==recTypeHQ && acc.FS_Chain__c!=FSConstants.NULLVALUE && (isInsert || (isUpdate && oldAccMap.get(acc.Id).FS_Chain__c!=acc.FS_Chain__c))){
                   accIDset.add(acc.FS_Chain__c);
                   mainAccIDset.add(acc.id);
               } 
                  
        }
        if(!accIDset.ISEMPTY()){
            for(Account acc: [Select id,Cokesmart_Payment_Method__c,FS_Payment_Method__c,FS_Payment_Type__c,Invoice_Customer__c from Account where ID=:accIDset]){
                accRecMAP.put(acc.id,acc);
            }
        }
        if(!accIDset.ISEMPTY()){
            for(Account acc:newList){
                if(acc.RecordTypeId==recTypeOutlet && mainAccIDset.contains(acc.id) && accRecMAP.containsKey(acc.FS_Headquarters__c)){
                    Account accRec= accRecMAP.get(acc.FS_Headquarters__c);
                    acc.Cokesmart_Payment_Method__c = accRec.Cokesmart_Payment_Method__c;
                    acc.FS_Payment_Method__c = accRec.FS_Payment_Method__c;
                    acc.FS_Payment_Type__c = accRec.FS_Payment_Type__c;
                    acc.Invoice_Customer__c = accRec.Invoice_Customer__c;
                }
                if(acc.RecordTypeId==recTypeHQ &&  mainAccIDset.contains(acc.id) && accRecMAP.containsKey(acc.FS_Chain__c)){
                    Account accRec= accRecMAP.get(acc.FS_Chain__c);
                    acc.FS_Payment_Type__c = accRec.FS_Payment_Type__c;
                    acc.Invoice_Customer__c = accRec.Invoice_Customer__c;
                }                
            }  
        }        
    }
}