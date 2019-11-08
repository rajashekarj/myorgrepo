/*****************************
Name         : FSInstallRescheduleTriggerhandler
Created By   : Infosys
Created Date : 19/03/2018
Usage        : This class holds the business logic of the installation Reschedule object.
*****************************/
public class FSInstallRescheduleTriggerhandler {  
    
    public static final Integer INTFIVE = 5;
    public static final Integer INTSEVEN = 7;
    public static final String CLASSNAME='FSInstallRescheduleTriggerhandler';
    public static Map<Id,FS_Installation__c> installMap;
    public static void isBeforeInsert(final List<FS_Installation_Reschedule__c> newList,final Map<Id,FS_Installation_Reschedule__c> newMap,final Map<Id,FS_Installation_Reschedule__c> oldMap){
        validateInstallRecords(newList,newMap,oldMap);
        system.debug('No of Queries used Reschedule BeforeInsert: ' + Limits.getQueries());
    }
    //  update the installation records 
    public static void isAfterInsert(final List<FS_Installation_Reschedule__c> newList,final Map<Id,FS_Installation_Reschedule__c> newMap,final Map<Id,FS_Installation_Reschedule__c> oldMap){
        copyRescheduleValuesToInstall(newList,newMap,oldMap);
        system.debug('No of Queries used Reschedule AfterInsert: ' + Limits.getQueries());
        FSInstallationBusinessProcess.runRescheduleOnce=false;
    }
    
     /*****************************************************************
Method: validateInstallRecords
Description: validateInstallRecords method to Validate the Rush Install and Ignore Brandset from installation records
New:Venkat as part of FET 5.0 FET 120 To validate Rush Install and Ignore Branset Scenarios 
*******************************************************************/ 
    
    public static void validateInstallRecords(final List<FS_Installation_Reschedule__c> newList,final Map<Id,FS_Installation_Reschedule__c> newMap,final Map<Id,FS_Installation_Reschedule__c> oldMap){
        final Set<Id> installIdSet=new Set<Id>();
        Boolean ignoreBrandCheck;
        for(FS_Installation_Reschedule__c ipResch:newList){ 
            installIdSet.add(ipResch.FS_Installation__c);      
        }
        // Query to retrive  installation object with associated brandset values for given installation 
         installMap=new Map<Id,FS_Installation__c>(
            [select id,name,RecordTypeId,RecordType.Name,FS_Install_Reconnect_Date__c,FS_Original_Install_Date__c,FS_Orginal_Install_Stamp_Date__c,FS_Rush_Install_Reason__c,Overall_Status2__c,
             FS_Original_Onboarding_Date__c,FS_Survey_Install_On_Hold__c,FS_NewRemodelOutletOnlyProjectedFireUp__c,FS_Dry_Install__c,
             FS_Change_Onboarding_Date__c,FS_HowManyDaysAfterInstallOnboarding__c, 
             FS_Relocation_from_old_outlet_to_SP_is__c,FS_relocation_new_outlet_Complete__c,FS_No_SP_Storage_Relocation_complete__c,FS_Disconnect_Final_Date__c,
             	(select id,FS_Brandset__c,FS_Platform__c,FS_Brandset__r.FS_Effective_Start_Date__c,FS_Installation__c from Account_Brandsets__r) 
             from FS_Installation__c where Id IN:installIdSet]);
        
        final  date defaultDate= date.newInstance(1900, 1, 8);//set date for calculations
        Integer numberDaysDue;//to calculate difference between given dates. 
        Integer numberDaysDue2;
        Boolean rushCheck;
        Double eDays;//to hold value of elapse days
        for(FS_Installation_Reschedule__c ipResch:newList){
            ignoreBrandCheck=false; //Checkbox to check Brandset date less than Scheduled date
            final FS_Installation__c install=installMap.get(ipResch.FS_Installation__c);
            rushCheck=false;//Boolean to check for rush install reason
            rushCheck=install.FS_Rush_Install_Reason__c==FSConstants.NULLVALUE?True:false;//assigning TRUE if Install rush reason is null
            rushCheck=(rushCheck && ipResch.FS_Rush_Install_Reason__c==FSConstants.NULLVALUE)?True:false;//assigning TRUE if both IP and Reschdule rush reason is NULL
            
            //Cannot provide Reschedule date or Pending Reschedule once Install/Reconnect complete check box is checked
                if (install.RecordType.Name==Label.IP_Relocation_I4W_Rec_Type && install.FS_relocation_new_outlet_Complete__c && install.FS_Relocation_from_old_outlet_to_SP_is__c){
                    ipResch.addError(Label.IP_I4W_Reschedule_Error);
                }
            
            //Reschedule Date Null Check
            if(ipResch.FS_Reschedule_Install_Date__c!=FSConstants.NULLVALUE){
                
                if(install.RecordType.Name==FSConstants.NEWINSTALLATION){
                    Date dateinst=Date.newInstance(2020, 12, 31);
                    Integer addDaysValue=Integer.valueOf(install.FS_HowManyDaysAfterInstallOnboarding__c);
                    if(install.FS_Survey_Install_On_Hold__c || (install.FS_NewRemodelOutletOnlyProjectedFireUp__c==null && install.FS_Dry_Install__c)){
                        dateinst=Date.newInstance(2020, 12, 31);
                    }
                    else if(install.FS_Change_Onboarding_Date__c!=null){  dateinst=install.FS_Change_Onboarding_Date__c;     }
                    
                    else if(install.FS_NewRemodelOutletOnlyProjectedFireUp__c!=null){
                        dateInst= install.FS_NewRemodelOutletOnlyProjectedFireUp__c;
                        
                        if(addDaysValue!=null){ dateInst=dateInst.addDays(addDaysValue);        }                        
                    }
                    else{
                        dateInst=ipResch.FS_Reschedule_Install_Date__c;                       
                        if(addDaysValue!=null){ dateInst=dateInst.addDays(addDaysValue);        }  
                    }
                    if(dateInst<ipResch.FS_Reschedule_Install_Date__c){                   
                        ipResch.addError('New Onboarding Date Needs to Be Equal or Greater than Installation Date. ['+dateInst.format()+']');
                    }
                }
                
                
                //Rescheduled Date should reflect a date later than the date provided on Original Install/Reconnect Date
                //if(install.FS_Install_Reconnect_Date__c!=FSConstants.NULLVALUE && install.FS_Relocation_from_old_outlet_to_SP_is__c && !install.FS_relocation_new_outlet_Complete__c&& ipResch.FS_Reschedule_Install_Date__c<install.FS_Install_Reconnect_Date__c){
                   // ipResch.FS_Reschedule_Install_Date__c.addError('Rescheduled Date should reflect a date later than the date provided on Original Install/Reconnect Date');
                //}
                
                //POC Reschedule Date should be later than last Remove/Disconnect scheduled date
                if(install.RecordType.Name==Label.IP_Relocation_I4W_Rec_Type && install.FS_Relocation_from_old_outlet_to_SP_is__c && ipResch.FS_Reschedule_Install_Date__c<install.FS_Disconnect_Final_Date__c	){
                    Date discDate = install.FS_Disconnect_Final_Date__c;
                    ipResch.addError('Rescheduled Date should reflect a date later than the last Remove/Disconnect scheduled date of ('+discDate.month()+'/'+discDate.day()+'/'+discDate.year()+')');
                }
                
                //Installation Original Stamp Date Null Check
                if(install.FS_Orginal_Install_Stamp_Date__c!=FSConstants.NULLVALUE){
                    final Date originalInstallStampDate=install.FS_Orginal_Install_Stamp_Date__c;
                    numberDaysDue = defaultDate.daysBetween(originalInstallStampDate);
                    numberDaysDue2 = defaultDate.daysBetween(ipResch.FS_Reschedule_Install_Date__c);
                    //Calculating business Days between Reschdule Date and Install Stamp Date
                    eDays= (INTFIVE * ( math.floor(( defaultDate.daysBetween(ipResch.FS_Reschedule_Install_Date__c)  ) / INTSEVEN) ) + math.MIN( INTFIVE, math.MOD( numberDaysDue2,INTSEVEN) ) )
                        -(INTFIVE * ( math.floor( defaultDate.daysBetween(originalInstallStampDate) / INTSEVEN)) + math.MIN( INTFIVE, math.MOD(numberDaysDue,INTSEVEN ) ) );
                    //if days <=16 and rush install reason Not filled in installation and re-scheduled 
                    if(eDays<=16 && rushCheck){
                        //assigning value to check box to initiate validation Rule
                        ipResch.FS_Rush_Install_Check__c=true;                        
                    } 
                    else{
                        ipResch.FS_Rush_Install_Check__c=false;
                    }
                }
                system.debug('ipResch.FS_Rush_Install_Check__c'+ipResch.FS_Rush_Install_Check__c);
                if((install.Overall_Status2__c==FSConstants.x3PendingSchedu ||  install.Overall_Status2__c==FSConstants.x4InstallSchedule) && (install.RecordType.Name==Label.IP_New_Install_Rec_Type || install.RecordType.Name==Label.IP_Replacement_Rec_Type || install.RecordType.Name==Label.IP_Relocation_I4W_Rec_Type)){
                    for(FS_Association_Brandset__c brands:install.Account_Brandsets__r){ 
                        //Brandset Not Null and Reschedule date less than Brandset Effective date
                        if(brands.FS_Brandset__c!=FSConstants.NULLVALUE && ipResch.FS_Reschedule_Install_Date__c<brands.FS_Brandset__r.FS_Effective_Start_Date__c 
                           && !ipResch.FS_Ignore_brandset_commercial_date__c){                            
                            //assigning value to check box to initiate validation Rule
                            ignoreBrandCheck=true;                           
                        }                
                    }
                    ipResch.FS_Ignore_Brandset_Check__c=ignoreBrandCheck; 
                }
            }
        }
    }  
    
    
    /*****************************************************************
Method: copyRescheduleValuesToInstall
Description: copyRescheduleValuesToInstall method to update installation fields after validation    
New:Venkat as part of FET 5.0 FET 120 copy values from installation Reschedule to Installation
*******************************************************************/ 
    public static void copyRescheduleValuesToInstall(final List<FS_Installation_Reschedule__c> newList,final Map<Id,FS_Installation_Reschedule__c> newMap,final Map<Id,FS_Installation_Reschedule__c> oldMap){
        final Map<Id,FS_Installation__c> installMapUpdate=new Map<Id,FS_Installation__c>();        
        FS_installation__c install;
        
        for(FS_Installation_Reschedule__c ipResch:newList){          
            //Checking the Installation refrence in Map
            if(installMap.containsKey(ipResch.FS_Installation__c)){
                install=installMap.get(ipResch.FS_Installation__c);                
                install.FS_Pending_for_Reschedule__c=ipResch.FS_Pending_for_Reschedule__c;
                install.FS_Scheduled_Install_Date__c=ipResch.FS_Reschedule_Install_Date__c;
                install.FS_Confirm_Install_Date__c=ipResch.FS_Ignore_brandset_commercial_date__c;
                //Assigning Rush Install Reason to Install if Not NULL
                if(ipResch.FS_Rush_Install_Reason__c!=FSConstants.NULLVALUE){
                    install.FS_Rush_Install_Reason__c=ipResch.FS_Rush_Install_Reason__c;
                }
                //Is Transaction Currently a Rush? field value to switch to "No" when
                //Pending Reschedule check box on reschedule is true
                if(ipResch.FS_Pending_for_Reschedule__c==True){
                    install.Is_Install_Currently_a_Rush__c='No';
                    install.Fs_Elapse_Days__c=null;
                }
                
                installMapUpdate.put(install.Id, install); 
            }                                         
        }
        
        //Updating Installation if Map is not empty
        if(!installMapUpdate.isEmpty()){ 
            //Creating error logger instance with required information
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,Object_Name__c=FSConstants.INSTALLATIONOBJECTNAME,
                                                                    Method_Name__c='copyRescheduleValuesToInstall',Error_Severity__c=FSConstants.MediumPriority);                                                                    
            //Updating Installation records
            FSUtil.dmlProcessorUpdate(installMapUpdate.values(),true,apexError);
            
        }
    }    
}