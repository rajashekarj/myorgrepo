Global class FS_ShippingForm_ManufacturerController {
    @AuraEnabled
    Public static String SendforPreBook(String id){
        String returnStr = '';
        Shipping_Form__c SF = [select id, FS_PO_Number__c, FS_Status__c from Shipping_Form__c where id=:id];
        if(SF.FS_PO_Number__c == null || SF.FS_PO_Number__c == ''){
            returnStr = 'Please Enter PO Number before sending for Pre-Book';
        }else{
            try{
                SF.FS_Status__c = 'Ready for Pre-Book';
                update SF;
                returnStr = 'Success';
            }Catch(Exception e){
                returnStr = e.getMessage();
            }
        }
        Return returnStr;
    }
    
    @AuraEnabled
    WebService static String Notify_Coordinator(String id,Boolean IsnotTestClass) {
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
            if(IsnotTestClass){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );// Dummy email send
            }
            Database.rollback(sp);
            
            //Send Actual email        
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();        
            emailToSend.setToAddresses(mail.getToAddresses());        
            emailToSend.setPlainTextBody(mail.getPlainTextBody());        
            emailToSend.setHTMLBody(mail.getHTMLBody());        
            emailToSend.setSubject(mail.getSubject());
            if(IsnotTestClass){
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