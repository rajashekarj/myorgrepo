/********************************************************************************************************* 
Name         : FSEnterEditViewOnBoardingInfoTest
Created By   : Pallavi Sharma (Appiro)
Created Date : 18 - Sep - 2013
Usage        : Unit test coverage of FSEnterEditViewOnBoardingInfoController
***********************************************************************************************************/
@isTest 
private class FSEnterEditViewOnBoardingInfoTest {
    
    private static FS_Execution_Plan__c executionPlan;
    public static Account acc;
    
    //Create Test data
    private static void createTestData(){
        FSTestFactory.createTestDisableTriggerSetting();
        final Account accHeadQtr = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        acc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.Id, true);
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHeadQtr.Id, true);
        FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id, acc.Id, true);       
    }
    
    //Test Method   
    private static testMethod void  testUnit(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createTestData();
            Test.startTest();
            FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id, acc.Id, true);
            final Pagereference pgRef = Page.FSEnterEditView_OnBoarding_Info;
            Test.setCurrentPage(pgRef);
            
            //Initialize Page paramteres
            pgRef.getParameters().put('executionplanid', executionPlan.Id);
            
            final FSEnterEditViewOnBoardingInfoController onBoardingInfo = new FSEnterEditViewOnBoardingInfoController();
            onBoardingInfo.saveInstallation();
            onBoardingInfo.selectedFillDown='All';
            onBoardingInfo.fillDown();
            onBoardingInfo.selectedFillDown='Trainer';
            onBoardingInfo.fillDown();
            onBoardingInfo.selectedFillDown='OnboardingContact';
            onBoardingInfo.fillDown();
            onBoardingInfo.selectedFillDown='SecondaryContact';
            onBoardingInfo.fillDown();
            onBoardingInfo.selectedFillDown='StartTime';
            onBoardingInfo.fillDown();
            onBoardingInfo.selectedFillDown='OpenTime';
            onBoardingInfo.fillDown();
            onBoardingInfo.selectedFillDown='NoofDays';
            onBoardingInfo.fillDown();
            onBoardingInfo.selectedFillDown='Comments';
            onBoardingInfo.fillDown();
            
            Test.stopTest();
            system.assertNotEquals(NULL,onBoardingInfo.selectedFillDown);
        }
    }
    
    
    //Test Method for Cancel  
    private static testMethod void  testCancelMethod(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        
        system.runAs(adminUser){
            createTestData();
            Test.startTest();
            FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id, acc.Id, true);
            final Pagereference pgRef = Page.FSEnterEditView_OnBoarding_Info;
            Test.setCurrentPage(pgRef);
            
            //Initialize Page paramteres
            pgRef.getParameters().put('executionplanid', executionPlan.Id);
            
            final FSEnterEditViewOnBoardingInfoController onBoardingInfo = new FSEnterEditViewOnBoardingInfoController();
            
            //testing cancel method
            onBoardingInfo.cancel();
            System.assertEquals(onBoardingInfo.executionPlan, executionPlan.Id);            
            Test.stopTest();
            
        }
    }
}