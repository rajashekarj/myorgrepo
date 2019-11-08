@isTest
public class FS_InstallationWarningTest {
    
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);    
    
    private static testmethod void testWarning(){
        
        List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSODBusinessProcess','FSAccountBusinessProcess','FSExecutionPlanTriggerHandler','FSAssociationBrandsetTrigger'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
        //create main Installation record
        FSTestFactory.createCommonTestInstallationRecords();
        final FS_Installation__c installation = [select id,FS_Execution_Plan__c,FS_Outlet__c,RecordTypeId from FS_Installation__c limit 1];
        installation.Type_of_Dispenser_Platform__c='7000;';
        installation.Platform_change_approved__c=true; //FET 7.0 FNF-823
        
        update installation;
        
        //create other Installation record
        final FS_Installation__c secondInstall =FSTestFactory.createTestInstallationPlan(installation.FS_Execution_Plan__c,installation.FS_Outlet__c,false,1,installation.RecordTypeId)[0];
        secondInstall.Type_of_Dispenser_Platform__c='7000;';
        
        
        //create relocation installation record
        final Id relocationId = Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Relocation_I4W_Rec_Type).getRecordTypeId();
        final FS_Installation__c relocationIP =FSTestFactory.createTestInstallationPlan(installation.FS_Execution_Plan__c,installation.FS_Outlet__c,false,1,relocationId)[0];
        relocationIP.FS_Relocation_from_old_outlet_to_SP_is__c=FSConstants.BOOL_VAL;
        relocationIP.Type_of_Dispenser_Platform__c='7000;';
        relocationIP.FS_Rush_Install_Reason__c='Customer Request'; //FET 7.0 FNF-823
        insert new List<FS_Installation__c>{secondInstall,relocationIP}; 
        
         //Platform types custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        //Create HTTP Mock callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        //Create OD
        FS_Outlet_Dispenser__c od= new FS_Outlet_Dispenser__c();
        od.FS_Serial_Number2__c='ZPL9987878';
        od.FS_Equip_Type__c='7000';
        od.FS_Outlet__c=installation.FS_Outlet__c;
        od.recordTypeid = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(Label.CCNA_Disp_Record_type).getRecordTypeId(); 
        od.Relocated_Installation__c=relocationIP.id;
        insert od;
         test.startTest();//FET 7.0 FNF-823
        relocationIP.FS_Install_Reconnect_Date__c=Date.today().addDays(-1);
        relocationIP.FS_Scheduled_Install_Date__c=relocationIP.FS_Disconnect_Final_Date__c=Date.today();
        update relocationIP;       
        
        //create brandsets
        final List<FS_Brandset__c>  brandsets = FSTestFactory.createTestBrandset();
        //create Association brandsets
        final List<FS_Association_Brandset__c> assBrandsets = 
            FSTestFactory.createTestAssociationBrandset(true,brandsets, FSConstants.INSTALLATIONOBJECTNAME,installation.Id,1);
        //Set NonBranded Water value to null
        assBrandsets[0].FS_NonBranded_Water__c=null;
        update assBrandsets[0];
        
        
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final ApexPages.StandardController stdController = new ApexPages.StandardController(installation);
            final FS_InstallationWarningController controller = new FS_InstallationWarningController(stdController);
            controller.checkBrandsetAndSyncValues();
            system.assertEquals(true, controller.displayError);
            final ApexPages.StandardController stdController2 = new ApexPages.StandardController(relocationIP);
            final FS_InstallationWarningController controller2 = new FS_InstallationWarningController(stdController2);
            controller2.checkBrandsetAndSyncValues();
        }
        test.stopTest();
    }

}