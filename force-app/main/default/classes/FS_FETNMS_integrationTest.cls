/**************************************************************************************
Apex Class Name     : FS_FETNMS_integrationTest
Version             : 1.0
Function            : This test class is for FS_FETNMS_integration Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@istest
private class FS_FETNMS_integrationTest {
    
    public static string COLON=';';
    public static string BARQS = 'Barqs';
    public static string HIDE = 'Hide';
    public static string NO = 'No';
    public static string YES = 'Yes';
    public static string SHOW = 'Show';
    public static string END_POINT = 'https://www.salesforce.com/';
    public static string HEADERPARAMNAME = 'Authorization';
    public static string HEADERPARAMVAL = 'BasicRzR3d2VEamJSeHBrVHNNNWlYRzdDczVORnN3V0J3MEQ6cEdvQnFTT1dhS3I1NnFGdw==';
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5; 
    
    static testmethod void postest() { 
        
        final Date today=System.today()+1;
        final Account acc= new account ();
        acc.name='outlet test';
        acc.RecordTypeId= FSConstants.RECORD_TYPE_OUTLET;
        acc.shippingCountry='US';
        final String domesticRecordType = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get('CCNA Dispenser').getRecordTypeId();
        insert acc;
        final Account accNew2=new Account(Name='Test Account 2',RecordTypeId= FSConstants.RECORD_TYPE_HQ);
        insert accNew2;
        
        final FS_Execution_Plan__c newEP=new FS_Execution_Plan__c(FS_Headquarters__c=accNew2.id);
        insert newEP;
        
        final FS_Installation__c newObject=new FS_Installation__c(FS_Outlet__c=acc.id,FS_of_7000_Series_Units_being_relocated__c =0,
                                                                  FS_of_8000_Series_units_being_relocated__c=0,FS_of_9000_Series_units_being_relocated__c=0,
                                                                  FS_Remove_Disconnect_Date__c=today,FS_Execution_Plan__c=newEP.id);
        insert newObject;
        
        List<Platform_Type_ctrl__c> listplatform = new List<Platform_Type_ctrl__c>();
		platformTypes=new Platform_Type_ctrl__c();
		platformTypes.Name='updateBrands';
        platformTypes.Platforms__c='7000';
        listplatform.add(platformTypes);
		platformTypes1=new Platform_Type_ctrl__c();
		platformTypes1.Name='EquipmentTypeCheckForNMSUpdateCall';
        platformTypes1.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes1);
        platformTypes2=new Platform_Type_ctrl__c();
		platformTypes2.Name='WaterHideCheck';
        platformTypes2.Platforms__c='8000,9000';
        listplatform.add(platformTypes2);
        platformTypes3=new Platform_Type_ctrl__c();
		platformTypes3.Name='all_Platform';
        platformTypes3.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes3);
        platformTypes4=new Platform_Type_ctrl__c();
		platformTypes4.Name='updatecrewServeDasani';
        platformTypes4.Platforms__c='8000';
        listplatform.add(platformTypes4);
        platformTypes5=new Platform_Type_ctrl__c();
		platformTypes5.Name='updateSelfServeDasani';
        platformTypes5.Platforms__c='9000';
        listplatform.add(platformTypes5);
        insert listplatform; 
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        final FS_Outlet_Dispenser__c odNew1 =new FS_Outlet_Dispenser__c(FS_Outlet__c=acc.Id,
                                                                        FS_7000_Series_Agitated_Brands_Selection__c = BARQS, FS_7000_Series_Static_Brands_Selections__c =  'Hi-C / Vitamin Water'+COLON+'POWERade', 
                                                                        FS_7000_Series_Brands_Option_Selections__c = '2 Static/1 Agitated' ,
                                                                        FS_7000_Series_Hide_Water_Button__c= HIDE,
                                                                        FS_Water_Button__c=HIDE,FS_Serial_Number2__c = 'HPTEST101',RecordTypeId = domesticRecordType,
                                                                        FS_CE_Enabled__c = NO,
                                                                        FS_LTO__c='LTO1',
                                                                        FS_Promo_Enabled__c=YES,FS_Spicy_Cherry__c = 'Dr. Pepper/Diet Dr. Pepper',
                                                                        FS_Valid_Fill__c=NO,
                                                                        FS_Soft_Ice_Adjust_Flag__c='true',FS_Soft_Ice_Manufacturer__c='xyz',FS_Calculated_Time_Zone__c='india' );
        insert odNew1; 
        
        
        
        final FS_Outlet_Dispenser__c odUpdate=new FS_Outlet_Dispenser__c(Id=odNew1.Id,
                                                                         FS_7000_Series_Brands_Selection_New__c = '0 Static/2 Agitated' ,
                                                                         //FS_7000_Series_Static_Selection_New__c = 'Hi-C / Vitamin Water'+COLON+'Raspberry',
                                                                         FS_7000_Series_Agitated_Selections_New__c='Dr Pepper'+COLON+BARQS,
                                                                         FS_7000_Series_Hide_Water_Button_New__c = SHOW,FS_Water_Button_New__c =SHOW,
                                                                         FS_CE_Enabled_New__c=YES,
                                                                         FS_Dasani_New__c=SHOW,
                                                                         //FS_FAV_MIX_New__c = NO,
                                                                         FS_LTO_New__c = 'LTO2',
                                                                         FS_Spicy_Cherry_New__c = 'Pibb/Pibb Zero',
                                                                         FS_Promo_Enabled_New__c = NO,
                                                                         FS_Valid_Fill_New__c= YES,
                                                                         FS_7000_Series_Hide_Water_Effective_Date__c=today, 
                                                                         FS_Brand_Selection_Value_Effective_Date__c = today , 
                                                                         FS_CE_Enabled_Effective_Date__c = today,FS_Dasani_Settings_Effective_Date__c =today ,
                                                                        // FS_FAV_MIX_Effective_Date__c=today  , 
                                                                         FS_LTO_Effective_Date__c= today , 
                                                                         FS_Promo_Enabled_Effective_Date__c= today , 
                                                                         FS_Spicy_Cherry_Effective_Date__c=today , 
                                                                         
                                                                         FS_Valid_Fill_Settings_Effective_Date__c=today , FS_Water_Hide_Show_Effective_Date__c=today);
        update odUpdate;                                
     /*   final OutboundServiceDetails__c setting = new OutboundServiceDetails__c();
        setting.Name = 'MasterDataChange';
        setting.End_Point__c= END_POINT;
        setting.HeaderParamName__c= HEADERPARAMNAME;
        setting.HeaderParamValue__c =HEADERPARAMVAL;

        insert setting;
        
        final OutboundServiceDetails__c setting2 = new OutboundServiceDetails__c();
        setting2.Name = 'MasterDataCreate';
        setting2.End_Point__c= END_POINT;
        setting2.HeaderParamName__c= HEADERPARAMNAME;
        setting2.HeaderParamValue__c =HEADERPARAMVAL;

        insert setting2;
	*/
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            
            Test.startTest();
            
            final String cronExp = '0 0 23 * * ?';
            final FS_Schedule_FETNMS_integration scheObj = new FS_Schedule_FETNMS_integration();
            system.schedule('Test Scheduler Job', cronExp, scheObj);
            Test.stopTest();
            
            final FS_Outlet_Dispenser__c checkOD =[select FS_7000_Series_Agitated_Selections_New__c from FS_Outlet_Dispenser__c where id=:odNew1.Id];
            System.assertEquals(checkOD.FS_7000_Series_Agitated_Selections_New__c, 'Barqs;Dr Pepper');
        }
        
    }
    
    static testmethod void batchTest() { 
        final Date today=System.today()+1;
        final Date schedulerDate=today.addDays(5);
        final  Account acc= new account ();
        acc.name='outlet test';
        acc.RecordTypeId= FSConstants.RECORD_TYPE_OUTLET;
        acc.shippingCountry='US';
        final String domesticRecordType = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get('CCNA Dispenser').getRecordTypeId();
        insert acc;
        final Account accNew2=new Account(Name='Test Account 2',RecordTypeId= FSConstants.RECORD_TYPE_HQ);
        insert accNew2;
        
        final FS_Execution_Plan__c newEP=new FS_Execution_Plan__c(FS_Headquarters__c=accNew2.id);
        insert newEP;
        
        final FS_Installation__c newObject=new FS_Installation__c(FS_Outlet__c=acc.id,FS_of_7000_Series_Units_being_relocated__c =0,
                                                                  FS_of_8000_Series_units_being_relocated__c=0,FS_of_9000_Series_units_being_relocated__c=0,
                                                                  FS_Remove_Disconnect_Date__c=today,FS_Execution_Plan__c=newEP.id);
        insert newObject;
        
        List<Platform_Type_ctrl__c> listplatform = new List<Platform_Type_ctrl__c>();
		platformTypes=new Platform_Type_ctrl__c();
		platformTypes.Name='updateBrands';
        platformTypes.Platforms__c='7000';
        listplatform.add(platformTypes);
		platformTypes1=new Platform_Type_ctrl__c();
		platformTypes1.Name='EquipmentTypeCheckForNMSUpdateCall';
        platformTypes1.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes1);
        platformTypes2=new Platform_Type_ctrl__c();
		platformTypes2.Name='WaterHideCheck';
        platformTypes2.Platforms__c='8000,9000';
        listplatform.add(platformTypes2);
        platformTypes3=new Platform_Type_ctrl__c();
		platformTypes3.Name='all_Platform';
        platformTypes3.Platforms__c='7000,8000,9000';
        listplatform.add(platformTypes3);
        platformTypes4=new Platform_Type_ctrl__c();
		platformTypes4.Name='updatecrewServeDasani';
        platformTypes4.Platforms__c='8000';
        listplatform.add(platformTypes4);
        platformTypes5=new Platform_Type_ctrl__c();
		platformTypes5.Name='updateSelfServeDasani';
        platformTypes5.Platforms__c='9000';
        listplatform.add(platformTypes5);
        insert listplatform; 
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        final FS_Outlet_Dispenser__c odNew1 =new FS_Outlet_Dispenser__c(FS_Outlet__c=acc.Id,
                                                                        FS_7000_Series_Agitated_Brands_Selection__c = BARQS, FS_7000_Series_Static_Brands_Selections__c =  'Hi-C / Vitamin Water'+COLON+'POWERade', 
                                                                        FS_7000_Series_Brands_Option_Selections__c = '2 Static/1 Agitated' ,
                                                                        FS_7000_Series_Hide_Water_Button__c= HIDE,
                                                                        FS_Water_Button__c=HIDE,FS_Serial_Number2__c = 'HPTEST101',RecordTypeId = domesticRecordType,
                                                                        FS_CE_Enabled__c = NO,
                                                                        FS_LTO__c='LTO1',Hide_Water_Dispenser__c=HIDE,
                                                                        FS_Promo_Enabled__c=YES,FS_Spicy_Cherry__c = 'Dr. Pepper/Diet Dr. Pepper',
                                                                        FS_Valid_Fill__c=NO,
                                                                        Brand_Set__c='CAN Default Collection',
                                                                        FS_Soft_Ice_Adjust_Flag__c='true',FS_Soft_Ice_Manufacturer__c='xyz',FS_Calculated_Time_Zone__c='india' );
        insert odNew1; 
        
        
        final FS_Outlet_Dispenser__c odUpdate=new FS_Outlet_Dispenser__c(Id=odNew1.Id,
                                                                         FS_7000_Series_Brands_Selection_New__c = '0 Static/2 Agitated' ,
                                                                         //FS_7000_Series_Static_Selection_New__c = 'Hi-C / Vitamin Water'+COLON+'Raspberry',
                                                                         FS_7000_Series_Agitated_Selections_New__c='Dr Pepper'+COLON+BARQS,
                                                                         FS_7000_Series_Hide_Water_Button_New__c = SHOW,FS_Water_Button_New__c =SHOW,
                                                                         FS_CE_Enabled_New__c=YES,
                                                                         FS_Dasani_New__c=SHOW,
                                                                        // FS_FAV_MIX_New__c = NO,
                                                                         FS_LTO_New__c = 'LTO2',
                                                                         FS_Spicy_Cherry_New__c = 'Pibb/Pibb Zero',
                                                                         FS_Promo_Enabled_New__c = NO,
                                                                         FS_Valid_Fill_New__c= YES,
                                                                         FS_7000_Series_Hide_Water_Effective_Date__c=schedulerDate, 
                                                                         FS_Brand_Selection_Value_Effective_Date__c = schedulerDate, 
                                                                         FS_CE_Enabled_Effective_Date__c = schedulerDate,FS_Dasani_Settings_Effective_Date__c =schedulerDate ,
                                                                        // FS_FAV_MIX_Effective_Date__c=schedulerDate, 
                                                                         FS_LTO_Effective_Date__c= schedulerDate, 
                                                                         FS_Promo_Enabled_Effective_Date__c= schedulerDate, 
                                                                         FS_Spicy_Cherry_Effective_Date__c=schedulerDate,
                                                                         Hide_Water_Dispenser__c=HIDE,
                                                                         FS_Hide_Water_Dispenser_New__c=SHOW,FS_showHideWater_Effective_date__c=schedulerDate,
                                                                         Brand_Set_New__c='GER Default Collection',
                                                                         Brand_Set_Effective_Date__c=today,
                                                                         FS_Valid_Fill_Settings_Effective_Date__c=schedulerDate, FS_Water_Hide_Show_Effective_Date__c=schedulerDate);
        update odUpdate;                                
     /*   
        final OutboundServiceDetails__c setting = new OutboundServiceDetails__c();
        setting.Name = 'MasterDataChange';
        setting.End_Point__c= END_POINT;
        setting.HeaderParamName__c= HEADERPARAMNAME;
        setting.HeaderParamValue__c =HEADERPARAMVAL;
        
        
        insert setting;
        
        final OutboundServiceDetails__c setting2 = new OutboundServiceDetails__c();
        setting2.Name = 'MasterDataCreate';
        setting2.End_Point__c= END_POINT;
        setting2.HeaderParamName__c= HEADERPARAMNAME;
        setting2.HeaderParamValue__c =HEADERPARAMVAL;
        
        
        insert setting2;
        */
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
            
            Test.startTest();
            
            final FS_FETNMS_integration batchObj= new FS_FETNMS_integration(schedulerDate);
            Database.executeBatch(batchObj);
            Test.stopTest();
            final FS_Outlet_Dispenser__c checkOD =[select FS_7000_Series_Agitated_Selections_New__c from FS_Outlet_Dispenser__c where id=:odNew1.Id];
            
        }
    }
    
}