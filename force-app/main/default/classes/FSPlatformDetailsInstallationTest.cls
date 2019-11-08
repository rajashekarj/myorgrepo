/*************************************************************************************
Apex Class Name     : FSPlatformDetailsInstallationTest
Version             : 1.0
Function            : This test class is for FSPlatformDetailsInstallationExtension Class code coverage. 
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkat	FET5.0 			01/05/2018			Original Version
************************************************************************************/

@isTest
public class FSPlatformDetailsInstallationTest {
    private static Account headquartersAcc,outletAcc;
    private static FS_Execution_Plan__c executionPlan;
    private static FS_Installation__c installation;
    public static final String PLATFORM='7000;8000;9000';
     private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    private static FS_Installation__c createTestData(){
        //creating test Data
        FSTestFactory.createTestDisableTriggerSetting();
        final List<Account> insertAccounts = new List<Account>();
        headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,false);           
        insertAccounts.add(headquartersAcc);
        insertAccounts.add(outletAcc);            
        insert insertAccounts;
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, false);
        executionPlan.FS_Platform_Type__c=PLATFORM;
        insert executionPlan; 
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        installation.Type_of_Dispenser_Platform__c=PLATFORM;
         
        return installation;
    }
    private static testmethod void platformDetailCheck(){    
        createTestData();
        Test.startTest();
        //inserting Installation
        installation.FS_Platform1__c=FSConstants.RECTYPE_7k;
        installation.FS_Platform2__c=FSConstants.RECTYPE_8k;
        installation.FS_Platform3__c=FSConstants.RECTYPE_9k;
        insert installation;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final ApexPages.StandardController stdcon = new ApexPages.standardController(installation);            
            final FSPlatformDetailsInstallationExtension controller= new FSPlatformDetailsInstallationExtension(stdcon);
            
            system.assertEquals(3, controller.platformList.size());
        }
        Test.stopTest();      
    }
    private static testmethod void platformDetailCheckBlank(){    
        createTestData();
        Test.startTest();  
        //creating Installation
        installation.Type_of_Dispenser_Platform__c=FSConstants.STRING_NULL;
        insert installation;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final ApexPages.StandardController stdcon = new ApexPages.standardController(installation);            
            final FSPlatformDetailsInstallationExtension controller= new FSPlatformDetailsInstallationExtension(stdcon);
            system.assertEquals(new FS_Installation__c(), controller.mapInstallRecords.get('Platform 1'));
        }
        Test.stopTest();      
    }
    
}