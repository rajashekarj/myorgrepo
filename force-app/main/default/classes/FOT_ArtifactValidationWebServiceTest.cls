/*********************************************************************************************************
Name         : FOT_ArtifactValidationWebServiceTest
Created By   : Infosys Limited 
Created Date : 12-may-2017
Usage        : Test Class for FOT_ArtifactValidationWebService

***********************************************************************************************************/
@isTest
public class FOT_ArtifactValidationWebServiceTest {
    @testsetup
    static void insertRecords()
    {
        FS_Artifact_Ruleset__c ruleSet=new FS_Artifact_Ruleset__c();
        ruleSet.Name='Test_Ruleset';
        insert ruleSet;
        
        FS_Artifact__c artifact=new FS_Artifact__c();
        artifact.Name='testArtifact';
        artifact.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Dry Run').getRecordTypeId();
        artifact.FS_Rank__c=1;
        artifact.FS_Version__c='1.2';
        artifact.FS_Ruleset__c=ruleSet.id;
        artifact.FS_Artifact_Type__c='Bundle';
        artifact.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        artifact.FS_Rule__c='Platform=\'9000\'';
        artifact.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        artifact.FS_Enabled__c=false;
        artifact.FS_Dependency_Artifact_Type__c='';
        artifact.FS_Deployment_Group_Rule__c='';
        artifact.FS_Overide_Group_Rule__c='';
        artifact.FS_UUID__c='';
        artifact.DependancyBreakVersion__c='';
        artifact.FS_Dependency_M_in_Version__c='';
        artifact.Settings_Update__c ='';
        insert artifact;
    }
    @isTest
    static void testValidationCalloutSuccess()
    {
        test.startTest();
        FOT_ResponseClass response3=new FOT_ResponseClass();
        FS_Artifact__c artifact=[select Name,id,RecordTypeId,Settings_Update__c,FS_Dependency_M_in_Version__c,DependancyBreakVersion__c,FS_UUID__c,FS_Overide_Group_Rule__c,FS_Enabled__c,FS_Dependency_Artifact_Type__c,FS_Rank__c,FS_Version__c,FS_Ruleset__c,FS_Artifact_Type__c,FS_Deployment_Group_Rule__c,FS_Rule__c,FS_S3Path__c from FS_Artifact__c limit 1];
        Test.setMock(HttpCalloutMock.class, new FOT_ArtifactValidationWebServiceResMock(200));
        FOT_ResponseClass response = FOT_ArtifactValidationWebService.getArtifactValidation(artifact);
        Test.setMock(HttpCalloutMock.class, new FOT_ArtifactValidationWebServiceResMock(400));
        FOT_ResponseClass response1 = FOT_ArtifactValidationWebService.getArtifactValidation(artifact);
        system.assertEquals(true, response1.message.contains('API error '));
        test.stopTest();
    }
    
    
    @isTest
    static void testValidationCalloutExcep()
    {
        test.startTest();
        FS_Artifact__c artifact=[select Name,Settings_Update__c,id,RecordTypeId,FS_Dependency_M_in_Version__c,DependancyBreakVersion__c,FS_UUID__c,FS_Overide_Group_Rule__c,FS_Enabled__c,FS_Dependency_Artifact_Type__c,FS_Rank__c,FS_Version__c,FS_Ruleset__c,FS_Artifact_Type__c,FS_Deployment_Group_Rule__c,FS_Rule__c,FS_S3Path__c from FS_Artifact__c ];
        Test.setMock(HttpCalloutMock.class, new FOT_ArtifactValidationWebServiceResMock(200));
        FOT_ResponseClass response = FOT_ArtifactValidationWebService.getArtifactValidation(artifact);  
        test.stopTest();
    }
    @isTest
    static void testValidationCalloutExcepFail()
    {
        test.startTest();
        FS_Artifact__c artifact=[select Name,Settings_Update__c,id,RecordTypeId,FS_Dependency_M_in_Version__c,DependancyBreakVersion__c,FS_UUID__c,FS_Overide_Group_Rule__c,FS_Enabled__c,FS_Dependency_Artifact_Type__c,FS_Rank__c,FS_Version__c,FS_Ruleset__c,FS_Artifact_Type__c,FS_Deployment_Group_Rule__c,FS_Rule__c,FS_S3Path__c from FS_Artifact__c ];
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMockFailure());
        FOT_ResponseClass response = FOT_ArtifactValidationWebService.getArtifactValidation(artifact);  
        test.stopTest();
        
    }
}