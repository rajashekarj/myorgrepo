/***************************************************************************
Name         : FsODTriggerSettingBusinessProcess
Created By   : Infosys Limited
Description  : FsODTriggerSettingBusinessProcess is a handler class to FOT_OD_Settings_Trigger trigger and contains all the logic
Created Date : 28-MAR-2018
****************************************************************************/
public class FsODTriggerSettingBusinessProcess {
  public static final String CLASSNAME='FsODTriggerSettingBusinessProcess';
    public static final String FOTAPP = 'FOT';
    public static final String SEVEARITY='Medium'; 
    public static DateTime NOW = System.now();
    //public boolean check;
    //Method OnBeforeInsertProcess contains all the logic that gets executed before insert operation
    public static void OnBeforeInsertProcess(List<FS_OD_Settings__c> ODSettingList)
    {
        
    }
    
    //Method OnBeforeUpdateProcess contains all the logic that gets executed before update operation
    public static void OnBeforeUpdateProcess(List<FS_OD_Settings__c> ODSettingList, Map<Id,FS_OD_Settings__c> ODSettingMap)
    {	
        
        List<String> profileList = New List<String> ();
        Id profileId=userinfo.getProfileId();
        //String userName = userinfo.getName();
        String userName = userinfo.getUserName();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
      
        //Custom metadata types with FOT profile name as values except MDM API
        List<FOT_Profile__mdt> lstFotProfiles = [SELECT Profile_Name__c FROM FOT_Profile__mdt];
    
        
       For(FOT_Profile__mdt FPM :lstFotProfiles ){
           profileList.add(FPM.Profile_Name__c);
       }
        
        System.debug('profileList' +profileList + 'CMTprofileName'+ lstFotProfiles +'userName'+ userName);
        List<FS_Outlet_Dispenser__c> lstFSODs = New List<FS_Outlet_Dispenser__c> ();
        Set<Id> DispenserIds = new Set<Id>();
        
        //Loop to get the Dispenser Id from received  ODSettingList
        for(FS_OD_Settings__c OdSetting: ODSettingList)
        {
            DispenserIds.add(OdSetting.FS_OD_RecId__c);
        }
        
        Map<id, FS_Outlet_Dispenser__c> dispenserMap = new Map<id, FS_Outlet_Dispenser__c>([select id,name,OD_Settings_Timestamp__c from FS_Outlet_Dispenser__c where Id in :DispenserIds]);
        for(FS_OD_Settings__c OdSetting: ODSettingList)
        {
            //Compare the old value and new value of the settings 
            If(OdSetting.FS_Force_Restore__c != ODSettingMap.get(OdSetting.Id).FS_Force_Restore__c ||
               OdSetting.FS_Do_Not_Update_Software__c != ODSettingMap.get(OdSetting.Id).FS_Do_Not_Update_Software__c ||
               OdSetting.FS_Do_Not_Update_Content__c != ODSettingMap.get(OdSetting.Id).FS_Do_Not_Update_Content__c ||
               OdSetting.Do_Not_Update_Settings__c != ODSettingMap.get(OdSetting.Id).Do_Not_Update_Settings__c ||
               OdSetting.Do_Not_Update_Rounding_Rules__c != ODSettingMap.get(OdSetting.Id).Do_Not_Update_Rounding_Rules__c ||
               OdSetting.Debug_Flag_Enabled__c != ODSettingMap.get(OdSetting.Id).Debug_Flag_Enabled__c ||
               OdSetting.Debug_Flag_Expiration__c != ODSettingMap.get(OdSetting.Id).Debug_Flag_Expiration__c ||
               //OdSetting.Ice_Type_Manufacturer__c != ODSettingMap.get(OdSetting.Id).Ice_Type_Manufacturer__c ||
               OdSetting.Ice_Type__c != ODSettingMap.get(OdSetting.Id).Ice_Type__c ||
               OdSetting.Time_Zone__c != ODSettingMap.get(OdSetting.Id).Time_Zone__c ||
               OdSetting.FS_Calorie_Display_Enable__c != ODSettingMap.get(OdSetting.Id).FS_Calorie_Display_Enable__c ||
               OdSetting.Camera_Enabled__c != ODSettingMap.get(OdSetting.Id).Camera_Enabled__c ||
               OdSetting.Default_Language_For_NCUI__c != ODSettingMap.get(OdSetting.Id).Default_Language_For_NCUI__c ||
               OdSetting.Microphone_Enabled__c != ODSettingMap.get(OdSetting.Id).Microphone_Enabled__c ||
               OdSetting.Proximity_Sensor_Enabled__c != ODSettingMap.get(OdSetting.Id).Proximity_Sensor_Enabled__c ||
               OdSetting.Ambient_Screen_Update_Timer_Msec__c != ODSettingMap.get(OdSetting.Id).Ambient_Screen_Update_Timer_Msec__c ||
               OdSetting.Screen_Attract_Enabled__c != ODSettingMap.get(OdSetting.Id).Screen_Attract_Enabled__c ||
               OdSetting.ADAHome_To_Home_Msec__c != ODSettingMap.get(OdSetting.Id).ADAHome_To_Home_Msec__c ||
               OdSetting.Are_You_Still_There_Msec__c != ODSettingMap.get(OdSetting.Id).Are_You_Still_There_Msec__c ||
               OdSetting.ADAAfter_Pour_Msec__c != ODSettingMap.get(OdSetting.Id).ADAAfter_Pour_Msec__c ||
               OdSetting.To_Ambient_Msec__c != ODSettingMap.get(OdSetting.Id).To_Ambient_Msec__c ||
               OdSetting.Screen_Idle_To_Attract_Ms__c != ODSettingMap.get(OdSetting.Id).Screen_Idle_To_Attract_Ms__c ||
               OdSetting.After_Pour_Msec__c != ODSettingMap.get(OdSetting.Id).After_Pour_Msec__c ||
               OdSetting.Screen_Idle_To_Low_Power_Ms__c != ODSettingMap.get(OdSetting.Id).Screen_Idle_To_Low_Power_Ms__c ||
               OdSetting.Speaker_Enabled__c != ODSettingMap.get(OdSetting.Id).Speaker_Enabled__c ||
               OdSetting.Start_Install_Window__c != ODSettingMap.get(OdSetting.Id).Start_Install_Window__c ||
               OdSetting.Cup_Name_1__c != ODSettingMap.get(OdSetting.Id).Cup_Name_1__c ||
               OdSetting.Cup_Name_2__c != ODSettingMap.get(OdSetting.Id).Cup_Name_2__c ||
               OdSetting.Cup_Name_3__c != ODSettingMap.get(OdSetting.Id).Cup_Name_3__c ||
               OdSetting.Cup_Name_4__c != ODSettingMap.get(OdSetting.Id).Cup_Name_4__c ||
               OdSetting.Cup_Name_5__c != ODSettingMap.get(OdSetting.Id).Cup_Name_5__c ||
               OdSetting.Cup_Name_6__c != ODSettingMap.get(OdSetting.Id).Cup_Name_6__c ||
               OdSetting.Cup_Size_1__c != ODSettingMap.get(OdSetting.Id).Cup_Size_1__c ||
               OdSetting.Cup_Size_2__c != ODSettingMap.get(OdSetting.Id).Cup_Size_2__c ||
               OdSetting.Cup_Size_3__c != ODSettingMap.get(OdSetting.Id).Cup_Size_3__c ||
               OdSetting.Cup_Size_4__c != ODSettingMap.get(OdSetting.Id).Cup_Size_4__c ||
               OdSetting.Cup_Size_5__c != ODSettingMap.get(OdSetting.Id).Cup_Size_5__c ||
               OdSetting.Cup_Size_6__c != ODSettingMap.get(OdSetting.Id).Cup_Size_6__c ||
               OdSetting.FS_Agitate_OffTime_Seconds__c != ODSettingMap.get(OdSetting.Id).FS_Agitate_OffTime_Seconds__c ||
               OdSetting.FS_Agitate_OnTime_Seconds__c != ODSettingMap.get(OdSetting.Id).FS_Agitate_OnTime_Seconds__c ||
               OdSetting.FS_Agitate_Threshold_OZ__c != ODSettingMap.get(OdSetting.Id).FS_Agitate_Threshold_OZ__c ||
               //OdSetting.Water_Adjustment_Enabled__c != ODSettingMap.get(OdSetting.Id).Water_Adjustment_Enabled__c ||
               OdSetting.Default_Language_For_CUI__c != ODSettingMap.get(OdSetting.Id).Default_Language_For_CUI__c ||
               OdSetting.Service_Mode__c != ODSettingMap.get(OdSetting.Id).Service_Mode__c ||
               OdSetting.Water_Adjustment_Factor__c != ODSettingMap.get(OdSetting.Id).Water_Adjustment_Factor__c || 
               OdSetting.Allow_Language_Selection__c != ODSettingMap.get(OdSetting.Id).Allow_Language_Selection__c || 
               OdSetting.Screen_Idle_to_Home_After_Pour__c != ODSettingMap.get(OdSetting.Id).Screen_Idle_to_Home_After_Pour__c ||
               OdSetting.Debug_Log_Level__c != ODSettingMap.get(OdSetting.Id).Debug_Log_Level__c ||
               OdSetting.Revoke_Artifacts__c != ODSettingMap.get(OdSetting.Id).Revoke_Artifacts__c ||
               OdSetting.FS_Valid_Fill_Enabled__c != ODSettingMap.get(OdSetting.Id).FS_Valid_Fill_Enabled__c ||
               OdSetting.FS_DMVerbosity__c != ODSettingMap.get(OdSetting.Id).FS_DMVerbosity__c ||
               OdSetting.FS_DMVerbosityExpiration__c != ODSettingMap.get(OdSetting.Id).FS_DMVerbosityExpiration__c ||
               OdSetting.All_Actual_Artifacts__c != ODSettingMap.get(OdSetting.Id).All_Actual_Artifacts__c ||
               OdSetting.Agitation_Duration__c != ODSettingMap.get(OdSetting.Id).Agitation_Duration__c ||
               OdSetting.Agitate_After_Volume__c != ODSettingMap.get(OdSetting.Id).Agitate_After_Volume__c ||
               OdSetting.Agitate_After_Time__c != ODSettingMap.get(OdSetting.Id).Agitate_After_Time__c
              )
            {
                //Set the OD setting timestamp
                FS_Outlet_Dispenser__c settingDispenser = dispenserMap.get(OdSetting.FS_OD_RecId__c);
                settingDispenser.OD_Settings_Timestamp__c = system.now();
                lstFSODs.add(settingDispenser);
               
            }
            
        }
        
        //To update OD with timestamp
        if(lstFSODs.Size()>0){ 
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FOTAPP,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c='OnBeforeUpdateProcess',Object_Name__c='FS_Outlet_Dispenser__c',
                                                                    Error_Severity__c=SEVEARITY);
            FSUtil.dmlProcessorUpdate(lstFSODs,true,apexError); 
        }
        
        For(FS_OD_Settings__c OdSetting: ODSettingList){
        //checking current user's profile
        //if it's not MDM API User, then proceeds 
            if(profileList.contains(profileName)){
                //Check for every OD setting field update then 
                //update corresponding fields. Updated By to "Current User name"
                //Update On to "NOW" 
                
                if(OdSetting.Default_Language_For_CUI__c != ODSettingMap.get(OdSetting.Id).Default_Language_For_CUI__c){
                    OdSetting.Default_Language_For_CUI_Last_Updtd_By__c = userName;
                    OdSetting.Default_Language_For_CUI_Updated_on__c = NOW;
                    OdSetting.Default_Language_For_CUI_Verified__c = NULL;
                }
                /*if(OdSetting.Ice_Type_Manufacturer__c != ODSettingMap.get(OdSetting.Id).Ice_Type_Manufacturer__c)
                {
                    OdSetting.Ice_Type_Manufacturer_Last_Updtd_By__c = userName;
                    OdSetting.Ice_Type_Manufacturer_Updated_on__c = NOW;
                    OdSetting.Ice_Type_Manufacturer_Verified__c = NULL;
                }*/
                
                if(OdSetting.FS_DMVerbosity__c != ODSettingMap.get(OdSetting.Id).FS_DMVerbosity__c)
                {
                    OdSetting.FS_DMVerbosity_Updated_By__c = userName;
                    OdSetting.FS_DMVerbosity_Updated_On__c = NOW;
                    OdSetting.FS_DMVerbosity_Verified__c = NULL;
                }
                
                if(OdSetting.FS_DMVerbosityExpiration__c != ODSettingMap.get(OdSetting.Id).FS_DMVerbosityExpiration__c)
                {
                    OdSetting.FS_DMVerbosityExpiration_Updated_By__c = userName;
                    OdSetting.FS_DMVerbosityExpiration_Updated_On__c = NOW;
                    OdSetting.FS_DMVerbosityExpiration_Verified__c = NULL;
                }
                
                if(OdSetting.Ice_Type__c != ODSettingMap.get(OdSetting.Id).Ice_Type__c)
                {
                    OdSetting.Ice_Type_Last_Updt_By__c = userName;
                    OdSetting.Ice_Type_Updated_On__c = NOW;
                    OdSetting.Ice_Type_Verified__c = NULL;
                }
                
                if(OdSetting.Time_Zone__c != ODSettingMap.get(OdSetting.Id).Time_Zone__c)
                {
                    OdSetting.Time_Zone_Updated_By__c = userName;
                    OdSetting.Time_Zone_Updated_on__c = NOW;
                    OdSetting.Time_Zone_Verified__c = NULL;
                }
                if(OdSetting.FS_Calorie_Display_Enable__c != ODSettingMap.get(OdSetting.Id).FS_Calorie_Display_Enable__c)
                {
                    OdSetting.Calorie_Display_Enable_Last_Updtd_By__c = userName;
                    OdSetting.Calorie_Display_Enable_Updated_on__c = NOW;
                    OdSetting.Calorie_Display_Enable_Verified__c = NULL;
                }
                
                if(OdSetting.Camera_Enabled__c != ODSettingMap.get(OdSetting.Id).Camera_Enabled__c)
                {
                    OdSetting.Camera_Enable_Last_Updtd_By__c = userName;
                    OdSetting.Camera_Enable_Updated_on__c = NOW;
                    OdSetting.Camera_Enable_Verified__c = NULL;
                }
                
                if(OdSetting.Default_Language_For_NCUI__c != ODSettingMap.get(OdSetting.Id).Default_Language_For_NCUI__c)
                {
                    OdSetting.Default_Language_For_NCUI_Last_Updtd_By__c = userName;
                    OdSetting.Default_Language_For_NCUI_Updated_on__c = NOW;
                    OdSetting.Default_Language_For_NCUI_Verified__c = NULL;
                }
                if(OdSetting.Microphone_Enabled__c != ODSettingMap.get(OdSetting.Id).Microphone_Enabled__c)
                {
                    OdSetting.Microphone_Enable_Last_Updtd_By__c = userName;
                    OdSetting.Microphone_Enable_Updated_on__c = NOW;
                    OdSetting.Microphone_Enable_Verified__c = NULL;
                }
                
                if(OdSetting.Proximity_Sensor_Enabled__c != ODSettingMap.get(OdSetting.Id).Proximity_Sensor_Enabled__c)
                {
                    OdSetting.Proximity_Sensor_Enable_Last_Updtd_By__c = userName;
                    OdSetting.Proximity_Sensor_Enable_Updated_on__c = NOW;
                    OdSetting.Proximity_Sensor_Enable_Verified__c = NULL;
                }
                
                if(OdSetting.Ambient_Screen_Update_Timer_Msec__c != ODSettingMap.get(OdSetting.Id).Ambient_Screen_Update_Timer_Msec__c)
                {
                    OdSetting.Ambient_Screen_Updt_Timer_Last_Updtd_By__c = userName;
                    OdSetting.Ambient_Screen_Upd_Timer_Msec_Updated_on__c = NOW;
                    OdSetting.Ambient_Screen_Updt_Timer_Verified__c = NULL;
                }
                if(OdSetting.Screen_Attract_Enabled__c != ODSettingMap.get(OdSetting.Id).Screen_Attract_Enabled__c)
                {
                    OdSetting.Screen_Attract_Enabled_Last_Updtd_By__c = userName;
                    OdSetting.Screen_Attract_Enabled_Updated_on__c = NOW;
                    OdSetting.Screen_Attract_Enabled_Verified__c = NULL;
                }
                
                if(OdSetting.ADAHome_To_Home_Msec__c != ODSettingMap.get(OdSetting.Id).ADAHome_To_Home_Msec__c)
                {
                    OdSetting.ADA_Home_To_Home_Msec_Last_Updtd_By__c = userName;
                    OdSetting.ADAHome_To_Home_Msec_Updated_on__c = NOW;
                    OdSetting.ADA_Home_To_Home_Msec_Verified__c = NULL;
                }
                
                if(OdSetting.Are_You_Still_There_Msec__c != ODSettingMap.get(OdSetting.Id).Are_You_Still_There_Msec__c)
                {
                    OdSetting.Are_You_Still_There_Msec_Last_Updtd_By__c = userName;
                    OdSetting.Are_You_Still_There_Msec_Updated_on__c = NOW;
                    OdSetting.Are_You_Still_There_Msec_Verified__c = NULL;
                }
                if(OdSetting.ADAAfter_Pour_Msec__c != ODSettingMap.get(OdSetting.Id).ADAAfter_Pour_Msec__c)
                {
                    OdSetting.ADA_After_Pour_Msec_Last_Updtd_By__c = userName;
                    OdSetting.ADAAfter_Pour_Msec_Updated_on__c = NOW;
                    OdSetting.ADA_After_Pour_Msec_Verified__c = NULL;
                }
                if(OdSetting.To_Ambient_Msec__c != ODSettingMap.get(OdSetting.Id).To_Ambient_Msec__c)
                {
                    OdSetting.To_Ambient_Msec_Last_Updtd_By__c = userName;
                    OdSetting.To_Ambient_Msec_Updated_on__c = NOW;
                    OdSetting.To_Ambient_Msec_Verified__c = NULL;
                }
                if(OdSetting.Screen_Idle_To_Attract_Ms__c != ODSettingMap.get(OdSetting.Id).Screen_Idle_To_Attract_Ms__c)
                {
                    OdSetting.Screen_Idle_To_Attract_Ms_Last_Updtd_By__c = userName;
                    OdSetting.Screen_Idle_To_Attract_Ms_Updated_On__c = NOW;
                    OdSetting.Screen_Idle_To_Attract_Ms_Verified__c = NULL;
                }
                if(OdSetting.After_Pour_Msec__c != ODSettingMap.get(OdSetting.Id).After_Pour_Msec__c)
                {
                    OdSetting.After_Pour_Msec_Last_Updtd_By__c = userName;
                    OdSetting.After_Pour_Msec_Updated_on__c = NOW;
                    OdSetting.After_Pour_Msec_Verified__c = NULL;
                }
                
                if(OdSetting.Screen_Idle_To_Low_Power_Ms__c != ODSettingMap.get(OdSetting.Id).Screen_Idle_To_Low_Power_Ms__c)
                {
                    OdSetting.Screen_Idle_To_Low_Power_Ms_Last_Uptd_By__c = userName;
                    OdSetting.Screen_Idle_To_Low_Power_Ms_Updated_On__c = NOW;
                    OdSetting.Screen_Idle_To_Low_Power_Ms_Verified__c = NULL;
                }
                
                if(OdSetting.Speaker_Enabled__c != ODSettingMap.get(OdSetting.Id).Speaker_Enabled__c)
                {
                    OdSetting.Speaker_Enable_Last_Updtd_By__c = userName;
                    OdSetting.Speaker_Enable_Updated_on__c = NOW;
                    OdSetting.Speaker_Enable_Verified__c = NULL;
                }
                
                if(OdSetting.Start_Install_Window__c != ODSettingMap.get(OdSetting.Id).Start_Install_Window__c)
                {
                    OdSetting.Start_Install_Window_Last_Updtd_By__c = userName;
                    OdSetting.Start_Install_Window_Updated_on__c = NOW;
                    OdSetting.FS_Start_Install_Window_Verified__c = NULL;
                } 
                if(OdSetting.Cup_Name_1__c != ODSettingMap.get(OdSetting.Id).Cup_Name_1__c)
                {
                    OdSetting.Cup_Name_1_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Name_1_Updated_on__c = NOW;
                    OdSetting.Cup_Name_1_Verified__c = NULL;
                }
                if(OdSetting.Cup_Name_2__c != ODSettingMap.get(OdSetting.Id).Cup_Name_2__c)
                {
                    OdSetting.Cup_Name_2_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Name_2_Updated_on__c = NOW;
                    OdSetting.Cup_Name_2_Verified__c = NULL;
                }
                if(OdSetting.Cup_Name_3__c != ODSettingMap.get(OdSetting.Id).Cup_Name_3__c)
                {
                    OdSetting.Cup_Name_3_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Name_3_Updated_on__c = NOW;
                    OdSetting.Cup_Name_3_Verified__c = NULL;
                }
                if(OdSetting.Cup_Name_4__c != ODSettingMap.get(OdSetting.Id).Cup_Name_4__c)
                {
                    OdSetting.Cup_Name_4_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Name_4_Updated_on__c = NOW;
                    OdSetting.Cup_Name_4_Verified__c = NULL;
                }
                if(OdSetting.Cup_Name_5__c != ODSettingMap.get(OdSetting.Id).Cup_Name_5__c)
                {
                    OdSetting.Cup_Name_5_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Name_5_Updated_on__c = NOW;
                    OdSetting.Cup_Name_5_Verified__c = NULL;
                }
                if(OdSetting.Cup_Name_6__c != ODSettingMap.get(OdSetting.Id).Cup_Name_6__c)
                {
                    OdSetting.Cup_Name_6_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Name_6_Updated_on__c = NOW;
                    OdSetting.Cup_Name_6_Verified__c = NULL;
                }
                if(OdSetting.Cup_Size_1__c != ODSettingMap.get(OdSetting.Id).Cup_Size_1__c)
                {
                    OdSetting.Cup_Size_1_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Size_1_Updated_on__c = NOW;
                    OdSetting.Cup_Size_1_Verified__c = NULL;
                }
                if(OdSetting.Cup_Size_2__c != ODSettingMap.get(OdSetting.Id).Cup_Size_2__c)
                {
                    OdSetting.Cup_Size_2_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Size_2_Updated_on__c = NOW;
                    OdSetting.Cup_Size_2_Verified__c = NULL;
                }
                if(OdSetting.Cup_Size_3__c != ODSettingMap.get(OdSetting.Id).Cup_Size_3__c)
                {
                    OdSetting.Cup_Size_3_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Size_3_Updated_on__c = NOW;
                    OdSetting.Cup_Size_3_Verified__c = NULL;
                }
                if(OdSetting.Cup_Size_4__c != ODSettingMap.get(OdSetting.Id).Cup_Size_4__c)
                {
                    OdSetting.Cup_Size_4_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Size_4_Updated_on__c = NOW;
                    OdSetting.Cup_Size_4_Verified__c = NULL;
                }
                if(OdSetting.Cup_Size_5__c != ODSettingMap.get(OdSetting.Id).Cup_Size_5__c)
                {
                    OdSetting.Cup_Size_5_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Size_5_Updated_on__c = NOW;
                    OdSetting.Cup_Size_5_Verified__c = NULL;
                }
                if(OdSetting.Cup_Size_6__c != ODSettingMap.get(OdSetting.Id).Cup_Size_6__c)
                {
                    OdSetting.Cup_Size_6_Last_Updtd_By__c = userName;
                    OdSetting.Cup_Size_6_Updated_on__c = NOW;
                    OdSetting.Cup_Size_6_Verified__c = NULL;
                }
                if(OdSetting.Do_Not_Update_Settings__c != ODSettingMap.get(OdSetting.Id).Do_Not_Update_Settings__c)
                {
                    OdSetting.Do_Not_Update_Settings_Updated_By__c = userName;
                    OdSetting.Do_Not_Update_Settings_Updated_On__c = NOW;
                }
                if(OdSetting.FS_Do_Not_Update_Content__c != ODSettingMap.get(OdSetting.Id).FS_Do_Not_Update_Content__c)
                {
                    OdSetting.Do_Not_Update_Content_Updated_By__c = userName;
                    OdSetting.Do_Not_Update_Content_Updated_On__c = NOW;
                }
                if(OdSetting.Do_Not_Update_Rounding_Rules__c != ODSettingMap.get(OdSetting.Id).Do_Not_Update_Rounding_Rules__c)
                {
                    OdSetting.Do_Not_Update_Rounding_Rules_Updated_By__c = userName;
                    OdSetting.Do_Not_Update_Rounding_Rules_Updated_On__c = NOW;
                    
                }
                if(OdSetting.FS_Do_Not_Update_Software__c != ODSettingMap.get(OdSetting.Id).FS_Do_Not_Update_Software__c)
                {
                    OdSetting.Do_Not_Update_Software_Updated_By__c = userName;
                    OdSetting.Do_Not_Update_Software_Updated_On__c = NOW;
                    
                }
                if(OdSetting.Service_Mode__c != ODSettingMap.get(OdSetting.Id).Service_Mode__c)
                {
                    OdSetting.Service_Mode_Updated_By__c = userName;
                    OdSetting.Service_Mode_Updated_On__c = NOW;
                    OdSetting.Service_Mode_Verified__c = NULL;
                }
                if(OdSetting.Allow_Language_Selection__c != ODSettingMap.get(OdSetting.Id).Allow_Language_Selection__c)
                {
                    OdSetting.Allow_Language_Selection_Updated_By__c = userName;
                    OdSetting.Allow_Language_Selection_Updated_on__c = NOW;
                    OdSetting.Allow_Language_Selection_Verified__c = NULL;
                }
                if(OdSetting.Screen_Idle_to_Home_After_Pour__c != ODSettingMap.get(OdSetting.Id).Screen_Idle_to_Home_After_Pour__c)
                {
                    OdSetting.Screen_Idle_to_Home_After_Pour_Updtd_By__c = userName;
                    OdSetting.Screen_Idle_to_Home_After_Pour_Updtd_On__c = NOW;
                    OdSetting.Screen_Idle_to_Home_After_Pour_Verified__c = NULL;
                }
                
                if(OdSetting.Revoke_Artifacts__c != ODSettingMap.get(OdSetting.Id).Revoke_Artifacts__c)
                {
                    OdSetting.Revoke_Artifacts_Updated_By__c = userName;
                    OdSetting.Revoke_Artifacts_Updated_On__c = NOW;
                    OdSetting.Revoke_Artifacts_Verified__c = NULL;
                }
                
                if(OdSetting.FS_Valid_Fill_Enabled__c != ODSettingMap.get(OdSetting.Id).FS_Valid_Fill_Enabled__c)
                {
                    OdSetting.FS_Valid_Fill_Enabled_Updt_By__c = userName;
                    OdSetting.FS_Valid_Fill_Enabled_Updated_On__c	 = NOW;
                    OdSetting.FS_Valid_Fill_Enabled_Verified__c = NULL;
                }
                
                if(OdSetting.Debug_Flag_Enabled__c != ODSettingMap.get(OdSetting.Id).Debug_Flag_Enabled__c)
                {
                    OdSetting.Debug_Flag_Enabled_Updated_By__c = userName;
                    OdSetting.Debug_Flag_Enabled_Updated_On__c = NOW;                    
                }
                if(OdSetting.Debug_Flag_Expiration__c != ODSettingMap.get(OdSetting.Id).Debug_Flag_Expiration__c)
                {
                    OdSetting.Debug_Flag_Expiration_Updated_By__c = userName;
                    OdSetting.Debug_Flag_Expiration_Updated_On__c = NOW;                    
                }
                if(OdSetting.Water_Adjustment_Factor__c != ODSettingMap.get(OdSetting.Id).Water_Adjustment_Factor__c)
                {
                    OdSetting.Water_Adjustment_Factor_Updated_By__c = userName;
                    OdSetting.Water_Adjustment_Factor_Updated_On__c = NOW;                    
                }   
                if(OdSetting.Debug_Log_Level__c != ODSettingMap.get(OdSetting.Id).Debug_Log_Level__c)
                {
                    OdSetting.Debug_Log_Level_Updated_By__c = userName;
                    OdSetting.Debug_Log_Level_Updated_On__c = NOW;                    
                }

                if(OdSetting.Agitate_After_Volume__c != ODSettingMap.get(OdSetting.Id).Agitate_After_Volume__c)
                {
                    OdSetting.Agitate_After_Volume_Last_Updtd_By__c = userName;
                    OdSetting.Agitate_After_Volume_Updated_on__c = NOW;                    
                }
                
                if(OdSetting.Agitation_Duration__c != ODSettingMap.get(OdSetting.Id).Agitation_Duration__c)
                {
                    OdSetting.Agitation_Duration_Last_Updtd_By__c = userName;
                    OdSetting.Agitation_Duration_Updated_on__c = NOW;                    
                }
                
                if(OdSetting.Agitate_After_Volume__c != ODSettingMap.get(OdSetting.Id).Agitate_After_Volume__c)
                {
                    OdSetting.Agitate_After_Volume_Last_Updtd_By__c = userName;
                    OdSetting.Agitate_After_Volume_Updated_on__c = NOW;                    
                }
            }
            
        }
    }
    
   
}