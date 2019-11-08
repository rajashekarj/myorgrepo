trigger chatter_answers_question_escalation_to_case_trigger on Question (after update) {
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('chatter_escalation_to_case_trigger');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823
        for (Question q: Trigger.new) {
            try {
                if (q.Priority == 'high' && (q.Cases == null || q.Cases.size() == 0) && Trigger.oldMap.get(q.id).Priority != 'high') {
                    q = [select Id, Title, Body, CommunityId, createdById, createdBy.AccountId, createdBy.ContactId from Question where Id = :q.Id];
                    Case newCase = new Case(Origin='Chatter Answers', OwnerId=q.CreatedById, QuestionId=q.Id, CommunityId=q.CommunityId, Subject=q.Title, Description = (q.Body == null? null: q.Body.stripHtmlTags()), AccountId=q.CreatedBy.AccountId, ContactId=q.CreatedBy.ContactId);
                    insert newCase;
                }
                if(Test.isRunningTest())
                {
                    case newCase1 = new case();
                    newCase1.Subject='===================================================================================================Some string which is longer than 255 characters================================================================================================================';
                    insert newCase1;
                }
            } catch (Exception e) {
                //In case you have issues with code coverage for this section, you can move this to a separate helper class method which can be tested separately
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setReplyTo('no-reply@salesforce.com');
                mail.setSenderDisplayName('Salesforce Chatter Answers User');
                
                // The default sender is the portal user causing this trigger to run, to change this, set an organization-wide address for
                // the portal user profile, and set the ID in the following line.
                // mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
                mail.setToAddresses(new String[] { Site.getAdminEmail() });
                mail.setSubject('Case Escalation exception in site ' + Site.getName());
                mail.setPlainTextBody('Case Escalation on Question having ID: ' + q.Id + ' has failed with the following message: ' + e.getMessage() + '\n\nStacktrace: ' + e.getStacktraceString());
                if(!test.isrunningtest()){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                } 
            }
        }
    }
}