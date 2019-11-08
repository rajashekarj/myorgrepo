@isTest
private class FSInitialOrdSapMaterialExtensionsTest {    
    private static testMethod void test1(){
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FS_Initial_Order__c initialorder = new FS_Initial_Order__c();
            final FSInitialOrdSapMaterialExtensions c=new FSInitialOrdSapMaterialExtensions();
            c.show7000Section=true;
            c.initialorder=initialorder;
        }
    } 
}