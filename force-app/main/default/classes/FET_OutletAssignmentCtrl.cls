/*************************
(c) 2015 Appirio, Inc.
Controller for VisualForce Page FET_OutletAssignment- Shows the clone of
 Outlet Description record and make the reference record inactive.
19 June2015       Rohit Mathur
**************************/ 
/*************************
Last Modified By: Lavanya & Team, Last Modified Date: 26th July 2016
Methods:  save()
Description : Modified Save method to Extend assign to 
              outlet functionality for relinking 
**/
/**           
Reference Info: Fet International Requirement #B-14998
**************************/ 
/*************************
Last Modified By : Reshma & Team ,Last Modified Date: 20th Jun 2017  
Description :Modified to prevent cloning OD when the 
             assign to outlet happened on existing record.
Methods: save(), removeAssignToOutlet()
**/
/**
Reference Info : Fet International R1 2017     
**************************/ 

public class FET_OutletAssignmentCtrl {
                  
    public Id outletPrev ;  
    public String response; 
    public string serialSAP ;     
    public Set<Id> outletDispIDs =new set<Id>(); 
    public static final ID ID_NULL = null;
    public static final FS_Outlet_Dispenser__c OUTLET_REF_NULL = null;  
    private PageReference reference;        
    public FS_Outlet_Dispenser__c outletRef {get;set;}
    public FS_Outlet_Dispenser__c cloneOutletDispenser{get;set;}
    public FS_Outlet_Dispenser__c out{get;set;}
    public Id currentOutletId {get;set;}
    public boolean displayPopup {get; set;}
    public boolean displayPopup1 {get; set;}
    public boolean displayPopup2 {get; set;} 
    public boolean displayPopup3 {get; set;}    
    // Constructor method used when the page is in clone mode.
    //  @param ApexPages.StandardController
    //  @return none.
    public FET_OutletAssignmentCtrl(final ApexPages.StandardController controller) {
    
        currentOutletId = ApexPages.currentPage().getParameters().get('id');
        cloneOutletDispenser = new FS_Outlet_Dispenser__c ();
        out  = new FS_Outlet_Dispenser__c ();
        outletRef = new FS_Outlet_Dispenser__c();   
        if(currentOutletId != ID_NULL){
        
            outletRef = [Select isDefaultOutlet__c, Weight_unit_of_measure__c, Weight__c, Warehouse_Details__c, Warehouse_Name__c, Warehouse_Country__c,
                                 SystemModstamp, Shipping_Form__c, Send_Create_Request__c, Removed_Returned_Date__c, Relocated_Installation__c, RecordTypeId,Ownership__c, Ownership_Type__c, Re_Manufactured__c, Planned_Remove_Date__c, PO_Number__c, Outlet_Zip_Code__c,
                                 Outlet_Street_Address__c, Outlet_State_Province__c, Outlet_Country__c, Outlet_City__c, Name,
                                 LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, Item_code__c, IsDeleted, 
                                 Installation__c, Installation2__c, Install_Date_Missed__c, Id, IC_Code__c, Head_Quarter_Name__c,
                                 Head_Quarter_ID__c, Fav_Mix__c, FS_Winterize_State_Date__c, FS_Water_Hide_Show_Overridden__c,
                                 FS_Water_Hide_Show_Effective_Date__c, FS_Water_Button__c, FS_Water_Button_New__c, FS_Wake_Up_State_Date__c,
                                 FS_Valid_Fill__c, FS_Valid_Fill_Settings_Overridden__c, FS_Valid_Fill_Settings_Effective_Date__c,
                                 FS_Valid_Fill_New__c, FS_Uses_Portion_Control__c, FS_User_Defined_Location__c, FS_Update_to_AW_Request__c,
                                 FS_Un_Enrolled_State_Date__c, FS_TimeZone__c, FS_Status__c, FS_Spicy_Cherry__c, FS_Spicy_Cherry_Overridden__c,
                                 FS_Spicy_Cherry_New__c, FS_Spicy_Cherry_Effective_Date__c, FS_Soft_Ice_Manufacturer__c, FS_Soft_Ice_Adjust_Flag__c,
                                 FS_Serial_Number__c, FS_Serial_Number2__c, FS_Selected_Brands__c, FS_STRAS__c, FS_SAP_ID__c, FS_Removal_Request_Submitted__c,
                                 FS_REGIO__c, FS_Promo_Enabled__c, FS_Promo_Enabled_Overridden__c, FS_Promo_Enabled_New__c, FS_Promo_Enabled_Effective_Date__c,
                                 FS_Postal_Code__c, FS_Post_Installation_Status__c, FS_Planned_Install_Date__c,
                                 FS_Pending_Migration_to_AW__c, FS_Outlet__c, FS_ORT01__c, FS_Name1__c, FS_Migration_to_AW_Required__c,
                                 FS_Migration_to_AW_Complete__c, FS_LTO__c, FS_LTO_Overridden__c, FS_LTO_New__c, FS_LTO_Effective_Date__c, FS_IsInstalled__c,
                                 FS_IsActive__c, FS_IceType__c, FS_Hibernate_State_Date__c, FS_FAV_MIX__c, FS_FAV_MIX_Overridden__c, FS_FAV_MIX_New__c,
                                 FS_FAV_MIX_Effective_Date__c, FS_Equip_Type__c, FS_Equip_Sub_Type__c, FS_Enrolled_State_Date__c,
                                 FS_Dispenser_Type__c, FS_Dispenser_Type2__c, FS_Dispenser_Location__c, FS_Date_Transfer__c, FS_Date_Status__c,
                                 FS_Date_Replaced__c, FS_Date_Removed__c, FS_Date_Relocated__c, FS_Date_Installed__c, FS_Date_Installed2__c,
                                 FS_Data_Transfer_Date__c,FS_Dasani_Settings_Overridden__c, FS_Dasani_Settings_Effective_Date__c,
                                 FS_Dasani_New__c, FS_DL_Indicator__c, FS_Cup_Sizes__c, FS_Country_Key__c, FS_Code__c, FS_CE_Enabled__c, 
                                 FS_CE_Enabled_Overridden__c, FS_CE_Enabled_New__c, FS_CE_Enabled_Effective_Date__c, FS_Brand_Selection_Value_Effective_Date__c, 
                                 FS_AttributesSelected__c, FS_Asset_Number__c, FS_Agitated_Selection_Value_Overridden__c, FS_Actual_Remove_Date__c, FS_ACN_NBR__c, 
                                 FS_7000_Series_Static_Selection_New__c, FS_7000_Series_Static_Brands_Selections__c, FS_7000_Series_Static_Brands_Overridden__c, FS_7000_Series_Hide_Water_Overridden__c, FS_7000_Series_Hide_Water_Effective_Date__c,
                                 FS_7000_Series_Hide_Water_Button__c, FS_7000_Series_Hide_Water_Button_New__c, FS_7000_Series_Brands_Selection_New__c,
                                 FS_7000_Series_Brands_Option_Selections__c, FS_7000_Series_Agitated_Selections_New__c,
                                 FS_7000_Series_Agitated_Brands_Selection__c, FSInt_Dispenser_Type__c, FSCombinedId__c, Enable_Promo__c,
                                 Enable_CE__c, Dispenser_Notes__c, CreatedDate, CreatedById, Country__c, Chain_Name__c, Chain_ID__c, Brands_Selected__c,
                                 Brand_Set__c,  RecordType.Name,Serial_SAP_ID__c, FS_Outlet__r.FS_SAP_ID__c 
                            From FS_Outlet_Dispenser__c 
                            WHERE ID =: currentOutletId];
                             outletDispIDs.add(currentOutletId);
            system.debug('outletList--'+outletRef);
        }
        
        if(outletRef != OUTLET_REF_NULL){
        cloneOutletDispenser= outletRef.clone(false, false, false, false);
        //cloneOutletDispenser.FS_Outlet__c = null;
        outletPrev = outletRef.FS_Outlet__c ;
        }
    }
    
    //  Save the record and redirect the page to cloned record detail page.
    //  Set the current record as active.
    //  Make the refrence record as in-active.
    //  Return pagerefrence of recently cloned record.
    
    public void save(){
       
        List<FS_Outlet_Dispenser__c> ListOD = new List<FS_Outlet_Dispenser__c>();
             
        try{
         //FET-International Relinking - Extend existing Assign to Outlet code to 
         //delete record for old serial/ACN if OD is active and status NOT Enrolled
            
            if(outletRef.FS_Status__c==Label.OD_Enrolled_Status){
                    displayPopup =true;     
            }
            else if(outletRef.FS_Status__c==Label.Assigned_to_Outlet){
                  displayPopup2=true;
                
            }
            else{
        
                    System.debug('Inside remove from outlet');
                    displayPopup2= false;
                    system.debug('Current Outlet:' +outletPrev);
                    system.debug('New outlet:' +outletRef.FS_Outlet__c);
                    system.debug('current SAP Id:' +outletRef.FS_SAP_ID__c);
                    final Account outletSap = [select FS_SAP_ID__c from Account where Id = :outletRef.FS_Outlet__c];
                    system.debug('New SAP Id:' +outletSap.FS_SAP_ID__c);
                    
                	system.debug('serial no ' + outletRef.FS_Serial_Number2__c);
                    final List<FS_Outlet_Dispenser__c> disp = [SELECT Id,Warehouse_Details__c, Serial_SAP_ID__c ,Name, FS_Status__c, FS_Serial_Number2__c, FS_SAP_ID__c, FS_Outlet__c, FS_IsActive__c From FS_Outlet_Dispenser__c WHERE FS_Serial_Number2__c  =: outletRef.FS_Serial_Number2__c and FS_SAP_ID__c = : outletSap.FS_SAP_ID__c Limit 1];
                	system.debug(disp);
                    if(!disp.isEmpty())
                    {
                        disp[0].FS_IsActive__c = true;
                        disp[0].FS_Status__c = FSConstants.dispenserStatusAssigned;
                        system.debug('Inside clone mathching ');               
    
                        outletRef.FS_IsActive__c = false;                        
                        outletRef.FS_Outlet__c = outletPrev;
                        ListOD.add(outletRef);
                        ListOD.add(disp[0]);
                        update ListOD;   
                        displayPopup3= true;
                    } 
                    else
                    {         
                        system.debug('Inside clone not matching else');                                                 
                        system.debug('changed outlet Id' +outletRef.FS_Outlet__c);
                        system.debug('cloned outlet before assigning' +cloneOutletDispenser.FS_Outlet__c);
                        
                        cloneOutletDispenser.Serial_SAP_ID__c='';
                        cloneOutletDispenser.FS_Outlet__c = outletRef.FS_Outlet__c;
                        cloneOutletDispenser.FS_IsActive__c = true;
                        cloneOutletDispenser.FS_Status__c = FSConstants.dispenserStatusAssigned;
                        cloneOutletDispenser.Planned_Remove_Date__c = null;
                        cloneOutletDispenser.Install_Date_Missed__c = false;
                        system.debug('cloned outlet after assigning' +cloneOutletDispenser.FS_Outlet__c);
                        Insert cloneOutletDispenser;
                          
                        outletRef.FS_IsActive__c = false;                        
                        outletRef.FS_Outlet__c = outletPrev;
                        update outletRef;  
                        displayPopup1= true; 
                    }                  
                }
        }catch(exception e){
            system.debug('Exception :' + e.getMessage());
        }
    }
    
    public void removeAssignToOutlet(){
            Savepoint savePoint = Database.setSavepoint();
            try{
                  System.debug('Inside remove from outlet');
                  displayPopup2= false;
                  system.debug('Current Outlet:' +outletPrev);
                  system.debug('New outlet:' +outletRef.FS_Outlet__c);
                  system.debug('current SAP Id:' +outletRef.FS_SAP_ID__c);
                  final Account outletSap = [select FS_SAP_ID__c from Account where Id = :outletRef.FS_Outlet__c];
                  system.debug('New SAP Id:' +outletSap.FS_SAP_ID__c);
                
                  List<FS_Outlet_Dispenser__c> disp = [SELECT Id,Warehouse_Details__c, Serial_SAP_ID__c ,Name, FS_Status__c, FS_Serial_Number2__c, FS_SAP_ID__c, FS_Outlet__c, FS_IsActive__c From FS_Outlet_Dispenser__c WHERE FS_Serial_Number2__c  =: outletRef.FS_Serial_Number2__c and FS_SAP_ID__c = : outletSap.FS_SAP_ID__c Limit 1];
                  if(!disp.isEmpty())
                  {
                      disp[0].FS_IsActive__c = true;
                      disp[0].FS_Status__c = FSConstants.dispenserStatusAssigned;
                      disp[0].Planned_Remove_Date__c = null;
                      system.debug('Inside clone mathching ');               

                      inActivateAndUpdateODStatus();
                      update disp[0];   
                      displayPopup3= true;
                  } 
                  else
                  {          
                      system.debug('Inside clone not matching else');                                                 
                      system.debug('changed outlet Id' +outletRef.FS_Outlet__c);
                      system.debug('cloned outlet before assigning' +cloneOutletDispenser.FS_Outlet__c);
                      cloneOutletDispenser.FS_Outlet__c = outletRef.FS_Outlet__c;
                      cloneOutletDispenser.FS_IsActive__c = true;
                      cloneOutletDispenser.FS_Status__c = FSConstants.dispenserStatusAssigned;
                      cloneOutletDispenser.Planned_Remove_Date__c = null;
                      cloneOutletDispenser.Install_Date_Missed__c = false;
                      cloneOutletDispenser.Serial_SAP_ID__c='';
                      system.debug('cloned outlet after assigning' +cloneOutletDispenser.FS_Outlet__c);
                      inActivateAndUpdateODStatus();  
                      displayPopup1= true; 
                      Insert cloneOutletDispenser;
                  }
                  system.debug('cloneOutletDispenser Id' +cloneOutletDispenser.Id);                                     
                  
    }catch(exception e){
        system.debug('Exception :' + e.getMessage());
        Database.rollback(savePoint);
    }
    }
    
    public void inActivateAndUpdateODStatus(){
        outletRef.FS_IsActive__c = false;
        outletRef.FS_Status__c = Label.Removed_from_Outlet;
        outletRef.FS_Outlet__c = outletPrev;
        update outletRef;        
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }
    
    public void closePopup1() {        
        displayPopup1 = false;    
    }
    public void closePopup2() {        
        displayPopup2 = false;    
    }
    public void closePopup3() {        
        displayPopup3 = false;    
    }
     public PageReference redirectPopup(){
           displayPopup = false;
           displayPopup1 = false;
           displayPopup2 = false;
           displayPopup3 = false;
           if(cloneOutletDispenser.Id!= ID_NULL){
               reference =  new PageReference('/'+cloneOutletDispenser.Id);
               return reference;
           }else{
               reference =  new PageReference('/'+outletRef.Id);
               return reference;
           }
           }
           
      public void redirectPopup1(){
           displayPopup2 = false;
           }
}