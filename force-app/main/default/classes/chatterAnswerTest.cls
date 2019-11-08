@isTest
public class chatterAnswerTest {
	@istest
    public static void insertAcc(){
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

    User usr= new User(
    Alias = 'standt',
    Email='standarduser@testorg.com',
    EmailEncodingKey='UTF-8',
    LastName='Testing',
    ProfileId = p.Id,
    LanguageLocaleKey='en_US',
    LocaleSidKey='en_US',
    TimeZoneSidKey='America/Los_Angeles',
    UserName='ser@testorg.com',
    isActive = true
	);
	insert usr;
        
        
        ChatterAnswers ca= new ChatterAnswers();
        ca.createAccount('firstname', 'lastname', usr.id);
    }
}