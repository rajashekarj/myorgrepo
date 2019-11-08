/**************************************************************************************
Apex Class Name     : FSCustomerInputFormNewAndEdit
Version             : 1.0
Function            : This is a Helper class for FSCustomerInputFormController which will
handle all the common functionalities.
Modification Log    :
* Developer         : Deepak Jetty   
* Date              : 15 Jan 2017                
****************************************************************************************/

public class FSCustomerInputFormNewAndEdit {
    private Integer countCompleted=0;
    private Integer countNotCompleted=0;
    private Integer countNotStarted=0;
    public  String previousStage;
    public  String previousSec;
    public String[] searchOutletACNLst;
    public String searchOutletName='';
    public String searchOutletCity='';
    public String searchOutletACN='';
    public String searchOutletState='';
    public CIF_Header__c cifHead;
    public List<FS_Customer_Disp_After_SA__c> custDisSAs;
    public string valMedium ='Medium'; 
    public string valCust = 'Customer';
    public string valgetHQDetails ='getHQDetails';  
    public string valNA ='NA' ;
    public string valFSCIFNewandEdit ='FSCustomerInputFormNewAndEdit' ;
    public string valFET = 'FET';
    public boolean enabPerfSa = false;
    public List<WrpOutlet> lstOutletUpd; 
    public static object objNull(){return null;} 
    
    public List<String> setViewTrackerList1(List<String> viewTrackerList){
        viewTrackerList.add(FSConstants.SELECTOUTLETS);
        viewTrackerList.add(FSConstants.SALESREPINFO);
        viewTrackerList.add(FSConstants.SITESURVEYREQUEST);
        viewTrackerList.add(FSConstants.SITESURVEYRESULTS);
        viewTrackerList.add(FSConstants.Installation);
        viewTrackerList.add(FSConstants.DispenserEquipment);
        return viewTrackerList;
    }
    //6-10 Section Names
    public List<String> setViewTrackerList2(List<String> viewTrackerList){
        viewTrackerList.add(FSConstants.ICEMAKERWATERFILTER);
        viewTrackerList.add(FSConstants.PRODUCT);
        viewTrackerList.add(FSConstants.TRAINING);    
        viewTrackerList.add(FSConstants.FINANCE);
        viewTrackerList.add(FSConstants.SUMMARY);
        return viewTrackerList;     
    }
    //0-10 Section Status //
    /* ------------------------
1. Not Started - Red
2. In Progress - Yellow
3. Completed - Green
-------------------------
*/
    
    /*****************************************************************
Method: setViewStateTracketList()
Description: setViewStateTracketList method will set the chevron status for each section.
*******************************************************************/
    public Map<String,String> setViewStateTracketList(Map<String,String> viewStateTrackerList){
        viewStateTrackerList.put(FSConstants.SELECTOUTLETS, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.SALESREPINFO, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.SITESURVEYREQUEST, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.SITESURVEYRESULTS, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.INSTALLATION, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.DISPENSEREQUIPMENT,FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.ICEMAKERWATERFILTER, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.PRODUCT, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.TRAINING, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.FINANCE, FSConstants.NOTSTARTED);
        viewStateTrackerList.put(FSConstants.SUMMARY, FSConstants.NOTSTARTED);
        return viewStateTrackerList;
    }
    
    public List<WrpOutlet> getCIFMap(Map<Id,FS_CIF__c> mapOut,List<WrpOutlet> lstOutlet){
        for(WrpOutlet wrp: lstOutlet){
            if(mapOut.containskey(wrp.outlet.id)){                
                wrp.cif = mapout.get(wrp.outlet.id);                
            }
        }
        return lstOutlet;
    }
    
    //Updates current selected outlets
    public Set<id> updateSelection(Set<id> currentSelectedOutletIds,List<WrpOutlet> lstOutlet){
        for(WrpOutlet ow : lstOutlet) {
            //if(ow.isSelected!=null){
            if(ow.isSelected) {
                currentSelectedOutletIds.add(ow.outlet.Id);
            } else {
                currentSelectedOutletIds.remove(ow.outlet.Id);
            }
        }
        return currentSelectedOutletIds;
    }
    
    public CIF_Header__c getCIFHeaderDetails(String currentCIFId){
        CIF_Header__c cifHead;
        if(currentCIFId!=null && !String.isBlank(currentCIFId)){
            try{
                cifHead = [select id,name,Is_FET4_Migrated_CIF_Header__c,FS_EP__c,FS_CIF_Number__c,FSSales_Lead__c,FSCOM__c,FSCOM__r.Name,FSCOM__r.UserId__c,FSCOM__r.UserId__r.Name,FSSales_Lead__r.Name,FSSales_Lead__r.UserId__c,FSSales_Lead__r.UserId__r.Name,FS_HQ__c,FS_Sales_Rep_Name__c,FS_FPS__c,FS_FPS__r.Email,FS_FPS__r.Phone,FS_Sales_Rep_Name__r.UserId__c,FS_Sales_Rep_Name__r.UserId__r.name,FS_FPS__r.name, FS_Sales_Rep_Name__r.FS_Phone__c,FS_Sales_Rep_Name__r.FS_Email__c,FS_Version__c,FS_Reparent_CIF__c,FS_Status__c,FSCOM__r.FS_Email__c,FSCOM__r.FS_Phone__c from CIF_Header__c where id =: currentCIFId limit 1];
            }
            Catch(Exception e){
                ApexErrorLogger.addApexErrorLog(valFET,valFSCIFNewandEdit,'getCIFHeaderDetails','CIF Header',valMedium,e,valNA); 
            }
        }
        return cifHead;
    }
    
    //Get Head Quarter Customer Details
    public Account getHQDetails(ID hqAccountId){
        Account acc = new Account();
        try{acc = [Select Id,Name,OwnerId,FS_ACN__c,FS_Dr_Pepper_pct__c,FS_Payment_Type__c,Invoice_Customer__c,Cokesmart_Payment_Method__c,FS_Payment_Method__c,(SELECT Id, Name,FS_Platform__c,FS_Brandset__c FROM FSHeadquarters__r WHERE FS_Platform__c IN ('7000','8000','9000')) from Account where Id =: hqAccountId limit 1];
           }catch(QueryException e){
               ApexErrorLogger.addApexErrorLog(valFET,valFSCIFNewandEdit,valgetHQDetails,'acc',valMedium,e,valNA); 
           }
        return acc;
    }
    
    /*****************************************************************
Method: getSelectQueryForCustomerInput()
Description: getSelectQueryForCustomerInput method to get CIF Details
*******************************************************************/
    public String getSelectQueryForCustomerInput(){
        String csv = '';
        for(String field : Schema.getGlobalDescribe().get('FS_CIF__c').getDescribe().fields.getMap().keyset()){
            csv += field + ',';
        }
        csv += 'FS_Account__r.Invoice_Customer__c,FS_Account__r.FS_Payment_Type__c,FS_Account__r.BillingCountry,FS_Account__r.FS_Site_Assessment_Contact__c,FS_Account__r.BillingPostalCode, FS_Account__r.BillingState,FS_Account__r.FS_Legal_Entity_Name__c,FS_Account__r.BillingCity, FS_Outlet_Contact__r.Name, FS_Outlet_Contact__r.Email, FS_Outlet_Contact__r.Phone,FS_On_Boarding_Contact__r.Phone, FS_Account__r.FS_Final_Delivery_Method__c,FS_Account__r.FS_Final_Order_Method__c,' +
            'FS_Account__r.BillingStreet, FS_Account__r.Name ,FS_Account__r.RecordType.Name,FS_Contractor_Contact__r.Name,FS_Contractor_Contact__r.Phone,FS_Contractor_Contact__r.Email, FS_Water_Filter_Contact_Name__r.Email,FS_Water_Filter_Contact_Name__r.Phone, FS_On_Boarding_Contact__r.Email,FS_Order_Administrator__r.Phone,FS_Order_Standard_User__r.Phone,FS_Brandset1__r.name,FS_Brandset2__r.name,FS_Brandset3__r.name,FS_General_Contractor__r.name,'+
            'Water_Filter_Installer_Name__r.name,FS_Secondary_Site_Assessment_Contact__r.name,Water_Filter_Installer_Name__r.Email,FS_Brandset1__r.FS_Platform__c,FS_Brandset2__r.FS_Platform__c,FS_Brandset3__r.FS_Platform__c,Water_Filter_Installer_Name__r.Phone,FS_Water_Filter_Contact_Name__r.name,FS_Order_Standard_User__r.Name,FS_Order_Administrator__r.name,FS_On_Boarding_Contact__r.Name,FS_Select_Site_assessment_contact__r.Name,FS_Select_Site_assessment_contact__r.Title,FS_Select_Site_assessment_contact__r.FS_Title__c,'+
            'FS_Select_Site_assessment_contact__r.Phone,FS_Select_Site_assessment_contact__r.Email,FS_Select_Site_assessment_contact__r.FS_Alternate_Phone_Cell__c,FS_Order_Administrator__r.Email,FS_Order_Standard_User__r.Email,FS_Secondary_Site_Assessment_Contact__r.Phone,FS_Secondary_Site_Assessment_Contact__r.Email,FS_Secondary_Site_Assessment_Contact__r.FS_Alternate_Phone_Cell__c,FS_Secondary_Site_Assessment_Contact__r.FS_Title__c,FS_Secondary_Site_Assessment_Contact__r.Title,FS_RO4W1__r.Name,'+
            'FS_RO4W1__r.Type_of_Dispenser_Platform__c,FS_RO4W2__r.Name,FS_RO4W2__r.Type_of_Dispenser_Platform__c,FS_RO4W3__r.Name,FS_RO4W3__r.Type_of_Dispenser_Platform__c, '+
            'FS_Replacement_1__r.name,FS_Replacement_2__r.name,FS_Replacement_3__r.name';
        return 'Select ' + csv + ' From FS_CIF__c ';
    }
    
    public List<FS_CIF__c> getCIFLst(String currentCIFId){
        final String qryCustomerInput = getSelectQueryForCustomerInput() + ' Where CIF_Head__c =: currentCIFId';
        final List<FS_CIF__c> CIFLst = new List<FS_CIF__c>();
        for(FS_CIF__c cifObj : database.query(qryCustomerInput)){
            cifObj.FS_Invoice_Customer__c = cifObj.FS_Account__r.Invoice_Customer__c;
            if(cifObj.FS_Account__r.Invoice_Customer__c == null){
                cifObj.FS_Invoice_Customer__c = 'No';  
            }
            cifObj.FS_Payment_Type__c = cifObj.FS_Account__r.FS_Payment_Type__c;
            if(cifObj.FS_Account__r.FS_Payment_Type__c == null){
                cifObj.FS_Payment_Type__c = 'No'; 
            }
            CIFLst.add(cifObj);
        }
        return CIFLst;
    }
    
    public Boolean chevronNotiMessage(Map<String, String> viewStateTrackerList,String currentStage){
        Boolean notiSize=false;
        if(viewStateTrackerList.get(currentStage)==FSConstants.NOTSTARTED || viewStateTrackerList.get(currentStage)==FSConstants.INPROGRESS){
            notiSize = true;
        }
        return notiSize;
    }
    
    /*****************************************************************
Method: chevronStatus()
Description: chevronStatus method to set the Chevron status based on all manditory field on respective section
*******************************************************************/
    public Map<String, String> chevronStatus(Map<String, String> viewStateTrackerList,List<WrpOutlet> lstOutlet,CIF_Header__c cifHead,Map<Id,FS_CIF__c> mapOut, String sectionName,Boolean onLoadCheck){
        lstOutletUpd = new List<WrpOutlet>();
        if(onLoadCheck){
            for(WrpOutlet wrp:lstOutlet){
                if(wrp.isSelected){
                    lstOutletUpd.add(wrp);
                }
            }
            lstOutlet=lstOutletUpd;
        }
        previousSec = sectionName;
        if(lstOutlet!= objNull() && !lstOutlet.isEmpty()){
            if(sectionName==FSConstants.SECDISPENSEREQUIPMENT || onLoadCheck){
                previousStage= FSConstants.DISPENSEREQUIPMENT;
                for(WrpOutlet outAcc : lstOutlet){
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        if(((outAcc.cif.FS_Any_Crew_Serve_Dispensers__c == 'Yes' && outAcc.cif.FS_Portion_Control_Setting__c != null 
                             && outAcc.cif.FS_Customers_Ice_Fill_Policy__c != null && outAcc.cif.FS_Top_Off_Feature__c != null) ||
                            (outAcc.cif.FS_Any_Crew_Serve_Dispensers__c == 'No'))
                           && outAcc.cif.FS_Brandset1__c!= null && outAcc.cif.FS_Water1__c!=null && 
                           (outAcc.cif.FS_DryAccount_curently_no_dispnsd_accnt__c=='No' && outAcc.cif.FS_RemoveAllFTNLegacyServeDispensers__c != null &&
                            outAcc.cif.FS_Current_Fountain_Equipment_Ownership__c != null && outAcc.cif.FS_Disposition_of_Current_Equipment__c != null &&
                            outAcc.cif.FS_Disposition_of_Current_BIB_rack__c != null && outAcc.cif.FS_IndicateDispositionOfCurrentBIBPump__c != null) &&
                           (outAcc.cif.Does_Install_Involve_RO4W__c == 'No' || (outAcc.cif.Does_Install_Involve_RO4W__c == 'Yes' && outAcc.cif.FS_RO4W1__c!=NULL))
                           &&(outAcc.cif.FS_Does_Install_Involve_a_Replacement__c == 'No' || (outAcc.cif.FS_Does_Install_Involve_a_Replacement__c == 'Yes' && outAcc.cif.FS_Replacement_1__c!=NULL))
                           ){ //Added as part of FET-7.0 FNF 795
                               countCompleted++;
                               outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                           }
                        else if(((outAcc.cif.FS_Any_Crew_Serve_Dispensers__c == 'Yes' && outAcc.cif.FS_Portion_Control_Setting__c != null 
                                  && outAcc.cif.FS_Customers_Ice_Fill_Policy__c != null && outAcc.cif.FS_Top_Off_Feature__c != null) ||
                                 (outAcc.cif.FS_Any_Crew_Serve_Dispensers__c == 'No')) && outAcc.cif.FS_DryAccount_curently_no_dispnsd_accnt__c!=null &&    
                                outAcc.cif.FS_Brandset1__c!= null && outAcc.cif.FS_Water1__c!=null && (outAcc.cif.FS_DryAccount_curently_no_dispnsd_accnt__c=='Yes') 
                                && (outAcc.cif.Does_Install_Involve_RO4W__c == 'No'  || (outAcc.cif.Does_Install_Involve_RO4W__c == 'Yes' && outAcc.cif.FS_RO4W1__c!=NULL))
                                && (outAcc.cif.FS_Does_Install_Involve_a_Replacement__c == 'No'  || (outAcc.cif.FS_Does_Install_Involve_a_Replacement__c == 'Yes' && outAcc.cif.FS_Replacement_1__c!=NULL))
                                ){ //Added as part of FET-7.0 FNF 795
                                    countCompleted++;
                                    outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                                } else if(outAcc.cif.FS_Any_Crew_Serve_Dispensers__c == null && outAcc.cif.Does_Install_Involve_RO4W__c == null && outAcc.cif.FS_Does_Install_Involve_a_Replacement__c == null 
                                          && outAcc.cif.FS_RemoveAllFTNLegacyServeDispensers__c == null &&
                                          outAcc.cif.FS_Brandset1__c== null && outAcc.cif.FS_Water1__c==null && (outAcc.cif.FS_DryAccount_curently_no_dispnsd_accnt__c == null  && outAcc.cif.FS_RemoveAllFTNLegacyServeDispensers__c == null)
                                         ){//Added as part of FET-7.0 FNF 795
                                             countNotStarted++;
                                             outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATRED);
                                         } else {
                                             countNotCompleted++;
                                             outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                                         }
                    }
                }
                changeStatus(viewStateTrackerList,lstOutlet);
            }
            if(sectionName==FSConstants.SECINSTALLATION || onLoadCheck){
                previousStage= FSConstants.INSTALLATION;
                for(WrpOutlet outAcc : lstOutlet){
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        if(outAcc.cif.FS_Requested_Install_Period__c!= null && outAcc.cif.FS_Requested_Install_Date__c != null && outAcc.cif.FS_Day_AM_or_Night_PM_Installation__c != null &&
                           outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c != null && outAcc.cif.FS_General_Contractor_Name__c != null && ((outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c != valCust  && outAcc.cif.FS_Contractor_Contact__c != null) || (outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c == valCust  && (outAcc.cif.FS_Contractor_Contact__c == null || outAcc.cif.FS_Contractor_Contact__c != null))) && outAcc.cif.FS_Outlet_Contact__c != null){
                               countCompleted++;
                               outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                           }else if(outAcc.cif.FS_Requested_Install_Period__c== null && outAcc.cif.FS_Requested_Install_Date__c == null && outAcc.cif.FS_Day_AM_or_Night_PM_Installation__c == null &&
                                    outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c == null && outAcc.cif.FS_General_Contractor_Name__c == null && (outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c != valCust && outAcc.cif.FS_Contractor_Contact__c == null) && outAcc.cif.FS_Outlet_Contact__c == null){
                                        countNotStarted++;
                                        outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATRED);
                                    }else if(outAcc.cif.FS_Requested_Install_Period__c == null || outAcc.cif.FS_Requested_Install_Date__c == null || outAcc.cif.FS_Day_AM_or_Night_PM_Installation__c == null || outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c == null || outAcc.cif.FS_General_Contractor_Name__c == null || (outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c != valCust && outAcc.cif.FS_Contractor_Contact__c == null) || outAcc.cif.FS_Outlet_Contact__c== null){
                                        countNotCompleted++;
                                        outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                                    }
                    }
                }
                changeStatus(viewStateTrackerList,lstOutlet);
            }
            if(sectionName==FSConstants.SECTRAINING || onLoadCheck){
                previousStage = FSConstants.TRAINING;
                for(WrpOutlet outAcc : lstOutlet){
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        if(outAcc.cif.FS_OB_Trainer__c != null && outAcc.cif.FS_On_Boarding_Days_after_Install__c != null && 
                           outAcc.cif.FS_Select_On_Boarding_Start_Time__c != null &&
                           outAcc.cif.FS_On_boarding_time_requested__c != null && outAcc.cif.FS_On_Boarding_Contact__c != null){
                               countCompleted++; 
                               outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                           }else if(outAcc.cif.FS_OB_Trainer__c == null && outAcc.cif.FS_On_Boarding_Days_after_Install__c == null && 
                                    outAcc.cif.FS_Select_On_Boarding_Start_Time__c == null &&
                                    outAcc.cif.FS_On_boarding_time_requested__c == null && outAcc.cif.FS_On_Boarding_Contact__c == null){
                                        countNotStarted++;
                                        outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATRED);
                                    }else if(outAcc.cif.FS_OB_Trainer__c == null || outAcc.cif.FS_On_Boarding_Days_after_Install__c == null || 
                                             outAcc.cif.FS_Select_On_Boarding_Start_Time__c == null || outAcc.cif.FS_On_boarding_time_requested__c == null || outAcc.cif.FS_On_Boarding_Contact__c == null){
                                                 countNotCompleted++;
                                                 outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                                             }
                    }
                } 
                changeStatus(viewStateTrackerList,lstOutlet);           
            }
            if(sectionName==FSConstants.SECPRODUCT || onLoadCheck){
                previousStage = FSConstants.PRODUCT;
                for(WrpOutlet outAcc : lstOutlet){
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        if(outAcc.cif.FS_Name_of_Sweetener_Distributor__c != null && outAcc.cif.FS_Distributor_City__c != null && outAcc.cif.FS_Distributor_State__c != null && outAcc.cif.FS_Distributor_Name_City_ST__c!= null &&
                           outAcc.cif.FS_Order_Administrator__c != null && outAcc.cif.FS_Order_Standard_User__c != null && outAcc.cif.FS_Cartridge_Order_Method__c !=null && outAcc.cif.FS_Delivery_Method__c !=null){
                               countCompleted++;
                               outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                           }else if(outAcc.cif.FS_Name_of_Sweetener_Distributor__c == null && outAcc.cif.FS_Distributor_City__c == null && outAcc.cif.FS_Distributor_State__c == null && outAcc.cif.FS_Distributor_Name_City_ST__c == null &&
                                    outAcc.cif.FS_Order_Administrator__c == null && outAcc.cif.FS_Order_Standard_User__c == null && outAcc.cif.FS_Cartridge_Order_Method__c == null && outAcc.cif.FS_Delivery_Method__c ==null){
                                        countNotStarted++;
                                        outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATRED);
                                    }else if(outAcc.cif.FS_Name_of_Sweetener_Distributor__c == null || outAcc.cif.FS_Distributor_City__c == null || outAcc.cif.FS_Distributor_State__c == null || outAcc.cif.FS_Distributor_Name_City_ST__c == null ||
                                             outAcc.cif.FS_Order_Administrator__c == null || outAcc.cif.FS_Order_Standard_User__c == null || outAcc.cif.FS_Cartridge_Order_Method__c == null || outAcc.cif.FS_Delivery_Method__c ==null){
                                                 countNotCompleted++;
                                                 outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                                             }
                    }
                }
                changeStatus(viewStateTrackerList,lstOutlet);
            }
            if(sectionName==FSConstants.SECSITESURVEYREQUEST || onLoadCheck){
                previousStage= FSConstants.SITESURVEYREQUEST;
                for(WrpOutlet outAcc : lstOutlet){
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        //FET 7.1 Added Site Assessor Logic based on What type of Site Assessment for Green
                        if(outAcc.cif.FS_What_type_of_outlet_install__c != null && outAcc.cif.FS_Select_Site_assessment_contact__c != null &&
                           outAcc.cif.FS_Platform1__c != null && outAcc.cif.FS_Platform1_Qty__c != null && outAcc.cif.FS_Total_VPO__c != null &&
                           (outAcc.cif.FS_What_type_of_Site_Assessment__c != null && (outAcc.cif.FS_What_type_of_Site_Assessment__c==FSConstants.SANOTREQUIRED || outAcc.cif.FS_Site_Assessor__c!=null) ) &&
                           ((outAcc.cif.FS_Perf_Site_Assessment__c == 'Yes' && outAcc.cif.FS_Davaco_Order_Entered__c) 
                            || outAcc.cif.FS_Perf_Site_Assessment__c == 'No') //&& outAcc.cif.FS_JDE_Doc__c != null   //Modfied as part FET-7.0 FNF 722
                           && outAcc.cif.FS_Work_Order_WO__c != null && outAcc.cif.FS_Perf_Site_Assessment__c != null){
                               countCompleted++;
                               outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);  
                           }else if(outAcc.cif.FS_What_type_of_outlet_install__c == null && outAcc.cif.FS_Select_Site_assessment_contact__c == null &&
                                    outAcc.cif.FS_Platform1__c == null && outAcc.cif.FS_Platform1_Qty__c == null && outAcc.cif.FS_Total_VPO__c == null &&
                                    outAcc.cif.FS_What_type_of_Site_Assessment__c == null //&& outAcc.cif.FS_JDE_Doc__c == null //Modfied as part FET-7.0 FNF 722
                                    && outAcc.cif.FS_Work_Order_WO__c == null && 
                                    outAcc.cif.FS_Perf_Site_Assessment__c == null){
                                        countNotStarted++;
                                        outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATRED);
                                    }else if(outAcc.cif.FS_What_type_of_outlet_install__c == null || outAcc.cif.FS_Select_Site_assessment_contact__c == null || outAcc.cif.FS_Total_VPO__c == null ||
                                             outAcc.cif.FS_Platform1__c == null || outAcc.cif.FS_Platform1_Qty__c == null || outAcc.cif.FS_What_type_of_Site_Assessment__c == null || 
                                             //outAcc.cif.FS_JDE_Doc__c == null || //Modfied as part FET-7.0 FNF 722
                                             outAcc.cif.FS_Work_Order_WO__c == null || outAcc.cif.FS_Perf_Site_Assessment__c == null || 
                                             outAcc.cif.FS_What_type_of_Site_Assessment__c != null  ||
                                             (outAcc.cif.FS_Perf_Site_Assessment__c == 'Yes' && !outAcc.cif.FS_Davaco_Order_Entered__c)){
                                                 countNotCompleted++;
                                                 outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                                             } 
                        if(outAcc.cif.FS_What_type_of_outlet_install__c != null && outAcc.cif.FS_Select_Site_assessment_contact__c != null &&
                           outAcc.cif.FS_Platform1__c != null && outAcc.cif.FS_Platform1_Qty__c != null && outAcc.cif.FS_Total_VPO__c != null &&
                           outAcc.cif.FS_What_type_of_Site_Assessment__c != null){
                               outAcc.enabPerfSa = true; 
                           }else{
                               outAcc.enabPerfSa = false;
                           }
                    }
                }
                changeStatus(viewStateTrackerList,lstOutlet);
            }
            if(sectionName==FSConstants.SECICEMAKERWATERFILTER || onLoadCheck){
                previousStage= FSConstants.ICEMAKERWATERFILTER;
                for(WrpOutlet outAcc : lstOutlet){
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        if(outAcc.cif.FS_Kitchen_Ice_Fill_Requirements__c != null && outAcc.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c !=null && outAcc.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c !=null &&
                           outAcc.cif.FS_Who_will_coordinate_Ice_maker_Install__c != null && outAcc.cif.FS_WhoWillPerformRequiredIceMakerWork__c != null &&
                           outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c != null && outAcc.cif.FS_Water_Filter_MFG__c != null && 
                           outAcc.cif.FS_Water_Filter_Model_no__c != null && outAcc.cif.FS_Who_will_install_Water_Filter__c != null &&
                           outAcc.cif.Water_Filter_Installer_Name__c != null && outAcc.cif.FS_Water_Filter_Contact_Name__c != null &&
                           outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c == 'No - approved make/model to be installed'){
                               countCompleted++;
                               outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                           }else if(outAcc.cif.FS_Kitchen_Ice_Fill_Requirements__c != null && outAcc.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c !=null && outAcc.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c !=null &&
                                    outAcc.cif.FS_Who_will_coordinate_Ice_maker_Install__c != null && outAcc.cif.FS_WhoWillPerformRequiredIceMakerWork__c != null &&
                                    outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c != null && outAcc.cif.FS_Water_Filter_MFG__c != null && 
                                    outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c != 'No - approved make/model to be installed'  &&  
                                    outAcc.cif.FS_Water_Filter_Model_no__c != null){
                                        countCompleted++;
                                        outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                                    } 
                        else if(outAcc.cif.FS_Kitchen_Ice_Fill_Requirements__c == null && outAcc.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c ==null && outAcc.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c ==null &&
                                outAcc.cif.FS_Who_will_coordinate_Ice_maker_Install__c == null && outAcc.cif.FS_WhoWillPerformRequiredIceMakerWork__c == null &&
                                outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c == null && outAcc.cif.FS_Water_Filter_MFG__c == null && 
                                outAcc.cif.Water_Filter_Installer_Name__c == null && outAcc.cif.FS_Water_Filter_Model_no__c == null){
                                    countNotStarted++;
                                    outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATRED);
                                }
                        else if(outAcc.cif.FS_Kitchen_Ice_Fill_Requirements__c == null || outAcc.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c ==null || outAcc.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c ==null ||
                                outAcc.cif.FS_Who_will_coordinate_Ice_maker_Install__c == null || outAcc.cif.FS_WhoWillPerformRequiredIceMakerWork__c == null ||
                                outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c == null || outAcc.cif.FS_Water_Filter_MFG__c == null || outAcc.cif.FS_Water_Filter_Model_no__c == null || outAcc.cif.FS_Who_will_install_Water_Filter__c == null || outAcc.cif.FS_Water_Filter_Contact_Name__c == null || outAcc.cif.Water_Filter_Installer_Name__c == null){
                                    countNotCompleted++;
                                    outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                                }
                    }
                }
                changeStatus(viewStateTrackerList,lstOutlet);
            }
            if(sectionName==FSConstants.SECSITESURVEYRESULTS || onLoadCheck){
                previousStage= FSConstants.SITESURVEYRESULTS;
                for(WrpOutlet outAcc : lstOutlet){
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        if(outAcc.cif.FS_Customer_s_disposition_after_review__c == FSConstants.APPROVED){
                            countCompleted++;
                            outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                        }else if(outAcc.cif.FS_Customer_s_disposition_after_review__c == FSConstants.REVIEWAW || outAcc.cif.FS_Customer_s_disposition_after_review__c == FSConstants.AWTCUSTDEC || outAcc.cif.FS_Customer_s_disposition_after_review__c == FSConstants.REDFORCOM){
                            countNotCompleted++;
                            outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                        }
                        else if(outAcc.cif.FS_Customer_s_disposition_after_review__c != null && outAcc.cif.FS_Customer_s_disposition_after_review__c != FSConstants.REVIEWAW && outAcc.cif.FS_Customer_s_disposition_after_review__c != FSConstants.APPROVED && outAcc.cif.FS_Customer_s_disposition_after_review__c != FSConstants.SCNDSSPEN){
                            if(String.isEmpty(outAcc.cif.FS_Reason_if_applicable__c)){
                                countNotCompleted++;
                                outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                            }else{
                                countCompleted++;
                                outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                            }
                        }else if(outAcc.cif.FS_Customer_s_disposition_after_review__c != null && outAcc.cif.FS_Customer_s_disposition_after_review__c == FSConstants.SCNDSSPEN){
                            if(String.isEmpty(outAcc.cif.FS_Second_Site_Survey_Reason__c)){
                                countNotCompleted++;
                                outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                            }else{
                                countNotCompleted++;
                                outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                            }
                        }else{
                            countNotStarted++;
                            outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATRED);
                        }
                    }
                    outAcc.chevStatusMap.put(FSConstants.SUMMARY,FSConstants.CHEVSTATGRN);
                }
                changeStatus(viewStateTrackerList,lstOutlet);
            }
            if(sectionName==FSConstants.SECFINANCE || onLoadCheck){
                previousStage= FSConstants.FINANCE;
                for(WrpOutlet outAcc : lstOutlet){
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        if(outAcc.cif.FS_Cartridge_Payment_Method__c != null && outAcc.cif.FS_Program_Fee_Payment_Method__c != null){
                            countCompleted++;
                            outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATGRN);
                        }else if(outAcc.cif.FS_Cartridge_Payment_Method__c == null && outAcc.cif.FS_Program_Fee_Payment_Method__c == null){
                            countNotStarted++;
                            outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATRED);
                        }else if(outAcc.cif.FS_Cartridge_Payment_Method__c == null || outAcc.cif.FS_Program_Fee_Payment_Method__c == null){
                            countNotCompleted++;
                            outAcc.chevStatusMap.put(previousStage,FSConstants.CHEVSTATYLW);
                        }
                    }
                }
                changeStatus(viewStateTrackerList,lstOutlet);
            }
            if(sectionName==FSConstants.SECSALESREPINFO || onLoadCheck){            
                previousStage= FSConstants.SALESREPINFO;
                if(cifHead.FS_Sales_Rep_Name__c != null && cifHead.FS_FPS__c != null && cifHead.FSCOM__c != null){
                    viewStateTrackerList.put(previousStage, FSConstants.COMPLETED);
                }else if(cifHead.FS_Sales_Rep_Name__c == null && cifHead.FS_FPS__c == null && cifHead.FSCOM__c == null){
                    viewStateTrackerList.put(previousStage, FSConstants.NOTSTARTED);
                }else if(cifHead.FS_Sales_Rep_Name__c == null || cifHead.FS_FPS__c == null || cifHead.FSCOM__c == null){
                    viewStateTrackerList.put(previousStage,FSConstants.INPROGRESS);
                }
            }
            for(String str:viewStateTrackerList.keySet()){
                if(str != FSConstants.SUMMARY){
                    if(viewStateTrackerList.get(str)==FSConstants.COMPLETED){
                        countCompleted++;                    
                    }else {                    
                        countNotCompleted++;
                    }
                } 
            }
            if(countCompleted == viewStateTrackerList.size()-1){
                viewStateTrackerList.put(FSConstants.SUMMARY, FSConstants.COMPLETED);           
            }else if(countNotCompleted != viewStateTrackerList.size()){
                viewStateTrackerList.put(FSConstants.SUMMARY, FSConstants.INPROGRESS);            
            }
        }
        if(lstOutlet.SIZE()<1 ){
            viewStateTrackerList.put(FSConstants.SELECTOUTLETS,FSConstants.NOTSTARTED);  
        }
        countCompleted=0;
        countNotCompleted=0;
        countNotStarted=0;
        lstOutletUpd = lstOutlet;
        
        return viewStateTrackerList;
    }
    public void changeStatus(Map<String, String> viewStateTrackerList,List<WrpOutlet> lstOutlet){
        if(countCompleted == lstOutlet.size()){
            viewStateTrackerList.put(previousStage, FSConstants.COMPLETED);
        }else if(countNotCompleted > 0 && countNotStarted != lstOutlet.size()){
            viewStateTrackerList.put(previousStage, FSConstants.INPROGRESS);
        }else if(countNotStarted < lstOutlet.size()){
            viewStateTrackerList.put(previousStage, FSConstants.INPROGRESS);
        }else if(countNotStarted== lstOutlet.size()){
            viewStateTrackerList.put(previousStage, FSConstants.NOTSTARTED);
        }
        countCompleted=0;
        countNotCompleted=0;
        countNotStarted=0;
    }
    
    /*****************************************************************
Method: getSummaryReport()
Description: getSummaryReport method is redirect to Summary report on click on Generate Summary Link on Summary section.
*******************************************************************/
    
    public PageReference getSummaryReport(String currentCIFId){
        PageReference pageRef = null;
        
        try{
            final List <Report> reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName = 'FS_CIF_Summary_Report'];
            final String reportId = (String)reportList.get(0).get('Id');
            final String repCIFId = currentCIFId.substring(0, 15);
            if(UserInfo.getUiThemeDisplayed() == 'Theme4d'){
                pageRef = new PageReference('/lightning/r/Report/'+reportId+'/view?&fv0='+repCIFId);
                
            }else{
                pageRef = new PageReference('/'+reportId+'?&pv0='+repCIFId);  
            }
            pageRef.setRedirect(true);
        }catch(QueryException e){
            ApexErrorLogger.addApexErrorLog(valFET,valFSCIFNewandEdit,'getSummaryReport','reportList',valMedium,e,valNA);
            pageRef = null; 
        }catch(ListException e){
            ApexErrorLogger.addApexErrorLog(valFET,valFSCIFNewandEdit,'getSummaryReport','reportList',valMedium,e,valNA);
            pageRef = null; 
        }
        return pageRef;
    }
    
    public String buildSearchQuery(String OUTLET_RECORD_TYPE, Id accId, String sortString){
        searchOutletACNLst = new String[]{};
            String qry = null;
        qry = 'SELECT Id,FS_ACN__c,Phone,FS_Headquarters__c,FS_Headquarters__r.FS_ACN__c, FS_Headquarters__r.FS_SAP_ID__c,FS_Chain__r.name,FS_Chain_ACN__c,FS_Store_Number__c,FS_Admin_User__c,FS_Payment_Type__c,Invoice_Customer__c, FS_SAP_ID__c,Total_VPO__c,FS_Count_Total_number_of_Dispensaries__c, Name, Bottler_Name__c,FS_Primary_Contact__c,FS_ALL_FS_Equipment_Removed__c,FS_Approved_For_Execution_Plan__c,FS_Revenue_Center__c, ShippingStreet, ShippingState, ShippingCity,ShippingCountry,ShippingPostalCode, FS_Headquarters__r.Name, Latest_Installation_Status__c,'+
            'FS_Site_Assessment_Contact__r.Email,FS_Site_Assessment_Contact__r.Phone,FS_Site_Assessment_Contact__r.Title,FS_Site_Assessment_Contact__r.OtherPhone, BillingStreet, BillingCity, BillingState, BillingPostalCode, Ownership, FS_Requested_Channel__c, FS_Market_ID__c, Bottlers_Name__r.Name, FS_HQ_ACN__c, FS_Site_Assessment_Contact__r.Name, '+
            'FS_Distributor__r.Name,FS_Distributor__r.ShippingStreet,FS_Distributor__r.ShippingCity,FS_Distributor__r.ShippingState,FS_Distributor__r.ShippingPostalCode, FS_CS_Bill_To_Address__c,FS_CS_Bill_To_City__c,FS_CS_State__c,FS_CS_Bill_To_Zip__c,Cokesmart_Payment_Method__c,FS_Payment_Method__c,FS_Final_Delivery_Method__c,FS_Final_Order_Method__c,'+
            'BillingCountry,FS_VMS_Customer__c,FS_Admin_User_Name__c,FS_Admin_User_Title__c,FS_Admin_User_Email__c,FS_Requested_Order_Method__c ,FS_Admin_User_Phone__c,FS_Standard_User__c,FS_Standard_User_Function__c,FS_Standard_User_Email__c,FS_Standard_User_Phone__c,FS_Concatenated_Address__c,FS_Site_Assessment_Contact__c,FS_Site_Assessment_Contact_Title__c,'+
            'FS_Site_Assessment_Contact_Phone__c,FS_Site_Assessment_Contact_Alt_Phone__c,FS_Site_Assessment_Contact_Email__c,FS_Legal_Entity_Name__c, FS_Requested_Delivery_Method__c,'+
            ' (Select Id,RecordType.Name from Installations5__r WHERE RecordType.Name = \'Relocation (O4W)\' AND FS_Overall_Status__c != \'Cancelled\' and FS_Overall_Status__c  != \'Complete\' Limit 1),'+
            ' (SELECT Id, Name,RecordType.Name,RecordTypeid,FS_Overall_Status__c, FS_Same_incoming_platform__c, CreatedDate FROM Installations1__r WHERE FS_Overall_Status__c NOT IN (\''+FSConstants.IPCOMPLETE +'\',\''+FSConstants.IPCANCELLED +'\',\'\') AND FS_Overall_Status__c != null AND (RecordType.Name = \'New Install\' OR RecordType.Name = \'Replacement\') ORDER BY CreatedDate DESC), (SELECT Id, Name,CIF_Head__c,FS_Perf_Site_Assessment__c,FS_Customer_s_disposition_after_review__c,SA_Status__c,FS_Davaco_Order_Entered__c,FS_What_type_of_Site_Assessment__c,FS_CIF_Header__c from CIF9__r where FS_CIF_Header_Status__c = \'In Progress\' and FS_Customer_s_disposition_after_review__c NOT IN (\'Cancelled\',\'Not Approved\')  ORDER BY CreatedDate DESC) '+
            ' FROM Account WHERE FS_Headquarters__c = :accId AND RecordType.Name = :OUTLET_RECORD_TYPE ';
        if(!String.isBlank(searchOutletName) ){qry += ' AND Name LIKE \'%' + searchOutletName.trim() + '%\'';}
        if(!String.isBlank(searchOutletACN) ){
            final  String strTest = searchOutletACN;
            if(strTest.contains(',')){
                for(String str:strTest.split(',')){
                    if(!str.startswith('0')){str = str.trim().leftPad(10).replace(' ', '0');}
                    searchOutletACNLst.add(str);
                }
                qry += ' AND FS_ACN__c IN :searchOutletACNLst';
            }else if(strTest.contains('\n')){
                for(String str:strTest.split('\n')){
                    if(!str.startswith('0')){str = str.trim().leftPad(10).replace(' ', '0');}
                    searchOutletACNLst.add(str);
                }
                qry += ' AND FS_ACN__c IN :searchOutletACNLst';
            }else{qry += ' AND FS_ACN__c LIKE \'%' + searchOutletACN.trim() + '%\'';}
        }
        if(!String.isBlank(searchOutletCity) ){qry += ' AND ShippingCity LIKE \'%' + searchOutletCity.trim()  + '%\'';}
        if(!String.isBlank(searchOutletState) ){qry += ' AND ShippingState LIKE \'%' + searchOutletState.trim() + '%\'';}
        qry += ' Order by ' + sortString + ' Limit 100';
        return qry;
    }
    
     //function to fetch all the records instead of only 100
     public String buildSearchQueryAllRecs(String OUTLET_RECORD_TYPE, Id accId, String sortString){
        searchOutletACNLst = new String[]{};
            String qry = null;
        qry = 'SELECT Id,FS_ACN__c,Phone,FS_Headquarters__c,FS_Headquarters__r.FS_ACN__c, FS_Headquarters__r.FS_SAP_ID__c,FS_Chain__r.name,FS_Chain_ACN__c,FS_Store_Number__c,FS_Admin_User__c,FS_Payment_Type__c,Invoice_Customer__c, FS_SAP_ID__c,Total_VPO__c,FS_Count_Total_number_of_Dispensaries__c, Name, Bottler_Name__c,FS_Primary_Contact__c,FS_ALL_FS_Equipment_Removed__c,FS_Approved_For_Execution_Plan__c,FS_Revenue_Center__c, ShippingStreet, ShippingState, ShippingCity,ShippingCountry,ShippingPostalCode, FS_Headquarters__r.Name, Latest_Installation_Status__c,'+
            'FS_Site_Assessment_Contact__r.Email,FS_Site_Assessment_Contact__r.Phone,FS_Site_Assessment_Contact__r.Title,FS_Site_Assessment_Contact__r.OtherPhone, BillingStreet, BillingCity, BillingState, BillingPostalCode, Ownership, FS_Requested_Channel__c, FS_Market_ID__c, Bottlers_Name__r.Name, FS_HQ_ACN__c, FS_Site_Assessment_Contact__r.Name, '+
            'FS_Distributor__r.Name,FS_Distributor__r.ShippingStreet,FS_Distributor__r.ShippingCity,FS_Distributor__r.ShippingState,FS_Distributor__r.ShippingPostalCode, FS_CS_Bill_To_Address__c,FS_CS_Bill_To_City__c,FS_CS_State__c,FS_CS_Bill_To_Zip__c,Cokesmart_Payment_Method__c,FS_Payment_Method__c,FS_Final_Delivery_Method__c,FS_Final_Order_Method__c,'+
            'BillingCountry,FS_VMS_Customer__c,FS_Admin_User_Name__c,FS_Admin_User_Title__c,FS_Admin_User_Email__c,FS_Requested_Order_Method__c ,FS_Admin_User_Phone__c,FS_Standard_User__c,FS_Standard_User_Function__c,FS_Standard_User_Email__c,FS_Standard_User_Phone__c,FS_Concatenated_Address__c,FS_Site_Assessment_Contact__c,FS_Site_Assessment_Contact_Title__c,'+
            'FS_Site_Assessment_Contact_Phone__c,FS_Site_Assessment_Contact_Alt_Phone__c,FS_Site_Assessment_Contact_Email__c,FS_Legal_Entity_Name__c, FS_Requested_Delivery_Method__c,'+
            ' (Select Id,RecordType.Name from Installations5__r WHERE RecordType.Name = \'Relocation (O4W)\' AND FS_Overall_Status__c != \'Cancelled\' and FS_Overall_Status__c  != \'Complete\' Limit 1),'+
            ' (SELECT Id, Name,RecordType.Name,RecordTypeid,FS_Overall_Status__c, FS_Same_incoming_platform__c, CreatedDate FROM Installations1__r WHERE FS_Overall_Status__c NOT IN (\''+FSConstants.IPCOMPLETE +'\',\''+FSConstants.IPCANCELLED +'\',\'\') AND FS_Overall_Status__c != null AND (RecordType.Name = \'New Install\' OR RecordType.Name = \'Replacement\') ORDER BY CreatedDate DESC), (SELECT Id, Name,CIF_Head__c,FS_Perf_Site_Assessment__c,FS_Customer_s_disposition_after_review__c,SA_Status__c,FS_Davaco_Order_Entered__c,FS_What_type_of_Site_Assessment__c,FS_CIF_Header__c from CIF9__r where FS_CIF_Header_Status__c = \'In Progress\' and FS_Customer_s_disposition_after_review__c NOT IN (\'Cancelled\',\'Not Approved\')  ORDER BY CreatedDate DESC) '+
            ' FROM Account WHERE FS_Headquarters__c = :accId AND RecordType.Name = :OUTLET_RECORD_TYPE ';
        if(!String.isBlank(searchOutletName) ){qry += ' AND Name LIKE \'%' + searchOutletName.trim() + '%\'';}
        if(!String.isBlank(searchOutletACN) ){
            final  String strTest = searchOutletACN;
            if(strTest.contains(',')){
                for(String str:strTest.split(',')){
                    if(!str.startswith('0')){str = str.trim().leftPad(10).replace(' ', '0');}
                    searchOutletACNLst.add(str);
                }
                qry += ' AND FS_ACN__c IN :searchOutletACNLst';
            }else if(strTest.contains('\n')){
                for(String str:strTest.split('\n')){
                    if(!str.startswith('0')){str = str.trim().leftPad(10).replace(' ', '0');}
                    searchOutletACNLst.add(str);
                }
                qry += ' AND FS_ACN__c IN :searchOutletACNLst';
            }else{qry += ' AND FS_ACN__c LIKE \'%' + searchOutletACN.trim() + '%\'';}
        }
        if(!String.isBlank(searchOutletCity) ){qry += ' AND ShippingCity LIKE \'%' + searchOutletCity.trim()  + '%\'';}
        if(!String.isBlank(searchOutletState) ){qry += ' AND ShippingState LIKE \'%' + searchOutletState.trim() + '%\'';}
        qry += ' Order by ' + sortString + ' ';
        return qry;
    }
}