/*********************************************************************************************************
Name         : FSCreateExecutionPlanExtension
Created By   : Pallavi Sharma (Appiro)
Created Date : Sep 24, 2013
Usage        : Extension for FSCreateExecutionPlan Page
Modified By  : Ashish Sharma 6th October, 2014 Ref - T-324029
Modified By  : Vandana Kumari 9th October, 2014 Ref - T-324805 , T-325196
Modified By  : Deepti Maheshwari 10th December, 2014 Ref - T-339451
Modified By  : Deepti Maheshwari 19th December, 2014 Copy CIF Data to Execution plan
Modified By  : Deepti Maheshwari 19th January , 2015 I-145989
Modified By  : Deepti Maheshwari 20th January , 2015 // Uncommented to fix issue I-146068
Modified By  : Deepti Maheshwari 10th April, 2015 //// Fix for I-845
Modified for : Venkata  13 th Feb 2017 		FET 4.0 project 
Modified for : Venkata  21 th DEC 2017 		FET 5.0 project
***********************************************************************************************************/
public with sharing class FSCreateExecutionPlanExtension {  
    public static final String SPACE='';
    public static final String COLON=';';
    public static final String PERCENT='%';
    public static final String SLASH='\'';
    public static final String CLONE='clone';
    public static final String NEWEXE='new';
    public static final String ADDEXIST='addExisting';
    public static final String EXEOBJNAME='FS_Execution_Plan__c';
    public static final String HYPHEN='-';
    public static final Integer ZEROVALUE=0;
    public static final Integer ONEVALUE=1;
    public static final String FETVALUE='FET'; 
    public static final String CLASSNAME='FSCreateExecutionPlanExtension';
    public static final String SEVEARITY='Medium';
    public static final String DISTRIBUTOR='Distributor';
    public static final Id IDNULL=null;
    public String platformType=SPACE;    
    public Account accHeadquarter; 
    public Id accId;
    public Map<id,FS_CIF__c> mapOutletWrap;//OCR
    public CIF_Header__c customerInputHQ{get;set;}
    public List<FS_Installation__c> lstInstallation{get;set;}//OCR 
    public String selectedExecutionPlan{get;set;}
    public String selectedPlanType{get;set;}
    public List<FS_Execution_Plan__c> lstExecutionPlan{get;set;}
    public String executionPlanName{get;set;}
    public String chainName{get;set;}
    public String headquarterName{get;set;}   
    public String executionPlanNo{get;set;}       
    public String currentCIFId {get;set;}  
    public List<FS_CIF__c> cifList{get;set;}
    public List<FS_CIF__c> cifListChecked{get;set;}
    public List<FS_CIF__c> cifForClonedHeader{get;set;}
    public Set<Id> outletsSet{get;set;}
    public Boolean displayPopup{get;set;}
    public Boolean displayButton{get;set;}
    
    public CIF_Header__c cloneHead{get;set;}   
    public static Object nullVal()
    {return null;}
    
    /*****************************************************************
Method: platformValues
Description: platformValues method is to store all the platform values from all selected CIF into a string	
New:Created as part of FET 4.0
Modified: Venkat for FET 5.0 project US-4
*******************************************************************/
    public void platformValues(final List<FS_CIF__c> cifListChecked){
        //FET 5.0
        
        String options=platformType;                                     
        final Set<String> optionSetMain=new Set<String>();
        
        for(FS_CIF__c ow : cifListChecked){           
            if(ow.FS_Platform1__c!=nullVal()){  optionSetMain.add(ow.FS_Platform1__c);  }
            if(ow.FS_Platform2__c!=nullVal()){  optionSetMain.add(ow.FS_Platform2__c);  }
            if(ow.FS_Platform3__c!=nullVal()){  optionSetMain.add(ow.FS_Platform3__c);  }        
        }
        for(String typeValue:optionSetMain){                    
            options+=typeValue+COLON; 
        }
        if(!string.isBlank(options)){
            options=options.removeEnd(COLON);
            platformType=options;
        }
    }
    //FET 5.0
    
    
    //Constructor
    //Modified as Part of FET 4.0 to query all necessary records at once
    //CIF Header,CIF,Outlet records 
    public FSCreateExecutionPlanExtension (final Apexpages.Standardcontroller sct){ 
        
        displayButton = true;
        displayPopup = false;
        outletsSet=new Set<Id>();        
        cifListChecked=new List<FS_CIF__c>();
        cifForClonedHeader=new List<FS_CIF__c>();
        cloneHead=new CIF_Header__c();        
        accId = Apexpages.currentPage().getParameters().get('Id');
        accHeadquarter = Database.query(FSUtil.getSelectQuery('Account')+' WHERE ID=:accId');
        currentCIFId = Apexpages.currentPage().getParameters().get('currentCIFId'); 
        
        try{
            //soql of CIF header record details
            customerInputHQ=[select id,Name,FSCOM__r.UserId__c,FS_EP__c,FS_FPS__c,FS_HQ__c,FS_HQ__r.Name,FS_Original_CIF_Head__c,FS_Sales_Rep_Name__r.UserId__c,FS_Status__c,FS_Version__c from CIF_Header__c where id=:currentCIFId];        
            //Soql of all the chaid CIF linked to the CIF Header with the necessary fields
            cifList=[SELECT Id,FS_EP_Check__c,FS_Account__c,FS_Site_Prep_Contract_Received__c,FS_Customer_s_disposition_after_review__c,FS_Reason_if_applicable__c,FS_Customer_disposition_Submit_DateTime__c,
                     FS_Customer_s_Disposition_Submitted_by__c,FS_Davaco_Order_Entered__c,FS_Davaco_Order_Entered_By__c,FS_Davaco_Order_Entered_Date_Time__c,
                     //FS_JDE_Doc__c,  //Commented as part of FET-7.0 FNF 722
                     FS_Work_Order_WO__c,FS_SA_Scheduled_On_Date__c,FS_SA_Completed_Date__c,FS_SA_Scheduled_Contacted_Date__c,
                     FS_SA_Scheduled_By__c,FS_Date_GFE_Posted__c,FS_Requested_Install_Period__c,FS_Requested_Install_Date__c,
                     FS_Customers_Ice_Fill_Policy__c,FS_Top_Off_Feature__c,FS_Day_AM_or_Night_PM_Installation__c,FS_Contractor_Coordination_to_be_done_by__c,
                     FS_On_Boarding_Contact__c,FS_OB_Trainer__c,FS_Second_SA_Scheduled_Contacted_Date__c,
                     FS_Time_to_call_home__c,FS_On_Boarding_Days_after_Install__c,FS_Select_On_Boarding_Start_Time__c,FS_Brandset1__c,FS_Brandset2__c,FS_Brandset3__c,FS_Outlet_Contact__c,
                     FS_General_Contractor__c,FS_Contractor_Contact__r.Name,FS_Contractor_Contact__r.Email,FS_Contractor_Contact__r.Phone,
                     FS_Second_Site_Survey_Reason__c,Water_Filter_Installer_Name__r.name,Water_Filter_Installer_Name__r.Phone,Water_Filter_Installer_Name__r.Email,
                     FS_NewRemodelOutletOnlyProjectedOpening__c,FS_NewRemodelOutletOnlyProjectedFireUp__c,FS_NewRemodelOutletOnlyLineInstallation__c,Any_known_construction_needs__c,
                     FS_NewRemodelOutletOnlyEquipmentInstall__c,FS_Ice_maker_and_water_filter_comments__c,FS_On_boarding_time_requested__c,
                     FS_Who_will_install_Water_Filter__c,FS_Water_Filter_Contact_Name__r.Email,FS_Water_Filter_Contact_Name__r.Phone,FS_Water_Filter_Contact_Name__r.Name,FS_Platform1__c,FS_Water1__c,FS_Water2__c,FS_Water3__c,FS_Platform2__c,FS_Platform3__c,
                     FS_Training_Comment__c,FS_Platform1_Qty__c,FS_Platform2_Qty__c,FS_Platform3_Qty__c,
                     FS_Water_Filter_Model_no__c,FS_What_type_of_outlet_install__c,FS_What_type_of_Site_Assessment__c,FS_Select_Site_assessment_contact__r.Name,
                     FS_Any_Crew_Serve_Dispensers__c,FS_Select_Site_assessment_contact__r.FS_Title__c,FS_Select_Site_assessment_contact__r.Phone,FS_Select_Site_assessment_contact__r.FS_Alternate_Phone_Cell__c,
                     FS_Select_Site_assessment_contact__r.Email,FS_Ancillary_equipment_needed__c,FS_Dispenser_Comments__c,FS_Secondary_Site_Assessment_Contact__r.Email,
                     FS_Secondary_Site_Assessment_Contact__r.Name,FS_Secondary_Site_Assessment_Contact__r.FS_Title__c,FS_Secondary_Site_Assessment_Contact__r.Phone,FS_Secondary_Site_Assessment_Contact__r.FS_Alternate_Phone_Cell__c,
                     FS_Cartridge_Payment_Method__c,FS_Program_Fee_Payment_Method__c,FS_DryAccount_curently_no_dispnsd_accnt__c,FS_Product_Comment__c,
                     FS_Cartridge_Order_Method__c,FS_Total_VPO__c,FS_Order_Administrator__r.Name,FS_SA_Rescheduled_On_Date__c,FS_No_of_TopMountIceMaker1__c,FS_No_of_TopMountIceMaker2__c,FS_No_of_TopMountIceMaker3__c,
                     FS_Order_Administrator__r.FS_Title__c,FS_Order_Administrator__r.Email,FS_Order_Administrator__r.Phone,FS_Order_Standard_User__r.Name,
                     FS_Order_Standard_User__r.FS_Title__c,FS_Order_Standard_User__r.Email,FS_Order_Standard_User__r.Phone,FS_Name_of_Sweetener_Distributor__c,
                     FS_RemoveAllFTNLegacyServeDispensers__c,FS_Water_Filter_MFG__c,FS_SA_Unable_to_Complete_Reason__c,FS_Second_SA_Rescheduled_Reason__c,FS_SA_Rescheduled_Reason__c,
                     FS_Ancillary_equipment_to_remain_on_site__c,FS_ValidFill_Option__c,FS_Second_Site_Assessment_Completed_Date__c,FS_Second_SA_Scheduled_Date__c,FS_Second_SA_Scheduled_By__c,FS_Second_SA_Incomplete_reason__c,FS_Second_Work_Order_WO__c,
                     //FS_Second_JDE_Doc__c,  //Commented out as part of FET-7.0 FNF 722
                     FS_Second_Davaco_Order_Entered_Date_Time__c,FS_Second_Davaco_Order_Entered_By__c,FS_Second_Davaco_Order_Entered__c,FS_Second_Site_Prep_Contract_Received__c,FS_Second_GFE_Posted_Date__c,FS_Requested_Channel__c,FS_Distributor_Name_City_ST__c,FS_Distributor_City__c,FS_Distributor_State__c,FS_Mail_to_Zip_Code__c,FS_Mail_to_State__c,FS_Mail_to_City__c,FS_Delivery_Method__c,   
                     FS_Cup_Name_1__c,FS_Cup_Name_2__c,FS_Cup_Name_3__c,FS_Cup_Name_4__c,FS_Cup_Name_5__c,FS_Cup_Name_6__c,FS_Size_1__c,FS_Size_2__c,FS_Second_SA_Rescheduled_Date__c,
                     FS_Size_3__c,FS_Size_4__c,FS_Size_5__c,FS_Size_6__c,FS_Fluid_Ounces_1__c,FS_Fluid_Ounces_2__c,FS_Fluid_Ounces_3__c,FS_Fluid_Ounces_4__c,FS_Fluid_Ounces_5__c,FS_Fluid_Ounces_6__c,FS_Installation__c,
                     FS_Mail_to_Address__c,FS_Date_SA_to_be_completed_by__c,FS_Bill_to_Phone__c,FS_Is_Bill_to_Address_Same_as_Ship_to__c,FS_Bill_to_Zip_Code__c,FS_Bill_to_State__c,FS_Bill_to_City__c,FS_Bill_to_Country__c,FS_Bill_to_Address__c,FS_General_Contractor_Name__c,
                     Does_Install_Involve_RO4W__c,FS_RO4W1__c,FS_RO4W2__c,FS_RO4W3__c,FS_Does_Install_Involve_a_Replacement__c,FS_Replacement_1__c,FS_Replacement_2__c,FS_Replacement_3__c,FS_RO4W1__r.Name,FS_RO4W2__r.Name,FS_RO4W3__r.Name,FS_Site_Assessor__c
                     from FS_CIF__c WHERE CIF_Head__c=:currentCIFId ];//Edited Query as part of FET-7.0 FNF 795
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog(FETVALUE, CLASSNAME, 'Constructor', 'Account/CIF', SEVEARITY, e, 'NA');
        }
        
        //iterating the cif list
        for(FS_CIF__c cif:cifList){
            //getting the cif records which are approved and selected for EP creation
            if(cif.FS_EP_Check__c && cif.FS_Customer_s_disposition_after_review__c==FSConstants.APPROVED){
                cifListChecked.add(cif);
                outletsSet.add(cif.FS_Account__c);
            }
            // seperating the child CIF records to link to new CIF header
            if(!cif.FS_EP_Check__c && (cif.FS_Customer_s_disposition_after_review__c==FSConstants.APPROVED || 
                                       cif.FS_Customer_s_disposition_after_review__c==FSConstants.ONHOLD || 
                                       cif.FS_Customer_s_disposition_after_review__c==FSConstants.REVIEWAW || 
                                       cif.FS_Customer_s_disposition_after_review__c==FSConstants.SCNDSSPEN ||
                                       cif.FS_Customer_s_disposition_after_review__c==FSConstants.AWTCUSTDEC ||
                                       cif.FS_Customer_s_disposition_after_review__c==FSConstants.REDFORCOM)){
                                           cifForClonedHeader.add(cif);  
                                       }                        
        } 
        //getting the platform values given under the CIFs
        platformValues(cifListChecked);
       
    }    
    /*****************************************************************
Method: closePopup
Description: closePopup method is close the popup displayed to the user
added as part of FET 4.0
*******************************************************************/
    public void closePopup() {displayPopup = false;} 
    /*****************************************************************
Method: showPopup
Description: showPopup method is show the popup for the user with 
related message 
added as part of FET 4.0
*******************************************************************/
    public void showPopup() {displayPopup = true;}  
    
    
    /*****************************************************************
Method: createExecutionPlan
Description: createExecutionPlan method is to Create Execution Plan, Installation records for the selected CIFs.
we have New/Add Existing/Clone functionality on Create of Execution Plan/Installation
for the selected Platform Types 
Modified as part of FET 4.0
*******************************************************************/       
    public pageReference createExecutionPlan(){  
        
        closePopup();
        PageReference page=null;        
        SavePoint savePosition;
        
        try{
            savePosition = Database.setSavePoint();                   
            Id latestEPId;
            if(!FSUtil.checkAccessForSobject(EXEOBJNAME , FSConstants.ACCESS_IS_CREATABLE)){
                Apexpages.addMessage(FSConstants.PAGE_MSG_ACCESS);                
            } 
            //when the selected option is New to create execution plan
            if(selectedPlanType.equals(NEWEXE)){
                if(FSUtil.checkAccessForSobject(EXEOBJNAME, FSConstants.ACCESS_IS_CREATABLE)){                    
                    final FS_Execution_Plan__c newExecutionPlan = new FS_Execution_Plan__c();
                    FSUtil.putValueInField(newExecutionPlan, EXEOBJNAME, 'FS_Headquarters__c', accHeadquarter.Id);
                    FSUtil.putValueInField(newExecutionPlan, EXEOBJNAME, 'FS_Chain_Name__c', accHeadquarter.FS_Chain__c);
                    newExecutionPlan.FS_Platform_Type__c=platformType;                    
                    final Datetime hqDT = Datetime.now(); // Returns the current Datetime based on a GMT calendar.                    
                    newExecutionPlan.Name=accHeadquarter.Name+HYPHEN+userInfo.getLastName()+HYPHEN+hqDT.format('MMddYY')+hqDT.format('HHmm');
                    newExecutionPlan.FS_CIF_Header__c=customerInputHQ.Id;                    
                    newExecutionPlan.FS_FPS__c=customerInputHQ.FS_FPS__c;
                    newExecutionPlan.FS_Back_up_COM__c=customerInputHQ.FSCOM__r.UserId__c;                                    
                    newExecutionPlan.FS_Sales_Lead__c=customerInputHQ.FS_Sales_Rep_Name__r.UserId__c;
                    newExecutionPlan.RecordTypeId=FSExecutionPlanValidateAndSet.mapofExecutionPlanRecordtypNameAndRecordTypeId.get('Execution Plan');                    
                    insert newExecutionPlan;                                   
                    latestEPId = newExecutionPlan.Id;               
                }
                else{
                    Apexpages.addMessage(FSConstants.PAGE_MSG_ACCESS);
                    closePopup();
                }
            }
            //if selected option is Add Existing for EP creation
            else if(selectedPlanType.equals(ADDEXIST)){
                for(FS_Execution_Plan__c exePlan :lstExecutionPlan){
                    if(selectedExecutionPlan.equals(exePlan.Id + SPACE)){
                        if(exeplan.FS_Installations_approved_by_PM__c==ZEROVALUE || exeplan.FS_Installations_approved_by_PM__c==null){
                            FSUtil.putValueInField(exePlan, EXEOBJNAME, 'FS_Headquarters__c', accHeadquarter.Id);
                            FSUtil.putValueInField(exePlan, EXEOBJNAME, 'FS_Chain_Name__c', accHeadquarter.FS_Chain__c);
                            String options=SPACE;
                            final Set<String> pickSet=new Set<String>();
                            List<String> platformList=new List<String>();
                            List<String> pickList=new List<String>();
                            if(!string.ISBLANK(platformType)){
                                platformList=platformType.split(COLON);
                            }                             
                            if(exePlan.FS_Platform_Type__c!=nullVal()){
                                options=exePlan.FS_Platform_Type__c;
                                pickList=options.split(COLON);
                                pickSet.addAll(pickList);                                
                                options+=COLON;
                                for(String valueType:platformList){                                    
                                    if(!pickSet.contains(valueType)){                                        
                                        options+=valueType+COLON;                                        
                                    }
                                }                                
                            }
                            else{
                                for(String typeValue:platformList){
                                    options+=typeValue+COLON; 
                                }
                            }
                            if(!string.isBlank(options)){
                                options=options.removeEnd(COLON);                                
                                exePlan.FS_Platform_Type__c=options;                                
                            }
                            exePlan.FS_Platform_change_approved__c=true;
                            exePlan.FS_Equipment_Package_Insert_Check__c=true;   
                            update exePlan;
                            latestEPId = exePlan.Id;                        
                            break;
                        }
                        else{
                            closePopup();
                            final ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'one or more installations have been approved for the selected Execution Plan.Please select another');
                            ApexPages.addMessage(warningMessage);
                            closePopup();
                        }
                    }
                }
            }       
            //if selected option is Clone for EP creation
            else if(selectedPlanType.equals(CLONE)){
                for(FS_Execution_Plan__c exePlan :lstExecutionPlan){
                    if(selectedExecutionPlan.equals(exePlan.Id + SPACE)){
                        final FS_Execution_Plan__c newExecutionPlan = new FS_Execution_Plan__c();
                        FSUtil.putValueInField(newExecutionPlan, EXEOBJNAME, 'FS_Headquarters__c', accHeadquarter.Id);
                        FSUtil.putValueInField(newExecutionPlan, EXEOBJNAME, 'FS_Chain_Name__c', accHeadquarter.FS_Chain__c);
                        copySelectedFields(exePlan, newExecutionPlan);
                        final Datetime hqDT = Datetime.now();
                        newExecutionPlan.Name=accHeadquarter.Name+HYPHEN+userInfo.getLastName()+HYPHEN+hqDT.format('MMddYY')+hqDT.format('HHmm');
                        newExecutionPlan.FS_CIF_Header__c=customerInputHQ.Id;                        
                        newExecutionPlan.FS_FPS__c=customerInputHQ.FS_FPS__c;
                        newExecutionPlan.FS_Back_up_COM__c=customerInputHQ.FSCOM__r.UserId__c;                                    
                        newExecutionPlan.FS_Sales_Lead__c=customerInputHQ.FS_Sales_Rep_Name__r.UserId__c;
                        newExecutionPlan.RecordTypeId=FSExecutionPlanValidateAndSet.mapofExecutionPlanRecordtypNameAndRecordTypeId.get('Execution Plan');
                        if(!string.isBlank(platformType)){                            
                            newExecutionPlan.FS_Platform_Type__c=platformType;
                        }                       
                        insert newExecutionPlan;
                        cloneTechnicianInstructions(exePlan.Id, newExecutionPlan.id);
                        cloneEquipmentPackage(exePlan.Id, newExecutionPlan.id);
                        latestEPId = newExecutionPlan.Id;                    
                        break;
                    }
                }
            }        
            //after EP creation updating the CIF header record with EP ID
            if(latestEPId != nullVal()){          
                List<String> disTriggersRec = new List<String>{'FSCIFHeaderTrigger','FSAssociationBrandsetTrigger','FSCOMNotifications','FS_EquipPakage_Install_TriggerHandler'};
                Map<String, Disable_Trigger__c> tiggerisActive = Disable_Trigger__c.getAll();
                List<Disable_Trigger__c> disTriggerList = new List<Disable_Trigger__c>();
                for(String triggerStr: disTriggersRec){
                    tiggerisActive.get(triggerStr).IsActive__c=false;
               		disTriggerList.add(tiggerisActive.get(triggerStr));
                }
                update disTriggerList;
           
                //after EP creation updating the CIF header record with EP ID
                customerInputHQ.FS_EP__c = latestEPId;
                customerInputHQ.FS_Status__c = 'Closed – Converted to EP';             
                update customerInputHQ;
                //creating the installations for the Child CIFs based on the platform selected
                FSInstallationBusinessProcess.checkCreateVFClass=false; 
                FSAccountAuthorizationAndPopulateFields.executedbeforeUpdate=true;                
                createInstallations(latestEPId);                
                linkingIPToCIF();//OCR                
                //create new CIF header with the Clone of the Main CIF header and link the other CIFs toit
                if(!cifForClonedHeader.isEmpty()){
                    cloneCIFHead();
                }
                //ABTriggerON
                for(Disable_Trigger__c dtRec: disTriggerList){
                    dtRec.IsActive__c=true;
                }
                update disTriggerList;
                System.debug(logginglevel.info,'CPU TIME END of EP PROCESS Before navigation' +Limits.getCpuTime());
                page=new PageReference('/' + latestEPId);
            }
        }
        catch(Exception ex){          
            String errorMessage = ex.getMessage();
            Integer occurence;
            closePopup();            
            Database.rollback(savePosition);
            if(ex.getMessage()!=null && ex.getMessage().contains('CUSTOM_VALIDATION_EXCEPTION')){                              
                occurence = errorMessage.indexOf('CUSTOM_VALIDATION_EXCEPTION,') + 28;               
                errorMessage = errorMessage.mid(occurence, errorMessage.length());                
                occurence = errorMessage.lastIndexOf(':');
                errorMessage = errorMessage.mid(0, occurence);                
                errorMessage = errorMessage.substringBefore(':');
                errorMessage=errorMessage.trim();                
                Boolean errorMsgCheck=false;
                for(Apexpages.Message msg:ApexPages.getMessages()){					                    
                    if (msg.getDetail().contains(errorMessage)){   errorMsgCheck=true;   }                   
                }
                if(!errorMsgCheck){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));                }                
            }
            else {                
                ApexPages.addMessages(ex);
            }                        
        }
        return page;
    }
    /*****************************************************************
Method: cloneCIFHead
Description: cloneCIFHead method creates New CIF Header with clone of 
main CIF header and link other outlet CIF which are onhold/pending
Added as part of FET 4.0
*******************************************************************/
    private void cloneCIFHead(){      
        cloneHead=customerInputHQ.clone(false,false,false);
        cloneHead.FS_Version__c=customerInputHQ.FS_Version__c+ONEVALUE;//updating the version value with 1
        cloneHead.FS_Status__c = FSConstants.INPROGRESS;
        cloneHead.FS_EP__c=IDNULL;
        String str=customerInputHQ.Name;
        str=str.substring(ZEROVALUE,str.length()-ONEVALUE);
        cloneHead.Name=str+cloneHead.FS_Version__c;
        //inserting the new CIF Header
        try{
            upsert cloneHead;
        }
        catch(exception e){
            ApexErrorLogger.addApexErrorLog(FETVALUE, CLASSNAME, 'cloneCIFHead', 'CIF-Head', SEVEARITY, e, 'NA');
        }
        
        for(FS_CIF__c cif:cifForClonedHeader){
            cif.CIF_Head__c=cloneHead.Id;                
        }
        //upadting the other CIF records with the new CIF Header record ID
        if(!cifForClonedHeader.isEmpty()){
            try{
                update cifForClonedHeader; 
            }
            catch(Exception e){
                ApexErrorLogger.addApexErrorLog(FETVALUE, CLASSNAME, 'cloneCIFHead', 'CIF', SEVEARITY, e, 'NA');
            }
                           
        }    
    }    
    
    //Added by Srinivas B for FET 2.1 Helper method to clone Equipment Package in Cloned EP  
    private void cloneEquipmentPackage(final ID epsID,final ID epTarID){
        final Map<String,FS_EP_Equipment_Package__c> srcEquipmentMap=new Map<String,FS_EP_Equipment_Package__c>();
        final List<FS_EP_Equipment_Package__c> updateTrgEPEPList=new List<FS_EP_Equipment_Package__c>();    
        List<FS_EP_Equipment_Package__c> srcEPEPList=new List<FS_EP_Equipment_Package__c>();
        srcEPEPList=Database.query(FSUtil.getSelectQuery('FS_EP_Equipment_Package__c')+ ' where FS_Execution_Plan__c=:epsID');
        List<FS_EP_Equipment_Package__c> targetEPEPList=new List<FS_EP_Equipment_Package__c>();
        targetEPEPList=Database.query(FSUtil.getSelectQuery('FS_EP_Equipment_Package__c')+ ' where FS_Execution_Plan__c=:epTarID');    
        for(FS_EP_Equipment_Package__c eqp:srcEPEPList){
            srcEquipmentMap.put(eqp.FS_Platform_Type__c,eqp);
        }        
        for(FS_EP_Equipment_Package__c trgEPEP:targetEPEPList){             
            if(srcEquipmentMap.containsKey(trgEPEP.FS_Platform_Type__c)){
                final FS_EP_Equipment_Package__c srcEPEP=srcEquipmentMap.get(trgEPEP.FS_Platform_Type__c);
                trgEPEP.FS_Dispenser_Series_IC_code__c=srcEPEP.FS_Dispenser_Series_IC_code__c;
                trgEPEP.FS_Dispenser_QTY__c=srcEPEP.FS_Dispenser_QTY__c;
                trgEPEP.FS_LID_IM_Adapter1__c=srcEPEP.FS_LID_IM_Adapter1__c;
                trgEPEP.FS_LID_IM_Adapter1_QTY__c=srcEPEP.FS_LID_IM_Adapter1_QTY__c;
                trgEPEP.FS_LID_IM_Adapter2__c=srcEPEP.FS_LID_IM_Adapter2__c;
                trgEPEP.FS_LID_IM_Adapter2_QTY__c=srcEPEP.FS_LID_IM_Adapter2_QTY__c;
                trgEPEP.FS_Soft_Ice_Misc_Adapter__c=srcEPEP.FS_Soft_Ice_Misc_Adapter__c;
                trgEPEP.FS_Soft_Ice_Misc_Adapter_QTY__c=srcEPEP.FS_Soft_Ice_Misc_Adapter_QTY__c;
                trgEPEP.FS_Pump_Kit__c=srcEPEP.FS_Pump_Kit__c;
                trgEPEP.FS_Pump_Kit_QTY__c=srcEPEP.FS_Pump_Kit_QTY__c;
                trgEPEP.FS_External_Modems__c=srcEPEP.FS_External_Modems__c;
                trgEPEP.FS_External_Modems_QTY__c=srcEPEP.FS_External_Modems_QTY__c;
                trgEPEP.FS_Regulator__c=srcEPEP.FS_Regulator__c;
                trgEPEP.FS_Regulator_QTY__c=srcEPEP.FS_Regulator_QTY__c;
                trgEPEP.FS_Water_Booster__c=srcEPEP.FS_Water_Booster__c;
                trgEPEP.FS_Water_Booster_QTY__c=srcEPEP.FS_Water_Booster_QTY__c;
                trgEPEP.FS_Booster_Shelf__c=srcEPEP.FS_Booster_Shelf__c;
                trgEPEP.FS_Booster_Shelf_QTY__c=srcEPEP.FS_Booster_Shelf_QTY__c;
                trgEPEP.FS_Manifold__c=srcEPEP.FS_Manifold__c;
                trgEPEP.FS_Manifold_QTY__c=srcEPEP.FS_Manifold_QTY__c;
                trgEPEP.FS_Valid_Fill__c=srcEPEP.FS_Valid_Fill__c;
                trgEPEP.FS_Valid_Fill_QTY__c=srcEPEP.FS_Valid_Fill_QTY__c;
                trgEPEP.X30_Ice_Maker_Shroud__c=srcEPEP.X30_Ice_Maker_Shroud__c;
                trgEPEP.X30_Ice_Maker_Shroud_QTY__c=srcEPEP.X30_Ice_Maker_Shroud_QTY__c;
                trgEPEP.FS_Rack1__c=srcEPEP.FS_Rack1__c;
                trgEPEP.FS_Rack1_QTY__c=srcEPEP.FS_Rack1_QTY__c;
                trgEPEP.FS_Rack2__c=srcEPEP.FS_Rack2__c;
                trgEPEP.FS_Rack2_QTY__c=srcEPEP.FS_Rack2_QTY__c;
                trgEPEP.FS_Rack3__c=srcEPEP.FS_Rack3__c;
                trgEPEP.FS_Rack3_QTY__c=srcEPEP.FS_Rack3_QTY__c;
                trgEPEP.FS_Shelf1__c=srcEPEP.FS_Shelf1__c;
                trgEPEP.FS_Shelf1_QTY__c=srcEPEP.FS_Shelf1_QTY__c;
                trgEPEP.FS_Shelf2__c=srcEPEP.FS_Shelf2__c;
                trgEPEP.FS_Shelf2_QTY__c=srcEPEP.FS_Shelf2_QTY__c;
                trgEPEP.FS_Extended_Splash__c=srcEPEP.FS_Extended_Splash__c;
                trgEPEP.FS_Extended_Splash_QTY__c=srcEPEP.FS_Extended_Splash_QTY__c;
                trgEPEP.FS_Water_Filter__c=srcEPEP.FS_Water_Filter__c;
                trgEPEP.FS_Water_Filter_QTY__c=srcEPEP.FS_Water_Filter_QTY__c;
                trgEPEP.FS_Water_Filter_2__c=srcEPEP.FS_Water_Filter_2__c;
                trgEPEP.FS_Water_Filter_2_QTY__c=srcEPEP.FS_Water_Filter_2_QTY__c;
                trgEPEP.FS_Stand__c=srcEPEP.FS_Stand__c;
                trgEPEP.FS_Stand_QTY__c=srcEPEP.FS_Stand_QTY__c;
                trgEPEP.FS_Tall_Cup_Kit__c=srcEPEP.FS_Tall_Cup_Kit__c;
                trgEPEP.FS_Tall_Cup_Kit_QTY__c=srcEPEP.FS_Tall_Cup_Kit_QTY__c;
                trgEPEP.FS_Label_kits__c=srcEPEP.FS_Label_kits__c;
                trgEPEP.FS_Label_kits_QTY__c=srcEPEP.FS_Label_kits_QTY__c;
                trgEPEP.FS_Vacuum_Regulator__c=srcEPEP.FS_Vacuum_Regulator__c;
                trgEPEP.FS_Vacuum_Regulator_QTY__c=srcEPEP.FS_Vacuum_Regulator_QTY__c;
                trgEPEP.FS_Legacy_Equip_during_install__c=srcEPEP.FS_Legacy_Equip_during_install__c;
                trgEPEP.FS_Legacy_Equip_IC_Code_Desc_Qty__c=srcEPEP.FS_Legacy_Equip_IC_Code_Desc_Qty__c;
                trgEPEP.FS_X4LC_NNS_Tray__c=srcEPEP.FS_X4LC_NNS_Tray__c;
                trgEPEP.FS_X4LC_NNS_Tray_QTY__c=srcEPEP.FS_X4LC_NNS_Tray_QTY__c;
                trgEPEP.FS_X4LC_RCGP_Installation_Kit__c=srcEPEP.FS_X4LC_RCGP_Installation_Kit__c;
                trgEPEP.FS_X4LC_RCGP_Installation_Kit_QTY__c=srcEPEP.FS_X4LC_RCGP_Installation_Kit_QTY__c;
                trgEPEP.FS_X4LC_RCGP_Module_s__c=srcEPEP.FS_X4LC_RCGP_Module_s__c;
                trgEPEP.FS_X4LC_RCGP_Module_s_QTY__c=srcEPEP.FS_X4LC_RCGP_Module_s_QTY__c;
                
                updateTrgEPEPList.add(trgEPEP);                
            }
        }
        if(!updateTrgEPEPList.isEmpty()){
            try{
                update updateTrgEPEPList; 
            }
            Catch(Exception e){
                ApexErrorLogger.addApexErrorLog(FETVALUE, CLASSNAME, 'cloneEquipmentPackage', 'EP', SEVEARITY, e, 'NA');
            }                       
        }        
    }
    
    // Added by Praveen Sahu for FET 2.0 Helper method to clone Technician Instruction in Cloned EP  
    private void cloneTechnicianInstructions(final ID epSRCID,final ID epTargetID){
        final Map<String,FS_EP_Technician_Instructions__c> srcTechInstMap=new Map<String,FS_EP_Technician_Instructions__c>();
        final List<FS_EP_Technician_Instructions__c> updateTrgEPTIList=new List<FS_EP_Technician_Instructions__c>();    
        List<FS_EP_Technician_Instructions__c> srcEPTIList=new List<FS_EP_Technician_Instructions__c>();
        srcEPTIList=Database.query(FSUtil.getSelectQuery('FS_EP_Technician_Instructions__c')+ ' where Execution_Plan__c=:epSRCID');
        List<FS_EP_Technician_Instructions__c> targetEPTIList=new List<FS_EP_Technician_Instructions__c>();
        targetEPTIList=Database.query(FSUtil.getSelectQuery('FS_EP_Technician_Instructions__c')+ ' where Execution_Plan__c=:epTargetID');
        for(FS_EP_Technician_Instructions__c techIns:srcEPTIList){
            srcTechInstMap.put(techIns.FS_Platform_Type__c,techIns);
        }
        for(FS_EP_Technician_Instructions__c trgEPTI:targetEPTIList){ 
            if(srcTechInstMap.containsKey(trgEPTI.FS_Platform_Type__c)){
                final FS_EP_Technician_Instructions__c srcEPTI=srcTechInstMap.get(trgEPTI.FS_Platform_Type__c);
                trgEPTI.FS_X7000_Series_Dispenser_Placement__c=srcEPTI.FS_X7000_Series_Dispenser_Placement__c;
                trgEPTI.FS_Type_of_Line__c=srcEPTI.FS_Type_of_Line__c;
                trgEPTI.FS_Protocol_for_Existing_Lines__c=srcEPTI.FS_Protocol_for_Existing_Lines__c;
                trgEPTI.FS_Path__c=srcEPTI.FS_Path__c;
                trgEPTI.FS_Line_Special_Instructions__c=srcEPTI.FS_Line_Special_Instructions__c;
                trgEPTI.FS_Protocol_for_Existing_Rack__c=srcEPTI.FS_Protocol_for_Existing_Rack__c;        
                trgEPTI.FS_Location_of_Syrup_Rack__c=srcEPTI.FS_Location_of_Syrup_Rack__c;
                trgEPTI.FS_Rack_Special_Instructions__c=srcEPTI.FS_Rack_Special_Instructions__c;
                trgEPTI.FS_Water_Booster_Location__c=srcEPTI.FS_Water_Booster_Location__c;
                trgEPTI.FS_Water_Booster_Special_Instructions__c=srcEPTI.FS_Water_Booster_Special_Instructions__c;
                trgEPTI.FS_Water_Filter_Supplier__c=srcEPTI.FS_Water_Filter_Supplier__c;
                trgEPTI.FS_Requirements__c=srcEPTI.FS_Requirements__c;
                trgEPTI.FS_Installer__c=srcEPTI.FS_Installer__c;
                trgEPTI.FS_Location__c=srcEPTI.FS_Location__c;
                trgEPTI.FS_Water_Filter_Special_Instructions__c=srcEPTI.FS_Water_Filter_Special_Instructions__c;
                trgEPTI.FS_IM_Requirements__c=srcEPTI.FS_IM_Requirements__c;
                trgEPTI.IM_Dispense_Soft_Ice__c=srcEPTI.IM_Dispense_Soft_Ice__c;
                trgEPTI.FS_IM_Make__c=srcEPTI.FS_IM_Make__c;
                trgEPTI.FS_IM_Model__c=srcEPTI.FS_IM_Model__c;
                trgEPTI.FS_Is_Coordination_by_Coca_Cola_Required__c=srcEPTI.FS_Is_Coordination_by_Coca_Cola_Required__c;
                trgEPTI.FS_IM_Special_Instructions__c=srcEPTI.FS_IM_Special_Instructions__c;
                trgEPTI.FS_KO_or_DOE_Disposition_of_Removd__c=srcEPTI.FS_KO_or_DOE_Disposition_of_Removd__c;
                trgEPTI.FS_Equip_Placement__c=srcEPTI.FS_Equip_Placement__c;
                trgEPTI.FS_Instructions__c=srcEPTI.FS_Instructions__c;
                trgEPTI.FS_Other_Instructions__c=srcEPTI.FS_Other_Instructions__c;
                trgEPTI.FS_Parts_SP_Needs_to_Order__c=srcEPTI.FS_Parts_SP_Needs_to_Order__c;
                
                updateTrgEPTIList.add(trgEPTI);               
            }
        }        
        if(!updateTrgEPTIList.isEmpty()){
            try{
                update updateTrgEPTIList;  
            }
            catch(Exception e){
                ApexErrorLogger.addApexErrorLog(FETVALUE, CLASSNAME, 'cloneTechnicianInstructions', 'TI', SEVEARITY, e, 'NA');
            }
                      
        }
    }
    //End OF Technician Instruction Clone
    
    /*****************************************************************
Method: createInstallations
Description: createInstallations method is create Installation for the selected CIFs based on the platform assigned to it.
update the respective outlet Information from the CIF data
Modified: venkat as part of FET 4.0
Modified: Venkat as part of FET 5.0 for US-4 to create one installation for one outlet CIF
*******************************************************************/
    private void createInstallations(final Id newExecutionPlanId){ 
        //FET5.0        
        final List<String> pickListPercent=new List<String>{'33%','50%','66%','75%','Full'};        
            final List<Account> lstOutletToUpdate = new List<Account>();
        lstInstallation = new List<FS_Installation__c>();
        
        mapOutletWrap=new Map<id,FS_CIF__c>();        
        final Set<Id> outletIdsToMap = new Set<Id>();       
        final Id installRecordId=FSInstallationValidateAndSet.ipNewRecType;
        Set<String> platformSet;
        List<String> platformList;
        Map<String,FS_CIF__c> cifPlatformMap;
        FS_Installation__c install;
        FS_CIF__c cifRecTemp;
        String platformTypes;
        Boolean brandStatus;
        for(FS_CIF__c outAcc : cifListChecked){
            platformTypes=''; 
            brandStatus=true;           
            mapOutletWrap.put(outAcc.FS_Account__c,outAcc);
            outletIdsToMap.add(outAcc.FS_Account__c);            
            platformSet=new Set<String>();
            platformList=new List<String>();
            cifPlatformMap=new Map<String,FS_CIF__c>();            
            
            //New Installation record creation
            install = new FS_Installation__c();
            install.FS_Execution_Plan__c = newExecutionPlanId;			
            install.RecordtypeId = installRecordId;
            
            if(outAcc.FS_Platform1__c!=nullVal()){ 
                install.FS_Platform1__c=outAcc.FS_Platform1__c;
                install.FS_DispRequested1__c=outAcc.FS_Platform1_Qty__c;                                
                if(outAcc.FS_Brandset1__c==null || outAcc.FS_Water1__c==null ){
                    brandStatus=false;
                }
                platformSet.add(outAcc.FS_Platform1__c);                
            }
            if(outAcc.FS_Platform2__c!=nullVal()){
                install.FS_Platform2__c=outAcc.FS_Platform2__c;
                install.FS_DispRequested2__c=outAcc.FS_Platform2_Qty__c;                
                if(brandStatus && (outAcc.FS_Brandset2__c==null || outAcc.FS_Water2__c==null) ){
                    brandStatus=false;
                }
                platformSet.add(outAcc.FS_Platform2__c);                
            }
            if(outAcc.FS_Platform3__c!=nullVal()){
                install.FS_Platform3__c=outAcc.FS_Platform3__c;
                install.FS_DispRequested3__c=outAcc.FS_Platform3_Qty__c;                
                if(brandStatus && (outAcc.FS_Brandset3__c==null || outAcc.FS_Water3__c==null) ){
                    brandStatus=false;
                }
                platformSet.add(outAcc.FS_Platform3__c);                
            }
            String options='';
            for(String typeValue:platformSet){                    
                options+=typeValue+COLON; 
            }
            if(!string.isBlank(options)){
                options=options.removeEnd(COLON);
                platformTypes=options;
            }              
            install.FS_BrandStatus__c=brandStatus?'Complete':'NOT Complete';
            install.Type_of_Dispenser_Platform__c=platformTypes;           
            install.FS_CIF__c=outAcc.Id;
            if(outAcc != nullVal() && outAcc.FS_Account__c != nullVal()){
                install.FS_Outlet__c = outAcc.FS_Account__c;
            }            
            lstInstallation.add(install);
        }                      
        //FET5.0
        
        //copying of CIF records details to the installation records
        for(FS_Installation__c inst:lstInstallation){
            if(mapOutletWrap.containsKey(inst.FS_Outlet__c)){
                final FS_CIF__c outAcc=mapOutletWrap.get(inst.FS_Outlet__c); 
                
                inst.FS_Time_to_call_home__c=outAcc.FS_Time_to_call_home__c;
                inst.FS_CIF__c=outAcc.Id;//OCR
                inst.FS_COM_Regular__c=customerInputHQ.FSCOM__r.UserId__c;//OCR
                inst.FS_Sales_Lead__c=customerInputHQ.FS_Sales_Rep_Name__r.UserId__c;//OCR
                inst.FS_Valid_fill_required__c=outAcc.FS_ValidFill_Option__c;
                
                //Site survey results section  
                inst.FS_Any_Crew_Serve_Dispensers__c=outAcc.FS_Any_Crew_Serve_Dispensers__c;              
                inst.FS_Customer_s_disposition_after_review__c=outAcc.FS_Customer_s_disposition_after_review__c;                
                inst.FS_Reason_if_applicable__c=outAcc.FS_Reason_if_applicable__c;
                inst.FS_Second_Site_Survey_Reason__c=outAcc.FS_Second_Site_Survey_Reason__c;
                inst.FS_Customer_disposition_Provide_DateTime__c=outAcc.FS_Customer_disposition_Submit_DateTime__c;
                inst.FS_Customer_s_disposition_captured_by__c=outAcc.FS_Customer_s_Disposition_Submitted_by__c;
                inst.FS_Davaco_Order_Entered__c=outAcc.FS_Davaco_Order_Entered__c;
                inst.FS_Davaco_Order_Entered_By__c=outAcc.FS_Davaco_Order_Entered_By__c;
                inst.FS_DavacoOrderEnteredDateTime__c=outAcc.FS_Davaco_Order_Entered_Date_Time__c;
                //inst.FS_JDE_Doc__c=outAcc.FS_JDE_Doc__c; //commenting out as part of FET-7.0 FNF 722
                //inst.FS_Doc__c=outAcc.FS_JDE_Doc__c;  //commenting out as part of FET-7.0 FNF 722
                inst.FS_WO__c=outAcc.FS_Work_Order_WO__c;
                inst.FS_SA_Scheduled_On_Date__c=outAcc.FS_SA_Scheduled_On_Date__c;
                //OCR2
                inst.FS_SA_Rescheduled_On_Date__c=outAcc.FS_SA_Rescheduled_On_Date__c;
                inst.FS_SA_Rescheduled_Reason__c=outAcc.FS_SA_Rescheduled_Reason__c;
                inst.FS_Second_SA_Rescheduled_Date__c=outAcc.FS_Second_SA_Rescheduled_Date__c;
                inst.FS_Second_SA_Rescheduled_Reason__c=outAcc.FS_Second_SA_Rescheduled_Reason__c;
                inst.FS_Second_SA_Scheduled_Contacted_Date__c  =outAcc.FS_Second_SA_Scheduled_Contacted_Date__c;
                //OCR2
                inst.FS_SA_Completed_Date__c=outAcc.FS_SA_Completed_Date__c;
                inst.FS_SA_Scheduled_Contacted_Date__c=outAcc.FS_SA_Scheduled_Contacted_Date__c;
                inst.FS_SA_Scheduled_By__c=outAcc.FS_SA_Scheduled_By__c;
                inst.FS_SA_Unable_to_Complete_Reason__c=outAcc.FS_SA_Unable_to_Complete_Reason__c;
                inst.FS_Date_GFE_Posted__c=outAcc.FS_Date_GFE_Posted__c;
                inst.FS_Site_Prep_Contract_Received__c=outAcc.FS_Site_Prep_Contract_Received__c;
                inst.X2nd_SA_Completed_Date__c = outAcc.FS_Second_Site_Assessment_Completed_Date__c;
                inst.X2nd_SA_Scheduled_On_Date__c = outAcc.FS_Second_SA_Scheduled_Date__c;
                inst.FS_Second_SA_Scheduled_By__c = outAcc.FS_Second_SA_Scheduled_By__c;
                inst.FS_Second_SA_Incomplete_reason__c = outAcc.FS_Second_SA_Incomplete_reason__c;
                inst.FS_Second_GFE_Posted_Date__c = outAcc.FS_Second_GFE_Posted_Date__c;
                inst.FS_Second_Site_Prep_Contract_Received__c = outAcc.FS_Second_Site_Prep_Contract_Received__c;
                inst.FS_Davaco_Order_Entered_Second_Survey__c = outAcc.FS_Second_Davaco_Order_Entered__c;
                inst.FS_Davaco_Order_Entered_By_Second_survey__c = outAcc.FS_Second_Davaco_Order_Entered_By__c;
                inst.FS_Davaco_Order_Entered_Date_Time_2nd_Su__c = outAcc.FS_Second_Davaco_Order_Entered_Date_Time__c;
                //inst.FS_JDE_Doc_Second_survey__c = outAcc.FS_Second_JDE_Doc__c;  //commenting out as part of FET-7.0 FNF 722
                inst.FS_Second_Work_Order_WO__c = outAcc.FS_Second_Work_Order_WO__c;
                inst.FS_SA_Completion_By_Date__c = outAcc.FS_Date_SA_to_be_completed_by__c;
                //Site survey results section
                //Installation Section
                inst.FS_Requested_Install_Period__c=outAcc.FS_Requested_Install_Period__c;
                inst.FS_Requested_Install_Date__c = outAcc.FS_Requested_Install_Date__c;
                inst.FS_Coordination_To_Be_Done_By__c = outAcc.FS_Contractor_Coordination_to_be_done_by__c;
                inst.FS_GC_Coordination_to_be_done_by__c = outAcc.FS_Contractor_Coordination_to_be_done_by__c;
                inst.FS_Day_AM_or_Night_PM_Installation__c =outAcc.FS_Day_AM_or_Night_PM_Installation__c;               
                
                inst.FS_Outlet_Contact2__c=outAcc.FS_Outlet_Contact__c;                
                inst.FS_General_Contractor_Contact_Name__c = outAcc.FS_Contractor_Contact__r.Name;
                inst.FS_General_Contractor_Contact_Email__c= outAcc.FS_Contractor_Contact__r.Email;
                inst.FS_General_Contractor_Contact_Phone__c= outAcc.FS_Contractor_Contact__r.Phone;
                inst.FS_NewRemodelOutletOnlyProjectedOpening__c = outAcc.FS_NewRemodelOutletOnlyProjectedOpening__c;
                inst.FS_NewRemodelOutletOnlyProjectedFireUp__c = outAcc.FS_NewRemodelOutletOnlyProjectedFireUp__c;
                inst.FS_NewRemodelOutletOnlyLineInstallation__c = outAcc.FS_NewRemodelOutletOnlyLineInstallation__c;
                inst.FS_NewRemodelOutletOnlyEquipmentInstall__c = outAcc.FS_NewRemodelOutletOnlyEquipmentInstall__c;
                //Installation Section
                //Ice water section                
                inst.FS_Water_Filter_Contact_Email__c=outAcc.FS_Water_Filter_Contact_Name__r.Email;
                inst.FS_Water_Filter_Contact_Name__c=outAcc.FS_Water_Filter_Contact_Name__r.Name;
                inst.FS_Water_Filter_Contact_Phone__c=outAcc.FS_Water_Filter_Contact_Name__r.Phone;
                inst.Water_Filter_Installer_Email__c=outAcc.Water_Filter_Installer_Name__r.Email;
                inst.Water_Filter_Installer_Name__c=outAcc.Water_Filter_Installer_Name__r.Name;
                inst.Water_Filter_Installer_Phone__c=outAcc.Water_Filter_Installer_Name__r.Phone;
                inst.FS_Water_Filter_MFG__c=outAcc.FS_Water_Filter_MFG__c;
                inst.FS_Water_Filter_Model_no__c=outAcc.FS_Water_Filter_Model_no__c ;
                inst.FS_Who_will_install_Water_Filter__c=outAcc.FS_Who_will_install_Water_Filter__c;
                inst.FS_Ice_maker_and_water_filter_comments__c=outAcc.FS_Ice_maker_and_water_filter_comments__c;                
                //Ice water section
                inst.FS_Trainer__c=outAcc.FS_OB_Trainer__c;
                if(outAcc.FS_On_Boarding_Days_after_Install__c!=nullVal()){
                    inst.FS_HowManyDaysAfterInstallOnboarding__c=decimal.valueOf(outAcc.FS_On_Boarding_Days_after_Install__c);
                }
                inst.FS_Training_Start_Time__c=outAcc.FS_Select_On_Boarding_Start_Time__c;
                inst.Outlet_Open_Time__c = outAcc.FS_On_boarding_time_requested__c;
                inst.Onboarding_Training_Contact__c=outAcc.FS_On_Boarding_Contact__c;                
                inst.FS_OB_Comments__c=outAcc.FS_Training_Comment__c;
                inst.FS_What_type_of_outlet_install__c=outAcc.FS_What_type_of_outlet_install__c;                
                inst.FS_Site_Assessment_Contact_name__c = outAcc.FS_Select_Site_assessment_contact__r.Name;
                inst.FS_Site_Assessment_Contact_Title__c = outAcc.FS_Select_Site_assessment_contact__r.FS_Title__c;
                inst.FS_Site_Assessment_Contact_Phone__c = outAcc.FS_Select_Site_assessment_contact__r.Phone;
                inst.FS_Site_Assessment_Contact_Cell__c = outAcc.FS_Select_Site_assessment_contact__r.FS_Alternate_Phone_Cell__c;
                inst.FS_Site_Assessment_contact_email__c =outAcc.FS_Select_Site_assessment_contact__r.Email; 
                //RO4W section FET 5.1
                inst.Does_Install_Involve_RO4W__c =outAcc.Does_Install_Involve_RO4W__c;
                inst.FS_RO4W1__c=outAcc.FS_RO4W1__c;
                inst.FS_RO4W2__c=outAcc.FS_RO4W2__c;
                inst.FS_RO4W3__c=outAcc.FS_RO4W3__c;
                //Replacement section Added as part of FET-7.0 FNF 795
                inst.FS_Does_Install_Involve_a_Replacement__c =outAcc.FS_Does_Install_Involve_a_Replacement__c;
                inst.FS_Replacement_1__c=outAcc.FS_Replacement_1__c;
                inst.FS_Replacement_2__c=outAcc.FS_Replacement_2__c;
                inst.FS_Replacement_3__c=outAcc.FS_Replacement_3__c;
                //OCR2
                inst.FS_Secondary_Contact_Email_Address__c=outAcc.FS_Secondary_Site_Assessment_Contact__r.Email;
                inst.FS_Scndry_Site_Assmnt_Cnct_name__c=outAcc.FS_Secondary_Site_Assessment_Contact__r.Name;
                inst.FS_Sec_Site_Assessment_Cnct_Title__c=outAcc.FS_Secondary_Site_Assessment_Contact__r.FS_Title__c;
                inst.FS_Scndry_Site_Assmnt_cnct_cell__c=outAcc.FS_Secondary_Site_Assessment_Contact__r.Phone;
                inst.FS_Scndry_Site_Assmnt_cnct_ofc__c=outAcc.FS_Secondary_Site_Assessment_Contact__r.FS_Alternate_Phone_Cell__c;
                //OCR2
                inst.FS_Ancillary_equipment_needed__c=outAcc.FS_Ancillary_equipment_needed__c;
                inst.FS_Dispenser_Comments__c=outAcc.FS_Dispenser_Comments__c;
                inst.FS_Describe_Any_Known_Construction_Needs__c=outAcc.Any_known_construction_needs__c;
                inst.FS_Site_Assessor__c=outAcc.FS_Site_Assessor__c;//FNF-64 Site Assessor Copy Down
                //Finance Section
                inst.Cokesmart_Payment_Method__c= outAcc.FS_Cartridge_Payment_Method__c;
                inst.FS_Program_Fee_Payment_Method__c=outAcc.FS_Program_Fee_Payment_Method__c;
                inst.FS_DryAccount_curently_no_dispnsd_accnt__c=outAcc.FS_DryAccount_curently_no_dispnsd_accnt__c;
                //Finance Section
                //product section
                inst.FS_Product_Information_Comments__c=outAcc.FS_Product_Comment__c;
                inst.FS_Requested_Delivery_Method__c=outAcc.FS_Delivery_Method__c;
                inst.FS_Requested_Order_Method__c=outAcc.FS_Cartridge_Order_Method__c;
                inst.FS_Cartridge_Order_Method__c=outAcc.FS_Cartridge_Order_Method__c;
                //product section
                //Finance section
                inst.FS_Bill_to_Address__c=outAcc.FS_Bill_to_Address__c;
                inst.FS_Bill_To_City__c=outAcc.FS_Bill_to_City__c;
                inst.FS_Bill_to_State__c=outAcc.FS_Bill_to_State__c;
                inst.FS_Bill_To_Country__c = outAcc.FS_Bill_to_Country__c;
                inst.FS_Bill_To_Zip__c=outAcc.FS_Bill_to_Zip_Code__c;
                inst.FS_Bill_to_Phone__c=outAcc.FS_Bill_to_Phone__c;
                inst.FS_New_Mailing_Address__c=outAcc.FS_Mail_to_Address__c; 
                inst.FS_New_Mailing_City__c=outAcc.FS_Mail_to_City__c;                
                //related Vendor account                
                inst.FS_Related_Vendor__c = outAcc.FS_General_Contractor_Name__c;
                inst.FS_New_Mailing_State__c=outAcc.FS_Mail_to_State__c;
                inst.FS_New_Mailing_Zip__c=outAcc.FS_Mail_to_Zip_Code__c;
                inst.FS_Ancillary_equipment_to_remain_on_site__c=outAcc.FS_Ancillary_equipment_to_remain_on_site__c;
                inst.FS_Davaco_Requirements__c=outAcc.FS_What_type_of_Site_Assessment__c;                
                inst.FS_Top_Off_Button__c=outAcc.FS_Top_Off_Feature__c;
                inst.FS_Bill_To_Address_same_as_Ship_to_Addrs__c = outAcc.FS_Is_Bill_to_Address_Same_as_Ship_to__c;
                inst.FS_Is_Bill_to_Address_Same_as_Ship_to__c = outAcc.FS_Is_Bill_to_Address_Same_as_Ship_to__c;
                if(outAcc.FS_Customers_Ice_Fill_Policy__c==pickListPercent[0]){inst.FS_Customer_Ice_Fill_Spec__c='1/3';}
                else if(outAcc.FS_Customers_Ice_Fill_Policy__c==pickListPercent[1]){inst.FS_Customer_Ice_Fill_Spec__c='1/2';}
                else if(outAcc.FS_Customers_Ice_Fill_Policy__c==pickListPercent[2]){inst.FS_Customer_Ice_Fill_Spec__c='2/3';}
                else if(outAcc.FS_Customers_Ice_Fill_Policy__c==pickListPercent[3]){inst.FS_Customer_Ice_Fill_Spec__c='3/4';}
                else if(outAcc.FS_Customers_Ice_Fill_Policy__c==pickListPercent[4]){inst.FS_Customer_Ice_Fill_Spec__c='Full';}
            }            
        }
        if(FSUtil.checkAccessForSobject('FS_Installation__c', FSConstants.ACCESS_IS_CREATABLE) && !lstInstallation.isEmpty()){            
          //  try{
                insert lstInstallation;
          /*  }
            catch(exception e){
                ApexErrorLogger.addApexErrorLog(FETVALUE, CLASSNAME, 'createInstallations', 'Installation', SEVEARITY, e, 'NA');
            } */
            
        }
        else{
            Apexpages.addMessage(FSConstants.PAGE_MSG_ACCESS);
        }                
    }
    
    // Methos to search existing Execution Plan  
    public static String addAndOrWhere(final String qry){
        String returnValue=SPACE;
        if(qry.contains('Where') ){returnValue= qry + ' AND '; }
        else{returnValue= qry + ' Where ' ; }
        return returnValue;
    }
    
    // SOQL Injection Optimization  
    public void searchExistingExecutionPlan(){        
        String csv = SPACE;
        for(String field : Schema.getGlobalDescribe().get(EXEOBJNAME).getDescribe().fields.getMap().keyset()){
            csv += field + ',';
        }
        csv = csv.removeEnd(',');
        csv=csv+',Recordtype.name,FS_Chain_Name__r.Name,FS_Headquarters__r.Name,FS_Chain_Name__r.RecordType.Name,FS_Headquarters__r.RecordType.Name';
        String qryExecutionPlan='Select ' + csv + ' From ' + EXEOBJNAME;      
        String prjName;
        qryExecutionPlan += ' Where RecordType.Name =\'' +'Execution Plan'+ SLASH;
        
        if(executionPlanName != nullVal() && !String.isBlank(executionPlanName)){
            final String plan=String.escapeSingleQuotes(executionPlanName);
            prjName = PERCENT + plan.trim() + PERCENT;
            
            qryExecutionPlan =addAndOrWhere(qryExecutionPlan) +'FS_Execution_Plan__c.Name LIKE  \'' + prjName + SLASH;
        }        
        String strHqName;
        //Add check for Headquater Name
        if(headquarterName != nullVal() && !String.isBlank(headquarterName)){
            final String plan=String.escapeSingleQuotes(headquarterName);
            strHqName = PERCENT + plan.trim() + PERCENT;
            qryExecutionPlan = addAndOrWhere(qryExecutionPlan) + ' FS_Headquarters__r.Name LIKE \'' + strHqName +SLASH +
                ' AND FS_Headquarters__r.RecordType.Name = \'' + FSConstants.RECORD_TYPE_NAME_HQ + SLASH;
        }
        String exePlanNo;
        if(executionPlanNo != nullVal() && !String.isBlank(executionPlanNo)){
            final String plan=String.escapeSingleQuotes(executionPlanNo);
            exePlanNo = PERCENT + plan.trim()  + PERCENT;
            qryExecutionPlan = addAndOrWhere(qryExecutionPlan) + ' FS_Execution_Plan__c LIKE \'' + exePlanNo + SLASH;            
        }
        if((selectedPlanType.equals(CLONE)) && accHeadquarter.FS_Chain__c!=nullVal()){
            qryExecutionPlan = addAndOrWhere(qryExecutionPlan) + ' FS_Chain_Name__c = \'' + accHeadquarter.FS_Chain__c + SLASH;        
        }
        if(selectedPlanType.equals(CLONE) && platformType!=nullVal() ){
            qryExecutionPlan = addAndOrWhere(qryExecutionPlan) + ' FS_Platform_Type__c = \'' + platformType + SLASH;        
        }
        //OCR2
        if(selectedPlanType.equals(ADDEXIST)){
            qryExecutionPlan = addAndOrWhere(qryExecutionPlan) + 'FS_Execution_Plan_Status__c !=\'' +'Cancelled'+ SLASH+ 'AND FS_Execution_Plan_Status__c !=\'' +'Complete' +SLASH +  'AND FS_Headquarters__c = \'' +accHeadquarter.id+SLASH;            
        }
        //OCR2
        
        lstExecutionPlan = (List<FS_Execution_Plan__c>)database.query(qryExecutionPlan) ;
    }  
    
    // Helper method to copy fields while cloning the existing execution plan  
    private void copySelectedFields(final FS_Execution_Plan__c epSRC,final FS_Execution_Plan__c epTarget){                
        FSUtil.putValueInField(epTarget, EXEOBJNAME, 'FS_Scope_of_Work__c', epSRC.FS_Scope_of_Work__c);        
    }
    
    // Selects list options for Execution Plan Type  
    public List<Selectoption> executionPlanOption{
        get{
            if(executionPlanOption == nullVal()){
                executionPlanOption = new List<Selectoption>();
                executionPlanOption.add( new Selectoption(NEWEXE, 'New'));
                executionPlanOption.add( new Selectoption(ADDEXIST, 'Add to Existing HQ Execution Plan'));
                executionPlanOption.add( new Selectoption(CLONE, 'Clone an Existing Execution Plan'));
            }
            return executionPlanOption;
        }
        set;
    }
    //OCR
    private void linkingIPToCIF(){
        final Set<Id> cifUpdateSet=new Set<Id>();
        FS_CIF__c outAcc;
        final List<FS_CIF__c> cifUpdateList=new List<FS_CIF__c>();
        for(FS_Installation__c inst:lstInstallation){
            if(mapOutletWrap!=null && mapOutletWrap.containsKey(inst.FS_Outlet__c)){
                outAcc=mapOutletWrap.get(inst.FS_Outlet__c);                               
                if(!cifUpdateSet.contains(outAcc.Id)){
                    cifUpdateSet.add(outAcc.Id);
                    outAcc.FS_installation__c=inst.Id;
                    cifUpdateList.add(outAcc);
                }
            }
        }
        
        if(!cifUpdateList.isEmpty()){
            try{
                update cifUpdateList;
            }
            catch(Exception e){
                ApexErrorLogger.addApexErrorLog(FETVALUE, CLASSNAME, 'linkingIPToCIF', 'CIF', SEVEARITY, e, 'NA');
            }
            
        }
    }
    //OCR
}