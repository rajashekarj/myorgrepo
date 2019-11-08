/***********************************************************************************************************
Name         : FOT_SimProRulesetTest
Created By   : Infosys Limited 
Created Date : 12-may-2017
Usage        : Test Class for FOT_SimProRuleset

***********************************************************************************************************/
@isTest
public class FOT_SimProRulesetTest {
    
    @testsetup
    static void insertRuleset()
    {
        FS_Artifact_Ruleset__c ruleSet=new FS_Artifact_Ruleset__c();
        ruleSet.Name='Test_Ruleset1';
        insert ruleSet;
         FS_Artifact_Ruleset__c ruleSet2=new FS_Artifact_Ruleset__c();
        ruleSet2.Name='Test_Ruleset2';
        insert ruleSet2;
    }
    
    @istest
    static void testCalloutSimulate()
    {
        String response;
        test.startTest();
        FS_Artifact_Ruleset__c ruleSet=[select Name from FS_Artifact_Ruleset__c where name='Test_Ruleset1'];
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetSimulateMock(400));
        response=FOT_SimProRuleset.rulesetSimulate(ruleSet);
         Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetSimulateMock(200));
        response=FOT_SimProRuleset.rulesetSimulate(ruleSet);
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetSimulateMock(500));
        response=FOT_SimProRuleset.rulesetSimulate(ruleSet);
        test.stopTest();
    }
       @istest
    static void testCalloutSimulate1()
    {
        String response;
        test.startTest();
        FS_Artifact_Ruleset__c ruleSet=[select Name from FS_Artifact_Ruleset__c where name='Test_Ruleset1'];
      
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetSimulateMock(500));
        response=FOT_SimProRuleset.rulesetSimulate(ruleSet);
        test.stopTest();
    }
    @istest
    static void testCalloutPromote()
    {
        String hashCode='375130806';
        String returnVal;
        test.startTest();
        FS_Artifact_Ruleset__c ruleSet=[select Name from FS_Artifact_Ruleset__c where name='Test_Ruleset2'];
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetPromoteMock(200));
        FOT_ResponseClass resp = FOT_SimProRuleset.rulesetPromote(ruleSet);
        
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetPromoteMock(400));
        FOT_ResponseClass responseError = FOT_SimProRuleset.rulesetPromote(ruleSet);
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetPromoteMock(200));
        returnVal = FOT_SimProRuleset.finalPromote(ruleSet.Name,hashCode,ruleSet);
        //system.assertEquals(true, returnVal);
        test.stopTest();
    }
      @istest
    static void testCalloutPromote3()
    {
        String hashCode='375130806';
        String returnVal;
        test.startTest();
        FS_Artifact_Ruleset__c ruleSet=[select Name from FS_Artifact_Ruleset__c where name='Test_Ruleset2'];
      
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetPromoteMock(200));
        returnVal = FOT_SimProRuleset.finalPromote(ruleSet.Name,hashCode,ruleSet);
        //system.assertEquals(true, returnVal);
        test.stopTest();
    }
      @istest
    static void testCalloutPromote1()
    {
        String hashCode='375130806';
        String returnVal;
        test.startTest();
        FS_Artifact_Ruleset__c ruleSet=[select Name from FS_Artifact_Ruleset__c where name='Test_Ruleset2'];
     
        
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetPromoteMock(400));
        FOT_ResponseClass responseError = FOT_SimProRuleset.rulesetPromote(ruleSet);
		 returnVal = FOT_SimProRuleset.finalPromote(ruleSet.Name,hashCode,ruleSet);
        //system.assertEquals(true, returnVal);
        test.stopTest();
    }
        @istest
    static void testCalloutPromote2()
    {
        String hashCode='375130806'; 
        String returnVal;
        test.startTest();
        FS_Artifact_Ruleset__c ruleSet=[select Name from FS_Artifact_Ruleset__c where name='Test_Ruleset2'];
     
        
        Test.setMock(HttpCalloutMock.class, new FOT_SimProRulesetPromoteMock(500));
        FOT_ResponseClass responseError = FOT_SimProRuleset.rulesetPromote(ruleSet);
		 returnVal = FOT_SimProRuleset.finalPromote(ruleSet.Name,hashCode,ruleSet);
        //system.assertEquals(true, returnVal);
        test.stopTest();
    }
}