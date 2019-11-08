//*********************************************
//Name         : FSInstallationCreateEPIPAndMails
//Created By   : Infosys
//Created Date : 12/08/2016  
//Usage        : This class holds the business 
//              logic of the InstallationTrigger
//*************************************************
public class FSInstallationCreateEPIPAndMails{  
        
    public static final String CLASSNAME='FSInstallationCreateEPIPAndMails';
    public static final String METHODNAME='ancillaryEQPOnReplacementUpdate';
    public static final String METHODNAMEUPDATE='updateEQPAssociateBrandAndTI';
    
    public static Boolean spEmailrunonce=false;
    public static Boolean valueOnce1=true;
    public static Boolean spEmailrunonce1=false;
    public static Boolean footprintEmailrunonce=false;
    public static Boolean valueOnce=true;   
    public static Boolean relocationOnce=true; 
    //Changing value from FootPrint to EcoSure
    public static String footPrint='EcoSure'; 
    
    public static String comValue='COM';   
    public static final String SATURDAY='Saturday';
    public static final String SUNDAY='Sunday';    
    public static final String NEWORDER='New Order';
    public static final String SCHEDULECONFIRM='Schedule Confirmed';
       
    
    public static Id installABrecordType=Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName().get(FSConstants.ASSBRANDSET_IP).getRecordTypeId();
    
    
    /**@desc: Send an Email Notification to Installation's Service Provider's Contacts
      *@param List<FS_Installation__c> newInstallList,Map<Id,FS_Installation__c> oldInstallMap,Boolean isInsert and Boolean isUpdate
      *@return void
      */
     public static void sendEmailNotificationToServiceProviderContacts(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> newInstallMap,
                                                                       final Map<Id,FS_Installation__c> oldInstallMap,final Boolean isInsert,final Boolean isUpdate){
         if(!spEmailrunonce){
        //Collection variable to store all Installations to be processed for this functionality
        final Set<Id> installationIdsToBeProcessed=new Set<Id>();       
        //Collection variable to store all Installation's Service Provider Account Ids
        final Set<Id> installationServiceProviderIds=new Set<Id>();        
        //Collection variable to store all Installation's Outlet Ids
        final Set<Id> outletIds=new Set<Id>();        
        //Collection variable to store all Installation's SME User Ids
        final Set<Id> smeIds=new Set<Id>();       
        //Collection variable to store all Installation's Related Vendor Account Ids
        final Set<Id> relatedVendorIds=new Set<Id>();   
        //Collection variable to store all Installation's user lookup fields COM/PM/PC
        Set<Id> regularInstallUsers=new Set<Id>();//OCR2
        //Criteria Block   
        for(FS_Installation__c installationInstance : newInstallList){
            if(isInsert && installationInstance.recordtypeId==FSInstallationValidateAndSet.ipNewRecType && (installationInstance.FS_Overall_Status__c == FSConstants.x4InstallSchedule|| installationInstance.Overall_Status2__c == FSConstants.x4InstallSchedule)){
              
               installationIdsToBeProcessed.add(installationInstance.Id);
               if(installationInstance.FS_SP__c!=FSConstants.NULLVALUE){
                    installationServiceProviderIds.add(installationInstance.FS_SP__c);
               }
               if(installationInstance.FS_Outlet__c!=FSConstants.NULLVALUE) {
                    outletIds.add(installationInstance.FS_Outlet__c);
               }
               if(installationInstance.FS_SME_Name__c!=FSConstants.NULLVALUE){ 
                    smeIds.add(installationInstance.FS_SME_Name__c);
               }
               if(installationInstance.FS_Related_Vendor__c!=FSConstants.NULLVALUE){
                    relatedVendorIds.add(installationInstance.FS_Related_Vendor__c);
               }
            }
            //If condition Modified as part of FET 5.0
            else if(isUpdate && installationInstance.recordtypeId==FSInstallationValidateAndSet.ipNewRecType && ((oldInstallMap.get(installationInstance.id).FS_Overall_Status__c != FSConstants.x4InstallSchedule 
                                    && installationInstance.FS_Overall_Status__c == FSConstants.x4InstallSchedule)
                                 || (oldInstallMap.get(installationInstance.id).Overall_Status2__c != FSConstants.x4InstallSchedule
                                    && installationInstance.Overall_Status2__c == FSConstants.x4InstallSchedule)
                                 || (installationInstance.Overall_Status2__c == FSConstants.x4InstallSchedule && installationInstance.FS_Scheduled_Install_Date__c!=FSConstants.NULLVALUE
                                     && oldInstallMap.get(installationInstance.id).FS_Scheduled_Install_Date__c!=installationInstance.FS_Scheduled_Install_Date__c))){
            
               installationIdsToBeProcessed.add(installationInstance.Id);
               if(installationInstance.FS_SP__c!=FSConstants.NULLVALUE){
                    installationServiceProviderIds.add(installationInstance.FS_SP__c);
               } 
               if(installationInstance.FS_Outlet__c!=FSConstants.NULLVALUE){
                    outletIds.add(installationInstance.FS_Outlet__c);
               }
               if(installationInstance.FS_SME_Name__c!=FSConstants.NULLVALUE){
                    smeIds.add(installationInstance.FS_SME_Name__c);
               }
               if(installationInstance.FS_Related_Vendor__c!=FSConstants.NULLVALUE){ 
                    relatedVendorIds.add(installationInstance.FS_Related_Vendor__c);
               }
            }
            //OCR2
            if(installationInstance.FS_COM_Regular__c!=FSConstants.NULLVALUE){
                regularInstallUsers.add(installationInstance.FS_COM_Regular__c);
            }
            if(installationInstance.FS_PM_Regular__c!=FSConstants.NULLVALUE){
                regularInstallUsers.add(installationInstance.FS_PM_Regular__c);
            }
            if(installationInstance.FS_Installation_PC_AC_1__c!=FSConstants.NULLVALUE){
                regularInstallUsers.add(installationInstance.FS_Installation_PC_AC_1__c);
            }
            //OCR2
        }       
        //Collection variable to store map of Installation Id and Installation's equipment package
        final Map<Id,FS_IP_Equipment_Package__c> mapOfInstallationAndEquipmentPackage=new Map<Id,FS_IP_Equipment_Package__c>();
        //Collection variable to store map of Installation Id and Installation's Technician Instruction records
        final Map<Id,List<FS_IP_Technician_Instructions__c>> mapOfInstallationAndTechnicianInstructions=new Map<Id,List<FS_IP_Technician_Instructions__c>>();
        //Collection variable to store map of Service Provider AccountId and related Contacts
        final Map<Id,List<Contact>> mapOfServiceProviderAndContacts=new Map<Id,List<Contact>>();
        //Collection variable to store map of Outlet Id and other field values
        Map<Id,Account> installationOutletMap=new Map<Id,Account>();
        //Collection variable to store map of User Id and other field values
        Map<Id,User> installationSMEUserMap=new Map<Id,User>();
        //Collection variable to store map of Vendor Id and other field values
        Map<Id,Account> installationRelatedVendorMap=new Map<Id,Account>();
        //Collection variable to store map of User Id and name Values
        Map<Id,User> regularInstallUsersMap=new Map<Id,User>();//OCR
		/******************Retrieve Related records Start**************************************/
        //Retrieve Euipment Package and Technicain Instructions
        if(!installationIdsToBeProcessed.isEmpty()){
             final String EQUIPMENTPACKAGEQUERY =FSUtil.getSelectQuery('FS_IP_Equipment_Package__c') + ' WHERE FS_Installation__c in:installationIdsToBeProcessed';
             final String TECHNICIANINSTRUCTIONQUERY =FSUtil.getSelectQuery('FS_IP_Technician_Instructions__c') + ' WHERE FS_Instalation_Process__c in:installationIdsToBeProcessed';
             
             //Populate Map for Equipment Package
             for(FS_IP_Equipment_Package__c epInstance: (List<FS_IP_Equipment_Package__c>)Database.query(EQUIPMENTPACKAGEQUERY)){
                mapOfInstallationAndEquipmentPackage.put(epInstance.FS_Installation__c,epInstance);   
             }
             
             //Populate Map for Equipment Package
             for(FS_IP_Technician_Instructions__c techInstance: (List<FS_IP_Technician_Instructions__c>)Database.query(TECHNICIANINSTRUCTIONQUERY )){
                
                if(mapOfInstallationAndTechnicianInstructions.containsKey(techInstance.FS_Instalation_Process__c)){
                   mapOfInstallationAndTechnicianInstructions.get(techInstance.FS_Instalation_Process__c).add(techInstance); 
                }
                else{
                   mapOfInstallationAndTechnicianInstructions.put(techInstance.FS_Instalation_Process__c,new List<FS_IP_Technician_Instructions__c>{techInstance});      
                }
             }
        }   
        
        //Retrieve Service Provider Contacts
        if(!installationServiceProviderIds.isEmpty()){
           final List<Account> accInstance = [select Id, (SELECT Id, Email  FROM Contacts WHERE FS_SP_Contact_Active__c=true) from  Account where Id in :installationServiceProviderIds];
           for(Account accountInstance: accInstance){
                mapOfServiceProviderAndContacts.put(accountInstance.id,accountInstance.Contacts);
           }
        }
        
        //Retrieve Outlet details
        if(!outletIds.isEmpty()){
            final String qryOutlet = FSUtil.getSelectQuery('Account') + ' WHERE Id=:outletIds';
            installationOutletMap=new Map<Id,Account>((List<Account>)Database.query(qryOutlet));
        }
        //Retrieve SME User details
        if(!smeIds.isEmpty()){
            installationSMEUserMap=new Map<Id,User>([SELECT ID,Name,Email FROM User WHERE Id=:smeIds]);
        }  
             //OCR
        //Retrieve regular install User details
        if(!regularInstallUsers.isEmpty()){
        	regularInstallUsersMap=new Map<Id,User>([SELECT ID,Name,Email FROM User WHERE Id=:regularInstallUsers]);
        } 
             //OCR
        //Retrieve Vendor Details
        if(!relatedVendorIds.isEmpty()){
            final String qryVendor = FSUtil.getSelectQuery('Account') + ' WHERE Id=:relatedVendorIds';
            installationRelatedVendorMap=new Map<Id,Account>((List<Account>)Database.query(qryVendor));
        }  
        
        /******************Retrieve Related records End**************************************/ 
        final List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();    
        
         //Process the Installation Records
         for(Id installationId :installationIdsToBeProcessed){ 
                
            final Messaging.SingleEmailMessage mail =FSInstallationServicProviderNotification.frameServiceProviderEmail(newInstallMap.get(installationId),
                                                                    mapOfInstallationAndTechnicianInstructions.get(installationId),
                                                                    mapOfServiceProviderAndContacts,installationOutletMap,
                                                                    installationRelatedVendorMap,
                                                                    mapOfInstallationAndEquipmentPackage.get(installationId),
                                                                    installationSMEUserMap,regularInstallUsersMap);//OCR
             if(mail!=FSConstants.NULLVALUE){                 
                 mails.add(mail);
            }
            
            try{
                if(!mails.isEmpty() && Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){                    
                    Messaging.sendEmail(mails);
                }
            } 
            catch(EmailException ex){
               ApexErrorLogger.addApexErrorLog(FSConstants.FET,CLASSNAME,'sendEmailNotificationToServiceProviderContacts','Messaging',FSConstants.MediumPriority,ex,'NA');
            }                                                                                   
         } 
          spEmailrunonce=true;    
        }                  
     } 
     
     //FET4.0
     //SP Notification for replacement records 
     
    public static void sendEmailNotificationToServiceProviderContacts1(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> newInstallMap,
                                                                       final Map<Id,FS_Installation__c> oldInstallMap,final Boolean isInsert,final Boolean isUpdate){
        	
            if(!spEmailrunonce1){            
            spEmailrunonce1=true;
            //Collection variable to store all Installations to be processed for this functionality
            final Set<Id> installationIdsToBeProcessed=new Set<Id>();  
            //Collection variable to store all Installation's Service Provider Account Ids
            final Set<Id> installationServiceProviderIds=new Set<Id>();     
            //Collection variable to store all Installation's Outlet Ids
            final Set<Id> userIds=new Set<Id>();
            final Map<String,String> usersMap=new Map<String,String>();
            final Set<Id> outletIds=new Set<Id>();
            final Set<Id> pIARecordTypeIDSet=new Set<Id>{FSInstallationValidateAndSet.ipRecTypeReplacement,FSInstallationValidateAndSet.ipRecTypeRelocation,FSInstallationValidateAndSet.ipRecTypeRelocationO4W,
                    										FSInstallationValidateAndSet.ipRecTypeRemoval};
                for(FS_Installation__c installationInstance : newInstallList){
                    if(pIARecordTypeIDSet.contains(installationInstance.RecordTypeId)){
                        userIds.add(installationInstance.FS_Entering_COM__c);
                        userIds.add(installationInstance.FS_PM_Execution__c);
                        if(installationInstance.FS_PIC__c!=FSConstants.NULLVALUE){
                           userIds.add(installationInstance.FS_PIC__c);
                        }
                        if(isInsert && installationInstance.Overall_Status2__c == FSConstants.x4InstallSchedule){
                            installationIdsToBeProcessed.add(installationInstance.Id);
                            if(installationInstance.FS_SP__c!=FSConstants.NULLVALUE){
                                installationServiceProviderIds.add(installationInstance.FS_SP__c);
                            }
                            if(installationInstance.FS_Outlet__c!=FSConstants.NULLVALUE){
                                outletIds.add(installationInstance.FS_Outlet__c);
                            }
                        }
                        else if(isUpdate && ((oldInstallMap.get(installationInstance.id).Overall_Status2__c != FSConstants.x4InstallSchedule
                                    && installationInstance.Overall_Status2__c == FSConstants.x4InstallSchedule)
                                 || (installationInstance.Overall_Status2__c == FSConstants.x4InstallSchedule && installationInstance.FS_Scheduled_Install_Date__c!=FSConstants.NULLVALUE
                                     && oldInstallMap.get(installationInstance.id).FS_Scheduled_Install_Date__c!=installationInstance.FS_Scheduled_Install_Date__c))){
                                                 installationIdsToBeProcessed.add(installationInstance.Id);
                                                 if(installationInstance.FS_SP__c!=FSConstants.NULLVALUE){
                                                     installationServiceProviderIds.add(installationInstance.FS_SP__c);
                                                 } 
                                                 if(installationInstance.FS_Outlet__c!=FSConstants.NULLVALUE){
                                                     outletIds.add(installationInstance.FS_Outlet__c);
                                                 }
                                             }
                    }
                }
                final List<User> usersList=[select id,name from user where Id IN:userIds];
                for(User users:usersList){
                    usersMap.put(users.Id,users.Name);
                }
                //Collection variable to store map of Installation Id and Installation's equipment package
                final Map<Id,List<FS_IP_Equipment_Package__c>> mapOfInstallationAndEquipmentPackage=new Map<Id,List<FS_IP_Equipment_Package__c>>();
                //Collection variable to store map of Installation Id and Installation's Technician Instruction records
                //Unused-Map<Id,List<FS_IP_Technician_Instructions__c>> mapOfInstallationAndTechnicianInstructions=new Map<Id,List<FS_IP_Technician_Instructions__c>>();
                //Collection variable to store map of Service Provider AccountId and related Contacts
                final Map<Id,List<Contact>> mapOfServiceProviderAndContacts=new Map<Id,List<Contact>>();
                //Collection variable to store map of Outlet Id and other field values
                Map<Id,Account> installationOutletMap=new Map<Id,Account>();
                /******************Retrieve Related records Start**************************************/
                
                //Retrieve Euipment Package and Technicain Instructions
                if(!installationIdsToBeProcessed.isEmpty()){
                    final String EQUIPMENTPACKAGEQUERY =FSUtil.getSelectQuery('FS_IP_Equipment_Package__c') + ' WHERE FS_Installation__c in:installationIdsToBeProcessed';
                    //Populate Map for Equipment Package
                    for(FS_IP_Equipment_Package__c epInstance: (List<FS_IP_Equipment_Package__c>)Database.query(EQUIPMENTPACKAGEQUERY)){
                        if(mapOfInstallationAndEquipmentPackage.containsKey(epInstance.FS_Installation__c)){
                            mapOfInstallationAndEquipmentPackage.get(epInstance.FS_Installation__c).add(epInstance);   
                        }
                        else{
                            mapOfInstallationAndEquipmentPackage.put(epInstance.FS_Installation__c, new List<FS_IP_Equipment_Package__c>{epInstance});
                        }                      
                    }                
                }
                //Retrieve Service Provider Contacts
                if(!installationServiceProviderIds.isEmpty()){
                    final List<Account> accInstance = [select Id, (SELECT Id, Email  FROM Contacts WHERE FS_SP_Contact_Active__c=true) from  Account where Id in :installationServiceProviderIds]; 
                    for(Account accountInstance: accInstance ){
                        mapOfServiceProviderAndContacts.put(accountInstance.id,accountInstance.Contacts);
                    }
                }
                //Retrieve Outlet details
                if(!outletIds.isEmpty()){
                    final String qryOutlet = FSUtil.getSelectQuery('Account') + ' WHERE Id=:outletIds';
                    installationOutletMap=new Map<Id,Account>((List<Account>)Database.query(qryOutlet));
                }
                final List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                //Process the Installation Records
                for(Id installationId :installationIdsToBeProcessed){
                   final Messaging.SingleEmailMessage mail =FSInstallationServicProviderNotification.frameServiceProviderEmailPIA(newInstallMap.get(installationId),
                                                                mapOfServiceProviderAndContacts,installationOutletMap,                                                            
                                                               mapOfInstallationAndEquipmentPackage.get(installationId),usersMap);
                    
                    if(mail!=FSConstants.NULLVALUE){
                        mails.add(mail);
                    }
                }
                try{                    
                    if(!mails.isEmpty() && Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()){
                        Messaging.sendEmail(mails);
                    }
                }
                catch(EmailException ex){
                   ApexErrorLogger.addApexErrorLog(FSConstants.FET,CLASSNAME,'sendEmailNotificationToServiceProviderContacts','Messaging',FSConstants.MediumPriority,ex,'NA');
                }                                                                                   
        }
    }
    //FET4.0
     
     /**@desc: Update FS_Send_email_to_footprint__c to true and FS_Previous_original_onboarding_date__c that in turn sends a email
       *       notification to list of users in configured in the workflow Email alert 
      *@param Trigger context variables(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate) 
      *       Map<Id,Sobject> sObjectsToUpdate 
      *@return void
      */
     public static void sendEmailtoFootprint(final List<FS_Installation__c> newInstallList,final List<FS_Installation__c> oldInstallList,
                                                  final Map<Id,FS_Installation__c> newInstallMap,final Map<Id,FS_Installation__c> oldInstallMap,
                                                  final Boolean isInsert,final Boolean isUpdate,final Map<Id,Sobject> sObjectsToUpdate){
         
         //Collection variable to store records to be process that meet the criteria
         // final List<FS_Installation__c> installationsToBeProcessed=new List<FS_Installation__c>(); 
		  final Set<Id> installationsToBeProcessed=new Set<Id>(); 
         //Citeria Block
          if(!footprintEmailrunonce){
         //FET 5.1 855 Footprint notification only for New Install
         for(FS_Installation__c  installationInstance : newInstallList){
            if(	installationInstance.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType
                && (oldInstallMap.get(installationInstance.Id).FS_Trainer__c!=newInstallMap.get(installationInstance.Id).FS_Trainer__c || 
                oldInstallMap.get(installationInstance.Id).FS_OB_Status__c!=newInstallMap.get(installationInstance.Id).FS_OB_Status__c ||
                oldInstallMap.get(installationInstance.Id).Overall_Status2__c!=newInstallMap.get(installationInstance.Id).Overall_Status2__c ||
                oldInstallMap.get(installationInstance.Id).FS_Survey_Install_Cancelled__c!=newInstallMap.get(installationInstance.Id).FS_Survey_Install_Cancelled__c ||
                oldInstallMap.get(installationInstance.Id).FS_Original_Onboarding_Date__c!=newInstallMap.get(installationInstance.Id).FS_Original_Onboarding_Date__c)){
                installationsToBeProcessed.add(installationInstance.Id);
             } 
         }
         
         //Process Block
         if(!installationsToBeProcessed.isEmpty()){            
            final Date today = Date.today();
            final Datetime day = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
            final String dayOfWeek=day.format('EEEE');
            final String dayOfWeekSingleChar = dayOfWeek.substring(0,1); //S,M,T,W,T,F,S (Sunday,Monday...)
            
            final Map<Id,Boolean> criteria1Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria2Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria3Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria4Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria5Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria6Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria7Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria8Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria9Map=new Map<Id,Boolean> ();
            final Map<Id,Boolean> criteria10Map=new Map<Id,Boolean> ();
            
            for(FS_installation__c installationInstance: newInstallList) {   
			if(installationsToBeProcessed.contains(installationInstance.Id)){
                //Default values to false for the following maps
                criteria1Map.put(installationInstance.Id,false); 
                criteria2Map.put(installationInstance.Id,false);
                criteria3Map.put(installationInstance.Id,false);
                criteria4Map.put(installationInstance.Id,false);
                criteria5Map.put(installationInstance.Id,false);
                criteria6Map.put(installationInstance.Id,false);
                criteria7Map.put(installationInstance.Id,false);
                criteria8Map.put(installationInstance.Id,false);
                criteria9Map.put(installationInstance.Id,false);
                criteria10Map.put(installationInstance.Id,false);
                
                // Ensure that Onboarding date which was within 5 business days is moved to Anydate                      
                final FS_Installation__c oldOnboradingrecord = oldInstallMap.get(installationInstance.id);
                // Ensure the Onboarding date which was Anydate is moved within 5 business days
                final FS_Installation__c newInstallation=newInstallMap.get(installationInstance.id);
                Date oldOnboradingDate=null;
                Date currentOnboradingDate=null;
                if(oldOnboradingrecord.FS_Original_Onboarding_Date__c!=null &&  newInstallation.FS_Original_Onboarding_Date__c!=null){
                    oldOnboradingDate = oldOnboradingrecord.FS_Original_Onboarding_Date__c;
                    currentOnboradingDate = newInstallation.FS_Original_Onboarding_Date__c;
                    final Integer calDaysoldOnboardingdate = today.daysBetween(oldOnboradingDate);               
                    final Integer calDays= today.daysBetween(currentOnboradingDate); 
                    //Criteria 1 : original onboarding date changes to a date that is within the next 5 business days
                    if ((currentOnboradingDate!= oldOnboradingDate) && 
                        ((calDays <=7 && calDays >-1 && dayOfWeekSingleChar != 'S') || 
                         (calDays >-1 && ((calDays <6 && dayOfWeek == SATURDAY) || 
                                          (calDays < 5 && dayOfWeek == SUNDAY))))) {    
                                              criteria1Map.put(installationInstance.Id,true);
                                          }
                    //Criteria 2 : original onboarding date changes from a date that was within the next 5 business days
                    if ((currentOnboradingDate!= oldOnboradingDate) && 
                        ((dayOfWeekSingleChar != 'S' && calDaysoldOnboardingdate <=7 && calDaysoldOnboardingdate > -1) ||
                         (((dayOfWeek == SATURDAY && calDaysoldOnboardingdate <6 ) || 
                           (dayOfWeek == SUNDAY && calDaysoldOnboardingdate <5)) && calDaysoldOnboardingdate >-1))) {                      
                               criteria2Map.put(installationInstance.Id,true);
                           }
                    //Criteria 5 : The original onboarding date is within next 5 business days
                    if((calDays <=7 && calDays >-1 && dayOfWeekSingleChar != 'S') || 
                       (calDays >-1 && ((calDays <6 && dayOfWeek == SATURDAY) ||
                                        (calDays < 5 && dayOfWeek == SUNDAY)))){                     
                                            criteria5Map.put(installationInstance.Id,true);                    
                                        }
                }
                 //Criteria 3 : Trainer value is  'EcoSure'
                 if(installationInstance.FS_Trainer__c == footPrint){
                     criteria3Map.put(installationInstance.Id,true);                    
                 }
                 
                 //Criteria 4 : OB Status value is  'New Order' or 'Schedule Confirmed'
                 if(installationInstance.FS_OB_Status__c==NEWORDER || 
                    installationInstance.FS_OB_Status__c==SCHEDULECONFIRM){
                     criteria4Map.put(installationInstance.Id,true);                   
                 }
                 
                 
                 //Criteria 6 : Trainer is changed from ‘EcoSure’ to ‘COM’
                 if(oldOnboradingrecord.FS_Trainer__c==footPrint && 
                    installationInstance.FS_Trainer__c == comValue){
                     criteria6Map.put(installationInstance.Id,true);                   
                 }
                 //Criteria 7 : Trainer is changed from COM to ‘EcoSure’
                 if(oldOnboradingrecord.FS_Trainer__c==comValue && 
                    installationInstance.FS_Trainer__c == footPrint){
                     criteria7Map.put(installationInstance.Id,true);                   
                 }
                 //Criteria 8 : OB-Status changes from ‘New Order’, ‘Scheduled Confirmed’ to ‘Cancelled’ 
                 if((oldOnboradingrecord.FS_OB_Status__c==NEWORDER ||
                     oldOnboradingrecord.FS_OB_Status__c == SCHEDULECONFIRM ) 
                     &&  installationInstance.FS_OB_Status__c == 'Cancelled'){
                     criteria8Map.put(installationInstance.Id,true);                    
                 }  
                 //Criteria 9 : Installation Status changes to ‘**Cancelled’ or ‘*On Hold’ 
                 if(oldOnboradingrecord.Overall_Status2__c!=installationInstance.Overall_Status2__c && 
                   (installationInstance.Overall_Status2__c==FSConstants.onHolds || 
                    installationInstance.Overall_Status2__c==FSConstants.IPCANCELLED)){
                     criteria9Map.put(installationInstance.Id,true);                     
                 }
                 //Criteria 10 : Installation Status changes from  ‘**Cancelled’ or ‘*On Hold’ 
                 if((oldOnboradingrecord.Overall_Status2__c==FSConstants.onHolds || 
                     oldOnboradingrecord.Overall_Status2__c==FSConstants.IPCANCELLED) 
                     && oldOnboradingrecord.Overall_Status2__c!=installationInstance.Overall_Status2__c){
                     criteria10Map.put(installationInstance.Id,true);                   
                 }
                /******************************************************/
                //Condition when the email should be sent (((1 or 2) or (5 and (9 or 10))) and 3 and 4) or ((4 and 5) and (6 or 7)) or (5 and 3 and 8)
                
                if((((criteria1Map.get(installationInstance.Id) || criteria2Map.get(installationInstance.Id)) ||
                     (criteria5Map.get(installationInstance.Id) && 
                      (criteria9Map.get(installationInstance.Id) || criteria10Map.get(installationInstance.Id))))  &&
                    criteria3Map.get(installationInstance.Id) && criteria4Map.get(installationInstance.Id))
                    || ((criteria4Map.get(installationInstance.Id) && criteria5Map.get(installationInstance.Id)) &&
                        (criteria6Map.get(installationInstance.Id) || criteria7Map.get(installationInstance.Id))) 
                    || (criteria5Map.get(installationInstance.Id) && criteria3Map.get(installationInstance.Id) &&
                        criteria8Map.get(installationInstance.Id)) ){
                            //footprintEmailrunonce=true;
                            installationInstance.FS_Send_email_to_footprint__c=true; 
                            installationInstance.FS_Previous_original_onboarding_date__c= oldOnboradingDate;
                    
                }
                }
               } 
            }
         }                                        
     }   
    
    public static void updateBrandStatusInstall(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> oldInstallMap){
    	final Set<Id> installIdSet=new Set<Id>();
        for(FS_Installation__c install:newInstallList){
            if(install.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && install.Type_of_Dispenser_Platform__c!=null && install.Type_of_Dispenser_Platform__c!=oldInstallMap.get(install.id).Type_of_Dispenser_Platform__c ){
                installIdSet.add(install.Id);
            }
        }
        if(!installIdSet.isEmpty()){          
            final Map<Id,FS_Installation__c> installBrandsetMap=new Map<Id,FS_Installation__c>(
                [select id,name,(select id,name,FS_Installation__c,FS_Platform__c,FS_NonBranded_Water__c,FS_Brandset__c from Account_Brandsets__r where FS_Installation__c!=null) 
                 from FS_Installation__c where Id IN:installIdSet]);
            for(FS_Installation__c install:newInstallList){
                if(installIdSet.contains(install.Id) && installBrandsetMap.containsKey(install.Id)){
                    final String platforms=install.Type_of_Dispenser_Platform__c;
                    Boolean brandStatus=true;
                    for(FS_Association_Brandset__c abRec:installBrandsetMap.get(install.Id).Account_Brandsets__r){
                        if(platforms.contains(abRec.FS_Platform__c)){
                            if(abRec.FS_NonBranded_Water__c==null || abRec.FS_Brandset__c==null){
                                brandStatus=false; 							                           
                            }                        
                        }
                    }
                    install.FS_BrandStatus__c=brandStatus?'Complete':'NOT Complete';
                }
            }
        }
    }
    
     
    //Sprint 5 - 507
    /*****************************************************************
  	Method: prepareCIFDetails
  	Description: prepareCIFDetails method is to fetch necessary fields from CIF of IP to update the Equipment package
	And Association Brandset records data
	Added as part of FET 5.0, //Sprint 5 - 507
	*******************************************************************/ 
    public static Map<String,FS_CIF__c> prepareCIFDetails(final List<FS_Installation__c> newInstallList){       
        //Set to Store CIF record Ids from installation
        final Set<Id> cifIdSet=new Set<Id>();
        final Map<String,FS_CIF__c> cifMap=new Map<String,FS_CIF__c>();
        
        for(FS_Installation__c installationInstance : newInstallList){
            //Condition to select only those IPs where record type New Install and CIF is Populated 
            if(installationInstance.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && installationInstance.FS_CIF__c!=FSConstants.NULLVALUE){
                cifIdSet.add(installationInstance.FS_CIF__c);
            }           
        }
        if(!cifIdSet.isEmpty()){        
            for(FS_CIF__c cif:[select id,name,FS_Brandset1__c,FS_Brandset2__c,FS_Brandset3__c,FS_Water1__c,FS_Water2__c,FS_Water3__c,FS_Cup_Name_5__c,FS_Cup_Name_6__c,
                               FS_Platform1__c,FS_Platform2__c,FS_Platform3__c,FS_No_of_TopMountIceMaker1__c,FS_Cup_Name_1__c,FS_Cup_Name_2__c,FS_Cup_Name_3__c,FS_Cup_Name_4__c,
                               FS_Size_1__c,FS_Size_2__c,FS_Size_3__c,FS_Size_4__c,FS_Size_5__c,FS_Size_6__c,FS_Fluid_Ounces_1__c,FS_Fluid_Ounces_2__c,
                               FS_Fluid_Ounces_3__c,FS_Fluid_Ounces_4__c,FS_Fluid_Ounces_5__c,FS_Fluid_Ounces_6__c,FS_JDE_Doc__c,
                               FS_No_of_TopMountIceMaker2__c,FS_No_of_TopMountIceMaker3__c from FS_CIF__c where id IN:cifIdSet]){
               
               cifMap.put(cif.Id, cif);
                                   //Creating CIF instance for platform 1 values                    
               if(cif.FS_Platform1__c!=FSConstants.NULLVALUE){                
                  FS_CIF__c cifRec=new FS_CIF__c(FS_Water1__c=cif.FS_Water1__c,FS_Brandset1__c=cif.FS_Brandset1__c,FS_No_of_TopMountIceMaker1__c=cif.FS_No_of_TopMountIceMaker1__c,FS_JDE_Doc__c='Platform 1');                                               
                  cifMap.put(cif.Id+cif.FS_Platform1__c, cifRec);
               }
               //Creating CIF instance for platform 2 values
               if(cif.FS_Platform2__c!=FSConstants.NULLVALUE){               
                   FS_CIF__c cifRec=new FS_CIF__c(FS_Water1__c=cif.FS_Water2__c,FS_Brandset1__c=cif.FS_Brandset2__c,FS_No_of_TopMountIceMaker1__c=cif.FS_No_of_TopMountIceMaker2__c,FS_JDE_Doc__c='Platform 2');                                                  
                  cifMap.put(cif.Id+cif.FS_Platform2__c, cifRec);
               }
               //Creating CIF instance for platform 3 values
               if(cif.FS_Platform3__c!=FSConstants.NULLVALUE){                
                   FS_CIF__c cifRec=new FS_CIF__c(FS_Water1__c=cif.FS_Water3__c,FS_Brandset1__c=cif.FS_Brandset3__c,FS_No_of_TopMountIceMaker1__c=cif.FS_No_of_TopMountIceMaker3__c,FS_JDE_Doc__c='Platform 3');                                                 
                   cifMap.put(cif.Id+cif.FS_Platform3__c, cifRec);
               }             
            }
        }
        return cifMap;
    }
    /*****************************************************************
  	Method: createAssociateBrandset
  	Description: createAssociateBrandset method is to Create Association Brandset records for New Installs
	based  on the platforms selected in Platform Type/s field	
	*******************************************************************/     
    public static void createAssociateBrandset(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> newInstallMap,final Map<Id,FS_Installation__c> oldInstallMap){
        //list to store AB records
        final List<FS_Association_Brandset__c> associateBrandList=new List<FS_Association_Brandset__c>();        
        //Map to get the CIF details
        Map<String,FS_CIF__c> cifMap=new Map<String,FS_CIF__c>();
        cifMap= prepareCIFDetails(newInstallList);//Sprint 5 - 507
        for(FS_Installation__c installationInstance : newInstallList){
            //Checking condition for New install and Platform Types should not be Blank
            if(installationInstance.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && installationInstance.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){                
                final String options=installationInstance.Type_of_Dispenser_Platform__c;
                final List<String> optionsList=options.split(FSConstants.SEMICOLON);
                //Iterating the Platforms List to Create record for every Platform under that IP
                for(String platformValue : optionsList){                  
                  final FS_Association_Brandset__c assocoiatebrand=new FS_Association_Brandset__c();
                  assocoiatebrand.FS_Platform__c=platformValue;
                  assocoiatebrand.FS_Installation__c=installationInstance.Id;
                  //FET 5.0
                  assocoiatebrand.RecordTypeId = installABrecordType;
                    //Populating Water,Brandset and Platform fields based on the CIF values from the platform
                    if(cifMap.containsKey(installationInstance.FS_CIF__c+platformValue)){
                        assocoiatebrand.FS_Platforms__c=cifMap.get(installationInstance.FS_CIF__c+platformValue).FS_JDE_Doc__c;
                        assocoiatebrand.FS_NonBranded_Water__c=cifMap.get(installationInstance.FS_CIF__c+platformValue).FS_Water1__c;
                        assocoiatebrand.FS_Brandset__c=cifMap.get(installationInstance.FS_CIF__c+platformValue).FS_Brandset1__c;
                    }                                  
                  associateBrandList.add(assocoiatebrand); 
                }
            }                                 
        }
        if(!associateBrandList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c='createAssociateBrandset',Object_Name__c='FS_Association_Brandset__c',
                                                                    Error_Severity__c=FSConstants.MediumPriority);
            FSUtil.dmlProcessorInsert(associateBrandList,true,apexError);                                                            
        }        
    }
    
    //deleting the Association Brandset linked to Relocation after Type Of Dispenser Value changes
    public static void deleteRelocationAssociateBrands(final Set<String> installId,final Set<String> installWithPlatform){
       List<FS_Association_Brandset__c> associationList=new List<FS_Association_Brandset__c>();
        final Map<String,FS_Association_Brandset__c> associationMap=new Map<String,FS_Association_Brandset__c>();
        final List<FS_Association_Brandset__c> deleteAsscociationList=new List<FS_Association_Brandset__c>();
        associationList=[select id,name,FS_Platform__c,FS_Installation__c from FS_Association_Brandset__c where FS_Installation__c IN:installId];
        for(FS_Association_Brandset__c brand:associationList){
            associationMap.put(brand.FS_Installation__c+'-'+brand.FS_Platform__c,brand);
        }
        for(String installPlatform:installWithPlatform){
            if(associationMap.containsKey(installPlatform)){
                deleteAsscociationList.add(associationMap.get(installPlatform));
            }
        }
        if(!deleteAsscociationList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                           Method_Name__c='deleteRelocationAssociateBrands',Object_Name__c='FS_Association_Brandset__c',
                                                           Error_Severity__c=FSConstants.MediumPriority);
            FSUtil.dmlProcessorDelete(deleteAsscociationList,true,apexError);  
        }
    }    
    
     
     /**@desc: Insert Installation's Equipment Package Records for 7000 Series,8000 Series,9000 Series,8000 & 9000 Series
*@param Trigger context variables(Trigger.new,Trigger.newMap)
*@return void
*/
    public static void createEquipmentPackageAndTechnicianInstruction(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> newInstallMap){
        
        final Set<Id> exePlanSet=new Set<Id>();
        final Map<String,String> installExecMap=new Map<String,String>();
        
        final List<FS_IP_Equipment_Package__c> equipmentPackageList=new List<FS_IP_Equipment_Package__c>();
        final List<FS_IP_Equipment_Package__c> equipmentPackageReplaceList=new List<FS_IP_Equipment_Package__c>();
        final List<FS_IP_Equipment_Package__c> equipmentPackageRelocationList=new List<FS_IP_Equipment_Package__c>();
        final List<FS_Association_Brandset__c> assocBrandSetList = new List<FS_Association_Brandset__c>();
        Map<String,FS_CIF__c> cifMap=new Map<String,FS_CIF__c>();
        cifMap= prepareCIFDetails(newInstallList);//Sprint 5 - 507
        for(FS_Installation__c installationInstance : newInstallList){    
            //Create equipment Package and link to Installation as per the platformtype of Installation
            //FET 5.0 
            if(installationInstance.RecordTypeId==FSInstallationValidateAndSet.ipNewrecType && installationInstance.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){
            installExecMap.put(installationInstance.Id,installationInstance.FS_Execution_Plan__c);
            exePlanSet.add(installationInstance.FS_Execution_Plan__c);
                final String options=installationInstance.Type_of_Dispenser_Platform__c;
                final List<String> optionsList= options.split(FSConstants.SEMICOLON);
                for(String platformValue : optionsList){
                    final FS_IP_Equipment_Package__c newEquipPackage=new FS_IP_Equipment_Package__c();
                    newEquipPackage.FS_Installation__c=installationInstance.Id;
                    newEquipPackage.RecordtypeId=FSInstallationValidateAndSet.ipNewEPrecType;
                    newEquipPackage.FS_Platform_Type__c=platformValue;
                    //Sprint 5 - 507
                    if(cifMap.containsKey(installationInstance.FS_CIF__c+platformValue)){
                        newEquipPackage.FS_Planned_Topmount_Icemakers__c=cifMap.get(installationInstance.FS_CIF__c+platformValue).FS_No_of_TopMountIceMaker1__c;
                    }
                    equipmentPackageList.add(newEquipPackage);
                }
            }   
            //FET 5.0
            //for replacement installations equipment ancillary records and the associated brandset records will get created
            if(installationInstance.RecordTypeId!=FSInstallationValidateAndSet.ipNewrecType && installationInstance.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE ){
             
                final String options=installationInstance.Type_of_Dispenser_Platform__c;
                final List<String> optionsList=options.split(FSConstants.SEMICOLON);
                for(String platformValue : optionsList){
                    if(FSInstallationValidateAndSet.ipRecTypeReplacement==installationInstance.RecordTypeId || FSInstallationValidateAndSet.ipRecTypeRelocation==installationInstance.RecordTypeId){
                        final FS_IP_Equipment_Package__c newEquipPackage=new FS_IP_Equipment_Package__c();
                        newEquipPackage.FS_Installation__c=installationInstance.Id;
                        newEquipPackage.FS_Platform_Type__c=platformValue;
                        newEquipPackage.RecordtypeId=FSInstallationValidateAndSet.ipNewEPrecType;
                        equipmentPackageReplaceList.add(newEquipPackage);
                    }                 
                    final FS_Association_Brandset__c assBrandSet = new FS_Association_Brandset__c();
                    assBrandSet.FS_Installation__c = installationInstance.Id;
                    assBrandSet.FS_Platform__c = platformValue;
                    //FET 5.0
                    assBrandSet.RecordTypeId = installABrecordType;
                    assocBrandSetList.add(assBrandSet);
                }
            }    
        }
        //Create/Insert Equipment Package Records
        if(!equipmentPackageList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c='createEquipmentPackageAndTechnicianInstruction',Object_Name__c='FS_IP_Equipment_Package__c',
                                                                    Error_Severity__c=FSConstants.MediumPriority);          
            //create/Insert Technician Instructions
            final Boolean success= mapExecutionPlanEquipmentPack(equipmentPackageList,exePlanSet,installExecMap);
            if(success){
                
                createTechnicianInstruction(equipmentPackageList,newInstallList,newInstallMap,cifMap,exePlanSet, installExecMap);
            }
        }
        if(!assocBrandSetList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c='createEquipmentPackageAndTechnicianInstruction',Object_Name__c='FS_Association_Brandset__c',
                                                                    Error_Severity__c=FSConstants.MediumPriority);
            
            FSUtil.dmlProcessorInsert(assocBrandSetList,true,apexError);                                                                                        
        }        
        if(!equipmentPackageReplaceList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c='createEquipmentPackageAndTechnicianInstruction',Object_Name__c='FS_IP_Equipment_Package__c',
                                                                    Error_Severity__c=FSConstants.MediumPriority);
            
            final Boolean success=FSUtil.dmlProcessorInsert(equipmentPackageReplaceList,true,apexError); 
            //Added in FET5.1 
            if(success){               
                createTechInstforPIA(equipmentPackageReplaceList,newInstallList,newInstallMap);
            }
        }       
    }  
    
    public static Boolean mapExecutionPlanEquipmentPack(final List<FS_IP_Equipment_Package__c> newEquipmentList,final Set<Id> exePlanSet,final Map<String,String> installExecMap){
     //FET5.0   Link EP equipmentpackage lookup on IP equipment package
        Boolean success = false;
        final Map<String,Id> equipExecMap=new Map<String,Id>();
        //FET 5.0
        for(FS_EP_Equipment_Package__c equipment:[select id,RecordTypeId,FS_Platform_Type__c,FS_Execution_Plan__c from FS_EP_Equipment_Package__c where FS_Execution_Plan__c IN:exePlanSet]){
            equipExecMap.put(equipment.FS_Execution_Plan__c+equipment.FS_Platform_Type__c,equipment.Id);
        }      
        for(FS_IP_Equipment_Package__c equipment:newEquipmentList){                       
            if(installExecMap.containsKey(equipment.FS_Installation__c) && (equipExecMap.containsKey(installExecMap.get(equipment.FS_Installation__c)+equipment.FS_Platform_Type__c))){
                equipment.FS_EP_Equipment_Package__c=equipExecMap.get(installExecMap.get(equipment.FS_Installation__c)+equipment.FS_Platform_Type__c);
                
            }                                 
        }
        if(!newEquipmentList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c='mapExecutionPlanEquipmentPack',Object_Name__c='FS_IP_Equipment_Package__c',
                                                                    Error_Severity__c=FSConstants.MediumPriority);
           
            success = FSUtil.dmlProcessorinsert(newEquipmentList,true,apexError);
        }  
        return success;
    }
    
    public static boolean mapExecutionPlanTechnician(final List<FS_IP_Technician_Instructions__c> technicianInstructionList,final set<ID> exePlanSet,final Map<String,String> installExecMap){
        //Link EP technician instruction lookup  on Ip technincian Intruction 
        boolean success = false;        
        final Map<String,Id> technicianExecMap=new Map<String,Id>();
        
       //FET 5.0 
        for(FS_EP_Technician_Instructions__c technician:[select id,RecordTypeId,FS_Platform_Type__c,Execution_Plan__c from FS_EP_Technician_Instructions__c where Execution_Plan__c IN:exePlanSet]){
            technicianExecMap.put(technician.Execution_Plan__c+technician.FS_Platform_Type__c,technician.Id);
        }        
        for(FS_IP_Technician_Instructions__c technician:technicianInstructionList){                       
            if(installExecMap.containsKey(technician.FS_Instalation_Process__c) && (technicianExecMap.containsKey(installExecMap.get(technician.FS_Instalation_Process__c)+technician.FS_Platform_Type__c))){                    
                technician.FS_EP_Technician_Instructions__c=technicianExecMap.get(installExecMap.get(technician.FS_Instalation_Process__c)+technician.FS_Platform_Type__c);
                
            }                               
        }
        if(!technicianInstructionList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c='mapExecutionPlanTechnician',Object_Name__c='FS_IP_Technician_Instructions__c',
                                                                    Error_Severity__c=FSConstants.MediumPriority);
            success = FSUtil.dmlProcessorinsert(technicianInstructionList,true,apexError);                                                                                        
        }        
        return success;
    }    
    
    /**@desc: Insert Installation's Technician Instruction  Records for 7000 Series,8000 Series,9000 Series
*@param List<FS_IP_Equipment_Package__c> equipmentPackageList, List<FS_Installation__c> newInstallList and Map<Id,FS_Installation__c> newInstallMap
*@return void
*/
    public static void createTechnicianInstruction(final List<FS_IP_Equipment_Package__c> equipmentPackageList,final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> newInstallMap,final Map<String,FS_CIF__c> cifMap,final set<ID> exePlanSet,final Map<String,String> installExecMap){
        //FET 5.0 Create technician instruction records on creation on installation record with same platform type selected in Installation
        
        //Colection to store new sObject instance to create Technician Instruction records
        final List<FS_IP_Technician_Instructions__c> technicianInstructionList=new List<FS_IP_Technician_Instructions__c>();    
             
        
        for(FS_IP_Equipment_Package__c equipPackageInstance: equipmentPackageList){
            
            FS_IP_Technician_Instructions__c newTechnicianInstruction=new FS_IP_Technician_Instructions__c();
            newTechnicianInstruction.FS_Instalation_Process__c=equipPackageInstance.FS_Installation__c;
//FET 5.0
            newTechnicianInstruction.RecordtypeId= FSInstallationValidateAndSet.ipNewTIrectype;
            newTechnicianInstruction.FS_Platform_Type__c=equipPackageInstance.FS_Platform_Type__c;
            newTechnicianInstruction.FS_IP_Equipment_Package__c=equipPackageInstance.Id;
            
            newTechnicianInstruction=FSInstallationValidateAndSet.populateWaterFilterConfigToTechInst(equipPackageInstance.FS_Installation__c,newTechnicianInstruction,newInstallMap);
            newTechnicianInstruction=FSInstallationValidateAndSet.populatePortionControl(equipPackageInstance.FS_Installation__c,newTechnicianInstruction,newInstallMap,cifMap);            
            technicianInstructionList.add(newTechnicianInstruction);       
        } 
                                                      
        //Create/Insert Technicain Instructions Records
        if(!technicianInstructionList.isEmpty()){                                                                                                                                
            final Boolean success = mapExecutionPlanTechnician(technicianInstructionList,exePlanSet,installExecMap);            
            if(success){                
                //Collection to store field api based on euipmentPackage/Installation recordType       
                final Map<String,Id> techInstructionRecordId=new Map<String,Id>();
                
                for(FS_IP_Technician_Instructions__c  techInstance: technicianInstructionList){
                    techInstructionRecordId.put(techInstance.FS_Platform_Type__c+techInstance.FS_IP_Equipment_Package__c,techInstance.Id);
                }
                //Link Equipment Package to respective Technician Instructions
                for(FS_IP_Equipment_Package__c equipPackageInstance: equipmentPackageList){
                    if(techInstructionRecordId.containsKey(equipPackageInstance.FS_Platform_Type__c+equipPackageInstance.Id)){
                      equipPackageInstance.FS_Related_Technician_Instructions__c=techInstructionRecordId.get(equipPackageInstance.FS_Platform_Type__c+equipPackageInstance.Id);                    
                    }
                }                  
                //Update equipment Package
                final Apex_Error_Log__c apexErrorEQP=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                           Method_Name__c='createTechnicianInstruction',Object_Name__c='FS_IP_Equipment_Package__c',
                                                           Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorUpdate(equipmentPackageList,true,apexErrorEQP);                                                                                                                    
            }
        }          
    } 
    
    //FET5.1, Insert Technician Instruction records for Replacement and Relocation (I4W) 
	 public static void createTechInstforPIA(final List<FS_IP_Equipment_Package__c> equipmentPackageList,final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> newInstallMap){
        //Create technician instruction records on creation on installation record with same platform type selected in Installation               
        //Colection to store new sObject instance to create Technician Instruction records        
        final List<FS_IP_Technician_Instructions__c> technicianInstructionList=new List<FS_IP_Technician_Instructions__c>();       
           final Map<String,FS_CIF__c> cifMap=new Map<String,FS_CIF__c>();       
        for(FS_IP_Equipment_Package__c equipPackageInstance: equipmentPackageList){
            
            FS_IP_Technician_Instructions__c newTechnicianInstruction=new FS_IP_Technician_Instructions__c();
            newTechnicianInstruction.FS_Instalation_Process__c=equipPackageInstance.FS_Installation__c;

            newTechnicianInstruction.RecordtypeId= FSInstallationValidateAndSet.ipNewTIrectype;
            newTechnicianInstruction.FS_Platform_Type__c=equipPackageInstance.FS_Platform_Type__c;
            newTechnicianInstruction.FS_IP_Equipment_Package__c=equipPackageInstance.Id;
            
            newTechnicianInstruction=FSInstallationValidateAndSet.populateWaterFilterConfigToTechInst(equipPackageInstance.FS_Installation__c,newTechnicianInstruction,newInstallMap);
            newTechnicianInstruction=FSInstallationValidateAndSet.populatePortionControl(equipPackageInstance.FS_Installation__c,newTechnicianInstruction,newInstallMap,cifMap);            
            technicianInstructionList.add(newTechnicianInstruction);       
        }                                                       
        //Create/Insert Technicain Instructions Records
        if(!technicianInstructionList.isEmpty()){
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                           Method_Name__c='createTechnicianInstruction',Object_Name__c='FS_IP_Technician_Instructions__c',
                                                           Error_Severity__c=FSConstants.MediumPriority);
            final Boolean success=FSUtil.dmlProcessorInsert(technicianInstructionList,true,apexError); 
             if(success){
                 //Collection to store field api based on euipmentPackage/Installation recordType       
                final Map<String,Id> techInstructionRecordId=new Map<String,Id>();
                
                for(FS_IP_Technician_Instructions__c  techInstance: technicianInstructionList){
                    techInstructionRecordId.put(techInstance.FS_Platform_Type__c+techInstance.FS_IP_Equipment_Package__c,techInstance.Id);
                }
                //Link Equipment Package to respective Technician Instructions
                for(FS_IP_Equipment_Package__c equipPackageInstance: equipmentPackageList){
                    if(techInstructionRecordId.containsKey(equipPackageInstance.FS_Platform_Type__c+equipPackageInstance.Id)){
                      equipPackageInstance.FS_Related_Technician_Instructions__c=techInstructionRecordId.get(equipPackageInstance.FS_Platform_Type__c+equipPackageInstance.Id);                    
                    }
                }                  
                //Update equipment Package
                final Apex_Error_Log__c apexErrorEQP=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                           Method_Name__c='createTechnicianInstruction',Object_Name__c='FS_IP_Equipment_Package__c',
                                                           Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorUpdate(equipmentPackageList,true,apexErrorEQP);                                                                                                                    
            }
        }          
    } 
    
   //FET 5.0  
    public static void updateEQPAssociateBrandAndTI(List<FS_Installation__c> newList,Map<Id,FS_Installation__c> oldInstallMap,Map<Id,FS_Installation__c> newInstallMap){
       //Update Association brandset and Equipment package and TI records on change of platform type in related installation record
        final Set<Id> exePlanSet=new Set<Id>();
        final Map<String,String> installExecMap=new Map<String,String>();
        
        Set<Id> installationIdSet=new Set<Id>();
        List<FS_Installation__c> installplanList=new List<FS_Installation__c>();
        List<FS_IP_Technician_Instructions__c> delTIList=new List<FS_IP_Technician_Instructions__c>();
        Map<String,FS_CIF__C> cifMap=new Map<String,FS_CIF__c>();
        List<FS_IP_Equipment_Package__c> equipmentPackageList=new List<FS_IP_Equipment_Package__c>();
        List<FS_IP_Equipment_Package__c> delEQPList=new List<FS_IP_Equipment_Package__c>();
        Map<String,FS_IP_Equipment_Package__c> mapEQP=new Map<String,FS_IP_Equipment_Package__c>();
        Set<String> delList=new Set<String>();       
        
        Map<String,FS_IP_Technician_Instructions__c> mapTI=new Map<String,FS_IP_Technician_Instructions__c>();
        
        final List<FS_Association_Brandset__c> assetBrandSet = new List<FS_Association_Brandset__c>();  
        final List<FS_Association_Brandset__c> deleAssetBrandSets = new List<FS_Association_Brandset__c>();
        final Map<String,FS_Association_Brandset__c> mapAssociate=new Map<String,FS_Association_Brandset__c>();
        
        if(valueOnce1) {     
            for(FS_Installation__c ip:newList){
                //check if there is change in platform type values
                if(ip.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && ip.Type_of_Dispenser_Platform__c!=oldInstallMap.get(ip.Id).Type_of_Dispenser_Platform__c){
                    installplanList.add(ip);
                    installationIdSet.add(ip.Id);
                }
            }
            if(!installplanList.isEmpty() ){
                cifMap= prepareCIFDetails(installplanList);
            }
            
            for(FS_Installation__c ip:installplanList) {
                installExecMap.put(ip.Id,ip.FS_Execution_Plan__c);
            exePlanSet.add(ip.FS_Execution_Plan__c);
				
				Set<String> mainList=new Set<String>();
                Set<String> delListTemp=new Set<String>();
                Map<Set<String>,Set<String>> platformMap=new Map<Set<String>,Set<String>>();
                // separate the platform types , into mainlist and deletion list
                platformMap=FSUtil.checkPlatformValues(ip.Id,ip.Type_of_Dispenser_Platform__c,oldInstallMap.get(ip.Id).Type_of_Dispenser_Platform__c);
                for(Set<String> main:platformMap.keySet()){
                    mainList=main;   
                    delListTemp=platformMap.get(mainList);
                }             
                for(String deleteValue:delListTemp){
                    delList.add(deleteValue);                    
                }    
                for(String platform:mainList){
                    String platformValue='0';
                    FS_IP_Equipment_Package__c ipEquip=new FS_IP_Equipment_Package__c();                
                    ipEquip.FS_Installation__c=ip.Id;
                    ipEquip.FS_Platform_Type__c=platform;
                    ipEquip.recordtypeId=FSInstallationValidateAndSet.ipNewEPrecType;                    
                    equipmentPackageList.add(ipEquip);
                    platformValue=(ip.FS_Platform1__c!=null && ip.FS_Platform1__c==platform)?'1':platformValue;
                    platformValue=(platformValue=='0' && ip.FS_Platform2__c!=null && ip.FS_Platform2__c==platform)?'2':platformValue;
                    platformValue=(platformValue=='0' && ip.FS_Platform3__c!=null && ip.FS_Platform3__c==platform)?'3':platformValue;
                    final FS_Association_Brandset__c assBS = new FS_Association_Brandset__c();
                    assBS.RecordTypeId = installABrecordType;
                    assBS.FS_Installation__c=ip.Id; 
                    assBS.FS_Platform__c = platform;
                    assBS.FS_Platforms__c=(platformValue=='0')?'Platform 4':'Platform '+platformValue;
                    assetBrandSet.add(assBS);
                }
                valueonce1=False;
            }
            if(!delList.isEmpty()){
                List<FS_IP_Equipment_Package__c> eqpList=[select Id,Name,FS_Platform_Type__c,FS_Installation__c from FS_IP_Equipment_Package__c where FS_Installation__c IN:installationIdSet];            
                List<FS_IP_Technician_Instructions__c> tiList=[select Id,Name,FS_Platform_Type__c ,FS_Instalation_Process__c from FS_IP_Technician_Instructions__c where FS_Instalation_Process__c IN:installationIdSet];
                final List<FS_Association_Brandset__c> assetBrandList = [Select id,FS_Installation__c,FS_Platform__c from FS_Association_Brandset__c where FS_Installation__c IN:installationIdSet];
                for(FS_IP_Equipment_Package__c eqp:eqpList){
                    String platform=eqp.FS_Installation__c+eqp.FS_Platform_Type__c;
                    mapEQP.put(platform, eqp);                
                }
                for(FS_IP_Technician_Instructions__c techInst:tiList){
                    String platform=techInst.FS_Instalation_Process__c+techInst.FS_Platform_Type__c;
                    mapTI.put(platform, techInst);                
                }
                for(FS_Association_Brandset__c associate:assetBrandList){
                    final String platform=associate.FS_Installation__c+associate.FS_Platform__c;
                    mapAssociate.put(platform,associate);                             
                }
                for(String delValue:delList){
                    if(mapEQP.containsKey(delValue)){
                        delEQPList.add(mapEQP.get(delValue));
                    }
                    if(mapTI.containsKey(delValue)){
                        delTIList.add(mapTI.get(delValue));
                    }
                    if(mapAssociate.containsKey(delValue)){
                        deleAssetBrandSets.add(mapAssociate.get(delValue));
                    } 
                }               
            }
            // deletion of equipment package list if  the platform is removed from installation
            if(!delEQPList.isEmpty()){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSInstallationCreateEPIPAndMails',
                                                                        Method_Name__c=METHODNAMEUPDATE,Object_Name__c='FS_IP_Equipment_Package__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorDelete(delEQPList,true,apexError);
            }
            //deletion of TI if platform is removed from installation 
            if(!delTIList.isEmpty()){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FSInstallationCreateEPIPAndMails',
                                                                        Method_Name__c=METHODNAMEUPDATE,Object_Name__c='FS_IP_Technician_Instructions__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorDelete(delTIList,true,apexError);
            }
            if(!deleAssetBrandSets.isEmpty() && deleAssetBrandSets!=null){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODNAMEUPDATE,Object_Name__c='FS_Association_Brandset__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorDelete(deleAssetBrandSets,true,apexError);                                                        
            }
            if(!assetBrandSet.isEmpty()){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODNAMEUPDATE,Object_Name__c='FS_Association_Brandset__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorInsert(assetBrandSet,true,apexError);                                                                                                                    
            }  
            if(!equipmentPackageList.isEmpty()){
                //create/Insert Technician Instructions
				Boolean success = mapExecutionPlanEquipmentPack(equipmentPackageList,exePlanSet, installExecMap);
                if(success){
                    createTechnicianInstruction(equipmentPackageList,newlist,newInstallMap,cifMap,exePlanSet, installExecMap);
                }
            }
        }       
    }
    
    //FET4.0 
    //updating the ancillary equipment record creation and associate brandset records
    //Modified for adding TI in Replacement, FET5.1
    public static void ancillaryEQPOnReplacementUpdate(final List<FS_Installation__c> installList,final Map<Id,FS_Installation__c> oldInstallMap,Map<Id,FS_Installation__c> newInstallMap){            
        
        final Set<Id> installIdSet=new Set<Id>();        
        final Set<String> delSet=new Set<String>(); 
        List<FS_IP_Technician_Instructions__c> delTIList=new List<FS_IP_Technician_Instructions__c>();
        
        final List<FS_IP_Equipment_Package__c> ipEPList=new List<FS_IP_Equipment_Package__c>();             
        final List<FS_IP_Equipment_Package__c> delListEQP=new List<FS_IP_Equipment_Package__c>();
        final Map<String,FS_IP_Equipment_Package__c> mapEquip=new Map<String,FS_IP_Equipment_Package__c>();
        
        Map<String,FS_IP_Technician_Instructions__c> mapTI=new Map<String,FS_IP_Technician_Instructions__c>();
        
        final List<FS_Association_Brandset__c> assetBrandSet = new List<FS_Association_Brandset__c>();  
        final List<FS_Association_Brandset__c> deleAssetBrandSets = new List<FS_Association_Brandset__c>();
        final Map<String,FS_Association_Brandset__c> mapAssociate=new Map<String,FS_Association_Brandset__c>(); 
        
        final Set<FS_Installation__c> replaceInstallsList=new Set<FS_Installation__c>();
        //FET-1249 Changes Start
        List<FS_Outlet_Dispenser__c> odRecList=new List<FS_Outlet_Dispenser__c>();
        //FET-1249 Changes End
        if(valueOnce){                     
            for(FS_Installation__c install:installList){
                if(install.RecordTypeId!= FSInstallationValidateAndSet.ipNewRecType && install.Type_of_Dispenser_Platform__c!=oldInstallMap.get(install.Id).Type_of_Dispenser_Platform__c){
                    replaceInstallsList.add(install);
                    installIdSet.add(install.id);
                }                   
            }
            Map<Id,FS_Installation__c> installMap=new Map<Id,FS_Installation__c>
            ([select id,name,(select id,FS_Equip_Type__c,Hide_Water_Dispenser__c,Relocated_Installation__c,FS_Water_Button__c,FS_Brandset__c from Outlet_Dispensers1__r where Relocated_Installation__c!=null),
              (select id,FS_Equip_Type__c,Hide_Water_Dispenser__c,FS_Other_PIA_Installation__c,FS_Water_Button__c,FS_Brandset__c from Outlet_Dispensers2__r where FS_Other_PIA_Installation__c!=null) from FS_Installation__c where id IN:installIdSet]);
           
            for(FS_Installation__c installRec:replaceInstallsList){ 
                Set<String> mainList=new Set<String>();
                Set<String> delListTemp=new Set<String>();
                Map<Set<String>,Set<String>> platformMap=new Map<Set<String>,Set<String>>();
                platformMap=FSUtil.checkPlatformValues(installRec.Id,installRec.Type_of_Dispenser_Platform__c,oldInstallMap.get(installRec.Id).Type_of_Dispenser_Platform__c);
                for(Set<String> main:platformMap.keySet()){
                    mainList=main;   
                    delListTemp=platformMap.get(mainList);
                }
                for(String deleteValue:delListTemp){
                    delSet.add(deleteValue);                           
                } 
                if(!mainList.isEmpty()){                  
                    for(String platformValue:mainList){
                        if(installRec.RecordTypeId== FSInstallationValidateAndSet.ipRecTypeRelocation || installRec.RecordTypeId== FSInstallationValidateAndSet.ipRecTypeReplacement){
                            final FS_IP_Equipment_Package__c ipEP=new FS_IP_Equipment_Package__c();
                            ipEP.FS_Installation__c=installRec.Id;                   
                            ipEP.recordtypeId=FSInstallationValidateAndSet.ipNewEPrecType;
                            ipEP.FS_Platform_Type__c=platformValue;
                            ipEPList.add(ipEP); 
                        }
                        
                        final FS_Association_Brandset__c assBS = new FS_Association_Brandset__c();
                        assBS.FS_Installation__c=installRec.Id; 
                        assBS.FS_Platform__c = platformValue;                        
                        assBS.RecordTypeId = installABrecordType;
                        
                        //FET-1249 Changes Start to Store list of OD for the PIA based on Record type From 2 lookup fields
                        odRecList=installMap.containsKey(installRec.Id)?(installRec.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation?installMap.get(installRec.Id).Outlet_Dispensers1__r:installMap.get(installRec.Id).Outlet_Dispensers2__r):new List<FS_Outlet_Dispenser__c>();
                        //FET-1249 Changes END                       
                        //FET-1249 Changes Start iterating the List of OD records based on the PIA record for brandset and Water field population
                        for(FS_Outlet_Dispenser__c odRec:odRecList){
                            //FET-1249 Changes End
                            if(odRec.FS_Equip_Type__c==platformValue){
                                assBS.FS_Brandset__c=odRec.FS_Brandset__c;
                                assBS.FS_NonBranded_Water__c=odRec.FS_Water_Button__c;
                            }                                                          
                        }                        
                        assetBrandSet.add(assBS);
                    }
                }                
                valueOnce=false;                
            } 
            
            if(!ipEPList.isEmpty()){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODNAME,Object_Name__c='FS_IP_Equipment_Package__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                final Boolean success=FSUtil.dmlProcessorInsert(ipEPList,true,apexError);
             	//create/Insert Technician Instructions
                if(success){                    
                    createTechInstforPIA(ipEPList,installList,newInstallMap);
                }   
            }   
            if(!assetBrandSet.isEmpty()){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODNAME,Object_Name__c='FS_Association_Brandset__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorInsert(assetBrandSet,true,apexError);                                                                                                                    
            }                    
            if(!delSet.isEmpty()){                                   
                final List<FS_IP_Equipment_Package__c> equipmentList=[Select id,RecordTypeId,FS_Platform_Type__c,FS_Installation__c from FS_IP_Equipment_Package__c where FS_Installation__c IN:installIdSet];
                List<FS_IP_Technician_Instructions__c> tiList=[select Id,Name,FS_Platform_Type__c ,FS_Instalation_Process__c from FS_IP_Technician_Instructions__c where FS_Instalation_Process__c IN:installIdSet];
                final List<FS_Association_Brandset__c> assetBrandList = [Select id,FS_Installation__c,FS_Platform__c from FS_Association_Brandset__c where FS_Installation__c IN:installIdSet];
                for(FS_IP_Equipment_Package__c equipment:equipmentList){
                    final String equip=equipment.FS_Installation__c+equipment.FS_Platform_Type__c; 
                    mapEquip.put(equip,equipment);
                }            
                for(FS_IP_Technician_Instructions__c techInst:tiList){
                    String platform=techInst.FS_Instalation_Process__c+techInst.FS_Platform_Type__c;
                    mapTI.put(platform, techInst);                
                }for(FS_Association_Brandset__c associate:assetBrandList){
                    final String platform=associate.FS_Installation__c+associate.FS_Platform__c;
                    mapAssociate.put(platform,associate);                             
                }
                for(String deleteValues:delSet){                            
                    if(mapEquip.containsKey(deleteValues)){
                        delListEQP.add(mapEquip.get(deleteValues));
                    } 
                    if(mapTI.containsKey(deleteValues)){
                        delTIList.add(mapTI.get(deleteValues));
                    }
                    if(mapAssociate.containsKey(deleteValues)){
                        deleAssetBrandSets.add(mapAssociate.get(deleteValues));
                    } 
                }                              
            }        
            if(!delListEQP.isEmpty() && delListEQP!=null){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODNAME,Object_Name__c='FS_IP_Equipment_Package__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);                        
                FSUtil.dmlProcessorDelete(delListEQP,true,apexError);                                                                                                                    
            } 
            if(!delTIList.isEmpty()){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODNAME,Object_Name__c='FS_IP_Technician_Instructions__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorDelete(delTIList,true,apexError);
            }
            if(!deleAssetBrandSets.isEmpty() && deleAssetBrandSets!=null){
                final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                        Method_Name__c=METHODNAME,Object_Name__c='FS_Association_Brandset__c',
                                                                        Error_Severity__c=FSConstants.MediumPriority);
                FSUtil.dmlProcessorDelete(deleAssetBrandSets,true,apexError);                                                        
            }
        }
    }   
 
    /*****************************************************************
  	Method: updatePlatformTrackingFields
  	Description: updatePlatformTrackingFields method is to Update the 
		Platform Lastmodifiedby,Date,Prior platform and Platform History fields
		When ever platform Type/s field been modified
	*******************************************************************/  
    public static void updatePlatformTrackingFields(final List<FS_Installation__c> newInstList,final Map<id,FS_Installation__c> oldInstMap,final Boolean isUpdate){
        for(FS_Installation__c inst:newInstList){
            if(!isUpdate && inst.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE){
               inst.Platform_Type_History__c=UserInfo.getName()+', '+inst.FS_Local_Time__c+' EST'+', '+inst.Type_of_Dispenser_Platform__c; 
            }
            if(isUpdate && inst.Type_of_Dispenser_Platform__c!=oldInstMap.get(inst.Id).Type_of_Dispenser_Platform__c){               
                inst.FS_Platforms_LastModifiedBy__c=UserInfo.getName() ;
                inst.FS_Platforms_LastModifiedDate__c=system.today();
                inst.Prior_Platform_Type_Value__c=oldInstMap.get(inst.Id).Type_of_Dispenser_Platform__c;
                inst.Platform_Type_History__c=UserInfo.getName()+', '+inst.FS_Local_Time__c+' EST'+', '+inst.Type_of_Dispenser_Platform__c;
                if(oldInstMap.get(inst.Id).Platform_Type_History__c!=null){
                    inst.Platform_Type_History__c+='\n'+oldInstMap.get(inst.Id).Platform_Type_History__c;
                }
            }           
        }
    }
    
    public static void sinkABRecordsToPlatformDetails(final List<FS_Installation__c> installList,final Map<Id,FS_Installation__c> oldInstallMap){
        Set<Id> installSet=new Set<Id>();
        List<FS_Association_Brandset__c> abListUpdate=new List<FS_Association_Brandset__c>();
        for(FS_Installation__c install:installList){
            if(install.Type_of_Dispenser_Platform__c!=oldInstallMap.get(install.id).Type_of_Dispenser_Platform__c){
                installSet.add(install.Id);
            }
        }
        if(!installSet.isEmpty()){
            for(FS_Association_Brandset__c abs:[select id,name,FS_Platforms__c,FS_Platform__c,FS_Installation__c,FS_Installation__r.FS_Platform1__c,
                                                FS_Installation__r.FS_Platform2__c,FS_Installation__r.FS_Platform3__c  from FS_Association_Brandset__c
                                               where FS_Installation__c IN:installSet]){
          		String platformValue;
                platformValue=(abs.FS_Platform__c==abs.FS_Installation__r.FS_Platform1__c)?'Platform 1':platformValue;
                platformValue=(abs.FS_Platform__c==abs.FS_Installation__r.FS_Platform2__c)?'Platform 2':platformValue;
                platformValue=(abs.FS_Platform__c==abs.FS_Installation__r.FS_Platform3__c)?'Platform 3':platformValue;
                if(platformValue!=null && abs.FS_Platforms__c!=platformValue){
                    abs.FS_Platforms__c=platformValue;
                    abListUpdate.add(abs);                    
              	}                
            }
            if(!abListUpdate.isEmpty()){
                update abListUpdate;
            }
        }
    }
    
     /*****************************************************************
  	Method: copyCIFToOutlet
  	Description: copyCIFToOutlet method is to populate the necessary fields from CIF of IP to Outlet linked to the IP
				Added as part of FET 5.0, 
	Moved the functionality from FSCreateExecutionPlanExtension class to this trigger to avoid 101 SOQL error 
	while converstion of CIF to EP
	*******************************************************************/ 
    public static Account copyCIFToOutlet(final Account outlet,final FS_CIF__c cif){        
        outlet.FS_Requested_Channel__c=cif.FS_Requested_Channel__c; 
        outlet.FS_Requested_Order_Method__c=cif.FS_Cartridge_Order_Method__c;
        outlet.Cokesmart_Payment_Method__c=cif.FS_Cartridge_Payment_Method__c;
        outlet.FS_Payment_Method__c=cif.FS_Program_Fee_Payment_Method__c;
        outlet.FS_Estimated_Annual_Volume_gallons__c=cif.FS_Total_VPO__c; 
        outlet.FS_Admin_User_Name__c = cif.FS_Order_Administrator__r.Name;
        outlet.FS_Admin_User_Title__c =  cif.FS_Order_Administrator__r.FS_Title__c;
        outlet.FS_Admin_User_Email__c =  cif.FS_Order_Administrator__r.Email;
        outlet.FS_Admin_User_Phone__c = cif.FS_Order_Administrator__r.Phone;
        outlet.FS_Standard_User__c = cif.FS_Order_Standard_User__r.Name;
        outlet.FS_Standard_User_Function__c = cif.FS_Order_Standard_User__r.FS_Title__c;
        outlet.FS_Standard_User_Email__c =  cif.FS_Order_Standard_User__r.Email;
        outlet.FS_Standard_User_Phone__c =cif.FS_Order_Standard_User__r.Phone;
        outlet.FS_Name_of_Sweetener_Distributor__c=cif.FS_Name_of_Sweetener_Distributor__c;
        outlet.FS_Bill_To_Address_same_as_Ship_to_Add__c=cif.FS_Is_Bill_to_Address_Same_as_Ship_to__c;
        if(cif.FS_Cartridge_Order_Method__c!='Distributor'){
            outlet.FS_VMS_Customer__c=cif.FS_Cartridge_Order_Method__c;   
        }
        outlet.FS_CS_All_Ftn_Removed__c =  cif.FS_RemoveAllFTNLegacyServeDispensers__c;
        outlet.FS_Distributor_Name__c=cif.FS_Distributor_Name_City_ST__c;
        outlet.FS_Distributor_City__c=cif.FS_Distributor_City__c;
        outlet.FS_Distributor_State__c=cif.FS_Distributor_State__c;
        outlet.FS_Water_Filter_MFG__c=cif.FS_Water_Filter_MFG__c;
        outlet.FS_Requested_Delivery_Method__c = cif.FS_Delivery_Method__c ;
        outlet.FS_CS_Bill_To_Address__c = cif.FS_Bill_to_Address__c;
        outlet.FS_CS_Bill_To_City__c =   cif.FS_Bill_to_City__c;
        outlet.FS_CS_State__c = cif.FS_Bill_to_State__c;
        outlet.FS_CS_Bill_To_Country__c = cif.FS_Bill_to_Country__c;
        outlet.FS_CS_Bill_To_Zip__c = cif.FS_Bill_to_Zip_Code__c;
        
        return outlet;
    }
    
    /*****************************************************************
  	Method: updateOutletFromCIF
  	Description: updateOutletFromCIF method is to fetch necessary fields from CIF of IP to update the Outlet records
	Added as part of FET 5.0, 
	Moved the functionality from FSCreateExecutionPlanExtension class to this trigger to avoid 101 SOQL error 
	while converstion of CIF to EP
	*******************************************************************/ 
    public static void updateOutletFromCIF(final List<FS_Installation__c> newInstallList,final Map<Id,FS_Installation__c> newInstallMap,final Map<Id, Sobject> sobjectsToUpdate){
        final Set<Id> cifIdSet=new Set<Id>();   
        Account accRecord;
        for(FS_Installation__c install:newInstallList){
            if(install.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && install.FS_CIF__c!=FSConstants.NULLVALUE ){
                cifIdSet.add(install.FS_CIF__c);
            }
        }
        
        for(FS_CIF__c cif:[select id,FS_Account__c,FS_Requested_Channel__c,FS_Cartridge_Order_Method__c,FS_Cartridge_Payment_Method__c,FS_Program_Fee_Payment_Method__c,
                           FS_Total_VPO__c,FS_Order_Administrator__r.Name,FS_Order_Administrator__r.FS_Title__c,FS_Order_Administrator__r.Email,
                           FS_Order_Administrator__r.Phone,FS_Order_Standard_User__r.Name,FS_Order_Standard_User__r.FS_Title__c,FS_Order_Standard_User__r.Email,
                           FS_Order_Standard_User__r.Phone,FS_Name_of_Sweetener_Distributor__c,FS_Is_Bill_to_Address_Same_as_Ship_to__c,
                           FS_RemoveAllFTNLegacyServeDispensers__c,FS_Distributor_Name_City_ST__c,FS_Distributor_City__c,FS_Distributor_State__c,
                           FS_Water_Filter_MFG__c,FS_Delivery_Method__c,FS_Bill_to_Address__c,FS_Bill_to_City__c,FS_Bill_to_State__c,FS_Bill_to_Country__c,FS_Bill_to_Zip_Code__c
                           from FS_CIF__c where ID IN:cifIdSet]){
                               accRecord=new Account();
        	if(sobjectsToUpdate.containsKey(cif.FS_Account__c)){                
            	Account acc=(Account)sobjectsToUpdate.get(cif.FS_Account__c);
                accRecord=copyCIFToOutlet(acc,cif);
                sobjectsToUpdate.put(cif.FS_Account__c, accRecord);
            }
            else{                               
                accRecord=copyCIFToOutlet(new Account(Id=cif.FS_Account__c),cif);
                sobjectsToUpdate.put(cif.FS_Account__c, accRecord);
            }
        }      
    }
}