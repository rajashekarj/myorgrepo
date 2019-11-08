/***********************************************************************************************************
Name         : FOT_EditArtifactControllerTest
Created By   : Infosys Limited 
Created Date : 12-may-2017
Usage        : Test Class for FOT_EditArtifactController

***********************************************************************************************************/
@istest
public class FOT_EditArtifactControllerTest {
    
    @testsetup
    static void insertRecords()
    {
        final FS_Artifact_Ruleset__c ruleSet=new FS_Artifact_Ruleset__c();
        ruleSet.Name='SoftwareUS';
        insert ruleSet;
        
        final FS_Artifact__c artifactPublish=new FS_Artifact__c();
        artifactPublish.Name='ArtifactSample';
        artifactPublish.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Published').getRecordTypeId();
        artifactPublish.FS_Rank__c=1;
        artifactPublish.FS_Version__c='1.2';
        artifactPublish.FS_Ruleset__c=ruleSet.id;
        artifactPublish.FS_Artifact_Type__c='Bundle';
        artifactPublish.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        artifactPublish.FS_Rule__c='Platform=\'9000\'';
        artifactPublish.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        artifactPublish.FS_Enabled__c=false;
        artifactPublish.FS_Dependency_Artifact_Type__c='';
        artifactPublish.FS_Deployment_Group_Rule__c='';
        artifactPublish.FS_Overide_Group_Rule__c='';
        artifactPublish.FS_UUID__c='';
        artifactPublish.DependancyBreakVersion__c='';
        artifactPublish.FS_Dependency_M_in_Version__c='';
        artifactPublish.Settings_Update__c ='';
     
        insert artifactPublish;
           
       final FS_Artifact__c artifact=new FS_Artifact__c();
        artifact.Name='ArtifactSample';
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
        artifact.FS_Published_Artifact__c=artifactPublish.id;
        
        insert artifact;
    }
    @istest
    static void testMethod1()
    {
        test.startTest();
        String profileName;
        String rulesetLable;
        String rulesetfileContent = 'fileContent';
        String rulesetfileName = 'fileName';
        String returnUrlLink;
        String returnUrlLink1;
        List<String> picklistValues=new  List<String>();
        picklistValues=FOT_EditArtifactController.getArtifactTypeValues();
        system.assertNotEquals(0, picklistValues.size());
        
        picklistValues=FOT_EditArtifactController.getDependArtifactTypeValues();
        system.assertNotEquals(0, picklistValues.size());
        
        picklistValues=FOT_EditArtifactController.getSecondDependArtifactTypeValues();
        system.assertNotEquals(0, picklistValues.size());
        
        profileName=FOT_EditArtifactController.userProfileAccess();
        
        rulesetLable=FOT_EditArtifactController.actionLabel();
        
        Test.setMock(HttpCalloutMock.class, new FOT_ArtifactValidationWebServiceResMock(200));
        returnUrlLink=FOT_EditArtifactController.uploadRuleToAWS_S3(rulesetfileContent,rulesetfileName);
        //system.assertEquals('https://ccfs-fleet-managment-qa.s3.amazonaws.com/ArtifactRules/fileName', returnUrlLink);
        
        returnUrlLink1=FOT_EditArtifactController.viewRuleFileFromAWS_S3(rulesetfileName);
        
        test.stopTest();
    }
    @istest
    static void testmethod2()
    {
        test.startTest();
        final FS_Artifact__c artifact=[select Name,id,FS_Published_Artifact__c,Settings_Update__c,FS_Dependency_M_in_Version__c,DependancyBreakVersion__c,FS_UUID__c,FS_Overide_Group_Rule__c,FS_Enabled__c,FS_Dependency_Artifact_Type__c,FS_Rank__c,FS_Version__c,FS_Ruleset__c,FS_Artifact_Type__c,FS_Deployment_Group_Rule__c,FS_Rule__c,FS_S3Path__c from FS_Artifact__c where recordType.name='Dry Run' and Name='ArtifactSample'];
        final FS_Artifact__c artifactPubl=[select Name,id,FS_Published_Artifact__c,FS_Enabled__c from FS_Artifact__c where recordType.name='Published' and Name='ArtifactSample'];
        final FS_Artifact_Ruleset__c ruleSetTest=[select id from FS_Artifact_Ruleset__c where name='SoftwareUS'];
        
        boolean delCheck;
        String recordType;
        boolean deleteSuccess;
        Id publishAT;
        boolean isActive;
    
        recordType=FOT_EditArtifactController.actionRTArtifact(artifact.Id);
        system.assertEquals('Dry Run', recordType);
        recordType=FOT_EditArtifactController.actionRTArtifact(ruleSetTest.Id);//to cover QueryException
        
        publishAT=FOT_EditArtifactController.actionPublishArtifact(artifact.Id);
        publishAT=FOT_EditArtifactController.actionPublishArtifact(artifactPubl.Id);
        publishAT=FOT_EditArtifactController.actionPublishArtifact(ruleSetTest.Id);//to cover QueryException
        
        final FS_Artifact__c atRec=FOT_EditArtifactController.recordDetails(artifact.Id);
    
        final FS_Artifact__c artifact1=FOT_EditArtifactController.updateArtifact(artifact,true);
      
         Test.setMock(HttpCalloutMock.class, new FOT_ArtifactValidationWebServiceResMock(200));
        final FOT_ResponseClass resp=FOT_EditArtifactController.actionWebCall(artifact);
        
        delCheck=FOT_EditArtifactController.checkDelete(artifact.Id);
        delCheck=FOT_EditArtifactController.checkDelete(artifactPubl.Id);
        artifact.FS_Published_Artifact__c=null;
        update artifact;
        delCheck=FOT_EditArtifactController.checkDelete(artifact.Id);
        delCheck=FOT_EditArtifactController.checkDelete(ruleSetTest.Id);//to cover QueryException
        
        artifactPubl.FS_Enabled__c=true;
        update artifactPubl;
        isActive=FOT_EditArtifactController.actionPublishActive(artifactPubl.id);
        isActive=FOT_EditArtifactController.actionPublishActive(ruleSetTest.id);//to cover QueryException
        
        deleteSuccess=FOT_EditArtifactController.deleteArtifact(artifact.Id);
        system.assertEquals(true, deleteSuccess);
        deleteSuccess=FOT_EditArtifactController.deleteArtifact(ruleSetTest.Id);//to cover QueryException
        test.stopTest();
    }
}