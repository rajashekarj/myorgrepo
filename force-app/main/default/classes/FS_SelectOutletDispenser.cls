/***********************************************
Apex Class Name : FS_SelectOutletDispenser
Created By   	: Infosys
Created Date : 1/19/2016 
Usage        : Controller for FS_SelectOutletDispenser
Modification Log:
* Developer     :    Date                   Description
* ----------------------------------------------------------------------------   
Venkata			02/13/2017					Original Version.
As part of FET 4.0 added some columns for to display extra Information of the OD records.
Brandset functionality also added to create Associate brandset records for the respective Installation based on the platform type											
************************************************/

public with sharing class FS_SelectOutletDispenser {
   
    public Set<Id> dispenserSet;
	transient SavePoint savePosition;    
    public static final String CLASSNAME='FS_SelectOutletDispenser';
    public static final String DELETEMETHOD='deleteProcess';
    public FS_Installation__c currentInstall;
    public List<Id> associateIdList;
    public Boolean editMode{get;set;}
    public Boolean refreshPage{get;set;}    
    public String profileString {get; set;}     
       
    public FS_Installation__c install {get; set;}
    public Map<String,FS_Association_Brandset__c> associateMap {get;set;}      
    public Map<String,FS_Association_Brandset__c> assBrandSetMap {get;set;}
    public Map<String,FS_Association_Brandset__c> assBrandSetMapUpdate {get;set;}
    public String optionsList {get;set;}
    public List<FS_Outlet_DispenserWrapper> FS_OutletList {get; set;}
   
     public FS_SelectOutletDispenser(final ApexPages.StandardController controller) { 
       this.currentInstall = (FS_Installation__c) controller.getRecord();
         
         
       //  this.currentInstall= (FS_Installation__c)controller.getRecord();
        refreshPage=false;
        editMode=false;      
        profileString='FS Admin PM_P,FS AC_P,FS PM_P,System Administrator,FET System Admin';
        associateIdList=new List<Id>();
        dispenserSet=new Set<Id>();
        associateMap=new Map<String,FS_Association_Brandset__c>();      
        assBrandSetMap = new Map<String,FS_Association_Brandset__c>();
         assBrandSetMapUpdate = new Map<String,FS_Association_Brandset__c>();
        
        install = [select id,name,RecordType.name,RecordTypeId,FS_Outlet__r.id,Type_of_Dispenser_Platform__c,FS_Platform1__c,FS_Platform2__c,FS_Platform3__c,
                  	FS_DispRequested1__c,FS_DispRequested2__c,FS_DispRequested3__c,Overall_Status2__c FROM FS_Installation__c  where Id = :currentInstall.Id]; 
        
        optionsList=install.Type_of_Dispenser_Platform__c!=FSConstants.NULLVALUE?install.Type_of_Dispenser_Platform__c:FSConstants.BLANKVALUE;
       
       /* for(FS_Association_Brandset__c assoBrandset : 
            [select Id,Name,FS_Installation__c,FS_Platform__c,Brandset_Name__c,FS_Outlet_Dispenser__c,FS_NonBranded_Water__c,FS_Brandset__c from FS_Association_Brandset__c 
                        where FS_Installation__c!=null and FS_Installation__c =: install.id order by FS_Platform__c]){           
            
        	assBrandSetMap.put(assoBrandset.FS_Platform__c,assoBrandset);
        }        */
    }   
    
    /*****************************************************************
Method: getFSOutletDispensers
Description: getFSOutletDispensers method returns the list of Outlet dispenser linked to the Outlet of the replacement installation.
will also list down the list of Associate Brandset records linked to the particular ODs
changes done in this method as part of FET 4.0
*******************************************************************/
    public List<FS_Outlet_DispenserWrapper> getFSOutletDispensers() {
        FS_Outlet_DispenserWrapper fsOutletDispWrppr;
        if(FS_OutletList==FSConstants.NULLVALUE) {
            FS_OutletList = new List<FS_Outlet_DispenserWrapper>();            
            //FET-1249 Changes Start to add New Lookup fields in the query
            for(FS_Outlet_Dispenser__c c: 
                [Select id,Name,FS_Serial_Number2__c,FS_Equip_Type__c,FS_ACN_NBR__c,FS_Valid_Fill__c,FS_IsActive__c,FS_outlet__c,
                 FS_Dispenser_Active_Date__c,FS_Dispenser_Inactive_Date__c,Installation__c,Installation__r.Name,FS_Removal_Request_Submitted__c,
                 Relocated_Installation__c,Relocated_Installation__r.Name,FS_Date_Installed2__c,Relocated_Installation__r.Overall_status2__c,
                 FS_Other_PIA_Installation__c,FS_Other_PIA_Installation__r.name,FS_Other_PIA_Installation__r.Overall_status2__c
                 from FS_Outlet_Dispenser__c where FS_outlet__c =: install.FS_Outlet__c Order By FS_IsActive__c DESC,CreatedDate DESC]) {
                     dispenserSet.add(c.Id);
                     //Adding the Installation Details in a List
                     List<FS_Installation__c> ipListTemp=new List<FS_Installation__c>{
                         new FS_Installation__c(id=c.Relocated_Installation__c,Overall_Status2__c=c.Relocated_Installation__r.Overall_Status2__c),
                         new FS_Installation__c(id=c.FS_Other_PIA_Installation__c,Overall_Status2__c=c.FS_Other_PIA_Installation__r.Overall_Status2__c)};
                     system.debug('ipListTemp:'+ipListTemp);
                     fsOutletDispWrppr= new  FS_Outlet_DispenserWrapper(c);
                     //Variables for Status Check and Selection check
                     Boolean checkStatus=false;
                     Boolean checkSelection=false; 
                     //To Get to know Check box should be enabled or Disabled based on linked IP with Status and Current IP
                     for(FS_Installation__c inst:ipListTemp){
                         if(inst.Id!=null && inst.Overall_Status2__c!=FSConstants.IPCOMPLETE && inst.Id!=install.Id){                           
                             checkStatus=true;
                             break;                             
                         }
                     }
                     //To Get to know Check box should be Checked or Not based on linked IP with Status and Current IP
                     for(FS_Installation__c inst:ipListTemp){                         
                         checkSelection=inst.Id!=null?true:checkSelection;
                         
                         if(inst.Id!=null && inst.Id==install.Id){
                             checkSelection=true;
                             break;                                 
                         }
                         
                         if(inst.Overall_Status2__c==FSConstants.IPCOMPLETE && inst.Id!=install.Id){
                             checkSelection=false;                                 
                         }
                         
                     }
                     
                     fsOutletDispWrppr.isFormLinked=(checkStatus || install.Overall_Status2__c==FSConstants.IPCANCELLED || install.Overall_Status2__c==FSConstants.IPCOMPLETE)?true:false;
                     fsOutletDispWrppr.selected=checkSelection;                     
                     fsOutletDispWrppr.previousSelection=checkSelection;
                     FS_OutletList.add(fsOutletDispWrppr);
                 }             
            //FET-1249 Changes End
            for(FS_Association_Brandset__c associate:
                [select id,name,FS_Brandset__c,Brandset_Name__c,FS_NonBranded_Water__c,FS_Outlet_Dispenser__c,FS_Platform__c from FS_Association_Brandset__c 
                 where FS_Outlet_Dispenser__c!=null and FS_Outlet_Dispenser__c IN:dispenserSet]){                
                     
                     associateMap.put(associate.FS_Outlet_Dispenser__c,associate);                
                 }
            
            for(Id ids:dispenserSet){
                if(!associateMap.containsKey(ids)){
                    associateMap.put(ids,new FS_Association_Brandset__c(FS_Outlet_Dispenser__c=ids,FS_NonBranded_Water__c=FSConstants.STR_NULL,FS_Brandset__c=FSConstants.ID_NULL));                                       
                }               
            }
        }
        return FS_OutletList ;
    }
       
    public PageReference deleteProcess() { 
        
        //We create a new list of records that we be populated only if they are selected
        final List <FS_Outlet_Dispenser__c> toUpdatedOD = new list <FS_Outlet_Dispenser__c> ();  
        final List<FS_Outlet_Dispenser__c> selectedODs = new List<FS_Outlet_Dispenser__c>();
        final List<FS_Outlet_Dispenser__c> selectToUpdateODs = new List<FS_Outlet_Dispenser__c>();
        final List<FS_Outlet_Dispenser__c> deSelectedODList = new List<FS_Outlet_Dispenser__c>();
        Apex_Error_Log__c apexError;
        try{
            savePosition = Database.setSavePoint();//initializing the save point variable with the current status
            for(FS_Outlet_DispenserWrapper cCon: getFSOutletDispensers()) {           
                
                if(cCon.selected && !cCon.isFormLinked){          selectedODs.add(cCon.con);         }
                
                if(cCon.selected && !cCon.previousSelection){     selectToUpdateODs.add(cCon.con);   }
                
                if(!cCon.selected && cCon.previousSelection){     deSelectedODList.add(cCon.con);    } 
            }
            if(!selectToUpdateODs.isEmpty() || !selectedODs.isEmpty() || !deSelectedODList.isEmpty() ){           
                
                toUpdatedOD.clear(); //Removing previously stored values
                if(!selectToUpdateODs.isEmpty() || !deSelectedODList.isEmpty()){
                    //Start of OD Updation
                    for(FS_Outlet_Dispenser__c oDisp: selectToUpdateODs) {
                        oDisp.FS_Removal_Request_Submitted__c=true;
                        //FET-1249 Changes Start to population the Current PIA Id into Proper Field based On Record type
                        oDisp.Relocated_Installation__c=install.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation?install.Id:oDisp.Relocated_Installation__c;
                        oDisp.FS_Other_PIA_Installation__c=install.RecordTypeId!=FSInstallationValidateAndSet.ipRecTypeRelocation?install.Id:oDisp.FS_Other_PIA_Installation__c;
                        //FET-1249 Changes End
                        toUpdatedOD.add(oDisp);          
                    }
                    for(FS_Outlet_Dispenser__c oDisp: deSelectedODList) {
                        oDisp.FS_Removal_Request_Submitted__c=false;
                        //FET-1249 Changes Start to Blanking the Current PIA Id from Proper Field based On Record type
                        oDisp.Relocated_Installation__c=install.RecordTypeId==FSInstallationValidateAndSet.ipRecTypeRelocation?FSConstants.ID_NULL:oDisp.Relocated_Installation__c;
                        oDisp.FS_Other_PIA_Installation__c=install.RecordTypeId!=FSInstallationValidateAndSet.ipRecTypeRelocation?FSConstants.ID_NULL:oDisp.FS_Other_PIA_Installation__c;                        
                        //FET-1249 Changes End
                        toUpdatedOD.add(oDisp);          
                    }
                    //Updating OD records   
                    if(!toUpdatedOD.isEmpty()){
                        update toUpdatedOD;                        
                    }
                    //END of OD Updation  
                    
                    //Start of Installation Updation
                    //Update Install Removal/Reconnect quantity fields
                    updateInstallQuantity();
                    update new List<FS_Installation__c>{install};
                        //END of Installation Updation
                        
                        //Blank out Association Brandset Record Values of Install on Deselecting an OD
                        if(!deSelectedODList.isEmpty()){
                            blankOutABRecord(deSelectedODList);
                        }
                    //Populate Association Brandset Records of Install from already selected OD under the same IP if any AB record is having blank valus
                    if(!selectedODs.isEmpty()){
                        populateABRecordFromOldNewSelectedOD(selectedODs,true);
                    }
                    //Populate Association Brandset Records of Install from Newly selected OD under the same IP
                    if(!selectToUpdateODs.isEmpty()){
                        populateABRecordFromOldNewSelectedOD(selectToUpdateODs,false);
                    }
                    
                    if(assBrandSetMapUpdate!=FSConstants.NULLVALUE && !assBrandSetMapUpdate.isEmpty()){
                        update assBrandSetMapUpdate.values();                        
                    }
                    refreshPage=true;
                }                          
            }
            FS_OutletList=FSConstants.OBJ_LIST_NULL;
            editMode=false;
        }
        catch(Exception ex){                
            Database.rollback(savePosition);
			ApexPages.addMessages(ex);            
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,CLASSNAME,DELETEMETHOD,'FS_Installation__c',FSConstants.MediumPriority,ex,ex.getMessage());            
        }
        return null;
    }
    
    public void updateInstallQuantity(){
        
        install.FS_DispRequested1__c=install.FS_Platform1__c!=FSConstants.NULLVALUE?FSConstants.ZERO:null;
        install.FS_DispRequested2__c=install.FS_Platform2__c!=FSConstants.NULLVALUE?FSConstants.ZERO:null;
        install.FS_DispRequested3__c=install.FS_Platform3__c!=FSConstants.NULLVALUE?FSConstants.ZERO:null;
        //Populating Dispensers Removed/Disconnect and reconnected quantity fields on Installation
        for(FS_Outlet_Dispenser__c odRec:
            [select id,name,FS_Equip_Type__c,Relocated_Installation__c,FS_Other_PIA_Installation__c,Installation__c,FS_outlet__c from FS_Outlet_Dispenser__c 
             where (Relocated_Installation__c!=null or FS_Other_PIA_Installation__c!=null) and FS_outlet__c!=null and 
             FS_outlet__c=:install.FS_Outlet__c and (Relocated_Installation__c=:install.id or FS_Other_PIA_Installation__c=:install.id)]){
                 
                 if(install.FS_Platform1__c!=FSConstants.NULLVALUE && odRec.FS_Equip_Type__c==install.FS_Platform1__c){
                     install.FS_DispRequested1__c=(install.FS_DispRequested1__c!=FSConstants.NULLVALUE && install.FS_DispRequested1__c!=FSConstants.ZERO)?install.FS_DispRequested1__c+FSConstants.NUM_1:FSConstants.NUM_1;
                 }
                 else if(install.FS_Platform2__c!=FSConstants.NULLVALUE && odRec.FS_Equip_Type__c==install.FS_Platform2__c){
                     install.FS_DispRequested2__c=(install.FS_DispRequested2__c!=FSConstants.NULLVALUE && install.FS_DispRequested2__c!=FSConstants.ZERO)?install.FS_DispRequested2__c+FSConstants.NUM_1:FSConstants.NUM_1;
                 }
                 else if(install.FS_Platform3__c!=FSConstants.NULLVALUE && odRec.FS_Equip_Type__c==install.FS_Platform3__c){
                     install.FS_DispRequested3__c=(install.FS_DispRequested3__c!=FSConstants.NULLVALUE && install.FS_DispRequested3__c!=FSConstants.ZERO)?install.FS_DispRequested3__c+FSConstants.NUM_1:FSConstants.NUM_1;
                 }                                                  
             }
    }
    
    public void blankOutABRecord(List<FS_Outlet_Dispenser__c> deSelectedODList){
        for(FS_Outlet_Dispenser__c od:deSelectedODList){
            if(assBrandSetMap.containsKey(od.FS_Equip_Type__c)){
                final FS_Association_Brandset__c abRec=assBrandSetMap.get(od.FS_Equip_Type__c);
                abRec.FS_Brandset__c=FSConstants.ID_NULL;
                abRec.FS_NonBranded_Water__c=FSConstants.STR_NULL;
                associateIdList.add(abRec.id);
                assBrandSetMap.put(od.FS_Equip_Type__c, abRec);
                assBrandSetMapUpdate.put(od.FS_Equip_Type__c, abRec);
            }
        }
    }
    
     public void populateABRecordFromOldNewSelectedOD(List<FS_Outlet_Dispenser__c> listOfODs,Boolean old){
        for(FS_Outlet_Dispenser__c od:listOfODs){
            if(associateMap.containsKey(od.Id) && assBrandSetMap.containsKey(od.FS_Equip_Type__c) ){                
                final FS_Association_Brandset__c abRecOD=associateMap.get(od.Id);
                final FS_Association_Brandset__c abRec=assBrandSetMap.get(od.FS_Equip_Type__c);
                system.debug('associateIdList'+associateIdList);
                system.debug('abRec'+abRec);
                if(!old || ((abRec.FS_Brandset__c==FSConstants.NULLVALUE && abRec.FS_NonBranded_Water__c==FSConstants.NULLVALUE) || (!associateIdList.isEmpty() && associateIdList.contains(abRec.Id)))){                   
                    abRec.FS_Brandset__c=abRecOD.FS_Brandset__c;
                    abRec.FS_NonBranded_Water__c=abRecOD.FS_NonBranded_Water__c;
                    assBrandSetMap.put(od.FS_Equip_Type__c, abRec);
                    assBrandSetMapUpdate.put(od.FS_Equip_Type__c, abRec);
                }
            }
        }
    }
    
    public pageReference changeMode(){
       	deleteProcess();
            //FS_OutletList=FSConstants.OBJ_LIST_NULL;
        install = [select id,name,RecordType.name,RecordTypeId,FS_Outlet__r.id,Type_of_Dispenser_Platform__c,FS_Platform1__c,FS_Platform2__c,FS_Platform3__c,
                  	FS_DispRequested1__c,FS_DispRequested2__c,FS_DispRequested3__c,Overall_Status2__c FROM FS_Installation__c  where Id = :currentInstall.Id]; 
        
        for(FS_Association_Brandset__c assoBrandset : 
            [select Id,Name,FS_Installation__c,FS_Platform__c,Brandset_Name__c,FS_Outlet_Dispenser__c,FS_NonBranded_Water__c,FS_Brandset__c from FS_Association_Brandset__c 
                        where FS_Installation__c!=null and FS_Installation__c =: install.id order by FS_Platform__c]){           
            
        	assBrandSetMap.put(assoBrandset.FS_Platform__c,assoBrandset);
        } 
        getFSOutletDispensers();
        
        editMode=true;
        return null;
    }
    
    public pageReference cancel(){
      //  PageReference pageRef = new PageReference('/apex/FS_SelectOutletDispenser?Id='+install.Id);
      //  pageRef.setRedirect(true);
      // return pageRef;
        editMode=false;
        return null;
        
    }
    
    //Wrapper Class
    public class FS_Outlet_DispenserWrapper {
        public FS_Outlet_Dispenser__c con {get; set;}
        public Boolean selected {get; set;}
        public boolean isFormLinked {get;set;}
        public boolean previousSelection {get;set;}        
        
        public FS_Outlet_DispenserWrapper(final FS_Outlet_Dispenser__c recOD) {
            con = recOD;                                    
        }
    }
}