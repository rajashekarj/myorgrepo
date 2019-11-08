/**************************************************************************************
Apex Class Name     : FSCEAttributesUpdatesTest
Version             : 1.0
Function            : This test class is for FSCEAttributesUpdates Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
public class FSCEAttributesUpdatesTest{
    
    public static String recTypeIP=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_New_Install_Rec_Type).getRecordTypeId() ;
    public static String recTypeOd=Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get(Label.CCNA_Disp_Record_type).getRecordTypeId() ;
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    private static testmethod void updateAccount(){
        final Account headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        final Account outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,true);
        outletAcc.FS_ACN__c='30112016001';
        outletAcc.ShippingCountry='US';
        outletAcc.First_Install_Date1__c=null;
        update outletAcc;
        
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            Database.executeBatch(new FSCEAttributesUpdates('Account'));
        }
        Test.stopTest();        
    }
    
    private static testmethod void updateOD(){
        
        //insert platform type custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
 
        final Account headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        final Account outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,true);
        final FS_Execution_Plan__c executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, true);
        
        final FS_Installation__c installation = FSTestUtil.createInstallationAcc(Label.IP_New_Install_Rec_Type,executionPlan.Id,outletAcc.id , false);
        installation.RecordTypeId=recTypeIP;
        insert installation ;
        
        final FS_Outlet_Dispenser__c odRec=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,Installation__c=installation.Id,RecordTypeId=recTypeOd,
                                                                   FS_Equip_Type__c='8000',FS_IsActive__c=true);
        insert odRec;
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            Database.executeBatch(new FSCEAttributesUpdates('FS_Outlet_Dispenser__c'));
        }
        Test.stopTest();        
    }
}