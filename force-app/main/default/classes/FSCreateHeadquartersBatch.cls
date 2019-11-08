/*****************************************************************************************
*  Purpose : Batch class to create Headquaters
*  Author  : Sunil Gupta
*  Date    : November 14, 2013
from neel
 
 
 
 /******************************************************************************************************
Name         : FSCreateHeadquartersBatch
Created By   : Sunil Gupta
Created Date :November 14, 2013
Usage        :Batch class to create Headquaters

// 17-Oct-2016          Modified By: Srinivas Bolneni   Ref: OCR-2 : FR5 (Place Holder Job - Handling Try Catches)
// 19-Oct-2016          Modified By: Lavanya Valluru     Ref: OCR-2 : FR5 (Place Holder Job - Finish method Email Notification)
//  Added multiple try and catch blocks  after review by Srinivas Bolneni

//25-10-2017            Modified By Aman   Ref:Production Issue
Calling NMS method in the Btach itself

*******************************************************************************************/ 
global class FSCreateHeadquartersBatch implements Database.Batchable<sObject>{
  global String Query;
  global Id hqRecordId;
  global Id outletRecordId;
  global Id chainRecordId;  //OCRE FET 2.1 
  //declared below variables as global in OCR2
  global List<Id> selectedOutlets_HQIds_Type_4; 
  global Set<String> newChainIds;
  global Set<String> newHQIds;
  //global List<Account> allOutlets;
  global List<Account> selectedHQs_Type_4;
  /****************************************************************************
  //Intialize the batch
  /***************************************************************************/
  public FSCreateHeadquartersBatch (){
    // HeadQuaters RecordType Id.
    Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
    Schema.RecordTypeInfo rtByName =  rtMapByName.get('FS Headquarters');
    hqRecordId = rtByName.getRecordTypeId();
    
    Schema.RecordTypeInfo rtByName2 =  rtMapByName.get('FS Outlet');
    outletRecordId = rtByName2.getRecordTypeId();
    
    Schema.RecordTypeInfo rtByName3 =  rtMapByName.get('FS Chain'); //OCRE FET 2.1 
    chainRecordId= rtByName3.getRecordTypeId();
  } 
  
  /****************************************************************************
  //Start the batch
  /***************************************************************************/
  global Database.QueryLocator start(Database.BatchableContext bc) {

    if (Label.TO_INCLUDE_ALL_OUTLETS_FOR_PLACEHOLDER_CHAIN_HQ != null && Label.TO_INCLUDE_ALL_OUTLETS_FOR_PLACEHOLDER_CHAIN_HQ.equalsIgnoreCase('true')) {
      query = 'SELECT Id, Name, FS_ACN__c, FS_SAP_ID__c, FS_Chain_ACN__c, FS_HQ_ACN__c, FS_Market_ID__c, FS_Headquarters__c,'+
        'FS_Headquarters__r.CCR_ACN_RecordType_Id__c, FS_Chain__r.CCR_ACN_RecordType_Id__c,'+
        'FS_Payment_Type__c, FS_Payment_Method__c, Invoice_Customer__c, Cokesmart_Payment_Method__c,'+
        'FS_Headquarters__r.Name, FS_Headquarters__r.FS_ACN__c, FS_Headquarters__r.FS_SAP_ID__c, FS_Headquarters__r.FS_Market_ID__c,'+
        'FS_Headquarters__r.FS_Payment_Type__c, FS_Headquarters__r.Invoice_Customer__c,'+
        'FS_Chain__c, FS_Chain__r.Name, FS_Chain__r.FS_ACN__c, FS_Chain__r.FS_SAP_ID__c, FS_Chain__r.FS_Market_ID__c,'+
        'ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity FROM Account WHERE RecordTypeId = \'' + outletRecordId + '\'  '
         + ' AND CCR_KO_Record_Type__c = 55 '
         + ' AND ShippingCountry = \'US\' '
         + ' AND (FS_Headquarters__c = null OR FS_Chain__c = null)';
    } else {
      query = 'SELECT Id,SELECT Id, Name, FS_ACN__c, FS_SAP_ID__c, FS_Chain_ACN__c, FS_HQ_ACN__c, FS_Market_ID__c, FS_Headquarters__c,'+
        'FS_Headquarters__r.CCR_ACN_RecordType_Id__c, FS_Chain__r.CCR_ACN_RecordType_Id__c,'+
        'FS_Payment_Type__c, FS_Payment_Method__c, Invoice_Customer__c, Cokesmart_Payment_Method__c,'+
        'FS_Headquarters__r.Name, FS_Headquarters__r.FS_ACN__c, FS_Headquarters__r.FS_SAP_ID__c, FS_Headquarters__r.FS_Market_ID__c,'+
        'FS_Headquarters__r.FS_Payment_Type__c, FS_Headquarters__r.Invoice_Customer__c,'+
        'FS_Chain__c, FS_Chain__r.Name, FS_Chain__r.FS_ACN__c, FS_Chain__r.FS_SAP_ID__c, FS_Chain__r.FS_Market_ID__c,'+
        'ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity FROM Account WHERE RecordTypeId = \'' + outletRecordId + '\'  '
         + ' AND CreatedDate = LAST_N_DAYS:7 '
         + ' AND CCR_KO_Record_Type__c = 55 '
         + ' AND ShippingCountry = \'US\' '
         + ' AND (FS_Headquarters__c = null OR FS_Chain__c = null)';
    }
    if(system.Test.isRunningTest()){
      query += ' LIMIT 100';
    }
    system.debug('@@@Query' + query);
    return Database.getQueryLocator(query);
  }
  
  /****************************************************************************
  // Execute Batch
  /***************************************************************************/
  global void execute(Database.BatchableContext bc, List < sObject > lstAccount) {
    //added try and catch blocks in OCR2
    /*try {
      allOutlets = [SELECT Id, Name, FS_ACN__c, FS_SAP_ID__c, FS_Chain_ACN__c, FS_HQ_ACN__c, FS_Market_ID__c, FS_Headquarters__c,
        FS_Headquarters__r.CCR_ACN_RecordType_Id__c, FS_Chain__r.CCR_ACN_RecordType_Id__c,
        FS_Payment_Type__c, FS_Payment_Method__c, Invoice_Customer__c, Cokesmart_Payment_Method__c,
        FS_Headquarters__r.Name, FS_Headquarters__r.FS_ACN__c, FS_Headquarters__r.FS_SAP_ID__c, FS_Headquarters__r.FS_Market_ID__c,
        FS_Headquarters__r.FS_Payment_Type__c, FS_Headquarters__r.Invoice_Customer__c,
        FS_Chain__c, FS_Chain__r.Name, FS_Chain__r.FS_ACN__c, FS_Chain__r.FS_SAP_ID__c, FS_Chain__r.FS_Market_ID__c,
        ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity
        FROM Account
        WHERE Id IN: lstAccount AND CCR_KO_Record_Type__c = 55];
    } catch (Exception exp) {
      System.debug('##Exception occurred- ' + exp);
    }*/

    String Record_Type_Suffix = '-' + outletRecordId;
    String Record_Type_HQ_Suffix = '-' + hqRecordId;
    String Record_Type_Chain_Suffix = '-' + chainRecordId;
    Integer Record_Type_Literal = 15; // HQ Record Type Literal
    Integer Record_Type_Literal_Chain = 13; // Chain Record Type Literal
    Integer Record_Type_Literal_Outlet = 55; // Outlet Record Type Literal
    //system.debug('@@@allOutlets' + allOutlets);

    //Type 1 Outlets: FS_Chain_ACN__c == FS_HQ_ACN__c and both not NULL
    //Type 2 Outlets: FS_Chain_ACN__c = NOT NULL && FS_HQ_ACN__c = NULL
    //Type 3 Outlets: FS_Chain_ACN__c = NULL && FS_HQ_ACN__c = NULL
    //Type 4 Outlets: FS_Chain_ACN__c = NULL && FS_HQ_ACN__c not NULL

    //Filter all outlets and fill list of all 3 types..
    List < Account > selectedOutlets_Type_1 = new List < Account > ();
    List < Account > selectedOutlets_Type_2 = new List < Account > ();
    List < Account > selectedOutlets_Type_3 = new List < Account > ();
    List < Account > selectedOutlets_Type_4 = new List < Account > ();
    selectedOutlets_HQIds_Type_4 = new List < Id > ();

    for (Account acc: (List<Account>)lstAccount) {
      if (acc.FS_Chain_ACN__c != null && acc.FS_HQ_ACN__c == null) {
        selectedOutlets_Type_2.add(acc);
        System.debug('### type 2 ' + acc.name + ' , ' + acc.FS_Chain_ACN__c);
      } else if (acc.FS_Chain_ACN__c == null && acc.FS_HQ_ACN__c == null) {
        selectedOutlets_Type_3.add(acc);
        System.debug('### type 3 ' + acc.name + ' , ' + acc.FS_ACN__c);
      } else if (acc.FS_Chain_ACN__c == null && acc.FS_HQ_ACN__c != null) {
        selectedOutlets_Type_4.add(acc);
        selectedOutlets_HQIds_Type_4.add(acc.FS_Headquarters__c);
        System.debug('### type 4 ' + acc.name + ' , ' + acc.FS_HQ_ACN__c);
      }
    }
    //added try and catch blocks in OCR2
    try {
      selectedHQs_Type_4 = [SELECT Id, Name, FS_ACN__c, FS_SAP_ID__c, FS_Chain_ACN__c, FS_HQ_ACN__c, FS_Market_ID__c,
        FS_Payment_Type__c, FS_Payment_Method__c, Invoice_Customer__c, Cokesmart_Payment_Method__c,
        FS_Chain__r.CCR_ACN_RecordType_Id__c, FS_Chain__r.Name, FS_Chain__r.FS_ACN__c,
        FS_Chain__r.FS_SAP_ID__c, FS_Chain__r.FS_Market_ID__c,
        ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity
        FROM Account
        WHERE Id IN: selectedOutlets_HQIds_Type_4];
    } catch (Exception exp) {
      System.debug('##Exception occurred- ' + exp);
    }

    /*system.debug('@@@selectedOutlets_Type_2' + selectedOutlets_Type_2);
    system.debug('@@@selectedOutlets_Type_3' + selectedOutlets_Type_3);
    system.debug('@@@selectedOutlets_Type_4' + selectedOutlets_Type_4);
    system.debug('@@@selectedHQs_Type_4' + selectedHQs_Type_4);*/

    //Type 2: Consider only Unique pair
    Map < String, Account > mapUniqueOutlets_Type_2 = new Map < String, Account > ();
    for (Account acc: selectedOutlets_Type_2) {
      mapUniqueOutlets_Type_2.put(acc.FS_ACN__c, acc);
    }
    system.debug('@@@mapUniqueOutlets_Type_2' + mapUniqueOutlets_Type_2);

    // Type 3: Consider only Unique pair
    Map < String, Account > mapUniqueOutlets_Type_3 = new Map < String, Account > ();
    for (Account acc: selectedOutlets_Type_3) {
      mapUniqueOutlets_Type_3.put(acc.FS_ACN__c, acc);

    }
    system.debug('@@@mapUniqueOutlets_Type_3' + mapUniqueOutlets_Type_3);

    // Type 4: Consider only Unique pair
    Map < String, Account > mapUniqueOutlets_Type_4 = new Map < String, Account > ();
    Map < String, Account > mapUniqueOutlets_HQs_Type_4 = new Map < String,  Account > ();
    Map < String, Account > mapOutlet = new Map < String, Account > ();
    for (Account acc: selectedOutlets_Type_4) {
      mapUniqueOutlets_Type_4.put(acc.FS_Headquarters__r.CCR_ACN_RecordType_Id__c, acc);

    }
    system.debug('@@@mapUniqueOutlets_Type_4' + mapUniqueOutlets_Type_4);

    //Prepare list of HQ to create
    List < Account > lstHeadQuaters = new List < Account > ();
    String trimmed_acn; //Added in OCR2
    //Prepare list of Chains to create
    List < Account > lstChains = new List < Account > ();
    newChainIds = new Set < String > ();
    newHQIds = new Set < String > ();

        // For Type 2
        if(mapUniqueOutlets_Type_2.size()>0) //added in OCR2 by srini
        for(Account acc :mapUniqueOutlets_Type_2.values()){
           trimmed_acn= acc.FS_ACN__c;
          if(!String.isBlank(acc.FS_ACN__c) && acc.FS_ACN__c.length() > 9){
            trimmed_acn = acc.FS_ACN__c.substring(acc.FS_ACN__c.length() - 9, acc.FS_ACN__c.length());
          }
            
          Account newAcc = new Account();
          newAcc.recordTypeId = hqRecordId;
          newAcc.FS_Chain__c = acc.FS_Chain__c;
          newAcc.FS_Market_ID__c = acc.FS_Market_ID__c;
          newAcc.Name = acc.Name + 'PH';
          newAcc.FS_ACN__c = acc.FS_ACN__c + 'PH';
          newAcc.CCR_ACN_RecordType_Id__c = trimmed_acn + 'PH' + Record_Type_HQ_Suffix;
          newAcc.CCR_KO_Record_Type__c = Record_Type_Literal_Outlet;
           
          if(acc.FS_SAP_ID__c != null)
            newAcc.FS_SAP_ID__c = acc.FS_SAP_ID__c + 'PH';
          else
            newAcc.FS_SAP_ID__c = 'PH';
          
          //Ashish Sharma 26th September : Changes for task T-322028
          //Start
          newAcc.ShippingCountry = acc.ShippingCountry;
          newAcc.ShippingCity = acc.ShippingCity;
          newAcc.ShippingState = acc.ShippingState;
          newAcc.ShippingStreet = acc.ShippingStreet;
          newAcc.ShippingPostalCode = acc.ShippingPostalCode;
          //End
          
          lstHeadQuaters.add(newAcc);
          newHQIds.add(newAcc.CCR_ACN_RecordType_Id__c);
        }
        
        // For Type 3 Chain = null and HQ = null
        if(mapUniqueOutlets_Type_3.size()>0) //added in OCR2 by srini
        for(Account acc :mapUniqueOutlets_Type_3.values()){
          trimmed_acn = acc.FS_ACN__c;
          if(!String.isBlank(acc.FS_ACN__c) && acc.FS_ACN__c.length() > 9){
            trimmed_acn = acc.FS_ACN__c.substring(acc.FS_ACN__c.length() - 9, acc.FS_ACN__c.length());
          }
          
          Account newAcc = new Account();
          newAcc.recordTypeId = hqRecordId;
          newAcc.Name = acc.Name + 'PH';
          newAcc.FS_Market_ID__c = acc.FS_Market_ID__c;
          newAcc.FS_ACN__c = acc.FS_ACN__c + 'PH';
          newAcc.CCR_ACN_RecordType_Id__c = trimmed_acn + 'PH' + Record_Type_HQ_Suffix;
          newAcc.CCR_KO_Record_Type__c = Record_Type_Literal_Outlet;
          newAcc.FS_Payment_Type__c=acc.FS_Payment_Type__c;
          newAcc.FS_Payment_Method__c=acc.FS_Payment_Method__c;
          newAcc.Invoice_Customer__c=acc.Invoice_Customer__c;
          newAcc.Cokesmart_Payment_Method__c=acc.Cokesmart_Payment_Method__c; 
          if(acc.FS_SAP_ID__c != null && acc.FS_SAP_ID__c != ''){
            newAcc.FS_SAP_ID__c = acc.FS_SAP_ID__c + 'PH';
          }
          else{
            newAcc.FS_SAP_ID__c = 'PH';
          }
          
          //Ashish Sharma 26th September : Chnages for task T-322028
          //Start
          newAcc.ShippingCountry = acc.ShippingCountry;
          newAcc.ShippingCity = acc.ShippingCity;
          newAcc.ShippingState = acc.ShippingState;
          newAcc.ShippingStreet = acc.ShippingStreet;
          newAcc.ShippingPostalCode = acc.ShippingPostalCode;
          //End
          
          lstHeadQuaters.add(newAcc);
          newHQIds.add(newAcc.CCR_ACN_RecordType_Id__c);
          
          //Chain creation Set up--OCRE FET 2.1 
          Account chainAcc = new Account();
          chainAcc.recordTypeId = chainRecordId;
          chainAcc.Name = acc.Name + 'CH';
          chainAcc.FS_Market_ID__c = acc.FS_Market_ID__c;
          chainAcc.FS_ACN__c = acc.FS_ACN__c + 'CH';
          chainAcc.CCR_ACN_RecordType_Id__c = trimmed_acn + 'CH' + Record_Type_Chain_Suffix;
          chainAcc.CCR_KO_Record_Type__c = Record_Type_Literal_Outlet;
          chainAcc.FS_Payment_Type__c=acc.FS_Payment_Type__c;
          chainAcc.Invoice_Customer__c=acc.Invoice_Customer__c;
          if(acc.FS_SAP_ID__c != null && acc.FS_SAP_ID__c != ''){
            chainAcc.FS_SAP_ID__c = acc.FS_SAP_ID__c + 'CH';
          }
          else{
            chainAcc.FS_SAP_ID__c = 'CH';
          }
          //Start
          chainAcc.ShippingCountry = acc.ShippingCountry;
          chainAcc.ShippingCity = acc.ShippingCity;
          chainAcc.ShippingState = acc.ShippingState;
          chainAcc.ShippingStreet = acc.ShippingStreet;
          chainAcc.ShippingPostalCode = acc.ShippingPostalCode;
          //End
          
          lstChains.add(chainAcc);
          newChainIds.add(chainAcc.CCR_ACN_RecordType_Id__c);
        }
        system.debug('@@@accList' + lstHeadQuaters);
        system.debug('@@@accList Chain' + lstChains);
        
        // For Type 4 Chain = null AND HQ != null  
        if(mapUniqueOutlets_Type_4.size()>0) //added in OCR2 by srini       
        for(Account acc :mapUniqueOutlets_Type_4.values()){
          trimmed_acn = acc.FS_HQ_ACN__c;
          if(!String.isBlank(acc.FS_HQ_ACN__c) && acc.FS_HQ_ACN__c.length() > 9){
            trimmed_acn = acc.FS_HQ_ACN__c.substring(acc.FS_HQ_ACN__c.length() - 9, acc.FS_HQ_ACN__c.length());
          }
          
          //Chain creation Set up--OCRE FET 2.1 
          Account chainAcc = new Account();
          chainAcc.recordTypeId = chainRecordId;
          if(acc.FS_Headquarters__r.Name != null) {
            if(acc.FS_Headquarters__r.Name.endsWithIgnoreCase('PH')) {
                chainAcc.Name = acc.FS_Headquarters__r.Name.removeEndIgnoreCase('PH') + 'CH';
            } else {
                chainAcc.Name = acc.FS_Headquarters__r.Name + 'CH';
            }
          } else {
             chainAcc.Name = 'CH';
          }
          chainAcc.FS_Market_ID__c = acc.FS_Headquarters__r.FS_Market_ID__c;
          if(acc.FS_Headquarters__r.FS_ACN__c != null) {
            if(acc.FS_Headquarters__r.FS_ACN__c.endsWithIgnoreCase('PH')) {
                chainAcc.FS_ACN__c = acc.FS_Headquarters__r.FS_ACN__c.removeEndIgnoreCase('PH') + 'CH';
            } else {
                chainAcc.FS_ACN__c = acc.FS_Headquarters__r.FS_ACN__c + 'CH';
            }
          } else {
             chainAcc.FS_ACN__c = 'CH';
          }
          chainAcc.CCR_ACN_RecordType_Id__c = trimmed_acn + 'CH' + Record_Type_Chain_Suffix;
          chainAcc.CCR_KO_Record_Type__c = Record_Type_Literal;
          chainAcc.FS_Payment_Type__c=acc.FS_Headquarters__r.FS_Payment_Type__c;
          chainAcc.Invoice_Customer__c=acc.FS_Headquarters__r.Invoice_Customer__c;
          if(acc.FS_Headquarters__r.FS_SAP_ID__c != null) {
            if(acc.FS_Headquarters__r.FS_SAP_ID__c.endsWithIgnoreCase('PH')) {
                chainAcc.FS_SAP_ID__c = acc.FS_Headquarters__r.FS_SAP_ID__c.removeEndIgnoreCase('PH') + 'CH';
            } else {
                chainAcc.FS_SAP_ID__c = acc.FS_Headquarters__r.FS_SAP_ID__c + 'CH';
            }
          } else {
             chainAcc.FS_SAP_ID__c = 'CH';
          }
          //Start
          chainAcc.ShippingCountry = acc.ShippingCountry;
          chainAcc.ShippingCity = acc.ShippingCity;
          chainAcc.ShippingState = acc.ShippingState;
          chainAcc.ShippingStreet = acc.ShippingStreet;
          chainAcc.ShippingPostalCode = acc.ShippingPostalCode;
          //End
          
          lstChains.add(chainAcc);
          newChainIds.add(chainAcc.CCR_ACN_RecordType_Id__c);
        }
         system.debug('@@@accList Chain type 4 outlet' + lstChains);
         
        // Avoid inserting records with duplicate ACN
        //Set<Id> newChainIds = new Set<Id>();
        
         Database.UpsertResult[] resultsChain = Database.upsert(lstChains, Account.Fields.CCR_ACN_RecordType_Id__c, false);
                //to handle errors for database upsert OCR2 
                if(resultsChain.size()>0)
                for(Database.UpsertResult theResult:resultsChain) {
                    if(theResult.isSuccess())
                    continue; // next item
                    List<Database.Error> errors = theResult.getErrors();
                    System.debug('##Exception occurred- '+errors);
                }
        
        // Avoid inserting records with duplicate ACN
        //Set<Id> newHQIds = new Set<Id>();
        
        Database.UpsertResult[] results = Database.upsert(lstHeadQuaters, Account.Fields.CCR_ACN_RecordType_Id__c, false);       
        //to handle errors for database upsert OCR2
        if(results.size()>0) 
        for(Database.UpsertResult theResult:results) {
                    if(theResult.isSuccess())
                    continue; // next item
                    List<Database.Error> errors = theResult.getErrors();
                    System.debug('##Exception occurred- '+errors);
                }
        String temp_acn;
         //Query again to get new formula fields  //OCRE FET 2.1 
          //added try and catch blocks in OCR2
           try{
             lstChains= [SELECT Id, Name, FS_ACN__c, FS_SAP_ID__c, FS_Chain_ACN__c, FS_HQ_ACN__c, FS_Market_ID__c,
                                    FS_Chain__r.Name, FS_Chain__r.FS_ACN__c, FS_Chain__r.FS_SAP_ID__c, FS_Chain__r.FS_Market_ID__c 
                                    FROM Account 
                                    WHERE CCR_ACN_RecordType_Id__c IN :newChainIds];
             }catch(Exception exp){
                 system.debug('Exception updating Outlet-HQ occured'+exp);           
                }
       
       System.debug('#FSCreateHQBatch#lstChains- '+lstChains);
                                    
        //Update outlets with newly created Chain__c field
        Map<Id, Account> mapUpdateOutletsHQsForChain = new Map<Id, Account>();
     
        for(Account newAccount :lstChains){
          for(Account type3_Outlet :selectedOutlets_Type_3){
            if(type3_Outlet.Name + 'CH' == newAccount.Name){
              type3_Outlet.FS_Chain__c= newAccount.Id;
              mapUpdateOutletsHQsForChain.put(type3_Outlet.Id, type3_Outlet);
            }
          }
          
          // Type 4- Associate Placeholder Chain to Outlet  
          for(Account type4_Outlet :selectedOutlets_Type_4){
            
            temp_acn = type4_Outlet.FS_HQ_ACN__c;
            if(!String.isBlank(temp_acn)) {
                if(temp_acn.endsWithIgnoreCase('PH')) {
                    temp_acn = temp_acn.removeEndIgnoreCase('PH') + 'CH';
                }
                else {
                    temp_acn = temp_acn + 'CH';
                }
            } else {
                temp_acn = 'CH';
            }
            
            if(temp_acn == newAccount.FS_ACN__c){
             //added try and catch blocks in OCR2
              try {
                  type4_Outlet.FS_Chain__c= newAccount.Id;
                  //update type4_Outlet;
                  mapUpdateOutletsHQsForChain.put(type4_Outlet.Id, type4_Outlet);
              }
               catch(Exception exp) {System.debug('##Exception updating Outlet-Chain occurred- '+exp);}
            }
          }
          
          // Type 4- Associate Placeholder Chain to HeadQuaters 
          for(Account type4_HQ :selectedHQs_Type_4){
            temp_acn = type4_HQ.FS_ACN__c;
           if(!String.isBlank(temp_acn)) {
                if(temp_acn.endsWithIgnoreCase('PH')) {
                    temp_acn = temp_acn.removeEndIgnoreCase('PH') + 'CH';
                }
                else {
                    temp_acn = temp_acn + 'CH';
                }
            } else {
                temp_acn = 'CH';
            }
            
            if(temp_acn == newAccount.FS_ACN__c){
              type4_HQ.FS_Chain__c= newAccount.Id;
              mapUpdateOutletsHQsForChain.put(type4_HQ.Id, type4_HQ);
            }
          }
        }                            
        
        system.debug('@@@mapUpdateOutlets for Chains' + mapUpdateOutletsHQsForChain);
        if(mapUpdateOutletsHQsForChain != null) {
        //added try catch block in OCR2 by srini
         try{
            update mapUpdateOutletsHQsForChain.values();   
            }catch(Exception exp){system.debug('Exception updating Outlet-HQ occured'+exp);}            
        }
        
             
        //Query again to get new formula fields
         //added try and catch blocks in OCR2
        try{ 
        lstHeadQuaters = [SELECT Id, Name, FS_ACN__c, FS_SAP_ID__c, FS_Chain_ACN__c, FS_HQ_ACN__c, FS_Market_ID__c,FS_Chain__c,
                                    FS_Chain__r.Name, FS_Chain__r.FS_ACN__c, FS_Chain__r.FS_SAP_ID__c, FS_Chain__r.FS_Market_ID__c 
                                    FROM Account 
                                    WHERE CCR_ACN_RecordType_Id__c IN :newHQIds];
            }catch(Exception exp){ 
            System.debug('##Exception updating Outlet-HQ occurred- '+exp);}
        System.debug('@@@' + lstHeadQuaters);
                                    
        Map<Id, Account> mapHQChainAssociation = new Map<Id, Account>();
        for(Account newAccount :lstHeadQuaters){
           mapHQChainAssociation.put(newAccount.Id,newAccount);
        }
        
        System.debug('@@@ Map' + mapHQChainAssociation); 
        
        //Update outlets with newly created Heaquarters__c field
        Map<Id, Account> mapUpdateOutlets = new Map<Id, Account>();
        
        // Type 2- Update newly created Placeholder HQs with Chain
        Map<Id, Account> mapUpdatePlaceholderHQs = new Map<Id, Account>();
        
        
        for(Account newAccount :lstHeadQuaters){
                 
          // Associate Outlet to Placeholder HQ 
          // Associate Placeholder HQ to Chain 
          for(Account type2_Outlet :selectedOutlets_Type_2){
            String hq_acn = type2_Outlet.FS_ACN__c + 'PH';
            System.debug('JF: hq_acn: '+ hq_acn + ' ,hq AC: ' + newAccount.FS_ACN__c);
            if(hq_acn == newAccount.FS_ACN__c) {
              type2_Outlet.FS_Headquarters__c = newAccount.Id;
              newAccount.FS_Chain__c = type2_Outlet.FS_Chain__c;
              mapUpdatePlaceholderHQs.put(newAccount.Id, newAccount);
              mapUpdateOutlets.put(type2_Outlet.Id, type2_Outlet);
              
              /*try {
                  update type2_Outlet;
                  mapUpdateOutlets.put(type2_Outlet.Id, type2_Outlet);
              } 
              catch(Exception exp) {System.debug('##Exception updating Outlet-HQ occurred- '+exp);}*/
            }
          }
      
          for(Account type3_Outlet :selectedOutlets_Type_3){
            if(type3_Outlet.FS_ACN__c + 'PH' == newAccount.FS_ACN__c) {
              type3_Outlet.FS_Headquarters__c = newAccount.Id;
              mapUpdateOutlets.put(type3_Outlet.Id, type3_Outlet);
              if(mapHQChainAssociation!= null && mapHQChainAssociation.containsKey(newAccount.Id)) {
                mapHQChainAssociation.get(newAccount.Id).FS_Chain__c=type3_Outlet.FS_Chain__c;  
              }
              
            }
          }
          for(Account type4_Outlet :selectedOutlets_Type_4){
            if(mapHQChainAssociation != null && mapHQChainAssociation.containsKey(type4_Outlet.FS_Headquarters__c)) {
                mapHQChainAssociation.get(type4_Outlet.FS_Headquarters__c).FS_Chain__c=type4_Outlet.FS_Chain__c;
            }
          }
        }
        
                                
        
                                
        
        system.debug('@@@mapUpdatePlaceholderHQs' + mapUpdatePlaceholderHQs);
        if(mapUpdatePlaceholderHQs != null) {
            //update mapUpdatePlaceholderHQs.values();    
            dmlProcessor(mapUpdatePlaceholderHQs.values());
        }
        
        
        system.debug('@@@mapHQChainAssociation' + mapHQChainAssociation);
        if(mapHQChainAssociation != null) {
            //update mapHQChainAssociation.values();
            dmlProcessor(mapHQChainAssociation.values());           
        } 
          
       //uncommented out over-ached try and catch block in OCR2
    /*} catch(Exception exp) {
        System.debug('##Exception occurred- '+exp);
        System.debug('##Exception occurred- '+exp.getLineNumber());
    }*/
         //change 
        String integrationUserID = FSConstants.getIntegrationUserID();
        String OD_reg_Status=Label.OD_Register_Status;
        system.debug('@@@mapUpdateOutlets' + mapUpdateOutlets);
        if(mapUpdateOutlets != null) {
            //update mapUpdateOutlets.values();   
            dmlProcessor(mapUpdateOutlets.values());
        }
                                final Map<Id, String> mapDispenserIdstrDispenserAttrChange = new Map<Id, String>();                                
      							final Id recordId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType,Label.INT_OD_RECORD_TYPE);
                                final Map<Id,FS_Outlet_Dispenser__c> dispenserMap = new Map<Id, FS_Outlet_Dispenser__c>
                    ([SELECT id,name,FS_Status__c,RecordTypeId,Send_Create_Request__c,LastModifiedById FROM FS_Outlet_Dispenser__c WHERE FS_Outlet__r.id in : mapUpdateOutlets.keyset()]);
            for(Id idOutletDispenser : dispenserMap.keyset()) {
                if(recordId !=dispenserMap.get(idOutletDispenser).RecordTypeId){
                    mapDispenserIdstrDispenserAttrChange.put(idOutletDispenser, 'Dispenser');
                }
                //else if(recordId ==dispenserMap.get(idOutletDispenser).RecordTypeId){
                else if(recordId ==dispenserMap.get(idOutletDispenser).RecordTypeId && ((dispenserMap.get(idOutletDispenser).LastModifiedById != integrationUserId) && 
                        (OD_reg_Status.contains(dispenserMap.get(idOutletDispenser).FS_Status__c)||dispenserMap.get(idOutletDispenser).FS_Status__c==Label.Assigned_to_Outlet))){
                        mapDispenserIdstrDispenserAttrChange.put(idOutletDispenser, 'Dispenser');
                    }
                //}
                                                }
                                
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
                if(!splittedMap.isEmpty()){
                    for(Map<Object,Object> splitMapRecord: splittedMap){
                        final Map<Id, String> mapDispenserIdstrDispenserAttrChangeOriginal = new Map<Id, String>();
                        for(Object obj : splitMapRecord.keySet()){
                            mapDispenserIdstrDispenserAttrChangeOriginal.put((Id)obj,(String)splitMapRecord.get(obj));
                        }
                        Set<Id> odSet=new Set<Id>();
                        odSet=mapDispenserIdstrDispenserAttrChangeOriginal.keySet();
                        //to call aw
                        System.Queueable job = new DeferredHandler(mapDispenserIdstrDispenserAttrChangeOriginal);
                        System.enqueueJob(job);
                        //TestAWfromBatch.callFuturefromBatch(mapDispenserIdstrDispenserAttrChangeOriginal);
                        //FSFETNMSConnector.updateMasterAssetData(odSet,mapDispenserIdstrDispenserAttrChangeOriginal); 
                    }
                }
               /**Record Splitter module End******************************/
  }
  
  //Method to do DMLs
   public void dmlProcessor(List<Sobject> sobjectList){
      List<Database.SaveResult> updateResults= Database.update(sobjectList, false);
      for (Database.SaveResult sr : updateResults) {
           if(!sr.isSuccess()) {
               System.debug('These records failed to get updated ' + sr.getId());
               System.debug('Reason for failure' + sr.getErrors());
           }
      }
   }
  /****************************************************************************
  //finish the batch 
  /***************************************************************************/ 
  global void finish(Database.BatchableContext BC) {
  
   //Implemented by OCR2 to send Email after running Batch to find out Error List
    // Use this object(AsyncApexJob) to query Apex batch jobs in your organization.
    // Query the AsyncApexJob object to retrieve the current job's information.
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
       TotalJobItems, CreatedBy.Email
       FROM AsyncApexJob WHERE Id =
       :BC.getJobId()];
       
    // Send an email to the Apex job's submitter notifying of job completion.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {a.CreatedBy.Email};
    mail.setToAddresses(toAddresses);
    mail.setSubject('Apex Sharing Recalculation ' + a.Status);
    mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
     ' batches with '+ a.NumberOfErrors + ' failures.');
     //Sending the mail in case of failure updates
     if( a.NumberOfErrors>0){
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
       
  }
}