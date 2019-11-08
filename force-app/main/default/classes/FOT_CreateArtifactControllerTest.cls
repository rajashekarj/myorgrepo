/*********************************************************************************************************
Name         : FOT_CreateArtifactControllerTest
Created By   : Infosys Limited 
Created Date : 12-may-2017
Usage        : Test Class for FOT_CreateArtifactController

***********************************************************************************************************/
@istest
public class FOT_CreateArtifactControllerTest {
    @testsetup
    static void insertArtifact()
    {
        final FS_Artifact_Ruleset__c ruleSet=new FS_Artifact_Ruleset__c();
        ruleSet.Name='TestRulesetTrigger';
        insert ruleSet;
        
        List<FS_Artifact__c> artiPublishList=new  List<FS_Artifact__c>();
        
        final FS_Artifact__c artiPublish1=new FS_Artifact__c();
        artiPublish1.Name='sampleTestv1';
        artiPublish1.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Published').getRecordTypeId();
        artiPublish1.FS_Rank__c=1;
        artiPublish1.FS_Version__c='2.2';
        artiPublish1.FS_Ruleset__c=ruleSet.id;
        artiPublish1.FS_Artifact_Type__c='Bundle';
        artiPublish1.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        artiPublish1.FS_Rule__c='Platform=\'9000\'';
        artiPublish1.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        artiPublish1.FS_Enabled__c=false;
        artiPublish1.FS_Dependency_Artifact_Type__c='';
        artiPublish1.FS_Deployment_Group_Rule__c='';
        artiPublish1.FS_Overide_Group_Rule__c='';
        artiPublish1.FS_UUID__c='';
        artiPublish1.DependancyBreakVersion__c='';
        artiPublish1.FS_Dependency_M_in_Version__c='';
        artiPublish1.Settings_Update__c ='';
        artiPublishList.add(artiPublish1);
        
        final FS_Artifact__c artiPublish2=new FS_Artifact__c();
        artiPublish2.Name='sampleTestv2';
        artiPublish2.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Published').getRecordTypeId();
        artiPublish2.FS_Rank__c=2;
        artiPublish2.FS_Version__c='2.2';
        artiPublish2.FS_Ruleset__c=ruleSet.id;
        artiPublish2.FS_Artifact_Type__c='Bundle';
        artiPublish2.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        artiPublish2.FS_Rule__c='Platform=\'9000\'';
        artiPublish2.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        artiPublish2.FS_Enabled__c=true;
        artiPublish2.FS_Dependency_Artifact_Type__c='';
        artiPublish2.FS_Deployment_Group_Rule__c='';
        artiPublish2.FS_Overide_Group_Rule__c='';
        artiPublish2.FS_UUID__c='';
        artiPublish2.DependancyBreakVersion__c='';
        artiPublish2.FS_Dependency_M_in_Version__c='';
        artiPublish2.Settings_Update__c ='';
        artiPublishList.add(artiPublish2);
        
        insert artiPublishList;
        
        final List<FS_Artifact__c> artiDryRun=new List<FS_Artifact__c>();
        final FS_Artifact__c arti=new FS_Artifact__c();
        arti.Name='sampleTestv1';
        arti.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Dry Run').getRecordTypeId();
        arti.FS_Rank__c=1;
        arti.FS_Version__c='2.2';
        arti.FS_Ruleset__c=ruleSet.id;
        arti.FS_Artifact_Type__c='Bundle';
        arti.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        arti.FS_Rule__c='Platform=\'9000\'';
        arti.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        arti.FS_Enabled__c=false;
        arti.FS_Dependency_Artifact_Type__c='';
        arti.FS_Deployment_Group_Rule__c='';
        arti.FS_Overide_Group_Rule__c='';
        arti.FS_UUID__c='';
        arti.DependancyBreakVersion__c='';
        arti.FS_Dependency_M_in_Version__c='';
        arti.Settings_Update__c ='';
        arti.FS_Published_Artifact__c= artiPublish1.Id;
        artiDryRun.add(arti);
        
        final FS_Artifact__c arti2=new FS_Artifact__c();
        arti2.Name='sampleTestv11';
        arti2.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Dry Run').getRecordTypeId();
        arti2.FS_Rank__c=1;
        arti2.FS_Version__c='2.2';
        arti2.FS_Ruleset__c=ruleSet.id;
        arti2.FS_Artifact_Type__c='Bundle';
        arti2.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        arti2.FS_Rule__c='Platform=\'9000\'';
        arti2.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        arti2.FS_Enabled__c=false;
        arti2.FS_Dependency_Artifact_Type__c='';
        arti2.FS_Deployment_Group_Rule__c='';
        arti2.FS_Overide_Group_Rule__c='';
        arti2.FS_UUID__c='';
        arti2.DependancyBreakVersion__c='';
        arti2.FS_Dependency_M_in_Version__c='';
        arti2.Settings_Update__c ='';
        arti2.FS_Published_Artifact__c= artiPublish1.Id;
        artiDryRun.add(arti2);
        
        final FS_Artifact__c arti1=new FS_Artifact__c();
        arti1.Name='sampleTestv2';
        arti1.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Dry Run').getRecordTypeId();
        arti1.FS_Rank__c=2;
        arti1.FS_Version__c='2.2';
        arti1.FS_Ruleset__c=ruleSet.id;
        arti1.FS_Artifact_Type__c='Bundle';
        arti1.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        arti1.FS_Rule__c='Platform=\'9000\'';
        arti1.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        arti1.FS_Enabled__c=true;
        arti1.FS_Dependency_Artifact_Type__c='';
        arti1.FS_Deployment_Group_Rule__c='';
        arti1.FS_Overide_Group_Rule__c='';
        arti1.FS_UUID__c='';
        arti1.DependancyBreakVersion__c='';
        arti1.FS_Dependency_M_in_Version__c='';
        arti1.Settings_Update__c ='';
        arti1.FS_Published_Artifact__c= artiPublish2.Id; 
        artiDryRun.add(arti1);
        insert artiDryRun;
        
    }
    @istest
    static void testPicklistVal()
    {
        test.startTest();
        List<String> picklist=new List<String>();
        String ruleLabel;
        
        picklist= FOT_CreateArtifactController.ArtifactTypeList();
        system.assertNotEquals(0, picklist.size());
        
        picklist= FOT_CreateArtifactController.dependArtifactTypeList();
        system.assertNotEquals(0, picklist.size());
        
        picklist=FOT_CreateArtifactController.secDependArtifactTypeList();
        system.assertNotEquals(0, picklist.size());
        
        ruleLabel=FOT_CreateArtifactController.actionLabel();
        
        test.stopTest();
    }
    @istest
    static void testSuccess()
    {
        test.startTest();
        String atType;
        
        final FS_Artifact_Ruleset__c ruleSet=new FS_Artifact_Ruleset__c();
        ruleSet.Name='TestRuleset';
        ruleSet.Last_Simulation_Status__c='In progress';
        ruleSet.Last_Promote_Status__c='In progress';
        insert ruleSet;
        
        final FS_Artifact__c arti=new FS_Artifact__c();
        arti.Name='sampleTest';
        arti.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Dry Run').getRecordTypeId();
        arti.FS_Rank__c=4;
        arti.FS_Version__c='2.2';
        arti.FS_Ruleset__c=ruleSet.id;
        arti.FS_Artifact_Type__c='Bundle';
        arti.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        arti.FS_Rule__c='Platform=\'9000\'';
        arti.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        arti.FS_Enabled__c=true;
        arti.FS_Dependency_Artifact_Type__c='';
        arti.FS_Deployment_Group_Rule__c='';
        arti.FS_Overide_Group_Rule__c='';
        arti.FS_UUID__c='';
        arti.DependancyBreakVersion__c='';
        arti.FS_Dependency_M_in_Version__c='';
        arti.Settings_Update__c ='';
        Id atId;
        
        atId=FOT_CreateArtifactController.saveArtifact(arti);
        
        atType=FOT_CreateArtifactController.actionArtifactType(ruleSet.Id);
        system.assertEquals('Bundle', atType);
        
        Test.setMock(HttpCalloutMock.class, new FOT_ArtifactValidationWebServiceResMock(200));
        final FOT_ResponseClass resp=FOT_CreateArtifactController.actionWebCallout(arti);
        
        
        test.stopTest();
    }

    @istest
    static void testArtifactRulesetTriggerUpdate()
    {
        test.startTest();
        final FS_Artifact__c arti=[select fs_rank__c from FS_Artifact__c where name='sampleTestv1' and recordType.name='Dry Run'];
        arti.fs_rank__c=5;
        arti.FS_Enabled__c=false;
        update arti;
        final FS_Artifact_Ruleset__c rule=[select id from FS_Artifact_Ruleset__c where name='TestRulesetTrigger'];
        
        
        final FS_Artifact_Ruleset__c ruleSet=new FS_Artifact_Ruleset__c();
        ruleSet.Name='TestRulesetTrigger';
        try
        {
            insert ruleSet;
        }
        catch(DmlException e)
        {
            system.assertEquals(true,e.getMessage().contains('Ruleset Name already exists, please enter different Ruleset Name.'));  
        }
        try
        {
            delete rule;
        }
        catch(DmlException e)
        {
            system.assertEquals(true,e.getMessage().contains('Can\'t delete the Ruleset as there are active artifacts associated to it.')); 
        }
        test.stopTest();
    }
        
    @istest
    static void testArtifactTriggerDelete()
    {
        test.startTest();
        List<FS_Artifact__c> arti=[select fs_rank__c from FS_Artifact__c where recordtype.name='Dry Run' and Name='sampleTestv1'];
        delete arti;
        
        test.stopTest();
    }
    
    @isTest
    static void getRulesetTest()
    {
        FS_Artifact_Ruleset__c testRuleset = FOT_CreateArtifactController.getRuleset();
    }
    
    /*
    @isTest
     static void testAttachments()
    {
        final FS_Artifact_Ruleset__c ruleSet1=new FS_Artifact_Ruleset__c();
        ruleSet1.Name='TestRulesetTrigger1';
        insert ruleSet1;
        
       // List<FS_Artifact__c> artiPublishList=new  List<FS_Artifact__c>();
        
        final FS_Artifact__c artiPublish1=new FS_Artifact__c();
        artiPublish1.Name='sampleTestv1';
        artiPublish1.RecordTypeId=Schema.SObjectType.FS_Artifact__c.getRecordTypeInfosByName().get('Published').getRecordTypeId();
        artiPublish1.FS_Rank__c=1;
        artiPublish1.FS_Version__c='2.2';
        artiPublish1.FS_Ruleset__c=ruleSet1.id;
        artiPublish1.FS_Artifact_Type__c='Bundle';
        artiPublish1.FS_Deployment_Group_Rule__c='Platform=\'9000\'';
        artiPublish1.FS_Rule__c='Platform=\'9000\'';
        artiPublish1.FS_S3Path__c='packages/bundles/9100/Onlyfortesting_2.pkg';
        artiPublish1.FS_Enabled__c=false;
        artiPublish1.FS_Dependency_Artifact_Type__c='';
        artiPublish1.FS_Deployment_Group_Rule__c='';
        artiPublish1.FS_Overide_Group_Rule__c='';
        artiPublish1.FS_UUID__c='';
        artiPublish1.DependancyBreakVersion__c='';
        artiPublish1.FS_Dependency_M_in_Version__c='';
        artiPublish1.Settings_Update__c ='';
        insert artiPublish1;
     
     //   FOT_CreateArtifactController controller=new FOT_CreateArtifactController();
 
        String fileName='Unit Test Attachment';
        String fileContent='arsfdghj';
      //  controller.fileBody=Blob.valueOf('Unit Test Attachment Body
        string urlii = FOT_CreateArtifactController.uploadRuleToAWS_S3(fileContent,fileName);
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:artiPublish1.id];
        System.assertEquals(1, attachments.size());
    } */
}