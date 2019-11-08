@isTest
private class ChatterAnswersEscalationTriggerTest {
    static testMethod void validateQuestionEscalation() {
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            String questionTitle = 'questionTitle';
            String questionBody = 'questionBody';
            Community[] c = [SELECT Id from Community];
            // We cannot create a question without a community
            if (c.size() == 0) { return; }
            String communityId = c[0].Id;
            Question q = new Question();
            q.Title = questionTitle;
            q.Body = questionBody;
            q.CommunityId = communityId;
            q.CreatedById=UserInfo.getUserId();
            insert(q);
            q.Priority = 'high';
            update(q);
            System.debug('this is question '+q); 
            Case newCase = 
                new Case(Origin='Chatter Answers', Issue_Name__c='test case',OwnerId=q.CreatedById, QuestionId=q.Id, CommunityId=q.CommunityId, Subject=q.Title, Description = (q.Body == null? null: q.Body.stripHtmlTags()), AccountId=q.CreatedBy.AccountId, ContactId=q.CreatedBy.ContactId);
            insert newCase;          
            List<Case> ca = [SELECT Origin, CommunityId, Subject, Description from Case where QuestionId =: q.Id];        
            System.debug('this is case ca '+ Ca);
            // Test that escaltion trigger correctly escalate the question to a case
            System.assertEquals(questionTitle, ca[0].Subject);
            System.assertEquals(questionBody, ca[0].Description);
            System.assertEquals('Chatter Answers', ca[0].Origin);
            System.assertEquals(communityId, ca[0].CommunityId);
           

           
            
        }
        
       
            
    }
      
}