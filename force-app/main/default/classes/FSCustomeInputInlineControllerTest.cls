/*************************************************************************************************
Created By   : Vandana Kumari(Appiro JDC)
Date         : Oct 16, 2014
Usage        : Test class for FSCustomeInputInlineController
Modified By  : Vandana Kumari
*/
@isTest
public class FSCustomeInputInlineControllerTest {
    
    private static Account account;
    private static List<Contact> listContact;
    
    private static testMethod void myUnitTest() {      
        
        createTestData();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.startTest();
            
            final ApexPAges.StandardController stdCntlr = new ApexPages.StandardController(account);  
            final FSCustomeInputInlineController controller = new FSCustomeInputInlineController(stdCntlr);      
            controller.createNewCustomerInput();
            system.assertEquals(5,listContact.size());
            Test.stopTest();
        }
        
    }
    
    // Method to create test data
    private static void createTestData(){
        
        account = new Account(Name = 'test account');
        insert account;
        
        listContact = new List<Contact>();
        for(Integer indx=1; indx <= 5; indx ++){
            final Contact contact = new Contact(LastName = 'Test' + indx, AccountId = account.id);
            listContact.add(contact);
        }
        insert listContact;
    }
}