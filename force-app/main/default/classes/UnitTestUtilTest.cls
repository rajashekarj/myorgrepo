@isTest
public class UnitTestUtilTest {
    private static testMethod void testUnitTestUtil(){
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_FETADMIN);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            UnitTestUtil.getInstance();
        }
    }
}