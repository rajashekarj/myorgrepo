/**************************************************************************************
Apex Class Name     : FSSPPlannerEmailHelperControllerTest
Version             : 1.0
Function            : Test class for  FSSPPlannerEmailHelperController Class. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             28/06/2019          Original Version 
*					  
*************************************************************************************/

@isTest
public class FSSPPlannerEmailHelperControllerTest {
    
    public static Account accchain,accHQ,accOutlet;    
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installtion,replacementInstall,relocationInstall;
    public static FS_Outlet_Dispenser__c  odRec;
    private static Profile fetSysAdmin;    
    private static String recTypeRelocation=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Relocation_I4W_Rec_Type).getRecordTypeId() ;
    private static String recTypeReplace=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Replacement_Rec_Type).getRecordTypeId();
    private static final String REMODEL ='Remodel';
    
    private static void createtestData(){
        List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSAccountBusinessProcess','FSExecutionPlanTriggerHandler'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        FSTestUtil.insertPlatformTypeCustomSettings();      
        
        accchain = new Account();
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        
        accHQ    = new Account();
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);     
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        
        accOutlet = new Account();
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,true);
        
        executionPlan = new FS_Execution_Plan__c();
        executionPlan =FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,accHQ.Id,true);
        fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        installtion = new FS_Installation__c();
        installtion =FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.id,accOutlet.id,true);       
        odRec = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,accOutlet.id,installtion.id,true);
        
        //Create Relocation and Replacement Instalaltion
        List<FS_Installation__c> listInstall=new List<FS_Installation__c>();
        replacementInstall=new FS_Installation__c();
        replacementInstall.Type_of_Dispenser_Platform__c='7000;8000;9000';
        replacementInstall.FS_Execution_Plan__c=executionPlan.id;
        replacementInstall.RecordTypeId=recTypeReplace;
        replacementInstall.FS_Install_Reconnect_Date__c=system.today();
        replacementInstall.FS_Rush_Install_Reason__c=REMODEL;
        listInstall.add(replacementInstall) ;
        
        relocationInstall=new FS_Installation__c();
        relocationInstall.Type_of_Dispenser_Platform__c='7000;8000;9000';
        relocationInstall.FS_Execution_Plan__c=executionPlan.id;
        relocationInstall.RecordTypeId=recTypeRelocation;
        relocationInstall.FS_Install_Reconnect_Date__c=system.today();
        relocationInstall.FS_Rush_Install_Reason__c=REMODEL;
        listInstall.add(relocationInstall);
        
        insert listInstall;
        
    }
    
    //OD record with Replacement Record
    private static testmethod void testODwithReplacementPIA(){
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        
        final Disable_Trigger__c disableABTrigger = new Disable_Trigger__c(Name='FSODBusinessProcess',IsActive__c=false,Trigger_Name__c='FSODBusinessProcess');
        insert disableABTrigger;
        test.startTest();
        system.runAs(fetSysAdminUser){ 
            
            //Link OD record with PIA and Update platform and Serial No to check later
            odRec.FS_Other_PIA_Installation__c=replacementInstall.id;
            odRec.FS_Serial_Number2__c='ZPL1234567';
            odRec.FS_Equip_Type__c='7000';
            update odRec;
            
            //Call Controller
            FSSPPlannerEmailHelperController spPlannerController =new FSSPPlannerEmailHelperController();
            spPlannerController.platform='7000';
            spPlannerController.installationId=replacementInstall.id;
            String strSerialNo=spPlannerController.getODSerialNo();
            
            //Check OD serial No and return string from COntroller are same
            system.assertEquals(strSerialNo,odRec.FS_Serial_Number2__c);
        }
        test.stopTest();
    }
    
    //OD record with Relocation I4W
    private static testmethod void testODWithRelocationI4WPIA(){
        createTestData();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        test.startTest();
        final Disable_Trigger__c disableABTrigger = new Disable_Trigger__c(Name='FSODBusinessProcess',IsActive__c=false,Trigger_Name__c='FSODBusinessProcess');
        insert disableABTrigger;
        system.runAs(fetSysAdminUser){
            
            //Link OD record with PIA and Update platform and Serial No to check later
            odRec.Relocated_Installation__c=relocationInstall.id;
            odRec.FS_Serial_Number2__c='ZPL1234567';
            odRec.FS_Equip_Type__c='7000';
            update odRec;
            
            //Call Controller
            FSSPPlannerEmailHelperController spPlannerController =new FSSPPlannerEmailHelperController();
            spPlannerController.recordType= Label.IP_Relocation_I4W_Rec_Type;
            spPlannerController.platform='7000';
            spPlannerController.installationId=relocationInstall.id;
            String strSerialNo=spPlannerController.getODSerialNo();
            
            //Check OD serial No and return string from COntroller are same
            system.assertEquals(strSerialNo,odRec.FS_Serial_Number2__c);
        }
        test.stopTest();
    }
}