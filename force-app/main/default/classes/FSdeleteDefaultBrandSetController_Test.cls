@isTest
private class FSdeleteDefaultBrandSetController_Test{
    private static final String HQCUSTOMER= 'FS Headquarters';
    private static final string LIT7K = '7000';
    private static final string LIT8K = '8000';
    private static final string LIT9K = '9000';
    
    @testSetup
    private static void loadTestData(){
        //create Brandset records
        FSTestFactory.createTestBrandset(); //creates 20 branset records
        
        //Create Single HeadQuarter
        FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,HQCUSTOMER));
    }
    private static testMethod void testHeadQuarterAssociation(){
        
        //get test data 
        List<FS_Brandset__c> brandsetRecordList=[SELECT Id,FS_Platform__c FROM FS_Brandset__c LIMIT 20];
        
        //Separate Brandset based on platform 
        final List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset8000List=new List<FS_Brandset__c>();
        final List<FS_Brandset__c> branset9000List=new List<FS_Brandset__c>();
        
        for(FS_Brandset__c branset :brandsetRecordList){
            if(branset.FS_Platform__c.contains(LIT7K)){ branset7000List.add(branset);}
            if(branset.FS_Platform__c.contains(LIT8K)){ branset8000List.add(branset);}
            if(branset.FS_Platform__c.contains(LIT9K)){ branset9000List.add(branset);}
        }
        
        List<Account> headQuarterCustomerList=[SELECT Id FROM Account WHERE RecordType.Name=:HQCUSTOMER limit 1];
        List<FS_Association_Brandset__c> brandsetsCollection=new List<FS_Association_Brandset__c>();
        brandsetsCollection.add(new FS_Association_Brandset__c(FS_Platform__c=LIT7K ,FS_Headquarters__c=headQuarterCustomerList.get(0).Id));
        brandsetsCollection.add(new FS_Association_Brandset__c(FS_Platform__c=LIT8K ,FS_Headquarters__c=headQuarterCustomerList.get(0).Id));
        brandsetsCollection.add(new FS_Association_Brandset__c(FS_Platform__c=LIT9K ,FS_Headquarters__c=headQuarterCustomerList.get(0).Id));
        insert brandsetsCollection;
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        system.runAs(sysAdminUser){
        Test.startTest();
        PageReference myVfPage = Page.FSdeleteDefaultBrandSetOverride;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('acc',headQuarterCustomerList.get(0).Id);
        ApexPages.currentPage().getParameters().put('id',brandsetsCollection.get(0).Id);
        ApexPages.StandardController standardController = new ApexPages.StandardController(new FS_Association_Brandset__c(Id=brandsetsCollection.get(0).Id));
        deleteDefaultBrandSetController controller = new deleteDefaultBrandSetController(standardController);
        controller.deleteBrandSet();
        Test.stopTest();  
        }
    }
}