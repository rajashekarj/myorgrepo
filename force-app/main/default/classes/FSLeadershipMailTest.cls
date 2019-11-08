@isTest
public class FSLeadershipMailTest {
	public static testMethod void testschedule() {
		Leadership_Mail__C ledM = new Leadership_Mail__C();
     	ledM.Email_Template_Name__c='Leadership_Mail';
        insert ledM;
        Test.StartTest();
		FSLeadershipMail lm = new FSLeadershipMail();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, lm); 
        Test.stopTest(); 
    }
    
}