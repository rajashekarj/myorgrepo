global class FSLeadershipMail Implements Schedulable
    {
        global void execute(SchedulableContext sc)
        {
            sendEmailToLeaders();
        }

        public void sendEmailToLeaders(){
        
        //create list for custom setting
        List<FSLeadershipEMail_Recipient_List__c> leadershipMailUsr = new List<FSLeadershipEMail_Recipient_List__c>();
        User u =[Select Id,IsActive FROM User Where Name='FET Admin' AND IsActive=True];
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        Leadership_Mail__c cs = Leadership_Mail__c.getOrgDefaults();
        system.debug('@@@@' + cs);
        string[] toMail = new string[] {} ;
        String templateName = cs.Email_Template_Name__c;
        String theTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:templateName].Id;
        msg.setTemplateId(theTemplate);
        msg.setTargetObjectId(u.Id);
        //msg.setTreatTargetObjectAsRecipient(false);
        //add custom setting list to recipient
        leadershipMailUsr = FSLeadershipEMail_Recipient_List__c.getall().values();
        for(FSLeadershipEMail_Recipient_List__c recp : leadershipMailUsr){
            toMail.add(recp.FS_FSLeadershipEmail__c);
           
        }
        msg.setToAddresses(toMail);
        msg.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }
        
            
     
       
}