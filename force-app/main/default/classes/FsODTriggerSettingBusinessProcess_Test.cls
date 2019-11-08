/*********************************************************************************************************
Name         : FsODTriggerSettingBusinessProcess_Test
Created By   : Infosys Limited 
Created Date : 5-may-2018
Usage        : Test Class for FsODTriggerSettingBusinessProcess

***********************************************************************************************************/
@isTest
public class FsODTriggerSettingBusinessProcess_Test {
    private static Account accchain,bottler,outlet,accHQ;
    @testsetup
    static void insertRecords()
    {   
        FSTestFactory.lstPlatform(); 
        List<FS_Outlet_Dispenser__c> lstFSODs = New List<FS_Outlet_Dispenser__c> ();
        List<FS_OD_Settings__c> ODSettingList = New List<FS_OD_Settings__c> ();
        bottler=FSTestUtil.createTestAccount('Test Bottler 1',FSConstants.RECORD_TYPE_BOTLLER,true);
        accchain = FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);
        //Create Headquarters
        accHQ = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        accHQ.FS_Chain__c = accchain.Id;
        insert accHQ;
        outlet = FSTestUtil.createAccountOutlet('Test Outlet',FSConstants.RECORD_TYPE_OUTLET,accHQ.id, true);
        FS_Outlet_Dispenser__c outletDispenser1 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RT_NAME_CCNA_OD,null,outlet.id,null,true);
        // FS_Outlet_Dispenser__c outletDispenser2 = FSTestUtil.createOutletDispenserAllTypes(FSConstants.RECTYPE_9k,null,outlet.id,null,true);
        system.debug('outletDispenser1'+outletDispenser1);
        // system.debug('outletDispenser2'+outletDispenser2);
        // lstFSODs.add(outletDispenser1);
        //  lstFSODs.add(outletDispenser2);
        
        //  insert lstFSODs;
        List<FOT_Profile__mdt> lstFOTProf = [SELECT Profile_Name__c FROM FOT_Profile__mdt];
        
    }
    
    @istest
    static void testMethod1()
    {
        
        Test.startTest();
        List<FS_OD_Settings__c> ODSetList = [SELECT Id,FS_Force_Restore__c,Cup_Name_1__c,Ice_Type__c,FS_OD_RecId__c FROM FS_OD_Settings__c];
        List<FS_OD_Settings__c> upODSet = New List<FS_OD_Settings__c>();
        
        For(FS_OD_Settings__c os :ODSetList ){
            os.Cup_Name_1__c = 'Test1';
            os.Default_Language_For_CUI__c = 'Test';
            //os.Ice_Type_Manufacturer__c = 'Test';
            os.Ice_Type__c ='Hard';
            os.Time_Zone__c = 'Test';
            os.FS_Calorie_Display_Enable__c ='Yes';
            os.Camera_Enabled__c = 'Yes';
            os.Default_Language_For_NCUI__c ='Eng';
            os.Microphone_Enabled__c = 'Yes';
            os.Proximity_Sensor_Enabled__c = 'Yes';
            os.Ambient_Screen_Update_Timer_Msec__c =20;
            os.Screen_Attract_Enabled__c = 'Yes';
            os.ADAHome_To_Home_Msec__c = 24;
            os.Are_You_Still_There_Msec__c = 34;
            os.ADAAfter_Pour_Msec__c = 44;
            os.To_Ambient_Msec__c = 55;
            os.Screen_Idle_To_Attract_Ms__c = 22;
            os.After_Pour_Msec__c = 33;
            os.Screen_Idle_To_Low_Power_Ms__c = 44;
            os.Speaker_Enabled__c = 'Yes';
            os.Start_Install_Window__c = 'Test';
            os.Cup_Name_1__c ='CUP1';
            os.Cup_Name_2__c ='CUP2';
            os.Cup_Name_3__c ='CUP3';
            os.Cup_Name_4__c ='CUP4';
            os.Cup_Name_5__c ='CUP5';
            os.Cup_Name_6__c ='CUP6';
            os.Cup_Size_1__c = 1;
            os.Cup_Size_2__c = 2;
            os.Cup_Size_3__c = 3;
            os.Cup_Size_4__c = 4;
            os.Cup_Size_5__c = 5;
            os.Cup_Size_6__c = 6;
            os.Service_Mode__c='Crew Serve';
            os.FS_Do_Not_Update_Content__c ='Yes';
            os.Do_Not_Update_Settings__c = 'Yes';
            os.Do_Not_Update_Rounding_Rules__c ='Yes';
            os.FS_Do_Not_Update_Software__c ='Yes';
            os.Allow_Language_Selection__c ='Yes';
            os.Screen_Idle_to_Home_After_Pour__c =45;
            os.Debug_Log_Level__c = 'DataV_Only';
            os.Water_Adjustment_Factor__c = 21;
            os.Debug_Flag_Expiration__c = System.now() + 1/24;
            os.Debug_Flag_Enabled__c = 'Yes';
            
            upODSet.add(os);
        }
        update upODSet;
        Test.stopTest();
    }
    
    @istest
    static void testMethod2()
    {
        // Test.startTest();
        List<FS_OD_Settings__c> ODSetList = [SELECT Id,FS_Force_Restore__c,Cup_Name_1__c,FS_OD_RecId__c FROM FS_OD_Settings__c];
        List<FS_OD_Settings__c> upODSet = New List<FS_OD_Settings__c>();
        
        List<FOT_Profile__mdt> lstFOTProf = [SELECT Profile_Name__c FROM FOT_Profile__mdt];
        
        final Profile fotOPAmin=FSTestFactory.getProfileId(FSConstants.USER_PROFILE_OP_ADMIN);
        final User fotOPAminUser=FSTestFactory.createUser(fotOPAmin.id);
        insert fotOPAminUser;
        system.runAs(fotOPAminUser){ 
            Test.startTest();
            For(FS_OD_Settings__c os :ODSetList ){
                
                os.Cup_Name_1__c = 'Test1';
                os.Default_Language_For_CUI__c = 'Test';
                //os.Ice_Type_Manufacturer__c = 'Test';
                os.Ice_Type__c ='Hard';
                os.Time_Zone__c = 'Test';
                os.FS_Calorie_Display_Enable__c ='Yes';
                os.Camera_Enabled__c = 'Yes';
                os.Default_Language_For_NCUI__c ='Eng';
                os.Microphone_Enabled__c = 'Yes';
                os.Proximity_Sensor_Enabled__c = 'Yes';
                os.Ambient_Screen_Update_Timer_Msec__c =20;
                os.Screen_Attract_Enabled__c = 'Yes';
                os.ADAHome_To_Home_Msec__c = 24;
                os.Are_You_Still_There_Msec__c = 34;
                os.ADAAfter_Pour_Msec__c = 44;
                os.To_Ambient_Msec__c = 55;
                os.Screen_Idle_To_Attract_Ms__c = 22;
                os.After_Pour_Msec__c = 33;
                os.Screen_Idle_To_Low_Power_Ms__c = 44;
                os.Speaker_Enabled__c = 'Yes';
                os.Start_Install_Window__c = 'Test';
                os.Cup_Name_1__c ='CUP1';
                os.Cup_Name_2__c ='CUP2';
                os.Cup_Name_3__c ='CUP3';
                os.Cup_Name_4__c ='CUP4';
                os.Cup_Name_5__c ='CUP5';
                os.Cup_Name_6__c ='CUP6';
                os.Cup_Size_1__c = 1;
                os.Cup_Size_2__c = 2;
                os.Cup_Size_3__c = 3;
                os.Cup_Size_4__c = 4;
                os.Cup_Size_5__c = 5;
                os.Cup_Size_6__c = 6;
                os.Service_Mode__c='Crew Serve';
                os.FS_Do_Not_Update_Content__c ='Yes';
                os.Do_Not_Update_Settings__c = 'Yes';
                os.Do_Not_Update_Rounding_Rules__c ='Yes';
                os.FS_Do_Not_Update_Software__c ='Yes';
                os.Allow_Language_Selection__c ='Yes';
                os.Screen_Idle_to_Home_After_Pour__c =45;
                os.Debug_Log_Level__c = 'DataV_Only';
                os.Water_Adjustment_Factor__c = 21;
                os.Debug_Flag_Expiration__c = System.now() + 2;
                os.Debug_Flag_Enabled__c = 'Yes';
                upODSet.add(os);
            }
            update upODSet;
            Test.stopTest();  
        }
    }
    
    @istest
    static void testMethod3()
    {
        // Test.startTest();
        List<FS_OD_Settings__c> ODSetList = [SELECT Id,FS_Force_Restore__c,Cup_Name_1__c,FS_OD_RecId__c FROM FS_OD_Settings__c];
        List<FS_OD_Settings__c> upODSet = New List<FS_OD_Settings__c>();
        
        List<FOT_Profile__mdt> lstFOTProf = [SELECT Profile_Name__c FROM FOT_Profile__mdt];
        
        final Profile fotOPAnlst=FSTestFactory.getProfileId(FSConstants.USER_PROFILE_OP_ANALYST);
        final User fotOPAnlstUser=FSTestFactory.createUser(fotOPAnlst.id);
        insert fotOPAnlstUser;
        system.runAs(fotOPAnlstUser){ 
            Test.startTest();
            For(FS_OD_Settings__c os :ODSetList ){
                
                os.Cup_Name_1__c = 'Test12';
                os.Default_Language_For_CUI__c = 'Test22';
                //os.Ice_Type_Manufacturer__c = 'Test222';
                os.Ice_Type__c ='Hard22';
                os.Time_Zone__c = 'Test22';
                os.FS_Calorie_Display_Enable__c ='No';
                os.Camera_Enabled__c = 'No';
                os.Default_Language_For_NCUI__c ='Englist';
                os.Microphone_Enabled__c = 'No';
                os.Proximity_Sensor_Enabled__c = 'No';
                os.Ambient_Screen_Update_Timer_Msec__c =220;
                os.Screen_Attract_Enabled__c = 'No';
                os.ADAHome_To_Home_Msec__c = 224;
                os.Are_You_Still_There_Msec__c = 324;
                os.ADAAfter_Pour_Msec__c = 424;
                os.To_Ambient_Msec__c = 525;
                os.Screen_Idle_To_Attract_Ms__c = 222;
                os.After_Pour_Msec__c = 323;
                os.Screen_Idle_To_Low_Power_Ms__c = 424;
                os.Speaker_Enabled__c = 'No';
                os.Start_Install_Window__c = 'Test22';
                os.Cup_Name_1__c ='CUP11';
                os.Cup_Name_2__c ='CUP22';
                os.Cup_Name_3__c ='CUP33';
                os.Cup_Name_4__c ='CUP44';
                os.Cup_Name_5__c ='CUP55';
                os.Cup_Name_6__c ='CUP66';
                os.Cup_Size_1__c = 11;
                os.Cup_Size_2__c = 22;
                os.Cup_Size_3__c = 33;
                os.Cup_Size_4__c = 44;
                os.Cup_Size_5__c = 55;
                os.Cup_Size_6__c = 66;
                os.Service_Mode__c='Crew Serve';
                os.FS_Do_Not_Update_Content__c ='No';
                os.Do_Not_Update_Settings__c = 'No';
                os.Do_Not_Update_Rounding_Rules__c ='No';
                os.FS_Do_Not_Update_Software__c ='No';
                os.Allow_Language_Selection__c ='Yes';
                os.Screen_Idle_to_Home_After_Pour__c =45;
                os.Debug_Log_Level__c = 'DataV_Only';
                os.Water_Adjustment_Factor__c = 21;
                os.Debug_Flag_Expiration__c = System.now() + 2;
                os.Debug_Flag_Enabled__c = 'Yes';
                upODSet.add(os);
            }
            update upODSet;
            Test.stopTest();  
        }
    }
    
    
    @istest
    static void testMethod4()
    {
        // Test.startTest();
        List<FS_OD_Settings__c> ODSetList = [SELECT Id,FS_Force_Restore__c,Cup_Name_1__c,FS_OD_RecId__c FROM FS_OD_Settings__c];
        List<FS_OD_Settings__c> upODSet = New List<FS_OD_Settings__c>();
        
        List<FOT_Profile__mdt> lstFOTProf = [SELECT Profile_Name__c FROM FOT_Profile__mdt];
        
        final Profile fotOPAnlst=FSTestFactory.getProfileId(FSConstants.USER_PROFILE_OP_ANALYST);
        final User fotOPAnlstUser=FSTestFactory.createUser(fotOPAnlst.id);
        insert fotOPAnlstUser;
        system.runAs(fotOPAnlstUser){ 
            Test.startTest();
            For(FS_OD_Settings__c os :ODSetList ){
                
                
                os.Service_Mode__c='Crew Serve';
                
                upODSet.add(os);
            }
            update upODSet;
            Test.stopTest();  
        }
    }
    
}