@isTest
public class FSAssociateBrandsetAccessControllerTest {    
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
    
    private static testMethod void testDeleteBrandset(){
        
        insert new Disable_Trigger__c (Name='FSAssociationBrandsetTrigger', IsActive__c=true);
        
        test.startTest();
        final FS_Association_Brandset__c assBrandset = new FS_Association_Brandset__c();
        assBrandset.RecordTypeId=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_HQ).getRecordTypeId();
        assBrandset.FS_Platform__c='7000';
        insert assBrandset;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final ApexPages.StandardController stdController = new ApexPages.StandardController(assBrandset);
            final FSAssociateBrandsetAccessController controller =  new FSAssociateBrandsetAccessController(stdController);
            controller.deleteAssBrandset();
        }        
        test.stopTest();
    }
}