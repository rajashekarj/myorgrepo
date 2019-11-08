public without sharing class  FSInstallRescheduleAuraController {
    //FNF-747 Change Starts
    @AuraEnabled public boolean outletDispensersNotSelectedError {get; set;}
    @AuraEnabled public boolean dispenserSectionEmptyError {get; set;}
    @AuraEnabled public boolean plattformMismatchError {get; set;}
    @AuraEnabled public boolean plattformMismatchError1 {get; set;}
    @AuraEnabled public boolean ipScheduleCheck {get; set;}
    @AuraEnabled public FS_Installation__c installation {get; set;}
    //FNF-747 Change Starts
    @AuraEnabled
    public static Boolean disableAccessCheck(){
        boolean accessCheck=true;       
        String usrProfileName = FSUtil.getProfileName();
        if(string.isNotBlank(usrProfileName) && Label.FS_Install_Reschedule_Create_Access_Profiles.contains(usrProfileName)){
            accessCheck=false;
        }                    
        return accessCheck;          
    }
    /*****************************************************************
    Method: installSechDateCheck
    Description: installSechDateCheck method to check wheather the Installation is Initially scheduled before trying to reschdule 
    Added as part of FET 7.0, //Sprint 2 - FNF-798
    *******************************************************************/
    @AuraEnabled
    public static FSInstallRescheduleAuraController installScheduleDateCheck(String recordId){  // Changed Return Type as part of FNF-747 
       //FNF-747 change Starts
        FSInstallRescheduleAuraController objCnt = new FSInstallRescheduleAuraController();
        List<String> installationPlatformTypes = new List<String>();
        FS_Outlet_Dispenser__c outletDispenser = new FS_Outlet_Dispenser__c();
        List<String> checkDispenser = new List<String>();
        objCnt.outletDispensersNotSelectedError = false;
        objCnt.dispenserSectionEmptyError = false;
        objCnt.plattformMismatchError= false;
        objCnt.ipScheduleCheck = true;
        Set<String> dispenserPlatformTypes = new Set<String>();
        List<FS_Outlet_Dispenser__c> installationDispensers = new List<FS_Outlet_Dispenser__c>();
        
        try{
            //FNF-747 change Starts
            FS_Installation__c install = [select id,recordTypeID,Overall_Status2__c,FS_Outlet__r.nb_Outlet_Dispensers__c,Type_of_Dispenser_Platform__c from FS_Installation__c where id= :recordId];
            objCnt.installation = install;
           
            if((install.recordTypeID != FSInstallationValidateAndSet.ipNewRecType) && FSConstants.TRANSACTION_STATUS.contains(install.Overall_Status2__c) ){
               
                if(install.Type_of_Dispenser_Platform__c != null){
                     installationPlatformTypes.addAll(install.Type_of_Dispenser_Platform__c.split(FSConstants.SEMICOLON));
                }
            
                           
                installationDispensers = [select id,Relocated_Installation__c,Name,FS_Other_PIA_Installation__c,FS_Equip_Type__c from FS_Outlet_Dispenser__c where Relocated_Installation__c = :recordId OR FS_Other_PIA_Installation__c = :recordId];
                //Checking if user has skipped outlet dispenser selection
                if( installationDispensers.size()==0 && install.FS_Outlet__r.nb_Outlet_Dispensers__c > FSConstants.COUNTZERO){
                             objCnt.outletDispensersNotSelectedError= true;   
        
                }
                //Checking for Empty Dispenser Section
                if(install.FS_Outlet__r.nb_Outlet_Dispensers__c == FSConstants.COUNTZERO){
                            objCnt.dispenserSectionEmptyError= true;   
                }
                //Checking for platform mismatch 
                for(FS_Outlet_Dispenser__c disp : installationDispensers){  
                        dispenserPlatformTypes.add(disp.FS_Equip_Type__c);
                        if(!installationPlatformTypes.contains(disp.FS_Equip_Type__c)){
                                objCnt.plattformMismatchError= true;
                                break;
                        }

                    
				}
				 //Checking if the Platform Types that are selected under IP contains the OD selected of that Platform Type.
				if(!dispenserPlatformTypes.isEmpty()){
    			    for(String plat:installationPlatformTypes){    
                                    if(!dispenserPlatformTypes.contains(plat))
                                    {         
                                        objCnt.plattformMismatchError= true;
                                        break;
                                        
                                    }  
                                    
                    }
				}
                
            }
            Date initialScheDate = [select id,FS_Original_Install_Date__c from FS_Installation__C where id=: recordId].FS_Original_Install_Date__c;
            if(initialScheDate != FSConstants.NULLVALUE ){
                objCnt.ipScheduleCheck=false;
        

            }
        }
        catch(Exception ex){
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSInstallRescheduleAuraController','installSechDateCheck',FSConstants.NA,FSConstants.MediumPriority,ex,FSConstants.NA);
        }        
        return objCnt; 
      
    }
}