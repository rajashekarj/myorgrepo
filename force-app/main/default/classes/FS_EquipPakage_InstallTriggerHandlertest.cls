@isTest
public  class FS_EquipPakage_InstallTriggerHandlertest {
    
    private static FS_Installation__c createTestData(){
        FSTestFactory.createTestDisableTriggerSetting();
        
        //Method to test updateOverallStatus method of InstallationTriggerHandler
        final Account headquartersAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        headquartersAcc.ShippingPostalCode = '12345';
        insert headquartersAcc;
        final Account outlet = FSTestUtil.createAccountOutlet('test outlet1',FSConstants.RECORD_TYPE_OUTLET,headquartersAcc.id,true);       
        //FET 5.0 regular Installation default record type "New Install"
        final FS_Execution_Plan__c executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,headquartersAcc.Id, true);
        final FS_Installation__c installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outlet.id , false);
        //FET 5.0 regular Installation default record type "New Install"        
        return installation;        
    }
    
    private Static testMethod void fsEquipPakageInstallTriggerHandlertest(){
        FSTestFactory.createTestDisableTriggerSetting();
        Test.startTest();            
        final FS_Installation__c installation = createTestData();   
        installation.Type_of_Dispenser_Platform__c='7000;8000;9000';
        installation.FS_Platform1__c=FSConstants.RECTYPE_7k;
        installation.FS_Platform2__c=FSConstants.RECTYPE_8k;
        installation.FS_Platform3__c=FSConstants.RECTYPE_9k;        
        insert installation;        
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        
        system.runAs(adminUser){
            final List<FS_IP_Equipment_Package__c> equipList=new List<FS_IP_Equipment_Package__c>();            
            equipList.add(new FS_IP_Equipment_Package__c(FS_Installation__c=installation.id,FS_Platform_Type__c=FSConstants.RECTYPE_7k));
            equipList.add(new FS_IP_Equipment_Package__c(FS_Installation__c=installation.id,FS_Platform_Type__c=FSConstants.RECTYPE_8k));
            equipList.add(new FS_IP_Equipment_Package__c(FS_Installation__c=installation.id,FS_Platform_Type__c=FSConstants.RECTYPE_9k,FS_Valid_Fill_Notification_Flag__c=true));
            insert equipList;           
            for(FS_IP_Equipment_Package__c equppkg:equipList){
                equppkg.FS_Valid_Fill_QTY__c=7;            
                equppkg.FS_Valid_Fill__c='46245 : Valid Fill Conversion Kit';
                if(equppkg.FS_Platform_Type__c==FSConstants.RECTYPE_7k){
                    equppkg.FS_Dispenser_QTY__c =2;
                    equppkg.FS_Dispenser_Series_IC_code__c='46401: Standard Splashplate with Driptray, Cuprest and optional leg kit';
                }
                else if(equppkg.FS_Platform_Type__c==FSConstants.RECTYPE_8k){
                    equppkg.FS_Dispenser_QTY__c =2;
                    equppkg.FS_Dispenser_Series_IC_code__c='46102: Freestyle GS2 Crew Serve';
                }
                else if(equppkg.FS_Platform_Type__c==FSConstants.RECTYPE_9k){
                    equppkg.FS_Dispenser_QTY__c =2;                    
                    equppkg.FS_Dispenser_Series_IC_code__c='46100 : Freestyle GS1 Red';
                }                  
            }
            update equipList;
            Test.stopTest();
            system.assert([select id from FS_IP_Equipment_Package__c where FS_Installation__c=:installation.id].size()>0);
        }
    }
}