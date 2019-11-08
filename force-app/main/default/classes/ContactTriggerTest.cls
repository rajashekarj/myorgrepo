@isTest
public class ContactTriggerTest {
    private static testmethod void testCreateContact(){
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Admin' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Service Escalation Community' LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id AND isActive=true LIMIT 1];
        User user;
        Account testAccount;
        System.runAs(admin) {
            testAccount = new Account();
            testAccount.Name='Freestyle Customer Service Escalation' ;
            insert testAccount;
            
            Contact objContact = new Contact(LastName ='testCon',AccountId = testAccount.Id);
            insert objContact;
            
            
            user = new User();
            user.ProfileID = profile_1.id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = 'test@appirio.com';   
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            
            user.ContactId = objContact.Id;
            insert user;
        }
        Test.startTest();
        System.runAs(user){
            Contact cont = new Contact();
            cont.FirstName='Test';
            cont.LastName='Test';
            cont.Accountid= testAccount.id;
            cont.Email='test12@test.com';
            insert cont;
        }
        Test.stopTest();

    }
}