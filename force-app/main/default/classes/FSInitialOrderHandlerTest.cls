/***************************************************************************
Name         : InitialOrderTrigger
Created By   : Mohit Parnami
Description  : Test class of FSInitialOrderHandler
Created Date : Oct 23, 2013         
****************************************************************************/
//Commenting Initial Order SAP Data Object related lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0
@isTest
private class FSInitialOrderHandlerTest {
    
    static Account headQuarterAcc, outletAcc;
    static List<FS_Initial_Order__c> initialOrder;    
    static FS_Execution_Plan__c executionPlan;
    static FS_Installation__c installation;
    static final Id initialOrderRecordType=FSUtil.getObjectRecordTypeId(FS_Initial_Order__c.SObjectType,FSConstants.NEWINITIALORDER);
    
    
    //--------------------------------------------------------------------------------------
    // Test method of Initial Order Trigger
    //--------------------------------------------------------------------------------------
    static testmethod void testInitialOrderTrigger(){
        createData();
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            
            test.startTest();
            insert initialOrder;
            initialOrder[0].FS_X7_Slots_to_Add2__c = 10;
            //update initial Order
            update initialOrder;
            system.assertEquals(initialOrder[0].FS_X7_Slots_to_Add2__c, 10);
            system.assertEquals(initialOrder[0].FS_X2_Slots_to_Add2__c, 1);
            system.assertEquals(initialOrder[0].FS_X4_Slots_to_Add2__c, 1);
            system.assertEquals(initialOrder[0].FS_X3_Slots_to_Add2__c, 1);
            system.assertEquals(initialOrder[0].FS_X16_Slots_to_Add2__c, 1);
            system.assertEquals(initialOrder[0].FS_X22_Slots_to_Add2__c, 1);
            
            //change the name of outlet to test else part.
            outletAcc.Name = 'Test firehouse';
            update outletAcc;
            //update initial order
            initialOrder[0].FS_X7_Slots_to_Add2__c = 2;
            update initialOrder[0];
            
            test.stopTest();
        }
    }    
    
    //--------------------------------------------------------------------------------------
    //Create Test Data For Initial Order Trigger
    //--------------------------------------------------------------------------------------
    private static void createData(){
        
        //Creates HeadQuater Accounts
        HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        //Creates Outlet Accounts
        outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, true);
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,HeadQuarterAcc.Id, true);
        //creates installation
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id, outletAcc.Id, false);
        insert installation;       
        
        //creates initial order       
        initialOrder=new List<FS_Initial_Order__c>();
        initialOrder= FSTestFactory.createTestInitialOrder(outletAcc.Id, installation.Id, false,2,initialOrderRecordType);
        for(FS_Initial_Order__c initialOrder1:initialOrder ){
            initialOrder1.FS_X7_Slots_to_Add2__c = 1;
            initialOrder1.FS_X2_Slots_to_Add2__c = 1;
            initialOrder1.FS_X4_Slots_to_Add2__c = 1;
            initialOrder1.FS_X3_Slots_to_Add2__c = 1;
            initialOrder1.FS_X18_Slots_to_Add2__c = 1;
            initialOrder1.FS_X16_Slots_to_Add2__c = 1;
            initialOrder1.FS_X22_Slots_to_Add2__c=  1;        
        }
        
    } 
}