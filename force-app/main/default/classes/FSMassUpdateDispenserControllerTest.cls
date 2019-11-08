/**
  * Test class for FSMassUpdateOutletDispenserController 
  */
@isTest
private class FSMassUpdateDispenserControllerTest{
	
    public static PageReference pageRef;
    public static List<FS_Outlet_Dispenser__c> createdDispensers;
    public static FSMassUpdateOutletDispenserController controller;
    public static List<FS_WorkBook_Holder__c> parentHolder;
    public static Attachment file;
    
    private static testMethod void testFileUpload(){
        
        pageRef = Page.FSMassUpdateOutletDispenserPage;
        Test.setCurrentPage(pageRef);
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            
            Test.startTest();
            createdDispensers=[SELECT Id,FS_Equip_Type__c,FS_Serial_Number2__c,FS_IsActive__c,FS_ACN_NBR__c FROM FS_Outlet_Dispenser__c LIMIT 100];
            
            controller = new FSMassUpdateOutletDispenserController();
            controller.csvFileBody=FSTestFactory.createValidCSVBlobForPostInstallAttributes(createdDispensers);  
            controller.csvFileName ='Dispenser WorkBook.csv';
            
            //user uploads the file
            controller.uploadFile();
            
            parentHolder=[SELECT Id,Name FROM FS_WorkBook_Holder__c
                          WHERE FS_WorkBook_Name__c='Dispenser WorkBook' limit 1];
            //verify parent record got created
            system.assert(!parentHolder.isEmpty());
            
            //verify Attachement got created 
            file=[SELECT Id,Body,Name from Attachment where parentId=:parentHolder.get(0).Id
                  ORDER BY  createdDate DESC limit 1];
            system.assert(file.Body!=null);   
            
            //Verify success Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.Info), 'File Uploaded Successfully');               
            Test.stopTest();
        }
    }
    
    private static testMethod void testFileUploadException(){
        
        pageRef = Page.FSMassUpdateOutletDispenserPage;
        Test.setCurrentPage(pageRef);
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            
            Test.startTest();
            createdDispensers=[SELECT Id,FS_Equip_Type__c,FS_Serial_Number2__c,FS_IsActive__c,FS_ACN_NBR__c FROM FS_Outlet_Dispenser__c LIMIT 100];
            controller = new FSMassUpdateOutletDispenserController();
            controller.csvFileBody=FSTestFactory.createValidCSVBlobForPostInstallAttributes(createdDispensers);  
            
            //user uploads the file
            controller.uploadFile();
            
            //Verify success Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.Error), 'Error while uploading file.');                   
            Test.stopTest();
        }
    }
    
    
    private static testMethod void testFileUploadAndCallBatch(){
        
        pageRef = Page.FSMassUpdateOutletDispenserPage;
        Test.setCurrentPage(pageRef);
        createdDispensers=[SELECT Id,FS_Equip_Type__c,FS_Serial_Number2__c,FS_IsActive__c,FS_ACN_NBR__c FROM FS_Outlet_Dispenser__c LIMIT 100];
        
        controller = new FSMassUpdateOutletDispenserController();
        controller.csvFileBody=FSTestFactory.createValidCSVBlobForPostInstallAttributes(createdDispensers);  
        controller.csvFileName ='Dispenser WorkBook.csv';
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){  
            //user uploads the file
            controller.uploadFile();
            
            parentHolder=[SELECT Id,Name FROM FS_WorkBook_Holder__c
                          WHERE FS_WorkBook_Name__c='Dispenser WorkBook' limit 1];
            //verify parent record got created
            system.assert(!parentHolder.isEmpty());
            
            //verify Attachement got created 
            file=[SELECT Id,Body,Name from Attachment where parentId=:parentHolder.get(0).Id
                  ORDER BY  createdDate DESC limit 1];
            system.assert(file.Body!=null);
            
            //Verify success Message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.Info), 'File Uploaded Successfully'); 
            
            
            
            Test.startTest();
            final Pagereference pageRefUrl=controller.callBatch();
            //verify batch started
            system.assert(controller.batchJobId!=null);
            
            //verify page refresh
            system.assert(pageRefUrl.getUrl().containsIgnoreCase('/apex/FSMassUpdateOutletDispenserPage'));                  
            Test.stopTest();
        }
        
    }
    
    private static testMethod void testFileUploadExecptionCatch(){
        pageRef = Page.FSMassUpdateOutletDispenserPage;
        Test.setCurrentPage(pageRef);
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        System.runAs(sysAdminUser){
            
            Test.startTest();
            controller = new FSMassUpdateOutletDispenserController();
            controller.csvFileName ='Dispenser WorkBook.csv';  
            controller.uploadFile();
            //verify error message
            system.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.ERROR));
            Test.stopTest();
        }
    }
}