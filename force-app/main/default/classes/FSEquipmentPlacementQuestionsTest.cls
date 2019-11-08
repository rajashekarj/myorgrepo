@isTest
public  class FSEquipmentPlacementQuestionsTest {
    static Account accchain,accHQ,accOutlet;
    static FS_Execution_Plan__c executionPlan;
    static String recTypeEP=Schema.SObjectType.FS_Execution_Plan__c.getRecordTypeInfosByName().get(FSConstants.EXECUTIONPLAN).getRecordTypeId() ;
    Static void createtestData(){
        
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);     
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,true);
        
    }
    Static testMethod void fsEquipmentPlacementQuestionsTest(){
        createtestData();
        
        executionPlan=new FS_Execution_Plan__c();
        executionPlan.FS_Headquarters__c= accHQ.Id;
        executionPlan.recordtypeid=recTypeEP;
        Test.startTest();
        insert executionPlan;
        
        FS_Equipment_Placement_Questionnaire__c equipmentCustomSetting=new FS_Equipment_Placement_Questionnaire__c();
        equipmentCustomSetting.name='1';
        equipmentCustomSetting.Field_API_Mapping__c='FS_What_type_of_install_is_this__c';
        equipmentCustomSetting.Question_Label__c='What type of install is this?';
        insert equipmentCustomSetting;
        FS_Equipment_Placement_Questionnaire__c equipmentCustomSetting2=new FS_Equipment_Placement_Questionnaire__c();
        equipmentCustomSetting2.name='2';
        equipmentCustomSetting2.Field_API_Mapping__c='FS_What_type_of_beverage_station_is_this__c';
        equipmentCustomSetting2.Question_Label__c='What type of beverage station is this?';
        insert equipmentCustomSetting2;
        
        ApexPages.StandardController controller=new ApexPages.StandardController(executionPlan);
        FSEquipmentPlacementQuestionsCTRL fsEqipQues= new FSEquipmentPlacementQuestionsCTRL(controller);
        fsEqipQues.Save();
        fsEqipQues.Edit();
        fsEqipQues.cancel();
        fsEqipQues.setAllNotApplicable();
        Test.stopTest();
    }
    
    Static testMethod void fsEquipmentPlacementQuestionsTestNegative(){
        createtestData();
        
        executionPlan=new FS_Execution_Plan__c();
        executionPlan.FS_Headquarters__c= accHQ.Id;
        executionPlan.recordtypeid=recTypeEP;
        Test.startTest();
        insert executionPlan;
        
        FS_Equipment_Placement_Questionnaire__c equipmentCustomSetting=new FS_Equipment_Placement_Questionnaire__c();
        equipmentCustomSetting.name='1';
        equipmentCustomSetting.Field_API_Mapping__c='FS_What_type_of_install_is_this__c';
        equipmentCustomSetting.Question_Label__c='What type of install is this?';
        insert equipmentCustomSetting;
        FS_Equipment_Placement_Questionnaire__c equipmentCustomSetting2=new FS_Equipment_Placement_Questionnaire__c();
        equipmentCustomSetting2.name='2';
        equipmentCustomSetting2.Field_API_Mapping__c='FS_What_type_of_beverage_station_is_this__c';
        equipmentCustomSetting2.Question_Label__c='What type of beverage station is this?';
        insert equipmentCustomSetting2;
        system.debug('aaaa'+FS_Equipment_Placement_Questionnaire__c.getall().values());
        
        ApexPages.StandardController controller=new ApexPages.StandardController(executionPlan);
        FSEquipmentPlacementQuestionsCTRL fsEqipQues= new FSEquipmentPlacementQuestionsCTRL(controller);
        fsEqipQues.isSetAllNotApplicable=true;
        fsEqipQues.setAllNotApplicable();
        Test.stopTest();
    }
    Static testMethod void fsEquipmentPlacementQuestionsTestNegative2(){
        createtestData();
        executionPlan=new FS_Execution_Plan__c();
        executionPlan.FS_Headquarters__c= accHQ.Id;
        executionPlan.recordtypeid=recTypeEP;
        
        Test.startTest();
        insert executionPlan;
        
        Pagereference pg = Page.FSEquipmentPlacementQuestions;
        Test.setCurrentPage(pg);
        pg.getParameters().put('displaySaveandClose','true');
        FS_Equipment_Placement_Questionnaire__c equipmentCustomSetting=new FS_Equipment_Placement_Questionnaire__c();
        equipmentCustomSetting.name='1';
        equipmentCustomSetting.Field_API_Mapping__c='FS_What_type_of_install_is_this__c';
        equipmentCustomSetting.Question_Label__c='What type of install is this?';
        insert equipmentCustomSetting;
        FS_Equipment_Placement_Questionnaire__c equipmentCustomSetting2=new FS_Equipment_Placement_Questionnaire__c();
        equipmentCustomSetting2.name='2';
        equipmentCustomSetting2.Field_API_Mapping__c='FS_What_type_of_beverage_station_is_this__c';
        equipmentCustomSetting2.Question_Label__c='What type of beverage station is this?';
        insert equipmentCustomSetting2;
        system.debug('aaaa'+FS_Equipment_Placement_Questionnaire__c.getall().values());
        
        ApexPages.StandardController controller=new ApexPages.StandardController(executionPlan);
        FSEquipmentPlacementQuestionsCTRL fsEqipQues= new FSEquipmentPlacementQuestionsCTRL(controller);
        
        fsEqipQues.Edit();
        Test.stopTest();
    }
}