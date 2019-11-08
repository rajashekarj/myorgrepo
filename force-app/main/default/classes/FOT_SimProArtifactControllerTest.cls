/***********************************************************************************************************
Name         : FOT_SimProArtifactControllerTest
Created By   : Infosys Limited 
Created Date : 12-may-2017
Usage        : Test Class for FOT_SimProArtifactController

***********************************************************************************************************/
@istest
public class FOT_SimProArtifactControllerTest {

     @testsetup
    static void insertRecords()
    {
        FS_Artifact_Ruleset__c ruleSet=new FS_Artifact_Ruleset__c();
        ruleSet.Name='SoftwareUSTest';
        insert ruleSet;
        
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
      
        insert artifact;
    }
    @istest
    static void testSuccessSimPro()
    {
        FS_Artifact_Ruleset__c rule=[Select id,Name,Last_Promote_Status__c,Last_Promote_Updated__c,Last_Simulation_Status__c,Last_Simulation_Updated__c from FS_Artifact_Ruleset__c where name='SoftwareUSTest'];
        FS_Artifact__c arti=[select id from FS_Artifact__c where Name='ArtifactSample'];
        FS_Artifact_Ruleset__c rulseSet=FOT_SimProArtifactController.recordDetails(rule.id);
        FS_Artifact_Ruleset__c rulseSet1=FOT_SimProArtifactController.recordDetails(arti.id);//to cover Query Exception
        
        String hashcode='1686623723';
        String ruleName=FOT_SimProArtifactController.getRuleSetName(rule.id);
        String ruleNameTest=FOT_SimProArtifactController.getRuleSetName(arti.id);//to cover Query Exception
        
        String profile=FOT_SimProArtifactController.userProfileAccess();
        
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetSimulateMock(200));
        String simulateStatus=FOT_SimProArtifactController.simulateRuleset(rule.id);
        
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetPromoteMock(200));
        FOT_ResponseClass resp=FOT_SimProArtifactController.promoteRuleset(rule.id);
        
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetPromoteMock(200));
        String promote=FOT_SimProArtifactController.finalPromote(rule.name,hashcode,rule.id);//to cover Query Exception
        
        Map<String,Boolean> ruleSetMap=FOT_SimProArtifactController.recordArifactDetails(rule.id);
        Map<String,Boolean> ruleSetTestMap=FOT_SimProArtifactController.recordArifactDetails(arti.id);
    }
}