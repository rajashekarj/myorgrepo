/*********************************************************************************************************
Name         : FSTestUtil
Created By   : Pallavi Sharma (Appiro)
Created Date : 17 - Sep - 2013
Usage        : Utility class for Test Classes
***********************************************************************************************************/
@isTest
public with sharing class FSTestUtil {
    
    public static final String HIDE='Hide';
    public static final String TESTVALUE='Test';
    
      /*** @desc Generic method to create Account object record based on the record type
         * @param Boolean $isInsert- true inserts a record
         * @param String accountName- Name of the Account
         * @param Id recType - record type Id of Account
         * @return Account
         */
    public static Account createTestAccount(final String accountName,final Id recType,final Boolean isInsert) {
        final Account testAccount = new Account();
        //checks rectype is null or not
        if(recType!=FSConstants.NULLVALUE){
            testAccount.RecordTypeId=recType;
            if(recType==FSConstants.RECORD_TYPE_VENDOR){
                testAccount.FS_Vendor_Type__c = 'General Contractor';
            }
        }
        if(FSUtil.isNotNullOrBlank(accountName)){
            testAccount.Name = accountName;
        }else{
            testAccount.Name='Test Account';
        }                
        if(isInsert) {
            insert testAccount;
        }
        return testAccount;
    }    

      /*** @desc Generic method to create Account object record based on the record type and Headquarter Id
         * @param Boolean $isInsert- true inserts a record
         * @param String accountName- Name of the Account
         * @param Id recType - record type Id of Account
         * @param Id accHeadQtrId - Headquarter Id of Account
         * @return Account
         */
    public static Account createAccountOutlet(final String accountName,final Id rectype,final Id accHeadQtrId,final Boolean isInsert){
        final Account accOutlet = new Account();
        if(recType!=FSConstants.NULLVALUE){
            accOutlet.RecordTypeId=recType; 
            if(recType==FSConstants.RECORD_TYPE_OUTLET_INT){
                accOutlet.Bottler_Name__c='Coca-Cola Amatil Limited';
            }
        }  
       if(FSUtil.isNotNullOrBlank(accountName)){
            accOutlet.Name = accountName;
        }else{
            accOutlet.Name='Test Account';
        } 
        accOutlet.FS_Headquarters__c = accHeadQtrId;
        accOutlet.shippingcountry = 'US';
        accOutlet.ShippingPostalCode='87695';       
        if(isInsert){
            insert accOutlet;
        }
        return accOutlet;
    }    
    
      /*** @desc Generic method to create Execution Plan record based on the record type and Headquarter Id
         * @param Boolean $isInsert- true inserts a record
         * @param String recType - record type name of Execution Plan
         * @param Id accHeadQtrId - Headquarter Id of Account
         * @return FS_Execution_Plan__c
         */
    public static FS_Execution_Plan__c createExecutionPlan(final String recType,final Id headquartersId,final Boolean isInsert){
        final FS_Execution_Plan__c executionPlan = new FS_Execution_Plan__c();
        if(FSUtil.isNotNullOrBlank(recType)){
            executionPlan.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.sObjectType,recType);            
        }       
        executionPlan.FS_Headquarters__c = headquartersId;
        if(isInsert){
            insert executionPlan;
        }
        return executionPlan;
    }  
    
      /*** @desc Generic method to create Installation Plan record based on the record type and outlet Id
         * @param Boolean $isInsert- true inserts a record
         * @param String recType - record type name of Installation Plan
         * @param Id accountId - outlet Id of Account
         * @return FS_Installation__c
         */
    public static FS_Installation__c createInstallationAcc(final String recType,final Id executionPlanId,final Id accountId,final Boolean isInsert ){
        final FS_Installation__c installtion = new FS_Installation__c();        
        if(FSUtil.isNotNullOrBlank(recType)){
            installtion.RecordTypeId=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,recType);            
        }        
        installtion.FS_Execution_Plan__c = executionPlanId;
        installtion.FS_Outlet__c = accountId;       
        if(isInsert){
            installtion.FS_7000_Series_Agitated_Brands_Selection__c = 'N/A to 8000/9000 Series';
            installtion.FS_7000_Series_Brands_Option_Selections__c = 'N/A to 8000/9000 Series';
            installtion.FS_7000_Series_Statics_Brands_Selection__c = 'N/A to 8000/9000 Series';
            insert installtion;
        }
        return installtion;
    }   
    
      /*** @desc Generic method to create Customer Input Type object record
         * @param Boolean $isInsert- true inserts a record      
         * @return FS_Customer_Input_Type__c
         */
    public static FS_Customer_Input_Type__c createCustomerInputType(final Boolean isInsert){
        final FS_Customer_Input_Type__c customerInputType = new FS_Customer_Input_Type__c();
        if(isInsert) {
            insert customerInputType;
        }
        return customerInputType;
    }
      /*** @desc Generic method to create Customer Input object record
         * @param Boolean $isInsert- true inserts a record
         * @param Id accId - outlet Id of Account
         * @param Id hqID - Headquarter Id of Account
         * @return FS_Customer_Input__c
         */
    public static FS_Customer_Input__c createCustomerInput(final Boolean isInsert,final Id accId,final Id hqID){
        final FS_Customer_Input__c customerInput = new FS_Customer_Input__c();
        customerInput.FS_Account__c = accId;
        customerInput.HQ_CIF__c = hqID;            
        customerInput.FS_Requested_Cartridge_Order_Method__c = 'Coke Smart';
        if(isInsert) {
            insert customerInput;
        }
        return customerInput;
    }     
      /*** @desc Generic method to create Flavor Change object record based on the record type Name
         * @param Boolean $isInsert- true inserts a record
         * @param String recType - record type name of Flavor Change
         * @return Flavor_Change__c
         */
    public static Flavor_Change__c createFlavorChange(final String recType,final Boolean isInsert){
        final Flavor_Change__c flavorChange = new Flavor_Change__c();
        flavorChange.FS_X7000_Series_Brands_Option_Selections__c='2 Static/1 Agitated';
        flavorChange.FS_7000_Series_Agitated_Brands_Selection__c='Barqs';
        flavorChange.FS_7000_Series_Statics_Brands_Selection__c='POWERade; Raspberry';
        flavorChange.FS_7000_New_Hide_Show_Water_Button_del__c =HIDE;
        flavorChange.FS_7000_Series_Brand_Selection_EF_Date__c =date.today();
        flavorChange.FS_7000_New_Hide_Show_Water_Button_EF_Dt__c =date.today();
        flavorChange.FS_GS1_New_Hide_Show_Dasani_EF_DATE__c=date.today();
        flavorChange.FS_GS2_New_Hide_Show_Dasani_EF_DATE__c=date.today();
        flavorChange.FS_GS1_New_Hide_Show_Water_Button_EF_Dt__c=date.today();
        flavorChange.FS_GS2_New_Hide_Show_Water_Button_EF_Dt__c=date.today();
        flavorChange.FS_7000_New_Hide_Show_Water_Button_EF_Dt__c=date.today();
        flavorChange.FS_GS1_New_Spicy_Cherry_EF_Date__c=date.today();
        flavorChange.FS_GS2_New_Spicy_Cherry_EF_Date__c=date.today();
        flavorChange.FS_7000S_New_Spicy_Cherry_EF_Date__c=date.today();
        flavorChange.FS_GS1_New_Spicy_Cherry__c='Pibb/Pibb Zero';
        flavorChange.FS_GS2_New_Spicy_Cherry__c='Pibb/Pibb Zero';
        flavorChange.FS_7000S_New_Spicy_Cherry__c='Pibb/Pibb Zero';
        flavorChange.FS_GS1_New_Hide_Show_Water_Button__c=HIDE;
        flavorChange.FS_GS2_New_Hide_Show_Water_Button__c=HIDE;
        flavorChange.FS_GS2_New_Hide_Show_Dasani__c=HIDE;
        flavorChange.FS_GS1_New_Hide_Show_Dasani__c=HIDE;
        
        if(isInsert) {           
            insert flavorChange;
        }
        return flavorChange;
    }   
    
      /*** @desc Generic method to create Valid Fill object record based on the record type name
         * @param Boolean $isInsert- true inserts a record
         * @param String recType - record type name of Valid Fill
         * @return FS_Valid_Fill__c
         */
    public static FS_Valid_Fill__c createValidFill(final String recType,final Boolean isInsert){       
        final FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        if(FSUtil.isNotNullOrBlank(recType)){
            validFill.recordTypeId=FSUtil.getObjectRecordTypeId(FS_Valid_Fill__c.sObjectType,recType);           
        }        
        validFill.Valid_Fill_Request_Approval_Status__c='yes';
        validFill.FS_Valid_Fill_Effective_Date__c=date.today();
        if(isInsert) {
            insert validFill;
        }
        return validFill;
    }
    
      /*** @desc Generic method to create Post install Marketing object record
         * @param Boolean $isInsert- true inserts a record       
         * @return FS_Post_Install_Marketing__c
         */
    public static FS_Post_Install_Marketing__c createMarketingField(final Boolean isInsert){
        final FS_Post_Install_Marketing__c marketingField = new FS_Post_Install_Marketing__c();
        marketingField.FS_Enable_Consumer_Engagement__c='Yes';
        marketingField.FS_Promo_Enabled__c='Yes';
        marketingField.FS_Enable_CE_Effective_Date__c=date.today();
        marketingField.FS_Promo_Enabled_Effective_Date__c=date.today();
        marketingField.FS_FAV_MIX__c ='Yes';
        marketingField.FS_LTO__c='LTO1';
        marketingField.FS_LTO_Effective_Date__c=date.today();
        marketingField.FS_FAV_MIX_Effective_Date__c=date.today();
        if(isInsert) {
            insert marketingField;
        }
        return marketingField;
    }
    
    
      /*** @desc Generic method to create Contact object record
         * @param Boolean $isInsert- true inserts a record
         * @param String lastName - last name of the Contact
         * @param Id accountId - Id of the Account linking to contact
         * @return Contact
         */
    public static Contact createTestContact(final Id accountId,final String lastName,final Boolean isInsert) {
        final Contact con = new Contact();
        con.AccountId = accountId;
        con.FirstName = TESTVALUE;
        con.LastName = lastName;
        if(isInsert) {
            insert con;
        }
        return con;
    }    
    
    /*** @desc Generic method to create Market Id object record
         * @param Boolean $isInsert- true inserts a record
         * @param User user - User linking to market Id
         * @return FS_Market_ID__c
         */
    public static FS_Market_ID__c createMarketId(final User user,final Boolean isInsert) {
        final FS_Market_ID__c marketId = new FS_Market_ID__c();
        marketId.FS_User__c = user.Id;
        if(isInsert) {
            insert marketId;
        }
        return marketId;
    } 
    
    
    /*** @desc Generic method to create SP Aligned Zip object record based on record type name
         * @param Boolean $isInsert- true inserts a record
         * @param String zipCode - zip code for the record
         * @param String recordTypeName-Record type Name
         * @param Id providerId - Service Provider Id linking to this record
         * @return FS_SP_Aligned_Zip__c
         */
    public static FS_SP_Aligned_Zip__c createSPZipAligned(final String recordTypeName ,final String zipCode,
                                                          final Id providerId,final Boolean isInsert){
        final FS_SP_Aligned_Zip__c zip = new FS_SP_Aligned_Zip__c();
        zip.FS_Zip_Code__c = zipCode;
        zip.RecordTypeId = FSUtil.getObjectRecordTypeId(FS_SP_Aligned_Zip__c.SObjectType,recordTypeName);
        zip.FS_Service_Provider__c = providerId;
        if(isInsert) {
            insert zip;
        }
        return zip;
    }
    
    /*** @desc Generic method to create Initial order SAP object record
         * @param Boolean $isInsert- true inserts a record
         * @param String name - Name of the record
         * @param String brandGroup-Record type Name
         * @param Id providerId - Service Provider Id linking to this record
         * @return FS_Initial_Order_SAP_Data__c
         */
  /*commenting below lines of codes bcoz of deleting Initial Order SAP Object, FET5.0
   
    public static FS_Initial_Order_SAP_Data__c createSAPData(final String brandGroup ,final String name,final boolean isInsert){
        final FS_Initial_Order_SAP_Data__c ioSapData = new FS_Initial_Order_SAP_Data__c();
        ioSapData.Cartridge_Name__c='Test Cartridge';
        ioSapData.Brand_Group__c=brandGroup;
        ioSapData.Days_In_Stock__c=30;
        ioSapData.Cost_per_Unit__c=30;
        ioSapData.Name=name;
        ioSapData.Master_Data__c=true;
        ioSapData.Brand_Name__c='Test Brand';
        ioSapData.FS_7000_Package_Days_Capacity_1000__c=120;
        if(isInsert){
            insert ioSapData;
        }
        return ioSapData;
    }*/
    
    /*** @desc Generic method to create Outlet Dispenser object record based on record type
         * @param Boolean $isInsert- true inserts a record
         * @param String recType -recordtype name 
         * @param String equipType-Equip type value
         * @param Id outletid - outlet id of the Account
         * @param Id installationID -Installation Id linking to OD
         * @return FS_Outlet_Dispenser__c
         */
    public static FS_Outlet_Dispenser__c createOutletDispenserAllTypes(final String recType,final String equipType,final Id outletid,final ID installationID,final Boolean isInsert){
        final FS_Outlet_Dispenser__c outletDispenser = new FS_Outlet_Dispenser__c();       
        if(FSUtil.isNotNullOrBlank(recType)){
            outletDispenser.recordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType,recType);            
        }
        outletDispenser.FS_Outlet__c=outletid;
        outletDispenser.installation__c=installationID;        
        outletDispenser.FS_Equip_Type__c=equipType;
        if(isInsert){
            insert outletDispenser;
        }
        return outletDispenser;
    }   
    
     /*** @desc Generic method to create Technician Instruction object record based on record type
         * @param Boolean $isInsert- true inserts a record
         * @param String recordTypeName -recordtype name         
         * @return FS_IP_Technician_Instructions__c
         */
    public static FS_IP_Technician_Instructions__c createTechnicianInstructions(final String recordTypeName,final Boolean isInsert){
        final FS_IP_Technician_Instructions__c techInstruction = new FS_IP_Technician_Instructions__c();
        techInstruction.RecordTypeId = FSUtil.getObjectRecordTypeId(FS_IP_Technician_Instructions__c.SObjectType,recordTypeName);
        if(isInsert){
            insert techInstruction ;
        }
        return techInstruction ;
    }   
    
   /*** @desc Generic method to create Shipping Form object record
         * @param Boolean $isInsert- true inserts a record       
         * @return Shipping_Form__c
         */
    public static Shipping_Form__c createShippingForm(final Boolean isInsert){
        
        final Shipping_Form__c newForm = new Shipping_Form__c();
        newForm.Name = 'Test Shipping Form';
        newForm.FS_PO_Number__c = '876876';
        newForm.IC_Code__c = '1234';
        
        if(isInsert){
            insert newForm;          
        }      
        return newForm;      
    }
    
   /*** @desc Generic method to create Dispenser Model object record
         * @param Boolean $isInsert- true inserts a record
         * @param String dispensertype -Dispenser type Value         
         * @return Dispenser_Model__c
         */
    public static Dispenser_Model__c createDispenserModel(final Boolean isInsert,final String dispensertype){
        final Dispenser_Model__c newModel = new Dispenser_Model__c();
        newModel.Dimensions__c = '20 * 30 * 40';
        newModel.Dimension_unit_of_measure__c = 'cm';
        newModel.Dispenser_Type__c = dispensertype;
        newModel.IC_Code__c = '1234';
        newModel.IC_Code_Description__c = 'New IC Code';
        newModel.Series__c = dispenserType;
        newModel.Weight__c = '20';
        if(isInsert){
            insert newModel;
        }
        return newModel;
    }   
    
   /*** @desc Generic method to create User object record
         * @param Contact contact-Contact details for user  
         * @param Integer userNo- user number for user name
         * @param String profileName- name of the profile that needs to assign to user
         * @param Boolean $isInsert- true inserts a record           
         * @return User
         */
    public static User createUser(final Contact contact,final Integer userNo, final String profileName ,final Boolean isInsert){
        String nameOfProfile;
        if(String.IsBlank(profileName)){
            nameOfProfile=FSConstants.systemAdmin;
        } 
        else{
            nameOfProfile=profileName;
        }       
        final Profile pro = [select id from profile where name=:nameOfProfile];
        final User user = new User();
        user.FirstName = contact != null ? contact.FirstName : TESTVALUE;
        user.LastName = contact != null ? contact.LastName : 'user';
        user.Email = TESTVALUE+userNo+'@testdomain.com';
        user.Username = TESTVALUE+userNo+'@testdomain1.comtestuser';
        user.ProfileId = pro.Id;
        user.Alias = TESTVALUE+userNo;
        user.CommunityNickname = 'testusr'+userNo;
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.Phone = '+9009899900';
        user.IC_Code__c = '1234';
        user.contactId = contact != null ? contact.Id : null;
        if(profileName==FSConstants.dispenserCoordinatorProfile){
            user.Ownership_Type__c = FSConstants.bottler;
            user.Ownership__c = 'Bottler-1';       
            user.Dispenser_Country__c = 'NZ';
            user.dispenser_read_edit__c = 'Read';
        }
        if(isInsert) { 
            insert user;
        }
        return user;      
    } 
    
    /*** @desc Method to insert platform type custom settings*/
    public static void insertPlatformTypeCustomSettings(){
        //create platform type custom settings
        List<Platform_Type_ctrl__c> listplatform = new List<Platform_Type_ctrl__c>();
        final Platform_Type_ctrl__c platformTypes=new Platform_Type_ctrl__c();
        platformTypes.Name='updateBrands';
        platformTypes.Platforms__c='7000';
        listplatform.add(platformTypes);
        
        final Platform_Type_ctrl__c platformTypes1=new Platform_Type_ctrl__c();
        platformTypes1.Name='EquipmentTypeCheckForNMSUpdateCall';
        platformTypes1.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes1);
        
        final Platform_Type_ctrl__c platformTypes2=new Platform_Type_ctrl__c();
        platformTypes2.Name='WaterHideCheck';
        platformTypes2.Platforms__c='8000,9000';
        listplatform.add(platformTypes2);
        
        final Platform_Type_ctrl__c platformTypes3=new Platform_Type_ctrl__c();
        platformTypes3.Name='all_Platform';
        platformTypes3.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes3);
        
        final Platform_Type_ctrl__c platformTypes4 = new Platform_Type_ctrl__c();
        platformTypes4.Name='updatecrewServeDasani';
        platformTypes4.Platforms__c='8000';
        listplatform.add(platformTypes4);
        
        final Platform_Type_ctrl__c platformTypes5 = new Platform_Type_ctrl__c();
        platformTypes5.Name='updateSelfServeDasani';
        platformTypes5.Platforms__c='9000';
        listplatform.add(platformTypes5);
        insert listplatform; 
    }

}