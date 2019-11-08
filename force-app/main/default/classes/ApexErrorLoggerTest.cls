@isTest(SeeAllData=false)
private class ApexErrorLoggerTest{
    
    //Create ApexErrorLog when exception
    static testmethod void createApexLogger(){
        try{
            final Account acc=new Account();
            insert acc;
        }catch(Exception exc){
            final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
            final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
            insert sysAdminUser;
            system.runAs(sysAdminUser){
                Test.startTest();
                ApexErrorLogger.addApexErrorLog('FET','ApexErrorLoggerTest','createApexLogger','Account','Critical',exc,'Ext');
                final Integer countErr=[SELECT count() FROM Apex_Error_Log__c];
                system.assert(countErr>0,true);
                Test.stopTest();
            }
        }
    }
    
    //Send notification to Admin when fail to insert Apex logger
    static testmethod void notifyAdmin(){
        try{
            final Account acc=new Account();
            insert acc;
        }catch(Exception exc){
            final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
            final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
            insert sysAdminUser;
            system.runAs(sysAdminUser){
                Test.startTest();
                ApexErrorLogger.addApexErrorLog('FET','ApexErrorLoggerTest','createApexLogger','Account','Med',exc,'Ext');
               final  Integer countErr=[SELECT count() FROM Apex_Error_Log__c];
                system.assert(countErr==0,true);
                Test.stopTest();
            }
        }
    }
    //Check if null string
    static testmethod void checkNullString(){
        try{
            final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
            final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
            insert sysAdminUser;
            system.runAs(sysAdminUser){
                final Account acc=new Account();
                insert acc;
            }
        }catch(Exception exc){
            
            Test.startTest();
            ApexErrorLogger.addApexErrorLog('FET',null,'createApexLogger','Account','Med',exc,'Ext');
            final Integer countErr=[SELECT count() FROM Apex_Error_Log__c];
            system.assert(countErr==0,true);
            Test.stopTest();
        }
    }
    
}