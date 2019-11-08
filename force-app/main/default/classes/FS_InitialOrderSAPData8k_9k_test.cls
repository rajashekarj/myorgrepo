@istest
public class FS_InitialOrderSAPData8k_9k_test{
    
    private static testMethod void testMethod1() {
        
        final list<Account> lstLead= new list<Account>();
        for(Integer i=0 ;i <200;i++)        {
            final Account acc = new Account();
            acc.Name ='Name'+i;
            lstLead.add(acc);
        }        
        insert lstLead;
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.systemAdmin);
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final FS_InitialOrderSAPData8k_9k lis=new FS_InitialOrderSAPData8k_9k();
            lis.start(null);
            lis.execute(null,lstLead);
            lis.finish(null);
        }        
        Test.stopTest();
    }  
}