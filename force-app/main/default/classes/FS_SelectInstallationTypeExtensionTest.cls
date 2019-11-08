/**************************************************************************************
Apex Class Name     : FS_SelectInstallationTypeExtensionTest
Version             : 1.0
Function            : This test class is for FS_SelectInstallationTypeExtension Class code coverage. 
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata             01/12/2017          Original Version
*************************************************************************************/
@isTest
private class FS_SelectInstallationTypeExtensionTest {
    public Static final Id RECTYPEOUTLET=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Outlet');
    @testSetup
    private static void loadData(){
        //Creating Outlet
        FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));//List<Account> outletLst = 
    }
    private static testMethod void proceedTest(){ 
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            final Account outlet = [Select id from Account where RecordTypeId =:RECTYPEOUTLET];
            //Sets the current PageReference for the controller
            final PageReference pageRef=Page.FS_SelectInstallationType;
            Test.setCurrentPage(pageRef);
            //Add parameters to page URL
            pageRef.getParameters().put('Id',outlet.id);       
            
            final FS_SelectInstallationTypeExtension controller = new FS_SelectInstallationTypeExtension();
            //Proceed with creating new Replacement record
            controller.proceedAction();
            system.assertEquals('a0k', controller.code);		       
            Test.stopTest(); 
        }
        
    }
    private static testMethod void cancelTest(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            final Account outlet = [Select id from Account where RecordTypeId =: RECTYPEOUTLET];
            new PageReference('/'+outlet.Id);
            //Sets the current PageReference for the controller
            final PageReference pageRef=Page.FS_SelectInstallationType;
            Test.setCurrentPage(pageRef);
            //Add parameters to page URL
            pageRef.getParameters().put('Id',outlet.id);         
            
            final FS_SelectInstallationTypeExtension controller = new FS_SelectInstallationTypeExtension();
            //Cancel creating new Replacement
            controller.cancelAction();
            system.assertEquals(false, controller.displayPopup);
            Test.stopTest(); 
        }        
    }
}