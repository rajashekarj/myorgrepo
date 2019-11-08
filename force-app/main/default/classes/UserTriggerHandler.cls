public without sharing class UserTriggerHandler {
    public static void afterInsert(){
        createShareRecordsForShippingForm(Trigger.newMap.keyset());
        updateAccessForDefaultOutletBasedOnCountry();
    }
	
	@future
	private static void createShareRecordsForShippingForm(Set<Id> userId){
		Map<String, List<Shipping_Form__c>> icCodeMap = new Map<String, List<Shipping_Form__c>>();
        List<User> userList;
        List<String> icCodeList;
        Map<String, List<User>> icCodeUserMap = new Map<String, List<User>>();
        List<Shipping_Form__Share> shippingFormSharingList = new List<Shipping_Form__Share>();
        //Creating a map of IC code and users having that IC code
        List<User> userListFromTrigger = [SELECT IC_Code__c,Id FROM User WHERE Id in :userId];
        for(User usr : userListFromTrigger){
        	if(usr.IC_Code__c != null){
	            icCodeList = usr.IC_Code__c.split(';');
	            for(String icCode : icCodeList){
	                if(icCodeUserMap.containsKey(icCode)){
	                    icCodeUserMap.get(icCode).add(usr);
	                }else{
	                    List<User> usrListTemp = new List<User>();  
	                    usrListTemp.add(usr);               
	                    icCodeUserMap.put(icCode, usrListTemp);
	                }
	            }
        	}
        }
        String slist = '';
        if(icCodeUserMap.size() > 0){
	        for (String s: icCodeUserMap.keyset()) {
	            slist += '\'' + s + '\',';
	        }
        }
        if(slist.length() > 0){
	        system.debug('sList : ' + sList);
	        slist = slist.substring (0,slist.length() -1);
	        String squery = 'SELECT Id, IC_Code__c from Shipping_Form__c WHERE IC_Code__c includes (' +  slist + ')';
	        system.debug('squery : ' + squery);
	        List<Shipping_Form__c> shippingFormList = Database.query(squery);       
	        for(Shipping_Form__c form : shippingFormList){
	        	if(form.IC_Code__c != null){
		            List<String> icCodeListTemp = form.IC_Code__c.split(';');
		            for(String icCode : icCodeListTemp){
		                if(icCodeMap.containsKey(icCode)){
		                    icCodeMap.get(icCode).add(form);
		                }else{
		                    List<Shipping_Form__c> shippingFormListTemp = new List<Shipping_Form__c>();  
		                    shippingFormListTemp.add(form);                 
		                    icCodeMap.put(icCode, shippingFormListTemp);
		                }
		            }
	        	}
	        }
	        
	        Shipping_Form__Share shippingFormSharingRec; 
	        for(String icCode : icCodeMap.keySet()){
	            if(!icCodeUserMap.isEmpty() && icCodeUserMap.containsKey(icCode)){
	                for(User user : icCodeUserMap.get(icCode)){
	                    for(Shipping_Form__c form : icCodeMap.get(icCode)){
	                        shippingFormSharingRec = new Shipping_Form__Share();
	                        shippingFormSharingRec.ParentID = form.id;
	                        shippingFormSharingRec.UserOrGroupId = user.id;
	                        shippingFormSharingRec.AccessLevel = 'Edit';
	                        system.debug('shippingFormSharingRec' + shippingFormSharingRec);
	                        shippingFormSharingList.add(shippingFormSharingRec);
	                    }
	                }
	            }
	        }
        }
        system.debug('shippingFormSharingList size : ' + shippingFormSharingList.size());  
        if(shippingFormSharingList.size() > 0){ 
        	List<Database.SaveResult> sr = Database.insert(shippingFormSharingList,false);
        	system.debug('Save Result : ' + sr);
        }
	}
	public static void afterUpdate(){
		updateShareRecordsForShippingForm();
		Map<Id, User> oldMap = (Map<Id,User>)Trigger.oldMap;
		Set<Id> userIDToUpdateSharing = new Set<Id>(); 
		for(User usr : (List<User>)Trigger.New){
			if((usr.Ownership__c != oldMap.get(usr.id).Ownership__c)
			|| (usr.Ownership_Type__c != oldMap.get(usr.Id).Ownership_Type__c)
			|| (usr.Dispenser_Country__c != oldMap.get(usr.id).dispenser_country__c))
			{
				if(!userIDToUpdateSharing.contains(usr.id)){
					userIDToUpdateSharing.add(usr.id);
				}
			}
		}
		List<AccountShare> accShare = [SELECT id FROM AccountShare WHERE userorGroupId in :userIDToUpdateSharing AND rowcause = 'Manual'];
		if(accShare != null && accShare.size() > 0){
			List<Database.DeleteResult> resList = Database.Delete(accShare, false);	
			system.debug('result list : ' + resList);	
		}
		updateAccessForDefaultOutletBasedOnCountry();
		
	}
	private static void updateShareRecordsForShippingForm(){
		Map<Id, User> oldMap = (Map<Id,User>)Trigger.oldMap;
		Set<Id> updateUsers = new Set<Id>();
		Map<String,String> ownerICCodeMap = new Map<String,String>(); 
		for(User usr : (List<User>)Trigger.New){
			if(usr.IC_Code__c != oldMap.get(usr.id).IC_Code__c){
				updateUsers.add(usr.id);
				ownerICCodeMap.put(usr.id, usr.IC_Code__c);
			}
		}
		system.debug('User list size : ' + updateUsers.size());
		if(updateUsers.size() > 0){
			List<Shipping_Form__Share> shippingFormShare = [SELECT id FROM Shipping_Form__Share WHERE UserOrGroupId in :updateUsers
															and RowCause = 'Manual'];
			if(shippingFormShare != null && shippingFormShare.size() > 0){
				List<Database.DeleteResult> resList = Database.delete(shippingFormShare, false);
				for(Database.DeleteResult res : resList){				
					if(!res.isSuccess()){
						system.debug('Errors in deleting : ' + res.getErrors());
					}
				}
			}
			List<Shipping_Form__c> shippingFormList = [SELECT Id, IC_Code__c,OwnerID FROM Shipping_Form__c WHERE OwnerId in :updateUsers];
			if(shippingFormList.size() > 0){
				for(Shipping_Form__c shippingform : shippingFormList){
					shippingForm.IC_Code__c = ownerICCodeMap.get(shippingForm.OwnerId);
				}
				system.debug('shippingFormList : ' + shippingFormList);
				update shippingFormList;
			}
			createShareRecordsForShippingForm(updateUsers);
		}
		
	}
	private static void updateAccessForDefaultOutletBasedOnCountry(){
		List<Account> accList;
		String accessLevel = 'Read';
		Set<String> countryList = new Set<String>();
		Set<String> bottlerName = new Set<String>();		
		for(User usr : (List<User>)Trigger.New){
			if(usr.Dispenser_Country__c != null){				
				for(String str : usr.Dispenser_Country__c.split(';')){
					if(!countryList.contains(str)){
						countryList.add(str);						
					}	
				}
			}		
			if(usr.Ownership__c != null){				
				for(String str : usr.Ownership__c.split(';')){
					if(!bottlerName.contains(str)){
						bottlerName.add(str);						
					}
				}
			}	
		}
	
		BatchToCreateShareRecords batchToCreateShare = new BatchToCreateShareRecords();
		if(countryList.size() > 0){						
			batchToCreateShare.countries = countryList;
		}
		
		if(bottlerName.size() != 0){							
			batchToCreateShare.bottlers = bottlerName;
		}
		
		batchToCreateShare.userIds = Trigger.newMap.keyset();
		if(countryList.size() > 0){
			Database.executeBatch(batchToCreateShare, 9000);
		}
		
	}
}