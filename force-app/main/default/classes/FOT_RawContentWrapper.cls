/*******************************************************************
	Class: FOT_RawContentWrapper
	Description: FOT_RawContentWrapper is a Wrapper class for A5 API input.
	Added as part of FOT
	*********************************/
public class FOT_RawContentWrapper {
    
    public ArtifactValues artifact{get;set;}
    public FOT_RawContentWrapper(FS_Artifact__c artifactRec)
    {
        artifact=new ArtifactValues(artifactRec);
    }
    class ArtifactValues
    {
        public string id;
        public boolean enabled;
        public String name;
        public Integer rank;
        public String artifactType;
        public String dependancyArtifactType;
        public String deploymentGroupRule;
        public String ruleSet;
        public String rule;
        public String overideRule;
        public String version;
        public String uuid;
        public String s3Path;
        public String dependancyBreakVersion;
        public String dependancyMinVersion;
        public String settingsUpdate;
        
        ArtifactValues(FS_Artifact__c artifact)
        {
            FS_Artifact_Ruleset__c ruleSetRec=[SELECT id,Name FROM FS_Artifact_Ruleset__c where id=:artifact.FS_Ruleset__c];
            id=artifact.id;
            enabled=artifact.FS_Enabled__c;
            name=artifact.name;
            rank=artifact.FS_Rank__c.intvalue();
            artifactType=artifact.FS_Artifact_Type__c;
            dependancyArtifactType = artifact.FS_Dependency_Artifact_Type__c;
            deploymentGroupRule=artifact.FS_Deployment_Group_Rule__c;
           ruleSet=ruleSetRec.name;
           rule=artifact.FS_Rule__c;
            overideRule=artifact.FS_Overide_Group_Rule__c;
            version=artifact.FS_Version__c;
            uuid=artifact.FS_UUID__c;
            s3Path=artifact.FS_S3Path__c;
            dependancyBreakVersion=artifact.DependancyBreakVersion__c;
            dependancyMinVersion=artifact.FS_Dependency_M_in_Version__c;
            settingsUpdate=artifact.Settings_Update__c;
        }
    }
}