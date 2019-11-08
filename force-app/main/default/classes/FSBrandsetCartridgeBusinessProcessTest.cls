/***************************************************************************
 Name         : FSBrandsetCartridgeBusinessProcessTest
 Created By   : Infosys Limited
 Description  : Test class for FSBrandsetCartridgeBusinessProcess
 Created Date : 15-FEB-2017
****************************************************************************/
@isTest
public class FSBrandsetCartridgeBusinessProcessTest {
    
    @testSetup
    private static void loadTestData(){
      //Create trigger switch custom setting.
      FSTestFactory.createTestDisableTriggerSetting();
      
      FSTestFactory.createTestAirWatchData();
      
      //create Brandset records
      FSTestFactory.createTestBrandset();
      FSTestFactory.createTestCartridge();      
      
    }
     
    private static testMethod void testUpdateCartridgeAWFlag(){
        final List<FS_Brandsets_Cartridges__c> brandsetCartRecordList = new List<FS_Brandsets_Cartridges__c>();
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        
        System.runAs(sysAdminUser){
            Test.startTest();
            //Create Brandset Cartridge Records
            for(FS_Brandset__c brandset : [SELECT Id,FS_Platform__c FROM FS_Brandset__c LIMIT 100 ]){
                for(FS_Cartridge__c cartridge : [SELECT Id,FS_Platform__c FROM FS_Cartridge__c WHERE FS_Brand__c!=NULL LIMIT 200 ]){
                    if(brandset.FS_Platform__c.contains(cartridge.FS_Platform__c)){
                        brandsetCartRecordList.add(new FS_Brandsets_Cartridges__c(FS_Brandset__c=brandset.Id,FS_Cartridge__c=cartridge.Id));
                    }
                }
            }
            
            system.assert(!brandsetCartRecordList.isEmpty());
            insert brandsetCartRecordList;
            
            Test.stopTest();
        }
    }
    
}