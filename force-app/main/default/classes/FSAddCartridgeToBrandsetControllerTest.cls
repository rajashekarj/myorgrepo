/*
*********************************************************************************************************
Name         : FSAddCartridgeToBrandsetController 
Created By   : Infosys Limited 
Created Date : 7-Feb-2017
Usage        : Test Class for FSAddCartridgeToBrandsetController

***********************************************************************************************************/


@isTest
private class FSAddCartridgeToBrandsetControllerTest{
    @testSetup
    private static void loadTestData(){
        
        //custom setting trigger switch
        FSTestFactory.createTestDisableTriggerSetting();
        
        //create Brandset records
        FSTestFactory.createTestBrandset();
        
        //create cartridge records 
        final List<FS_Cartridge__c > cartridgeRecords= FSTestFactory.createTestCartridge();
        system.assert(!cartridgeRecords.isEmpty());
    }
    
    
    private static testMethod void testOnPageLoad(){
        
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSAddCartridgeToBrandset;
        Test.setCurrentPage(pageRef);
        
        //Brandset record in Context
        final FS_Brandset__c brandsetRecord=[SELECT Id,Name,FS_Country__c,FS_Platform__c FROM FS_Brandset__c 
                                             WHERE FS_Country__c INCLUDES ('US;CA') AND FS_Platform__c  INCLUDES ('7000') limit 1];
        
        Profile contextProfile = [select id from profile where name='FS_FACT_BAST_P'];
        User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        Test.startTest();
        System.runAs(contextUser){
            final ApexPages.StandardController stdcontol = new ApexPages.StandardController(brandsetRecord);
            final FSAddCartridgeToBrandsetController controller = new FSAddCartridgeToBrandsetController(stdcontol);
            
            //picklist values
            controller.getCartridgeTypes();
            controller.getCartridgeRecords();
            
            system.assert(!controller.availableCartridgesList.isEmpty());
            
            //pagination variables
            controller.getAvailableDisablePrevious();
            controller.getAvailableDisableNext();
        }
        Test.stopTest();
    }
    
    private static testMethod void testBackToBrandsetDetailPage(){
        
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSAddCartridgeToBrandset;
        Test.setCurrentPage(pageRef);
        
        //Brandset record in Context
        final FS_Brandset__c brandsetRecord=[SELECT Id,Name,FS_Country__c,FS_Platform__c FROM FS_Brandset__c 
                                             WHERE FS_Platform__c  INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') limit 1];
        
        Profile contextProfile = [select id from profile where name='FS_FACT_BAST_P'];
        User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        Test.startTest();
        System.runAs(contextUser){
            final ApexPages.StandardController stdcontol = new ApexPages.StandardController(brandsetRecord);
            final FSAddCartridgeToBrandsetController controller = new FSAddCartridgeToBrandsetController(stdcontol);
            
            //picklist values
            controller.getCartridgeTypes();
            
            //User navigated to brandset detail page
            final Pagereference pageRefUrl=controller.backToDetailPage();
            final String expectedUrl='/'+brandsetRecord.Id;
            system.assert(expectedUrl.contains(pageRefUrl.getUrl()));
        }
        Test.stopTest();
    }
    
    
    private static testMethod void testUserProvidesSearchInputs1(){
        
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSAddCartridgeToBrandset;
        Test.setCurrentPage(pageRef);
        
        //Brandset record in Context
        final FS_Brandset__c brandsetRecord=[SELECT Id,Name,FS_Country__c,FS_Platform__c FROM FS_Brandset__c 
                                             WHERE FS_Platform__c  INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') limit 1];
        
        Profile contextProfile = [select id from profile where name='FS_FACT_BAST_P'];
        User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        Test.startTest();
        System.runAs(contextUser){
            final ApexPages.StandardController stdcontol = new ApexPages.StandardController(brandsetRecord);
            final FSAddCartridgeToBrandsetController controller = new FSAddCartridgeToBrandsetController(stdcontol);
            
            //picklist values
            controller.getCartridgeTypes();
            
            
            controller.searchCartridgeName='Powerade';
            controller.searchCartridgeBrand='Powerade';
            
            //user clicks on search button
            controller.search();
            
            system.assert(!controller.availableCartridgesList.isEmpty());
            
            //pagination variables
            controller.availableFirst();
            controller.availablePrevious();
            controller.availableNext();
            controller.availableEnd();
        }
        Test.stopTest();
    }
    
    private static testMethod void testUserProvidesSearchInputs2(){
        
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSAddCartridgeToBrandset;
        Test.setCurrentPage(pageRef);
        
        //Brandset record in Context
        final FS_Brandset__c brandsetRecord=[SELECT Id,Name,FS_Country__c,FS_Platform__c FROM FS_Brandset__c 
                                             WHERE FS_Platform__c  INCLUDES ('7000') AND FS_Country__c INCLUDES ('US;CA') limit 1];
        
        Profile contextProfile = [select id from profile where name='FS_FACT_BAST_P'];
        User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        Test.startTest();
        System.runAs(contextUser){
            final ApexPages.StandardController stdcontol = new ApexPages.StandardController(brandsetRecord);
            final FSAddCartridgeToBrandsetController controller = new FSAddCartridgeToBrandsetController(stdcontol);
            
            //picklist values
            controller.getCartridgeTypes();
            
            
            controller.searchCartridgeFlavor='Cherry';
            controller.searchCartridgeType='Core';
            
            //user clicks on search button
            controller.search();
            
            system.assert(!controller.availableCartridgesList.isEmpty());
        }
        Test.stopTest();
    }
    
    
    private static testMethod void testUserSelectsCartridgetoAdd(){
        
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSAddCartridgeToBrandset;
        Test.setCurrentPage(pageRef);
        
        //Brandset record in Context
        final FS_Brandset__c brandsetRecord=[SELECT Id,Name,FS_Country__c,FS_Platform__c FROM FS_Brandset__c 
                                             WHERE FS_Platform__c  INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') limit 1];
        
        Profile contextProfile = [select id from profile where name='FS_FACT_BAST_P'];
        User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        Test.startTest();
        System.runAs(contextUser){
            final ApexPages.StandardController stdcontol = new ApexPages.StandardController(brandsetRecord);
            final FSAddCartridgeToBrandsetController controller = new FSAddCartridgeToBrandsetController(stdcontol);
            
            //picklist values
            controller.getCartridgeTypes();
            
            //Select two cartridge records to add (carete brandset cartridge)
            for(FS_Cartridge__c  cartridge : [Select Id,Name,FS_Cartridge_Name__c,FS_Platform__c,FS_Country__c,FS_Brand__c,
                                              FS_Flavor__c,FS_RFID__c,FS_RFID_and_Version__c,FS_Cartridge_type__c,
                                              FS_Brand_code__c,FS_Available_for_commercial_use__c from FS_Cartridge__c 
                                              WHERE FS_Platform__c INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') 
                                              order by createdDate limit 2]){
                                                  
                                                  
                                                  controller.cartridgeRecords.add(new FSAddCartridgeToBrandsetController.CartridgeWrapper(cartridge,true));      
                                              }
            
            //add cartridges
            controller.addSelectedCartridges();
            
            //verify two cartridge were selected
            system.assert(controller.selectedCartridgesList.size()==2);
            
            //pagination variables
            controller.getSelectedDisablePrevious();
            controller.getSelectedDisableNext();
            controller.selectedFirst();
            controller.selectedPrevious();
            controller.selectedNext();
            controller.selectedEnd();
            
            //save cartridges selection
            controller.saveCartridgesToBrandset();
            
            //verify two branset cartridge were created
            system.assertEquals(2,[SELECT COUNT() FROM FS_Brandsets_Cartridges__c WHERE FS_Brandset__c=: brandsetRecord.Id]);
        }
        Test.stopTest();
    }
    
    private static testMethod void testUserSelectsCartridgestoRemove(){
        
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSAddCartridgeToBrandset;
        Test.setCurrentPage(pageRef);
        
        //Brandset record in Context
        final FS_Brandset__c brandsetRecord=[SELECT Id,Name,FS_Country__c,FS_Platform__c FROM FS_Brandset__c 
                                             WHERE FS_Platform__c  INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') limit 1];
        
        
        final ApexPages.StandardController stdcontol = new ApexPages.StandardController(brandsetRecord);
        final FSAddCartridgeToBrandsetController controller = new FSAddCartridgeToBrandsetController(stdcontol);
        
        //picklist values
        controller.getCartridgeTypes();
        
        
        //Select two cartridge records to add 
        for(FS_Cartridge__c  cartridge : [Select Id,Name,FS_Cartridge_Name__c,FS_Platform__c,FS_Country__c,FS_Brand__c,
                                          FS_Flavor__c,FS_RFID__c,FS_RFID_and_Version__c,FS_Cartridge_type__c,
                                          FS_Brand_code__c,FS_Available_for_commercial_use__c from FS_Cartridge__c 
                                          WHERE FS_Platform__c INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') 
                                          order by createdDate limit 2]){
                                              
                                              controller.cartridgeRecords.add(new FSAddCartridgeToBrandsetController.CartridgeWrapper(cartridge,true));                                             
                                          }
        
        
        //add cartridges
        controller.addSelectedCartridges();
        
        //verify selected cartridges    
        system.assertEquals(2,controller.selectedCartridgesList.size());
        
        Profile contextProfile = [select id from profile where name='FS_FACT_BAST_P'];
        User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        Test.startTest();
        System.runAs(contextUser){
            for(FS_Cartridge__c  cartridge : [Select Id,Name,FS_Cartridge_Name__c,FS_Platform__c,FS_Country__c,FS_Brand__c,
                                              FS_Flavor__c,FS_RFID__c,FS_RFID_and_Version__c,FS_Cartridge_type__c,
                                              FS_Brand_code__c,FS_Available_for_commercial_use__c from FS_Cartridge__c 
                                              WHERE FS_Platform__c INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') 
                                              order by createdDate limit 1]){
                                                  
                                                  controller.selectedCartridgeRecords.add(new FSAddCartridgeToBrandsetController.CartridgeWrapper(cartridge,true));                                                    
                                              } 
            
            //user clicks on remove button
            controller.removeCartridges(); 
            
            //save cartridges selection
            controller.saveCartridgesToBrandset();
            
            //verify all records were removed
            system.assertEquals(1,controller.selectedCartridgesList.size());
        }
        Test.stopTest();
    }
    
    
    private static testMethod void testUserSelectsAlreadyAddedCartridge(){
        
        //create bransetCartridge
        
        //Separate Brandset based on platform 
        final List<FS_Brandset__c> branset7000List=new List<FS_Brandset__c>();
        for(FS_Brandset__c branset :[SELECT Id,Name,FS_Country__c,FS_Effective_End_Date__c,FS_Effective_Start_Date__c,
                                     FS_Platform__c FROM FS_Brandset__c WHERE FS_Platform__c INCLUDES ('7000') 
                                     ORDER BY CreatedDate ASC limit 1]){
                                         branset7000List.add(branset);
                                     }
        //Separate Cartridge  based on platform 
        final List<FS_Cartridge__c> cartridge7000List=new List<FS_Cartridge__c>();
        for(FS_Cartridge__c cartridge  :[Select Id,Name,FS_Cartridge_Name__c,FS_Platform__c,FS_Country__c,FS_Brand__c,
                                         FS_RFID_and_Version__c,FS_Cartridge_type__c,FS_Available_for_commercial_use__c 
                                         FROM FS_Cartridge__c WHERE FS_Platform__c INCLUDES ('7000') 
                                         ORDER BY CreatedDate ASC limit 1]){
                                             cartridge7000List.add(cartridge);
                                         }
        
        
        final FS_Brandsets_Cartridges__c bsCartRec= new FS_Brandsets_Cartridges__c();
        bsCartRec.FS_Brandset__c=branset7000List.get(0).id;
        bsCartRec.FS_Cartridge__c=cartridge7000List.get(0).Id;
        //custom setting FET Airwatch Data Mapping
        // FS_FET_Airwatch_Data_Mapping__c
        final List<FS_FET_Airwatch_Data_Mapping__c> airwatchDetails = new List<FS_FET_Airwatch_Data_Mapping__c>();
        FS_FET_Airwatch_Data_Mapping__c custSetting = new FS_FET_Airwatch_Data_Mapping__c();
        //AgitatedBrand
        custSetting.Name='AgitatedBrand:Barqs';
        custSetting.FS_Field_name__c='FS_7000_Series_Agitated_Brands_Selection__c';
        custSetting.FS_Airwatch_Value__c='Barqs1';
        custSetting.FS_FET_Value__c='Barqs';
        airwatchDetails.add(custSetting);
        //static selections
        custSetting= new FS_FET_Airwatch_Data_Mapping__c();
        custSetting.Name='StaticBrand1';
        custSetting.FS_Airwatch_Value__c='Raspberry1';
        custSetting.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
        custSetting.FS_FET_Value__c='Raspberry';
        airwatchDetails.add(custSetting);
        //SpicyCherry
        
        custSetting= new FS_FET_Airwatch_Data_Mapping__c();
        custSetting.Name='SpicyCherry1';
        custSetting.FS_Airwatch_Value__c='Dr Pepper/Diet Dr Pepper1';
        custSetting.FS_Field_name__c='FS_Spicy_Cherry__c';
        custSetting.FS_FET_Value__c='Dr Pepper/Diet Dr Pepper';
        airwatchDetails.add(custSetting);
        insert airwatchDetails;
        insert bsCartRec;
        
        
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSAddCartridgeToBrandset;
        Test.setCurrentPage(pageRef);
        
        //Brandset record in Context
        final FS_Brandset__c brandsetRecord=[SELECT Id,Name,FS_Country__c,FS_Platform__c FROM FS_Brandset__c 
                                             WHERE FS_Platform__c  INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') limit 1];
        
        
        final ApexPages.StandardController stdcontol = new ApexPages.StandardController(brandsetRecord);
        final FSAddCartridgeToBrandsetController controller = new FSAddCartridgeToBrandsetController(stdcontol);
        
        //picklist values
        controller.getCartridgeTypes();
        
        //Select two cartridge records to add
        for(FS_Cartridge__c  cartridge : [Select Id,Name,FS_Cartridge_Name__c,FS_Platform__c,FS_Country__c,FS_Brand__c,
                                          FS_Flavor__c,FS_RFID__c,FS_RFID_and_Version__c,FS_Cartridge_type__c,
                                          FS_Brand_code__c,FS_Available_for_commercial_use__c from FS_Cartridge__c 
                                          WHERE FS_Platform__c INCLUDES ('7000') AND FS_Country__c INCLUDES ('US') 
                                          ORDER BY CreatedDate DESC limit 2]){
                                              
                                              controller.cartridgeRecords.add(new FSAddCartridgeToBrandsetController.CartridgeWrapper(cartridge,true));                                          
                                          }
        
        Profile contextProfile = [select id from profile where name='FS_FACT_BAST_P'];
        User contextUser = FSTestFactory.createUser(contextProfile.id);
        
        Test.startTest();
        System.runAs(contextUser){
            //add cartridges
            controller.addSelectedCartridges();
            
            //verify 3 cartridge were selected
            system.assertNotEquals(10,controller.selectedCartridgesList.size());
            
            //save cartridges
            controller.saveCartridgesToBrandset();  
            
            
            //verify three  branset cartridge were created
            system.assertNotEquals(10,[SELECT COUNT() FROM FS_Brandsets_Cartridges__c WHERE FS_Brandset__c=: brandsetRecord.Id]);
        }
        Test.stopTest();
    }
    
}