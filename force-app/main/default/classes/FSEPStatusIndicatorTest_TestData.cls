/******************************************** 
Name         : FSEPStatusIndicatorTest_TestData
Created By   : Infosys Limited
Created Date : Sep. 19, 2017
Usage        : Utility class for test data creation
			   for FSEPStatusIndicatorTest class
*************************************************/
 
@isTest
public class FSEPStatusIndicatorTest_TestData {
    public static final String APPROVED='Approved';
    public static final String STORE='Store Opening';
    public static final String BLUE='blue';
    public static final String GREEN='green';
    public static final String REDCOLR='red';
    public static final String YELLOW='yellow';
    public static final String GRAY='gray';
    public static List<Id> idsList;
    public static List<Id> accountId;
    public static List<FS_Installation__c> installList;
    
    public static List<Id> loadTestData(){
        idsList=new List<Id>();
        FSTestFactory.createTestDisableTriggerSetting(); 
        final Account accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        idsList.add(accHQ.Id);
        
        final Account accOutlet = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,accHQ.Id, false); 
        accOutlet.FS_Approved_For_Execution_Plan__c = true;    	
        accOutlet.FS_Headquarters__c = accHQ.Id;
        accOutlet.FS_ACN__c = 'outletACN';
        insert accOutlet; 
        idsList.add(accOutlet.Id);
        
        return idsList;        
    }   
    
    public static List<FS_Installation__c> createInstOther(final List<id> idsList,final Integer count,final Integer valueCheck){
        installList=new List<FS_Installation__c>();
        final List<Integer> integerList=new List<Integer>{1,2,3,4};
            for(integer i=0;i<count;i++){
                final FS_Installation__c  installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,idsList[0],idsList[1], false);
                installation.FS_SA_Scheduled_On_Date__c = System.today().addDays(-20);
                if(valueCheck==integerList[0]){ installation.FS_SA_Completed_Date__c = System.today().addDays(-10); }
                if(valueCheck==integerList[1]){installation.FS_Davaco_Requirements__c='SA Not Required - OSM approval required for local market';}
                if(valueCheck==integerList[2]){installation.FS_Execution_Plan_Final_Approval_PM__c=APPROVED;}
                if(valueCheck==integerList[3]){
                    installation.FS_Original_Install_Date__c = System.today().addDays(-10);
                    installation.FS_Rush_Install_Reason__c=STORE;
                }
                installList.add(installation);
            } 
        return installList;        
    } 
      
    public static List<FS_Installation__c> createInst(final List<id> idsList,final Integer count){
        installList=new List<FS_Installation__c>();
        for(integer i=0;i<count;i++){
            final FS_Installation__c installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,idsList[0],idsList[1], false);
            installList.add(installation);
        }
        return installList;        
    }
     public static FSExecutionPlanStatusIndicatorExtension executeMethod(final FS_Execution_Plan__c exePlan){
       //final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
      //final User adminUser = FSTestFactory.createUser(adminProfile.id);
      //insert adminUser;
        FSExecutionPlanStatusIndicatorExtension obj;
      //system.runAs(adminUser){
            final Pagereference pageRef = Page.FSCreateExecutionPlan;
            Test.setCurrentPage(pageRef);        
            // Initialize Page paramteres
            pageRef.getParameters().put('id', exePlan.Id);
           final apexpages.Standardcontroller standCont = new apexpages.Standardcontroller(exePlan);        
            obj = new FSExecutionPlanStatusIndicatorExtension(standCont);        
            
       //}
        return obj;
        
    }
}