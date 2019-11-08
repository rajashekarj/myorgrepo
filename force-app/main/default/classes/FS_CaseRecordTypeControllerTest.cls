/*********************************************************************************************************
Apex Class Name     : FS_CaseRecordTypeControllerTest
Function            : This test class is created for class FS_CaseRecordTypeController
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* BhargavD	          09/10/2019       This class is a test class for FS_CaseRecordTypeController
									   
***********************************************************************************************************/

@isTest(SeeAllData=false)
private with sharing class FS_CaseRecordTypeControllerTest {
    
public static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Linkage Management').getRecordTypeId();
    
         @testSetup
        public static void dataSetup()
        {
            User userRecord = new User();
            userRecord.LastName='Testuser';
            userRecord.Alias='testuser';
            userRecord.Email='abc@defq.com';
            userRecord.Username='fssupport@test.com';
            userRecord.TimeZoneSidKey='America/Los_Angeles';
            profile id1=[select id from profile where name='FS_FACT_BAST_P'];
            userRecord.ProfileId=id1.id;
            userRecord.LocaleSidKey='en_US';
            userRecord.EmailEncodingKey='ISO-8859-1';
            userRecord.LanguageLocaleKey='en_US';
            insert userRecord;
        }
    static testmethod void getRecordTypeTest(){
         User testuser = [select id from User where Email='abc@defq.com'];
         system.runAs(testuser)
        	{  
        List<RecordType> recordTypes = New List<RecordType>();
        Test.startTest();
        RecordTypes = FS_CaseRecordTypeController.getCaseRecordTypeList();
        System.debug('********* retrieved RecordTypes ********* : ' + RecordTypes);
        Test.stopTest();
        system.assert(RecordTypes!=NULL);
            }
    }
    
    static testmethod void getListviewTest(){
        User testuser = [select id from User where Email='abc@defq.com'];
        system.runAs(testuser)
        {  
            List<ListView> listView = New List<ListView>();
            Test.startTest();
            ListView = FS_CaseRecordTypeController.getCaseListViewID();
            System.debug('********* retrieved ListView ********* : ' + ListView);
            Test.stopTest();
            system.assert(ListView!=NULL);
        }
        
    }
}