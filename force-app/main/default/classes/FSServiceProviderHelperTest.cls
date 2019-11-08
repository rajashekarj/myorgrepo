/**************************************************************************************************************
*@Class Name: FSServiceProviderHelperTest
*@owner :Infosys limited
*@Description : Test class for FSServiceProviderHelper
***************************************************************************************************************/
@isTest
private class FSServiceProviderHelperTest{
    private final static String LIT7K='7000 Series';
    private final static String LIT8K9K='8000/9000 Series';
    private final static String SERVICEPROVIDERACCOUNT='FS Service Provider';
    private final static List<String> LISTOFZIPCODES=new List<String>{'13217-6969','13219-6969','30303','30304','30305'}; 
        
        @testSetup
        private static void loadTestData(){
            
            //create service provider account
            final List<Account> serviceProviderCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                                             FSUtil.getObjectRecordTypeId(Account.SObjectType,SERVICEPROVIDERACCOUNT));
            
            
            final List<FS_SP_Aligned_Zip__c> spAlignedZipList=new List<FS_SP_Aligned_Zip__c>();   
            //final Id recordTypeId7K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(LIT7K).getRecordTypeId();                                                                  
            //final Id recordTypeId8K9K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(LIT8K9K).getRecordTypeId();
            final string platform7k='7000';
        	final string platform8k9k='8000';
            
            final Set<String> setOfZipCodes=FSServiceProviderHelper.formatZip(LISTOFZIPCODES);
            //Get all the Outlets
            for(String zipCode: setOfZipCodes){
                
                spAlignedZipList.addAll(FSTestFactory.createTestSPAlignedZip(serviceProviderCustomerList.get(0).Id,zipCode.substring(0,5),platform7k,false,1));
                spAlignedZipList.addAll(FSTestFactory.createTestSPAlignedZip(serviceProviderCustomerList.get(0).Id,zipCode.substring(0,5),platform8k9k,false,1));
            }
            
            //Insert FS_SP_Aligned_Zip__c
            insert spAlignedZipList;   
            
        }
    
    private static testMethod void test7000ServiceProvider(){
        
        final Id recordTypeId7K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_SPAlignedZip).getRecordTypeId();                                                                  
        List<FS_SP_Aligned_Zip__c> list1=new List<FS_SP_Aligned_Zip__c>();
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){  
            
            Test.startTest();
            
            final Set<String> setOfZipCodes=FSServiceProviderHelper.formatZip(LISTOFZIPCODES);
            
            final Map<String,FS_SP_Aligned_Zip__c> spAlignedZip7000SeriesBasesdOnZip=new Map<String,FS_SP_Aligned_Zip__c>();
            
            for(FS_SP_Aligned_Zip__c sp7000 : FSServiceProviderHelper.get7000SPAlignedZip(new List<String>(setOfZipCodes))){
                spAlignedZip7000SeriesBasesdOnZip.put(sp7000.FS_Zip_Code__c,sp7000);
            }
            list1= [SELECT ID,FS_Zip_Code__c FROM FS_SP_Aligned_Zip__c WHERE  FS_Zip_Code__c in: setOfZipCodes AND RecordTypeId=:recordTypeId7K];
            for(FS_SP_Aligned_Zip__c spAlignedZip: list1){
                
                final FS_SP_Aligned_Zip__c  spObj=spAlignedZip7000SeriesBasesdOnZip.get(spAlignedZip.FS_Zip_Code__c );
               
            }

            Test.stopTest();  
        }
  
    }
    
    private static testMethod void test80009000ServiceProvider(){
        
        final Id recordTypeId8K9K=Schema.SObjectType.FS_SP_Aligned_Zip__c.getRecordTypeInfosByName().get(FSConstants.RECTYPE_SPAlignedZip).getRecordTypeId();    
        List<FS_SP_Aligned_Zip__c> list2=new List<FS_SP_Aligned_Zip__c>();
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            
            Test.startTest();
            
            final Set<String> setOfZipCodes=FSServiceProviderHelper.formatZip(LISTOFZIPCODES);
            
            final  Map<String,FS_SP_Aligned_Zip__c> spAlignedZip8K9KSeriesBasesdOnZip=new Map<String,FS_SP_Aligned_Zip__c>();
            
            for(FS_SP_Aligned_Zip__c sp8K9K : FSServiceProviderHelper.get80009000SPAlignedZip(new List<String>(setOfZipCodes))){
                spAlignedZip8K9KSeriesBasesdOnZip.put(sp8K9K.FS_Zip_Code__c,sp8K9K);
            }
            list2=[SELECT ID,FS_Zip_Code__c FROM FS_SP_Aligned_Zip__c WHERE FS_Zip_Code__c in: setOfZipCodes AND RecordTypeId=:recordTypeId8K9K];
            for(FS_SP_Aligned_Zip__c spAlignedZip:list2){
                
                final FS_SP_Aligned_Zip__c  spObj=spAlignedZip8K9KSeriesBasesdOnZip.get(spAlignedZip.FS_Zip_Code__c);
                
            }
            
            Test.stopTest();  
        }
        
        
    }
    
}