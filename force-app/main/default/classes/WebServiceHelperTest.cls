@isTest
public class WebServiceHelperTest {
    
    public static Account hQAcc,outletAcc,chainAcc,chainInt,hqInt,bottler;
    public static FS_Outlet_Dispenser__c outletDispenser;   
    private static final string SERIES_7K='7000';
    private static Contact cont;    
    private static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;
    public static Profile fetSysAdmin;
    
    private static void createTestData(){   
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final List<Account> listAcc = new LIst<Account>();
        //Chain Account
        chainAcc = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAcc.FS_ACN__c = '76876876';
        listAcc.add(chainAcc);
        
        //HQ Account
        hQAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        hQAcc.FS_ACN__c = '7658765876';
        listAcc.add(hQAcc);
        
        //Creates Outlet Accounts 
        outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,hQAcc.Id, false);
        outletAcc.FS_ACN__c='9874562100';
        listAcc.add(outletAcc);
        //Bottler for international
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,false);
        listAcc.add(bottler);
        insert listAcc;
        
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,hQAcc.Id, true);
        
        //creates installation
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.Id,false);
        installation.Overall_Status2__c=FSConstants.x4InstallSchedule;
        installation.FS_Valid_Fill_Approved__c=false;     
        insert installation;
        FSTestFactory.createTestDisableTriggerSetting();
        
        //Platform typpes custom settings
        FSTestFactory.lstPlatform();
        //creates OD  
        outletDispenser = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);        
    } 
    
    private static testmethod void testreAssignDispenser(){
        createTestData();
        
        outletDispenser.FS_Equip_Type__c = SERIES_7K;
        outletDispenser.FS_Outlet__c=outletAcc.id;
        outletDispenser.Re_Manufactured__c=true;
        insert outletDispenser;
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            WebServiceHelper.reAssignDispenser(outletDispenser.id);
        }
        Test.stopTest();
        system.assertEquals('Assigned to Outlet', [select id,FS_Status__c from  FS_Outlet_Dispenser__c where id=:outletDispenser.id].FS_Status__c);
    }
    
    
    private static testmethod void testSformNotification(){
        createTestData();
        Test.startTest();
        outletDispenser.FS_Equip_Type__c = SERIES_7K;
        outletDispenser.FS_Outlet__c=outletAcc.id;        
        String returnValue;
        insert outletDispenser;        
        
        cont=FSTestUtil.createTestContact(outletAcc.id, 'TestContact', false);
        cont.Email='test@contact.com';
        insert cont;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            returnValue=WebServiceHelper.shippingFormGenerationNotification(outletDispenser.id);
        }
        Test.stopTest();
        system.assertEquals('Success', returnValue);
    }
}