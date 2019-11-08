/********************************************************************************************************
Name         : FsodTriggerHelper
Created By   : Infosys
Created Date : 04-OCT-2017
Usage        : This class holds the common business logic of the Outletdispenser where fields are set and is called from the FSODHandler.
Methods      : populateActiveDate,populateRecordType,populateSendCreateRequest,populateIntOD,copyBrandsetToOd,deactivateOdWithSameSerialNumber,UpdateRecordTypeJDUEqupType
**********************************************************************************************************/


public with sharing class FsODTriggerHelper{
    
    //OD recordtypes
    public Static Id accRecTypeBoE;
    public Static Id odRecTypeCCNA;
    public Static Id integrationUserId=FSConstants.getIntegrationUserID();
    public Static Id odRecTypeInternational;
    public static string val7000 = '7000';
    public static string val8000 = '8000';
    public static string val9000 = '9000';
    public static String valCCNADisp= Label.CCNA_Disp_Record_type;
    public static string IntOutlet = Label.INTERNATIONAL_OUTLET_RECORD_TYPE;
    public static string valInt = Label.INT_OD_RECORD_TYPE;
    public static ID ID_Null=null;
    public static string valNo = 'No';
    public static integer valOne=1;
    public static integer valTwo=2;
    public static Boolean emailrunonce=false;  
    public static object nullValue() { return null; }
    public static Map<Id,String> mapofRecordtypIdAndRecordTypeName= new Map<Id,String>();
    public static Map<String,Id> mapofRecordtypNameAndRecordTypeId= new Map<String,Id>();
    static{
        if(odRecTypeCCNA == ID_Null){
            odRecTypeCCNA= FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType,valCCNADisp);
        }
        
        
        if(odRecTypeInternational==ID_Null){
            odRecTypeInternational=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType,valInt);
        }
        if(accRecTypeBoE==ID_Null){
            accRecTypeBoE=FSUtil.getObjectRecordTypeId(Account.sObjectType,IntOutlet);            
        }
        
        
        mapofRecordtypIdAndRecordTypeName.put(odRecTypeCCNA,valCCNADisp);
        mapofRecordtypIdAndRecordTypeName.put(odRecTypeInternational,valInt);
        
        
        mapofRecordtypNameAndRecordTypeId.put(valCCNADisp,odRecTypeCCNA);
        mapofRecordtypNameAndRecordTypeId.put(valInt,odRecTypeInternational);
    }
    
    /** @Desc - This Method is used to populate dispenser active date on before events.
* @param - populateActiveDate(Fs_outletdispenser__c dispenser)
* @Return - void
*/
    public static void populateActiveDate(FS_Outlet_Dispenser__c dispenser){ 
        if(dispenser.FS_IsActive__c && dispenser.FS_Dispenser_Active_Date__c == null){
            dispenser.FS_Dispenser_Active_Date__c = system.today();
            if(dispenser.CreatedDate!=null){
                dispenser.FS_Dispenser_Active_Date__c =dispenser.CreatedDate.date();
            }   
        }
    }
    /** @Desc - This Method is used to populate dispenser record type on before events.
* @param - populateRecordType(Fs_outletdispenser__c dispenser)
* @Return - void
*/
    //Updates recorde type of OD if Country other then "US"
    public static void populateRecordType(FS_Outlet_Dispenser__c dispenser){
        //Temporarily commented to debug SOQL 101 issue on 11/16/2017 
        if(!dispenser.is_DefaultOutlet__c && dispenser.LastModifiedById == integrationUserId){                      
            if(dispenser.FS_Country_Key__c != null && !dispenser.FS_Country_Key__c.equalsIgnoreCase('US')){
                dispenser.RecordTypeId = odRecTypeInternational;  
            }
        }
        
    }
    
    /** @Desc - This Method is used to populate dispenser status in case of BOE dispenser coming from SAP.
* @param - populateStatus(Fs_outletdispenser__c dispenser)
* @Return - void
*/    
    public static void populateStatus(FS_Outlet_Dispenser__c dispenser){
        if(odRecTypeInternational == dispenser.RecordTypeId && !dispenser.is_DefaultOutlet__c) {
            dispenser.FS_Status__c = 'Assigned to Outlet';
            dispenser.FS_Planned_Install_Date__c = system.today();
        }            
    }
    
    /** @Desc - This Method is used to populate send create request to dispenser on before events.
* @param - populateSendCreateRequest(Fs_outletdispenser__c dispenser)
* @Return - void
*/
    public static void populateSendCreateRequest(FS_Outlet_Dispenser__c dispenser){
        //Domestic
        if(odRecTypeInternational != dispenser.RecordTypeId){
            if(dispenser.FS_Status__c == 'Enrolled' && userInfo.getUserName() == Label.Integration_User){
                dispenser.Send_Create_Request__c = true;                        
            }
            //International 
        }else{
            if(dispenser.Is_DefaultOutlet__c){
                dispenser.Send_Create_Request__c = false;
            }else{
                if(dispenser.FS_Status__c == FSConstants.dispenserStatusAssigned){                      
                    dispenser.Send_Create_Request__c = true;
                }
            }
        }
    }
    
    /** @Desc - This Method is used to populate fields on International dispenser on before events.
* @param - populateIntOD(Fs_outletdispenser__c dispenser)
* @Return - void
*/
    public static void populateIntOD(FS_Outlet_Dispenser__c dispenser){
        Map<Id,FS_Outlet_Dispenser__c> oldMap = (Map<Id,FS_Outlet_Dispenser__c>)Trigger.oldMap;
        if(odRecTypeInternational == dispenser.RecordTypeId){
            //Make OD deactive if actual removal date updated
            if(dispenser.FS_Date_Removed__c != null && oldMap.get(dispenser.id).FS_Date_Removed__c != dispenser.FS_Date_Removed__c){
                dispenser.FS_IsActive__c = false;
            }
            //Updates Brandset
            if(dispenser.Brand_Set_formula__c != oldMap.get(dispenser.id).Brand_Set_formula__c && oldMap.get(dispenser.id).Brand_Set_formula__c != null){
                dispenser.Brands_Not_Selected__c = oldMap.get(dispenser.id).Brand_Set_formula__c;         
            }
        }
    }
    
    /** @Desc - This Method is used to copy brandset to dispenser if effective date is today.
* @param - copyBrandsetToOd(List<FS_Outlet_Dispenser__c> listOd)
* @Return - void
*/  
    public static void copyBrandsetToOd(List<FS_Outlet_Dispenser__c> listOd){
        Boolean brandsetSuccessfullyCopied=false;        
        if(!listOd.isEmpty()){
            brandsetSuccessfullyCopied=FSCopyTodaysBrandsetsDispenser.copyTodaysBrandsetsToCurrentBrandset(listOd);
        }        
        if(brandsetSuccessfullyCopied){
            for(FS_Outlet_Dispenser__c OD : (List<FS_Outlet_Dispenser__c>)Trigger.New){
                if(OD.FS_Brandset_Effective_Date__c!=NULL && OD.FS_Brandset_Effective_Date__c==Date.today() &&
                   OD.FS_Brandset__c!=OD.FS_Brandset_New__c){
                       OD.FS_Brandset__c=OD.FS_Brandset_New__c;
                       OD.FS_Brandset_Effective_Date__c=null;
                       OD.FS_Brandset_New__c=null;
                   }
                if(OD.FS_showHideWater_Effective_date__c!=NULL && OD.FS_showHideWater_Effective_date__c==Date.today() &&
                   OD.FS_Brandset__c!=OD.FS_Brandset_New__c){
                       OD.FS_Water_Button__c=OD.FS_Hide_Water_Dispenser_New__c;
                       OD.FS_showHideWater_Effective_date__c=null;
                       OD.FS_Hide_Water_Dispenser_New__c=null;
                   }
            }
        }
    }
    
    /** @Desc - This Method is used to deactivate dispenser which have same serial number.
* @param - deactivateOdWithSameSerialNumber()
* @Return - void
*/
    public static void deactivateOdWithSameSerialNumber(){
        
        //Start -  Deactivate OD with same serial number 
        Set<String> setSerialNumbers = new Set<String>();
        Set<Id> setDispenserIDs = new Set<Id>();
        for(FS_Outlet_Dispenser__c dispenserObj : (List<FS_Outlet_Dispenser__c>)Trigger.new) {
            if(odRecTypeInternational  != dispenserObj.RecordTypeId
               && dispenserObj.FS_IsActive__c && dispenserObj.FS_Status__c!=null
              ) {
                  setSerialNumbers.add(dispenserObj.FS_Serial_Number2__c);
                  setDispenserIDs.add(dispenserObj.Id);
              }
        }
        Map<Id, FS_Outlet_Dispenser__c> mapIdOutletDispenser = new Map<Id, FS_Outlet_Dispenser__c>();
        try{
            mapIdOutletDispenser = new Map<Id, FS_Outlet_Dispenser__c>([SELECT Id, FS_Serial_Number2__c, FS_Status__c, FS_IsActive__c FROM FS_Outlet_Dispenser__c 
                                                                                                    WHERE FS_Serial_Number2__c IN :setSerialNumbers 
                                                                                                    AND ID NOT IN :setDispenserIDs
                                                                                                    AND FS_Status__c != 'Enrolled'
                                                                                                    AND FS_IsActive__c = true ]);
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog('FET-7.0','FsODTriggerHelper','deactivateOdWithSameSerialNumber','OD','Medium',e,'NA');
        } 
        if(!mapIdOutletDispenser.values().isEmpty()) {
            for(FS_Outlet_Dispenser__c obj : mapIdOutletDispenser.values()) {
                obj.FS_IsActive__c = false;
            }               
            Database.update(mapIdOutletDispenser.values(), false);
        }  
        //End -- deactivate OD scenario
        
    }
    /** @Desc - This Method is used to populate Equipment Type or Recordtype.
* @param - Trigger context variables(Trigger.new)
* @Return - void
*/  
    public static void UpdateRecordTypeJDUEqupType(){
        List<Id> accIDs = new List<Id>();
        for(FS_Outlet_Dispenser__c ODRecord:(List<FS_Outlet_Dispenser__c>) Trigger.New){
            accIDs.add(ODRecord.FS_Outlet__c);
        }
        Map<Id,Account> accMap = new Map<Id,Account>();
        try{
            accMap = new Map<Id,Account>([Select Id,RecordTypeId from Account where Id in :accIDs]);
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog('FET-7.0','FsODTriggerHelper','UpdateRecordTypeJDUEqupType','Account','Medium',e,'NA');
        }
        String allPlatforms=Platform_Type_ctrl__c.getAll().get('all_Platform').Platforms__c;
        for(FS_Outlet_Dispenser__c OD:(List<FS_Outlet_Dispenser__c>)Trigger.new){
            if((!String.isBlank(OD.FS_Country_Key__c) && OD.FS_Country_Key__c.equalsIgnoreCase('US')) || String.isBlank(OD.FS_Country_Key__c)){                   
                if(OD.FS_Equip_Type__c!=null && OD.FS_Equip_Type__c!=''&& accMap.get(OD.FS_Outlet__c).RecordTypeId != accRecTypeBoE){    
                    //FET5.0 - for 7000/8000/9000/9100 equipment type CCNA record type
                    if(allPlatforms.contains(OD.FS_Equip_Type__c)){
                        OD.RecordTypeID=odRecTypeCCNA;
                    }
                }
            }  
        }
    }
    /**@desc populate OD's model, equip type and dispenser type base on Dispenser Model for International ODs
*@param List<FS_Outlet_Dispenser__c> newList- list of OD records in trigger context
*@return void
*/
    public static void platformForInt(){
        
        List<Id> dispenserModelIdList=new List<Id>();
        List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
        
        for(FS_Outlet_Dispenser__c odInstance: (List<FS_Outlet_Dispenser__c>)Trigger.new){
            if(odInstance.RecordTypeId==odRecTypeInternational && odInstance.FSInt_Dispenser_Type__c!=null){
                odList.add(odInstance);
                dispenserModelIdList.add(odInstance.FSInt_Dispenser_Type__c);
            }
        }
        Map<Id,Dispenser_Model__c> dispModelData=new Map<Id,Dispenser_Model__c>();        
        try{
            dispModelData=new Map<Id,Dispenser_Model__c>([select id,Dispenser_Type__c,Dispenser_Type1__c 
                                                                                 from Dispenser_Model__c where id IN :dispenserModelIdList]);
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog('FET-7.0','FsODTriggerHelper','platformForInt','Account','Medium',e,'NA');
        }
        for(FS_Outlet_Dispenser__c odInstance :odList){
            if(dispModelData.containsKey(odInstance.FSInt_Dispenser_Type__c)){
                Dispenser_Model__c dis=dispModelData.get(odInstance.FSInt_Dispenser_Type__c);
                odInstance.FS_Equip_Type__c=dis.Dispenser_Type__c;
                odInstance.FS_Dispenser_Type2__c=dis.Dispenser_Type1__c;
            }
        }
    }
    
    /** @Desc - If Effective date is >= today then copy the same attributes to Integration values.
* @param - Trigger context variables(Trigger.new)
* @Return - void
*/
    public static boolean CheckEffectiveDate(FS_Outlet_Dispenser__c outletDisp){
        boolean isCurrentDate = false; 
        FS_Integration_NMS_User__c nmsUser = FS_Integration_NMS_User__c.getInstance();        
        String loggedInUser = UserInfo.getUserName();       
        if (loggedInUser != nmsUser.username__c){           
            //Blank out post Install values and effective date when effective date is reached            
            if(odRecTypeInternational   != outletDisp.RecordTypeId){
                if (outletDisp.FS_7000_Series_Hide_Water_Effective_Date__c  == System.Today()) {
                    outletDisp.FS_7000_Series_Hide_Water_Button__c= outletDisp.FS_7000_Series_Hide_Water_Button_New__c  ; 
                    outletDisp.FS_7000_Series_Hide_Water_Button_New__c='';    
                    outletDisp.FS_7000_Series_Hide_Water_Effective_Date__c=null;
                    isCurrentDate = true;
                    if (outletDisp.FS_Brand_Selection_Value_Effective_Date__c  == System.Today() && outletDisp.FS_7000_Series_Static_Selection_New__c!=null &&!(outletDisp.FS_7000_Series_Static_Selection_New__c.Contains('Vitamin Water') && outletDisp.FS_7000_Series_Static_Selection_New__c.Contains('POWERade'))) {
                        outletDisp.FS_7000_Series_Static_Brands_Selections__c=outletDisp.FS_7000_Series_Static_Selection_New__c; 
                        outletDisp.FS_7000_Series_Agitated_Brands_Selection__c = outletDisp.FS_7000_Series_Agitated_Selections_New__c ;
                        outletDisp.FS_7000_Series_Brands_Option_Selections__c = outletDisp.FS_7000_Series_Brands_Selection_New__c ;
                        outletDisp.FS_7000_Series_Static_Selection_New__c='';
                        outletDisp.FS_7000_Series_Agitated_Selections_New__c='';
                        outletDisp.FS_7000_Series_Brands_Selection_New__c='';
                        outletDisp.FS_Brand_Selection_Value_Effective_Date__c=null;
                        isCurrentDate = true;  
                    }
                }else{
                    if (outletDisp.Brand_Set_Effective_Date__c  == System.Today()) {
                        outletDisp.Brand_Set__c= outletDisp.Brand_Set_New__c;
                        outletDisp.Brand_Set_New__c='';
                        outletDisp.Brand_Set_Effective_Date__c=null;
                        
                    }
                }
                if (outletDisp.FS_LTO_Effective_Date__c == System.Today()) {
                    outletDisp.FS_LTO__c=outletDisp.FS_LTO_New__c ; 
                    outletDisp.FS_LTO_New__c='';
                    outletDisp.FS_LTO_Effective_Date__c=null;
                    
                }            
                if (outletDisp.FS_FAV_MIX_Effective_Date__c == System.Today()) {                
                    // outletDisp.FS_FAV_MIX__c=outletDisp.FS_FAV_MIX_New__c; 
                    // outletDisp.FS_FAV_MIX_New__c='';
                    outletDisp.FS_FAV_MIX_Effective_Date__c=null;
                    isCurrentDate = true;
                }
                
                if (outletDisp.FS_Water_Hide_Show_Effective_Date__c  == System.Today()) {
                    outletDisp.FS_Water_Button__c= outletDisp.FS_Water_Button_New__c; 
                    outletDisp.FS_Water_Button_New__c='';
                    outletDisp.FS_Water_Hide_Show_Effective_Date__c =null;
                    
                }
                
                if (outletDisp.FS_CE_Enabled_Effective_Date__c  == System.Today()) {
                    outletDisp.FS_CE_Enabled__c= outletDisp.FS_CE_Enabled_New__c; 
                    outletDisp.FS_CE_Enabled_New__c='';
                    outletDisp.FS_CE_Enabled_Effective_Date__c=null;
                    isCurrentDate = true;
                }
                
                /*  if (outletDisp.FS_Dasani_Settings_Effective_Date__c == System.Today()) {
outletDisp.FS_Dasani__c= outletDisp.FS_Dasani_New__c ; 
outletDisp.FS_Dasani_New__c='';
outletDisp.FS_Dasani_Settings_Effective_Date__c=null;
isCurrentDate = true;
}*/
                
                
                if (outletDisp.FS_Promo_Enabled_Effective_Date__c  == System.Today()) {
                    outletDisp.FS_Promo_Enabled__c=outletDisp.FS_Promo_Enabled_New__c; 
                    outletDisp.FS_Promo_Enabled_New__c='';
                    outletDisp.FS_Promo_Enabled_Effective_Date__c=null;
                    
                }
                
                /*if (outletDisp.FS_Spicy_Cherry_Effective_Date__c == System.Today()) {
outletDisp.FS_Spicy_Cherry__c= outletDisp.FS_Spicy_Cherry_New__c ; 
outletDisp.FS_Spicy_Cherry_New__c ='';
outletDisp.FS_Spicy_Cherry_Effective_Date__c=null;
isCurrentDate = true;
}*/
                
                if (outletDisp.FS_Valid_Fill_Settings_Effective_Date__c  == System.Today()) {
                    outletDisp.FS_Valid_Fill__c= outletDisp.FS_Valid_Fill_New__c;
                    outletDisp.FS_Valid_Fill_New__c='';
                    outletDisp.FS_Valid_Fill_Settings_Effective_Date__c=null;
                    
                }        
                
            }
        }
        return isCurrentDate;
    }
    
    /** @Desc - While insert link OD to correct Installation. If multiple then send notification mail
* @param - Trigger context variables(Trigger.new)
* @Return - void
*/
    public static void linkInstODBeforeInsert(){
        Set<Id> outletIds=new Set<Id>();
        List<FS_Installation__c> openinstall=new List<FS_Installation__c>();
        List<FS_Installation__c> relocinstall=new List<FS_Installation__c>();
        List<FS_Installation__c> replaceinstall=new List<FS_Installation__c>();
        set<FS_Installation__c> mailingInstall=new Set<FS_Installation__c>();
        Map<String,Id> brandDispenserTypeMap=new Map<String,Id>();
        Boolean check=false;
        boolean duplicateMatch = false;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)Trigger.new){
            outletIds.add(od.FS_Outlet__c);
        }
        //Fetch all installation using under same outlet
        List<FS_Installation__c> installList=[select Id,FS_Same_incoming_platform__c,Name,Outlet_ACN__c,FS_Outlet__c,Type_of_Dispenser_Platform__c,FS_Overall_Status__c,recordtype.name from FS_Installation__c where FS_Outlet__c IN:outletIds];//Modified as part of FET-7.0 FNF 795
        //Fetch all replacement type installation
        List<FS_Installation__c> replacementInstallationId = [select Id from FS_Installation__c where FS_Outlet__c IN:outletIds and RecordTypeId =: FSInstallationValidateAndSet.ipRecTypeReplacement];
        List<Id> installationId = new List<Id>();
        for(FS_Installation__c inst : replacementInstallationId){
            installationId.add(inst.Id);
        }
        List<FS_Association_Brandset__c> associateBrandList=[select Id,FS_Brandset__c,FS_Platform__c,FS_Installation__c,FS_NonBranded_Water__c from FS_Association_Brandset__c where FS_Installation__c IN :installationId];
        Map<Id,Map<String,Id>> replacementPlatformBrandset = new Map<Id,Map<String,Id>>();
        for(FS_Association_Brandset__c brandSet:associateBrandList){
            String platInstallId = brandSet.FS_Platform__c + brandSet.FS_Installation__c ;            
            brandDispenserTypeMap.put(platInstallId , brandSet.FS_Brandset__c);
            
        }        
        String outletACN='';
        //Based on installation status add installation to list and find out any dupicate installation is there
        String IP_Excl_Status = Label.IP_Excluding_Status;
        for(FS_Installation__c install:installList){
            outletACN=install.Outlet_ACN__c;
            if((install.recordtype.name==FSConstants.NEWINSTALLATION ) && install.FS_Overall_Status__c!=null&& (!IP_Excl_Status.contains(install.FS_Overall_Status__c) )){
                openinstall.add(install);                
            }
            else if(install.recordtype.name==Label.IP_Replacement_Rec_Type && install.FS_Same_incoming_platform__c == FSConstants.YES 
                    && (install.FS_Overall_Status__c==FSConstants.x1ReadySchedule || 
                        install.FS_Overall_Status__c==FSConstants.x3PendingSchedu ||
                        install.FS_Overall_Status__c==FSConstants.onHolds ||       
                        install.FS_Overall_Status__c==FSConstants.scheduled)){
                            replaceinstall.add(install);
                        }
        }
        //Variables to use inside loacl method only
        integer matchOpenInstallCount = 0;
        integer matchRelocationCount = 0;
        integer matchReplacementCount = 0;
        Map<String,Id> brandPlatformMap=new Map<String,Id>();            
        for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)Trigger.new){                 
            for(FS_Installation__c openInstll:openinstall){
                
                if(od.FS_Outlet__c==openInstll.FS_Outlet__c && od.FS_Equip_Type__c!=null &&  openInstll.Type_of_Dispenser_Platform__c!=null && openInstll.Type_of_Dispenser_Platform__c.contains(od.FS_Equip_Type__c)){
                    matchOpenInstallCount  = matchOpenInstallCount  +1;
                    mailingInstall.add(openInstll);
                    if(matchOpenInstallCount > valOne){
                        duplicateMatch = true;                            
                    } 
                }
                
            }         
            /*
for(FS_Installation__c relocInstallation:relocinstall){

if(od.FS_Outlet__c==relocInstallation.FS_Outlet__c ){
matchRelocationCount  = matchRelocationCount +1;
mailingInstall.add(relocInstallation);
if(matchRelocationCount > valOne)                           
{
duplicateMatch = true;                            
}
}
} */        
            for(FS_Installation__c repInstall:replaceinstall){
                
                if(od.FS_Outlet__c==repInstall.FS_Outlet__c && od.FS_Equip_Type__c!=null 
					&& repInstall.Type_of_Dispenser_Platform__c!=null 
                    && repInstall.Type_of_Dispenser_Platform__c.contains(od.FS_Equip_Type__c) ){
                    matchReplacementCount = matchReplacementCount +1;
                    mailingInstall.add(repInstall);
                    if(matchReplacementCount > valOne){
                        duplicateMatch = true;                            
                    }
                }
            }                      
            if(matchReplacementCount + matchRelocationCount  + matchOpenInstallCount > valOne){                      
                duplicateMatch = true;
            }             
            
            Id activeInstallForm = null;
            
            for(FS_Installation__c install:openinstall){
                String recordTypeName=FSInstallationValidateAndSet.mapofRecordtypIdAndRecordTypeName.get(install.recordTypeId);
                if(Trigger.isBefore && od.FS_Equip_Type__c!=null &&  install.Type_of_Dispenser_Platform__c!=null && install.Type_of_Dispenser_Platform__c.contains(od.FS_Equip_Type__c))  {
                    if(od.FS_Outlet__c==install.FS_Outlet__c){
                        od.Installation__c=install.Id;
                        check=true;                        
                        break;
                    }
                }
            }
            /*if(!check ){
for(FS_Installation__c install:relocinstall){
if(od.FS_Outlet__c==install.FS_Outlet__c && od.FS_Equip_Type__c!=null && install.Type_of_Dispenser_Platform__c!=null && install.Type_of_Dispenser_Platform__c.contains(od.FS_Equip_Type__c)){
od.Installation__c=install.Id;                                
check=true;                           
break;
}
} 
}*/
            if(!check ){
                for(FS_Installation__c install:replaceinstall){
                    if(Trigger.isBefore && 
                       od.FS_Outlet__c==install.FS_Outlet__c && 
                       install.Type_of_Dispenser_Platform__c!=null && 
                       od.FS_Equip_Type__c!=null && 
                       install.Type_of_Dispenser_Platform__c.contains(od.FS_Equip_Type__c)){ //Modified the condition as part of FET-7.0 FNF 795
                        od.Installation__c=install.Id;                                                       
                        check=true;                                                            
                        break;
                    }
                } 
            }
            
            //If any duplicate installation then send notification mail
            if(Trigger.isAfter &&(duplicateMatch || od.Installation__c==null)){                    
                Messaging.SingleEmailMessage mail=sendNotificationForMulipleMatch(outletACN,od,mailingInstall);
                if(mail!=nullValue()){                        
                    mails.add(mail);
                }               
            } 
            
        }      
        if(!emailrunonce && Trigger.isAfter){
            try{
                emailrunonce=true;                    
                if(!mails.isEmpty() && Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){
                    Messaging.sendEmail(mails);
                }
            }
            catch(EmailException ex){
                ApexErrorLogger.addApexErrorLog('FET','FSOutletDispenserTriggerHandler','updateBrandsFromInstallation','Messaging','Medium',ex,'NA');
            }
        }
    }
    
    /** @Desc - Update brands details from installations - before insert/before update
* @param - Trigger context variables(Trigger.isUpdate,Trigger.newMap,Trigger.oldMap)
* @Return - void
*/
    
    public static void populateBrandsFromInst(boolean isUpdate,Map<Id,FS_Outlet_Dispenser__C> newMap,Map<Id,FS_Outlet_Dispenser__C> oldMap){
        
        Set<Id> installationIDSet = new Set<Id>();
        Set<String> odSerialNumber=new Set<String>();
        Set<Id> relocatedODOutletId=new Set<Id>();        
        if(isUpdate){
            Map<ID, FS_Outlet_Dispenser__c> oldMapI = oldMap;
            Map<ID,FS_Outlet_Dispenser__c> newMapI = newMap;
            for(ID odid: newMap.keySet()){
                if(odRecTypeInternational  != newMap.get(odid).RecordTypeId){                    
                    if(oldMapI.get(odid).Installation__c != newMapI.get(odid).Installation__c){                        
                        if(newMapI.get(odid).Installation__c != nullValue()){                            
                            installationIDSet.add(newMapI.get(odid).Installation__c);
                        }
                    }
                }
            }           
        }
        else{
            for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)Trigger.new){               
                if(odRecTypeInternational  != od.RecordTypeId) {
                    if(od.Installation__c != nullValue()){ 
                        installationIDSet.add(od.Installation__c);
                    }           if(String.isBlank(od.FS_Status__c)){
                        od.FS_Status__c = 'Pre-Enroll';
                    }
                    if(od.FS_Date_Status__c==nullValue()){ 
                        od.FS_Date_Status__c = Date.today();
                    }
                    if(od.FS_Serial_Number2__c!=nullValue()) {
                        odSerialNumber.add(od.FS_Serial_Number2__c);
                    }
                }
            }
        }      
        Map<Id,FS_Installation__c> installationMap;
        if(installationIDSet != null && !installationIDSet.isEmpty()){
            installationMap = new Map<Id,FS_Installation__c>([SELECT FS_7000_Series_Agitated_Brands_Selection__c
                                                              ,RecordTypeId,RecordType.Name,FS_7000_Series_Statics_Brands_Selection__c,FS_X7000_Series_Dispenser_c__c,FS_CS_Dispenser__c,
                                                              FS_Original_Install_Date__c,FS_Valid_fill_required__c,FS_X7000_Series_Dispenser_Placement__c,
                                                              FS_7000_Series_Brands_Option_Selections__c,FS_Spicy_Cherry__c,FS_SS_Dispenser__c,id FROM
                                                              FS_Installation__c WHERE id in :installationIDSet]);
            for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)Trigger.new){                
                if(od.Installation__c != nullValue() && installationMap.get(od.Installation__c)!= nullValue()){
                    od.FS_Planned_Install_Date__c = installationMap.get(od.Installation__c).FS_Original_Install_Date__c;                    
                    od.FS_Valid_Fill__c = installationMap.get(od.Installation__c).FS_Valid_fill_required__c;                    
                    //New logic
                    checkEquipmentType(od.FS_Equip_Type__c,installationMap,od);
                    
                }
            }
        }
        Map< String, Id > duplicateSerialNoMap = new Map< String, Id >();
        for( FS_Outlet_Dispenser__c c : [select Id, FS_Serial_Number2__c,FS_Outlet__c from FS_Outlet_Dispenser__c where FS_Serial_Number2__c = :odSerialNumber] ){
            duplicateSerialNoMap.put(c.FS_Serial_Number2__c,c.Id);  
        }
        for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)Trigger.new){
            Id existingODId = duplicateSerialNoMap.get(od.FS_Serial_Number2__c);
            if(existingODId!=null){
                relocatedODOutletId.add(od.FS_Outlet__c);
            }
        }
        List<FS_Installation__c> instalForRelocation=new List<FS_Installation__c>();
        if(relocatedODOutletId!=null && relocatedODOutletId.size()>0){
            instalForRelocation=[select id,FS_New_Outlet__c from FS_Installation__c where  FS_New_Outlet__c in:relocatedODOutletId and  FS_New_Outlet__c in:relocatedODOutletId and RecordTypeId=:FSInstallationValidateAndSet.ipRecTypeRelocation order by createdDate desc];
            for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)Trigger.new){
                for(FS_Installation__c relInst : instalForRelocation){
                    if(relInst.FS_New_Outlet__c!=null && relInst.FS_New_Outlet__c==od.FS_Outlet__c){
                        od.Installation__c=relInst.id;
                    }
                }
            }
        }
        for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)Trigger.new){
            if(odRecTypeInternational  != od.RecordTypeId){
                if(od.FS_Equip_Type__c == val7000){
                    if(od.FS_7000_Series_Agitated_Brands_Selection__c != nullValue() &&
                       !od.FS_7000_Series_Agitated_Brands_Selection__c.contains(FSConstants.naTo80009000S)){
                           od.FS_Selected_Brands__c = od.FS_7000_Series_Agitated_Brands_Selection__c.replace(';',',');
                       }
                    if(od.FS_7000_Series_Static_Brands_Selections__c != nullValue() &&
                       !od.FS_7000_Series_Static_Brands_Selections__c.contains(FSConstants.naTo80009000S)){
                           if(od.FS_Selected_Brands__c != nullValue()){
                               od.FS_Selected_Brands__c = od.FS_Selected_Brands__c + ',' + od.FS_7000_Series_Static_Brands_Selections__c.replace(';',',');
                           }
                           else{
                               od.FS_Selected_Brands__c = od.FS_7000_Series_Static_Brands_Selections__c.replace(';',',');
                           }
                       }
                }//else{
                // od.FS_Selected_Brands__c = od.FS_Spicy_Cherry__c;
                //}
            }
        }
        FS_Integration_NMS_User__c nmsUser=FS_Integration_NMS_User__c.getInstance(UserInfo.getUserId());
        
        if(isUpdate){
            //Local variable to send values
            String NMS='NMS';
            String FET='FET';
            if(UserInfo.getUserId()==nmsUser.Username__c){
                updateOverRiddenFields(oldMap,newMap,NMS);
                
            }else{
                updateOverRiddenFields(newMap,oldMap,FET);
            }
            
        }       
    }
    //Helper Method to used in previous method to update Overridden fields 
    private static void updateOverRiddenFields(Map<Id,FS_Outlet_Dispenser__C> newMap,Map<Id,FS_Outlet_Dispenser__C> oldMap,String str1){
        Map<ID,FS_Outlet_Dispenser__c> newMapI = newMap;
        Map<ID, FS_Outlet_Dispenser__c> oldMapI = oldMap;
        for(FS_Outlet_Dispenser__c od : (List<FS_Outlet_Dispenser__c>)Trigger.new){
            if(oldMapI.get(od.Id).FS_LTO__c!=newMapI.get(od.Id).FS_LTO__c){
                od.FS_LTO_Overridden__c=str1;
            }
            
            if(oldMapI.get(od.Id).FS_7000_Series_Hide_Water_Button__c!=newMapI.get(od.Id).FS_7000_Series_Hide_Water_Button__c){
                od.FS_7000_Series_Hide_Water_Overridden__c=str1;
            }
            
            if(oldMapI.get(od.Id).FS_Water_Button__c!=newMapI.get(od.Id).FS_Water_Button__c){
                od.FS_Water_Hide_Show_Overridden__c=str1;
            }
            
            if(oldMapI.get(od.Id).FS_CE_Enabled__c!=newMapI.get(od.Id).FS_CE_Enabled__c){
                od.FS_CE_Enabled_Overridden__c=str1;
            }
            
            /*  if(oldMapI.get(od.Id).FS_Dasani__c!=newMapI.get(od.Id).FS_Dasani__c){
od.FS_Dasani_Settings_Overridden__c=str1;
} */
            
            /*  if(oldMapI.get(od.Id).FS_FAV_MIX__c!=newMapI.get(od.Id).FS_FAV_MIX__c){
od.FS_FAV_MIX_Overridden__c=str1;
}*/
            
            if(oldMapI.get(od.Id).FS_Promo_Enabled__c!=newMapI.get(od.Id).FS_Promo_Enabled__c){
                od.FS_Promo_Enabled_Overridden__c=str1;
            }
            
            /*if(oldMapI.get(od.Id).FS_Spicy_Cherry__c!=newMapI.get(od.Id).FS_Spicy_Cherry__c){
od.FS_Spicy_Cherry_Overridden__c=str1;
}*/
            
            if(oldMapI.get(od.Id).FS_Valid_Fill__c!=newMapI.get(od.Id).FS_Valid_Fill__c){
                od.FS_Valid_Fill_Settings_Overridden__c=str1;
            }
            
            if(oldMapI.get(od.Id).FS_7000_Series_Agitated_Brands_Selection__c != newMapI.get(od.Id).FS_7000_Series_Agitated_Brands_Selection__c){
                od.FS_Agitated_Selection_Value_Overridden__c=str1;
            }
            
            if(oldMapI.get(od.Id).FS_7000_Series_Static_Brands_Selections__c !=newMapI.get(od.Id).FS_7000_Series_Static_Brands_Selections__c){
                od.FS_7000_Series_Static_Brands_Overridden__c =str1;
            }
            
            if(oldMapI.get(od.Id).FS_7000_Series_Brands_Option_Selections__c !=newMapI.get(od.Id).FS_7000_Series_Brands_Option_Selections__c){
                od.FS_7000_Series_Brands_Option_Overridden__c=str1;
            }
        }
    }
    /** @Desc - Send mail notification if duplicate installation found
* @param - Trigger context variables(Trigger.isUpdate,Trigger.newMap,Trigger.oldMap)
* @Return - void
*/
    public static Messaging.SingleEmailMessage sendNotificationForMulipleMatch(String acn,FS_Outlet_Dispenser__c outletDisp, set<FS_Installation__c> instList){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Set<String> recepientEmails=new Set<String>();
        String serialNumber=outletDisp.FS_Serial_Number__c;
        Id odid=outletDisp.id;
        if(!system.Test.isRunningTest()){
            recepientEmails.add(Label.Mail_ID_for_NotificationForMultipleMatch_Installations_OD1);
            recepientEmails.add(Label.Mail_ID_for_NotificationForMultipleMatch_Installations_OD2);
            recepientEmails.add(Label.Mail_ID_for_NotificationForMultipleMatch_Installations_OD3);
        }         
        String subjectOfEmail='Outlet Dispenser Record Linkage Issue';
        String bodyOfEmail='Outlet Dispenser Serial number ' ;
        bodyOfEmail=bodyOfEmail+'<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +odid +'">'+ serialNumber +'</a> ';    
        bodyOfEmail=bodyOfEmail+ ' was created against ';
        bodyOfEmail=bodyOfEmail+ '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +outletDisp.FS_Outlet__c +'">'+ outletDisp.FS_Name1__c+'</a>';
        bodyOfEmail=bodyOfEmail+ ', and was unable to link to an open install transaction or may have been linked to the incorrect installation record. Please correct any dispenser creation/linking issue that may exist.';
        bodyOfEmail=bodyOfEmail.replaceAll('null',' ');
        mail = FSUtil.sendEmail(new List<String>(recepientEmails),subjectOfEmail,bodyOfEmail,true);
        return mail;
    }
    //Comented out below method as field is removed from installation
    /** @Desc - populate OD dispenser type from IP_Technician_Instructions
* @param - Trigger context variables(Trigger.new)
* @Return - void

public static void popDispenserTypeFromIPTI(){
List<FS_IP_Technician_Instructions__c> IPTIList;
List<FS_Outlet_Dispenser__c> ODList=new List<FS_Outlet_Dispenser__c>();            
set<Id> ODIns7000Set=new set<Id>();
Map<Id,FS_IP_Technician_Instructions__c> mapIDTech = new Map<Id,FS_IP_Technician_Instructions__c>();  
for(FS_Outlet_Dispenser__c OD:(List<FS_Outlet_Dispenser__c>)Trigger.new){
if(odRecTypeInternational != OD.RecordTypeId && OD.FS_Equip_Type__c==val7000){  
ODIns7000Set.add(OD.Installation__c); 
}           
}  
//Modified the RecordTypeID, FET5.0
IPTIList= [Select Id,FS_7000_Series_Dispenser_Placement__c,FS_Instalation_Process__c From FS_IP_Technician_Instructions__c Where FS_Instalation_Process__c=:ODIns7000Set AND RecordTypeId=:FSInstallationValidateAndSet.ipNewTIrectype];                
for(FS_IP_Technician_Instructions__c IPTech:IPTIList){
mapIDTech.put(IPTech.FS_Instalation_Process__c,IPTech);
}

for(FS_Outlet_Dispenser__c OD:(List<FS_Outlet_Dispenser__c>)Trigger.new){  
if(odRecTypeInternational   != OD.RecordTypeId && OD.FS_Equip_Type__c==val7000 && mapIDTech.get(OD.Installation__c)!= null){                

OD.FS_Dispenser_Type2__c=mapIDTech.get(OD.Installation__c).FS_7000_Series_Dispenser_Placement__c;         
}         
}        
}
*/
    
    /** @Desc - populate OD Code field from FS_IP_Equipment_Package__c 
* @param - Trigger context variables(Trigger.new)
* @Return - void
*/
    public static void popCodeFieldFromIPEP(){ 
        List<FS_IP_Equipment_Package__c> IPEqupPckgList;
        List<FS_Outlet_Dispenser__c> ODList=new List<FS_Outlet_Dispenser__c>();            
        set<Id> ODInsSet=new set<Id>();
        Map<String,FS_IP_Equipment_Package__c> IPID_EqipmentPackageMap= new Map<String,FS_IP_Equipment_Package__c>();
        for(FS_Outlet_Dispenser__c OD:(List<FS_Outlet_Dispenser__c>)Trigger.new){
            if(odRecTypeInternational != OD.RecordTypeId){
                ODInsSet.add(OD.Installation__c);  
            }
        }  
        
        IPEqupPckgList= [Select Id,FS_Dispenser_Series_IC_code__c,FS_Installation__c,FS_Platform_Type__c From                 FS_IP_Equipment_Package__c Where FS_Installation__c=:ODInsSet ];
        for( FS_IP_Equipment_Package__c IPEP:IPEqupPckgList){
            IPID_EqipmentPackageMap.put(IPEP.FS_Installation__c+IPEP.FS_Platform_Type__c,IPEP);
        }
        // Added these lines for IPEP Dispenser series IC code,FET 5.0
        for(FS_Outlet_Dispenser__c OD:(List<FS_Outlet_Dispenser__c>)Trigger.new){ 
            if(odRecTypeInternational  != OD.RecordTypeId && IPID_EqipmentPackageMap!=null && IPID_EqipmentPackageMap.containsKey(OD.Installation__c+OD.FS_Equip_Type__c)) {
                OD.FS_Code__c=IPID_EqipmentPackageMap.get(OD.Installation__c+OD.FS_Equip_Type__c).FS_Dispenser_Series_IC_code__c;  
            }
        }        
    }
    public static void populateDispenserLocation()
    {
        if(checkRecursive.runOnce()) {
            List<Id> dispOutletIds = new List<Id>();
            List<FS_Outlet_Dispenser__c> totalDispensers = new List<FS_Outlet_Dispenser__c>();
            Map<Id, wrapdispLocation> dispLocMap = new Map<Id, wrapdispLocation>();
            Map<Id,FS_Outlet_Dispenser__c> oldMap1 = (Map<Id,FS_Outlet_Dispenser__c>)Trigger.oldMap;
            for(FS_Outlet_Dispenser__c OD:(List<FS_Outlet_Dispenser__c>)Trigger.new){
                if(OD.FS_Apply_to_all_dispensers_in_Outlet__c <> oldMap1.get(OD.Id).FS_Apply_to_all_dispensers_in_Outlet__c ||
                   OD.FS_isPublic__c <> oldMap1.get(OD.Id).FS_isPublic__c ||
                   OD.FS_Loc_Finder_Latitude__c <> oldMap1.get(OD.Id).FS_Loc_Finder_Latitude__c ||
                   OD.FS_Loc_Finder_Longitude__c <> oldMap1.get(OD.Id).FS_Loc_Finder_Longitude__c)
                {
                    dispOutletIds.add(OD.FS_Outlet__c);
                    if(dispLocMap.get(OD.FS_Outlet__c) == null)
                    {
                        wrapdispLocation newwrapdisploc = new wrapdispLocation(OD.FS_Apply_to_all_dispensers_in_Outlet__c, OD.FS_isPublic__c, OD.FS_Loc_Finder_Latitude__c, OD.FS_Loc_Finder_Longitude__c);
                        dispLocMap.put(OD.FS_Outlet__c, newwrapdisploc);    
                    }
                }
            }
            
            if(!dispOutletIds.isEmpty())
            {
                totalDispensers = [select id, FS_Outlet__c, FS_Apply_to_all_dispensers_in_Outlet__c, FS_isPublic__c, FS_Loc_Finder_Latitude__c, FS_Loc_Finder_Longitude__c from FS_Outlet_Dispenser__c where FS_Outlet__c in :dispOutletIds];
                for(FS_Outlet_Dispenser__c retOD: totalDispensers)
                {
                    if(dispLocMap.get(retOD.FS_Outlet__c).isApply)
                    {
                        retOD.FS_Apply_to_all_dispensers_in_Outlet__c = dispLocMap.get(retOD.FS_Outlet__c).isApply;
                        retOD.FS_isPublic__c = dispLocMap.get(retOD.FS_Outlet__c).isPublic;
                        retOD.FS_Loc_Finder_Latitude__c = dispLocMap.get(retOD.FS_Outlet__c).dispLatitude;
                        retOD.FS_Loc_Finder_Longitude__c = dispLocMap.get(retOD.FS_Outlet__c).dispLongitude;
                    }
                    else
                    {
                        retOD.FS_Apply_to_all_dispensers_in_Outlet__c = dispLocMap.get(retOD.FS_Outlet__c).isApply;
                    }
                    
                }
                update totalDispensers;
            }
        }
        
    }
    
    public static void DispenserLocationonOnInsert()
    {
        List<Id> dispOutletIds = new List<Id>();
        List<FS_Outlet_Dispenser__c> multiDispList = new List<FS_Outlet_Dispenser__c>();
        List<FS_Outlet_Dispenser__c> singleDispList = new List<FS_Outlet_Dispenser__c>();
        List<Account> outletwithODs = new List<Account>();
        Map<Id, FS_Outlet_Dispenser__c> dispoutletMap = new Map<Id, FS_Outlet_Dispenser__c>();
        Map<Id, FS_Outlet_Dispenser__c> multiDispoutletMap = new Map<Id, FS_Outlet_Dispenser__c>();
        List<FS_Outlet_Dispenser__c> totalDispensers = new List<FS_Outlet_Dispenser__c>();
        
        for(FS_Outlet_Dispenser__c OD:(List<FS_Outlet_Dispenser__c>)Trigger.new){
            dispOutletIds.add(OD.FS_Outlet__c);
            dispoutletMap.put(OD.FS_Outlet__c, OD);
        }
        
        if(!dispOutletIds.isEmpty())
        {
            List<account> totaloutlets = [select id, nb_Outlet_Dispensers__c  from account where Id in :dispOutletIds];
            for(Account out: totaloutlets)
            {
                If(out.nb_Outlet_Dispensers__c == 0)
                {
                    FS_Outlet_Dispenser__c od1 = new FS_Outlet_Dispenser__c();
                    od1 = dispoutletMap.get(out.Id);
                    od1.FS_Apply_to_all_dispensers_in_Outlet__c = true;
                    singleDispList.add(od1);
                }
                If(out.nb_Outlet_Dispensers__c > 0)
                {
                    outletwithODs.add(out);
                    multiDispList.add(dispoutletMap.get(out.Id));
                }
            }
        }
        
        List<FS_Outlet_Dispenser__c> existODs = [select id, FS_Outlet__c , FS_Loc_Finder_Reviewed_On__c, FS_Apply_to_all_dispensers_in_Outlet__c , FS_isPublic__c, FS_Loc_Finder_Latitude__c, FS_Loc_Finder_Longitude__c from FS_Outlet_Dispenser__c where FS_Outlet__c in :outletwithODs order by FS_Outlet__c ,FS_Loc_Finder_Reviewed_On__c desc NULLS LAST];
        
        for(FS_Outlet_Dispenser__c OD: existODs)
        {
            If(multiDispoutletMap.get(OD.FS_Outlet__c) == null && OD.FS_Loc_Finder_Reviewed_On__c <> null)
            {
                multiDispoutletMap.put(OD.FS_Outlet__c, OD);
            }
        }
        
        for(FS_Outlet_Dispenser__c OD2: multiDispList)
        {
            If(multiDispoutletMap.get(OD2.FS_Outlet__c) <> null)
            {
                //If(multiDispoutletMap.get(OD2.FS_Outlet__c).FS_Apply_to_all_dispensers_in_Outlet__c)
                //{
                    OD2.FS_Apply_to_all_dispensers_in_Outlet__c = multiDispoutletMap.get(OD2.FS_Outlet__c).FS_Apply_to_all_dispensers_in_Outlet__c ;
                    OD2.FS_isPublic__c = multiDispoutletMap.get(OD2.FS_Outlet__c).FS_isPublic__c ;
                    OD2.FS_Loc_Finder_Latitude__c = multiDispoutletMap.get(OD2.FS_Outlet__c).FS_Loc_Finder_Latitude__c ;
                    OD2.FS_Loc_Finder_Longitude__c = multiDispoutletMap.get(OD2.FS_Outlet__c).FS_Loc_Finder_Longitude__c ;
                //}
                //else
                //{
                    //OD2.FS_Apply_to_all_dispensers_in_Outlet__c = multiDispoutletMap.get(OD2.FS_Outlet__c).FS_Apply_to_all_dispensers_in_Outlet__c ;
                //}
            }
            
        }
        //update multiDispList;
        //update singleDispList;
    }
    /** @Desc - Based on field change on OD update attribute of OD  
* @param - Trigger context variables(Trigger.new)
* @Return - Map<Id, String>
*/
    public static Map<Id, String> attributeChange(FS_Outlet_Dispenser__c dispenserObj,Map<Id, String> mapDispenserIdstrDispenserAttrChange){
        Map<Id,FS_Outlet_Dispenser__c> oldMap = (Map<Id,FS_Outlet_Dispenser__c>)Trigger.oldMap;
        final String OD_Hibernation_Winterization = Label.OD_Hibernation_Winterization;
        if( (dispenserObj.Installation__c != oldMap.get(dispenserObj.id).Installation__c)
           || ((dispenserObj.FS_Equip_type__c != oldMap.get(dispenserObj.id).FS_Equip_type__c)
               && dispenserObj.FS_IsActive__c == true && oldMap.get(dispenserObj.id).FS_IsActive__c != false)
           || ((dispenserObj.FS_IsActive__c == true && oldMap.get(dispenserObj.id).FS_IsActive__c != dispenserObj.FS_IsActive__c) 
               && userInfo.getUserName() == Label.SAP_Service_User)
           || (dispenserObj.Ownership_Type__c != oldMap.get(dispenserObj.id).Ownership_Type__c)
           || ((dispenserObj.FS_Status__c != oldMap.get(dispenserObj.id).FS_Status__c) && (dispenserObj.FS_Status__c == Label.OD_Enrolled_Status))
           || (dispenserObj.FS_Equip_Type__c != oldMap.get(dispenserObj.id).FS_Equip_Type__c)
           || (dispenserObj.OD_Settings_Timestamp__c != oldMap.get(dispenserObj.id).OD_Settings_Timestamp__c)
           || (dispenserObj.FS_Dispenser_Type2__c!= oldMap.get(dispenserObj.id).FS_Dispenser_Type2__c)
           || (dispenserObj.FS_Dispenser_Location__c!= oldMap.get(dispenserObj.id).FS_Dispenser_Location__c)
           || (dispenserObj.Country__c!= oldMap.get(dispenserObj.id).Country__c)) {
               
               if(dispenserObj.FS_IsActive__c && dispenserObj.FS_Status__c!='New') {
                   if(mapDispenserIdstrDispenserAttrChange.containsKey(dispenserObj.id) && mapDispenserIdstrDispenserAttrChange.get(dispenserObj.id) =='Flavor') {
                       mapDispenserIdstrDispenserAttrChange.put(dispenserObj.id, 'Both');
                   } else {
                       mapDispenserIdstrDispenserAttrChange.put(dispenserObj.id, 'Dispenser');
                   }
               }else if(!dispenserObj.FS_IsActive__c && LABEL.INCLUDE_INACTIVE_DISPENSERS_FOR_NMS.equalsIgnoreCase('TRUE')) {
                   if(mapDispenserIdstrDispenserAttrChange.containsKey(dispenserObj.id)&& mapDispenserIdstrDispenserAttrChange.get(dispenserObj.id) =='Flavor') {
                       mapDispenserIdstrDispenserAttrChange.put(dispenserObj.id, 'Both');
                   } else{
                       mapDispenserIdstrDispenserAttrChange.put(dispenserObj.id, 'Dispenser');
                   }
               }                                   
           } 
        
        if( (dispenserObj.FS_7000_Series_Brands_Option_Selections__c !=oldMap.get(dispenserObj.id).FS_7000_Series_Brands_Option_Selections__c)
           ||(dispenserObj.FS_7000_Series_Static_Brands_Selections__c !=oldMap.get(dispenserObj.id).FS_7000_Series_Static_Brands_Selections__c)
           ||(dispenserObj.FS_7000_Series_Agitated_Brands_Selection__c !=oldMap.get(dispenserObj.id).FS_7000_Series_Agitated_Brands_Selection__c)  
           ||(dispenserObj.FS_Water_Button__c != oldMap.get(dispenserObj.id).FS_Water_Button__c)    
           ||(dispenserObj.Hide_Water_Dispenser__c != oldMap.get(dispenserObj.id).Hide_Water_Dispenser__c)
           ||(dispenserObj.FS_Valid_Fill__c != oldMap.get(dispenserObj.id).FS_Valid_Fill__c)
           || (dispenserObj.FS_CE_Enabled__c!= oldMap.get(dispenserObj.id).FS_CE_Enabled__c)
           || (dispenserObj.FS_LTO__c!= oldMap.get(dispenserObj.id).FS_LTO__c)
           // || (dispenserObj.FS_FAV_MIX__c!= oldMap.get(dispenserObj.id).FS_FAV_MIX__c)
           || (dispenserObj.FS_Promo_Enabled__c!= oldMap.get(dispenserObj.id).FS_Promo_Enabled__c)
           || (dispenserObj.FS_Brandset__c!= oldMap.get(dispenserObj.id).FS_Brandset__c)
           || (dispenserObj.Brand_Set_formula__c!= oldMap.get(dispenserObj.id).Brand_Set_formula__c)) {
               
               if(dispenserObj.FS_IsActive__c) {
                   if(mapDispenserIdstrDispenserAttrChange.containsKey(dispenserObj.id)&& mapDispenserIdstrDispenserAttrChange.get(dispenserObj.id) =='Dispenser') {
                       mapDispenserIdstrDispenserAttrChange.put(dispenserObj.id, 'Both');
                   }else{
                       mapDispenserIdstrDispenserAttrChange.put(dispenserObj.id, 'Flavor');
                   }
               }else if(dispenserObj.FS_IsActive__c && LABEL.INCLUDE_INACTIVE_DISPENSERS_FOR_NMS.equalsIgnoreCase('TRUE')) {  
                   if(mapDispenserIdstrDispenserAttrChange.containsKey(dispenserObj.id)&& mapDispenserIdstrDispenserAttrChange.get(dispenserObj.id) =='Dispenser') {
                       mapDispenserIdstrDispenserAttrChange.put(dispenserObj.id, 'Both');
                   }else{
                       mapDispenserIdstrDispenserAttrChange.put(dispenserObj.id, 'Flavor');
                   }
               }
           }
        
        return  mapDispenserIdstrDispenserAttrChange;
    }
    
    /** @Desc - Send delete call to AW using OD Id  
* @param - NA
* @Return - Void
*/
    public static void deleteUnenrolledDispensers(Set<Id> setOutletDispenserIds){
        
        /**Record Splitter module Start******************************/
        //Records to be processed will be divided into chunks and processed separately to avoid callout limits
        Integer recordChunkSize=Integer.valueOf(Label.recordChunkSize);
        List<List<Object>> splittedList=FSRecordSplitterToAvoidGovernorLimits.processRecords(new List<Id>(setOutletDispenserIds),recordChunkSize);
        for(List<Object> splitListRecord: splittedList){
            Set<Id> deleteOds=new Set<Id>();
            
            for(Object obj : splitListRecord){
                deleteOds.add((Id)obj);
            }
            FSFETNMSConnector.deleteMasterAssetData(deleteOds);
            
        }
        /**Record Splitter module End******************************/ 
    }
    
    /** @Desc - Send notification to Bottler Contact  
* @param - Set<Id> odId
* @Return - Void
*/
    public static void sendEmailContact(Set<Id> oDId){
        try{
            String response='';
            List<FS_Outlet_Dispenser__c> oDList = [Select isDefaultOutlet__c, Outlet_Zip_Code__c,Outlet_Country__c, Warehouse_Name_formula__c,
                                                   Warehouse_Country_formula__c,FS_Outlet__r.ShippingPostalCode, FS_Serial_Number2__c,
                                                   FS_Outlet__r.shippingCountry, FS_Outlet__r.Bottlers_Name__c ,FS_Equip_Type__c,
                                                   Warehouse_Country_New__c From FS_Outlet_Dispenser__c
                                                   WHERE ID =: oDId];                                       
            Set<String> botAccount = new Set<String>(); 
            Set<String> outCountry = new Set<String>(); 
            for(FS_Outlet_Dispenser__c temp : oDList){
                botAccount.add( temp.FS_Outlet__r.bottlers_name__c);
                outCountry.add(temp.Outlet_Country__c);
            }
            //getting contact of bottler
            List<Contact> contactList= [Select id,Email,MailingCountry,Warehouse_Country__c,MailingPostalCode ,account.name from Contact where accountid in :botAccount];
            List<String> sendTo = new List<String>();
            //Changes for Bulk Email on OD status update
            List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail;
            //Changes for Bulk Email on OD status update
            String[] ccEmail;
            String equipmentType;   
            
            for(FS_Outlet_Dispenser__c od:oDList){
                mail = new Messaging.SingleEmailMessage();
                equipmentType=od.FS_Equip_Type__c;
                for(Contact c:contactList){
                    if(c.Warehouse_Country__c==od.FS_Outlet__r.shippingCountry){
                        sendTo.add(c.Email);
                        ccEmail=new String[]{UserInfo.getUserEmail()};
                            }
                }        
                //Recipients
                mail.setToAddresses(sendTo);
                mail.setCcAddresses(ccEmail);
                mail.setSenderDisplayName('Coca-Cola'); 
                mail.setSubject('FET International Dispenser Delivered' ); 
                String body= Label.Email_Subject;
                body=body+'<br>Dispenser with serial number '+od.FS_Serial_Number2__c;
                body=body+' a Series '+equipmentType
                    +' dispenser has been delivered to '+ od.Warehouse_Name_formula__c
                    +' in '+od.Warehouse_Country_formula__c
                    +'<br><br><b>This dispenser is available for Assignment to an Outlet. </b><br>';      
                mail.setHtmlBody(body);  
                lstMails.add(mail);                
            }try{
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(lstMails);                
            }catch(System.EmailException ex){                   
                ApexErrorLogger.addApexErrorLog('FET','EmailTriggerHelper','sendEmailContact','NA','Medium',ex,'NA');
            }catch(exception e){
                ApexErrorLogger.addApexErrorLog('FET','EmailTriggerHelper','sendEmailContact','NA','Medium',e,'NA');
            }     
            
        }catch(exception e){
            ApexErrorLogger.addApexErrorLog('FET','EmailTriggerHelper','sendEmailContact','NA','Medium',e,'NA');
        }
    }
    
    
    //Platform Utility logic
    public static void checkEquipmentType(String quType,Map<Id,FS_Installation__c> InstallationMap,FS_Outlet_Dispenser__c od){
        Map<String,Platform_Type_ctrl__c> platformsMap= Platform_Type_ctrl__c.getAll();
        //Equipment type 7000 below logic will execute        
        if(string.isNotEmpty(quType) && platformsMap.get('updateBrands').Platforms__c.contains(quType)){                        
            updateBrands(InstallationMap,od);
            //Equipment type 8000 below logic will execute
        }else if(string.isNotEmpty(quType) &&platformsMap.get('updatecrewServeDasani').Platforms__c.contains(quType)){                       
            
            updateBrandsNull(od);
            updatecrewServeDasani(InstallationMap,od);
            //Equipment type 9000 below logic will execute
        }else if(string.isNotEmpty(quType) &&platformsMap.get('updateSelfServeDasani').Platforms__c.contains(quType)){ 
            updateBrandsNull(od);
            updateSeldServeDasani(InstallationMap,od);
        }
    }
    //Equipment type 7000 below logic will execute
    private static void updateBrands(Map<Id,FS_Installation__c> InstallationMap,FS_Outlet_Dispenser__c od){
        od.FS_7000_Series_Agitated_Brands_Selection__c =
            installationMap.get(od.Installation__c).FS_7000_Series_Agitated_Brands_Selection__c;
        od.FS_7000_Series_Static_Brands_Selections__c =
            installationMap.get(od.Installation__c).FS_7000_Series_Statics_Brands_Selection__c;
        od.FS_7000_Series_Brands_Option_Selections__c =
            installationMap.get(od.Installation__c).FS_7000_Series_Brands_Option_Selections__c;            
        od.FS_Water_Button__c = '';          
        od.FS_Code__c = installationMap.get(od.Installation__c).FS_X7000_Series_Dispenser_c__c;
        od.FS_Dispenser_Type2__c = installationMap.get(od.Installation__c).FS_X7000_Series_Dispenser_Placement__c;
    }
    //For 8000/9000 series dispenser below brands will be empty
    private static void updateBrandsNull(FS_Outlet_Dispenser__c od){
        od.FS_7000_Series_Agitated_Brands_Selection__c = '';
        od.FS_7000_Series_Static_Brands_Selections__c = '';
        od.FS_7000_Series_Brands_Option_Selections__c = '';
        od.FS_7000_Series_Hide_Water_Button__c = ''; 
    }
    //Equipment type 8000 below logic will execute
    private static void updatecrewServeDasani(Map<Id,FS_Installation__c> InstallationMap,FS_Outlet_Dispenser__c od){
        od.FS_Dispenser_Type2__c = 'Crew Serve';
        od.FS_Code__c = installationMap.get(od.Installation__c).FS_CS_Dispenser__c;                        
    }
    //Equipment type 9000 below logic will execute
    private static void updateSeldServeDasani(Map<Id,FS_Installation__c> InstallationMap,FS_Outlet_Dispenser__c od){
        od.FS_Dispenser_Type2__c = 'Self Serve';
        od.FS_Code__c = installationMap.get(od.Installation__c).FS_SS_Dispenser__c;                         
    }
    
    /** @Desc - This Method is used to populate Marketing Fields on before events.
* @param - populateMarketingFields(Fs_outletdispenser__c dispenser)
* @Return - void
*/
    public static void populateMarketingFields(List<FS_Outlet_Dispenser__c> dispenserList){ 
        Set<id> AccountID = new Set<id>();
        for(FS_Outlet_Dispenser__c Dis: dispenserList){
            if(Dis.recordtypeid == odRecTypeCCNA){
                AccountID.add(Dis.FS_Outlet__c);
            }
        }
        Map<id, Account> AccMap = new Map<id, Account>([Select id, RecordTypeid, FS_CE_Enabled__c, FS_LTO__c, FS_Promo_Enabled__c from Account where id IN: AccountID]);
        
        for(FS_Outlet_Dispenser__c Dis: dispenserList){
            if(Dis.recordtypeid == odRecTypeCCNA && AccMap.containskey(Dis.FS_Outlet__c)){
                Dis.FS_CE_Enabled__c = AccMap.get(Dis.FS_Outlet__c).FS_CE_Enabled__c;
                Dis.FS_LTO__c = AccMap.get(Dis.FS_Outlet__c).FS_LTO__c;
                Dis.FS_Promo_Enabled__c = AccMap.get(Dis.FS_Outlet__c).FS_Promo_Enabled__c;
            }
        }
    }
    
    public class wrapdispLocation {
        public Boolean  isApply ;
        public String   isPublic ;
        public Decimal  dispLatitude ;
        public Decimal  dispLongitude ;
        
        public wrapdispLocation(Boolean isApply, String isPublic, Decimal dispLatitude, Decimal dispLongitude) {
            this.isApply = isApply;
            this.isPublic = isPublic;
            this.dispLatitude = dispLatitude;
            this.dispLongitude = dispLongitude;
        }
    }
}