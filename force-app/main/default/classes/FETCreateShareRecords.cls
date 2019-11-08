public without sharing class FETCreateShareRecords {
    private static final String RECORD_TYPE_NAME_INTERNATIONAL = 'International';
    
    public static void createSharingRecordsForAccountBasedOnCountry(){
    /*
        system.debug('Entering create sharing records');
        List<User> userDetails = [SELECT Dispenser_Country__c, dispenser_read_edit__c,Ownership__c, Ownership_Type__c,  ProfileID FROM User Where id = :userinfo.getUserId()];
        Profile userProfile  = [SELECT Name FROM Profile WHERE Id =: userInfo.getProfileId()];
        String accessLevel = 'Read';
        String countryList = '';
        String accQuery = '';
        List<Account> outletAccList;
        String bottler = '';
        Account acc;
        Map<String, Account> countryBottlerAccMap = new Map<String, Account>();
        Set<String> countryBottlerKeyList = new Set<String>();
        List<Account> defaultAccountListToInsert = new List<Account>();
        String bottlerValue = '';
        String countryValue = '';
        String finalValue = '';
        
        Set<String> bottlerName = new Set<String>();
        Set<String> countryCodeSet = new Set<String>();
       // if(userProfile.Name == FSConstants.dispenserCoordinatorProfile || userProfile.Name == FSConstants.sedispenserCoordinatorProfile ||
        //   userProfile.Name == FSConstants.systemAdmin ||
      //     userProfile.Name == 'API User'){
      
         String fetProfiles = Label.FETProfiles;
         
         if(fetProfiles.contains(userProfile.Name)){
           
            for(FS_Outlet_Dispenser__c dispenser : (List<FS_Outlet_Dispenser__c>)Trigger.New){
                system.debug('Dispenser Info : ' +  dispenser.FS_Serial_Number2__c + ' , ' + dispenser.recordType.name + ' , ' + countryList + ' , ' + bottler);
                if(dispenser.recordTypeID == FSUtil.rtMapByNameForOD.get(RECORD_TYPE_NAME_INTERNATIONAL).getRecordTypeID()
                && dispenser.Is_DefaultOutlet__c){
                    
                    if(dispenser.Ownership__c != null){
                        bottlerValue = dispenser.Ownership__c;
                        if(!(bottlerName.contains(dispenser.Ownership__c)))
                        bottlerName.add(dispenser.Ownership__c);
                    }else{
                        bottlerValue = '';
                    }
                    if(dispenser.Country__c != null){
                        countryValue = dispenser.country__c;
                        if(!(countryCodeSet.contains(dispenser.Country__c))) {
                            countryCodeSet.add(dispenser.Country__c);
                            system.debug('#1 Adding ' + dispenser.Country__c);
                        }
                    }else{
                        countryValue = '';
                    }
                    if(countryValue != ''){
                        finalValue = countryValue + '#' + bottlerValue;                     
                        if(!countryBottlerKeyList.contains(finalValue))
                        countryBottlerKeyList.add(finalValue);
                    }
                    
                    if(countryCodeSet.size() > 0){
                        for(String countryCode : countryCodeSet){
                            countryList += '\'' + countryCode + '\' ,';
                        }
                    }else if (countryList == ''){
                        if(userDetails.get(0).Dispenser_Country__c != null){                    
                            for(String countryStr : userDetails.get(0).Dispenser_Country__c.split(';')){
                            system.debug('#2 Adding ' + countryStr );
                                countryList += '\'' + countryStr + '\',';   
                            }               
                        }
                    }
                    if(bottlerName.size() > 0){
                        for(String bottlerN : bottlerName){
                            bottler += '\'' + bottlerN + '\',';
                        }
                    }else if (bottler ==''){
                        if(userDetails.get(0).Ownership__c != null){
                            for(String ownershipStr : userDetails.get(0).Ownership__c.split(';')){
                                system.debug('#3 Adding ' + ownershipStr );
                                bottler += '\'' + ownershipStr + '\','; 
                            }
                        }
                    }
                    if(userDetails.get(0).Dispenser_Read_Edit__c != null){
                        accessLevel = userDetails.get(0).Dispenser_Read_Edit__c;
                    }
                                    
                }  
            } 
            accQuery = 'SELECT id, name,ownerId,shippingCountry, Bottler_Name__c FROM Account WHERE name = \'' + FSConstants.defaultOutletName + '\'';
            if(countryList.length() != 0){
                 countryList = countryList.substring (0,countryList.length() -1);
                 accQuery += ' AND shippingCountry in (' + countryList + ')';
            }  
            if(bottler.length() != 0){
                bottler = bottler.substring (0,bottler.length() -1);
                accQuery += ' AND Bottler_Name__c in (' + bottler + ')';
            }else{
                accQuery += ' AND Bottler_Name__c = null ';
            }
                                                
            system.debug('Account query : ' + accQuery);
        }
        if(accQuery.length() != 0){
            outletAccList = Database.Query(accQuery);           
            if(outletAccList == null || outletAccList.size() == 0){             
                if(countryCodeSet.size() > 0){
                    system.debug('I am here');
                    for(String str : countryBottlerKeyList){
                        acc = new Account();
                        acc.Name = FSConstants.defaultOutletName;
                        String[] shipperBottlerArr = str.split('#');
                        acc.shippingcountry = shipperBottlerArr.get(0);
                        if(shipperBottlerArr.size() > 1)
                        acc.Bottler_Name__c = str.split('#').get(1);
                        acc.shippingStreet = 'DefaultOutletStreet';
                        acc.ShippingCity = 'DefaultOutletCity';
                        acc.shippingPostalCode = '12345';
                        acc.FS_SAP_ID__c = '767886123';             
                        acc.RecordTypeId = FSUtil.rtMapByNameForAccount.get('FS Outlet').getRecordTypeId();
                        defaultAccountListToInsert.add(acc);
                        countryBottlerAccMap.put(str, acc);
                    }
                }else{
                    system.debug('I am there');
                    acc = new Account();
                    acc.Name = FSConstants.defaultOutletName;               
                    if(userDetails.get(0).Dispenser_Country__c != null)
                        acc.shippingcountry = userDetails.get(0).Dispenser_Country__c.split(';').get(0);
                    if(userDetails.get(0).Ownership_Type__c != null && userDetails.get(0).Ownership_Type__c == FSConstants.Bottler)
                        acc.Bottler_Name__c = userDetails.get(0).Ownership__c.split(';').get(0);
                    acc.shippingStreet = 'DefaultOutletStreet';
                    acc.ShippingCity = 'DefaultOutletCity';
                    acc.shippingPostalCode = '12345';
                    acc.FS_SAP_ID__c = '767886123';             
                    acc.RecordTypeId = FSUtil.rtMapByNameForAccount.get('FS Outlet').getRecordTypeId();
                    defaultAccountListToInsert.add(acc);
                }
                
            } else if(countryBottlerKeyList.size() > 0
            && outletAccList.size() < countryBottlerKeyList.size()){
                String shippingCountry = '';
                String bottlerNameIns = '';
                Boolean skipStatements;
                for(String str : countryBottlerKeyList){
                    skipStatements = false;
                    shippingCountry = str.split('#').get(0);
                    bottlerNameIns = str.split('#').get(1);
                    acc = new Account();                    
                    system.debug('Hello:' + str);
                    for(Account existingAcc : outletAccList){
                        if(existingAcc.shippingCountry == shippingCountry
                        && existingAcc.Bottler_Name__c == bottlerNameIns){
                            acc = existingAcc;
                            skipStatements = true;
                            break;
                        }
                    }
                    if(skipStatements){
                    system.debug('continuing..');
                    continue;
                    system.debug('continues..');
                    }
                    system.debug('continued..');
                    acc.Name = FSConstants.defaultOutletName;                       
                    acc.shippingStreet = 'DefaultOutletStreet';
                    acc.ShippingCity = 'DefaultOutletCity';
                    acc.shippingPostalCode = '12345';
                    acc.FS_SAP_ID__c = '767886123';     
                    acc.shippingCountry = shippingCountry;
                    acc.Bottler_Name__c = bottlerNameIns;       
                    acc.RecordTypeId = FSUtil.rtMapByNameForAccount.get('FS Outlet').getRecordTypeId();
                    system.debug('Adding to insert list : ' + acc);
                    defaultAccountListToInsert.add(acc);
                    countryBottlerAccMap.put(str, acc); 
                }       
            }
            if(defaultAccountListToInsert.size() > 0){
                insert defaultAccountListToInsert;
            }
        }
        
        for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Trigger.New){
            if(FSUtil.rtMapByNameForOD.get('International').getRecordTypeID() == dispenserObj.RecordTypeId
                && dispenserObj.Is_DefaultOutlet__c){               
                if(countryBottlerKeyList.size() > 0){
                    system.debug('Insertion through tool');
                    if(outletAccList  != null && outletAccList.size() > 0){
                        for(Account existingAccounts : outletAccList){
                            if(existingAccounts.shippingCountry == dispenserObj.country__c
                            && existingAccounts.Bottler_Name__c == dispenserObj.Ownership__c){
                                dispenserObj.FS_Outlet__c = existingAccounts.id;
                                break;                              
                            }
                        }
                    }
                    if(defaultAccountListToInsert.size() > 0){
                        system.debug('I have nine owl');
                        if(dispenserObj.Ownership__c != null){
                            bottlerValue = dispenserObj.Ownership__c;
                        }else{
                            bottlerValue = '';
                        }
                        if(dispenserObj.country__c != null){
                            countryValue = dispenserObj.country__c;
                        }else{
                            countryValue = '';
                        }
                        finalValue = countryValue + '#' + bottlerValue;
                        if(countryBottlerAccMap.containsKey(finalValue))
                        dispenserObj.FS_Outlet__c = countryBottlerAccMap.get(finalValue).id;
                    }
                }else{
                    system.debug('I have three owl');
                    if(outletAccList == null || outletAccList.size() == 0){
                        dispenserObj.FS_Outlet__c = defaultAccountListToInsert.get(0).id;
                    }else{
                        system.debug('I have two owl');
                        dispenserObj.FS_Outlet__c = outletAccList.get(0).id;
                    }
                }
                /*if(outletAccList != null && outletAccList.size() > 0){
                    dispenserObj.FS_Outlet__c = outletAccList.get(0).id;
                    for(Account existingAccounts : outletAccList){
                        
                    }
                }else if(defaultAccountListToInsert.size() > 1){
                    system.debug('I am nowhere');
                    if(dispenserObj.Ownership__c != null){
                        bottlerValue = dispenserObj.Ownership__c;
                    }else{
                        bottlerValue = '';
                    }
                    if(dispenserObj.country__c != null){
                        countryValue = dispenserObj.country__c;
                    }else{
                        countryValue = '';
                    }
                    finalValue = countryValue + '-' + bottlerValue;
                    dispenserObj.FS_Outlet__c = countryBottlerAccMap.get(finalValue).id;
                }else{
                    system.debug('I am no one');
                    dispenserObj.FS_Outlet__c = defaultAccountListToInsert.get(0).id;
                }
            }
        }
        
        system.debug('Exiting createSharingRecordsForAccountBasedOnCountry');
        */
    }
    
    
    
    public static void updateAccessForBusinessUnit(){
    /*
        system.debug('Entering update access for disp');
         String countryList = '';
         List<String> accIDList = new List<String>();
         List<User> userList;
         String ownershipList= '';
         String queryString;
         Map<Id, Account> accountMap;
         Boolean createShare = false;
         for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>) Trigger.new){
            if(od.recordTypeID == FSUtil.rtMapByNameForOD.get(RECORD_TYPE_NAME_INTERNATIONAL).getRecordTypeID()){
                //system.debug('Shipping country : ' + od.FS_Outlet__c.shippingCountry);
                /*if(od.FS_Outlet__r.shippingCountry != null){
                    countryList += '\'' + od.FS_Outlet__r.shippingCountry + '\',';   
                }           
                system.debug('Outlet id : ' + od.FS_Outlet__c);
                accIDList.add(od.FS_Outlet__c);
            }
         }
         if(!accIDList.isEmpty()){
            
             accountMap = new Map<Id,Account>([Select shippingCountry,FS_Headquarters__c,FS_Headquarters__r.OwnerID, FS_Chain__c,FS_Chain__r.OwnerID, Bottler_Name__c,Id,OwnerId, Name FROM Account where id in :accIDList]);
             system.debug('accountMap 273'+accountMap);
             for(Account acc : accountMap.values()){
                system.debug('accountMap 275'+acc.FS_Headquarters__c);
                    if(acc.shippingCountry != null){
                        countryList += '\'' + acc.shippingCountry + '\',';
                    }                   
             } 
         }
         if(countryList.length() != 0){
             countryList = countryList.substring (0,countryList.length() -1);
             queryString = 'SELECT id,name,Dispenser_Country__c,Ownership_Type__c, Ownership__c,Dispenser_Read_Edit__c FROM User WHERE Ownership_Type__c = \'' + FSConstants.BusinessUnit + '\''; 
             queryString += ' AND IsActive = true AND Dispenser_Country__c includes (' +  countryList + ')';
             userList = Database.query(queryString);
         }
         List<AccountShare> accountShareList = new List<AccountShare>();
         String accessLevel = 'Read';
         if(userList != null){
            for(User usr : userList){
                
                if(usr.Dispenser_Read_Edit__c != null){
                     accessLevel = usr.Dispenser_Read_Edit__c;
                }
                for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>) Trigger.new){
                    if(od.recordTypeID == FSUtil.rtMapByNameForOD.get(RECORD_TYPE_NAME_INTERNATIONAL).getRecordTypeID()
                        && usr.Id != accountMap.get(od.FS_Outlet__c).OwnerId){
                        if(od.Ownership_Type__c == FSConstants.BusinessUnit
                        && usr.dispenser_country__c.contains(accountMap.get(od.FS_Outlet__c).shippingCountry)){
                            AccountShare accountShare = new AccountShare();
                            accountShare.AccountId = od.FS_Outlet__c;
                            accountShare.UserOrGroupId = usr.Id;
                            accountShare.AccountAccessLevel = accessLevel;
                            accountShare.OpportunityAccessLevel = 'Read';
                            accountShareList.add(accountShare);
                            createShare = true;
                        }
                    }
                    if(createShare){
                         system.debug('Outlet HQ 308' + accountMap.get(od.FS_Outlet__c).FS_Headquarters__c);
                        if(accountMap.get(od.FS_Outlet__c).FS_Headquarters__c != null
                        && accountMap.get(od.FS_Outlet__c).FS_Headquarters__r.OwnerId != usr.Id){                           
                            AccountShare accountShare = new AccountShare();
                            accountShare.AccountId = accountMap.get(od.FS_Outlet__c).FS_Headquarters__c;
                            accountShare.UserOrGroupId = usr.Id;
                            accountShare.AccountAccessLevel = accessLevel;
                            accountShare.OpportunityAccessLevel = 'Read';
                            accountShareList.add(accountShare);
                        }
                        if(accountMap.get(od.FS_Outlet__c).FS_Chain__c != null
                        && accountMap.get(od.FS_Outlet__c).FS_Chain__r.OwnerId != usr.Id){
                            AccountShare accountShare = new AccountShare();
                            accountShare.AccountId = accountMap.get(od.FS_Outlet__c).FS_Chain__c;
                            accountShare.UserOrGroupId = usr.Id;
                            accountShare.AccountAccessLevel = accessLevel;
                            accountShare.OpportunityAccessLevel = 'Read';
                            accountShareList.add(accountShare);
                        }
                    }
                    createShare = false;
                 }
            }
        }
        if(accountShareList.size() > 0) {
            List<Database.Saveresult> sr = Database.insert(accountShareList, false);
            system.debug('SaveResult : ' + sr);
        }
        system.debug('Entering update access for disp');
        */
    }
    
    public static void updateAccessForBottler(){
    /*
     system.debug('Entering update access for business owner');
     String countryList = '';
     List<String> accIDList = new List<String>();
     Map<String, String> accountOwnerIDMap = new Map<String, String>();
     List<User> userList;
     String queryString;
     List<AccountShare> accountShareList = new List<AccountShare>();
     String accessLevel = 'Read';
     String ownerShip = '';
     Boolean createShare = false;
     Map<Id, Account> accountMap;
     for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>) Trigger.new){
        if(od.recordTypeID == FSUtil.rtMapByNameForOD.get(RECORD_TYPE_NAME_INTERNATIONAL).getRecordTypeID()){            
            accIDList.add(od.FS_Outlet__c);
        }
     }
     if(!accIDList.isEmpty()){
         accountMap = new Map<Id,Account>([SELECT ownerId,id,FS_Headquarters__c,FS_Headquarters__r.OwnerID, FS_Chain__c,FS_Chain__r.OwnerID, 
                        shippingCountry,Bottler_Name__c,Name from Account WHERE Id in :accIdList]);
         for(Account acc : accountMap.values()){
             if(acc.shippingCountry != null)
             countryList += '\'' + acc.shippingCountry + '\',';
             if(acc.Bottler_Name__c != null)
             ownerShip += '\'' + acc.Bottler_Name__c + '\',';
         } 
     }
     if(countryList.length() != 0){
         countryList = countryList.substring (0,countryList.length() -1);         
         queryString = 'SELECT id,name,Dispenser_Read_Edit__c,Dispenser_Country__c, Ownership_Type__c, Ownership__c FROM User WHERE Ownership_Type__c = \'' + FSConstants.Bottler + '\'';
         queryString += ' AND IsActive = true AND Dispenser_Country__c includes (' + countryList + ')';
         
     }
     system.debug('Query string : ' + queryString);
     if(ownership.length() != 0){
        ownerShip = ownerShip.substring(0, ownerShip.length() - 1);
        queryString += ' AND Ownership__c includes (' +  ownerShip + ')';
     }
     system.debug('Query string : ' + queryString);
     if(queryString != null && queryString.length() != 0 && countryList.length() != 0){
        system.debug('Query String ::' + queryString);
        userList = Database.query(queryString);
     }
     if(userList != null){
         for(User usr : userList){
            
            if(usr.Dispenser_Read_Edit__c != null){
                 accessLevel = usr.Dispenser_Read_Edit__c;
            }
            for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>) Trigger.new){            
                if(od.recordTypeID == FSUtil.rtMapByNameForOD.get(RECORD_TYPE_NAME_INTERNATIONAL).getRecordTypeID() 
                && usr.Id != accountMap.get(od.FS_Outlet__c).OwnerID
                && usr.Ownership__c != null && accountMap.get(od.FS_Outlet__c).Bottler_Name__c != null
                && usr.Ownership__c.contains(accountMap.get(od.FS_Outlet__c).Bottler_Name__c)
                && usr.Ownership_Type__c.equals(od.Ownership_Type__c)
                && usr.Dispenser_Country__c.contains(accountMap.get(od.FS_Outlet__c).shippingCountry)){                   
                    AccountShare accountShare = new AccountShare();
                    accountShare.AccountId = od.FS_Outlet__c;
                    accountShare.UserOrGroupId = usr.Id;
                    accountShare.AccountAccessLevel = accessLevel;
                    accountShare.OpportunityAccessLevel = 'Read';
                    accountShareList.add(accountShare);    
                    createShare = true;                
                }
                if(createShare){
                        system.debug('Outlet HQ 404' + accountMap.get(od.FS_Outlet__c).FS_Headquarters__c);
                        if(accountMap.get(od.FS_Outlet__c).FS_Headquarters__c != null
                        && accountMap.get(od.FS_Outlet__c).FS_Headquarters__r.OwnerId != usr.Id){                           
                            AccountShare accountShare = new AccountShare();
                            accountShare.AccountId = accountMap.get(od.FS_Outlet__c).FS_Headquarters__c;
                            accountShare.UserOrGroupId = usr.Id;
                            accountShare.AccountAccessLevel = accessLevel;
                            accountShare.OpportunityAccessLevel = 'Read';
                            accountShareList.add(accountShare);
                        }
                        if(accountMap.get(od.FS_Outlet__c).FS_Chain__c != null
                        && accountMap.get(od.FS_Outlet__c).FS_Chain__r.OwnerId != usr.Id){
                            AccountShare accountShare = new AccountShare();
                            accountShare.AccountId = accountMap.get(od.FS_Outlet__c).FS_Chain__c;
                            accountShare.UserOrGroupId = usr.Id;
                            accountShare.AccountAccessLevel = accessLevel;
                            accountShare.OpportunityAccessLevel = 'Read';
                            accountShareList.add(accountShare);
                        }
                    }
                    createShare = false;
             }
        }
    }
    if(accountShareList.size() > 0) {
        List<Database.Saveresult> sr = Database.insert(accountShareList, false);
        system.debug('SaveResult : ' + sr);
        Integer c = 0;
        for(Database.SaveResult res: sr){
            if(res.isSuccess()){                        
            }else{
                system.debug('res : ' + res.getErrors());
                system.debug(accountShareList.get(c));                      
            }
            c++;
        }
    }
    system.debug('Exiting update access for business owner');
    */
  }
  
 /* public static void setAccountSharingForOutletDispenser(List<FS_Outlet_Dispenser__c> newOutletDispensers) {
        List<AccountShare> accountShareList = new List<AccountShare>();
        String accessLevel = 'Read';
        System.debug('NEW OUTLET DISPENSER LIST IS : '+newOutletDispensers);
        Map<String, String> accountOwnerIDMap = new Map<String, String>();
        List<String> accIdList = new List<String>();
        for(FS_Outlet_Dispenser__c od : newOutletDispensers){
            if(FSUtil.rtMapByNameForOD.get('International').getRecordTypeId() == od.RecordTypeId)
            accIdList.add(od.FS_Outlet__c);
        }
        if(!accIdList.isEmpty()){
            List<Account> accList = [SELECT ownerId,id from Account WHERE Id in :accIdList];
            for(Account acc : accList){
                accountOwnerIDMap.put(acc.id, acc.ownerId);
            } 
        }
        for(User tempUser : [SELECT Dispenser_Read_Edit__c,Id,Ownership_Type__c, Ownership__c 
                                                 FROM User
                                                 WHERE IsActive = true AND Ownership_Type__c = :ccfc]) {
             //system.debug('User ID : ' + tempUser.Id);                                                 
             if(tempUser.Dispenser_Read_Edit__c != null){
                    accessLevel = tempUser.Dispenser_Read_Edit__c;
             }
             //System.debug('USER DispenserRole Is : '+tempUser.Dispenser_Role__c);
             //Iterate Over New Outlet Dispensers
             for(FS_Outlet_Dispenser__c outDisp : newOutletDispensers) {                    
                    //Put Check For Only International Outlet Dispenser Record Type
                    if(FSUtil.rtMapByNameForOD.get('International').getRecordTypeId() == outDisp.RecordTypeId 
                        && tempUser.id != accountOwnerIDMap.get(outDisp.FS_Outlet__c)
                        && outDisp.Ownership_Type__c == ccfc){
                       
                        System.debug('CREATING ACCOUNT SHARE FOR :'+outDisp);
                        //Create Account Share Record
                            AccountShare accountShare = new AccountShare();
                            accountShare.AccountId = outDisp.FS_Outlet__c;
                            accountShare.UserOrGroupId = tempUser.Id;
                            accountShare.AccountAccessLevel = accessLevel;
                            accountShare.OpportunityAccessLevel = 'Read';
                            accountShareList.add(accountShare);
                    }
             }
        }
    
        // Insert Account Share Records
        if(accountShareList.size() > 0) {
            Database.insert(accountShareList, false);
        }
    }*/
}