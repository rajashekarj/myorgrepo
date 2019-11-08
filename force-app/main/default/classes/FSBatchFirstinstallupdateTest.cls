/*************************************************************************************************** 
Name         : FSBatchFirstInstallDateUpdateTest
Usage        : Unit test coverage of FSBatchFirstInstallDateUpdate
***************************************************************************************************/
@isTest 
public class FSBatchFirstinstallupdateTest {
    public static String newInstallrecType=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(FSConstants.NEWINSTALLATION).getRecordTypeId();
    public static String recTypeRelocation=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Relocation_I4W_Rec_Type).getRecordTypeId() ;
    
    static testmethod void updateFirstInstallDate()
    {       
        List<FS_Installation__c> instList=new List<FS_Installation__c>();
        FS_Installation__c installation;
        account headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        Account outletAcc= FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,true);
        outletAcc.FS_ACN__c='0012362541254';
        outletAcc.ShippingCountry='US';
        outletAcc.First_Install_Date1__c=null;
        update outletAcc;
        //Platform types custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        //Create HTTP Mock callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        //Create OD
        FS_Outlet_Dispenser__c od= new FS_Outlet_Dispenser__c();
        od.FS_Serial_Number2__c='ZPL9987878';
        od.FS_Equip_Type__c='8000';
        od.FS_Outlet__c=outletAcc.id;
        od.recordTypeid='01261000000MbbL';
        insert od;
        
        FS_Execution_Plan__c executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, true);
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        //installation.FS_New_Outlet__c=outletAcc.id;
        installation.RecordTypeId=newInstallrecType;
        //installation.Overall_Status2__c='Complete';
        installation.FS_Original_Install_Date__c=Date.Today();
        installation.FS_Scheduled_Install_Date__c =Date.today();
        installation.FS_Rush_Install_Reason__c='Remodel';
        instList.add(installation);
        
        Fs_Installation__c installation1;
        installation1=FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.id , false);
        //installation1.FS_New_Outlet__c=outletAcc.id;
        installation1.RecordTypeId=recTypeRelocation;
        //installation1.Overall_Status2__c='Complete';
        //installation1.FS_Install_Reconnect_Date__c =Date.Today()-3;
        //installation1.FS_Scheduled_Install_Date__c =Date.today();
        installation1.FS_Rush_Install_Reason__c='Remodel';
        instList.add(installation1);
        
        insert(instList);
        Test.startTest();
        installation1.FS_Install_Reconnect_Date__c =Date.Today()-3;
        installation1.FS_Scheduled_Install_Date__c =Date.today();
        installation.Overall_Status2__c='Complete';
        update installation;
        
        od.Relocated_Installation__c=installation.id;
        update od;
        
        
        Database.executeBatch(new FSBatchFirstInstallDateUpdateNew());
        Database.executeBatch(new FSBatchFirstInstallDateUpdate());
        System.assertNotEquals(installation1,null);
        Test.stopTest();
        
    }
}