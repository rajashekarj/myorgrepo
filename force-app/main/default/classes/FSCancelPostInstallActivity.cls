global class FSCancelPostInstallActivity {

  webservice static String FSCancelPostInsMrkt(String cancelId) {
        FS_Post_Install_Marketing__c PM;
        String qryPM = FSUtil.getSelectQuery('FS_Post_Install_Marketing__c') + ' WHERE Id=:cancelId';
        List<FS_Post_Install_Marketing__c> ListPM = (List<FS_Post_Install_Marketing__c>)database.query(qryPM);
        For(FS_Post_Install_Marketing__c PIM:ListPM ){
            PM=PIM;
        }
        PM.FS_Cncl_Post_Install_Marketting_fields__c=true;
        update pm;
        Database.executeBatch(new FSBatchCancelPostInsMrkt(cancelId),200);
        return 'Cancel Successful';
}
    webservice static String FSCancelValidFill(String cancelId) {
     FS_Valid_Fill__c VF ;
     String qryVF = FSUtil.getSelectQuery('FS_Valid_Fill__c') + ' WHERE Id=:cancelId';
     List<FS_Valid_Fill__c> ListVF = (List<FS_Valid_Fill__c>)database.query(qryVF);
     For(FS_Valid_Fill__c VlF:ListVF ){
         VF=VlF;
     }
     VF.FS_Cancel_Valid_Fill__c=true;
     update VF;
    Database.executeBatch(new FSBatchCancelValidFill(cancelId),200);
    return 'Cancel Successful';
    }
}