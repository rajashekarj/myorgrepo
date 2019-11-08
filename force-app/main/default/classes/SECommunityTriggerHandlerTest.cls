@IsTest
private class SECommunityTriggerHandlerTest {
        static testmethod void CustomerTest() 
   {
        Account testAccount = new Account();
        testAccount.Name = 'Freestyle Customer Service Escalation';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.Email = 'deepu156@gmail.com';
        testContact.LastName='deepuReddy';
        testContact.AccountId = testAccount.Id;
        insert testContact;
                
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // User user2 ;
    
                        
       system.runAs(thisUser)
       {
          UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
          system.debug('portalRole is ' + portalRole);
          
          Id p = [SELECT Id FROM Profile WHERE Name='Service Escalation Community Plus'].id;
          
           /* user2 = new User(
               contactid=testContact.id,
               ProfileId = p,
                PortalRole = 'Manager',
               Username = 'TestUserCheckOut@gmail.com',
               Alias = 'batman',
               Email='deepu156@gmail.com',
               EmailEncodingKey='UTF-8',
               Lastname='Pooled Org Admin',
               LanguageLocaleKey='en_US',
               LocaleSidKey='en_US',
               TimeZoneSidKey='America/Chicago'
           );
           insert user2;*/
          
       }
        
       system.runAs(thisUser)
       { 
           Contact testContact1 = new Contact();
            testContact1.Email = 'deepu156@gmail.com';
            testContact1.LastName='deepuReddy';
            testContact1.AccountId = testAccount.Id;
            insert testContact1;
            
            List<contact> conList=new List<contact>();
            conList.add(testContact1);
            Test.StartTest();
            SECommunityTriggerHandler.insertContacts(conList);
            SECommunityTriggerHandler.createCommUsers(conList);
            Test.StopTest();
       } 
   }
}