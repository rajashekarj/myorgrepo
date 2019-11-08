/*********************************************************************************************************
Name         : FSAccountAuthorizationAndPopulateFields
Created By   : Infosys
Created Date : 02-Nov-2016
Usage        : This class holds the common business logic of the AccountTrigger where authorization is checked or fields are set and is called from the FSAccountTrigger.
Methods      : skipAuthorizationForBottler,populateFieldsBeforeInsertAndUpdate,populateSPAlignedZipOnOutlets,bottlerAuthorizationCheck
***********************************************************************************************************/
public class FSAccountAuthorizationAndPopulateFields {
    /** @Desc - This Method is used to skip authorization of user to select bottler.
* @param Trigger context variables(Trigger.oldMap,Trigger.new,Trigger.isUpdate,Trigger.isInsert)
* @Return - void
*/  
    //Constants from FSConstant class
    static final Integer INT_ONE = 1;
    static final Integer INT_TWO = 2; 
    public static Boolean executedbeforeUpdate =false;
    public Static Id recTypeOutlet=FSAccountUpdation.recTypeOutlet;
    public Static Id recTypeChain=FSAccountUpdation.recTypeChain;
    public Static Id recTypeHQ=FSAccountUpdation.recTypeHQ;
    public Static Id recTypeInternationalOutlet=FSAccountUpdation.recTypeInternationalOutlet;
    //FET - 1379 Changes by moving query from "skipAuthorizationForBottler" method to public instance
    public static final User userDetails=[SELECT ID,FS_Permission_Sets__c,profile.name FROM USER WHERE ID=:userinfo.getUserId()]; 
    public static void skipAuthorizationForBottler(final Map<Id,Account> oldMap,final List<Account> newList, final Boolean isUpdate, final Boolean isInsert){ 
        //user object to hold FS_Permission_Sets__c,profile.name of current user
        //FET - 1379 Commenting query and moving to Public Variable Instance for Class level access
        //final User userDetails=[SELECT ID,FS_Permission_Sets__c,profile.name FROM USER WHERE ID=:userinfo.getUserId()];   
        Account oldAccount;//to store the account details if its an existing account
        //process block for authorization check
        if(!executedbeforeUpdate){ 
            for(Account acc:newList){             
                if(isUpdate){
                    oldAccount=oldMap.get(acc.id);
                }
                if(IsInsert && acc.recordtypeId==recTypeOutlet){
                    bottlerAuthorizationCheck(acc,userDetails.FS_Permission_Sets__c,userDetails.profile.Name);                    
                }  
                if(IsUpdate && acc.recordtypeId==recTypeOutlet && (acc.FS_Requested_Order_Method__c!=oldAccount.FS_Requested_Order_Method__c 
                                                                                     ||acc.FS_Requested_Delivery_Method__c!=oldAccount.FS_Requested_Delivery_Method__c 
                                                                                     ||acc.FS_Approved_Bottler_Order_Delivery__c!=oldAccount.FS_Approved_Bottler_Order_Delivery__c)){
                                                                                         bottlerAuthorizationCheck(acc,userDetails.FS_Permission_Sets__c,userDetails.profile.Name);                
                                                                                     }                                                
            }
            executedbeforeUpdate =true;
        } 
    }
    
    /** @Desc - This Method is used to populate Account fields for outlet and HQ before Insert event.
* @param - Trigger context variables(Trigger.new)
* @Return - void
*/
    public static void populateFieldsBeforeInsert(final List<Account> newList){
        
        final List<account> lstAccountForShipping = new List<Account>();//to hold the list of outlet Accounts with proper ShippingPostalCode
        final Set<String> shippingPostalCodeSet = new Set<String>();//collection to hold ShippingPostalCode till 5 characters for outlet Accounts
        //retriving the records which meet below criteria
        for(Account acc : newList){
            if(acc.RecordTypeId == recTypeOutlet && !String.isBlank(acc.ShippingPostalCode) && acc.ShippingPostalCode.length() >= 5){
                shippingPostalCodeSet.add(acc.ShippingPostalCode.subString(0,5));
                lstAccountForShipping.add(acc);
            }
        }
        
        final Set<Id> fsChainIds=new Set<Id>(); //To Store Account Ids of FS Chain RecordType from trigger's new list
        final Set<Id> fsHQIds=new Set<Id>();//To Store Account Ids of FS HeadQuarter record Type from trigger's new list
        final Map<Id,Account> accFSChainMap = new Map<Id,Account>();//Collection to hold account Id and account details with Chain record type
        final Map<Id,Account> accFSHQMap = new Map<Id,Account>();//Collection to hold account Id and account details with HQ record type
        
        //add the chain/HQ Ids that meet the criteria
        for(Account acc : newList){
            if(acc.RecordTypeId == recTypeHQ && !String.isBlank(acc.FS_Chain__c)){
                fsChainIds.add(acc.FS_Chain__c);
            }
            if(acc.RecordTypeId == recTypeOutlet  && !String.isBlank(acc.FS_Headquarters__c)){
                fsHQIds.add(acc.FS_Headquarters__c);
            }
        }
        //criteria block to store records
        if(!fsChainIds.isEmpty() || !fsHQIds.isEmpty()){
            for(Account  acc : [select id,FS_CE_Enabled__c,FS_LTO__c,FS_Promo_Enabled__c,FS_FAV_MIX__c,
                                Invoice_Delivery_Method__c,Secondary_Email_1__c,Secondary_Email_2__c,Secondary_Email_3__c,
                                Secondary_Email_4__c,Secondary_Email_5__c,RecordTypeId from Account where Id in:fsChainIds OR Id in:fsHQIds]){
                                    if(acc.RecordTypeId==recTypeChain){
                                        accFSChainMap.put(acc.Id,acc);
                                    }
                                    else if(acc.RecordTypeId==recTypeHQ){
                                        accFSHQMap.put(acc.Id,acc);
                                    }
                                }
        }
        //process block to assign the values to Account Fields
        processBlock(newList,accFSChainMap,accFSHQMap);
        
        final Set<String> outletAccIds = new Set<String>();//collection to store Account Ids of outlets
        //process block to hold the Ids of Outlet Accounts
        for(Account acnt: newList) {
            if(acnt.RecordtypeId == FSAccountUpdation.mapofRecordtypNameAndRecordTypeId.get('FS Outlet') && !String.isBlank(acnt.Id)) {
                outletAccIds.add(acnt.Id);
            }
        }
        //process block to set the installation field values  
        if(!outletAccIds.isEmpty()){
            instllationProcessBlock(newList,outletAccIds);
        }
        //calling method to populate Zip code on outlets
        if(!lstAccountForShipping.isEmpty()){
            populateSPAlignedZipOnOutlets(lstAccountForShipping,shippingPostalCodeSet);
        }
    }
    
    /** @Desc - This Method is used to populate Account fields for outlet and HQ before Update event.
* @param - Trigger context variables(Trigger.oldMap,Trigger.new)
* @Return - void
*/
    public static void populateFieldsBeforeUpdate(final Map<Id,Account> oldMap,final  List<Account> newList){
        final Map<string,ISO_Country__c> mapCodes = ISO_Country__c.getAll();
          
        final List<account> lstAccountForShipping = new List<Account>();//to hold the list of outlet Accounts with proper ShippingPostalCode
        final  Set<String> shippingPostalCodeSet = new Set<String>();//collection to hold ShippingPostalCode till 5 characters for outlet Accounts
        final Set<Id> fsChainIds=new Set<Id>(); //To Store Account Ids of FS Chain RecordType from trigger's new list
        final Set<Id> fsHQIds=new Set<Id>();//To Store Account Ids of FS HeadQuarter record Type from trigger's new list
        final Map<Id,Account> accFSChainMap = new Map<Id,Account>();//Collection to hold account Id and account details with Chain record type
        final  Map<Id,Account> accFSHQMap = new Map<Id,Account>();//Collection to hold account Id and account details with HQ record type
        final Set<String> outletAccIds = new Set<String>();//collection to store Account Ids of outlets
        //retriving the records which meet below criteria
        //add the chain/HQ Ids that meet the criteria
        for(Account acc : newList){
            if(acc.RecordTypeId == recTypeOutlet && !String.isBlank(acc.ShippingPostalCode) && acc.ShippingPostalCode.length() >= 5
               && acc.ShippingPostalCode != oldMap.get(acc.Id).ShippingPostalCode){
                   shippingPostalCodeSet.add(acc.ShippingPostalCode.subString(0,5));
                   lstAccountForShipping.add(acc);
               }
            if(acc.RecordTypeId == recTypeHQ && !String.isBlank(acc.FS_Chain__c)
               && acc.FS_Chain__c!= oldMap.get(acc.Id).FS_Chain__c){
                   fsChainIds.add(acc.FS_Chain__c); 
               }
            if(acc.RecordTypeId == recTypeOutlet  && !String.isBlank(acc.FS_Headquarters__c)
               && acc.FS_Headquarters__c!= oldMap.get(acc.Id).FS_Headquarters__c){
                   fsHQIds.add(acc.FS_Headquarters__c); 
               }
            if(acc.RecordtypeId == recTypeOutlet
               && !String.isBlank(acc.Id)) {
                   outletAccIds.add(acc.Id);
               }
            if(acc.RecordTypeId == recTypeInternationalOutlet && mapCodes.containsKey(Acc.FS_Shipping_Country_Int__c) && Acc.FS_SAP_ID__c==null){
                final String countryCode=mapCodes.get(Acc.FS_Shipping_Country_Int__c).ISO_Code__c;                 
                acc.FS_SAP_ID__c=countryCode + acc.Autogenerated_SAP__c;
                acc.FS_ACN__c = countryCode + acc.Autogenerated_SAP__c;
                acc.CCR_ACN_RecordType_Id__c = acc.FS_ACN__c +'-'+ acc.recordtypeID;                
            }
        }
        //criteria block to store records
        if(!fsChainIds.isEmpty() || !fsHQIds.isEmpty()){
            for(Account  acc : [select id,FS_CE_Enabled__c,FS_LTO__c,FS_Promo_Enabled__c,FS_FAV_MIX__c,
                                Invoice_Delivery_Method__c,Secondary_Email_1__c,Secondary_Email_2__c,Secondary_Email_3__c,
                                Secondary_Email_4__c,Secondary_Email_5__c,RecordTypeId from Account where Id in:fsChainIds OR Id in:fsHQIds]){
                                    if(acc.RecordTypeId==recTypeChain){
                                        accFSChainMap.put(acc.Id,acc);
                                    }
                                    else if(acc.RecordTypeId==recTypeHQ){
                                        accFSHQMap.put(acc.Id,acc);
                                    }
                                }
        }
        
        processBlock(newList,accFSChainMap,accFSHQMap);
        
        //process block to set the installation field values  
        if(!outletAccIds.isEmpty()){
            instllationProcessBlock(newList,outletAccIds);
        }
        //calling method to populate Zip code on outlets
        if(!lstAccountForShipping.isEmpty()){
            populateSPAlignedZipOnOutlets(lstAccountForShipping,shippingPostalCodeSet);
        }
    }
    
    /** @Desc - This method is added in order to process block to assign the values to Account Fields.
* @param - List<Account> newList,Map<Id,Account> accFSChainMap,Map<Id,Account> accFSHQMap
* @Return - void
*/
    public static void processBlock(final List<Account> newList,final Map<Id,Account> accFSChainMap,final Map<Id,Account> accFSHQMap){
        
        //process block to assign the values to Account Fields
        for(Account acc : newList){
            if(!accFSChainMap.isEmpty() && acc.RecordTypeId==recTypeHQ && accFSChainMap.containsKey(acc.FS_Chain__c) && accFSChainMap.get(acc.FS_Chain__c) != null){
                account accFSChain = accFSChainMap.get(acc.FS_Chain__c);
                acc.FS_CE_Enabled__c=accFSChain.FS_CE_Enabled__c;  
                acc.FS_LTO__c=accFSChain.FS_LTO__c;
                acc.FS_Promo_Enabled__c = accFSChain.FS_Promo_Enabled__c;
                acc.FS_FAV_MIX__c = accFSChain.FS_FAV_MIX__c;
            }
            if(!accFSHQMap.isEmpty() && acc.RecordTypeId==recTypeOutlet && accFSHQMap.containsKey(acc.FS_Headquarters__c) && accFSHQMap.get(acc.FS_Headquarters__c) != null){
                account accFSHQ = accFSHQMap.get(acc.FS_Headquarters__c);
                acc.FS_CE_Enabled__c=accFSHQ.FS_CE_Enabled__c;  
                acc.FS_LTO__c=accFSHQ.FS_LTO__c;
                acc.FS_Promo_Enabled__c = accFSHQ.FS_Promo_Enabled__c;
                acc.FS_FAV_MIX__c = accFSHQ.FS_FAV_MIX__c;
                acc.Invoice_Delivery_Method__c=accFSHQ.Invoice_Delivery_Method__c;
                acc.Secondary_Email_1__c=accFSHQ.Secondary_Email_1__c;
                acc.Secondary_Email_2__c=accFSHQ.Secondary_Email_2__c;
                acc.Secondary_Email_3__c=accFSHQ.Secondary_Email_3__c;
                acc.Secondary_Email_4__c=accFSHQ.Secondary_Email_4__c;
                acc.Secondary_Email_5__c=accFSHQ.Secondary_Email_5__c;
                acc.AP_contact_available__c='';
            }
        }
    }
    
    /** @Desc - This method is added in order to process block to set the installation field values.
* @param - List<Account> newList
* @Return - void
*/
    public static void instllationProcessBlock(final List<Account> newList,final Set<String> outletAccIds){
        //collection to hold details of Installation object of 'New Install' type and which is linked with outlet of Trigger list 
        final Map<id,FS_Installation__c> outletIdInstllationMap=new Map<id,FS_Installation__c>();
        //FET 5.0 regular Installation default record type "New Install"    
        for( FS_Installation__c fsInst : [SELECT Id, Overall_Status2__c,FS_Outlet__c,LastModifiedDate FROM FS_Installation__c
                                          WHERE Recordtype.Id=:FSAccountUpdation.ipNewRecType AND FS_Outlet__c in :outletAccIds]){
                                              //FET 5.0 regular Installation default record type "New Install"
                                              if(!String.isBlank(fsInst.FS_Outlet__c) && outletIdInstllationMap.containskey(fsInst.FS_Outlet__c)){
                                                  if(fsInst.LastModifiedDate>outletIdInstllationMap.get(fsInst.FS_Outlet__c).LastModifiedDate){
                                                      outletIdInstllationMap.put(fsInst.FS_Outlet__c,fsInst);
                                                  }
                                              }else{
                                                  outletIdInstllationMap.put(fsInst.FS_Outlet__c,fsInst);
                                              }                      
                                          }
        //Updating account latest installation status based on Overall status of installations
        for(Account acnt: newList) {
            if(outletIdInstllationMap.containsKey(acnt.Id)){
                acnt.Latest_Installation_Status__c = outletIdInstllationMap.get(acnt.Id).Overall_Status2__c;                                 
            }else{
                acnt.Latest_Installation_Status__c ='';
            }
        }
    }
    
    /** @Desc - This method is added in order to populate SP Aligned Zip Field on Outlets.
* @param - List<Account> lstAccountForShipping,Set<String> shippingPostalCodeSet
* @Return - void
*/
    public static void populateSPAlignedZipOnOutlets(final List<Account> lstAccountForShipping, final Set<String> shippingPostalCodeSet){
        final  Map<String,FS_SP_Aligned_Zip__c> spAlignedZipMap = new Map<String,FS_SP_Aligned_Zip__c>();//to hold ZipCode and its details
        //process to add records with given shippingpostalcode into spAlignedZipMap
        for(FS_SP_Aligned_Zip__c cObjSPAlignedZip : [SELECT Id, FS_Zip_Code__c FROM FS_SP_Aligned_Zip__c WHERE FS_Zip_Code__c in :shippingPostalCodeSet]){
            spAlignedZipMap.put(cObjSPAlignedZip.FS_Zip_Code__c,cObjSPAlignedZip);
        }
        //process to set Account's FS_SP_Aligned_Zip__c field 
        for(Account sObjAcc : lstAccountForShipping){
            if(spAlignedZipMap.containsKey(sObjAcc.ShippingPostalCode.subString(0,5))){
                sobjAcc.FS_SP_Aligned_Zip__c = spAlignedZipMap.get(sObjAcc.ShippingPostalCode.subString(0,5)).Id;
            }
        }
    }
    /** @Desc - This is a helper method which is used to validate authorization of user who can select bottler.
* @param - Account acc,String permissionSet,String profileName
* @Return - void
*/  
    private static void bottlerAuthorizationCheck(final Account acc,final String permissionSet,final String profileName){
        //process block to validate the fields and throw error accordingly
        //FET - 1379 Changes by adding OR condition
        if(acc.FS_Requested_Order_Method__c=='Bottler' && (acc.FS_Requested_Delivery_Method__c=='Bottler'||acc.FS_Requested_Delivery_Method__c=='Direct Ship' )
           && !(permissionSet=='Bottler_Approval_Access'|| profileName=='FET System Admin' || profileName=='System Administrator' || profileName=='FS NDO_P' || Label.Exclude_User.contains(profileName))){   
               Acc.addError('You are not authorized to select Bottler in Order and/or Delivery Method fields');
           }
    }
    /** @Desc - This method validates if it is an update event and is of same record type then further validates the fields and throws error accordingly.
* @param - Trigger context variables(Trigger.new,Trigger.isUpdate)
* @Return - void
*/    
    private static void validateHQForBrands(final List<Account> newAccList,final  Boolean isUpdate){
        //Criteria Block:validation on outlet based on static and agitated brands selctions
        if(isUpdate){
            for(Account acc : newAccList){
                //FET - 1379 Changes by adding AND condition
                if(acc.RecordTypeId == recTypeHQ && !Label.Exclude_User.contains(userDetails.profile.Name)){
                    if(!String.isBlank(acc.FS_X7000_Series_Brands_Option_Selections__c)) {
                        List<String> staticSelectionList;//to hold list of Static Brand selection for matching with count in Brand Option Selection
                        List<String> agitatedSelectionList;//to hold list of Agitated Brand selection for matching with count in Brand Option Selection
                        //validations based on two static/one agitated
                        if(acc.FS_X7000_Series_Brands_Option_Selections__c == Label.TwoStatic1Agitated) {
                            if(!String.isBlank(acc.FS_7000_Series_Statics_Brands_Selection__c)) {
                                staticSelectionList = acc.FS_7000_Series_Statics_Brands_Selection__c.split(';');
                                if(staticSelectionList.size() < INT_TWO) {
                                    acc.addError(Label.TwoStaticError);
                                } else if(staticSelectionList.size() > INT_TWO) {
                                    acc.addError(Label.OnlyTwoStaticError);
                                }
                            } else {
                                acc.addError(Label.TwoStaticError);
                            }
                            if(String.isBlank(acc.FS_7000_Series_Agitated_Brands_Selection__c)) {
                                acc.addError(Label.OneAgitatedError);
                            }else{
                                agitatedSelectionList = acc.FS_7000_Series_Agitated_Brands_Selection__c.split(';');
                                if(agitatedSelectionList.size() > INT_ONE) {
                                    acc.addError(Label.OnlyOneAgitatedError);
                                }
                            }
                            //validations based on zero static/two agitated
                        } else if(acc.FS_X7000_Series_Brands_Option_Selections__c == Label.NoStatic2Agitated){
                            if(!String.isBlank(acc.FS_7000_Series_Agitated_Brands_Selection__c)) {
                                agitatedSelectionList = acc.FS_7000_Series_Agitated_Brands_Selection__c.split(';');
                                if(agitatedSelectionList.size() <= INT_ONE) {
                                    acc.addError(Label.TwoAgitatedError);
                                }else{
                                    if(agitatedSelectionList.size() == INT_TWO){
                                        if(!(acc.FS_7000_Series_Agitated_Brands_Selection__c.contains(Label.Agitated_Brand_2)
                                             && acc.FS_7000_Series_Agitated_Brands_Selection__c.contains(Label.Agitated_Brand_1))){
                                                 acc.addError('Please Select Only ' + Label.Agitated_Brand_1 + ' and ' + Label.Agitated_Brand_2 + ' Together in Agitated Brands');
                                             }
                                    }else{
                                        acc.addError(Label.OnlyTwoAgitatedError);
                                    }
                                }
                            } else {
                                acc.addError(Label.TwoAgitatedError);
                            }
                            if(!String.isBlank(acc.FS_7000_Series_Statics_Brands_Selection__c)) {
                                acc.addError(Label.DeselectStatic);
                            }
                        }
                    }else{
                        if(!String.isBlank(acc.FS_7000_Series_Agitated_Brands_Selection__c)){
                            acc.addError(Label.DeselectAgitated);
                        }
                        if(!String.isBlank(acc.FS_7000_Series_Statics_Brands_Selection__c)){
                            acc.addError(Label.DeselectStatic);
                        }
                    }
                }
            }
        }
    }
    /** @Description - This method is executed before insert operation is performed. The fields which are empty will be updated with the old values. 
* @param - Trigger context variables(Trigger.oldMap,Trigger.newMap,Trigger.new,Trigger.isUpdate) and Map<Id, Sobject> sobjectsToUpdate
* @Return - void
*/
    public static void setEmptyFieldsWithOldValues(final Map<Id,Account> oldMap,final  Map<Id,Account> newMap,final  List<Account> newList,final  Boolean isUpdate,final  Map<Id, SObject> sObjectsToUpdate) {
        validateHQForBrands(newList, isUpdate);//calling validateHQForBrands function for criterian check
        //Populate the old values for Account fields if new values are blank
        for(Account acc : (List<Account>) newList) {
            if(acc.FS_Market_ID__c != null && acc.FS_Market_ID__c != ''){
                acc.FS_Revenue_Center__c = FSRevenueCenterUtil.lookupRevenueCenter(acc.FS_Market_ID__c);
            }
            if(oldMap.containskey(acc.id)){
                Account oldacc = oldMap.get(acc.id);
                if(!String.isBlank(oldacc.FS_CS_Sub_Trade_Channel__c) && String.isBlank(acc.FS_CS_Sub_Trade_Channel__c)) {
                    acc.FS_CS_Sub_Trade_Channel__c = oldacc.FS_CS_Sub_Trade_Channel__c;
                }
                if(!String.isBlank(oldacc.FS_CS_Bill_To_Address__c) && String.isBlank(acc.FS_CS_Bill_To_Address__c)) {
                    acc.FS_CS_Bill_To_Address__c = oldacc.FS_CS_Bill_To_Address__c;
                }           
                if(!String.isBlank(oldacc.FS_CS_Bill_To_City__c) && String.isBlank(acc.FS_CS_Bill_To_City__c)) {
                    acc.FS_CS_Bill_To_City__c = oldacc.FS_CS_Bill_To_City__c;
                }
                if(!String.isBlank(oldacc.FS_CS_State__c) && String.isBlank(acc.FS_CS_State__c)) {
                    acc.FS_CS_State__c = oldacc.FS_CS_State__c;
                }
                if(!String.isBlank(oldacc.FS_CS_Bill_To_Zip__c) && String.isBlank(acc.FS_CS_Bill_To_Zip__c)) {
                    acc.FS_CS_Bill_To_Zip__c = oldacc.FS_CS_Bill_To_Zip__c;
                }
                if(!String.isBlank(oldacc.FS_CS_All_Ftn_Removed__c) && String.isBlank(acc.FS_CS_All_Ftn_Removed__c)) {
                    acc.FS_CS_All_Ftn_Removed__c = oldacc.FS_CS_All_Ftn_Removed__c;
                }
                if(!String.isBlank(oldacc.Invoice_Customer__c) && String.isBlank(acc.Invoice_Customer__c)) {
                    acc.Invoice_Customer__c = oldacc.Invoice_Customer__c;
                }
                if( (acc.RecordTypeId==recTypeHQ || acc.RecordTypeId==recTypeOutlet)) {
                    if(!String.isBlank(acc.Cokesmart_Payment_Method__c) && !String.isBlank(oldacc.Invoice_Customer__c) && !String.isBlank(acc.Invoice_Customer__c) 
                       && oldacc.Invoice_Customer__c.equalsIgnoreCase('Yes') && acc.Invoice_Customer__c.equalsIgnoreCase('No')
                       && acc.Cokesmart_Payment_Method__c.equalsIgnoreCase('Payment Term')) {
                           acc.Cokesmart_Payment_Method__c = '';
                       }  
                    if(!String.isBlank(acc.FS_Payment_Method__c) && !String.isBlank(oldacc.FS_Payment_Type__c) && !String.isBlank(acc.FS_Payment_Type__c) 
                       && oldacc.FS_Payment_Type__c.equalsIgnoreCase('Yes') && acc.FS_Payment_Type__c.equalsIgnoreCase('No')
                       && acc.FS_Payment_Method__c.equalsIgnoreCase('Payment Term')) {
                           acc.FS_Payment_Method__c = '';
                       }  
                }
                if(!String.isBlank(oldacc.FS_VMS_Customer__c) && String.isBlank(acc.FS_VMS_Customer__c)) {
                    acc.FS_VMS_Customer__c = oldacc.FS_VMS_Customer__c;
                }
            }
            
        }
        //calling below method to validates whether Payment type is modified and if its modified then updates account with new values
        FSAccountUpdation.updatePaymentTypeField(oldMap, newList, sObjectsToUpdate);
    }  
}