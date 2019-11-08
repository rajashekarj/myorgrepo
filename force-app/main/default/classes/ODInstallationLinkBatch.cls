global class ODInstallationLinkBatch implements Database.Batchable<sObject>, Database.Stateful {
        global Integer withinnmonths;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        OdLinkDates__mdt odlinkdate = [SELECT lastnmonths__c FROM OdLinkDates__mdt limit 1];
        if(odlinkdate.lastnmonths__c!=null)
			withinnmonths=Integer.valueOf(odlinkdate.lastnmonths__c)*-1;
        else
          	withinnmonths = 3*-1;
        Date lastnMonths=Date.Today().addMonths(withinnmonths);
        return Database.getQueryLocator('select id,FS_Date_Status__c,Installation__c,FS_Equip_Type__c,createddate,FS_Planned_Install_Date__c,FS_Outlet__c from FS_Outlet_Dispenser__c where FS_IsActive__c=true and FS_Status__c=\'Enrolled\' and FS_Country_Key__c=\'US\' and FS_Date_Installed2__c >= :lastnMonths and installation__c=\'\' ');
    }
    
    global void execute(Database.BatchableContext bc, List<FS_Outlet_Dispenser__c> scope){
  Set<Id> outletIds=new Set<Id>();
        List<FS_Installation__c> openinstall=new List<FS_Installation__c>();
        List<FS_Installation__c> replaceinstall=new List<FS_Installation__c>();
        Boolean check=false;
        boolean duplicateMatch = false;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(FS_Outlet_Dispenser__c od : scope){
           
            outletIds.add(od.FS_Outlet__c);
            
        }
        //Fetch all installation using under same outlet
        List<FS_Installation__c> installList=[select Id,FS_Scheduled_Install_Date__c,Name,Outlet_ACN__c,FS_Outlet__c,Type_of_Dispenser_Platform__c,FS_Overall_Status__c,recordtype.name from FS_Installation__c where FS_Outlet__c IN:outletIds];
        
               
        String outletACN='';
        //Based on installation status add installation to list and find out any dupicate installation is there
        String Installation_Status = Label.Installation_Status;
        for(FS_Installation__c install:installList){
            outletACN=install.Outlet_ACN__c;
            if((install.recordtype.name==FSConstants.NEWINSTALLATION ) && install.FS_Overall_Status__c!=null&& (Installation_Status!=(install.FS_Overall_Status__c) )){
                openinstall.add(install);                
            }
            else if(install.recordtype.name==Label.IP_Replacement_Rec_Type && (install.FS_Overall_Status__c==FSConstants.x1ReadySchedule || 
                                                                               install.FS_Overall_Status__c==FSConstants.x3PendingSchedu ||
                                                                               install.FS_Overall_Status__c==FSConstants.onHolds ||       
                                                                               install.FS_Overall_Status__c==FSConstants.scheduled)){
                                                                                   replaceinstall.add(install);
                                                                               }
        }
        
        for(FS_Outlet_Dispenser__c od : scope){                 
           
            for(FS_Installation__c install:openinstall){
              system.debug('Install ID: ' + install.Id + ' , Scheduled Date: ' + install.FS_Scheduled_Install_Date__c + ' Registration Date: ' + od.FS_Date_Status__c);
              if(od.FS_Date_Status__c!=null && install.FS_Scheduled_Install_Date__c!=null){
                DateTime dT =od.FS_Date_Status__c;
                Date odfsDate = date.newinstance(dT.year(), dT.month(), dT.day());
                integer numberOfMonths = (odfsDate).monthsBetween(install.FS_Scheduled_Install_Date__c );
                system.debug('install Id: ' + install.id + ' , ' + ' , numberOfMonths: '+ numberOfMonths);
                if(numberOfMonths<=(withinnmonths*-1) && numberOfMonths>=-1 ){
    
                    String recordTypeName=FSInstallationValidateAndSet.mapofRecordtypIdAndRecordTypeName.get(install.recordTypeId);
                    if(od.FS_Equip_Type__c!=null &&  install.Type_of_Dispenser_Platform__c!=null && install.Type_of_Dispenser_Platform__c.contains(od.FS_Equip_Type__c))  {
                        if(od.FS_Outlet__c==install.FS_Outlet__c){
                            od.Installation__c=install.Id;
                            check=true;                        
                            break;
                        }
                    }
                }
              }
            }
            if(!check ){
                for(FS_Installation__c install:replaceinstall){
                  if(od.FS_Date_Status__c!=null && install.FS_Scheduled_Install_Date__c!=null){
                    DateTime dT =od.FS_Date_Status__c;
                    Date odfsDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    integer numberOfMonths = (odfsDate).monthsBetween(install.FS_Scheduled_Install_Date__c );
                    system.debug('numberOfMonths'+numberOfMonths);
                	if(numberOfMonths<=(withinnmonths*-1) && numberOfMonths>=-1 ){
                            if( od.FS_Outlet__c==install.FS_Outlet__c && install.Type_of_Dispenser_Platform__c!=null && od.FS_Equip_Type__c!=null && install.Type_of_Dispenser_Platform__c.contains(od.FS_Equip_Type__c)){
                                od.Installation__c=install.Id;                                                       
                                check=true;                                                            
                                break;
                            }
                        } 
                    }
                }
            }
            system.debug('Duplicate: '+duplicateMatch);
            system.debug('Check '+check);
            
          
        
        
    }    
        update scope;
    }
    
    global void finish(Database.BatchableContext bc){
       system.debug('finish');
    }    
}