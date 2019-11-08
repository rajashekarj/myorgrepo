/***************************************************************************
 Name         : ShippingFormTriggerHandler
 Created By   : Deepti Maheshwari
 Description  : Handler class of ShippingFormTrigger
 Created Date : May 15, 2015
****************************************************************************/

public Class ShippingFormTriggerHandler{
    
    public static void beforeUpdate(){
       /* Map<Id, Shipping_Form__c> oldMap = (Map<Id, Shipping_Form__c>)Trigger.oldMap;
        Map<Id,Shipping_Form__c> shippingFormMap = new Map<Id, Shipping_Form__c>([SELECT id, FS_Status__c, 
                                            (SELECT id FROM Outlet_Dispensers__r) FROM Shipping_Form__c WHERE 
                                            id in :Trigger.newMap.keyset()]);
        //AggregateResult[] resLst = [Select Count(Outlet_Dispenser__c) from Shipping_Form__c where id in : Trigger.newMap.keyset()];
       for(Shipping_Form__c  shippingForm : (List<Shipping_Form__c>)Trigger.new){    //6/23-JD:commented out due to defect 1194
            if(shippingForm.FS_Status__c != oldMap.get(shippingForm.id).FS_Status__c){
                if(shippingForm.FS_Status__c == 'Ready for Pre-Book'){
                    Integer size = shippingFormMap.get(shippingForm.id).Outlet_Dispensers__r.size();
                    if(size == 0){
                        system.debug('Adding Error');
                        shippingForm.addError('Please add dispensers before Submitting');
                    }
                }
            }
        } */
        List<Shipping_Form__c> shippingFormList = (List<Shipping_Form__c>)Trigger.new;
        Set<Id> ownerIds = new Set<Id>();
        for(Shipping_Form__c form : shippingFormList){
        	if(!ownerIds.contains(form.OwnerId))
        	ownerIds.add(form.OwnerId);
        }
        system.debug('owner ids' + ownerIds);
    	Map<Id,User> userDetails = new Map<Id,User>([SELECT IC_Code__c FROM User where ID in : ownerIds]);
    	if(userDetails != null && userDetails.size() > 0){
	    	for(Shipping_Form__c form : shippingFormList){    
	    		system.debug('userDetails:' + userDetails.get(form.OwnerId));		
	    		form.IC_Code__c = userDetails.get(form.OwnerId).IC_Code__c;
	    	}
    	}
    }
    
    public static void beforeInsert(){
    	List<Shipping_Form__c> shippingFormList = (List<Shipping_Form__c>)Trigger.new;
    	List<User> userDetails = [SELECT IC_Code__c FROM User where ID =: UserInfo.getUserId()];
    	for(Shipping_Form__c form : shippingFormList){
    		form.IC_Code__c = userDetails.get(0).IC_Code__c;
    	}
    }
    
    public static void afterUpdate(){
    	Map<Id,Shipping_Form__c> oldMap  = (Map<Id,Shipping_Form__c>)Trigger.oldMap;
    	Set<ID> shippingFormUpdates = new Set<ID>(); 
    	Map<String, List<Shipping_Form__c>> icCodeMap = new Map<String, List<Shipping_Form__c>>();
    	List<Shipping_Form__c> shippingFormList;
    	List<Shipping_Form__Share> shippingFormSharingList = new List<Shipping_Form__Share>();
    	for(Shipping_Form__c shippingForm : (List<Shipping_Form__c>)Trigger.new){
    		if(shippingForm.IC_Code__c != null && 
    		oldMap.get(shippingForm.id).IC_Code__c != shippingForm.IC_Code__c){
    			shippingFormUpdates.add(shippingForm.id);
    			List<String> icCodeShippingFormList = shippingForm.IC_Code__c.split(';');
	            for(String code : icCodeShippingFormList){
	                if(icCodeMap.containsKey(code)){
	                    shippingFormList = icCodeMap.get(code);
	                    shippingFormList.add(shippingForm);
	                    icCodeMap.put(code, shippingFormList);
	                }else{
	                    shippingFormList = new List<Shipping_Form__c>();
	                    shippingFormList.add(shippingForm);
	                    icCodeMap.put(code, shippingFormList);
	                }
	            }
    		}
    	}
    	List<Shipping_Form__Share> shippingFormShareList = [SELECT id FROM Shipping_Form__Share WHERE parentId in : shippingFormUpdates];
    	if(shippingFormShareList != null && shippingFormShareList.size() > 0){
    		List<Database.DeleteResult> dr = Database.delete(shippingFormShareList, false);
    	}
    	String slist = '';
        if(icCodeMap.size() > 0){
	        for (String s: icCodeMap.keyset()) {
	            slist += '\'' + s + '\',';
	        }
        }
        system.debug('sList : ' + sList);
        if(slist.length() > 0){
	        slist = slist.substring (0,slist.length() -1);
	        String squery = 'SELECT Id, IC_Code__c from User WHERE IC_Code__c includes (' +  slist + ')';
	        system.debug('squery : ' + squery);
	        List<User> userList = Database.query(squery);
	        Map<String, List<User>> icCodeUserMap = new Map<String, List<User>>();
	        for(User usr : userList){
	            List<String> icCodeList = usr.IC_Code__c.split(';');
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
	        
	        Shipping_Form__Share shippingFormSharingRec;
	        for(String icCode : icCodeMap.keySet()){
	          if(!icCodeUserMap.isEmpty()){
	            for(User user : icCodeUserMap.get(icCode)){
	                for(Shipping_Form__c form : icCodeMap.get(icCode)){
	                    shippingFormSharingRec = new Shipping_Form__Share();
	                    shippingFormSharingRec.ParentID = form.id;
	                    shippingFormSharingRec.UserOrGroupId = user.id;
	                    shippingFormSharingRec.AccessLevel = 'Edit';
	                    shippingFormSharingList.add(shippingFormSharingRec);
	                }
	            }
	          }
	        }
        }
        system.debug('shippingFormSharingList size : ' + shippingFormSharingList.size());
        if(shippingFormSharingList.size() > 0){
        	List<Database.SaveResult> sr = Database.insert(shippingFormSharingList,false);
        }
    }
    public static void afterInsert(){
        Map<String, List<Shipping_Form__c>> icCodeMap = new Map<String, List<Shipping_Form__c>>();
        //List<Shipping_Form__c> shippingFormICCodeList = [SELECT id, IC_Code__c FROM Shipping_Form__c WHERE id in :Trigger.newMap.keyset()];
        List<Shipping_Form__c> shippingFormList;
        List<Shipping_Form__Share> shippingFormSharingList = new List<Shipping_Form__Share>();
        for(Shipping_Form__c shippingForm : (List<Shipping_Form__c>) Trigger.newMap.values()){
        	if(shippingForm.IC_Code__c != null){
	            List<String> icCodeShippingFormList = shippingForm.IC_Code__c.split(';');
	            for(String code : icCodeShippingFormList){
	                if(icCodeMap.containsKey(code)){
	                    shippingFormList = icCodeMap.get(code);
	                    shippingFormList.add(shippingForm);
	                    icCodeMap.put(code, shippingFormList);
	                }else{
	                    shippingFormList = new List<Shipping_Form__c>();
	                    shippingFormList.add(shippingForm);
	                    icCodeMap.put(code, shippingFormList);
	                }
	            }
	        }else{
	        	shippingForm.addError(FSConstants.noICCodeMsg);
	        	return;
	        }
        }
        String slist = '';
        if(icCodeMap.size() > 0){
	        for (String s: icCodeMap.keyset()) {
	            slist += '\'' + s + '\',';
	        }
        }
        system.debug('sList : ' + sList);
        if(slist.length() > 0){
	        slist = slist.substring (0,slist.length() -1);
	        String squery = 'SELECT Id, IC_Code__c from User WHERE IC_Code__c includes (' +  slist + ')';
	        system.debug('squery : ' + squery);
	        List<User> userList = Database.query(squery);
	        Map<String, List<User>> icCodeUserMap = new Map<String, List<User>>();
	        for(User usr : userList){
	            List<String> icCodeList = usr.IC_Code__c.split(';');
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
	        
	        Shipping_Form__Share shippingFormSharingRec;
	        for(String icCode : icCodeMap.keySet()){
	          if(!icCodeUserMap.isEmpty()){
	            for(User user : icCodeUserMap.get(icCode)){
	                for(Shipping_Form__c form : icCodeMap.get(icCode)){
	                    shippingFormSharingRec = new Shipping_Form__Share();
	                    shippingFormSharingRec.ParentID = form.id;
	                    shippingFormSharingRec.UserOrGroupId = user.id;
	                    shippingFormSharingRec.AccessLevel = 'Edit';
	                    shippingFormSharingList.add(shippingFormSharingRec);
	                }
	            }
	          }
	        }
        }
        system.debug('shippingFormSharingList size : ' + shippingFormSharingList.size());
        if(shippingFormSharingList.size() > 0){
        	List<Database.SaveResult> sr = Database.insert(shippingFormSharingList,false);
        }
        
    }
}