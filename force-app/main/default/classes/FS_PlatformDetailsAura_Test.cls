/*=================================================================================================================
* Date         : 01-30-2019
* Developer    : Goutham Rapolu
* Purpose      : Test class for FS_PlatformDetailsInstallationAura which will PlatformDetails inline component on Installation record.
*=================================================================================================================
*                                 Update History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 03-04-2019 | Goutham Rapolu |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

@isTest
public class FS_PlatformDetailsAura_Test {
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
            FS_PlatformDetailsInstallationAura.FSPlatformDetailsInstallationExtension(installation.id);
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
            FS_PlatformDetailsInstallationAura.FSPlatformDetailsInstallationExtension(installation.id);
        }
        Test.stopTest();      
    }
    
    private static testmethod void HelpTextCheck(){    
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FS_PlatformDetailsInstallationAura controller= new FS_PlatformDetailsInstallationAura();
            FS_PlatformDetailsInstallationAura.HelpText('FS_DispRequested1__c');
            FS_PlatformDetailsInstallationAura.HelpText('FS_DispOrder1__c');
        }
        Test.stopTest();      
    }
}