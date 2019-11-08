/**************************************************************************************
Apex Class Name     : FS_SelectOutletDispenserTest
Version             : 1.0
Function            : This test class is for FS_SelectOutletDispenser Class code coverage. 
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys           01/19/2016       	Original Version
Venkata			  	02/13/2017		 	Modified to cover newly added code for FET 4.0 project	
					05/29/2018		 	Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/

@istest
Private class FS_SelectOutletDispenserTest {
    private static Account headQuarterAcc, outletAcc;
    private static FS_Execution_Plan__c executionPlan;       
    private static FS_Outlet_Dispenser__c outletDispenser,outletDispenser1,outletDispenser2,outletDispenser3;
    
   //private static FS_Brandset__c brandSet1;    
    private static String location='Test Location';
    private static String location2='Test Location 2';
    private static String noVal='No';    
    public static FS_Installation__c installation;
    private static List<FS_Outlet_Dispenser__c > addAllODs=new List<FS_Outlet_Dispenser__c> ();
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5; 
    
    private static void createTestData(){        
        
        final List<Account> accList=new List<Account>();
        headQuarterAcc=new Account(Name='Test Account 2',ShippingCountry= 'US',RecordTypeId= FSConstants.RECORD_TYPE_HQ);
        accList.add(headQuarterAcc);
        outletAcc=new Account(Name='Test Account',ShippingCountry = 'US', RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId());
        accList.add(outletAcc);  
        insert accList;
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headQuarterAcc.id, true);       
   
        FSTestFactory.createTestDisableTriggerSetting();
        
        final Disable_Trigger__c disableABTrigger = new Disable_Trigger__c(Name='FSAssociationBrandsetTrigger',IsActive__c=false,Trigger_Name__c='FSAssociationBrandsetTrigger');
         insert disableABTrigger; 
        final String recTypeReplace=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_Replacement_Rec_Type).getRecordTypeId() ;
        installation=new FS_Installation__c(FS_Outlet__c=outletAcc.id,Type_of_Dispenser_Platform__c='7000;8000;9000',FS_Execution_Plan__c=executionPlan.id,recordtypeid=recTypeReplace);
        insert installation;
        
        FSTestFactory.lstPlatform();        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final Disable_Trigger__c disableODTrigger = new Disable_Trigger__c(Name='FSODBusinessProcess',IsActive__c=false,Trigger_Name__c='Fs_OD_Trigger');
        insert disableODTrigger;
        outletDispenser=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,FS_Serial_Number2__c='SNO001',FS_Dispenser_Location__c=location,
                                                   FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                   FS_Equip_Type__c='7000',FS_IsActive__c=true,Installation__c = installation.id );
        
        outletDispenser1=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,FS_Serial_Number2__c='SNO002',FS_Dispenser_Location__c=location,
                                                    FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                    FS_Equip_Type__c='8000',FS_IsActive__c=true);
        outletDispenser2=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,FS_Serial_Number2__c='SNO003',FS_Dispenser_Location__c=location,
                                                    FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                    FS_Equip_Type__c='9000',FS_IsActive__c=true);       
        
        outletDispenser3=new FS_Outlet_Dispenser__c(FS_Outlet__c=outletAcc.Id,FS_Serial_Number2__c='SNO004',FS_Dispenser_Location__c=location,
                                                    FS_User_Defined_Location__c=location2,FS_Valid_Fill__c=noVal, 
                                                    FS_Equip_Type__c='7000',FS_Removal_Request_Submitted__c=false);        
        addAllODs.add(outletDispenser);
        addAllODs.add(outletDispenser1);
        addAllODs.add(outletDispenser2);
        addAllODs.add(outletDispenser3);
        insert addAllODs;
       
    }
    
    private static testmethod void testMethod1() { 
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createTestData();        
            Test.startTest();
            
            final PageReference pageRef = Page.FS_SelectOutletDispenser;
            Test.setCurrentPage(pageRef);           
            
            ApexPages.standardController controller=null;            
            controller = new ApexPages.standardController(installation);
            
            final FS_SelectOutletDispenser classInstance=new FS_SelectOutletDispenser (controller);        
            classInstance.FS_OutletList=classInstance.getFSOutletDispensers();  
            
            system.assertEquals(4, classInstance.FS_OutletList.size());
            
            for(FS_SelectOutletDispenser.FS_Outlet_DispenserWrapper thisListItem : classInstance.FS_OutletList ){            
                thisListItem.selected=true;
            }           
            classInstance.DeleteProcess();                
            Test.stopTest();            
        }       
    }
    
    private static testmethod void testMethod2() {
        createTestData();
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            
            Test.startTest();             
            
            final PageReference pageRef = Page.FS_SelectOutletDispenser;
            Test.setCurrentPage(pageRef);            
            ApexPages.standardController controller=null;
            
            controller = new ApexPages.standardController(installation);
            
            final FS_SelectOutletDispenser classInstance=new FS_SelectOutletDispenser (controller);        
            classInstance.FS_OutletList=classInstance.getFSOutletDispensers();
            
            system.assertEquals(4, classInstance.FS_OutletList.size());
            
            for(FS_SelectOutletDispenser.FS_Outlet_DispenserWrapper thisListItem : classInstance.FS_OutletList ){            
                thisListItem.selected=true;
            }            
            classInstance.DeleteProcess();
            classInstance.FS_OutletList=classInstance.getFSOutletDispensers();
            for(FS_SelectOutletDispenser.FS_Outlet_DispenserWrapper thisListItem : classInstance.FS_OutletList ){            
                thisListItem.selected=FALSE;
            }
            classInstance.DeleteProcess();
           	classInstance.changeMode();
            classInstance.cancel();
            Test.stopTest();   
        }
    }  
}