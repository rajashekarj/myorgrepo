/*******************************
Created BY: Lavanya & Team
Purpose: Controller for VisualForce Page FETOutletRemove- Remove functionality for outlet dispenser.
Date: 26th July,2016
Methods: Remove();closePopup();closePopup1();closePopup2();redirectPopup();


******************************/
public class Fet_RemoveFromOutlet {
    
    public Id curODID;
    Public String response;
    public Set<Id> OutletDispenserIds =new set<Id>();
    public PageReference reference;
    public FS_Outlet_Dispenser__c outletRef {get;set;} 
    public Id currentOutletId {get;set;}   
    public boolean displayPopup {get; set;}
    public boolean displayPopup1 {get; set;}
    public boolean displayPopup2 {get; set;}
    public boolean displayPopup3 {get; set;}
    public boolean displayPopup4 {get; set;}
    
    public Fet_RemoveFromOutlet(ApexPages.StandardController controller) {
        currentOutletId = ApexPages.currentPage().getParameters().get('id');
        curODID = currentOutletId;
        outletRef = new FS_Outlet_Dispenser__c();
        if(currentOutletId != FSConstants.NULLVALUE){
            outletRef = [Select isDefaultOutlet__c, Weight_unit_of_measure__c, Weight__c, Warehouse_Name__c, Warehouse_Country__c,
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
                         Brand_Set__c,  RecordType.Name
                         From FS_Outlet_Dispenser__c 
                         WHERE ID =: currentOutletId];
        }
    }
    
    public void remove(){
        
        try{  
            if(outletRef != null && outletRef.FS_IsActive__c){
                String OD_Unreg_Status= Label.OD_Unregister_status;
                String OD_Reg_Status=Label.OD_Register_Status;
                if(OD_Unreg_Status.contains(outletRef.FS_Status__c)){
                    outletRef.FS_IsActive__c = false;
                    displayPopup = true;
                    update outletRef;
                    
                }
                else if(outletRef.FS_Status__c==Label.Assigned_to_Outlet){
                    outletRef.FS_IsActive__c = false;
                    outletRef.FS_Status__c = Label.Removed_from_Outlet;
                    update outletRef;
                    OutletDispenserIds.add(outletRef.id);
                    displayPopup1 = true;
                }
                else if(OD_Reg_Status.contains(outletRef.FS_Status__c)) {
                    
                    outletRef.FS_IsActive__c = false;
                    outletRef.FS_Status__c = Label.Removed_from_Outlet;
                    update outletRef;
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //Recipients
                    List<String> sendTo = new List<String>();
                    List<String> ccTo = new List<String>();
                    sendTo.add(Label.AW_Support_Mail_ID);
                    ccTo.add(UserInfo.getUserEmail());
                    mail.setToAddresses(sendTo);
                    mail.setCcAddresses(ccTo);
                    mail.setSenderDisplayName('Coca-Cola');
                    //Subject
                    mail.setSubject('Delete Enrollment- '+ outletRef.FS_Serial_Number2__c+ ' ACN # ' + outletRef.FS_ACN_NBR__c );
                    //Body
                    String body=  Label.Email_Subject;
                    body=body+'<br>'+ Label.Dispenser_with_serial_no
                        + '<br> <br> <br> Thank you.';
                    
                    mail.setHtmlBody(body);                               
                    try{
                        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        if(resultMail[0].isSuccess()){     
                            system.debug('mail sent');
                            response = 'email sent successfully';  
                        }
                        else{
                            response = resultMail[0].getErrors().get(0).getMessage();
                        }
                    }catch(System.EmailException ex){
                        response = ex.getMessage();
                    }catch(exception e){
                        System.debug('Exception in Outer try catch(): ' + e.getMessage());
                    }   
                    displayPopup2 = true;
                }
                else{
                    displayPopUp4=true;
                }
            }
            else{
                displayPopUp3=true;
            }
        }catch(exception e){
            system.debug('Exception :' + e.getMessage());
        }   
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }
    
    public void closePopup1(){
        displayPopup1 = false;
    }  
    
    public void closePopup2(){
        displayPopup2 = false;
    }
    public void closePopup3(){
        displayPopup3 = false;
    }
    public void closePopup4(){
        displayPopup4 = false;
    }  
    public PageReference redirectPopup(){
        displayPopup = false;
        displayPopup1 = false;
        displayPopup2 = false;
        displayPopup3 = false;
        displayPopup4 = false;
        reference =  new PageReference('/'+curODID);
        return reference;
    }
}