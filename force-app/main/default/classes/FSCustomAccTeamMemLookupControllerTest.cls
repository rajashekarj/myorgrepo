@isTest
public class FSCustomAccTeamMemLookupControllerTest {
	
	public static String backSlash='\'';
  private static testMethod void testPageLoadUnderHQ(){
    Test.StartTest();
      FSTestFactory.createTestDisableTriggerSetting();
        final List<Account> hqCustomerList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        
          final Account parentRecord=hqCustomerList[0];
          User userIDCOM;
          final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          System.runAs(sysAdmin){
            final Profile prof = FSTestFactory.getProfileId('FS COM_P');
            userIDCOM = FSTestFactory.createUser(prof.id);
          }
         final AccountTeamMember__c atm=new AccountTeamMember__c();
          atm.AccountId__c=parentRecord.id;
          atm.TeamMemberRole__c ='COM';
          atm.UserId__c =userIDCOM.id;
          Insert atm;
          //Add parameters to page URL
          final PageReference pageRef = Page.FSCIFSalesRepInfoCustLookup;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('accID', backSlash+parentRecord.Id+backSlash);
          ApexPages.currentPage().getParameters().put('fshq', '\'FS Headquarters\'');
          ApexPages.currentPage().getParameters().put('lksrch', 'user');
          ApexPages.currentPage().getParameters().put('sri', '\'COM\'');
          final FSCustomAccTeamMemLookupController controller = new FSCustomAccTeamMemLookupController();
          controller.search();
          final String formTag = controller.getFormTag();
          controller.getTextBox();
          Test.StopTest();
      
      System.assertEquals(formTag, null);
  }
    private static testMethod void testPageLoadUnderHQ1(){
    Test.StartTest();
      FSTestFactory.createTestDisableTriggerSetting();
        final List<Account> hqCustomerList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        
          final Account parentRecord= hqCustomerList[0];
          User userIDCOM;
          final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
          System.runAs(sysAdmin){
            final Profile prof = FSTestFactory.getProfileId('FS COM_P');
            userIDCOM = FSTestFactory.createUser(prof.id);
          }
         final AccountTeamMember__c atm=new AccountTeamMember__c();
          atm.AccountId__c=parentRecord.id;
          atm.TeamMemberRole__c ='COM';
          atm.UserId__c =userIDCOM.id;
          Insert atm;
          
          Contact cntct = FSTestUtil.createTestContact(parentRecord.id, 'contactName', false);
          cntct.phone='9874563210';
          cntct.email='test@testmail.com';
          insert cntct;
          
          //Add parameters to page URL
          final PageReference pageRef = Page.FSCIFSalesRepInfoCustLookup;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('accID', backSlash+parentRecord.Id+backSlash);
          ApexPages.currentPage().getParameters().put('fshq', '\'FS Headquarters\'');
          ApexPages.currentPage().getParameters().put('lksrch', 'contactName');
          ApexPages.currentPage().getParameters().put('sri', '\'Contact Lookup\'');
          final FSCustomAccTeamMemLookupController controller = new FSCustomAccTeamMemLookupController();
         // controller.searchContact();
          final String formTag = controller.getFormTag();
          controller.getTextBox();
        Test.StopTest();
        
        System.assertEquals(formTag, null);
  }
    
}