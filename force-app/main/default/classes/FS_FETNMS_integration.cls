global class FS_FETNMS_integration implements Database.batchable <sobject> ,Database.AllowsCallouts { 
    /*Removed Database.statful to fix 1320 */
    public list <FS_Outlet_Dispenser__c> updateOD = new list <FS_Outlet_Dispenser__c> ();
    public Date today; 
    //public Set <Id> dispId = new Set<Id>(); 
    public static final string NOVALUE='No';
    public Map<id,FS_Association_Brandset__c> abMaptoupdate=new Map<id,FS_Association_Brandset__c>();
    public FS_FETNMS_integration(final Date today){
        this.today=today;
    }
    
    
    
    global Database.QueryLocator start(final Database.BatchableContext batchCon){
        
        return Database.getQueryLocator('SELECT FS_Outlet__r.ShippingCity,FS_ACN_NBR__c,Ownership_Type__c, FS_outlet__r.Bottler_Name__c,FS_7000_Series_Hide_Water_Effective_Date__c,FS_7000_Series_Brands_Option_Selections__c, FS_outlet__r.id, FS_Outlet__r.Name, ' 
                                        + ' FS_outlet__r.ShippingCountry,FS_Soft_Ice_Manufacturer__c, FS_TimeZone__c,FS_Soft_Ice_Adjust_Flag__c,FS_Dispenser_Type2__c, FS_Outlet__r.FS_Chain__r.Name, FS_Outlet__r.FS_Headquarters__r.Name, FS_outlet__r.FS_Headquarters__r.FS_ACN__c, ' 
                                        + ' FS_LTO_New__c ,FS_LTO_Effective_Date__c,Brand_Set_New__c,Brand_Set__c,Brand_Set_Effective_Date__c ,Brands_Not_Selected__c, FS_7000_Series_Hide_Water_Button_New__c, '
                                        + ' FS_Water_Button_New__c ,FS_Water_Button__c,Hide_Water_Dispenser__c,FS_Hide_Water_Dispenser_New__c,FS_showHideWater_Effective_date__c ,IC_Code__c, FS_Water_Hide_Show_Effective_Date__c , FS_CE_Enabled_New__c, FS_CE_Enabled_Effective_Date__c,FS_Dasani_New__c ,FS_Dasani_Settings_Effective_Date__c, '
                                        + ' (select id,FS_NonBranded_Water__c,FS_Brandset__c from OutletDispensers__r),FS_FAV_MIX_New__c ,FS_FAV_MIX_Effective_Date__c,FS_Promo_Enabled_New__c , FS_Promo_Enabled_Effective_Date__c ,FS_Spicy_Cherry_New__c ,FS_Spicy_Cherry_Effective_Date__c,FS_Valid_Fill_New__c ,FS_Valid_Fill_Settings_Effective_Date__c, FS_7000_Series_Static_Selection_New__c,FS_Brand_Selection_Value_Effective_Date__c,FS_7000_Series_Agitated_Selections_New__c,FS_7000_Series_Brands_Selection_New__c,FS_Outlet__r.ShippingState, FS_Outlet__r.ShippingStreet, FS_Outlet__r.FS_ACN__c, FS_Outlet__r.ShippingPostalCode,FS_Outlet__r.FS_Chain__r.FS_ACN__c, FS_7000_Series_Agitated_Brands_Selection__c,FS_7000_Series_Static_Brands_Selections__c,FS_Code__c, FS_Serial_Number2__c,Installation__r.FS_Spicy_Cherry__c, FS_SAP_ID__c, Installation__r.FS_Valid_Fill_Approved__c, FS_Spicy_Cherry__c,FS_Equip_Type__c,Installation__r.FS_Original_Install_Date__c,FS_Equip_Sub_Type__c,FS_Country_Key__c,FS_Planned_Install_Date__c, Planned_Remove_Date__c,FS_7000_Series_Hide_Water_Button__c,FS_Valid_Fill__c,FS_CE_Enabled__c,FS_FAV_MIX__c,FS_LTO__c,FS_Promo_Enabled__c, FS_Migration_to_AW_Required__c, FS_Pending_Migration_to_AW__c, FS_Migration_to_AW_Complete__c, RecordTypeId ' 
                                        + ' FROM FS_Outlet_Dispenser__c where FS_IsActive__c = true AND (FS_Brand_Selection_Value_Effective_Date__c = :today or FS_CE_Enabled_Effective_Date__c = :today or FS_Dasani_Settings_Effective_Date__c =:today or FS_FAV_MIX_Effective_Date__c=:today  or FS_LTO_Effective_Date__c= :today or FS_Promo_Enabled_Effective_Date__c= :today or FS_Spicy_Cherry_Effective_Date__c=:today or FS_Valid_Fill_Settings_Effective_Date__c=:today or Brand_Set_Effective_Date__c=:today) ');       
        
    }
    
    global void execute(final Database.BatchableContext batchCon, final List<sObject> scope){
        Set <Id> dispId = new Set<Id>();
        final List<FS_Outlet_Dispenser__c> beList = (List<FS_Outlet_Dispenser__c>)scope;
        String static7000=FSConstants.BLANKVALUE;
        boolean awattributeCheck;
        
        for (FS_Outlet_Dispenser__c s :beList  ) {
            awattributeCheck=false;
            if(FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType,Label.INT_OD_RECORD_TYPE) != s.RecordTypeId){
                /* Commented out as part of FET5.1 FFET-651
if ((s.FS_7000_Series_Hide_Water_Button_New__c != s.FS_7000_Series_Hide_Water_Button__c) && (s.FS_7000_Series_Hide_Water_Effective_Date__c == today)){
s.FS_7000_Series_Hide_Water_Button__c = s.FS_7000_Series_Hide_Water_Button_New__c; 
s.FS_7000_Series_Hide_Water_Button_New__c=FSConstants.BLANKVALUE;
s.FS_7000_Series_Hide_Water_Effective_Date__c =FSConstants.DATE_NULL;
} */
                static7000=s.FS_7000_Series_Static_Selection_New__c;
                if((s.FS_Brand_Selection_Value_Effective_Date__c == today 
                    && ((s.FS_7000_Series_Static_Selection_New__c!=null && !static7000.Contains('Vitamin Water') && !static7000.Contains('POWERade')) || s.FS_7000_Series_Static_Selection_New__c==null)) 
                   && (s.FS_7000_Series_Static_Selection_New__c!= s.FS_7000_Series_Static_Brands_Selections__c || s.FS_7000_Series_Agitated_Selections_New__c != s.FS_7000_Series_Agitated_Brands_Selection__c || s.FS_7000_Series_Brands_Selection_New__c!= s.FS_7000_Series_Brands_Option_Selections__c)){
                       
                       s.FS_7000_Series_Static_Brands_Selections__c=s.FS_7000_Series_Static_Selection_New__c;
                       s.FS_7000_Series_Static_Selection_New__c=FSConstants.BLANKVALUE;
                       s.FS_7000_Series_Agitated_Brands_Selection__c=s.FS_7000_Series_Agitated_Selections_New__c ; 
                       s.FS_7000_Series_Agitated_Selections_New__c =FSConstants.BLANKVALUE;
                       s.FS_7000_Series_Brands_Option_Selections__c=s.FS_7000_Series_Brands_Selection_New__c; 
                       s.FS_7000_Series_Brands_Selection_New__c=FSConstants.BLANKVALUE;
                       s.FS_Brand_Selection_Value_Effective_Date__c =FSConstants.DATE_NULL;
                       awattributeCheck=true;                       
                   }                
            }
            else{
                if ((s.Brand_Set_New__c != s.Brand_Set__c) && (s.Brand_Set_Effective_Date__c  == today)) {
                    s.Brands_Not_Selected__c = s.Brand_Set__c;
                    s.Brand_Set__c= s.Brand_Set_New__c; 
                    s.Brand_Set_New__c=FSConstants.BLANKVALUE;  
                    s.Brand_Set_Effective_Date__c=FSConstants.DATE_NULL;             
                }
            }
            
            if ((s.FS_LTO_New__c != s.FS_LTO__c) && (s.FS_LTO_Effective_Date__c == today)){
                s.FS_LTO__c=s.FS_LTO_New__c; 
                s.FS_LTO_New__c=FSConstants.BLANKVALUE;
                s.FS_LTO_Effective_Date__c=FSConstants.DATE_NULL;
            }
            /*
if ((s.FS_FAV_MIX_New__c != s.FS_FAV_MIX__c) && (s.FS_FAV_MIX_Effective_Date__c== today)){
s.FS_FAV_MIX__c=s.FS_FAV_MIX_New__c; 
s.FS_FAV_MIX_New__c=FSConstants.BLANKVALUE;
s.FS_FAV_MIX_Effective_Date__c=FSConstants.DATE_NULL;
}*/
            
            if ((s.FS_CE_Enabled_New__c != s.FS_CE_Enabled__c) && (s.FS_CE_Enabled_Effective_Date__c == today )){
                s.FS_CE_Enabled__c=s.FS_CE_Enabled_New__c; 
                s.FS_CE_Enabled_New__c=FSConstants.BLANKVALUE;
                s.FS_CE_Enabled_Effective_Date__c=FSConstants.DATE_NULL;
                awattributeCheck=true;
            }
            
            /*Common Water button for all platform on OD
if ((s.FS_Hide_Water_Dispenser_New__c != s.FS_Water_Button__c) && (s.FS_showHideWater_Effective_date__c == today)){

for(FS_Association_Brandset__c ab:s.OutletDispensers__r){
ab.FS_NonBranded_Water__c=s.FS_Hide_Water_Dispenser_New__c;
abMaptoupdate.put(ab.id,ab);
}
s.FS_Hide_Water_Dispenser_New__c=FSConstants.BLANKVALUE;
s.FS_showHideWater_Effective_date__c=FSConstants.DATE_NULL;
} */
            
            /*Commented out as part of FET 5.1 FFET-651
if ((s.FS_Water_Button_New__c != s.FS_Water_Button__c) && (s.FS_Water_Hide_Show_Effective_Date__c == today)){
s.FS_Water_Button__c=s.FS_Water_Button_New__c; 
s.FS_Water_Button_New__c=FSConstants.BLANKVALUE;
s.FS_Water_Hide_Show_Effective_Date__c=FSConstants.DATE_NULL;
}          

if ((s.FS_Dasani_New__c != s.FS_Dasani__c) && (s.FS_Dasani_Settings_Effective_Date__c == today)){
s.FS_Dasani__c=s.FS_Dasani_New__c; 
s.FS_Dasani_New__c=FSConstants.BLANKVALUE;
s.FS_Dasani_Settings_Effective_Date__c=FSConstants.DATE_NULL;
}   */         
            
            if ((s.FS_Promo_Enabled_New__c != s.FS_Promo_Enabled__c) && (s.FS_Promo_Enabled_Effective_Date__c == today)){
                s.FS_Promo_Enabled__c=s.FS_Promo_Enabled_New__c; 
                s.FS_Promo_Enabled_New__c=FSConstants.BLANKVALUE;
                s.FS_Promo_Enabled_Effective_Date__c=FSConstants.DATE_NULL;
            }
            
            if ((s.FS_Spicy_Cherry_New__c != s.FS_Spicy_Cherry__c) && (s.FS_Spicy_Cherry_Effective_Date__c== today)){
                s.FS_Spicy_Cherry__c=s.FS_Spicy_Cherry_New__c; 
                s.FS_Spicy_Cherry_New__c=FSConstants.BLANKVALUE;
                s.FS_Spicy_Cherry_Effective_Date__c=FSConstants.DATE_NULL;
                awattributeCheck=true;
            }
            
            if ((s.FS_Valid_Fill_New__c != s.FS_Valid_Fill__c) && (s.FS_Valid_Fill_Settings_Effective_Date__c == today)){
                s.FS_Valid_Fill__c=s.FS_Valid_Fill_New__c; 
                s.FS_Valid_Fill_New__c=FSConstants.BLANKVALUE;
                s.FS_Valid_Fill_Settings_Effective_Date__c=FSConstants.DATE_NULL;
            }           
            updateOD.add(s);
            
            if(awattributeCheck){
                dispId.add(s.id);
            }
        }
        
        FSFETNMSConnector.isUpdateSAPIDBatchChange = true;
        FSFETNMSConnector.airWatchSynchronousCall(dispId,null);
        
        final Database.SaveResult [] upList = Database.update(updateOD,false);
        
    }
    
    
    global void finish(final Database.BatchableContext info){   
        
    } 
}