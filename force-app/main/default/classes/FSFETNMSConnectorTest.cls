/**************************************************************************************
Apex Class Name     : FSFETNMSConnectorTest
Version             : 1.0
Function            : This test class is for FSFETNMSConnector Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys                                 Original Version 
*                     05/29/2018          Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSFETNMSConnectorTest {
    
    public static Account headQuarterAcc, outletAcc1, outletAcc, outletAcc2, outletAccInt, chainAccInt, bottler;
    public static FS_Execution_Plan__c executionPlan;
    public static FS_Installation__c installation1, installation;
    static RecordType rectypeInternational;
    public static User tuser,coordinatorUser;
    public static FS_Outlet_Dispenser__c outletDispenser,outletDispenser1,outletDispenser2,dispenserInt1;    
    private static final string SERIES_7K='7000';
    private static final string MODEL_2K='2000';
    public static Shipping_Form__c shippingForm;
    public static Dispenser_Model__c dispenserModel;   
    private static final string POWER_RAS='Powerade;raspberry';
    private static final string SHOW='Show';
    private static final string YES='Yes';
    private static final string PIBB1='Pibb;';
    private static final string BRAND_SELECTION='2 Static/1 Agitated';
    private static final string HIDE='Hide';
    private static final string NO_VAL='No';
    private static final string BRAND_SELECTION1='0 Static/2 Agitated';
    private static Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.systemAdmin);
    
    //--------------------------------------------------------------------------------------
    //Create Test Data For Account Update
    //--------------------------------------------------------------------------------------
    private static void createTestData(){        
        final List<Account> outletList=new List<Account>();       
        
        HeadQuarterAcc = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        coordinatorUser = FSTestUtil.createUser(null,1,FSConstants.dispenserCoordinatorProfile,true);
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        
        system.runAs(coordinatorUser){
            shippingForm = FSTestUtil.createShippingForm(true);
        }
        dispenserModel = FSTestUtil.createDispenserModel(true, MODEL_2K);   
        
        chainAccInt = new Account();
        chainAccInt.Name = 'Test Chain 1';
        chainAccInt.FS_ACN__c='898989ICH';
        chainAccInt.RecordTypeId = FSConstants.RECORD_TYPE_CHAIN;
        insert chainAccInt;
        system.debug('Limits after inserting single outlet:-'+Limits.getQueries());
        outletAccInt = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET_INT,headQuarterAcc.Id, false);
        outletAccInt.FS_Chain__c = chainAccInt.id;
        outletAccInt.FS_ACN__c = '76876987698';        
        outletAccInt.shippingCountry = 'NZ';
        outletAccInt.Is_Default_FET_International_Outlet__c = true;
        outletAccInt.FS_Is_Address_Validated__c = 'Yes';
        outletAccInt.shippingCity = 'Test City';
        outletAccInt.shippingState = 'Test State';
        outletAccInt.shippingStreet = 'Test Street';
        outletAccInt.shippingPostalCode = '12345';      
        insert  outletAccInt;
        //Creates Outlet Accounts
        outletAcc = FSTestUtil.createAccountOutlet('Test Outlet 1',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, true);
        outletAcc.Name = 'Test Outlet';
        outletAcc.Bottler_Name__c='Coca-Cola Refreshments Canada';
        outletAcc.shippingCity = 'Test City';
        outletAcc.shippingState = 'Test State';
        outletAcc.shippingStreet = 'Test Street';
        outletAcc.shippingPostalCode = '12345'; 
        outletList.add(outletAcc);
        
        
        outletAcc1 = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, false);        
        outletAcc1.shippingcountry = 'NZ';
        outletAcc1.ShippingCity = 'Hyderabad';
        outletAcc1.shippingstate ='';
        outletAcc1.ShippingStreet='1/2/brundavan';
        outletAcc1.ShippingPostalCode='4546576';
        outletAcc1.FS_SAP_ID__c = '12346';
        outletAcc1.Bottler_Name__c='Coca-Cola Enterprises';        
        outletList.add(outletAcc1);
        
        outletAcc2 = FSTestUtil.createAccountOutlet('Test Outlet International',FSConstants.RECORD_TYPE_OUTLET,HeadQuarterAcc.Id, false);        
        outletAcc2.shippingcountry = 'NZ';
        outletList.add(outletAcc2);
        
        upsert outletList;
        
        system.debug('Limits after inserting the outlets:-'+Limits.getQueries());
        //Creates execution plan
        executionPlan = FSTestUtil.createExecutionPlan(FSConstants.EXECUTIONPLAN,HeadQuarterAcc.Id, true);
        final List<FS_Installation__c> installList=new List<FS_Installation__c>();
        //creates installation
        installation = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc.Id,false);      
        
        installation.FS_Valid_fill_required__c='Yes';
        //installation.FS_Original_Install_Date__c = ]'
        installList.add(installation);
        
        installation1 = FSTestUtil.createInstallationAcc(FSConstants.NEWINSTALLATION,executionPlan.Id,outletAcc1.Id,false);        
        
        installation1.FS_Valid_Fill_Approved__c=false;
        installList.add(installation1);
        insert installList;
        
        rectypeInternational=[SELECT Id, Name, sObjectType, DeveloperName FROM RecordType where Name=:FSConstants.OD_RECORD_TYPE_INT AND sObjectType = :FSConstants.ODOBJECTNAME limit 1];      
        //to fill the mandatory details and not inserting the OD to database
        outletDispenser1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outletAcc.id,null,false);   
        
        dispenserInt1 = new FS_Outlet_Dispenser__c();
        dispenserInt1.FS_Outlet__c = outletAccInt.id;    
        dispenserInt1.recordTypeId = rectypeInternational.Id;
        
        system.debug('Limits after inserting the outlet dispensers:-'+Limits.getQueries());
        
        //OCR-1 custom setting FET Airwatch Data Mapping
        // FS_FET_Airwatch_Data_Mapping__c
        final List<FS_FET_Airwatch_Data_Mapping__c> airwatchDetails = new List<FS_FET_Airwatch_Data_Mapping__c>();   
        FS_FET_Airwatch_Data_Mapping__c dataServiceDetails = new FS_FET_Airwatch_Data_Mapping__c();
        //AgitatedBrand
        
        dataServiceDetails.Name='AgitatedBrand:Barqs';
        dataServiceDetails.FS_Field_name__c='FS_7000_Series_Agitated_Brands_Selection__c';
        dataServiceDetails.FS_Airwatch_Value__c='Barqs1';
        dataServiceDetails.FS_FET_Value__c='Barqs';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='AgitatedBrand:Dr Pepper';
        dataServiceDetails.FS_Field_name__c='FS_7000_Series_Agitated_Brands_Selection__c';
        dataServiceDetails.FS_Airwatch_Value__c='Dr Pepper1';
        dataServiceDetails.FS_FET_Value__c='Dr Pepper';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='AgitatedBrand:Pibb';
        dataServiceDetails.FS_Airwatch_Value__c='Pibb1';
        dataServiceDetails.FS_FET_Value__c='Pibb';
        dataServiceDetails.FS_Field_name__c='FS_7000_Series_Agitated_Brands_Selection__c';
        
        airwatchDetails.add(dataServiceDetails);
        
        //CEEnabled
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='CEEnabled:Yes';
        dataServiceDetails.FS_Airwatch_Value__c= 'Yes1';
        dataServiceDetails.FS_Field_name__c='FS_CE_Enabled__c';
        dataServiceDetails.FS_FET_Value__c='Yes';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='CEEnabled:No';
        dataServiceDetails.FS_Airwatch_Value__c='No1';
        dataServiceDetails.FS_Field_name__c='FS_CE_Enabled__c';
        dataServiceDetails.FS_FET_Value__c='No';
        airwatchDetails.add(dataServiceDetails);
        
        //Code
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46099';
        dataServiceDetails.FS_Airwatch_Value__c='46099 : Freestyle GS1 Silver1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46099 : Freestyle GS1 Silver';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46100';
        dataServiceDetails.FS_Airwatch_Value__c='46100 : Freestyle GS1 Red1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46100 : Freestyle GS1 Red';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46101';
        dataServiceDetails.FS_Airwatch_Value__c='46101 : Freestyle GS1 Black1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46101 : Freestyle GS1 Black';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46102';
        dataServiceDetails.FS_Airwatch_Value__c='46102: Freestyle GS2 Crew Serve1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46102: Freestyle GS2 Crew Serve';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46126';
        dataServiceDetails.FS_Airwatch_Value__c='46126 : Freestyle GS1 Silver - Wood Crate1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46126 : Freestyle GS1 Silver - Wood Crate';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46127';
        dataServiceDetails.FS_Airwatch_Value__c='46127 : Freestyle GS1 Red - Wood Crate1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46127 : Freestyle GS1 Red - Wood Crate';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46130';
        dataServiceDetails.FS_Airwatch_Value__c='46130 : Freestyle GS1 Red - Cruise Ship1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46130 : Freestyle GS1 Red - Cruise Ship';
        airwatchDetails.add(dataServiceDetails);
        
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46293';
        dataServiceDetails.FS_Airwatch_Value__c='46293 : Freestyle GS1 Silver - Cruise Ship1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46293 : Freestyle GS1 Silver - Cruise Ship';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46379';
        dataServiceDetails.FS_Airwatch_Value__c='46379: Extended Splashplate - without Legs1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46379: Extended Splashplate - without Legs';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46401';
        dataServiceDetails.FS_Airwatch_Value__c='46401: Standard Splashplate with Driptray, Cuprest and optional leg kit1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46401: Standard Splashplate with Driptray, Cuprest and optional leg kit';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46402';
        dataServiceDetails.FS_Airwatch_Value__c='46402 : SUBWAY Extended Splashplate - without Legs *1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46402 : SUBWAY Extended Splashplate - without Legs *';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46403';
        dataServiceDetails.FS_Airwatch_Value__c='46403: SUBWAY Standard Splashplate with Driptray, Cuprest and optional leg kit1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46403: SUBWAY Standard Splashplate with Driptray, Cuprest and optional leg kit';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46128';
        dataServiceDetails.FS_Airwatch_Value__c='46128 : Freestyle GS1 Black - Wood Crate1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46128 : Freestyle GS1 Black - Wood Crate';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Code:46129';
        dataServiceDetails.FS_Airwatch_Value__c='46129: Freestyle GS2 Crew Serve - Wood Crate1';
        dataServiceDetails.FS_Field_name__c='FS_Code__c';
        dataServiceDetails.FS_FET_Value__c='46129: Freestyle GS2 Crew Serve - Wood Crate';
        airwatchDetails.add(dataServiceDetails);
        
        //color
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Color:Black';
        dataServiceDetails.FS_Airwatch_Value__c='Black1';
        //dataServiceDetails.FS_Field_name__c='FS_Color__c';
        dataServiceDetails.FS_FET_Value__c='Black';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Color:Red';
        dataServiceDetails.FS_Airwatch_Value__c='Red1';
        //dataServiceDetails.FS_Field_name__c='FS_Color__c';
        dataServiceDetails.FS_FET_Value__c='Red';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Color:Silver';
        dataServiceDetails.FS_Airwatch_Value__c='Silver1';
        //dataServiceDetails.FS_Field_name__c='FS_Color__c';
        dataServiceDetails.FS_FET_Value__c='Silver';
        airwatchDetails.add(dataServiceDetails);
        
        //Dasani
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Dasani1';
        dataServiceDetails.FS_Airwatch_Value__c='Hide1';
        dataServiceDetails.FS_Field_name__c='FS_Dasani__c';
        dataServiceDetails.FS_FET_Value__c='Hide';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Dasani2';
        dataServiceDetails.FS_Airwatch_Value__c='Show1';
        dataServiceDetails.FS_Field_name__c='FS_Dasani__c';
        dataServiceDetails.FS_FET_Value__c='Show';
        airwatchDetails.add(dataServiceDetails);
        
        //FavoriteOrMix        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='FavoriteOrMix1';
        dataServiceDetails.FS_Airwatch_Value__c='Yes1';
       // dataServiceDetails.FS_Field_name__c='FS_FAV_MIX__c';
        dataServiceDetails.FS_FET_Value__c='Yes';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='FavoriteOrMix2';
        dataServiceDetails.FS_Airwatch_Value__c='No1';
       // dataServiceDetails.FS_Field_name__c='FS_FAV_MIX__c';
        dataServiceDetails.FS_FET_Value__c='No';
        airwatchDetails.add(dataServiceDetails);
        
        //LTO        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='LTO-1';
        dataServiceDetails.FS_Airwatch_Value__c='LTO21';
        dataServiceDetails.FS_Field_name__c='FS_LTO__c';
        dataServiceDetails.FS_FET_Value__c='LTO2';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='LTO-2';
        dataServiceDetails.FS_Airwatch_Value__c='LTO31';
        dataServiceDetails.FS_Field_name__c='FS_LTO__c';
        dataServiceDetails.FS_FET_Value__c='LTO3';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='LTO-3';
        dataServiceDetails.FS_Airwatch_Value__c='LTO11';
        dataServiceDetails.FS_Field_name__c='FS_LTO__c';
        dataServiceDetails.FS_FET_Value__c='Share a Coke';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='LTO-4';
        dataServiceDetails.FS_Airwatch_Value__c='1';
        dataServiceDetails.FS_Field_name__c='FS_LTO__c';
        dataServiceDetails.FS_FET_Value__c='No LTO';
        airwatchDetails.add(dataServiceDetails);
        
        //Model      
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Model1';
        dataServiceDetails.FS_Airwatch_Value__c='20001';
        dataServiceDetails.FS_Field_name__c='FS_Model__c';
        dataServiceDetails.FS_FET_Value__c='2000';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Model2';
        dataServiceDetails.FS_Airwatch_Value__c='30001';
        dataServiceDetails.FS_Field_name__c='FS_Model__c';
        dataServiceDetails.FS_FET_Value__c='3000';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Model3';
        dataServiceDetails.FS_Airwatch_Value__c='70001';
        dataServiceDetails.FS_Field_name__c='FS_Model__c';
        dataServiceDetails.FS_FET_Value__c='7000';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Model4';
        dataServiceDetails.FS_Airwatch_Value__c='80001';
        dataServiceDetails.FS_Field_name__c='FS_Model__c';
        dataServiceDetails.FS_FET_Value__c='8000';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='Model5';
        dataServiceDetails.FS_Airwatch_Value__c='90001';
        dataServiceDetails.FS_Field_name__c='FS_Model__c';
        dataServiceDetails.FS_FET_Value__c='9000';
        airwatchDetails.add(dataServiceDetails);
        
        //PromoEnabled
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='PromoEnabled1';
        dataServiceDetails.FS_Airwatch_Value__c='Yes1';
        dataServiceDetails.FS_Field_name__c='FS_Promo_Enabled__c';
        dataServiceDetails.FS_FET_Value__c='Yes';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='PromoEnabled2';
        dataServiceDetails.FS_Airwatch_Value__c='No1';
        dataServiceDetails.FS_Field_name__c='FS_Promo_Enabled__c';
        dataServiceDetails.FS_FET_Value__c='No';
        airwatchDetails.add(dataServiceDetails);
        
        //SoftIceAdjust
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='SoftIceAdjust1';
        dataServiceDetails.FS_Airwatch_Value__c='No1';
        dataServiceDetails.FS_Field_name__c='FS_Soft_Ice_Adjust_Flag__c';
        dataServiceDetails.FS_FET_Value__c='No';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='SoftIceAdjust2';
        dataServiceDetails.FS_Airwatch_Value__c='Yes1';
        dataServiceDetails.FS_Field_name__c='FS_Soft_Ice_Adjust_Flag__c';
        dataServiceDetails.FS_FET_Value__c='Yes';
        airwatchDetails.add(dataServiceDetails);
        
        //SpicyCherry
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='SpicyCherry1';
        dataServiceDetails.FS_Airwatch_Value__c='Dr Pepper/Diet Dr Pepper1';
        dataServiceDetails.FS_Field_name__c='FS_Spicy_Cherry__c';
        dataServiceDetails.FS_FET_Value__c='Dr Pepper/Diet Dr Pepper';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='SpicyCherry2';
        dataServiceDetails.FS_Airwatch_Value__c='Pibb/Pibb Zero1';
        dataServiceDetails.FS_Field_name__c='FS_Spicy_Cherry__c';
        dataServiceDetails.FS_FET_Value__c='Pibb/Pibb Zero';
        airwatchDetails.add(dataServiceDetails);
        
        //static selections
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='StaticBrand1';
        dataServiceDetails.FS_Airwatch_Value__c='Raspberry1';
        dataServiceDetails.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
        dataServiceDetails.FS_FET_Value__c='Raspberry';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='StaticBrand2';
        dataServiceDetails.FS_Airwatch_Value__c='Fuze1';
        dataServiceDetails.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
        dataServiceDetails.FS_FET_Value__c='Fuze';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='StaticBrand3';
        dataServiceDetails.FS_Airwatch_Value__c='Powerade1';
        dataServiceDetails.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
        dataServiceDetails.FS_FET_Value__c='POWERade';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='StaticBrand4';
        dataServiceDetails.FS_Airwatch_Value__c='Hi-C/Vitamin Water1';
        dataServiceDetails.FS_Field_name__c='FS_7000_Series_Static_Brands_Selections__c';
        dataServiceDetails.FS_FET_Value__c='Hi-C';
        airwatchDetails.add(dataServiceDetails); 
        
        //validfill
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='ValidFill1';
        dataServiceDetails.FS_Airwatch_Value__c='Yes1';
        dataServiceDetails.FS_Field_name__c='FS_Valid_Fill__c';
        dataServiceDetails.FS_FET_Value__c='Yes';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='ValidFill2';
        dataServiceDetails.FS_Airwatch_Value__c='No1';
        dataServiceDetails.FS_Field_name__c='FS_Valid_Fill__c';
        dataServiceDetails.FS_FET_Value__c='No';
        airwatchDetails.add(dataServiceDetails); 
        
        //WaterButton
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='WaterButton1';
        dataServiceDetails.FS_Airwatch_Value__c='Show1';
        dataServiceDetails.FS_Field_name__c='FS_Water_Button__c';
        dataServiceDetails.FS_FET_Value__c='Show';
        airwatchDetails.add(dataServiceDetails);
        
        dataServiceDetails= new FS_FET_Airwatch_Data_Mapping__c();
        dataServiceDetails.Name='WaterButton2';
        dataServiceDetails.FS_Airwatch_Value__c='Hide1';
        dataServiceDetails.FS_Field_name__c='FS_Water_Button__c';
        dataServiceDetails.FS_FET_Value__c='Hide';
        airwatchDetails.add(dataServiceDetails); 
        
        
        insert airwatchDetails;
        
        //Platform types custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        System.Debug('End of createTestData');
        
    }   
    //This method checks whether there is create call happening when insertion of new OD
    private static testMethod void checkCreateCallTest() {
        createTestData();    
        
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='7000';
        outletDispenser1.FS_Serial_Number2__c = 'AHKJ1775';
        outletDispenser1.Installation__c = installation.id;
        //outletDispenser1.FS_Color__c = 'Black1';
        outletDispenser1.FS_IsActive__c = true ;
        outletDispenser1.FS_LTO__c='LTO11';
        //outletDispenser1.FS_Model__c='90001';
        outletDispenser1.FS_Valid_Fill__c='No1';
        outletDispenser1.FS_7000_Series_Brands_Option_Selections__c  ='2 Static/1 Agitated';
        outletDispenser1.FS_7000_Series_Static_Brands_Selections__c='Powerade1;Hi-C/Vitamin Water1';
        outletDispenser1.FS_7000_Series_Agitated_Brands_Selection__c = 'Barqs1';
        outletDispenser1.Brand_Set__c='GER Default Collection';
        outletDispenser1.FS_Soft_Ice_Adjust_Flag__c='No1';
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            INSERT outletDispenser1;
            system.debug('checkCreateCallTest() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};          
                final Map<String,String> numberList = new map<String,String>();
            numberList.put(outletDispenser1.FS_Serial_Number2__c,outletDispenser1.FS_ACN_NBR__c);
            
            try{
                Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
                FSFETNMSConnector.airWatchSynchronousCall(lstOutletDispensersID,NULL);
            }catch(Exception ex){
                System.debug('Exception- '+ex);
            }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()==200);
        }
        Test.stopTest();
    }    
    
    //This method checks for the failure scenario of create call to AW
    private static testMethod void checkCreateCallFailureTest() {
        createTestData();
        //account outletAcc=[SELECT id from account where name LIKE 'Test Outlet'];
        //FS_Installation__c installation=[SELECT id from FS_Installation__c where FS_Outlet__c=:outletAcc.Id];
        
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='7000';
        outletDispenser1.FS_Serial_Number2__c = 'AHKJ1775';
        outletDispenser1.Installation__c = installation.id;
        //outletDispenser1.FS_Color__c = 'Black1';
        outletDispenser1.FS_IsActive__c = true ;
        outletDispenser1.FS_LTO__c='LTO11';
        //outletDispenser1.FS_Model__c='90001';
        outletDispenser1.FS_Valid_Fill__c='No1';
        outletDispenser1.FS_7000_Series_Brands_Option_Selections__c  ='2 Static/1 Agitated';
        outletDispenser1.FS_7000_Series_Static_Brands_Selections__c='Powerade1;Hi-C/Vitamin Water1';
        outletDispenser1.FS_7000_Series_Agitated_Brands_Selection__c = 'Barqs1';
        outletDispenser1.Brand_Set__c='GER Default Collection';
        outletDispenser1.FS_Soft_Ice_Adjust_Flag__c='No1';
        Test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            INSERT outletDispenser1;
            
            system.debug('checkCreateCallFailureTest() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};         
                Map<String,String> numberList = new map<String,String>();
            numberList.put(outletDispenser1.FS_Serial_Number2__c,outletDispenser1.FS_ACN_NBR__c);
            
            try{
                Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMockFailure());
                FSFETNMSConnector.airWatchSynchronousCall(lstOutletDispensersID,NULL);
            }catch(Exception ex){
                System.debug('Exception- '+ex);
            }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMockFailure http = new FSFETNMSConnectorMockFailure();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()!=200);
        }
        Test.stopTest();
    } 
    
    //This method checks whether there is create call happening when insertion of new OD 8000 series
    private static testMethod void checkCreateCall8KTest() {
        createTestData();
        Test.startTest();
        
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c = 'AHKJ17788';
        outletDispenser1.Installation__c = installation.id;
        //outletDispenser1.FS_Color__c = 'Black1';
        outletDispenser1.FS_IsActive__c = true ;
        outletDispenser1.FS_LTO__c='LTO11';
        //outletDispenser1.FS_Model__c='90001';
        outletDispenser1.FS_Valid_Fill__c='No1';
        outletDispenser1.FS_7000_Series_Agitated_Brands_Selection__c = 'N/A to 8000/9000 Series';
        outletDispenser1.FS_Spicy_Cherry__c='Dr Pepper/Diet Dr Pepper';
        outletDispenser1.FS_Soft_Ice_Adjust_Flag__c='No1';
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            INSERT outletDispenser1;
            
            system.debug('checkCreateCall8KTest() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};        
                Map<String,String> numberList = new map<String,String>();
            numberList.put(outletDispenser1.FS_Serial_Number2__c,outletDispenser1.FS_ACN_NBR__c);
            
            try{
                Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
                FSFETNMSConnector.airWatchSynchronousCall(lstOutletDispensersID,NULL);
            }catch(Exception ex){
                System.debug('Exception- '+ex);
            }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()==200);
        }
        Test.stopTest();
    }    
    //International OD creation AW test-Asynchronous
    private static testMethod void createIntODAsync() {
        createTestData();
        Test.startTest();
        
        //dispenserInt1.FS_Model__c = MODEL_2K;        
        dispenserInt1.Shipping_Form__c = shippingForm.id;
        dispenserInt1.FSInt_Dispenser_Type__c = dispenserModel.id;
        dispenserInt1.FS_Serial_Number2__c = 'TEST_7687';
        dispenserInt1.Warehouse_Country__c = 'New Zealand';
        dispenserInt1.Warehouse_Name__c = 'New Zealand #1';
        dispenserInt1.Brand_Set__c = 'NZ Default Collection';
        dispenserInt1.Brands_Not_Selected__c = 'Test Brand';
        dispenserInt1.FS_Planned_Install_Date__c = system.today(); 
        dispenserInt1.FS_IsActive__c = true;
        dispenserInt1.FS_Status__c = 'New';
        dispenserInt1.Send_Create_Request__c = true;
        dispenserInt1.Ownership_Type__c = FSConstants.Bottler;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            insert dispenserInt1;
            
            system.debug('createIntODAsync() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{dispenserInt1.id};       
                
                try{
                    Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
                    FSFETNMSConnector.airWatchAsynchronousCall(lstOutletDispensersID,NULL);
                }catch(Exception ex){
                    System.debug('Exception- '+ex);
                }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()==200);
        }
        Test.stopTest();
        
    }  
    //International OD creation AW test-Synchronous
    private static testMethod void createIntODSync() {
        createTestData();
        Test.startTest();
        
        //dispenserInt1.FS_Model__c = MODEL_2K;        
        dispenserInt1.Shipping_Form__c = shippingForm.id;
        dispenserInt1.FSInt_Dispenser_Type__c = dispenserModel.id;
        dispenserInt1.FS_Serial_Number2__c = 'TEST_7687';
        dispenserInt1.Warehouse_Country__c = 'New Zealand';
        dispenserInt1.Warehouse_Name__c = 'New Zealand #1';
        dispenserInt1.Brand_Set__c = 'NZ Default Collection';
        dispenserInt1.FS_Planned_Install_Date__c = system.today(); 
        dispenserInt1.FS_IsActive__c = true;
        dispenserInt1.FS_Status__c = 'New';
        dispenserInt1.Brand_Set__c = 'CAN Default Collection';        
        dispenserInt1.Send_Create_Request__c = true;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            insert dispenserInt1;
            
            system.debug('createIntODSync() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{dispenserInt1.id};
                
                try{
                    Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
                    FSFETNMSConnector.airWatchSynchronousCall(lstOutletDispensersID,NULL);
                }catch(Exception ex){
                    System.debug('Exception- '+ex);
                }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()==200);
        }
        Test.stopTest();
    }  
    
    //Update OD brands active date as today,OD UPdate call to AW - this method tests for batch class calls
    private static testMethod void updatetODDomesticSync(){
        createTestData();
        test.startTest();
        outletDispenser1.FS_Equip_Type__c = SERIES_7K;
        //outletDispenser1.FS_Dasani__c=SHOW;
        insert outletDispenser1;
        
        outletDispenser1.FS_Dasani_New__c = HIDE;
        outletDispenser1.FS_Dasani_Settings_Effective_Date__c=Date.today();
      //  outletDispenser1.FS_FAV_MIX__c=YES;
       // outletDispenser1.FS_FAV_MIX_New__c=NO_VAL;
       // outletDispenser1.FS_FAV_MIX_Effective_Date__c=Date.today();
        outletDispenser1.FS_Spicy_Cherry__c=YES;
        outletDispenser1.FS_Spicy_Cherry_New__c = NO_VAL;
        outletDispenser1.FS_Spicy_Cherry_Effective_Date__c=Date.today();
        outletDispenser1.FS_Promo_Enabled__c=YES;
        outletDispenser1.FS_Promo_Enabled_Effective_Date__c =Date.today();
        outletDispenser1.FS_Promo_Enabled_New__c = NO_VAL;
        outletDispenser1.FS_CE_Enabled__c=NO_VAL;
        
        outletDispenser1.FS_Valid_Fill__c=YES;
        outletDispenser1.FS_Valid_Fill_Settings_Effective_Date__c=Date.today();
        outletDispenser1.FS_Valid_Fill_New__c = NO_VAL; 
        outletDispenser1.FS_7000_Series_Agitated_Brands_Selection__c =PIBB1;
        outletDispenser1.FS_7000_Series_Static_Brands_Selections__c =POWER_RAS;
        outletDispenser1.FS_7000_Series_Brands_Option_Selections__c=BRAND_SELECTION;
        outletDispenser1.FS_7000_Series_Brands_Selection_New__c = BRAND_SELECTION1;
        outletDispenser1.FS_7000_Series_Hide_Water_Button_New__c=SHOW;
        outletDispenser1.FS_Brand_Selection_Value_Effective_Date__c =Date.today();
        outletDispenser1.FS_7000_Series_Hide_Water_Effective_Date__c=Date.today();
        outletDispenser1.Brand_Set_Effective_Date__c=Date.today();
        //outletDispenser1.FS_LTO_Effective_Date__c=Date.today();
        //outletDispenser1.FS_Water_Hide_Show_Effective_Date__c=Date.today();
        //outletDispenser1.FS_CE_Enabled_Effective_Date__c=Date.today();
        outletDispenser1.FS_Serial_Number2__c='zpl0987652';
        outletDispenser1.FS_Brandset_Effective_Date__c=Date.today();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            update outletDispenser1;
            
            system.debug('UpdatetODDomesticSync() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};
                
                try{
                    Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
                    FSFETNMSConnector.airWatchSynchronousCall(lstOutletDispensersID,NULL);
                }catch(Exception ex){
                    System.debug('Exception- '+ex);
                }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()==200);
        }
        test.stopTest();
    }
    
    //Update OD brands active date as today,OD UPdate call to AW failure code- this method tests for batch class calls
    private static testMethod void updatetODDomesticSyncFail(){
        createTestData();
        test.startTest();
        outletDispenser1.FS_Equip_Type__c = SERIES_7K;
        //outletDispenser1.FS_Dasani__c=SHOW;
        insert outletDispenser1;
        
        outletDispenser1.FS_Dasani_New__c = HIDE;
        outletDispenser1.FS_Dasani_Settings_Effective_Date__c=Date.today();
       // outletDispenser1.FS_FAV_MIX__c=YES;
       // outletDispenser1.FS_FAV_MIX_New__c=NO_VAL;
       // outletDispenser1.FS_FAV_MIX_Effective_Date__c=Date.today();
        outletDispenser1.FS_Spicy_Cherry__c=YES;
        outletDispenser1.FS_Spicy_Cherry_New__c = NO_VAL;
        outletDispenser1.FS_Spicy_Cherry_Effective_Date__c=Date.today();
        outletDispenser1.FS_CE_Enabled_New__c=YES;
        outletDispenser1.FS_Promo_Enabled__c=YES;
        outletDispenser1.FS_Promo_Enabled_Effective_Date__c =Date.today();
        outletDispenser1.FS_Promo_Enabled_New__c = NO_VAL;
        outletDispenser1.FS_Valid_Fill__c=YES;
        outletDispenser1.FS_Valid_Fill_Settings_Effective_Date__c=Date.today();
        outletDispenser1.FS_Valid_Fill_New__c = NO_VAL; 
        outletDispenser1.FS_7000_Series_Agitated_Brands_Selection__c =PIBB1;
        outletDispenser1.FS_7000_Series_Static_Brands_Selections__c =POWER_RAS;
        outletDispenser1.FS_7000_Series_Brands_Option_Selections__c=BRAND_SELECTION;
        outletDispenser1.FS_7000_Series_Brands_Selection_New__c = BRAND_SELECTION1;
        outletDispenser1.FS_Brand_Selection_Value_Effective_Date__c =Date.today();
        outletDispenser1.FS_7000_Series_Hide_Water_Button_New__c=SHOW;
        outletDispenser1.FS_7000_Series_Hide_Water_Effective_Date__c=Date.today();
        outletDispenser1.Brand_Set_Effective_Date__c=Date.today();
        //outletDispenser1.FS_LTO_Effective_Date__c=Date.today();
        //outletDispenser1.FS_Water_Hide_Show_Effective_Date__c=Date.today();
        outletDispenser1.FS_CE_Enabled_Effective_Date__c=Date.today();
        outletDispenser1.FS_Serial_Number2__c='zpl0987652';
        outletDispenser1.FS_Brandset_Effective_Date__c=Date.today();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            update outletDispenser1;
            
            system.debug('UpdatetODDomesticSyncFail() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};
                Map<Id, String> mapDispenserIdstrDispenserAttrChange = new Map<Id, String>();
            mapDispenserIdstrDispenserAttrChange.put(outletDispenser1.id,'Both');
            try{
                Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMockFailure());
                FSFETNMSConnector.airWatchSynchronousCall(lstOutletDispensersID,mapDispenserIdstrDispenserAttrChange);
            }catch(Exception ex){
                System.debug('Exception- '+ex);
            }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMockFailure http = new FSFETNMSConnectorMockFailure();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()!=200);
        }
        test.stopTest();
    }
    
    //Update OD brands active date as today,OD UPdate call to AW - Async call is for trigger calls
    private static testMethod void updatetODDomesticAsync(){
        createTestData();
        test.startTest();
        outletDispenser1.FS_Equip_Type__c = SERIES_7K;
        //outletDispenser1.FS_Dasani__c=SHOW;
        insert outletDispenser1;
        
        outletDispenser1.FS_Dasani_New__c = HIDE;
        outletDispenser1.FS_Dasani_Settings_Effective_Date__c=Date.today();
        //outletDispenser1.FS_FAV_MIX__c=YES;
       // outletDispenser1.FS_FAV_MIX_New__c=NO_VAL;
       // outletDispenser1.FS_FAV_MIX_Effective_Date__c=Date.today();
        outletDispenser1.FS_Spicy_Cherry__c=YES;
        outletDispenser1.FS_Spicy_Cherry_New__c = NO_VAL;
        outletDispenser1.FS_Spicy_Cherry_Effective_Date__c=Date.today();
        outletDispenser1.FS_CE_Enabled__c=NO_VAL;
        outletDispenser1.FS_CE_Enabled_New__c=YES;
        outletDispenser1.FS_Promo_Enabled__c=YES;
        outletDispenser1.FS_Promo_Enabled_Effective_Date__c =Date.today();
        outletDispenser1.FS_Promo_Enabled_New__c = NO_VAL;
        outletDispenser1.FS_Valid_Fill__c=YES;
        outletDispenser1.FS_Valid_Fill_Settings_Effective_Date__c=Date.today();
        outletDispenser1.FS_Valid_Fill_New__c = NO_VAL; 
        outletDispenser1.FS_7000_Series_Agitated_Brands_Selection__c =PIBB1;
        outletDispenser1.FS_7000_Series_Static_Brands_Selections__c =POWER_RAS;
        outletDispenser1.FS_7000_Series_Brands_Option_Selections__c=BRAND_SELECTION;
        outletDispenser1.FS_7000_Series_Brands_Selection_New__c = BRAND_SELECTION1;
        outletDispenser1.FS_7000_Series_Hide_Water_Button_New__c=SHOW;
        outletDispenser1.FS_Brand_Selection_Value_Effective_Date__c =Date.today();
        outletDispenser1.FS_7000_Series_Hide_Water_Effective_Date__c=Date.today();
        outletDispenser1.Brand_Set_Effective_Date__c=Date.today();
        //outletDispenser1.FS_LTO_Effective_Date__c=Date.today();
        //outletDispenser1.FS_Water_Hide_Show_Effective_Date__c=Date.today();
        outletDispenser1.FS_CE_Enabled_Effective_Date__c=Date.today();
        outletDispenser1.FS_Serial_Number2__c='zpl0987652';
        outletDispenser1.FS_Brandset_Effective_Date__c=Date.today();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            update outletDispenser1;
            
            system.debug('UpdatetODDomesticAsync() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};       
                
                try{
                    Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
                    FSFETNMSConnector.airWatchAsynchronousCall(lstOutletDispensersID,NULL);
                }catch(Exception ex){
                    System.debug('Exception- '+ex);
                }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()==200);
        }
        test.stopTest();
    }
    
    //Test the failure Airwatch call for deleting domestic OD
    private static testMethod void deleteDomesticODFailure(){
        createTestData();
        outletDispenser1.FS_Equip_Type__c= SERIES_7K;
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Serial_Number2__c='zpl548756';
        outletDispenser1.FS_Equip_Type__c=SERIES_7K;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        insert outletDispenser1; 
        outletDispenser1.FS_IsActive__c=false;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            update outletDispenser1;
            
            system.debug('deleteDomesticODFailure() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};        
                Map<String,String> numberList = new map<String,String>();
            numberList.put(outletDispenser1.FS_Serial_Number2__c,outletDispenser1.FS_ACN_NBR__c);
            
            try{
                Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMockFailure());
                FSFETNMSConnector.deleteMasterAssetData(lstOutletDispensersID);
            }catch(Exception ex){
                System.debug('Exception- '+ex);
            }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMockFailure http = new FSFETNMSConnectorMockFailure();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()!=200);
        }
        Test.stopTest();
    }
    
    private static testMethod void deleteMasterAssetDataTest(){
        createTestData();
        outletDispenser1.FS_Equip_Type__c= SERIES_7K;
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Serial_Number2__c='zpl548756';
        outletDispenser1.FS_Equip_Type__c=SERIES_7K;
        test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
            insert outletDispenser1; 
            
            system.debug('deleteDomesticODFailure() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};          
                Map<String,String> numberList = new map<String,String>();
            numberList.put(outletDispenser1.FS_Serial_Number2__c,outletDispenser1.FS_ACN_NBR__c);
            
            try{
                Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMockFailure());
                FSFETNMSConnector.airWatchAsynchronousCall(lstOutletDispensersID,NULL);
                FSFETNMSConnector.deleteMasterAssetData(lstOutletDispensersID);
            }catch(Exception ex){
                System.debug('Exception- '+ex);
            }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMockFailure http = new FSFETNMSConnectorMockFailure();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()!=200);
        }
        Test.stopTest();
    }
    
    //Test the Airwatch call for deleting domestic OD
    private static testMethod void deleteDomesticOD(){
        createTestData();
        outletDispenser1.FS_Equip_Type__c= SERIES_7K;
        outletDispenser1.FS_IsActive__c=true;
        outletDispenser1.FS_Serial_Number2__c='zpl548756';
        outletDispenser1.FS_Equip_Type__c=SERIES_7K;
        test.startTest();
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
            insert outletDispenser1; 
            outletDispenser1.FS_IsActive__c=false;
            
            update outletDispenser1;
            
            system.debug('deleteDomesticOD() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            Set<id> lstOutletDispensersID = new Set<id>{outletDispenser1.id};        
                Map<String,String> numberList = new map<String,String>();
            numberList.put(outletDispenser1.FS_Serial_Number2__c,outletDispenser1.FS_ACN_NBR__c);
            
            try{
                Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
                FSFETNMSConnector.deleteMasterAssetData(lstOutletDispensersID);
            }catch(Exception ex){
                System.debug('Exception- '+ex);
            }
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()==200);
        }
        Test.stopTest();
    }
    
    
    //Test to check airwatch call when placeholder chain/HQ is created for orphan outlet
    private static testMethod void aWCallForOrphanOutletTest(){
        createTestData();
        Test.startTest();
        
        outletDispenser1.FS_Outlet__c = outletAcc.Id;
        outletDispenser1.FS_Equip_Type__c  ='8000';
        outletDispenser1.FS_Serial_Number2__c = 'AHKJ17786';
        outletDispenser1.Installation__c = installation.id;
        //outletDispenser1.FS_Color__c = 'Black1';
        outletDispenser1.FS_Spicy_Cherry__c='Dr Pepper/Diet Dr Pepper';
        outletDispenser1.FS_IsActive__c = true ;
        outletDispenser1.FS_LTO__c='LTO11';
        //outletDispenser1.FS_Model__c='90001';
        outletDispenser1.FS_Valid_Fill__c='No1';
        outletDispenser1.FS_7000_Series_Agitated_Brands_Selection__c = 'N/A to 8000/9000 Series';
        outletDispenser1.FS_Soft_Ice_Adjust_Flag__c='No1';
        outletDispenser1.FS_Soft_Ice_Manufacturer__c='ABCD';
        outletDispenser1.FS_Migration_to_AW_Required__c=False;
        //outletDispenser1.FS_Model__c='80001';
        INSERT outletDispenser1;
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            system.debug('aWCallForOrphanOutletTest() - starting test case setup - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            
            String header='';      
            
            Map<Id,String> testMap=new Map<Id,String>();
            Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
            testMap.put(outletDispenser1.Id,header);
            System.Queueable job = new DeferredHandler(testMap);
            System.enqueueJob(job);
            HttpRequest req = new HttpRequest();
            FSFETNMSConnectorMock http = new FSFETNMSConnectorMock();
            HTTPResponse res = http.respond(req);
            system.assert(res.getStatusCode()==200);
        }
        Test.stopTest();        
    }
}