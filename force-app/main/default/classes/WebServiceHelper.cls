global class WebServiceHelper{
    
    Webservice static String reAssignDispenser(String id){
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = SchemaMap.get('FS_Outlet_Dispenser__c').getDescribe().fields.getMap();
        String csv = '';      
        List<FS_Outlet_Dispenser__c> dispenserListToUpsert = new List<FS_Outlet_Dispenser__c>();  
        for(Schema.SObjectField sfield : fieldMap.Values()){
            csv = csv + ',' + sField;            
        }        
        String queryStr = 'SELECT ' + csv.replaceFirst(',', '') + ' FROM FS_Outlet_Dispenser__c WHERE Id = \'' + ID + '\'';         
        List<FS_Outlet_Dispenser__c> dispenser = Database.query(queryStr);
        if(!dispenser.get(0).Re_Manufactured__c){
            return 'Error';
        }
        FS_Outlet_Dispenser__c newdisp = dispenser.get(0).clone(false,true,false,false);
        newDisp.Removed_Returned_Date__c = null;
        dispenser.get(0).FS_Status__c = 'Assigned to Outlet';
        //dispenser.get(0).WarehouseName = null;
        dispenserListToUpsert.add(newDisp);
        dispenserListToUpsert.addAll(dispenser);
        upsert dispenserListToUpsert;
        return newDisp.id;
        
    }
    
    
    WebService static String shippingFormGenerationNotification(String id) {
        String returnStr = '';
        List<EmailTemplate> templateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Shipping_Form_Generation']; 
        //create a mail object to send a single email.
        Group grp = [SELECT id FROM Group WHERE Name = 'Shipping form Coordinator Group'];
        List<GroupMember> grpMember = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =: grp.id];        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        //set the email properties
        List<String> addresses = new List<String>();
        List<ID> userIDList = new List<ID>();
        for(GroupMember grpMem : grpMember){
            userIDList.add(grpMem.UserOrGroupId);
        }
        List<User> users = [Select Email,firstName,lastName from User WHERE id in :userIDList];
        for(User usr : users){
            addresses.add(usr.Email);            
        }
        addresses.add(UserInfo.getUserEmail());
        List<Contact> cntList = [select id, Email from Contact where email != null limit 1];
        mail.setToAddresses(addresses);        
        mail.setTemplateId(templateList.get(0).Id);
        mail.setTargetObjectId(cntList.get(0).id);
        mail.setWhatId(id);
        //send the email
        try{
	        Savepoint sp = Database.setSavepoint();
	        if(!Test.isRunningTest()){
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );// Dummy email send
	        }
	        Database.rollback(sp);
	        
	        //Send Actual email        
	        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();        
	        emailToSend.setToAddresses(mail.getToAddresses());        
	        emailToSend.setPlainTextBody(mail.getPlainTextBody());        
	        emailToSend.setHTMLBody(mail.getHTMLBody());        
	        emailToSend.setSubject(mail.getSubject());
	        if(!Test.isRunningTest()){
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailToSend} );	            
	        }
	        returnStr = 'Success';
        }Catch(Exception ex){
        	system.debug('Exception in notifying Coordinator');
        	returnStr = 'Error';
        }
        return returnStr;
       }
    }