/*=================================================================================================================
* Date         : 01-01-2019
* Developer    : Goutham Rapolu
* Purpose      : Test class for FSUploadFileController which will handle Upload Documents to File Object.
*=================================================================================================================
*                                 Update History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 01-01-2019 | Goutham Rapolu |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/

@isTest
public class FSUploadFileController_Test {
    public static final String FILENAME ='Unit Test Attachment Body';
    public static final String LINKEDFILENAME = 'Unit Test Attachment Body for already linked';
    public Static Id recTypeHQ = FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Headquarters');
    public static final String RETURL = 'RetURL';
    public static final string PARENTID = 'Recid';
    public static final string ACCRECORDTYPE = 'FS Headquarters';
    public static final string NULLVALUE = 'null';  
    public static final string SHARETYPE = 'V';
    
    private static testMethod void testUploadFile(){
        //Create FS Headquarters Customer
        final List<Account> hqCustList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,ACCRECORDTYPE));
        //Create User
        final User sysAdmin=FSTestUtil.createUser(null, 1,FSConstants.USER_POFILE_SYSADMIN, true);
        system.runAs(sysAdmin){
            Test.startTest();
            final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
            final PageReference pageRef = Page.FSUploadFile;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put(PARENTID, parentRecord.id);
            ApexPages.currentPage().getParameters().put(RETURL, NULLVALUE);
            FSUploadFileController controller = new FSUploadFileController();
            
            //Upload File
            controller.fName = FILENAME;
            controller.file = Blob.valueOf(FILENAME);
            controller.upload();
            
            Test.stopTest();
        }    
    }
    
    private static testMethod void testUploadFile2(){
        //Create FS Headquarters Customer
        final List<Account> hqCustList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,ACCRECORDTYPE));
        //Create User
        final User sysAdmin=FSTestUtil.createUser(null, 1,FSConstants.USER_POFILE_SYSADMIN, true);
        system.runAs(sysAdmin){
            Test.startTest();
            final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ  limit 1];
            final PageReference pageRef = Page.FSUploadFile;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put(PARENTID, parentRecord.id);
            ApexPages.currentPage().getParameters().put(RETURL, NULLVALUE);
            FSUploadFileController controller = new FSUploadFileController();
            controller.upload();
            
            //create ContentVersion  record 
            ContentVersion cv=new Contentversion();
            cv.title= LINKEDFILENAME;
            cv.PathOnClient = LINKEDFILENAME;
            cv.versiondata=EncodingUtil.base64Decode(LINKEDFILENAME);
            insert cv;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = parentRecord.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = SHARETYPE;
            insert cdl;
            
            //Upload File
            controller.fName = FILENAME;
            controller.file = Blob.valueOf(FILENAME);
            controller.upload();
            Test.stopTest();
        }
    }
}