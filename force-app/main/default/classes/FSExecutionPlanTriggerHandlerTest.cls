/**************************************************************************************
Apex Class Name     : FSExecutionPlanTriggerHandlerTest
Version             : 1.0
Function            : This is a test class for FSExecutionPlanTriggerHandler & FSExecutionPlanValidateAndSet classes
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Mohit Parnami         Nov 11, 2013         Original Version
*Venkata				01/12/2017 			Updated for FET 4.0 code coverage
*************************************************************************************/

@isTest
private class FSExecutionPlanTriggerHandlerTest{
    public static Account accchain,accHQ,accOutlet;
    public static FS_Execution_Plan__c executionPlan;
    public static String recTypeNewIP=Schema.SObjectType.FS_Installation__c.getRecordTypeInfosByName().get(Label.IP_New_Install_Rec_Type).getRecordTypeId() ;
    public static String recTypeExePlan=Schema.SObjectType.FS_Execution_Plan__c.getRecordTypeInfosByName().get('Execution Plan').getRecordTypeId() ;
    
    public static void createtestData(){
        FSTestFactory.createTestDisableTriggerSetting();
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);        
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);    
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,true);   
    }
    
    public static testmethod void testcreateTechInstruction(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createtestData();   
            final Profile fetCOM=FSTestFactory.getProfileId(FSConstants.USER_POFILE_COM);
        	final User fetCOMUser=FSTestFactory.createUser(fetCOM.id);
        	insert fetCOMUser;
            final List<FS_Execution_Plan__c> epList=new List<FS_Execution_Plan__c>();
            final List<FS_Installation__c > ipList=new List<FS_Installation__c >();
            epList.add(new FS_Execution_Plan__c(FS_Headquarters__c= accHQ.Id,recordtypeid=recTypeExePlan,FS_Platform_Type__c='7000;8000',FS_Back_up_COM__c=fetCOMUser.Id));
            insert epList;
            ipList.add(new FS_Installation__c (FS_Execution_Plan__c=epList[0].id,FS_Outlet__c=accOutlet.Id,RecordTypeId=recTypeNewIP));
            insert ipList;
			system.debug('testcreateTechInstruction q#queries '+ Limits.getQueries());
            Test.startTest(); 
            final FS_Execution_Plan__c epUpdate=new FS_Execution_Plan__c(Id=epList[0].id,FS_Platform_Type__c='7000;9000',FS_Platform_change_approved__c=true );
            update epUpdate;
            system.debug('testcreateTechInstruction q#queries '+ Limits.getQueries());
            Test.stopTest();
            
            final List<FS_EP_Technician_Instructions__c> epTiList=[select id from FS_EP_Technician_Instructions__c where Execution_Plan__c=:epList[0].id];
            system.assertEquals(2,epTiList.size());
        }
    }  
    
    public static testmethod void testupdateInstallation(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createtestData();       
            final List<FS_Execution_Plan__c> epList=new List<FS_Execution_Plan__c>();
            final List<FS_Installation__c > ipList=new List<FS_Installation__c >();
            epList.add(new FS_Execution_Plan__c(FS_Headquarters__c= accHQ.Id,recordtypeid=recTypeExePlan,FS_Platform_Type__c='7000;8000'));     
            insert epList;
            
            system.debug('testupdateInstallation q#queries '+ Limits.getQueries());
            Test.startTest(); 
            
            ipList.add(new FS_Installation__c (FS_Execution_Plan__c=epList[0].id,FS_Outlet__c=accOutlet.Id,RecordTypeId=recTypeNewIP));
            insert ipList;
            
            Test.stopTest();
            final List<FS_EP_Technician_Instructions__c> eqpList=[select id from FS_EP_Technician_Instructions__c where Execution_Plan__c=:epList[0].Id];
            system.assert(!eqpList.isEmpty());
        }
    }  
    
    public static testmethod void testupdateExecutionPlanStatusOnHold(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createtestData();     
            final List<FS_Execution_Plan__c> epList=new List<FS_Execution_Plan__c>();
            final List<FS_Installation__c > ipList=new List<FS_Installation__c >();
            final List<FS_Installation__c > ipListtoUpdate=new List<FS_Installation__c >();
            
            
            epList.add(new FS_Execution_Plan__c(FS_Headquarters__c= accHQ.Id,recordtypeid=recTypeExePlan));     
            insert epList;
            
            ipList.add(new FS_Installation__c (FS_Execution_Plan__c=epList[0].id,FS_Outlet__c=accOutlet.Id,RecordTypeId=recTypeNewIP));
            insert ipList;
            
            system.debug('testupdateExecutionPlanStatusOnHold q#queries '+ Limits.getQueries());
            Test.startTest();
            ipListtoUpdate.add(new FS_Installation__c (Id=ipList[0].id,FS_Survey_Install_On_Hold__c=true));     
            update ipListtoUpdate;   
            system.debug('testupdateExecutionPlanStatusOnHold q#queries test '+ Limits.getQueries());
            Test.stopTest();
            final  String value=[select FS_Overall_Status__c from FS_Installation__c where Id=:ipList[0].id].FS_Overall_Status__c;
            system.assertEquals(FSConstants.onHolds ,value);
        }
    } 
    
    public static testmethod void testupdateExecutionPlanStatusCancelled(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createtestData();
            final List<FS_Execution_Plan__c> epList=new List<FS_Execution_Plan__c>();
            final List<FS_Installation__c > ipList=new List<FS_Installation__c >();
            final List<FS_Installation__c > ipListtoUpdate=new List<FS_Installation__c >();
            
            epList.add(new FS_Execution_Plan__c(FS_Headquarters__c= accHQ.Id,recordtypeid=recTypeExePlan));     
            insert epList;
            
            ipList.add(new FS_Installation__c (FS_Execution_Plan__c=epList[0].id,FS_Outlet__c=accOutlet.Id,RecordTypeId=recTypeNewIP));
            insert ipList;
            system.debug('testupdateExecutionPlanStatusCancelled q#queries '+ Limits.getQueries());
            Test.startTest();
            ipListtoUpdate.add(new FS_Installation__c (Id=ipList[0].id,FS_Survey_Install_Cancelled__c=true));     
            update ipListtoUpdate;   
            system.debug('testupdateExecutionPlanStatusCancelled q#queries test '+ Limits.getQueries());
            Test.stopTest();
            system.assertEquals('Cancelled',[select FS_Execution_Plan_Status__c from FS_Execution_Plan__c where Id=:epList[0].id].FS_Execution_Plan_Status__c );
        }
    }  
    public static testmethod void testupdateExecutionPlanStatusInprogress(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            createtestData();

            final Account accOutlet1=FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id,true);
            final List<FS_Execution_Plan__c> epList=new List<FS_Execution_Plan__c>();
            final List<FS_Installation__c > ipList=new List<FS_Installation__c >();
            final List<FS_Installation__c > ipListtoUpdate=new List<FS_Installation__c >();
            
            Test.startTest();
            
            epList.add(new FS_Execution_Plan__c(FS_Headquarters__c= accHQ.Id,recordtypeid=recTypeExePlan));     
            insert epList;
            
            ipList.add(new FS_Installation__c (FS_Execution_Plan__c=epList[0].id,FS_Outlet__c=accOutlet.Id,RecordTypeId=recTypeNewIP));
            ipList.add(new FS_Installation__c (FS_Execution_Plan__c=epList[0].id,FS_Outlet__c=accOutlet1.Id,RecordTypeId=recTypeNewIP));
            insert ipList;
            
            Test.stopTest();
            
            ipListtoUpdate.add(new FS_Installation__c (Id=ipList[0].id,FS_Davaco_Requirements__c='SA Not Required - OSM approval required for local market',FS_Install_Complete__c=true,FS_Original_Install_Date__c=Date.today(),FS_Rush_Install_Reason__c='NRA'));
            ipListtoUpdate.add(new FS_Installation__c (Id=ipList[1].id,FS_Survey_Install_Cancelled__c=true));     
            update ipListtoUpdate;   
            
            system.assertEquals('In Progress',[select FS_Execution_Plan_Status__c from FS_Execution_Plan__c where Id=:epList[0].id].FS_Execution_Plan_Status__c );
        }
    } 
    
    @testSetup  
    public static void mytestSetup() {
        final Disable_Trigger__c disTrigrSetting = new Disable_Trigger__c();       
        disTrigrSetting.name='FSExecutionPlanTriggerHandler';
        disTrigrSetting.IsActive__c=true;
        disTrigrSetting.Trigger_Name__c='FSExecutionPlanTrigger' ; 
        insert disTrigrSetting; 
        system.assertEquals(true,disTrigrSetting.IsActive__c);  
    }
    
}