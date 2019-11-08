public with sharing class FS_SelectOutletDispenserRemoveRelocate {
    public static Integer ZERO = 0;
    public static String EQUIP_7K = FSConstants.RECTYPE_7k;
    public static String EQUIP_8K = FSConstants.RECTYPE_8k;
    public static String EQUIP_9K = FSConstants.RECTYPE_9k; 
    
    public static Boolean FALSE_VAL = false;
    public List <FS_Outlet_Dispenser__c> toUpdatedOD = new list <FS_Outlet_Dispenser__c> ();
    public List<Id> installationId=new List<Id>();
    public FS_Outlet_Dispenser__c tempOD {get; set;}
    public Date DisconnectDate {get;set;}
    public FS_Installation__c currentInstallation {get; set;}
    
    public FS_SelectOutletDispenserRemoveRelocate(final ApexPages.StandardController controller) {
        tempOD = new FS_Outlet_Dispenser__c();        
        currentInstallation = [SELECT RecordType.name,FS_Outlet__r.id, FS_of_7000_Series_Units_being_relocated__c , FS_of_8000_Series_units_being_relocated__c , FS_of_9000_Series_units_being_relocated__c, FS_Remove_Disconnect_Date__c FROM FS_Installation__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];         
    }    
    public List<FS_Outlet_DispenserWrapper> FS_OutletList {get; set;}
    
    public List<FS_Outlet_DispenserWrapper> getFS_Outlet_Dispensers() {        
        
        if(FS_OutletList == null) {
            FS_OutletList = new List<FS_Outlet_DispenserWrapper>();
            
            for(FS_Outlet_Dispenser__c c: [Select id,FS_ACN_NBR__c,  name ,Installation__r.id, FS_outlet__r.name , Planned_Remove_Date__c,FS_Date_Installed2__c , Relocated_Installation__c,
                                           FS_Serial_Number2__c,FS_Dispenser_Location__c,FS_User_Defined_Location__c, FS_Valid_Fill__c, FS_Dispenser_Type2__c, FS_Equip_Type__c, FS_Removal_Request_Submitted__c
                                           from FS_Outlet_Dispenser__c where FS_outlet__r.Id =: currentInstallation.FS_Outlet__r.id and FS_IsActive__c=true]) {
                                               
                                               FS_OutletList.add(new FS_Outlet_DispenserWrapper(c));
                                           }
        }
        return FS_OutletList ;
    }
    
    public PageReference DeleteProcess() {
        
        //We create a new list of records that we be populated only if they are selected
        final List<FS_Outlet_Dispenser__c> selectedODs = new List<FS_Outlet_Dispenser__c>();
        
        
        
        for(FS_Outlet_DispenserWrapper cCon: getFS_Outlet_Dispensers()) {
            
            if(DisconnectDate!=null  && (currentInstallation.RecordType.Name==Label.IP_Relocation_I4W_Rec_Type 
                                         || currentInstallation.RecordType.Name==Label.IP_Removal_Rec_Type 
                                         || currentInstallation.RecordType.Name==Label.IP_Replacement_Rec_Type) && cCon.selected == true){
                                             
                                             
                                             selectedODs.add(cCon.con);
                                             
                                         }   
            if(DisconnectDate==null && (currentInstallation.RecordType.Name==Label.IP_Relocation_I4W_Rec_Type
                                        || currentInstallation.RecordType.Name==Label.IP_Removal_Rec_Type 
                                        || currentInstallation.RecordType.Name==Label.IP_Replacement_Rec_Type) ){
                                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Select Disconnect Date to proceed'));
                                            return null;
                                            break;
                                        }          
            
        }
        
        // Now we have our list of selected records 
        
        
        toUpdatedOD.clear(); //Removing previously stored values
        
        
        final List<FS_Installation__c> installationList=[select id,FS_of_7000_Series_Units_being_relocated__c,FS_of_8000_Series_Units_being_relocated__c,FS_of_9000_Series_Units_being_relocated__c from FS_Installation__c where id =:currentInstallation.id  limit 1];
        if(installationList.size()> ZERO){
            
            for(FS_Outlet_Dispenser__c oDisp1: selectedODs) {
                for(FS_Installation__c inst :installationList){
                    if(oDisp1.FS_Removal_Request_Submitted__c==FALSE_VAL){
                        if(oDisp1.FS_Equip_Type__c ==EQUIP_7K){
                            if(inst.FS_of_7000_Series_Units_being_relocated__c == null || inst.FS_of_7000_Series_Units_being_relocated__c == 0) {
                                inst.FS_of_7000_Series_Units_being_relocated__c = 1 ; 
                            }      
                            else {
                                inst.FS_of_7000_Series_units_being_relocated__c += 1; 
                            }
                        }
                        if(oDisp1.FS_Equip_Type__c ==EQUIP_8K){
                            if(inst.FS_of_8000_Series_Units_being_relocated__c == null || inst.FS_of_8000_Series_Units_being_relocated__c == 0) {
                                inst.FS_of_8000_Series_Units_being_relocated__c = 1 ; 
                                
                            }
                            else {
                                inst.FS_of_8000_Series_units_being_relocated__c += 1;
                                
                            }
                        }
                        if(oDisp1.FS_Equip_Type__c ==EQUIP_9K){
                            if(inst.FS_of_9000_Series_units_being_relocated__c == null || inst.FS_of_9000_Series_units_being_relocated__c == 0) {
                                inst.FS_of_9000_Series_units_being_relocated__c = 1 ; 
                                
                            }
                            else {
                                
                                inst.FS_of_9000_Series_units_being_relocated__c+= 1;
                                final Decimal tempUnit=inst.FS_of_9000_Series_units_being_relocated__c;
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }
        }
        try{
            
            //Update the Installation Record
            final Database.SaveResult[] updateOp= Database.update(installationList,false);
            for(Database.SaveResult sr: updateOp){
                if(sr.isSuccess()){                    
                    
                }
                else{
                    system.debug('error  '+sr.getErrors());
                    
                }
            }           
        }
        catch(Exception e){
            system.debug('Error message::' +e);
        }
        
        
        
        for(FS_Outlet_Dispenser__c oDisp: selectedODs) {
            
            oDisp.Planned_Remove_Date__c = DisconnectDate ;
            oDisp.FS_Removal_Request_Submitted__c=true;
            oDisp.Relocated_Installation__c=currentInstallation.Id;
            toUpdatedOD.add(oDisp); 
            DisconnectDate=FSConstants.DATE_NULL;
            
        }
        
        //Updating OD records   
        if(toUpdatedOD.size()>ZERO){
            update toUpdatedOD;
        }
        
        
        
        
        
        
        final map<String,String> numberList = new map<String,String>(); //added by Bhanu
        final Set<ID> dispeserIDSet=new set<ID>();
        for(FS_Outlet_Dispenser__c dispenserObj : toUpdatedOD) {
            if(dispenserObj.FS_Serial_Number2__c != null
               && dispenserObj.FS_Date_Installed2__c == null
               && dispenserObj.FS_Status__c == null
               && dispenserObj.FS_Equip_Type__c == '7000'){
                   
                   numberList.put(dispenserObj.FS_Serial_Number2__c,dispenserObj.FS_ACN_NBR__c);
                   dispeserIDSet.add(dispenserObj.id);
               }
        }
        
        
        if(dispeserIDSet.size() > ZERO ){
            FSFETNMSConnector.deleteMasterAssetData(dispeserIDSet);
        }
        
        FS_OutletList =null; 
        return null;
    }
    
    
    
    
    
    public class FS_Outlet_DispenserWrapper {
        public FS_Outlet_Dispenser__c con {get; set;}
        public Boolean selected {get; set;}
        
        
        public FS_Outlet_DispenserWrapper(final FS_Outlet_Dispenser__c c) {
            con = c;
            selected = false;
        }
    }
}