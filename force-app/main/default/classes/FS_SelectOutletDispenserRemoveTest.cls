/**************************************************************************************
Apex Class Name     : FS_SelectOutletDispenserRemoveTest
Version             : 1.0
Function            : This test class is for FS_SelectOutletDispenserRemoveRelocate Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             01/19/2016          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@istest
Private class FS_SelectOutletDispenserRemoveTest {
    private static Account headQuarterAcc, outletAcc;
    private static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation;
    private static FS_Outlet_Dispenser__c outletDispenser;
    private static FS_Outlet_Dispenser__c outletDispenser1;
    private static FS_Outlet_Dispenser__c outletDispenser2;
    private static FS_Outlet_Dispenser__c outletDispenser3;
    private static FS_Brandset__c brandSet1;    
    private static String location='Test Location';
    private static String location2='Test Location 2';
    private static String noVal='No';    
    private static List<FS_Outlet_Dispenser__c > addAllODs=new List<FS_Outlet_Dispenser__c> ();
    
    
    private static void createTestData(){        
        FSTestFactory.createTestDisableTriggerSetting();    
        
        outletAcc=new Account(Name='Test Account',ShippingCountry = 'US', RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId());
        insert outletAcc;
        
        headQuarterAcc=new Account(Name='Test Account 2',ShippingCountry= 'US',RecordTypeId= FSConstants.RECORD_TYPE_HQ);
        insert headQuarterAcc;
        executionPlan=new FS_Execution_Plan__c(Name='Test EP',FS_Headquarters__c=headQuarterAcc.id);
        insert executionPlan;
        FSTestFactory.lstPlatform();
        
        brandSet1 = new FS_Brandset__c();
        brandSet1.FS_AccountName__c = 'TestAccount1BrandSet';
        brandSet1.FS_Country__c = 'AD;AE;';
        brandSet1.FS_Platform__c = '7000;8000;9000;';
        brandSet1.FS_Effective_Start_Date__c = System.today();
        insert brandSet1;
        
        final String recTypeRelocation=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Relocation_I4W_Rec_Type).getRecordTypeId() ;
        installation=new FS_Installation__c(FS_Outlet__c=outletAcc.id,FS_Execution_Plan__c=executionPlan.id,recordtypeid=recTypeRelocation);
        insert installation;       
        
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        outletDispenser=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,
                                                   FS_Serial_Number2__c='SNO001',FS_Dispenser_Location__c=location,
                                                   FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                   FS_Equip_Type__c='7000',FS_IsActive__c=true,Installation__c = installation.id );
        
        outletDispenser1=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,
                                                    FS_Serial_Number2__c='SNO002',FS_Dispenser_Location__c=location,
                                                    FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                    FS_Equip_Type__c='8000',FS_IsActive__c=true);
        outletDispenser2=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,
                                                    FS_Serial_Number2__c='SNO003',FS_Dispenser_Location__c=location,
                                                    FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                    FS_Equip_Type__c='9000',FS_IsActive__c=true);       
        
        outletDispenser3=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,
                                                    FS_Serial_Number2__c='SNO004',FS_Dispenser_Location__c=location,
                                                    FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                    FS_Equip_Type__c='7000',FS_Removal_Request_Submitted__c=false);        
        addAllODs.add(outletDispenser);
        addAllODs.add(outletDispenser1);
        addAllODs.add(outletDispenser2);
        addAllODs.add(outletDispenser3);
        insert addAllODs;
    }
    
    private static testmethod void testRemoveSingle() { 
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createTestData();        
            
            final Date today=System.today();
             Test.startTest();
            final PageReference pageRef = Page.FS_SelectOutletDispenserRemoveRelocate;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',installation.id);
            ApexPages.standardController controller=null;
            for(FS_Outlet_Dispenser__c  od: addAllODs){
                controller = new ApexPages.standardController(od);
            }        
            final FS_SelectOutletDispenserRemoveRelocate classInstance=new FS_SelectOutletDispenserRemoveRelocate (controller);        
            classInstance.FS_OutletList=classInstance.getFS_Outlet_Dispensers();        
            for(FS_SelectOutletDispenserRemoveRelocate.FS_Outlet_DispenserWrapper thisListItem : classInstance.FS_OutletList ){            
                thisListItem.selected=true;
            }        
            classInstance.DisconnectDate=today;          
            classInstance.DeleteProcess();     
            System.assertEquals(FSConstants.DATE_NULL, classInstance.DisconnectDate);
            Test.stopTest();            
        }
    }
    
    private static testmethod void testRemoveMulti() {
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createTestData();
            
            final Date today=System.today();           
            Test.startTest();
            final PageReference pageRef = Page.FS_SelectOutletDispenserRemoveRelocate;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',installation.id);
            ApexPages.standardController controller=null;
            for(FS_Outlet_Dispenser__c  od: addAllODs){
                controller = new ApexPages.standardController(od);
            }        
            final FS_SelectOutletDispenserRemoveRelocate classInstance=new FS_SelectOutletDispenserRemoveRelocate (controller);        
            classInstance.FS_OutletList=classInstance.getFS_Outlet_Dispensers();
            for(FS_SelectOutletDispenserRemoveRelocate.FS_Outlet_DispenserWrapper thisListItem : classInstance.FS_OutletList ){            
                thisListItem.selected=true;
            }
            classInstance.DisconnectDate=today;
            
            classInstance.DeleteProcess();         
            System.assertEquals(FSConstants.DATE_NULL, classInstance.DisconnectDate);
            Test.stopTest();
        }
    }
}