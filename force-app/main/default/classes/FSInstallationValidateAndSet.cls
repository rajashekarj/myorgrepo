/***************************
Name         : FSInstallationValidateAndSet 
Created By   : Infosys
Created Date : 12/07/08/2016   
Usage        : This class holds the business logic of the InstallationTrigger
**************************/
public without sharing class FSInstallationValidateAndSet{  
    
    public static Boolean brandsetDateCheck=true;
    public static Boolean brandsetDateCheck1=true;
    public static Boolean validationForInstallDateCheckRunOnce=false;
    public static Boolean valueOnce=true;
    
    public static final String YES = 'Yes';
    public static final String STR_NO = 'No';    
    
    public static final Integer RUSHLIMITDAYS=16;   
    public static final Integer INT_FIVE = 5;
    public static final Integer INT_SEVEN = 7;
    public Static Id ipNewRecType;
    public Static Id ipNewEPrecType;
    public static Id ipNewTIrectype;
    public Static Id ipRecTypeRelocationO4W;
    public Static Id ipRecTypeRelocation;
    public Static Id ipRecTypeRemoval;
    public Static Id ipRecTypeReplacement;    
    
    public static Map<Id,String> mapofRecordtypIdAndRecordTypeName= new Map<Id,String>();
    public static Map<String,Id> mapofInstallationRecordtypNameAndRecordTypeId= new Map<String,Id>();
    public static Map<String,Id> mapofEquipmentPackageRecordtypNameAndRecordTypeId= new Map<String,Id>();
    public static Map<String,Id> mapofTechnicianInstructionRecordtypNameAndRecordTypeId= new Map<String,Id>();
    public static Set<Id> installCheckFalseIds,installIds;
    public static Map<Id, FS_Installation__c> installMap,installMapNull;
    
    public Static Id ipTIrecType9000;
    public static list<String> platformTypes = new list<String>{FSConstants.RECTYPE_6k,FSConstants.RECTYPE_65k,FSConstants.RECTYPE_9k,FSConstants.RECTYPE_91k};
    public static final String PROJECTNAME = 'FET';
    public static final String CLASSNAME = 'FSInstallationValidateAndSet';
    public static final String NA = 'NA';
    public static final String MEDIUM = 'Medium';
    static{        
        final ID referID=null;
        if(ipNewRecType==referID){
            ipNewRecType=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,FSConstants.NEWINSTALLATION);
        }
        
        if(ipRecTypeRelocation==referID){
            ipRecTypeRelocation=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,Label.IP_Relocation_I4W_Rec_Type);
        }
        if(ipRecTypeRelocationO4W==referID){
            ipRecTypeRelocationO4W=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,Label.IP_Relocation_O4W_Rec_Type);
        }
        if(ipRecTypeRemoval==referID){
            ipRecTypeRemoval=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,Label.IP_Removal_Rec_Type);
        }
        if(ipRecTypeReplacement==referID){
            ipRecTypeReplacement=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,Label.IP_Replacement_Rec_Type);
        }
        
        
        if(ipNewEPrecType==referID){
            ipNewEPrecType=FSUtil.getObjectRecordTypeId(FS_IP_Equipment_Package__c.sObjectType,'Equipment Package');
        }
        
        if(ipNewTIrectype==referID){
            ipNewTIrectype=FSUtil.getObjectRecordTypeId(FS_IP_Technician_Instructions__c.sObjectType,'Technician Instruction');
        }
        mapofRecordtypIdAndRecordTypeName.put(ipNewRecType,FSConstants.NEWINSTALLATION);
        
        mapofRecordtypIdAndRecordTypeName.put(ipRecTypeRelocation,Label.IP_Relocation_I4W_Rec_Type);
        mapofRecordtypIdAndRecordTypeName.put(ipRecTypeRelocationO4W,Label.IP_Relocation_O4W_Rec_Type);
        mapofRecordtypIdAndRecordTypeName.put(ipRecTypeRemoval,Label.IP_Removal_Rec_Type);
        mapofRecordtypIdAndRecordTypeName.put(ipRecTypeReplacement,Label.IP_Replacement_Rec_Type);        
        
        mapofRecordtypIdAndRecordTypeName.put(ipNewEPrecType,'Equipment Package');       
        mapofRecordtypIdAndRecordTypeName.put(ipNewTIrectype,'Technician Instruction');
        mapofInstallationRecordtypNameAndRecordTypeId.put(FSConstants.NEWINSTALLATION,ipNewRecType);
        mapofInstallationRecordtypNameAndRecordTypeId.put(Label.IP_Relocation_I4W_Rec_Type,ipRecTypeRelocation);
        mapofInstallationRecordtypNameAndRecordTypeId.put(Label.IP_Relocation_O4W_Rec_Type,ipRecTypeRelocationO4W);
        mapofInstallationRecordtypNameAndRecordTypeId.put(Label.IP_Removal_Rec_Type,ipRecTypeRemoval);
        mapofInstallationRecordtypNameAndRecordTypeId.put(Label.IP_Replacement_Rec_Type,IPrecTypeReplacement);        
        
        mapofEquipmentPackageRecordtypNameAndRecordTypeId.put('Equipment Package',ipNewEPrecType);
        
        mapofTechnicianInstructionRecordtypNameAndRecordTypeId.put('Technician Instruction',ipNewTIrectype);
    } 
    
    /**@desc: to update Installation count field on Account
      *@param - Trigger context variables(Trigger.new,Trigger.newMap,Trigger.oldMap)
      *@return void
      */
    public static void setIsDailyUpdatedField(final List<FS_Installation__c> newList,final Map<Id,FS_Installation__c> newMap,final Map<Id,FS_Installation__c> oldMap){
        for(FS_Installation__c install : newList){                
            if(install.Overall_Status2__c == FSConstants.STATUS_COMPLETE && 
               ((install.FS_Spicy_Cherry__c != oldMap.get(install.id).FS_Spicy_Cherry__c)
                || (install.FS_7000_Series_Statics_Brands_Selection__c != oldMap.get(install.id).FS_7000_Series_Statics_Brands_Selection__c)                       
                || (install.FS_Valid_Fill__c != oldMap.get(install.id).FS_Valid_fill__c)
                || (install.FS_Outlet__r.FS_Chain__r.Name != oldMap.get(install.id).FS_Outlet__r.FS_Chain__r.Name)
                || (install.FS_Outlet__r.FS_Chain__r.Id != oldMap.get(install.id).FS_Outlet__r.FS_Chain__r.Id)
                || (install.FS_Original_Install_Date__c != oldMap.get(install.id).FS_Original_Install_Date__c && oldMap.get(install.id).FS_Original_Install_Date__c != null))){
                    install.IsDailyUpdated__c = true;
                }            
        }
    }
    
    /**@desc: to validate date field values of Installation
    *@param - Trigger context variables(Trigger.new)
    *@return void
    */  
    public static void validationForInstallDateCheck(final List<FS_Installation__c> newList,final Map<Id,FS_Installation__c> oldMap,final Boolean isInsert){
        //process block to validate the fields b/w install date and market activation date
        if(!validationForInstallDateCheckRunOnce){
            for(FS_Installation__c install:newList){
                //FET 5.1 527 added for all RT
                //population of Scheduled date based on INitially scheduled date for New Instal/PIA If Pending Reschdule is False and Scheduled date is Blank
                if(install.RecordTypeId!=ipRecTypeRelocation && install.FS_Scheduled_Install_Date__c==null && !install.FS_Pending_for_Reschedule__c && install.FS_Original_Install_Date__c!=null){
                    install.FS_Scheduled_Install_Date__c=install.FS_Original_Install_Date__c;
                }
                //Population of Initially scheduled date and scheduled date based on Remove/Disconnect date for Post Installs
                if(install.RecordTypeId==ipRecTypeRelocation && ((isInsert && install.FS_Remove_Disconnect_Date__c!=FSConstants.NULLVALUE) || (!isInsert && install.FS_Remove_Disconnect_Date__c!=oldMap.get(install.Id).FS_Remove_Disconnect_Date__c))){
                    install.FS_Original_Install_Date__c=install.FS_Remove_Disconnect_Date__c;
                    install.FS_Scheduled_Install_Date__c=install.FS_Remove_Disconnect_Date__c;
                }
                //Populate Disconnect Date
                if(install.RecordTypeId==ipRecTypeRelocation && install.FS_Relocation_from_old_outlet_to_SP_is__c && ((!isInsert && !oldMap.get(install.Id).FS_Relocation_from_old_outlet_to_SP_is__c)
                                                                || isInsert)){
                    if (install.FS_Scheduled_Install_Date__c!=FSConstants.DATE_NULL){
                        install.FS_Disconnect_Final_Date__c=install.FS_Scheduled_Install_Date__c;
                    }
                }
                
                //Population of scheduled date for relocation records based on Install/Reconnect date when Disconnnect Complete Checkbox checked and Install/Reconnect value populated
                if(install.RecordTypeId==ipRecTypeRelocation && (isInsert && install.FS_Install_Reconnect_Date__c!=FSConstants.NULLVALUE && install.FS_Relocation_from_old_outlet_to_SP_is__c) || 
                   (!isInsert && install.FS_Install_Reconnect_Date__c!=FSConstants.NULLVALUE && install.FS_Relocation_from_old_outlet_to_SP_is__c &&
                    (install.FS_Relocation_from_old_outlet_to_SP_is__c!=oldMap.get(install.Id).FS_Relocation_from_old_outlet_to_SP_is__c || install.FS_Install_Reconnect_Date__c!=oldMap.get(install.Id).FS_Install_Reconnect_Date__c))){
                        //Reconnect date should be after disconnect date
                        if (install.FS_Install_Reconnect_Date__c >= install.FS_Scheduled_Install_Date__c) {
                            install.FS_Scheduled_Install_Date__c=install.FS_Install_Reconnect_Date__c;
                        }
                    }     

                //prevent updating Remove/Disconnect Date
                if(!isInsert && install.RecordTypeId==ipRecTypeRelocation && oldMap.get(install.Id).FS_Remove_Disconnect_Date__c!=null && install.FS_Remove_Disconnect_Date__c!= oldMap.get(install.Id).FS_Remove_Disconnect_Date__c){
                    install.FS_Remove_Disconnect_Date__c.addError(Label.Initial_Scheduled_Date_update_error);
                }
                
                //FET 5.1 527 added for all RT
                if(!install.FS_Install_Date_Validation_Bypass_Check__c){
                    //Verfication of Scheduled date value with Market activation dates for the platforms on installation records 
                    if(install.FS_Scheduled_Install_Date__c!=null && !install.FS_Market_Activation_override__c &&
                       (((install.FS_Platform1__c != null && install.FS_Mrkt_ActiveDate1__c!=null && install.FS_Scheduled_Install_Date__c<install.FS_Mrkt_ActiveDate1__c) || 
                         (install.FS_Platform2__c != null && install.FS_Mrkt_ActiveDate2__c!=null && install.FS_Scheduled_Install_Date__c<install.FS_Mrkt_ActiveDate2__c) ||
                         (install.FS_Platform3__c != null && install.FS_Mrkt_ActiveDate3__c!=null && install.FS_Scheduled_Install_Date__c<install.FS_Mrkt_ActiveDate3__c))
                       ))
                    {                            
                        install.addError(Label.IP_Platform_Date_Error);
                    } 
                    
                }else{
                    install.FS_Install_Date_Validation_Bypass_Check__c=false;
                }               
            }
            validationForInstallDateCheckRunOnce=true;
        }
    }
    
    
    
      /**@desc: To update rush install check box and related 
    fields before Insert/before Update and 
    *@param - FS_Installation__c instal,Boolean check,String picVal
    *@return - double
    */
    public static Double setInstallDateAndCalculateElapseDays(final FS_Installation__c instal,final Boolean check,final String picVal){
        final  date defaultDate= date.newInstance(1900, 1, 8);//set date for calculations
        Integer numberDaysDue;//to calculate difference between given dates. 
        //to calculate difference between install/original 
        //install date with the given date
        Integer numberDaysDue2;
        Double eDays;//to hold value of elapse days
        
        //process block to set original install stamp date field and calculate elapse days
        if(check){   
            instal.FS_Orginal_Install_Stamp_Date__c=System.Today();
            instal.Original_Install_Updated_By__c=  UserInfo.getName();
            numberDaysDue = defaultDate.daysBetween(System.Today());
            numberDaysDue2 = defaultDate.daysBetween(instal.FS_Original_Install_Date__c);
            eDays= (INT_FIVE *( math.floor((defaultDate.daysBetween(instal.FS_Original_Install_Date__c)) / INT_SEVEN)) + math.MIN( INT_FIVE, math.MOD( numberDaysDue2,INT_SEVEN) ))
                -(INT_FIVE * (  math.floor(  defaultDate.daysBetween(System.Today()) / INT_SEVEN))   + math.MIN( INT_FIVE, math.MOD(numberDaysDue,INT_SEVEN ) ) );
        }else{
            final Date originalInstallStampDate=instal.FS_Orginal_Install_Stamp_Date__c;
            numberDaysDue = defaultDate.daysBetween(originalInstallStampDate);
            if(instal.FS_Scheduled_Install_Date__c!=NULL){
                numberDaysDue2 = defaultDate.daysBetween(instal.FS_Scheduled_Install_Date__c);
                eDays= (INT_FIVE * ( math.floor(( defaultDate.daysBetween(instal.FS_Scheduled_Install_Date__c)  ) / INT_SEVEN) ) + math.MIN( INT_FIVE, math.MOD( numberDaysDue2,INT_SEVEN) ) )
                    -(INT_FIVE * ( math.floor( defaultDate.daysBetween(originalInstallStampDate) / INT_SEVEN)) + math.MIN( INT_FIVE, math.MOD(numberDaysDue,INT_SEVEN ) ) );
            }
            else{
                numberDaysDue2 = defaultDate.daysBetween(instal.FS_Original_Install_Date__c);
                eDays= (INT_FIVE * ( math.floor(( defaultDate.daysBetween(instal.FS_Original_Install_Date__c)  ) / INT_SEVEN) ) + math.MIN( INT_FIVE, math.MOD( numberDaysDue2,INT_SEVEN) ) )
                    -(INT_FIVE * ( math.floor( defaultDate.daysBetween(originalInstallStampDate) / INT_SEVEN)) + math.MIN( INT_FIVE, math.MOD(numberDaysDue,INT_SEVEN ) ) );
            }
        }
        //updating elapse days field
        instal.Fs_Elapse_Days__c=eDays;
        //Criteria block to update rush install check box and related fields
        if(eDays<=RUSHLIMITDAYS && instal.FS_Rush_Install_Reason__c!=null){
            //FET 5.0 Paritosh US 8 FS_Rush_Installation__c datatype change
            instal.Is_Install_Currently_a_Rush__c=YES;
            if(picVal==FSConstants.NULLVALUE){
                instal.FS_Was_Original_Install_Date__c=YES;
            }
            instal.FS_Was_Final_instal_a_Rush__c=STR_NO;
        }else if(eDays<=RUSHLIMITDAYS && instal.FS_Rush_Install_Reason__c==null){
            instal.FS_Rush_Install_Reason__c.addError(Label.IP_Rush_Reason_Error_Message);
        }else{
            instal.Is_Install_Currently_a_Rush__c=STR_NO;
            if(picVal==FSConstants.NULLVALUE){
                instal.FS_Was_Original_Install_Date__c=STR_NO;
            }
            instal.FS_Was_Final_instal_a_Rush__c=STR_NO;
        }  
        return eDays;
    }
    /**@desc: to make installation rush while updating record
    *@param - Trigger context variables(Trigger.new,Trigger.oldmap)
    *@return void
    */
    public static void setRushInstallationOnUpdate(final List<FS_Installation__c> newList,final Map<Id,FS_Installation__c> oldmap){
       
        //FET 5.1 updated for all RT
        for(FS_Installation__c instal:newList){   
            if(instal.FS_Scheduled_Install_Date__c != null){
                if(instal.FS_Orginal_Install_Stamp_Date__c==FSConstants.NULLVALUE && instal.Original_Install_Updated_By__c==FSConstants.NULLVALUE){
                    instal.FS_Orginal_Install_Stamp_Date__c=System.Today();
                    instal.Original_Install_Updated_By__c=  UserInfo.getName();                    
                }                
                //Calling above method for checking business days 
                //and update rush install check box
                final Double eDays;
                
                eDays=setInstallDateAndCalculateElapseDays(instal,false,instal.FS_Was_Original_Install_Date__c);        
                
                //criteria block to update final install was rush or not
                if(instal.RecordTypeId==ipNewRecType && 
                   ((instal.FS_Overall_Status__c==FSConstants.STATUS_COMPLETE) || 
                    (instal.FS_Execution_Plan_Final_Approval_PM__c==FSConstants.IPEPAPPROVED && instal.FS_Davaco_SA_Status__c == FSConstants.STATUS_COMPLETE && instal.FS_Installation_Status__c == FSConstants.STATUS_COMPLETE))){
                        if(eDays<=RUSHLIMITDAYS){
                            instal.FS_Was_Final_instal_a_Rush__c=YES;
                        }else{
                            instal.FS_Was_Final_instal_a_Rush__c=STR_NO;
                        }
                    }  
                else if(instal.RecordTypeId!=ipNewRecType &&  instal.RecordTypeId!=ipRecTypeRelocation && instal.FS_Overall_Status__c==FSConstants.STATUS_COMPLETE){
                    if(eDays<=RUSHLIMITDAYS){
                        instal.FS_Was_Final_instal_a_Rush__c=YES;
                    }else{
                        instal.FS_Was_Final_instal_a_Rush__c=STR_NO;
                    }
                }
                
                else if (instal.RecordTypeId==ipRecTypeRelocation && instal.FS_Relocation_from_old_outlet_to_SP_is__c){
                    if(eDays<=RUSHLIMITDAYS){
                        instal.FS_Was_Final_instal_a_Rush__c=YES;
                    }else{
                        instal.FS_Was_Final_instal_a_Rush__c=STR_NO;
                    }
                }
            }           
        }
    }
    /**@desc: to set the fields of Installation like Market Activation date,
              Reconnect, Market text.
    *@param - Trigger context variables(Trigger.new,Trigger.oldMap,
              Trigger.isUpdate) and Set<Id> setOutletIds
    *@return void
    */
    public static void populateSPReconnectDisconnect(final List<FS_Installation__c> newList,final Map<Id, FS_Installation__c> oldMap,final Boolean isUpdate,final Set<Id> setOutletIds) {
        try{
            final Set<String> postalCodeList = new Set<String>();//to hold ShippingPostalCode
            final Map<Id, String> outletMap = new Map<Id, String>();//collection to store outletId and ShippingPostalCode         
            final Map<String,FS_SP_Aligned_Zip__c> spZipMap=new Map<String,FS_SP_Aligned_Zip__c>();        
            String zipCode;//to store ShippingPostalCode
            //process block to add records to collections
            for(Account outlet : [SELECT Id,ShippingPostalCode FROM Account WHERE Id IN: setOutletIds]){
                if(outlet.ShippingPostalCode != null  && outlet.ShippingPostalCode != '') {
                    if(outlet.ShippingPostalCode.length() > INT_FIVE) {
                        zipCode = outlet.ShippingPostalCode.substring(FSConstants.ZERO,INT_FIVE);
                    }else{
                        zipCode = outlet.ShippingPostalCode;
                    }
                    postalCodeList.add(zipCode);
                    outletMap.put(outlet.Id, zipCode);
                }
            }
            //process block to capture Zipcode to collections
            if(!postalCodeList.isEmpty()){
                for(FS_SP_Aligned_Zip__c alignedZip : [SELECT FS_Platform_Type__c,FS_Zip_Code__c,FS_Service_Provider__c,FS_Selling_Market_Activation_Date__c,
                                                       FS_Selling_Activity_Market__r.Name FROM FS_SP_Aligned_Zip__c WHERE FS_Zip_Code__c IN : postalCodeList]){                
                    
                    spZipMap.put(alignedZip.FS_Zip_Code__c+alignedZip.FS_Platform_Type__c,alignedZip);
                    spZipMap.put(alignedZip.FS_Zip_Code__c,alignedZip);
                }    
            }
            
            //Criteria block to set installation fields market and market activation date
            for(FS_Installation__c inst : newList){                         
                if(outletMap.containskey(inst.FS_Outlet__c) && spZipMap.containsKey(outletMap.get(inst.FS_Outlet__c))){               
                    Id spId=FSConstants.ID_NULL;                                
                    inst.FS_Market_Text__c=spZipMap.get(outletMap.get(inst.FS_Outlet__c)).FS_Selling_Activity_Market__r.Name;                    
                    
                    if(string.isNotBlank(inst.FS_Platform1__c) && spZipMap.ContainsKey(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform1__c)){
                        inst.FS_Mrkt_ActiveDate1__c=spZipMap.get(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform1__c).FS_Selling_Market_Activation_Date__c;
                        spId=(spId==FSConstants.NULLVALUE)?spZipMap.get(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform1__c).FS_Service_Provider__c:spId;                                        
                    }
                    else{
                        inst.FS_Mrkt_ActiveDate1__c=FSConstants.DATE_NULL;                        
                    }
                    if(string.isNotBlank(inst.FS_Platform2__c) && spZipMap.ContainsKey(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform2__c)){
                        inst.FS_Mrkt_ActiveDate2__c=spZipMap.get(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform2__c).FS_Selling_Market_Activation_Date__c;                    
                        spId=(spId==FSConstants.NULLVALUE)?spZipMap.get(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform2__c).FS_Service_Provider__c:spId;                      
                    }
                    else{                    
                        inst.FS_Mrkt_ActiveDate2__c=FSConstants.DATE_NULL;                        
                    }
                    if(string.isNotBlank(inst.FS_Platform3__c) && spZipMap.ContainsKey(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform3__c)){
                        inst.FS_Mrkt_ActiveDate3__c=spZipMap.get(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform3__c).FS_Selling_Market_Activation_Date__c;
                        spId=(spId==FSConstants.NULLVALUE)?spZipMap.get(outletMap.get(inst.FS_Outlet__c)+inst.FS_Platform3__c).FS_Service_Provider__c:spId;                                        
                    }
                    else{                     
                        inst.FS_Mrkt_ActiveDate3__c=FSConstants.DATE_NULL;
                    }
                    if(!inst.SP_Override__c){                                       
                        inst.FS_SP__c=spId;                     
                    }
                    if(isUpdate){
                        inst.FS_SP_Disconnect_Reconnect_Override_Flag__c=oldMap.get(inst.Id).FS_SP_Disconnect_Reconnect_Override_Flag__c?false:true;                       
                    }                    
                }
                else{
                    inst.FS_SP__c=FSConstants.ID_NULL;
                    inst.FS_Market_Text__c=FSConstants.BLANKVALUE;
                    inst.FS_Mrkt_ActiveDate1__c=FSConstants.DATE_NULL;
                    inst.FS_Mrkt_ActiveDate2__c=FSConstants.DATE_NULL;
                    inst.FS_Mrkt_ActiveDate3__c=FSConstants.DATE_NULL;
                }            
            }
        }
         catch(Exception ex){
            ApexErrorLogger.addApexErrorLog(PROJECTNAME,CLASSNAME,NA,NA,MEDIUM,ex,NA);
        }
    }
    /**@desc: to update Installation count field on Account
      *@param - Trigger context variables(Trigger.new,Trigger.oldMap) 
                and List<FS_Installation__c> installList
      *@return void
      */    
    public static List<Account> setAccountFields(final Map<Id, List<FS_Installation__c>> mapOutletInstallation,final Map<String, Integer> mapOutletIdCompletedInstalls,final Map<Id,Account> mapOfOutletRecords,final List<Account> lstAccount){
        //process block to set Account field values
        for(Id outId : mapOutletInstallation.keySet()){
            Account out = new Account(id= outId);
            out.FS_of_Self_Serve_Installations2__c = FSConstants.ZERO;
            out.FS_of_Crew_Serve_Installations2__c = FSConstants.ZERO;
            out.FS_of_7000_Series_Installations__c = FSConstants.ZERO;
            if(mapOutletInstallation.get(outId)!=FSConstants.NULLVALUE){
                out.FS_Max_Installation_Date__c = mapOutletInstallation.get(outId).get(FSConstants.ZERO).FS_Scheduled_Install_Date__c;
                for(FS_Installation__c childInstall : mapOutletInstallation.get(outId) ){
                    
                    if(childInstall.FS_Survey_Install_Cancelled__c && mapOfOutletRecords.get(outId)!=FSConstants.NULLVALUE){
                        out.FS_Survey_Install_Cancelled__c=(mapOfOutletRecords.get(outId).FS_Survey_Install_Cancelled__c!=null ? mapOfOutletRecords.get(outId).FS_Survey_Install_Cancelled__c:FSConstants.ZERO)+FSConstants.NUM_1;
                    }
                    
                    if(childInstall.FS_Scheduled_Install_Date__c > out.FS_Max_Installation_Date__c){
                        out.FS_Max_Installation_Date__c = childInstall.FS_Scheduled_Install_Date__c;
                    }
                    if(mapOutletIdCompletedInstalls.containsKey(outId)) {
                        out.FS_Installs_Complete__c = mapOutletIdCompletedInstalls.get(outId);
                    }
                    out.FS_of_Self_Serve_Installations2__c += childInstall.FS_Eq_SS_Dispenser_QTY__c != null? childInstall.FS_Eq_SS_Dispenser_QTY__c : FSConstants.ZERO;
                    out.FS_of_Crew_Serve_Installations2__c += childInstall.FS_Eq_CS_Dispenser_QTY__c != null? childInstall.FS_Eq_CS_Dispenser_QTY__c : FSConstants.ZERO;
                    out.FS_of_7000_Series_Installations__c += childInstall.FS_7000S_Dispenser_QTY__c != null? childInstall.FS_7000S_Dispenser_QTY__c : FSConstants.ZERO;
                    if(mapOfOutletRecords.get(outId)!=FSConstants.NULLVALUE){
                        if( childInstall.FS_Spicy_Cherry__c == 'Dr Pepper/Diet Dr Pepper'|| childInstall.FS_Spicy_Cherry__c=='Dr Pepper/Diet Dr Pepper/Add FUZE/Remove Dasani'||childInstall.FS_Spicy_Cherry__c=='Dr Pepper/Diet Dr Pepper/Add FUZE/Remove Powerade'||childInstall.FS_Spicy_Cherry__c=='Dr Pepper/Diet Dr Pepper/Add FUZE/Remove Vitaminwater'){
                            out.FS_of_Dr_Pepper_Changes__c=(mapOfOutletRecords.get(outId).FS_of_Dr_Pepper_Changes__c!=null ? mapOfOutletRecords.get(outId).FS_of_Dr_Pepper_Changes__c:FSConstants.ZERO)+FSConstants.NUM_1 ;
                        }
                        if( childInstall.FS_Spicy_Cherry__c == 'Pibb/Pibb Zero' ||childInstall.FS_Spicy_Cherry__c==' Pibb/Pibb Zero/Add FUZE/Remove Dasani'||childInstall.FS_Spicy_Cherry__c=='Pibb/Pibb Zero/Add FUZE/Remove Powerade'||childInstall.FS_Spicy_Cherry__c=='Pibb/Pibb Zero/Add FUZE/Remove Vitaminwater'){
                            out.FS_of_Pibb_Changes__c=(mapOfOutletRecords.get(outId).FS_of_Pibb_Changes__c!=null ? mapOfOutletRecords.get(outId).FS_of_Pibb_Changes__c:FSConstants.ZERO)+FSConstants.NUM_1 ;                   
                        }                      
                    }
                }
            } 
            lstAccount.add(out);
        }
        return lstAccount;
    }
    
    public static FS_IP_Technician_Instructions__c populatePortionControl(final Id installationId,final FS_IP_Technician_Instructions__c newTechnicianInstruction,final Map<Id,FS_Installation__c> newInstallMap,final Map<String,FS_CIF__c> cifMap){
        
        if(newInstallMap.containsKey(installationId)){
            final FS_Installation__c inst=newInstallMap.get(installationId);
            //US FNF-69 updated the condition to check platform types 6000,6050,9000,9100
            if(newTechnicianInstruction.FS_Platform_Type__c!= NULL && !platformTypes.contains(newTechnicianInstruction.FS_Platform_Type__c)){
                if(cifMap.containsKey(inst.FS_CIF__c) ){
                    final FS_CIF__c cifRec=cifMap.get(inst.FS_CIF__c);
                    newTechnicianInstruction.FS_Size_1__c=cifRec.FS_Size_1__c;
                    newTechnicianInstruction.FS_Size_2__c=cifRec.FS_Size_2__c;
                    newTechnicianInstruction.FS_Size_3__c=cifRec.FS_Size_3__c;
                    newTechnicianInstruction.FS_Size_4__c=cifRec.FS_Size_4__c;
                    newTechnicianInstruction.FS_Size_5__c=cifRec.FS_Size_5__c;
                    newTechnicianInstruction.FS_Size_6__c=cifRec.FS_Size_6__c;
                    
                    newTechnicianInstruction.FS_Cup_Name_1__c=cifRec.FS_Cup_Name_1__c;
                    newTechnicianInstruction.FS_Cup_Name_2__c=cifRec.FS_Cup_Name_2__c;
                    newTechnicianInstruction.FS_Cup_Name_3__c=cifRec.FS_Cup_Name_3__c;
                    newTechnicianInstruction.FS_Cup_Name_4__c=cifRec.FS_Cup_Name_4__c;
                    newTechnicianInstruction.FS_Cup_Name_5__c=cifRec.FS_Cup_Name_5__c;
                    newTechnicianInstruction.FS_Cup_Name_6__c=cifRec.FS_Cup_Name_6__c;
                    
                    newTechnicianInstruction.FS_Finished_Ounces_1__c=String.valueOf(cifRec.FS_Fluid_Ounces_1__c);
                    newTechnicianInstruction.FS_Finished_Ounces_2__c=String.valueOf(cifRec.FS_Fluid_Ounces_2__c);
                    newTechnicianInstruction.FS_Finished_Ounces_3__c=String.valueOf(cifRec.FS_Fluid_Ounces_3__c);
                    newTechnicianInstruction.FS_Finished_Ounces_4__c=String.valueOf(cifRec.FS_Fluid_Ounces_4__c);
                    newTechnicianInstruction.FS_Finished_Ounces_5__c=String.valueOf(cifRec.FS_Fluid_Ounces_5__c);
                    newTechnicianInstruction.FS_Finished_Ounces_6__c=String.valueOf(cifRec.FS_Fluid_Ounces_6__c);
                }
                newTechnicianInstruction.FS_Top_Off_Button__c=inst.FS_Top_Off_Button__c;
                newTechnicianInstruction.FS_Customer_Ice_Fill_Spec__c=inst.FS_Customer_Ice_Fill_Spec__c;    
            }
            newTechnicianInstruction.FS_Time_to_call_home__c=inst.FS_Time_to_call_home__c;              
        }
        
        return newTechnicianInstruction;
    }
    
     /**@desc: Copy Water Filter Conatct information from Installation's Outlet 
      *@param Map<Id,Account> installationOutletMap , Id installationId,
      *       FS_IP_Technician_Instructions__c newTechnicianInstruction 
              and  Map<Id,FS_Installation__c> newInstallMap
      *@return FS_IP_Technician_Instructions__c
      */
     public static FS_IP_Technician_Instructions__c populateWaterFilterConfigToTechInst(final Id installationId,final FS_IP_Technician_Instructions__c newTechnicianInstruction,final Map<Id,FS_Installation__c> newInstallMap){
       if(newInstallMap.ContainsKey(installationId)){          
          newTechnicianInstruction.FS_Water_Filter_Contact_Email__c = newInstallMap.get(installationId).FS_Water_Filter_Contact_Email__c;
          newTechnicianInstruction.FS_Water_Filter_Contact_Name__c = newInstallMap.get(installationId).FS_Water_Filter_Contact_Name__c;
          newTechnicianInstruction.FS_Water_Filter_Contact_Phone__c = newInstallMap.get(installationId).FS_Water_Filter_Contact_Phone__c;
          newTechnicianInstruction.FS_Water_Filter_MFG__c = newInstallMap.get(installationId).FS_Water_Filter_MFG__c;
          newTechnicianInstruction.FS_Water_Filter_Model_no__c = newInstallMap.get(installationId).FS_Water_Filter_Model_no__c;
          newTechnicianInstruction.Water_Filter_Installer_Email__c = newInstallMap.get(installationId).Water_Filter_Installer_Email__c;
          newTechnicianInstruction.Water_Filter_Installer_Name__c = newInstallMap.get(installationId).Water_Filter_Installer_Name__c;
          newTechnicianInstruction.Water_Filter_Installer_Phone__c = newInstallMap.get(installationId).Water_Filter_Installer_Phone__c;
          newTechnicianInstruction.FS_Who_will_install_Water_Filter__c= newInstallMap.get(installationId).FS_Who_will_install_Water_Filter__c;
       }
       return newTechnicianInstruction;
     }
    
    /**@desc: Can not make rush instal reason to null once it set to some value 
      *@param Map<Id,Account> newMap and  Map<Id,FS_Installation__c> oldMap
      *@return VOID
      */
    public static void validateRushInstallationReason(final Map<Id,FS_Installation__c> newMap,final Map<Id,FS_Installation__c> oldMap){
        for(Id intId:oldMap.keySet()){
            if(oldMap.get(intId).FS_Rush_Install_Reason__c!=null && newMap.get(intId).FS_Rush_Install_Reason__c==null){
                newMap.get(intId).FS_Rush_Install_Reason__c.addError('Can not make reason to null once it was falling under rush');
            
            }
        }   
    }    
    
    public static void validateBrandsetDateCheck(final List<FS_Installation__c> newList,final Map<Id,FS_Installation__c> oldMap,final Map<Id,FS_Installation__c> newMap){
        try{
            installCheckFalseIds=new Set<Id>();    
            installIds=new Set<Id>();
            installMap =new Map<Id,FS_Installation__c>();
            installMapNull =new Map<Id,FS_Installation__c>();
            
            for(FS_Installation__c install:newList){ 
                if(install.RecordTypeId==ipNewRecType && install.Overall_Status2__c==FSConstants.x4InstallSchedule &&
                   install.FS_Scheduled_Install_Date__c!=oldmap.get(install.Id).FS_Scheduled_Install_Date__c){
                       if(oldmap.get(install.Id).FS_Original_Install_Date__c!=FSConstants.NULLVALUE){
                           installMap.put(install.id,install);
                       }
                       else{
                           installMapNull.put(install.id,install);
                       }                   
                       installIds.add(install.id);
                   }
                //FET 5.1 528 updated Original Install/Reconnect to Scheduled Install Date
                else if((install.RecordTypeId==ipRecTypeReplacement || install.RecordTypeId==ipRecTypeRelocation) && install.Overall_Status2__c == FSConstants.SCHEDULED &&
                        install.FS_Scheduled_Install_Date__c!=oldmap.get(install.id).FS_Scheduled_Install_Date__c){
                            if(install.FS_Original_Install_Date__c!=FSConstants.NULLVALUE){
                                installMap.put(install.id,install); 
                            }
                            else{
                                installMapNull.put(install.id,install);
                            }
                            installIds.add(install.id);
                        }            
            }
           final List<FS_Association_Brandset__c> brandsetList=[select id,FS_Brandset__c,FS_Platform__c,FS_Brandset__r.FS_Effective_Start_Date__c,
                                                           FS_Installation__c from FS_Association_Brandset__c 
                                                           where FS_Installation__c!=null and FS_Installation__c IN:installIds];
            if(brandsetDateCheck && !installMap.isEmpty()){
                brandsetDateCheck=false;
                for(FS_Association_Brandset__c brands:brandsetList){                
                    if(installMap.containsKey(brands.FS_Installation__c) && brands.FS_Brandset__c!=FSConstants.NULLVALUE){
                        final Date datePrint=brands.FS_Brandset__r.FS_Effective_Start_Date__c;
                        final String dateFormat=datePrint.format();
                        if((installMap.get(brands.FS_Installation__c).recordtypeId==ipNewRecType || installMap.get(brands.FS_Installation__c).recordtypeId==ipRecTypeReplacement || installMap.get(brands.FS_Installation__c).recordtypeId==ipRecTypeRelocation) && 
                           installMap.get(brands.FS_Installation__c).FS_Scheduled_Install_Date__c<brands.FS_Brandset__r.FS_Effective_Start_Date__c &&                          
                           !installMap.get(brands.FS_Installation__c).FS_Confirm_Install_Date__c){
                               
                            installMap.get(brands.FS_Installation__c).FS_Confirm_Install_Date__c.addError(Label.IP_Brandset_Commercial_Error);
                        }                    
                        else{
                            installCheckFalseIds.add(brands.FS_Installation__c);
                        }
                    }                
                } 
            }
            if(!installMapNull.isEmpty() && brandsetDateCheck1){
                brandsetDateCheck1=false;
                for(FS_Association_Brandset__c brands:brandsetList){ 
                    if(installMapNull.containsKey(brands.FS_Installation__c) && brands.FS_Brandset__c!=FSConstants.NULLVALUE){
                        final Date datePrint=brands.FS_Brandset__r.FS_Effective_Start_Date__c;
                        final String dateFormat=datePrint.format();
                        if((installMapNull.get(brands.FS_Installation__c).recordtypeId==ipNewRecType || installMapNull.get(brands.FS_Installation__c).recordtypeId==ipRecTypeReplacement || installMapNull.get(brands.FS_Installation__c).recordtypeId==ipRecTypeRelocation)  && 
                           installMapNull.get(brands.FS_Installation__c).FS_Scheduled_Install_Date__c<brands.FS_Brandset__r.FS_Effective_Start_Date__c &&                          
                           !installMapNull.get(brands.FS_Installation__c).FS_Confirm_Install_Date__c) {    
                            brandsetDateCheck1=true;                        
                            
                            installMapNull.get(brands.FS_Installation__c).FS_Confirm_Install_Date__c.addError(Label.IP_Brandset_Commercial_Error);
                        }                    
                        else{
                            installCheckFalseIds.add(brands.FS_Installation__c);
                        }
                    }                
                }
            }
            for(Id ids:installCheckFalseIds){
               newMap.get(ids).FS_Confirm_Install_Date__c=false; 
            }
        }
        catch(Exception ex){
            ApexErrorLogger.addApexErrorLog(PROJECTNAME,CLASSNAME,NA,NA,MEDIUM,ex,NA);
        }
    }  
}