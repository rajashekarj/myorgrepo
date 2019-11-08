/****************************************************************************************
Apex Class Name     : FETCreateShareRecordsTest
Version             : 1.0
Function            :  
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FETCreateShareRecordsTest{
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    public static Account headQuarterAcc, outletAcc, defaultAccount, internationalOutlet, chainAccount,bottler, outletacc2;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;    
    public static User apiUser, coordinatorUser;
    
    public static FS_Outlet_Dispenser__c outletDispenserInt;    
    public static FS_Integration_NMS_User__c integrationUser;
    public static FS_IP_Technician_Instructions__c  ipTechInstruction;
    public static Shipping_Form__c shippingForm;
    public static final string COUNTRY='FR';
    public static final string COCACOLA='Coca-Cola Enterprises';
    public static final string READ='Read';
    public static final string COCACOLABUSI='Coca-Cola Business Unit';
    public static final string BOTTLER1='Bottler-1';
    public static final string ODCOUNTRY='France';
    
    
    private static void createTestData(){    
        
        //set Mock callout
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        //create platform type custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        
        apiUser=FSTestUtil.createUser(null,null,'API User',false);
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
        
        chainAccount = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,false);
        chainAccount.FS_ACN__c = '000182755ICH';
        chainAccount.OwnerId=UserInfo.getUserId();
        insert chainAccount;
        
        HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        HeadQuarterAcc.FS_ACN__c = '7658765876';
        HeadQuarterAcc.FS_Chain__c=chainAccount.Id;
        HeadQuarterAcc.OwnerId=UserInfo.getUserId();
        insert HeadQuarterAcc;
        
        //Creates Outlet Accounts
        outletAcc = FSTestUtil.createAccountOutlet('FET International Outlet',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, false);
        
        outletAcc.Is_Default_FET_International_Outlet__c=true;
        outletAcc.shippingcountry = COUNTRY;
        outletAcc.FS_Chain__c=chainAccount.Id;
        outletAcc.FS_Headquarters__c=HeadQuarterAcc.Id;
        outletAcc.Bottler_Name__c=COCACOLA;
        outletAcc.OwnerId=UserInfo.getUserId();
        insert outletAcc;
        
        outletAcc2 = FSTestUtil.createAccountOutlet('FS Outlet',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, false);
        
        outletAcc2.Is_Default_FET_International_Outlet__c=false;
        outletAcc2.shippingcountry = COUNTRY;
        outletAcc2.FS_Chain__c=chainAccount.Id;
        outletAcc2.FS_Headquarters__c=HeadQuarterAcc.Id;
        outletAcc2.Bottler_Name__c=COCACOLA;
        outletAcc2.OwnerId=UserInfo.getUserId();
        insert outletAcc2;
        
        system.runAs(coordinatorUser){
            shippingForm = FSTestUtil.createShippingForm(true);
        }
        
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,HeadQuarterAcc.Id, true);
        
        //creates installation
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.Id,true);      

        outletDispenserInt = FSTestUtil.createOutletDispenserAllTypes('BoE Dispenser',null,outletAcc.id,null,false);
        outletDispenserInt.FS_Serial_Number2__c='ZPLTEST001';        
    }
    
    
    private static testMethod void odWithCountryDefaultOutlet() {
        
        createTestData();
        apiUser.Dispenser_Country__c=COUNTRY;
        apiUser.dispenser_read_edit__c=READ;
        apiUser.Ownership__c=COCACOLA;
        apiUser.Ownership_Type__c=COCACOLABUSI;
        insert apiUser;
        system.assertEquals(installation.FS_Outlet__c,outletAcc.Id);
        system.assertEquals(1,[SELECT COUNT() FROM Account where RecordTypeId=:FSConstants.RECORD_TYPE_OUTLET_INT and Name='FET International Outlet']);
        for(Account acc : [Select shippingCountry,FS_Headquarters__c,FS_Headquarters__r.OwnerID, FS_Chain__c,FS_Chain__r.OwnerID, Bottler_Name__c,Id,OwnerId, Name FROM Account where id=:outletAcc.Id]){
            system.assertEquals(acc.FS_Headquarters__c,HeadQuarterAcc.Id);
            system.assertEquals(acc.FS_Chain__c,chainAccount.Id);            
        }
        system.assertEquals(HeadQuarterAcc.ownerId,UserInfo.getUserId());
        system.assertEquals(installation.FS_Outlet__c,outletAcc.Id);
        System.runAs(apiUser){
            Test.startTest();
            
            outletDispenserInt.FS_Outlet__c=outletAcc2.Id;
            outletDispenserInt.Shipping_Form__c=shippingForm.Id;
            outletDispenserInt.FS_Equip_Type__c = FSConstants.RECTYPE_7k;
            outletDispenserInt.Ownership_Type__c=COCACOLABUSI;
            outletDispenserInt.Ownership__c=BOTTLER1;
            outletDispenserInt.Country__c=ODCOUNTRY;
            insert outletDispenserInt;
            Test.stopTest();
        }
    }
    
    private static testMethod void odWithCountryNoDefaultOutlet() {
        
        createTestData();
        outletAcc.Name='Other Outlet';
        update outletAcc;
        
        apiUser.Dispenser_Country__c=COUNTRY;
        apiUser.dispenser_read_edit__c=READ;
        apiUser.Ownership__c=COCACOLA;
        apiUser.Ownership_Type__c=COCACOLABUSI;
        insert apiUser;
        system.assertEquals(installation.FS_Outlet__c,outletAcc.Id);
        
        for(Account acc : [Select shippingCountry,FS_Headquarters__c,FS_Headquarters__r.OwnerID, FS_Chain__c,FS_Chain__r.OwnerID, Bottler_Name__c,Id,OwnerId, Name FROM Account where id=:outletAcc.Id]){
            system.assertEquals(acc.FS_Headquarters__c,HeadQuarterAcc.Id);
            system.assertEquals(acc.FS_Chain__c,chainAccount.Id);
            
        }
        system.assertEquals(HeadQuarterAcc.ownerId,UserInfo.getUserId());
        system.assertEquals(installation.FS_Outlet__c,outletAcc.Id);
        System.runAs(apiUser){
            Test.startTest();
            
            outletDispenserInt.FS_Outlet__c=outletAcc.Id;
            outletDispenserInt.Shipping_Form__c=shippingForm.Id;
            outletDispenserInt.FS_Equip_Type__c = FSConstants.RECTYPE_7k;
            outletDispenserInt.Ownership_Type__c=COCACOLABUSI;
            outletDispenserInt.Ownership__c=BOTTLER1;
            outletDispenserInt.Country__c=ODCOUNTRY;
            insert outletDispenserInt;
            
            Test.stopTest();
        }
    }
    
    
    private static testMethod void odWithoutCountry() {
        
        createTestData();
        apiUser.Dispenser_Country__c=COUNTRY;
        apiUser.dispenser_read_edit__c=READ;
        apiUser.Ownership__c=COCACOLA;
        apiUser.Ownership_Type__c=COCACOLABUSI;
        insert apiUser;
        system.assertEquals(installation.FS_Outlet__c,outletAcc.Id);
        system.assertEquals(1,[SELECT COUNT() FROM Account where RecordTypeId=:FSConstants.RECORD_TYPE_OUTLET_INT and Name='FET International Outlet']);
        System.runAs(apiUser){
            Test.startTest();
            
            outletDispenserInt.FS_Outlet__c=outletAcc2.Id;
            //outletDispenserInt.Installation__c = installation.Id;
            outletDispenserInt.Shipping_Form__c=shippingForm.Id;
            outletDispenserInt.FS_Equip_Type__c = FSConstants.RECTYPE_7k;
            outletDispenserInt.Ownership_Type__c=COCACOLABUSI;
            outletDispenserInt.Ownership__c=BOTTLER1;
            insert outletDispenserInt;
            
            Test.stopTest();
        }
    }  
    
    private static testMethod void odWithCountryBottler() {
        
        createTestData();
        outletAcc.Name='Other Outlet';
        update outletAcc;
        
        apiUser.Dispenser_Country__c=COUNTRY;
        apiUser.dispenser_read_edit__c=READ;
        apiUser.Ownership__c=COCACOLA;
        apiUser.Ownership_Type__c='Bottler';
        insert apiUser;
        system.assertEquals(installation.FS_Outlet__c,outletAcc.Id);
        
        System.runAs(apiUser){
            
            
            Test.startTest();
            
            outletDispenserInt.FS_Outlet__c=outletAcc.Id;
            outletDispenserInt.Shipping_Form__c=shippingForm.Id;
            outletDispenserInt.FS_Equip_Type__c = FSConstants.RECTYPE_7k;
            outletDispenserInt.Ownership_Type__c=COCACOLABUSI;
            outletDispenserInt.Ownership__c=BOTTLER1;
            outletDispenserInt.Country__c=ODCOUNTRY;
            insert outletDispenserInt;
            Test.stopTest();
        }
    }
    
    private static testMethod void odWithCountryNoDefaultOutletCountry() {
        
        createTestData();
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        outletAcc.Name='Other Outlet';
        outletAcc.Bottlers_Name__c = bottler.id;
        outletAcc.Bottler_Name__c ='Coca Cola Beverages Singapore';
        update outletAcc;
        
        apiUser.Dispenser_Country__c=COUNTRY;
        apiUser.dispenser_read_edit__c=READ;
        apiUser.Ownership__c=COCACOLA;
        apiUser.Ownership_Type__c='Bottler';
        insert apiUser;
        system.assertEquals(installation.FS_Outlet__c,outletAcc.Id);
        
        System.runAs(apiUser){
            
            
            Test.startTest();
            
            outletDispenserInt.FS_Outlet__c=outletAcc.Id;
            outletDispenserInt.Shipping_Form__c=shippingForm.Id;
            outletDispenserInt.FS_Equip_Type__c = FSConstants.RECTYPE_7k;
            outletDispenserInt.Ownership_Type__c='Bottler';
            outletDispenserInt.Ownership__c=BOTTLER1;
            outletDispenserInt.Country__c=ODCOUNTRY;
            insert outletDispenserInt;
            
            Test.stopTest();
        }
    }    
    
    private static testMethod void covrageMethod() {
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            FETCreateShareRecords.createSharingRecordsForAccountBasedOnCountry();
            FETCreateShareRecords.updateAccessForBusinessUnit();
            FETCreateShareRecords.updateAccessForBottler();
        }
    }
    
}