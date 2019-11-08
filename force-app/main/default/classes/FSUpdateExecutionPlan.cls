public class FSUpdateExecutionPlan {
    public static CIF_Header__c customerInputHQ;
    public static FS_Execution_Plan__c executionPlan;
    public static List<FS_CIF__c> cifList;
    public static List<Account> outletsList;
    public static List<FS_Installation__c> installList;
    public static Map<String,FS_CIF__c> cifDetailsMap;
    public static Map<String,FS_CIF__c> cifAccountMap;
    public static Map<String,FS_Installation__c> installMap;
    public static Map<String,FS_Installation__c> installDetailsMap;
    public static List<FS_Installation__c> updateInstall;
    public static List<FS_IP_Technician_Instructions__c> ipTechInstruction;
    
    public static void fetchRecordDetails(final Id cifHeader){
        customerInputHQ=new CIF_Header__c();
        executionPlan=new FS_Execution_Plan__c();
        updateInstall=new List<FS_Installation__c>();
        cifList=new List<FS_CIF__c>();
        outletsList=new List<Account>();
        installList=new List<FS_Installation__c>();
        ipTechInstruction=new List<FS_IP_Technician_Instructions__c>();
        final Set<Id> outletsSet=new Set<Id>();
        final Set<Id> installSetId=new Set<Id>();
        //outletsMap=new Map<String,Account>();
        cifDetailsMap=new Map<String,FS_CIF__c>();
        cifAccountMap=new Map<String,FS_CIF__c>();
        installDetailsMap=new Map<String,FS_Installation__c>();
        installMap=new Map<String,FS_Installation__c>();
        //CIF Header query
        customerInputHQ=[select id,Name,FSCOM__r.UserId__c,FS_EP__c,FS_FPS__c,FS_HQ__c,FS_HQ__r.Name,FS_Original_CIF_Head__c,FS_Sales_Rep_Name__r.UserId__c,FS_Status__c,FS_Version__c from CIF_Header__c where id=:cifHeader];        
        
        //CIF Line Items Query
        cifList=[SELECT Id,FS_EP_Check__c,CIF_Head__r.FS_EP__c,FS_Account__c,FS_Site_Prep_Contract_Received__c,FS_Customer_s_disposition_after_review__c,FS_Reason_if_applicable__c,FS_Customer_disposition_Submit_DateTime__c,
                 FS_Customer_s_Disposition_Submitted_by__c,FS_Davaco_Order_Entered__c,FS_Davaco_Order_Entered_By__c,FS_Davaco_Order_Entered_Date_Time__c,
                 FS_JDE_Doc__c,FS_Work_Order_WO__c,FS_SA_Scheduled_On_Date__c,FS_SA_Completed_Date__c,FS_SA_Scheduled_Contacted_Date__c,
                 FS_Pepper_Mix__c,FS_SA_Scheduled_By__c,FS_Date_GFE_Posted__c,FS_Requested_Install_Period__c,FS_Requested_Install_Date__c,
                 FS_Customers_Ice_Fill_Policy__c,FS_Top_Off_Feature__c,FS_Day_AM_or_Night_PM_Installation__c,FS_Contractor_Coordination_to_be_done_by__c,
                 FS_On_Boarding_Contact__r.Name,FS_On_Boarding_Contact__r.Phone,FS_On_Boarding_Contact__r.Email,FS_OB_Trainer__c,FS_Second_SA_Scheduled_Contacted_Date__c,
                 FS_Time_to_call_home__c,FS_On_Boarding_Days_after_Install__c,FS_Select_On_Boarding_Start_Time__c,FS_Brandset1__c,FS_Brandset2__c,FS_Brandset3__c,FS_Outlet_Contact__r.Name,FS_Outlet_Contact__r.Email,FS_Outlet_Contact__r.Phone,
                 FS_General_Contractor__c,FS_Contractor_Contact__r.Name,FS_Contractor_Contact__r.Email,FS_Contractor_Contact__r.Phone,
                 FS_Second_Site_Survey_Reason__c,Water_Filter_Installer_Name__r.name,Water_Filter_Installer_Name__r.Phone,Water_Filter_Installer_Name__r.Email,
                 FS_NewRemodelOutletOnlyProjectedOpening__c,FS_NewRemodelOutletOnlyProjectedFireUp__c,FS_NewRemodelOutletOnlyLineInstallation__c,Any_known_construction_needs__c,
                 FS_NewRemodelOutletOnlyEquipmentInstall__c,FS_Ice_maker_and_water_filter_comments__c,FS_On_boarding_time_requested__c,
                 FS_Who_will_install_Water_Filter__c,FS_Water_Filter_Contact_Name__r.Email,FS_Water_Filter_Contact_Name__r.Phone,FS_Water_Filter_Contact_Name__r.Name,FS_Wired_Solutions_Required__c,FS_Platform1__c,FS_Water1__c,FS_Water2__c,FS_Water3__c,FS_Platform2__c,FS_Platform3__c,
                 FS_Training_Comment__c,FS_Platform1_Qty__c,FS_Platform2_Qty__c,FS_Platform3_Qty__c,
                 FS_Water_Filter_Model_no__c,FS_What_type_of_outlet_install__c,FS_What_type_of_Site_Assessment__c,FS_Select_Site_assessment_contact__r.Name,
                 FS_Any_Crew_Serve_Dispensers__c,FS_Select_Site_assessment_contact__r.FS_Title__c,FS_Select_Site_assessment_contact__r.Phone,FS_Select_Site_assessment_contact__r.FS_Alternate_Phone_Cell__c,
                 FS_Select_Site_assessment_contact__r.Email,FS_Ancillary_equipment_needed__c,FS_Dispenser_Comments__c,FS_Secondary_Site_Assessment_Contact__r.Email,
                 FS_Secondary_Site_Assessment_Contact__r.Name,FS_Secondary_Site_Assessment_Contact__r.FS_Title__c,FS_Secondary_Site_Assessment_Contact__r.Phone,FS_Secondary_Site_Assessment_Contact__r.FS_Alternate_Phone_Cell__c,
                 FS_Cartridge_Payment_Method__c,FS_Program_Fee_Payment_Method__c,FS_DryAccount_curently_no_dispnsd_accnt__c,FS_Product_Comment__c,
                 FS_Cartridge_Order_Method__c,FS_Total_VPO__c,FS_Order_Administrator__r.Name,FS_SA_Rescheduled_On_Date__c,
                 FS_Order_Administrator__r.FS_Title__c,FS_Order_Administrator__r.Email,FS_Order_Administrator__r.Phone,FS_Order_Standard_User__r.Name,
                 FS_Order_Standard_User__r.FS_Title__c,FS_Order_Standard_User__r.Email,FS_Order_Standard_User__r.Phone,FS_Name_of_Sweetener_Distributor__c,
                 FS_RemoveAllFTNLegacyServeDispensers__c,FS_Water_Filter_MFG__c,FS_SA_Unable_to_Complete_Reason__c,FS_Second_SA_Rescheduled_Reason__c,FS_SA_Rescheduled_Reason__c,
                 FS_Ancillary_equipment_to_remain_on_site__c,FS_ValidFill_Option__c,FS_Second_Site_Assessment_Completed_Date__c,FS_Second_SA_Scheduled_Date__c,FS_Second_SA_Scheduled_By__c,FS_Second_SA_Incomplete_reason__c,FS_Second_Work_Order_WO__c,FS_Second_JDE_Doc__c,FS_Second_Davaco_Order_Entered_Date_Time__c,FS_Second_Davaco_Order_Entered_By__c,FS_Second_Davaco_Order_Entered__c,FS_Second_Site_Prep_Contract_Received__c,FS_Second_GFE_Posted_Date__c,FS_Requested_Channel__c,FS_Distributor_Name_City_ST__c,FS_Distributor_City__c,FS_Distributor_State__c,FS_Mail_to_Zip_Code__c,FS_Mail_to_State__c,FS_Mail_to_City__c,FS_Delivery_Method__c,   
                 FS_Cup_Name_1__c,FS_Cup_Name_2__c,FS_Cup_Name_3__c,FS_Cup_Name_4__c,FS_Cup_Name_5__c,FS_Cup_Name_6__c,FS_Size_1__c,FS_Size_2__c,FS_Second_SA_Rescheduled_Date__c,
                 FS_Size_3__c,FS_Size_4__c,FS_Size_5__c,FS_Size_6__c,FS_Fluid_Ounces_1__c,FS_Fluid_Ounces_2__c,FS_Fluid_Ounces_3__c,FS_Fluid_Ounces_4__c,FS_Fluid_Ounces_5__c,FS_Fluid_Ounces_6__c,FS_Installation__c,
                 FS_Mail_to_Address__c,FS_Date_SA_to_be_completed_by__c,FS_Bill_to_Phone__c,FS_Is_Bill_to_Address_Same_as_Ship_to__c,FS_Bill_to_Zip_Code__c,FS_Bill_to_State__c,FS_Bill_to_City__c,FS_Bill_to_Country__c,FS_Bill_to_Address__c,FS_General_Contractor_Name__c from FS_CIF__c WHERE CIF_Head__c=:cifHeader];
        //iterating Cif line items to store outlet and mapping of CIF details 
        for(FS_CIF__c cif:cifList){
            cifDetailsMap.put(cif.CIF_Head__r.FS_EP__c+'-'+cif.FS_Account__c,cif);
            cifAccountMap.put(cif.FS_Account__c,cif);
            outletsSet.add(cif.FS_Account__c);
        }
        //querying of outlet records
        outletsList=Database.query(FSUtil.getSelectQuery('Account')+' WHERE ID=:outletsSet');        
        //for(Account a:outletsList){
        //     outletsMap.put(a.Id,a);
        // } 
        final Id exeId=customerInputHQ.FS_EP__c;
        //querying of execution plan record
        executionPlan=Database.query(FSUtil.getSelectQuery('FS_Execution_Plan__c')+' WHERE Id=:exeId');
        //querying of installation records
        installList=Database.query(FSUtil.getSelectQuery('FS_Installation__c')+' WHERE FS_Execution_Plan__c=:exeId');
        for(FS_Installation__c install:installList){
            installDetailsMap.put(install.FS_Execution_Plan__c+'-'+install.FS_Outlet__c,install);
            installSetId.add(install.Id);
        }
        ipTechInstruction=Database.query(FSUtil.getSelectQuery('FS_IP_Technician_Instructions__c')+' WHERE FS_Instalation_Process__c IN :installSetId');
        //calling methods to update installation and outlet records
        mapIPPlatformValues();
        mapCIFIPValues();
        mapCIFOutlet();
        //updating of installations
        if(!updateInstall.isEmpty()){
            update updateInstall;
        }
        for(FS_Installation__c install:updateInstall){
            installMap.put(install.Id,install);
        }
        //populate IP values to TI
        mapIPToTechInstr(installMap,ipTechInstruction);
        //updating of outlet records
        if(!outletsList.isEmpty()){
            update outletsList;
        }
        if(executionPlan!=null){
            executionPlan.FS_CIF_Header__c=customerInputHQ.Id;                    
            executionPlan.FS_FPS__c=customerInputHQ.FS_FPS__c;
            executionPlan.FS_Back_up_COM__c=customerInputHQ.FSCOM__r.UserId__c;                                    
            executionPlan.FS_Sales_Lead__c=customerInputHQ.FS_Sales_Rep_Name__r.UserId__c;
            executionPlan.FS_Headquarters__c =customerInputHQ.FS_HQ__c;
            update executionPlan;
        }
        if(customerInputHQ!=null){
            customerInputHQ.FS_Status__c='Closed – Converted to EP';
            customerInputHQ.FS_Reparent_CIF__c = false;
            update customerInputHQ;
        }
    }
    
    //assign the Installation values to tech Instruction
    public static void mapIPToTechInstr(final Map<String,FS_Installation__c> installMap,final List<FS_IP_Technician_Instructions__c> ipTechInstruction){
        for(FS_IP_Technician_Instructions__c techinst:ipTechInstruction){
            if(installMap.ContainsKey(techinst.FS_Instalation_Process__c)){   
                final FS_Installation__c inst=installMap.get(techinst.FS_Instalation_Process__c);
                techinst.FS_Water_Filter_Contact_Email__c = inst.FS_Water_Filter_Contact_Email__c;
                techinst.FS_Water_Filter_Contact_Name__c = inst.FS_Water_Filter_Contact_Name__c;
                techinst.FS_Water_Filter_Contact_Phone__c = inst.FS_Water_Filter_Contact_Phone__c;
                techinst.FS_Water_Filter_MFG__c = inst.FS_Water_Filter_MFG__c;
                techinst.FS_Water_Filter_Model_no__c = inst.FS_Water_Filter_Model_no__c;
                techinst.Water_Filter_Installer_Email__c = inst.Water_Filter_Installer_Email__c;
                techinst.Water_Filter_Installer_Name__c = inst.Water_Filter_Installer_Name__c;
                techinst.Water_Filter_Installer_Phone__c = inst.Water_Filter_Installer_Phone__c;
                techinst.FS_Who_will_install_Water_Filter__c= inst.FS_Who_will_install_Water_Filter__c;
                if(techinst.recordTypeId!=FSInstallationValidateAndSet.ipTIrecType9000){
                    /* Commenting Cup Name,Size,Finished Ounces bcoz of removing frm layout -- FET5.1
                    techinst.FS_Size_1__c=inst.FS_Size_1__c;
                    techinst.FS_Size_2__c=inst.FS_Size_2__c;
                    techinst.FS_Size_3__c=inst.FS_Size_3__c;
                    techinst.FS_Size_4__c=inst.FS_Size_4__c;
                    techinst.FS_Size_5__c=inst.FS_Size_5__c;
                    techinst.FS_Size_6__c=inst.FS_Size_6__c;
                    techinst.FS_Cup_Name_1__c=inst.FS_Cup_Name_1__c;
                    techinst.FS_Cup_Name_2__c=inst.FS_Cup_Name_2__c;
                    techinst.FS_Cup_Name_3__c=inst.FS_Cup_Name_3__c;
                    techinst.FS_Cup_Name_4__c=inst.FS_Cup_Name_4__c;
                    techinst.FS_Cup_Name_5__c=inst.FS_Cup_Name_5__c;
                    techinst.FS_Cup_Name_6__c=inst.FS_Cup_Name_6__c;
                    techinst.FS_Finished_Ounces_1__c=inst.FS_Finished_Ounces_1__c;
                    techinst.FS_Finished_Ounces_2__c=inst.FS_Finished_Ounces_2__c;
                    techinst.FS_Finished_Ounces_3__c=inst.FS_Finished_Ounces_3__c;
                    techinst.FS_Finished_Ounces_4__c=inst.FS_Finished_Ounces_4__c;
                    techinst.FS_Finished_Ounces_5__c=inst.FS_Finished_Ounces_5__c;
                    techinst.FS_Finished_Ounces_6__c=inst.FS_Finished_Ounces_6__c;*/
                }
                techinst.FS_Time_to_call_home__c=inst.FS_Time_to_call_home__c;
                techinst.FS_Top_Off_Button__c=inst.FS_Top_Off_Button__c;
                techinst.FS_Customer_Ice_Fill_Spec__c=inst.FS_Customer_Ice_Fill_Spec__c;
            }            
        }
        if(!ipTechInstruction.isEmpty()){
            update ipTechInstruction;
        }        
    }
    
    //assign the CIF Platform values to IP platform values
    public static void mapIPPlatformValues(){
        for(FS_CIF__c cif:cifList){
            if(installDetailsMap.containsKey(cif.CIF_Head__r.FS_EP__c+'-'+cif.FS_Account__c)){
                final FS_Installation__c install= installDetailsMap.get(cif.CIF_Head__r.FS_EP__c+'-'+cif.FS_Account__c);
                if(cif.FS_Platform1__c=='7000' && install.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType){
                    
                    install.FS_Brandset__c=cif.FS_Brandset1__c;                   
                    //install.FS_Planned_SelfServe_TopMount_Ice_Makers__c=cif.FS_7000_Series_Top_Mnt_Ice_Maker_Instld__c;               
                }
                else if(cif.FS_Platform1__c=='8000' && install.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType){
                    
                    install.FS_Brandset_8k__c=cif.FS_Brandset1__c;                                                        
                }
                else if(cif.FS_Platform1__c=='9000' && install.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType){
                    
                    install.FS_Brandset_9k__c=cif.FS_Brandset1__c;                                    
                    //install.FS_Planned_SelfServe_TopMount_Ice_Makers__c=cif.FS_Self_Serve_Top_Mnt_Ice_Maker_Instld__c;
                }
                if(cif.FS_Platform1__c=='9000' && cif.FS_Platform2__c=='8000' && install.RecordTypeId==FSInstallationValidateAndSet.ipNewRecType){
                    
                    install.FS_Brandset_9k__c=cif.FS_Brandset1__c;                   
                    
                    install.FS_Brandset_8k__c=cif.FS_Brandset2__c;                                                     
                    //install.FS_Planned_SelfServe_TopMount_Ice_Makers__c=cif.FS_Self_Serve_Top_Mnt_Ice_Maker_Instld__c;
                }
                updateInstall.add(install);
            }           
        }
        
    }
    //update the installation fields with cif data
    public static void mapCIFIPValues(){        
        
        final List<String> pickListPercent=new List<String>{'33%','50%','66%','75%','Full'};
            for(FS_Installation__c inst:updateInstall){
                if(cifDetailsMap.containsKey(inst.FS_Execution_Plan__c+'-'+inst.FS_Outlet__c)){
                    final FS_CIF__c outAcc=cifDetailsMap.get(inst.FS_Execution_Plan__c+'-'+inst.FS_Outlet__c);
                    if(inst.recordTypeId!=FSInstallationValidateAndSet.ipNewRecType){
                        /* Commenting Cup Name,Size,Finished Ounces bcoz of removing frm layout -- FET5.1
                        inst.FS_Cup_Name_1__c=outAcc.FS_Cup_Name_1__c;
                        inst.FS_Cup_Name_2__c=outAcc.FS_Cup_Name_2__c;
                        inst.FS_Cup_Name_3__c=outAcc.FS_Cup_Name_3__c;
                        inst.FS_Cup_Name_4__c=outAcc.FS_Cup_Name_4__c;
                        inst.FS_Cup_Name_5__c=outAcc.FS_Cup_Name_5__c;
                        inst.FS_Cup_Name_6__c=outAcc.FS_Cup_Name_6__c;
                        inst.FS_Size_1__c=outAcc.FS_Size_1__c;
                        inst.FS_Size_2__c=outAcc.FS_Size_2__c;
                        inst.FS_Size_3__c=outAcc.FS_Size_3__c;
                        inst.FS_Size_4__c=outAcc.FS_Size_4__c;
                        inst.FS_Size_5__c=outAcc.FS_Size_5__c;
                        inst.FS_Size_6__c=outAcc.FS_Size_6__c;
                        inst.FS_Finished_Ounces_1__c=String.valueOf(outAcc.FS_Fluid_Ounces_1__c);
                        inst.FS_Finished_Ounces_2__c=String.valueOf(outAcc.FS_Fluid_Ounces_2__c);
                        inst.FS_Finished_Ounces_3__c=String.valueOf(outAcc.FS_Fluid_Ounces_3__c);
                        inst.FS_Finished_Ounces_4__c=String.valueOf(outAcc.FS_Fluid_Ounces_4__c);
                        inst.FS_Finished_Ounces_5__c=String.valueOf(outAcc.FS_Fluid_Ounces_5__c);
                        inst.FS_Finished_Ounces_6__c=String.valueOf(outAcc.FS_Fluid_Ounces_6__c);*/                   
                    }                
                    inst.FS_Time_to_call_home__c=outAcc.FS_Time_to_call_home__c;
                    inst.FS_COM_Regular__c=executionPlan.FS_Back_up_COM__c;//OCR
                    inst.FS_Sales_Lead__c=executionPlan.FS_Sales_Lead__c;//OCR
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
                    //inst.FS_JDE_Doc__c=outAcc.FS_JDE_Doc__c;
                    //inst.FS_Doc__c=outAcc.FS_JDE_Doc__c;
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
                    inst.FS_JDE_Doc_Second_survey__c = outAcc.FS_Second_JDE_Doc__c;
                    inst.FS_Second_Work_Order_WO__c = outAcc.FS_Second_Work_Order_WO__c;
                    inst.FS_SA_Completion_By_Date__c = outAcc.FS_Date_SA_to_be_completed_by__c;
                    //Site survey results section
                    //Installation Section
                    inst.FS_Requested_Install_Period__c=outAcc.FS_Requested_Install_Period__c;
                    inst.FS_Requested_Install_Date__c = outAcc.FS_Requested_Install_Date__c;
                    inst.FS_Coordination_To_Be_Done_By__c = outAcc.FS_Contractor_Coordination_to_be_done_by__c;
                    inst.FS_GC_Coordination_to_be_done_by__c = outAcc.FS_Contractor_Coordination_to_be_done_by__c;
                    inst.FS_Day_AM_or_Night_PM_Installation__c =outAcc.FS_Day_AM_or_Night_PM_Installation__c;               
                    
                    inst.FS_Outlet_Contact__c=outAcc.FS_Outlet_Contact__r.Name;
                    inst.FS_Outlet_Contact_Email__c=outAcc.FS_Outlet_Contact__r.Email;
                    inst.FS_Outlet_Contact_Phone__c=outAcc.FS_Outlet_Contact__r.Phone;
                    inst.FS_General_Contractor_Contact_Name__c = outAcc.FS_Contractor_Contact__r.Name;
                    inst.FS_General_Contractor_Contact_Email__c= outAcc.FS_Contractor_Contact__r.Email;
                    inst.FS_General_Contractor_Contact_Phone__c= outAcc.FS_Contractor_Contact__r.Phone;
                    inst.FS_NewRemodelOutletOnlyProjectedOpening__c = outAcc.FS_NewRemodelOutletOnlyProjectedOpening__c;
                    inst.FS_NewRemodelOutletOnlyProjectedFireUp__c = outAcc.FS_NewRemodelOutletOnlyProjectedFireUp__c;
                    inst.FS_NewRemodelOutletOnlyLineInstallation__c = outAcc.FS_NewRemodelOutletOnlyLineInstallation__c;
                    inst.FS_NewRemodelOutletOnlyEquipmentInstall__c = outAcc.FS_NewRemodelOutletOnlyEquipmentInstall__c;
                    //Installation Section
                    //Ice water section   
                    inst.FS_Wired_Solution_Required__c=outAcc.FS_Wired_Solutions_Required__c;
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
                    if(outAcc.FS_On_Boarding_Days_after_Install__c!=null){
                        inst.FS_HowManyDaysAfterInstallOnboarding__c=decimal.valueOf(outAcc.FS_On_Boarding_Days_after_Install__c);
                    }
                    inst.FS_Training_Start_Time__c=outAcc.FS_Select_On_Boarding_Start_Time__c;
                    inst.Outlet_Open_Time__c = outAcc.FS_On_boarding_time_requested__c;
                    inst.OB_Outlet_Contact__c = outAcc.FS_On_Boarding_Contact__r.Name;
                    inst.FS_OB_Outlet_Contact_Phone__c = outAcc.FS_On_Boarding_Contact__r.Phone;
                    inst.FS_OB_Outlet_Contact_Email__c = outAcc.FS_On_Boarding_Contact__r.Email;
                    inst.FS_OB_Comments__c=outAcc.FS_Training_Comment__c;
                    inst.FS_What_type_of_outlet_install__c=outAcc.FS_What_type_of_outlet_install__c;                
                    inst.FS_Site_Assessment_Contact_name__c = outAcc.FS_Select_Site_assessment_contact__r.Name;
                    inst.FS_Site_Assessment_Contact_Title__c = outAcc.FS_Select_Site_assessment_contact__r.FS_Title__c;
                    inst.FS_Site_Assessment_Contact_Phone__c = outAcc.FS_Select_Site_assessment_contact__r.Phone;
                    inst.FS_Site_Assessment_Contact_Cell__c = outAcc.FS_Select_Site_assessment_contact__r.FS_Alternate_Phone_Cell__c;
                    inst.FS_Site_Assessment_contact_email__c =outAcc.FS_Select_Site_assessment_contact__r.Email;
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
    }
    //update the outlet records with cif data
    public static void mapCIFOutlet(){
        for(Account outlet:outletsList){
            if(cifAccountMap.containsKey(outlet.Id)){
                final FS_CIF__C outAcc=cifAccountMap.get(outlet.Id);                
                outlet.FS_Requested_Channel__c=outAcc.FS_Requested_Channel__c; 
                outlet.FS_Requested_Order_Method__c=outAcc.FS_Cartridge_Order_Method__c;
                outlet.Cokesmart_Payment_Method__c=outAcc.FS_Cartridge_Payment_Method__c;
                outlet.FS_Payment_Method__c=outAcc.FS_Program_Fee_Payment_Method__c;
                outlet.FS_Estimated_Annual_Volume_gallons__c=outAcc.FS_Total_VPO__c;                
                outlet.FS_Dr_Pepper_pct__c=outAcc.FS_Pepper_Mix__c;
                outlet.FS_Admin_User_Name__c = outAcc.FS_Order_Administrator__r.Name;
                outlet.FS_Admin_User_Title__c =  outAcc.FS_Order_Administrator__r.FS_Title__c;
                outlet.FS_Admin_User_Email__c =  outAcc.FS_Order_Administrator__r.Email;
                outlet.FS_Admin_User_Phone__c = outAcc.FS_Order_Administrator__r.Phone;
                outlet.FS_Standard_User__c = outAcc.FS_Order_Standard_User__r.Name;
                outlet.FS_Standard_User_Function__c = outAcc.FS_Order_Standard_User__r.FS_Title__c;
                outlet.FS_Standard_User_Email__c =  outAcc.FS_Order_Standard_User__r.Email;
                outlet.FS_Standard_User_Phone__c =outAcc.FS_Order_Standard_User__r.Phone;
                outlet.FS_Name_of_Sweetener_Distributor__c=outAcc.FS_Name_of_Sweetener_Distributor__c;
                if(outAcc.FS_Cartridge_Order_Method__c!='Distributor'){
                    outlet.FS_VMS_Customer__c=outAcc.FS_Cartridge_Order_Method__c;   
                }
                outlet.FS_CS_All_Ftn_Removed__c =  outAcc.FS_RemoveAllFTNLegacyServeDispensers__c;
                outlet.FS_Distributor_Name__c=outAcc.FS_Distributor_Name_City_ST__c;
                outlet.FS_Distributor_City__c=outAcc.FS_Distributor_City__c;
                outlet.FS_Distributor_State__c=outAcc.FS_Distributor_State__c;
                outlet.FS_Water_Filter_MFG__c=outAcc.FS_Water_Filter_MFG__c;
                outlet.FS_Requested_Delivery_Method__c = outAcc.FS_Delivery_Method__c ;
                outlet.FS_CS_Bill_To_Address__c = outAcc.FS_Bill_to_Address__c;
                outlet.FS_CS_Bill_To_City__c =   outAcc.FS_Bill_to_City__c;
                outlet.FS_CS_State__c = outAcc.FS_Bill_to_State__c;
                outlet.FS_CS_Bill_To_Zip__c = outAcc.FS_Bill_to_Zip_Code__c;
            }
        }
    }
    
    public static void updateReparentedInst(Id cifHeader){
        System.debug('*********** Method Ep Update Installation Data::');
        customerInputHQ=new CIF_Header__c();
        executionPlan=new FS_Execution_Plan__c();
        updateInstall=new List<FS_Installation__c>();
        cifList=new List<FS_CIF__c>();
        outletsList=new List<Account>();
        installList=new List<FS_Installation__c>();
        ipTechInstruction=new List<FS_IP_Technician_Instructions__c>();
        Set<Id> outletsSet=new Set<Id>();
        Set<Id> installSetId=new Set<Id>();
        //outletsMap=new Map<String,Account>();
        cifDetailsMap=new Map<String,FS_CIF__c>();
        cifAccountMap=new Map<String,FS_CIF__c>();
        installDetailsMap=new Map<String,FS_Installation__c>();
        installMap=new Map<String,FS_Installation__c>();
        //CIF Header query
        
        
        customerInputHQ=[select id,Name,FSCOM__r.UserId__c,FS_EP__c,FS_FPS__c,FS_HQ__c,FS_HQ__r.Name,FS_Original_CIF_Head__c,FS_Sales_Rep_Name__r.UserId__c,FS_Status__c,FS_Version__c from CIF_Header__c where id=:cifHeader];        
        
        //CIF Line Items Query
        cifList=[SELECT Id,FS_EP_Check__c,CIF_Head__r.FS_EP__c,FS_Account__c,
                 FS_On_Boarding_Contact__r.Name,FS_On_Boarding_Contact__r.Phone,FS_On_Boarding_Contact__r.Email,
                 FS_Outlet_Contact__r.Name,FS_Outlet_Contact__r.Email,FS_Outlet_Contact__r.Phone,
                 FS_Contractor_Contact__r.Name,FS_Contractor_Contact__r.Email,FS_Contractor_Contact__r.Phone,
                 Water_Filter_Installer_Name__r.name,Water_Filter_Installer_Name__r.Phone,Water_Filter_Installer_Name__r.Email, FS_Water_Filter_Contact_Name__r.Email,FS_Water_Filter_Contact_Name__r.Phone,FS_Water_Filter_Contact_Name__r.Name,FS_Select_Site_assessment_contact__r.Name,FS_Select_Site_assessment_contact__r.FS_Title__c,FS_Select_Site_assessment_contact__r.Phone,FS_Select_Site_assessment_contact__r.FS_Alternate_Phone_Cell__c,FS_Select_Site_assessment_contact__r.Email,FS_Order_Administrator__r.Name,
                 FS_Order_Administrator__r.FS_Title__c,FS_Order_Administrator__r.Email,FS_Order_Administrator__r.Phone,FS_Order_Standard_User__r.Name,
                 FS_Order_Standard_User__r.FS_Title__c,FS_Order_Standard_User__r.Email,FS_Order_Standard_User__r.Phone,FS_Secondary_Site_Assessment_Contact__r.name,FS_Secondary_Site_Assessment_Contact__r.Email,FS_Secondary_Site_Assessment_Contact__r.phone,
                 FS_Secondary_Site_Assessment_Contact__r.FS_Alternate_Phone_Cell__c,FS_Secondary_Site_Assessment_Contact__r.FS_Title__c from FS_CIF__c WHERE CIF_Head__c=:cifHeader];
        //iterating Cif line items to store outlet and mapping of CIF details 
        for(FS_CIF__c cif:cifList){
            cifDetailsMap.put(cif.CIF_Head__r.FS_EP__c+'-'+cif.FS_Account__c,cif);
            cifAccountMap.put(cif.FS_Account__c,cif);
            outletsSet.add(cif.FS_Account__c);
        }
        //querying of outlet records
        outletsList=Database.query(FSUtil.getSelectQuery('Account')+' WHERE ID=:outletsSet');        
        Id exeId=customerInputHQ.FS_EP__c;
        //querying of execution plan record from reparented CIF's
        executionPlan=Database.query(FSUtil.getSelectQuery('FS_Execution_Plan__c')+' WHERE Id=:exeId');
        //querying of installation records from reparented CIF's
        installList=Database.query(FSUtil.getSelectQuery('FS_Installation__c')+' WHERE FS_Execution_Plan__c=:exeId');
        for(FS_Installation__c install:installList){
            installDetailsMap.put(install.FS_Execution_Plan__c+'-'+install.FS_Outlet__c,install);
            installSetId.add(install.Id);
        }
        ipTechInstruction=Database.query(FSUtil.getSelectQuery('FS_IP_Technician_Instructions__c')+' WHERE FS_Instalation_Process__c IN :installSetId');
        //calling methods to update installation and outlet records
        if(executionPlan!=null){
            executionPlan.FS_CIF_Header__c=customerInputHQ.Id;                    
            executionPlan.FS_FPS__c=customerInputHQ.FS_FPS__c;
            executionPlan.FS_Headquarters__c = customerInputHQ.FS_HQ__c;
            executionPlan.FS_Back_up_COM__c=customerInputHQ.FSCOM__r.UserId__c;                                    
            executionPlan.FS_Sales_Lead__c=customerInputHQ.FS_Sales_Rep_Name__r.UserId__c;  
            update executionPlan;
        }
        mapMigIPPlatformValues();
        mapMigCIFIPValues();
        mapMigCIFOutlet();
        //updating of installations from reparented CIF's
        if(!updateInstall.isEmpty()){
            update updateInstall;            
        }
        for(FS_Installation__c install:updateInstall){
            installMap.put(install.Id,install);
        }
        //populate IP values to TI from reparented CIF's
        mapMigIPToTechInstr(installMap,ipTechInstruction);
        //updating of outlet records
        if(!outletsList.isEmpty()){
            update outletsList;
        }
        
        
        if(customerInputHQ!=null){
            customerInputHQ.FS_Status__c='Closed – Converted to EP';
            customerInputHQ.FS_Reparent_CIF__c= false;
            update customerInputHQ;
        }
    }
    
    //assign the Installation values to tech Instruction from reparented CIF's
    public static void mapMigIPToTechInstr(Map<String,FS_Installation__c> installMap,List<FS_IP_Technician_Instructions__c> ipTechInstruction){
        for(FS_IP_Technician_Instructions__c techinst:ipTechInstruction){
            if(installMap.ContainsKey(techinst.FS_Instalation_Process__c)){   
                FS_Installation__c inst=installMap.get(techinst.FS_Instalation_Process__c);
                techinst.FS_Water_Filter_Contact_Email__c = inst.FS_Water_Filter_Contact_Email__c;
                techinst.FS_Water_Filter_Contact_Name__c = inst.FS_Water_Filter_Contact_Name__c;
                techinst.FS_Water_Filter_Contact_Phone__c = inst.FS_Water_Filter_Contact_Phone__c;
                techinst.Water_Filter_Installer_Email__c = inst.Water_Filter_Installer_Email__c;
                techinst.Water_Filter_Installer_Name__c = inst.Water_Filter_Installer_Name__c;
                techinst.Water_Filter_Installer_Phone__c = inst.Water_Filter_Installer_Phone__c;
            }            
        }
        if(!ipTechInstruction.isEmpty()){
            update ipTechInstruction;
        }        
    }
    public static void mapMigIPPlatformValues(){
        for(FS_CIF__c cif:cifList){
            if(installDetailsMap.containsKey(cif.CIF_Head__r.FS_EP__c+'-'+cif.FS_Account__c)){
                FS_Installation__c install= installDetailsMap.get(cif.CIF_Head__r.FS_EP__c+'-'+cif.FS_Account__c);
                updateInstall.add(install);
            }           
        }
    }
    //update the installation fields with cif data from reparented CIF's
    public static void mapMigCIFIPValues(){        
        for(FS_Installation__c inst:updateInstall){
            if(cifDetailsMap.containsKey(inst.FS_Execution_Plan__c+'-'+inst.FS_Outlet__c)){
                FS_CIF__c outAcc=cifDetailsMap.get(inst.FS_Execution_Plan__c+'-'+inst.FS_Outlet__c);
                
                inst.FS_COM_Regular__c=executionPlan.FS_Back_up_COM__c;//OCR
                inst.FS_Sales_Lead__c=executionPlan.FS_Sales_Lead__c;//OCR
                
                //Installation Section
                inst.FS_Outlet_Contact__c=outAcc.FS_Outlet_Contact__r.Name;
                inst.FS_Outlet_Contact_Email__c=outAcc.FS_Outlet_Contact__r.Email;
                inst.FS_Outlet_Contact_Phone__c=outAcc.FS_Outlet_Contact__r.Phone;
                inst.FS_General_Contractor_Contact_Name__c = outAcc.FS_Contractor_Contact__r.Name;
                inst.FS_General_Contractor_Contact_Email__c= outAcc.FS_Contractor_Contact__r.Email;
                inst.FS_General_Contractor_Contact_Phone__c= outAcc.FS_Contractor_Contact__r.Phone;
                
                //Installation Section
                //Ice water section   
                inst.FS_Water_Filter_Contact_Email__c=outAcc.FS_Water_Filter_Contact_Name__r.Email;
                inst.FS_Water_Filter_Contact_Name__c=outAcc.FS_Water_Filter_Contact_Name__r.Name;
                inst.FS_Water_Filter_Contact_Phone__c=outAcc.FS_Water_Filter_Contact_Name__r.Phone;
                inst.Water_Filter_Installer_Email__c=outAcc.Water_Filter_Installer_Name__r.Email;
                inst.Water_Filter_Installer_Name__c=outAcc.Water_Filter_Installer_Name__r.Name;
                inst.Water_Filter_Installer_Phone__c=outAcc.Water_Filter_Installer_Name__r.Phone;                
                //Ice water section
                inst.OB_Outlet_Contact__c = outAcc.FS_On_Boarding_Contact__r.Name;
                inst.FS_OB_Outlet_Contact_Phone__c = outAcc.FS_On_Boarding_Contact__r.Phone;
                inst.FS_OB_Outlet_Contact_Email__c = outAcc.FS_On_Boarding_Contact__r.Email;
                
                inst.FS_Site_Assessment_Contact_name__c = outAcc.FS_Select_Site_assessment_contact__r.Name;
                inst.FS_Site_Assessment_Contact_Title__c = outAcc.FS_Select_Site_assessment_contact__r.FS_Title__c;
                inst.FS_Site_Assessment_Contact_Phone__c = outAcc.FS_Select_Site_assessment_contact__r.Phone;
                inst.FS_Site_Assessment_Contact_Cell__c = outAcc.FS_Select_Site_assessment_contact__r.FS_Alternate_Phone_Cell__c;
                inst.FS_Site_Assessment_contact_email__c =outAcc.FS_Select_Site_assessment_contact__r.Email; 
                inst.FS_Scndry_Site_Assmnt_Cnct_name__c = outAcc.FS_Secondary_Site_Assessment_Contact__r.name;
                inst.FS_Sec_Site_Assessment_Cnct_Title__c =outAcc.FS_Secondary_Site_Assessment_Contact__r.FS_Title__c;
                inst.FS_Secondary_Contact_Email_Address__c = outAcc.FS_Secondary_Site_Assessment_Contact__r.Email;
                inst.FS_Scndry_Site_Assmnt_cnct_cell__c = outAcc.FS_Secondary_Site_Assessment_Contact__r.Phone;
                inst.FS_Scndry_Site_Assmnt_cnct_ofc__c = outAcc.FS_Secondary_Site_Assessment_Contact__r.FS_Alternate_Phone_Cell__c;
            }            
        }
    }
    //update the outlet records with cif data from reparented CIF's
    public static void mapMigCIFOutlet(){
        for(Account outlet:outletsList){
            if(cifAccountMap.containsKey(outlet.Id)){
                FS_CIF__C outAcc=cifAccountMap.get(outlet.Id);                
                outlet.FS_Admin_User_Name__c = outAcc.FS_Order_Administrator__r.Name;
                outlet.FS_Admin_User_Title__c =  outAcc.FS_Order_Administrator__r.FS_Title__c;
                outlet.FS_Admin_User_Email__c =  outAcc.FS_Order_Administrator__r.Email;
                outlet.FS_Admin_User_Phone__c = outAcc.FS_Order_Administrator__r.Phone;
                outlet.FS_Standard_User__c = outAcc.FS_Order_Standard_User__r.Name;
                outlet.FS_Standard_User_Function__c = outAcc.FS_Order_Standard_User__r.FS_Title__c;
                outlet.FS_Standard_User_Email__c =  outAcc.FS_Order_Standard_User__r.Email;
                outlet.FS_Standard_User_Phone__c =outAcc.FS_Order_Standard_User__r.Phone;
            }
        }
    }
    
}