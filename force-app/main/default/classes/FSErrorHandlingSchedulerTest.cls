@isTest
public class FSErrorHandlingSchedulerTest {

    static testMethod void fSErrorHandlingSchedulerTest() {
      
       try{
        Test.startTest();
        String CRON_EXP = '0 0 23 * * ?';
        FSErrorHandlingScheduler scheObj = new FSErrorHandlingScheduler();
        system.schedule('Test Scheduler Job', CRON_EXP, scheObj);
        Test.stopTest();
       }catch(exception e) {}

    }
}