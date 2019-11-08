/*=================================================================================================================
* Date         : 01-30-2019
* Developer    : Goutham Rapolu
* Purpose      : Test class for NewBrandsetOverrideControlle which will handle Edit/Delete for Default Brandset.
*=================================================================================================================
*                                 Update History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 01-30-2019 | Goutham Rapolu |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/
@isTest
public class NewBrandsetOverrideController_Test {
    
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    private static List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >();         
    private static List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();     
    private static Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,FSConstants.NEWINSTALLATION); 
    private static Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,FSConstants.EXECUTIONPLAN);   
    private static string AccName = 'QWNjb3VudA==';
    private static string InstallationName = 'RlNfSW5zdGFsbGF0aW9uX19j';
    private static string OutletDispenser = 'T3V0bGV0RGlzcGVuc2Vyc19fcg==';
    private static string FS_Association_Brandset = 'RlNfQXNzb2NpYXRpb25fQnJhbmRzZXRfX2M=';
    private static string Account_Brandsets = 'QWNjb3VudF9CcmFuZHNldHNfX3I=';
    private static string FSHeadquarters = 'RlNIZWFkcXVhcnRlcnNfX3I=';
    
    
    private static testMethod void testEditBrandset(){
        
        //Disable Trigger
        insert new Disable_Trigger__c (Name='FSAssociationBrandsetTrigger', IsActive__c=true);
        
        test.startTest();
        //Insert Account
        final List<Account> AccList = FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        insert AccList;
        
        //Insert Execution Plan
        final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(AccList.get(0).Id,false,1,epRecordTypeId);
        executionPlanList.addAll(epList);  
        insert executionPlanList;
        
        //Insert Installation record.
        final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,AccList.get(0).id,false,1,intallationRecordTypeId);
        installationPlanList.addAll(installList);        
        insert installationPlanList;
        system.debug('@@ installList'+ installList[0].RecordType.Name);
        //Insert Association Brandset
        final FS_Association_Brandset__c assBrandset = new FS_Association_Brandset__c();
        assBrandset.RecordTypeId=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_HQ).getRecordTypeId();
        assBrandset.FS_Platform__c='7000';
        assBrandset.FS_Headquarters__c = AccList[0].id;
        assBrandset.FS_Installation__c = installationPlanList[0].id;
        insert assBrandset;
        
        //Insert User
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;

        system.runAs(fetSysAdminUser){
            NewBrandsetOverrideController.getHQRecordId(assBrandset.id, AccName);
            NewBrandsetOverrideController.getHQRecordId(assBrandset.id, InstallationName);
            NewBrandsetOverrideController.getHQRecordId(assBrandset.id, OutletDispenser);
            NewBrandsetOverrideController.getHQRecordId(assBrandset.id, FS_Association_Brandset);
            NewBrandsetOverrideController.getProfileAccess(assBrandset.id, InstallationName);
            NewBrandsetOverrideController.getProfileAccess(assBrandset.id, AccName);
            NewBrandsetOverrideController.getProfileAccess(assBrandset.id, OutletDispenser);
            NewBrandsetOverrideController.getInstallationRT(assBrandset.id, InstallationName);
            NewBrandsetOverrideController.deleteBrandSet(assBrandset.id);
            NewBrandsetOverrideController.getdecodeurl(Account_Brandsets);
            NewBrandsetOverrideController.getdecodeurl(FSHeadquarters);
            NewBrandsetOverrideController.getdecodeurl(OutletDispenser);
            
        }        
        test.stopTest();
    }
}