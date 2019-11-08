public class FSAssociationBrandsetTriggerHandler {
    public static final String CLASSNAME='FSAssociationBrandsetTriggerHandler';
    public static Boolean checkOnce=false;
    static final Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.FS_Association_Brandset__c.getRecordTypeInfosByName();
    
    
    /*****************************************
Dont allow to add duplicate platform on HQ
********************************************/
    public static void preventDuplicatePlatform() {
        final List<FS_Association_Brandset__c> newBrandsets = (List<FS_Association_Brandset__c>) Trigger.new;
        final List<FS_Association_Brandset__c> hqBrandsets = new List<FS_Association_Brandset__c>();
        final Map<ID,String> oldBrandPlat = new Map<ID,String>{};
            final Map<Id,List<String>> hqPlatforms = new Map<Id,List<String>>{};
                final ID hqBrandsetId = rtMap.get(FSConstants.ASSBRANDSET_HQ).recordtypeId;
        
        //Proceed only for HQ Association Brandset records and get all HQ ids of these Brandsets
        for (FS_Association_Brandset__c brandset : newBrandsets){
            if (brandset.recordtypeid==hqBrandsetId) {
                hqBrandsets.add(brandset);
                hqPlatforms.put(brandset.FS_Headquarters__c, new List<String>());
            }
        }
        
        if (hqBrandsets.isEmpty()) {  return;    }
        
        //Retrieve existing platforms for all headquarter ids
        for (FS_Association_Brandset__c brandset : [select id,FS_Platform__c,FS_Headquarters__c from FS_Association_Brandset__c where FS_Headquarters__c<>null and FS_Headquarters__c in :hqPlatforms.keySet()]){
            hqPlatforms.get(brandset.FS_Headquarters__c).add(brandset.FS_Platform__c);
            oldBrandPlat.put(brandset.id,brandset.FS_Platform__c);
        }
        
        //check for duplicate platforms
        if (Trigger.isUpdate){
            for (FS_Association_Brandset__c brandset : hqBrandsets){
                if (brandset.FS_Platform__c!=oldBrandPlat.get(brandset.id)){
                    list<String> platforms = hqPlatforms.get(brandset.FS_Headquarters__c);
                    if (platforms.contains(brandset.FS_Platform__c)){
                        brandset.FS_Platform__c.addError(System.Label.FS_Duplicate_AB_Error);
                    }
                    else {
                        //update platform list
                        if (platforms.indexOf(oldBrandPlat.get(brandset.id))!=-1) platforms.remove(platforms.indexOf(oldBrandPlat.get(brandset.id)));
                        platforms.add(brandset.FS_Platform__c);
                    }
                }
            }
        }
        
        if (Trigger.isInsert){
            for (FS_Association_Brandset__c brandset : hqBrandsets){
                list<String> platforms = hqPlatforms.get(brandset.FS_Headquarters__c);
                if (platforms.contains(brandset.FS_Platform__c)){
                    brandset.FS_Platform__c.addError(System.Label.FS_Duplicate_AB_Error);
                }
                else {
                    //update platform list
                    platforms.add(brandset.FS_Platform__c);
                }
            }
        }
        
    }
    
    /*
*New method POC- Sprint 8 FET 5.1
*/
    public static void updateODAB(){
        final List<FS_Association_Brandset__c> newBrandsets = (List<FS_Association_Brandset__c>) Trigger.new;
        final List<FS_Association_Brandset__c> ODAb = new List<FS_Association_Brandset__c>();
        final Map<Id,FS_Association_Brandset__c> oldMap = (Map<Id,FS_Association_Brandset__c>)Trigger.oldmap;
        Set<id> odID=new Set<Id>();
        Set<id> instID=new Set<Id>();
        Set<Id> fetchInstallId =new Set<Id>();
        final ID odABrecordtypeid=rtMap.get(FSConstants.ASSBRANDSET_OD).recordtypeId;
        final ID ipABrecordtypeid=rtMap.get(FSConstants.ASSBRANDSET_IP).recordtypeId;
        Map<String,FS_Association_Brandset__c> ipAbMap=new Map<String,FS_Association_Brandset__c>();
        //AW call
        Map<Id,String> dispenserAWMap = new  Map<Id,String>();
        
        
        for (FS_Association_Brandset__c brandset : newBrandsets){
            if (brandset.FS_IP_RecordType__c==Label.IP_New_Install_Rec_Type && ( brandset.FS_Brandset__c!=oldMap.get(brandset.id).FS_Brandset__c || brandset.FS_NonBranded_Water__c!=oldMap.get(brandset.id).FS_NonBranded_Water__c && (brandset.recordtypeid==ipABrecordtypeid))) {
                instID.add(brandset.FS_Installation__c);
                ipAbMap.put(brandset.FS_Installation__c+brandset.FS_Platform__c,brandset);     
            }
        }
        //Fetch Install and check for status
        for(FS_Installation__c install:[Select id,Overall_Status2__c from FS_Installation__c where id in:instId ]){
            if(install.Overall_Status2__c==FSConstants.x3PendingSchedu||install.Overall_Status2__c ==FSConstants.x4InstallSchedule ||install.Overall_Status2__c ==FSConstants.x1ReadySchedule){
                fetchInstallId.add(install.id);}
        }
        
        Map<id,Id> odIPMap= new Map<Id,Id>();
        
        //Fetch OD under that installation
        for(FS_Outlet_Dispenser__c od:[select id,Installation__c from FS_Outlet_Dispenser__c where Installation__c in:fetchInstallId]){
            odID.add(od.id);
            odIPMap.put(od.id,od.Installation__c);
            dispenserAWMap.put(od.id,'Flavor');
        }
        
        List<FS_Association_Brandset__c> updateAB = new List<FS_Association_Brandset__c>();
        //Fetch all OD related Ab
        for (FS_Association_Brandset__c odbrandset : [select id,FS_Platform__c,FS_Outlet_Dispenser__c from FS_Association_Brandset__c where FS_Outlet_Dispenser__c<>null and FS_Outlet_Dispenser__c in :odID]){
            if(ipAbMap.containsKey(odIPMap.get(odbrandset.FS_Outlet_Dispenser__c)+odbrandset.FS_Platform__c) ){
                odbrandset.FS_Brandset__c=ipAbMap.get(odIPMap.get(odbrandset.FS_Outlet_Dispenser__c)+odbrandset.FS_Platform__c).FS_Brandset__c;
                odbrandset.FS_NonBranded_Water__c=ipAbMap.get(odIPMap.get(odbrandset.FS_Outlet_Dispenser__c)+odbrandset.FS_Platform__c).FS_NonBranded_Water__c;
                updateAB.add(odbrandset);
            }
        }
        update updateAB;
    }
    /* UPdate Outlet dispenser HideWater field on insert of AB*/
    public static void updateODWaterFieldInsert(){
        final List<FS_Association_Brandset__c> newBrandsets = (List<FS_Association_Brandset__c>) Trigger.new;
        Map<Id,FS_Association_Brandset__c> dispenserIDMap = new Map<Id,FS_Association_Brandset__c>();
        List<FS_Outlet_Dispenser__c> updateODList= new List<FS_Outlet_Dispenser__c>();
        for (FS_Association_Brandset__c brandset : newBrandsets){
            dispenserIDMap.put(brandset.FS_Outlet_Dispenser__c,brandset);
            
        }
        for(FS_Outlet_Dispenser__c od:[Select id,FS_Water_Button__c,Hide_Water_Dispenser__c,FS_Brandset__c from FS_Outlet_Dispenser__c where id in: dispenserIDMap.keySet() ]){
            //od.Hide_Water_Dispenser__c=dispenserIDMap.get(od.id).FS_NonBranded_Water__c;
            od.FS_Water_Button__c=dispenserIDMap.get(od.id).FS_NonBranded_Water__c;
            od.FS_Brandset__c=dispenserIDMap.get(od.id).FS_Brandset__c;
            updateODList.add(od);
        }
        
        if(!FSConstants.odtriggercheck){
            update updateODList;
        }
    }
    
    
    /*Update Outlet dispenser HideWater field  on update of AB */
    
    public static void updateODWaterfield(){
        final List<FS_Association_Brandset__c> newBrandsets = (List<FS_Association_Brandset__c>) Trigger.new;
        final Map<Id,FS_Association_Brandset__c> oldMap = (Map<Id,FS_Association_Brandset__c>)Trigger.oldmap;
        final ID odABrecordtypeid=rtMap.get(FSConstants.ASSBRANDSET_OD).recordtypeId;
        Map<Id,FS_Association_Brandset__c> dispenserIDMap = new Map<Id,FS_Association_Brandset__c>();
        List<FS_Outlet_Dispenser__c> updateODList= new List<FS_Outlet_Dispenser__c>();
        
        for (FS_Association_Brandset__c brandset : newBrandsets){
            if (brandset.FS_Outlet_Dispenser__c != Null && (brandset.FS_Brandset__c!=oldMap.get(brandset.id).FS_Brandset__c || brandset.FS_NonBranded_Water__c!=oldMap.get(brandset.id).FS_NonBranded_Water__c) && (brandset.recordtypeid==odABrecordtypeid)) {
                dispenserIDMap.put(brandset.FS_Outlet_Dispenser__c,brandset);
            }
        }
        
        for(FS_Outlet_Dispenser__c od:[Select id,FS_Water_Button__c,Hide_Water_Dispenser__c,FS_Brandset__c from FS_Outlet_Dispenser__c where id in: dispenserIDMap.keySet() ]){
            //od.Hide_Water_Dispenser__c=dispenserIDMap.get(od.id).FS_NonBranded_Water__c;
            od.FS_Water_Button__c=dispenserIDMap.get(od.id).FS_NonBranded_Water__c;
            od.FS_Brandset__c=dispenserIDMap.get(od.id).FS_Brandset__c;
            updateODList.add(od);
        }
        
        if(!FSConstants.odtriggercheck){
            update updateODList;
        }
        
    }
    
    
    public static void brandStatusUpdateIP(final List<FS_Association_Brandset__c> newList,final List<FS_Association_Brandset__c> oldList,final Map<Id,FS_Association_Brandset__c> newMap,final Map<Id,FS_Association_Brandset__c> oldMap,final Boolean isUpdate){
        //Set to Store Installation Ids
        Set<Id> installIdSet=new Set<Id>();       
        //List to Store Installation records to Update
        List<FS_Installation__c> installUpdate=new List<FS_Installation__c>();
        
        //Iterating New List to Store Install Ids where record type is New Install        
        for(FS_Association_Brandset__c asscBrand:newList){
            if(asscBrand.FS_Installation__c!=null && asscBrand.FS_IP_RecordType__c==FSConstants.NEWINSTALLATION){
                installIdSet.add(asscBrand.FS_Installation__c);
            }
        }      
        if(!installIdSet.isEmpty() && !checkOnce){
            //Querying the Installation records with the respective AB records
            final Map<Id,FS_Installation__c> installBrandsetMap=new Map<Id,FS_Installation__c>(
                [select id,name,(select id,name,FS_Installation__c,FS_Platform__c,FS_NonBranded_Water__c,FS_Brandset__c from Account_Brandsets__r where FS_Installation__c!=null) 
                 from FS_Installation__c where Id IN:installIdSet]);
            //Iterating install Ids
            for(Id installId:installIdSet){
                if(installBrandsetMap.containsKey(installId)){                   
                    Boolean brandStatus=true;
                    for(FS_Association_Brandset__c abRec:installBrandsetMap.get(installId).Account_Brandsets__r){                        
                        if(abRec.FS_NonBranded_Water__c==null || abRec.FS_Brandset__c==null){
                            brandStatus=false;                                          
                        }                      
                    }
                    installUpdate.add(new FS_Installation__c(id=installId,FS_BrandStatus__c=brandStatus?'Complete':'NOT Complete'));                    
                    checkOnce=true;
                }
            }
        }      
        if(!installUpdate.isEmpty()){
            //Creating error logger instance with required information
            final Apex_Error_Log__c apexError=new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c=CLASSNAME,
                                                                    Method_Name__c='brandStatusUpdateIP',Object_Name__c=FSConstants.INSTALLATIONOBJECTNAME,
                                                                    Error_Severity__c=FSConstants.MediumPriority);
            //Updating Install records
            FSUtil.dmlProcessorUpdate(installUpdate,true,apexError); 
        }
    }
    
    
    //FET5.0- When brandset is changed on installation NDO/POM user will be notify
    public static void brandsetChangeNotification(){
        system.debug('In notification method');
        //old map
        Map<Id,FS_Association_Brandset__c > oldMap = (Map<Id,FS_Association_Brandset__c >)Trigger.oldMap;        
        set<ID> ABID=new Set<ID>();
        set<id> instID=new set<id>();
        Map<id,List<FS_Association_Brandset__c>> newABMap = new Map<id,List<FS_Association_Brandset__c>>();
        
        
        if(trigger.isUpdate){
            for(FS_Association_Brandset__c AB: (List<FS_Association_Brandset__c >)trigger.New){
                if(ab.FS_Installation__c!= null && ab.FS_Brandset__c != oldMap.get(AB.id).FS_Brandset__c){
                    ABID.add(ab.id);
                    instID.add(ab.FS_Installation__c);                    
                    if(newABMap.containsKey(ab.FS_Installation__c)){
                        List<FS_Association_Brandset__c> abListNew=newABMap.get(ab.FS_Installation__c);
                        abListNew.add(ab);
                        newABMap.put(ab.FS_Installation__c, abListNew);
                    }else{
                        List<FS_Association_Brandset__c> abListNew= new List<FS_Association_Brandset__c>();
                        abListNew.add(ab);
                        newABMap.put(ab.FS_Installation__c, abListNew);
                    }
                }
            }   
        }else{
            for(FS_Association_Brandset__c AB: (List<FS_Association_Brandset__c >)trigger.old){
                if(ab.FS_Installation__c!= null && ab.FS_Brandset__c != null){
                    ABID.add(ab.id);
                    instID.add(ab.FS_Installation__c);                    
                    if(newABMap.containsKey(ab.FS_Installation__c)){
                        List<FS_Association_Brandset__c> abListNew=newABMap.get(ab.FS_Installation__c);
                        abListNew.add(ab);
                        newABMap.put(ab.FS_Installation__c, abListNew);
                    }else{
                        List<FS_Association_Brandset__c> abListNew= new List<FS_Association_Brandset__c>();
                        abListNew.add(ab);
                        newABMap.put(ab.FS_Installation__c, abListNew);
                    }
                }
            } 
        } 
        
        
        //Querying the Installation records with the respective AB records
        final Map<Id,FS_Installation__c> installBrandsetMap=new Map<Id,FS_Installation__c>(
            [select id,name,RecordTypeId,FS_Outlet__c,Outlet_ACN__c,FS_Outlet_Name__c,FS_Outlet_SAP_ID__c,
             FS_Outlet_Address__c,Prior_Platform_Type_Value__c,FS_Order_Delivery_method_check__c,
             Distribution_Center__c,FS_Calculated_Customer_Classification__c,FS_Activation_Lead__c,
             Overall_Status2__c,(select id,FS_Brandset__c,FS_Platform__c,Brandset_Name__c,FS_Installation__c from Account_Brandsets__r where FS_Installation__c!=null),(select id,FS_Order_Processed__c from Initial_Orders__r where FS_Installation__c!=null order by createdDate DESC limit 1)
             from FS_Installation__c where Id IN:instID]);
        for(Id instRecId:instID){
            if(installBrandsetMap.containskey(instRecId)){
                final FS_Installation__c inst=installBrandsetMap.get(instRecId);
                //CDM
                system.debug('@@@'+inst.Overall_Status2__c);
                Boolean orderProcessedCheck=false;
                if(!inst.Initial_Orders__r.isEmpty() && inst.Initial_Orders__r[0].FS_Order_Processed__c){
                    orderProcessedCheck=true;
                }
                if(inst.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && (inst.Overall_Status2__c== FSConstants.x4InstallSchedule || inst.Overall_Status2__c== FSConstants.x3PendingSchedu) ){
                    if(newABMap.containsKey(inst.Id))
                        notifyCDMUser(inst,oldMap,newABMap.get(inst.Id),inst.Account_Brandsets__r);
                }
                if(inst.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType && orderProcessedCheck && (inst.Overall_Status2__c== FSConstants.x4InstallSchedule || inst.Overall_Status2__c== FSConstants.x3PendingSchedu) ){
                    if(newABMap.containsKey(inst.Id))
                        notifyPOMUser(inst,oldMap,newABMap.get(inst.Id),inst.Account_Brandsets__r);
                }
                
            }
        }        
    }    
    
    public static void  notifyCDMUser(FS_Installation__C inst,Map<Id,FS_Association_Brandset__c > oldMap,List<FS_Association_Brandset__c> ABList,List<FS_Association_Brandset__c> listAB1){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        List<FS_Brandset_Change_Recipient_List__c> recipientList = FS_Brandset_Change_Recipient_List__c.getall().values();
        for(FS_Brandset_Change_Recipient_List__c rec:recipientList){
            if(rec.FS_User_Type__c == 'CDM'){
                sendto.add(rec.FS_Email__C);
            }
        }
        String oldBrandset='';
        String newBrandset='';
        String oldPlatforms='';
        String newplatforms='';
        String checkBrandset='';
        
        for(FS_Association_Brandset__c ab:ABList){
            checkBrandset+=ab.FS_Platform__c+'-'+ab.Brandset_Name__c+'; ';
        }
        system.debug('@@## '+checkBrandset);
        for(FS_Association_Brandset__c ab:listAB1){
            if(oldMap.containsKey(ab.id)){
                if(oldmap.get(ab.id).Brandset_Name__c!=null){
                    oldBrandset +=  oldmap.get(ab.id).Brandset_Name__c+'; ';
                }
            }
            else{ 
                oldBrandset +=  ab.Brandset_Name__c+'; ';
            }
            if(trigger.isDelete){
                if(!oldmap.containskey(ab.id)){ 
                    newplatforms+=  ab.FS_Platform__c+'; ';
                }
                if(!checkBrandset.contains(ab.FS_Platform__c+'-'+ab.Brandset_Name__c) ){
                    newBrandset += ab.Brandset_Name__c+'; ';
                }
                
            }else{
                newBrandset += ab.Brandset_Name__c+'; ';
                newplatforms+=  ab.FS_Platform__c+'; ';
                oldPlatforms+= ab.FS_Platform__c+'; ';
            }
        }
        if(trigger.isdelete){
            for(FS_Association_Brandset__c ab:listAB1){
                oldPlatforms+= ab.FS_Platform__c+'; ';
            }
        }
        oldBrandset=oldBrandset.removeEnd('; ');
        newBrandset=newBrandset.removeEnd('; ');
        oldPlatforms=oldPlatforms.removeEnd('; ');
        newplatforms=newplatforms.removeEnd('; ');
        system.debug('@@@@@'+sendto);
        mail.setToAddresses(sendTo);
        string body = 
            'Hi,'+'</br></br>'+'The brandset has changed on a Scheduled/Pending Reschedule install. Please update SAP accordingly.' + '</br>';
        body+='Installation Name: '+'<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +inst.id +'">'+ inst.Name +'</a><br>'+'Outlet Name: '+inst.FS_Outlet_Name__c+'</br>'+'ACN: '+inst.Outlet_ACN__c+'</br>'+'SAP Id: '+inst.FS_Outlet_SAP_ID__c+'</br>'+'Address: '+inst.FS_Outlet_Address__c+'</br>';
        body+= 'Prior Brandsets: '+ oldBrandset + '</br>' + 'New Brandsets: '+ newBrandset + '</br>'; 
        body+= 'Prior Platforms: '+ oldPlatforms + '</br>' + 'New Platforms: '+ newplatforms + '</br>';
        
        body+='</br>Thank you, </br> FET';
        System.debug('@@CDM BODY '+body);
        mail.setSubject('The brandset has changed on an Install - Outlet ACN: '+inst.Outlet_ACN__c );
        mail.setHtmlBody(body);                 
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
    }
    
    public static void  notifyPOMUser(FS_Installation__C inst,Map<Id,FS_Association_Brandset__c > oldMap,List<FS_Association_Brandset__c> ABList,List<FS_Association_Brandset__c> listAB1){
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        List<FS_Brandset_Change_Recipient_List__c> recipientList = FS_Brandset_Change_Recipient_List__c.getall().values();
        for(FS_Brandset_Change_Recipient_List__c rec:recipientList){
            if(rec.FS_User_Type__c == 'POM' && rec.FS_Email__C!=null ){
                sendto.add(rec.FS_Email__C);
            }
        }
        String oldBrandset='';
        String newBrandset='';
        String oldPlatforms='';
        String newplatforms='';
        String checkBrandset='';
        
        for(FS_Association_Brandset__c ab:ABList){
            checkBrandset+=ab.FS_Platform__c+'-'+ab.Brandset_Name__c+'; ';
        }
        system.debug('@@## '+checkBrandset);
        for(FS_Association_Brandset__c ab:listAB1){
            if(oldMap.containsKey(ab.id)){
                if(oldmap.get(ab.id).Brandset_Name__c!=null){
                    oldBrandset +=  oldmap.get(ab.id).Brandset_Name__c+'; ';
                }
            }
            else{ 
                oldBrandset +=  ab.Brandset_Name__c+'; ';
            }
            if(trigger.isDelete){
                if(!oldmap.containskey(ab.id)){ 
                    newplatforms+=  ab.FS_Platform__c+'; ';
                }
                if(!checkBrandset.contains(ab.FS_Platform__c+'-'+ab.Brandset_Name__c) ){
                    newBrandset += ab.Brandset_Name__c+'; ';
                }
                
            }else{
                newBrandset += ab.Brandset_Name__c+'; ';
                newplatforms+=  ab.FS_Platform__c+'; ';
                oldPlatforms+= ab.FS_Platform__c+'; ';
            }
        }
        if(trigger.isdelete){
            for(FS_Association_Brandset__c ab:listAB1){
                oldPlatforms+= ab.FS_Platform__c+'; ';
            }
        }
        oldBrandset=oldBrandset.removeEnd('; ');
        newBrandset=newBrandset.removeEnd('; ');
        oldPlatforms=oldPlatforms.removeEnd('; ');
        newplatforms=newplatforms.removeEnd('; ');
        system.debug('@@@@@ POM'+sendto);
        
        mail.setToAddresses(sendTo);
        
        String bodypart='';
        if(trigger.isupdate){
            bodypart='The brandset has changed on a Scheduled/Pending Reschedule install. Please investigate.'+'</br>';
        }
        else if(trigger.isDelete){
            bodypart='The dispenser has been removed. Please investigate.'+'</br>';
        }
        string body = 
            'Hi,'+'</br></br>'+bodyPart + '</br>';
        body+='Installation Name: '+'<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +inst.id +'">'+ inst.Name +'</a><br>'+'Outlet Name: '+inst.FS_Outlet_Name__c+'</br>'+'ACN: '+inst.Outlet_ACN__c+'</br>'+'Address: '+inst.FS_Outlet_Address__c+'</br>';
        body+= 'Prior Brandsets: '+ oldBrandset + '</br>' + 'New Brandsets: '+ newBrandset + '</br>'; 
        body+= 'Prior Platforms: '+ oldPlatforms + '</br>' + 'New Platforms: '+ newplatforms + '</br>';
        
        body+='</br>Thank you, </br> FET';
        System.debug('@@POM BODY '+body);
        mail.setSubject('The brandset has changed after Initial Order is Processed - Outlet ACN: '+inst.Outlet_ACN__c );
        mail.setHtmlBody(body);                 
        if(!sendTo.isempty()){
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
        }
    } 
}