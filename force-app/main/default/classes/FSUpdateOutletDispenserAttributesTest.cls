/**************************************************************************************
Apex Class Name     : FSUpdateOutletDispenserAttributesTest
Version             : 1.0
Function            : This test class is for  FSUpdateOutletDispenserAttributes Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             04/12/2017          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/

@isTest
private class FSUpdateOutletDispenserAttributesTest {
    
    private static final string LIT7K = '7000';
    private static final string LIT8K = '8000';
    private static final string LIT9K = '9000';
    private static final String NUM7000 ='7000'; 
    private static final String NUM8000 ='8000';
    private static final String NUM9000 ='9000'; 
    private static final String CUSTOMFIELDEQUIPTYPE='FS_Equip_Type__c';
    private static final String CUSTOMFIELDPLATFORM ='FS_Platform__c';
  
    
    @testSetup
    private static void loadTestData(){        
        //create Brandset records
        List<Disable_Trigger__c> triggerList = new List<Disable_Trigger__c>();
        List<String> disTriggersRec = new List<String>{'FSAccountBusinessProcess','FSInstallationBusinessProcess','FSExecutionPlanTriggerHandler','FSAssociationBrandsetTrigger'};
            for(String str:disTriggersRec){
                triggerList.add(new Disable_Trigger__c(Name=str,IsActive__c=false));
            }
        insert triggerList;
        /** @desc this method creates 1 chain,1 HQ, 1 Outlet,1 Execution Pan(Execution Plan),
* 4 Installation('7000 Series','8000 & 9000 Series','8000 Series','9000 Series')*/
        FSTestFactory.createCommonTestRecords();
        FSTestFactory.lstPlatform(); 
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        //Create Outlet Dispensers 
        Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
        List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        
        for(FS_Installation__c installPlan : [SELECT Id,FS_Outlet__c,RecordTypeId FROM FS_Installation__c LIMIT 4]){
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId;
            outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FSConstants.RT_NAME_CCNA_OD);
            odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'');
            outletDispenserList.addAll(odList);            
            
            odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'');
            outletDispenserList.addAll(odList);
           
            odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'');
            outletDispenserList.addAll(odList);
            
            odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'');
            outletDispenserList.addAll(odList);
            
        }
        for(FS_Outlet_Dispenser__c od:outletDispenserList){
            od.FS_Equip_Type__c='7000';
        }
        insert outletDispenserList;
    }
    
    private static testMethod void testSingleRec9k(){
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            //get test data 
            List<FS_Outlet_Dispenser__c> outletDispenserList=[SELECT Id,RecordTypeId,FS_Equip_Type__c,FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,FS_Spicy_Cherry__c FROM FS_Outlet_Dispenser__c 
                                                               LIMIT 1];
            FS_Brandset__c brandset9K=new FS_Brandset__c();
            brandset9K.Name='brandset9K';
            brandset9K.FS_Effective_Start_Date__c =date.today();
            brandset9K.FS_Platform__c='9000';
            brandset9K.FS_Country__c='US';
            brandset9k.FS_Date_Brandset_is_available_for_Select__c=date.today();
            insert brandset9K;
            brandset9K.Name='brandset9KRename';
            update brandset9K;
            FS_Brandset__c brandsetRecord=[SELECT Id,FS_Platform__c,FS_Available_for_commercial_use__c,Available_for_Selection__c,FS_Effective_Start_Date__c,FS_Effective_End_Date__c FROM FS_Brandset__c
                                           WHERE FS_Platform__c INCLUDES (:LIT9K ) LIMIT 1];
            Test.startTest();
            FS_Cartridge__c cartridge9K=new FS_Cartridge__c();
            cartridge9K.Name='cartridge9K';
            cartridge9K.FS_Brand__c='Dr Pepper/Diet Dr Pepper';
            cartridge9K.FS_Platform__c='9000';
            cartridge9K.FS_Country__c='US';
            insert cartridge9K;
            
            //custom setting FET Airwatch Data Mapping
            // FS_FET_Airwatch_Data_Mapping__c
            final List<FS_FET_Airwatch_Data_Mapping__c> airwatchDetails = new List<FS_FET_Airwatch_Data_Mapping__c>();
            FS_FET_Airwatch_Data_Mapping__c custSetting = new FS_FET_Airwatch_Data_Mapping__c();
            //AgitatedBrand
            custSetting.Name='AgitatedBrand:Barqs';
            custSetting.FS_Field_name__c='FS_7000_Series_Agitated_Brands_Selection__c';
            custSetting.FS_Airwatch_Value__c='Barqs1';
            custSetting.FS_FET_Value__c='Barqs';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            //static selections
            custSetting= new FS_FET_Airwatch_Data_Mapping__c();
            custSetting.Name='StaticBrand1';
            custSetting.FS_Airwatch_Value__c='Raspberry1';
            custSetting.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
            custSetting.FS_FET_Value__c='Raspberry';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            //SpicyCherry
            
            custSetting= new FS_FET_Airwatch_Data_Mapping__c();
            custSetting.Name='SpicyCherry1';
            custSetting.FS_Airwatch_Value__c='Dr Pepper/Diet Dr Pepper1';
            custSetting.FS_Field_name__c='FS_Spicy_Cherry__c';
            custSetting.FS_FET_Value__c='Dr Pepper/Diet Dr Pepper';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            insert airwatchDetails;
            
            FS_Association_Brandset__c assoBrand=new FS_Association_Brandset__c();  
            assoBrand.FS_Platform__c='9000';
            assoBrand.FS_Brandset__c=brandsetRecord.Id;
            assoBrand.FS_Outlet_Dispenser__c=outletDispenserList.get(0).id;
            
            insert assoBrand;
            
            FS_Brandsets_Cartridges__c brandsetCartRecord= new FS_Brandsets_Cartridges__c();
            brandsetCartRecord.FS_Brandset__c=brandsetRecord.id;
            brandsetCartRecord.FS_Cartridge__c=cartridge9K.Id;
            brandsetCartRecord.FS_Airwatch_Flag__c='A';
            insert brandsetCartRecord;
            FSUpdateOutletDispenserAttributes.updateOutletDispenserAttributes(new List<FS_Outlet_Dispenser__c>{outletDispenserList.get(0)});   
            System.assertEquals(1, outletDispenserList.size());
            Test.stopTest();    
        }
    }
    
    private static testMethod void testSingleRec7kStatic(){
        
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            List<FS_Outlet_Dispenser__c> outletDispenserList=[SELECT Id,RecordTypeId,FS_Equip_Type__c,FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,FS_Spicy_Cherry__c FROM FS_Outlet_Dispenser__c 
                                                              WHERE FS_Equip_Type__c=:LIT7K LIMIT 1];
            FS_Brandset__c brandset7K=new FS_Brandset__c();
            brandset7K.Name='brandset7K';
            brandset7K.FS_Effective_Start_Date__c =date.today();
            brandset7K.FS_Platform__c='7000';
            brandset7K.FS_Country__c='US';
            brandset7k.FS_Date_Brandset_is_available_for_Select__c=date.today();
            insert brandset7K;
            brandset7K.Name='brandset7KRename';
            update brandset7K;
            FS_Brandset__c brandsetRecord=[SELECT Id,FS_Platform__c,FS_Available_for_commercial_use__c,Available_for_Selection__c,FS_Effective_Start_Date__c,FS_Effective_End_Date__c FROM FS_Brandset__c
                                           WHERE FS_Platform__c INCLUDES (:LIT7K ) LIMIT 1];
            
            List<FS_Cartridge__c> cartListStatic=new List<FS_Cartridge__c>();
            FS_Cartridge__c cartridge7K=new FS_Cartridge__c();
            cartridge7K.Name='cartridge7K';
            cartridge7K.FS_Brand__c='Raspberry';
            cartridge7K.FS_Platform__c='7000';
            cartridge7K.FS_Country__c='US';
            cartListStatic.add(cartridge7K);
            
            FS_Cartridge__c cartridge7KFuze=new FS_Cartridge__c();
            cartridge7KFuze.Name='cartridge7KFuze';
            cartridge7KFuze.FS_Brand__c='Fuze';
            cartridge7KFuze.FS_Platform__c='7000';
            cartridge7KFuze.FS_Country__c='US';
            cartListStatic.add(cartridge7KFuze);
            
            FS_Cartridge__c cartridge7KVw=new FS_Cartridge__c();
            cartridge7KVw.Name='cartridge7KVw';
            cartridge7KVw.FS_Brand__c='Vitaminwater';
            cartridge7KVw.FS_Platform__c='7000';
            cartridge7KVw.FS_Country__c='US';
            cartListStatic.add(cartridge7KVw);
            
            FS_Cartridge__c cartridge7KVw1=new FS_Cartridge__c();
            cartridge7KVw1.Name='cartridge7KVw1';
            cartridge7KVw1.FS_Flavor__c='Vitaminwater';
            cartridge7KVw1.FS_Platform__c='7000';
            cartridge7KVw1.FS_Country__c='US';
            cartListStatic.add(cartridge7KVw1);
            
            FS_Cartridge__c cartridge7KP=new FS_Cartridge__c();
            cartridge7KP.Name='cartridge7KP';
            cartridge7KP.FS_Brand__c='Pibb';
            cartridge7KP.FS_Platform__c='7000';
            cartridge7KP.FS_Country__c='US';
            cartListStatic.add(cartridge7KP);
            
            FS_Cartridge__c cartridge7KPF=new FS_Cartridge__c();
            cartridge7KPF.Name='cartridge7KPF';
            cartridge7KPF.FS_Flavor__c='Pibb';
            cartridge7KPF.FS_Platform__c='7000';
            cartridge7KPF.FS_Country__c='US';
            cartListStatic.add(cartridge7KPF);
            
            FS_Cartridge__c cartridge7KPF1=new FS_Cartridge__c();
            cartridge7KPF1.Name='cartridge7KPF';
            cartridge7KPF1.FS_Flavor__c='Barqs';
            cartridge7KPF1.FS_Platform__c='7000';
            cartridge7KPF1.FS_Country__c='US';
            cartListStatic.add(cartridge7KPF1);
            
            insert cartListStatic;
            
            //custom setting FET Airwatch Data Mapping
            // FS_FET_Airwatch_Data_Mapping__c
            final List<FS_FET_Airwatch_Data_Mapping__c> airwatchDetails = new List<FS_FET_Airwatch_Data_Mapping__c>();
            FS_FET_Airwatch_Data_Mapping__c custSetting = new FS_FET_Airwatch_Data_Mapping__c();
            //AgitatedBrand
            custSetting= new FS_FET_Airwatch_Data_Mapping__c();
            custSetting.Name='AgitatedBrand:Barqs';
            custSetting.FS_Field_name__c='FS_7000_Series_Agitated_Brands_Selection__c';
            custSetting.FS_Airwatch_Value__c='Barqs1';
            custSetting.FS_FET_Value__c='Barqs';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            
            //AgitatedBrand1
            custSetting= new FS_FET_Airwatch_Data_Mapping__c();
            custSetting.Name='AgitatedBrand1:Pibb';
            custSetting.FS_Field_name__c='FS_7000_Series_Agitated_Brands_Selection__c';
            custSetting.FS_Airwatch_Value__c='Pibb1';
            custSetting.FS_FET_Value__c='Pibb';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            //static selections
            custSetting= new FS_FET_Airwatch_Data_Mapping__c();
            custSetting.Name='StaticBrand1';
            custSetting.FS_Airwatch_Value__c='Raspberry1';
            custSetting.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
            custSetting.FS_FET_Value__c='Raspberry';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            
            custSetting= new FS_FET_Airwatch_Data_Mapping__c();
            custSetting.Name='StaticBrand2';
            custSetting.FS_Airwatch_Value__c='Fuze1';
            custSetting.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
            custSetting.FS_FET_Value__c='Fuze';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            
            custSetting= new FS_FET_Airwatch_Data_Mapping__c();
            custSetting.Name='StaticBrand3';
            custSetting.FS_Airwatch_Value__c='Vitamin Water1';
            custSetting.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
            custSetting.FS_FET_Value__c='Vitamin Water';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            
            //SpicyCherry
            
            custSetting= new FS_FET_Airwatch_Data_Mapping__c();
            custSetting.Name='SpicyCherry1';
            custSetting.FS_Airwatch_Value__c='Dr Pepper/Diet Dr Pepper1';
            custSetting.FS_Field_name__c='FS_Spicy_Cherry__c';
            custSetting.FS_FET_Value__c='Dr Pepper/Diet Dr Pepper';
            custSetting.FS_Active__c =true;
            airwatchDetails.add(custSetting);
            
            insert airwatchDetails;
            
            FS_Association_Brandset__c assoBrand=new FS_Association_Brandset__c();  
            assoBrand.FS_Platform__c='7000';
            assoBrand.FS_Brandset__c=brandsetRecord.Id;
            assoBrand.FS_Outlet_Dispenser__c=outletDispenserList.get(0).id;
            
            insert assoBrand;
            Test.startTest();
            List<FS_Brandsets_Cartridges__c> brCartList=new List<FS_Brandsets_Cartridges__c>();
            for(FS_Cartridge__c cart:cartListStatic){
                FS_Brandsets_Cartridges__c brandsetCartRecord= new FS_Brandsets_Cartridges__c();
                brandsetCartRecord.FS_Brandset__c=brandsetRecord.id;
                brandsetCartRecord.FS_Cartridge__c=cart.Id;
                brCartList.add(brandsetCartRecord);
            }
            insert brCartList;
            FSUpdateOutletDispenserAttributes.updateOutletDispenserAttributes(new List<FS_Outlet_Dispenser__c>{outletDispenserList.get(0)});
            System.assertEquals(1, outletDispenserList.size());
            Test.stopTest(); 
        }
    }
}