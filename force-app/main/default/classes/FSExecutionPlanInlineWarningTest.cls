@isTest
public class FSExecutionPlanInlineWarningTest {
    
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    @testSetup
    public static void createData(){
        //create EP and IP
        FSTestFactory.createCommonTestRecords();
    }   
    
    public static testMethod void displayWarning(){
        //get the Ep
        final FS_Execution_Plan__c exep = [select id from FS_Execution_Plan__c];
        //get the IP
        final FS_Installation__c install = [Select Type_of_Dispenser_Platform__c from FS_Installation__c];
        //mismatch the platform
        install.Type_of_Dispenser_Platform__c='7000;8000';
        install.Platform_change_approved__c=true;
        update install;
        //run the controller
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final ApexPages.StandardController standCon = new ApexPages.StandardController(exep);
            final FSExecutionPlanInlineWarningController controller = new FSExecutionPlanInlineWarningController(standCon);            
            controller.checkSyncValues();  
        }
    }
}