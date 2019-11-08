/**************************************************************************
Name         : FSCloneBrandsetControllerTest
Created By   : Alisha Gupta
Description  : Test class of FSCloneBrandsetController
Created Date : Sept 21, 2016
****************************************************************************/
@isTest
public class FSCloneBrandsetControllerTest{
    
    private static  FS_brandset__c brandsetName=new FS_Brandset__c();
    public static void testRecords(){
        //custom setting trigger switch
        FSTestFactory.createTestDisableTriggerSetting();
        
        //create test record
        brandsetName.FS_Country__c='US';       
        brandsetName.FS_Description__c='test record'+math.random();
        brandsetName.FS_Platform__c='7000';
        brandsetName.FS_Effective_Start_Date__c=system.today();
        insert brandsetName;
        
        final FS_Cartridge__c cart=new FS_Cartridge__c();
        cart.FS_Country__c='US';
        cart.FS_Platform__c='7000';
        cart.fs_flavor__c='nothing';
        insert cart;
        final FS_Brandsets_Cartridges__c brandsetCart=new FS_Brandsets_Cartridges__c();
        brandsetCart.FS_Brandset__c=brandsetName.id;
        brandsetCart.FS_Cartridge__c=cart.id;
        insert brandsetCart;
    }
    
    private static testMethod void testCloneRec(){
        
        //insert test records;
        testRecords();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            Test.StartTest();
            final ApexPages.StandardController con = new ApexPages.StandardController(brandsetName);
            // create the controller
            final FSCloneBrandsetController fsController=new FSCloneBrandsetController(con);
            
            final PageReference ref = fsController.Save();
            // create the matching page reference
            
            final PageReference redir = new PageReference('/'+fsController.newRecordId);
            
            // make sure the user is sent to the correct url
            System.assertEquals(ref.getUrl(),redir.getUrl());
            
            // check that the new Brandset is created
            final FS_brandset__c newBset = [select id from FS_brandset__c where id = :fsController.newRecordId];
            System.assertNotEquals(newBset.id, null);
            // check that the new Brandset cartridge is created
            final List<FS_Brandsets_Cartridges__c> newBC = [Select id From FS_Brandsets_Cartridges__c where FS_brandset__c = :newBset.id];
            System.assertEquals(newBC.size(),1);  
            
            Test.StopTest();
        }
        
    }
    
    private static testMethod void testCloneRec1()
    {
        //testRecords();
        final ApexPages.StandardController con = new ApexPages.StandardController(brandsetName);
        final FSCloneBrandsetController fsController=new FSCloneBrandsetController(con);
        
        Test.StartTest();
        
        
        final FS_brandset__c test1 = new FS_brandset__c();
        fsController.brandset = test1;
        fsController.Save();
        Test.stopTest();
        System.assertNotEquals(NULL,fsController.brandset); 
    }
    
}