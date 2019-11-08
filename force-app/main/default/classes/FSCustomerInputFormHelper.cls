/**********************************************************************************
Apex Class Name    : FSCustomerInputFormHelper
Version            : 1.1
Function           : This is used to read CIF workbook CSV file uploaded from the 'Upload Workbook' button
Modification Log   :  
* Date             : 7 June 2018
*********************************************************************************/

public class FSCustomerInputFormHelper {
    public CIF_Header__c cifHead;
    public string valSAContactMail ='SA Contact Email' ;
    public string valWaterFilter ='Water Filter Installer Contact Email'; 
    public string valGCEmail = 'GC Email'; 
    public string valOutletConsEon = 'Outlet Construction Contact Email'; 
    public string valAdmUserEmail = 'Admin User Email';  
    public string valStndUserMail ='Standard User Email';
    public string valProvOnBroadMail = 'Provide On-Boarding Contact Email'; 
    public string valWaterFilOutlet = 'Water Filter Outlet Contact Email';             
    public string valSalesEmail ='Sales Email';
    public string valOperationMngEmail='Operations Manager Email';
    public string valGenCont =  'General Contractor'  ;
    public List<FS_Customer_Disp_After_SA__c> custDisSAs;    
    public string valInstallPeriod ='Install Period';               
    public string valplatform1 ='Platform 1';
    public string valplatform2 ='Platform 2' ;
    public string valplatform3 ='Platform 3' ;  
    public string valBrandset1 ='Brandset 1' ;      
    public string valBrandset2 = 'Brandset 2' ;
    public string valBrandset3 ='Brandset 3' ;
    public string brandloop = '' ;
    public string plat1loop = '' ;
    public string plat2loop = '' ;
    public string plat3loop = '' ;
    public string valRecNotLoad = 'Record did not load';            
    public string valdayorNight = 'Day or Night Install' ;
    public string valappWatFilter =  'Is an approved Water Filter installed?';    
    
    /*****************************************************************
Method: readCSVFile
Description: To read the data from uploaded CSV file and returns the data in WrpOutlet list
*******************************************************************/
    public List<WrpOutlet> readCSVFile(String cifDataAsString,Account hqRec,Set<Id> currentSelectedOutletIds,CIF_Header__c cifHeader){
        final Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
        final List<WrpOutlet> lstOutlet_wrkbk = new List<WrpOutlet>();
        final List<String> csvACNList = new List<String>();
        final List<String> csvSrchACNLst = new List<String>();
        cifHead = cifHeader;
        String fieldValue;
        Integer fieldNumber;
        List<String> errorDetails = new List<String>();
        final Map<string,FS_Brandset__c> brandsMap = new Map<string,FS_Brandset__c>();
        final List<FS_Brandset__c> brandsList = [select name,FS_Platform__c,Available_for_Selection__c from FS_Brandset__c];
        String errorstoCSV = 'ACN Number' + ',' +'ACN Found?'+ ','+ 'Status' + ',' + 'Error or Warning messages' + '\n' ;        
        Id profileId=userinfo.getProfileId();
        String profileName;
        try{
            profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog('FET-7.0','FSCustomerInputFormHelper','readCSVFile','Profile','Medium',e,'NA');
        }
        for(FS_Brandset__c brandrec: brandsList){
            brandsMap.put(brandrec.name, brandrec);
        }
        string s='';
        try{
            
            final String[] cifDataLines = cifDataAsString.split('\n');
            
            final string[] csvFieldNames = cifDataLines[0].split(',');

            //for(string s : cifDataLines) system.debug(s);
            final String workbookName = cifDataLines[1].split(',')[0];
    
            if(workbookName != null && workbookName != ''){
                cifHead.FS_Version__c=1;
                cifHead.name = workbookName+'_V.'+cifHead.FS_Version__c; 
            }
            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumberMap.put(csvFieldNames[i].trim(), i);   
            }
  
            Set<String> cartrodgePickListVal = new Set<String>(); 
            Set<String> programFeePickListVal = new Set<String>();     
            cartrodgePickListVal = FsCIFworkbookValidation.getcatPaymentPickListVal(); 
            programFeePickListVal = FsCIFworkbookValidation.getproPaymentPickListVal(); 
            final Map<String,String> accountMemberEmails=new Map<String,String>();
            final  List<AccountTeamMember__c> salesTeamMembers = new List<AccountTeamMember__c>();
            final  List<AccountTeamMember__c> comUsers = new List<AccountTeamMember__c>();
            final  List<AccountTeamMember__c> SalesAndComUsers = new List<AccountTeamMember__c>();
            final List<String> contractorName = new List<String>();
            final  Map<String,Id> contractorBasedOnName = new Map<String,Id>();
            final Set<String> contactEmails=new Set<String>();
            final Map<String,Id> contactBasedOnEmail=new Map<String,Id>();
            final Map<String,Boolean> contactInfoCheck=new Map<String,Boolean>();            
            final Map<String,WrpOutlet> outletMap = new Map<String,WrpOutlet>();
            final Map<String,WrpOutlet> otlpaymentMap = new Map<String,WrpOutlet>();
			final List<FS_Installation__c> newInst = new List<FS_Installation__c>();//Added as part of FET-7.0 FNF 795
            
            for(Integer i = 1;i < cifDataLines.size(); i++){
                final string[] csvRecordData = cifDataLines[i].split(',');          
                for (String fieldName: csvFieldNames){
                    fieldNumber = fieldNumberMap.get(fieldName.trim());
                    fieldValue = csvRecordData[fieldNumber];                    
                    if(fieldName.contains('Outlet ACN#')){                            
                        csvACNList.add(csvRecordData[fieldNumberMap.get('Outlet ACN#')].trim());
                    }                   
                    if(fieldName.contains(valSAContactMail)){
                        contactEmails.add(csvRecordData[fieldNumberMap.get(valSAContactMail)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valWaterFilter)){
                        contactEmails.add(csvRecordData[fieldNumberMap.get(valWaterFilter)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valGCEmail)){
                        contactEmails.add(csvRecordData[fieldNumberMap.get(valGCEmail)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valOutletConsEon)){
                        contactEmails.add(csvRecordData[fieldNumberMap.get(valOutletConsEon)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valProvOnBroadMail)){
                        contactEmails.add(csvRecordData[fieldNumberMap.get(valProvOnBroadMail)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valAdmUserEmail)){
                        contactEmails.add(csvRecordData[fieldNumberMap.get(valAdmUserEmail)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valStndUserMail)){
                        contactEmails.add(csvRecordData[fieldNumberMap.get(valStndUserMail)].trim().toUpperCase());
                    }
                    if(fieldName.contains('Installation Contact Email')){
                        contactEmails.add(csvRecordData[fieldNumberMap.get('Installation Contact Email')].trim().toUpperCase());
                    }
                    if(fieldName.contains(valWaterFilOutlet)){
                        contactEmails.add(csvRecordData[fieldNumberMap.get(valWaterFilOutlet)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valSalesEmail)) {
                        accountMemberEmails.put(valSalesEmail,csvRecordData[fieldNumberMap.get(valSalesEmail)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valOperationMngEmail)){
                        accountMemberEmails.put(valOperationMngEmail,csvRecordData[fieldNumberMap.get(valOperationMngEmail)].trim().toUpperCase());
                    }
                    if(fieldName.contains(valGenCont)){
                        contractorName.add(csvRecordData[fieldNumberMap.get(valGenCont )].trim()); 
                    }                    
                }
            }             
            //Get Contacts Based on Email 
            if(!contactEmails.isEmpty()){
                for(Contact contact : [SELECT Id,Name,Email,FS_Contact_Info_Complete__c FROM Contact WHERE Email IN: contactEmails AND AccountId=:hqRec.Id AND FS_Contact_Info_Complete__c = true]){
                    contactBasedOnEmail.put(contact.Email.toUpperCase(),contact.Id);
                    contactInfoCheck.put(contact.Email.toUpperCase(), contact.FS_Contact_Info_Complete__c);
                }
            }
            //Get Sales Team Member and Operations Manager details based on Email
            if(!accountMemberEmails.isEmpty()){
                if(accountMemberEmails.containsKey(valSalesEmail)){
                    final  List<AccountTeamMember__c> salesTeamMember = [select id,name,FS_Email__c,TeamMemberRole__c from AccountTeamMember__c Where FS_Email__c =: accountMemberEmails.get(valSalesEmail) AND AccountId__c=:hqRec.Id AND TeamMemberRole__c='Sales Team Member' limit 1];
                    if(!salesTeamMember.isEmpty()){
                        salesTeamMembers.add(salesTeamMember.get(0));                  
                    }         
                }
                if(accountMemberEmails.containsKey(valOperationMngEmail)){
                    final List<AccountTeamMember__c> comUser = [select id,name,FS_Email__c,TeamMemberRole__c from AccountTeamMember__c Where FS_Email__c =: accountMemberEmails.get(valOperationMngEmail) AND AccountId__c=:hqRec.Id AND TeamMemberRole__c='COM' limit 1];
                    if(!comUser.isEmpty()){
                        comUsers.add(comUser.get(0)); 
                    }                  
                }               
            }
            // Get General Contractor based on Name
            if(!contractorName.isEmpty()){
                for(Account vendor : [select id,name,FS_Vendor_Type__c,FS_ACN__c from Account where RecordTypeId =: FSConstants.RECORD_TYPE_VENDOR AND FS_Vendor_Type__c = 'General Contractor' AND name IN : contractorName]){
                    contractorBasedOnName.put(vendor.name,vendor.Id);
                }
            }            
            for(String str: csvACNList){
                if(!str.startswith('0')){str = str.trim().leftPad(10).replace(' ', '0');}
                csvSrchACNLst.add(str);
            }
            
            String instalNumber;
            FS_CIF__c cifLineItem;
            Boolean isActiveCIF=false;
            Boolean isCustDispAfSA = false;
            boolean disCustDispSA = false;
            String isRO4WExist;
            String isReplaceExist; //Added as part of FET-7.0 FNF 795 
            Id replaceRecId = FSInstallationValidateAndSet.ipRecTypeReplacement; 
            custDisSAs = new List<FS_Customer_Disp_After_SA__c>();
            custDisSAs = FS_Customer_Disp_After_SA__c.getall().values();
            for(Account acc : [SELECT Id,FS_ACN__c,Phone,FS_Headquarters__r.FS_ACN__c,FS_Headquarters__r.FS_SAP_ID__c,FS_Headquarters__c,FS_Chain__r.name,FS_Chain_ACN__c,FS_Store_Number__c,FS_Admin_User__c,FS_Payment_Type__c,Invoice_Customer__c, FS_SAP_ID__c,Total_VPO__c,FS_Count_Total_number_of_Dispensaries__c, Name, Bottler_Name__c,FS_Primary_Contact__c,FS_ALL_FS_Equipment_Removed__c,FS_Approved_For_Execution_Plan__c,FS_Revenue_Center__c, ShippingStreet, ShippingState, ShippingCity, ShippingPostalCode, FS_Headquarters__r.Name, Latest_Installation_Status__c,
                               FS_Site_Assessment_Contact__r.Email,FS_Site_Assessment_Contact__r.Phone,FS_Site_Assessment_Contact__r.Title,FS_Site_Assessment_Contact__r.OtherPhone, BillingStreet, BillingCity, BillingState, BillingPostalCode, Ownership, FS_Requested_Channel__c, FS_Market_ID__c, Bottlers_Name__r.Name, FS_HQ_ACN__c, FS_Site_Assessment_Contact__r.Name,FS_Final_Order_Method__c,FS_Final_Delivery_Method__c,
                               FS_Distributor__r.Name,FS_Distributor__r.ShippingStreet,FS_Distributor__r.ShippingCity,FS_Distributor__r.ShippingState,FS_Distributor__r.ShippingPostalCode, FS_CS_Bill_To_Address__c,FS_CS_Bill_To_City__c,FS_CS_State__c,FS_CS_Bill_To_Zip__c,Cokesmart_Payment_Method__c,FS_Payment_Method__c,
                               BillingCountry,FS_VMS_Customer__c,FS_Admin_User_Name__c,FS_Admin_User_Title__c,FS_Admin_User_Email__c,FS_Requested_Order_Method__c ,FS_Admin_User_Phone__c,FS_Standard_User__c,FS_Standard_User_Function__c,FS_Standard_User_Email__c,FS_Standard_User_Phone__c,FS_Concatenated_Address__c,FS_Site_Assessment_Contact__c,FS_Site_Assessment_Contact_Title__c,
                               FS_Site_Assessment_Contact_Phone__c,FS_Site_Assessment_Contact_Alt_Phone__c,FS_Site_Assessment_Contact_Email__c,FS_Legal_Entity_Name__c, FS_Requested_Delivery_Method__c,
                               (SELECT Id,RecordType.Name,FS_Overall_Status__c FROM Installations5__r WHERE RecordType.Name = 'Relocation (O4W)' AND FS_Overall_Status__c NOT IN (:FSConstants.IPCOMPLETE ,:FSConstants.IPCANCELLED ,'') AND FS_Overall_Status__c != null LIMIT 1),
                               (SELECT Id, Name,RecordType.Name,RecordTypeid,FS_Overall_Status__c,FS_Same_incoming_platform__c, CreatedDate FROM Installations1__r WHERE (RecordType.Name = 'New Install' OR RecordType.Name = 'Replacement') AND FS_Overall_Status__c NOT IN (:FSConstants.IPCOMPLETE ,:FSConstants.IPCANCELLED ,'') AND FS_Overall_Status__c != null ORDER BY CreatedDate DESC),
                               (SELECT Id, Name,FS_Perf_Site_Assessment__c,CIF_Head__c,SA_Status__c,FS_What_type_of_Site_Assessment__c,CIF_Head__r.FS_CIF_Number__c,FS_Customer_s_disposition_after_review__c,FS_CIF_Header__c from CIF9__r where FS_CIF_Header_Status__c = 'In Progress' and FS_Customer_s_disposition_after_review__c NOT IN ('Cancelled','Not Approved') ORDER BY CreatedDate DESC)
                               FROM Account WHERE FS_Headquarters__c = :hqRec.Id AND RecordType.Name = :FSConstants.RECORD_TYPE_NAME_OUTLET AND FS_ACN__c IN :csvSrchACNLst]){
                                   //Modified query as part of FET-7.0 FNF 795
                                   instalNumber='';
                                   cifLineItem = new FS_CIF__c();
                                   if(acc.Installations1__r != null && !acc.Installations1__r.isEmpty()){
                                       for(FS_Installation__c inst: acc.Installations1__r){
                                           if(inst.RecordType.Name == 'New Install'){ //Modified as part of FET-7.0 FNF 795
												instalNumber=inst.Name;
												newInst.add(inst);
										   }
                                           //Added as part of FET-7.0 FNF 795
										   if(inst.RecordTypeId == replaceRecId && inst.FS_Same_incoming_platform__c == FSConstants.NO){
											   isReplaceExist = FSConstants.YES;
										   }
                                       }
                                   }
                                   if(acc.CIF9__r != null && !acc.CIF9__r.isEmpty()){
                                       for(FS_CIF__c cif : acc.CIF9__r){
                                           cifLineItem = cif;
                                       }
                                   }   
                                   //FET7.0 FNF-835 Start
                                   if(!acc.Installations5__r.isEmpty()){
                                       isRO4WExist = FSConstants.YES;
                                   }
                                   //FET7.0 FNF-835 Start
                                   
                                   
                                   
                                   for(FS_Customer_Disp_After_SA__c custDisSA :custDisSAs){
                                       if(custDisSA.Status__c==cifLineItem.FS_Customer_s_disposition_after_review__c){
                                           isCustDispAfSA = true;
                                           break;
                                       }else{
                                           isCustDispAfSA = false;
                                       }
                                   }                                   
                                   //Start FET4.1 
                                   if(cifHead.FS_CIF_Number__c != FSConstants.NULLVALUE){
                                       if((cifLineItem.CIF_Head__c == cifHead.id || isCustDispAfSA) && instalNumber == ''){
                                           isActiveCIF = false; 
                                       } else if((cifLineItem.FS_CIF_Header__c == null || isCustDispAfSA) && instalNumber == ''){
                                           isActiveCIF = false;
                                       }
                                       else {
                                           isActiveCIF = true; 
                                       }
                                   } else {
                                       if((cifLineItem.CIF_Head__c != NUll && cifLineItem.FS_CIF_Header__c != Null && !isCustDispAfSA) || instalNumber != ''){
                                           isActiveCIF = true; 
                                       }else{
                                           isActiveCIF = false; 
                                       } 
                                   }     
                                   
                                   if(isCustDispAfSA && (profileName == 'FET System Admin' || profileName == 'System Administrator')){
                                       disCustDispSA = false;
                                   }else if(isCustDispAfSA && (profileName != 'FET System Admin' || profileName != 'System Administrator')){
                                       disCustDispSA = true;   
                                   }else{
                                       disCustDispSA = false;   
                                   }
                                   
                                   lstOutlet_wrkbk.add(new WrpOutlet(acc,newInst,cifLineItem,acc.CIF9__r,instalNumber,!acc.Installations1__r.isEmpty(),isActiveCIF,false,isActiveCIF,disCustDispSA,isRO4WExist,isReplaceExist));//Modified as part of FET-7.0 FNF 795
                                   //End FET4.1 
                                   newInst.clear();
                                   isRO4WExist = FSConstants.BLANKVALUE;
								   isReplaceExist = FSConstants.BLANKVALUE; 
                               }
            for(WrpOutlet otl: lstOutlet_wrkbk){                  
                outletMap.put(String.valueOf(integer.valueOf(otl.outlet.FS_ACN__c)).trim(), otl);   
                otlpaymentMap.put(otl.outlet.FS_ACN__c, otl); 
            }
            Map<String, String[]>    ReadDataMAP = new  Map<String, String[]> (); 
            Map<String, FS_CIF_CSVMapping__mdt> CSVDataMap = new Map<String, FS_CIF_CSVMapping__mdt>();
            Map<String, FS_CIF_CSVMapping__mdt> CSVValidateDataMap = new Map<String, FS_CIF_CSVMapping__mdt>();
            //FFET-1673: FET 7.1 Warranty Defect Changes
            Map<String, FS_CIF_SiteAssessor__mdt> siteAssessorDataMap = new Map<String, FS_CIF_SiteAssessor__mdt>();
            //FFET-1673: FET 7.1 Warranty Defect Changes
            for(FS_CIF_CSVMapping__mdt CSV: [Select masterLabel, CSV_Field__c, Error_Message__c, Field_API__c, Mapping_Type__c,Mapping_Validation__c From FS_CIF_CSVMapping__mdt]){
                CSVDataMap.put(CSV.CSV_Field__c,CSV);
                if(CSV.Mapping_Validation__c == 'Both'){
                    CSVValidateDataMap.put(CSV.CSV_Field__c,CSV);
                }               
            }
            //FFET-1673: FET 7.1 Warranty Defect Changes
            for(FS_CIF_SiteAssessor__mdt recSA : [SELECT MasterLabel,Site_Assessor__c from FS_CIF_SiteAssessor__mdt] ){
                siteAssessorDataMap.put(recSA.MasterLabel,recSA);
            }
            //FFET-1673: FET 7.1 Warranty Defect Changes
            for(Integer i = 1;i < cifDataLines.size(); i++){
                string[] csvRecordData = cifDataLines[i].split(',');
                final  String[] csvRecordData1 = new String[]{};
                    for (String recordData: csvRecordData){
                        recordData=recordData.replaceAll('!',',');
                        csvRecordData1.add(recordData);
                    }                                    
                csvRecordData = csvRecordData1;
                List<String> recordEmailList = new List<String>();
                List<FsCIFworkbookValidation.emailWrapper> recordEmailWrap = new List<FsCIFworkbookValidation.emailWrapper>();               
                recordEmailList = FsCIFworkbookValidation.buildcontactEmailList(fieldNumberMap,csvRecordData);    
                recordEmailWrap = FsCIFworkbookValidation.buildcontactEmailMap(fieldNumberMap,csvRecordData);
                errorDetails = FsCIFworkbookValidation.validate(csvRecordData, fieldNumberMap, outletMap, contactBasedOnEmail, contactInfoCheck, recordEmailList, recordEmailWrap, CSVValidateDataMap);
                final  string stat = errorDetails.get(2);

                
                if (stat != valRecNotLoad){   
                    errorDetails = FsCIFworkbookValidation.checkTeamMember(salesTeamMembers, comUsers, errorDetails); 
                    errorDetails = FsCIFworkbookValidation.validatePaymentval(cartrodgePickListVal,programFeePickListVal ,csvRecordData,fieldNumberMap, otlpaymentMap,errorDetails);
                    //OCR FR_32
                    errorDetails = FsCIFworkbookValidation.validateOrderAndDeliveryVal(csvRecordData,fieldNumberMap, otlpaymentMap,errorDetails);
                }            
                errorstoCSV = FsCIFworkbookValidation.writeCSVline(errorDetails,errorstoCSV);
                for (String fieldName: csvFieldNames){
                    fieldNumber = fieldNumberMap.get(fieldName.trim());
                    fieldValue = csvRecordData[fieldNumber];
                    if(fieldNumber == FSConstants.NUM_3){    
                        fieldValue = fieldValue.trim();
                        //parse Outlet ACN to 10 digit
                        fieldValue=FSUtil.leftPadWithZeroes(fieldValue,10);
                        ReadDataMAP.put(fieldValue, csvRecordData);
                    }
                }                
            }
            for(WrpOutlet wrp: lstOutlet_wrkbk){
                if(ReadDataMAP.containsKey(wrp.outlet.FS_ACN__c)){
                    String[]  csvRecordData= ReadDataMAP.get(wrp.outlet.FS_ACN__c);                    
                    if(!wrp.isActiveCIF){
                        wrp.isSelected = true;
                        if(!wrp.disCustDispSA){                
                            if(!salesTeamMembers.isEmpty()){
                                cifHead.FS_Sales_Rep_Name__c=salesTeamMembers[0].Id;  
                            }
                            if(!comUsers.isEmpty()){
                                cifHead.FSCOM__c = comUsers[0].id;    
                            }    
                            
                            // FET7.0 FNF-835 Start
                            if(wrp.isRO4WExist == FSConstants.YES){
                                wrp.cif.Does_Install_Involve_RO4W__c = FSConstants.YES;
                            }
                            // FET7.0 FNF-835 End

                            // FET7.0 FNF-795 Start
                            if(wrp.isReplaceExist == FSConstants.YES){

                                wrp.cif.FS_Does_Install_Involve_a_Replacement__c = FSConstants.YES;
                            }
                            // FET7.0 FNF-795 End
                             
                            // if(){ 

                            for(String CSVString : CSVDataMap.keyset()){
                                if(fieldNumberMap.containskey(CSVString)){
                                  if(CSVDataMap.get(CSVString).Mapping_Type__c == 'UpperCase'){
                                     s=CSVString;
                                        if(fieldNumberMap.containsKey(CSVString) && csvRecordData[fieldNumberMap.get(CSVString)].trim() != '0'){
                                            
                                            wrp.cif.put(CSVDataMap.get(CSVString).Field_API__c,contactBasedOnEmail.get(csvRecordData[fieldNumberMap.get(CSVString)].trim().toUpperCase()));
                                        }
                                    }
                                    if(CSVDataMap.get(CSVString).Mapping_Type__c == 'ParseDate'){
                                     s=CSVString;
                                        if(fieldNumberMap.containsKey(CSVString) && !String.isBlank(csvRecordData[fieldNumberMap.get(CSVString)])){
                                            wrp.cif.put(CSVDataMap.get(CSVString).Field_API__c,date.parse(csvRecordData[fieldNumberMap.get(CSVString)]));
                                        }    
                                    }
                                    if(CSVDataMap.get(CSVString).Mapping_Type__c == 'Decimal'){
                                     s=CSVString;
                                        if(fieldNumberMap.containsKey(CSVString) && !String.ISBLANK(csvRecordData[fieldNumberMap.get(CSVString)]) && csvRecordData[fieldNumberMap.get(CSVString)] != '0'){
                                            wrp.cif.put(CSVDataMap.get(CSVString).Field_API__c,decimal.valueOf(csvRecordData[fieldNumberMap.get(CSVString)]));
                                        }
                                    }
                                    if(CSVDataMap.get(CSVString).Mapping_Type__c == 'ColorNotNA'){
                                     s=CSVString;
                                        if(fieldNumberMap.containsKey(CSVString) && csvRecordData[fieldNumberMap.get(CSVString)] != '0' && csvRecordData[fieldNumberMap.get(CSVString)] != 'N/A'){
                                            wrp.cif.put(CSVDataMap.get(CSVString).Field_API__c,csvRecordData[fieldNumberMap.get(CSVString)]);
                                        }   
                                    }
                                    if(CSVDataMap.get(CSVString).Mapping_Type__c == 'Other'){
                                    s=CSVString;
                                        if(fieldNumberMap.containsKey(CSVString) && csvRecordData[fieldNumberMap.get(CSVString)] != '0'){
                                            wrp.cif.put(CSVDataMap.get(CSVString).Field_API__c,csvRecordData[fieldNumberMap.get(CSVString)]);
                                        }   
                                    } 
                                }
                                
                            } 
                            //   }
                            

                            //General Contractor.
                            if(fieldNumberMap.containsKey(valGenCont) && csvRecordData[fieldNumberMap.get(valGenCont )] != '0'){
                                wrp.cif.FS_General_Contractor_Name__c = contractorBasedOnName.get(csvRecordData[fieldNumberMap.get(valGenCont )].trim());   
                            }
                            if(fieldNumberMap.containsKey(valplatform1) && csvRecordData[fieldNumberMap.get(valplatform1)] != '0'){
                                wrp.cif.FS_Platform1__c = csvRecordData[fieldNumberMap.get(valplatform1)];
                                plat1loop=csvRecordData[fieldNumberMap.get(valplatform1)]; 
                            }
                            if(fieldNumberMap.containsKey(valplatform2) && csvRecordData[fieldNumberMap.get(valplatform2)] != '0'){
                                wrp.cif.FS_Platform2__c = csvRecordData[fieldNumberMap.get(valplatform2)];
                                plat2loop= csvRecordData[fieldNumberMap.get(valplatform2)];
                            }                            
                            if(fieldNumberMap.containsKey(valplatform3) && csvRecordData[fieldNumberMap.get(valplatform3)] != '0'){
                                wrp.cif.FS_Platform3__c = csvRecordData[fieldNumberMap.get(valplatform3)];
                                plat3loop = csvRecordData[fieldNumberMap.get(valplatform3)];
                            }
                            if(fieldNumberMap.containsKey(valBrandset1) && csvRecordData[fieldNumberMap.get(valBrandset1)] != '0'){
                                brandloop = csvRecordData[fieldNumberMap.get(valBrandset1)];
                                if(brandsMap.containsKey(brandloop) && brandsMap.get(brandloop).Available_for_Selection__c  && brandsMap.get(brandloop).FS_Platform__c.contains(plat1loop)){   
                                    wrp.brandSetName1 = csvRecordData[fieldNumberMap.get(valBrandset1)];    
                                }
                                else{
                                    wrp.brandSetName1 = '';
                                }
                            }
                            if(fieldNumberMap.containsKey(valBrandset2) && csvRecordData[fieldNumberMap.get(valBrandset2)] != '0'){
                                brandloop = csvRecordData[fieldNumberMap.get(valBrandset2)];
                                if(brandsMap.containsKey(brandloop) && brandsMap.get(brandloop).Available_for_Selection__c  && brandsMap.get(brandloop).FS_Platform__c.contains(plat2loop)){

                                    wrp.brandSetName2 = csvRecordData[fieldNumberMap.get(valBrandset2)];    
                                }
                                else {

                                    wrp.brandSetName2 = '';
                                } 
                            }
                            if(fieldNumberMap.containsKey(valBrandset3) && csvRecordData[fieldNumberMap.get(valBrandset3)] != '0'){
                                brandloop = csvRecordData[fieldNumberMap.get(valBrandset3)];
                                if(brandsMap.containsKey(brandloop) && brandsMap.get(brandloop).Available_for_Selection__c  && brandsMap.get(brandloop).FS_Platform__c.contains(plat3loop)){                              
                                    wrp.brandSetName3 = csvRecordData[fieldNumberMap.get(valBrandset3)];    
                                }
                                else{
                                    wrp.brandSetName3 = '';
                                }
                            }
                            if(fieldNumberMap.containsKey('Requested Cartridge Order Method') && csvRecordData[fieldNumberMap.get('Requested Cartridge Order Method')] != '0' && FsCIFworkbookValidation.mapCartOrderMethod){
                                wrp.cif.FS_Cartridge_Order_Method__c = csvRecordData[fieldNumberMap.get('Requested Cartridge Order Method')];
                                //OCR FR 32
                                wrp.cif.FS_Delivery_Method__c = 'Direct Ship';
                                //OCR FR 32
                            } 
                            if(fieldNumberMap.containsKey('Cartridge Payment Method') && csvRecordData[fieldNumberMap.get('Cartridge Payment Method')] != '0'){
                                if(FsCIFworkbookValidation.validatePaymentval2(cartrodgePickListVal,csvRecordData,fieldNumberMap, otlpaymentMap)){
                                    wrp.cif.FS_Cartridge_Payment_Method__c = csvRecordData[fieldNumberMap.get('Cartridge Payment Method')];    
                                } 
                            }
                            if(fieldNumberMap.containsKey('Program Fee Payment Method') && csvRecordData[fieldNumberMap.get('Program Fee Payment Method')] != '0'){
                                if(FsCIFworkbookValidation.validatePaymentval3(programFeePickListVal,csvRecordData,fieldNumberMap, otlpaymentMap)){
                                    wrp.cif.FS_Program_Fee_Payment_Method__c = csvRecordData[fieldNumberMap.get('Program Fee Payment Method')];
                                }
                            }
                            if(fieldNumberMap.containsKey(valInstallPeriod) && csvRecordData[fieldNumberMap.get(valInstallPeriod)] != '0'){
                                if(csvRecordData[fieldNumberMap.get(valInstallPeriod)].contains('Week of')){
                                    wrp.cif.FS_Requested_Install_Period__c = 'Week of...'; 
                                }
                                else{
                                    wrp.cif.FS_Requested_Install_Period__c = csvRecordData[fieldNumberMap.get(valInstallPeriod)];  
                                }
                            }                                                                                                                                    
                            if(fieldNumberMap.containsKey(valdayorNight) && csvRecordData[fieldNumberMap.get(valdayorNight)] != '0'){
                                if(csvRecordData[fieldNumberMap.get(valdayorNight)].contains('Day')){
                                    wrp.cif.FS_Day_AM_or_Night_PM_Installation__c = 'Day – typically 8am start time';
                                }                                                
                                else if(csvRecordData[fieldNumberMap.get(valdayorNight)].contains('Night')){
                                    wrp.cif.FS_Day_AM_or_Night_PM_Installation__c = 'Night – typically 10pm start time';                   
                                }
                                else if(csvRecordData[fieldNumberMap.get(valdayorNight)].contains('Early AM')){
                                    wrp.cif.FS_Day_AM_or_Night_PM_Installation__c = 'Early AM – typically 5am or 6am start time';                   
                                }
                            }
                            if(fieldNumberMap.containsKey(valappWatFilter) && csvRecordData[fieldNumberMap.get(valappWatFilter)] != '0'){
                                if(csvRecordData[fieldNumberMap.get(valappWatFilter)].contains('Yes')){
                                    wrp.cif.FS_Is_an_approved_Water_Filter_Installed__c = 'Yes – approved water filter is installed';  
                                }
                                else{
                                    wrp.cif.FS_Is_an_approved_Water_Filter_Installed__c = csvRecordData[fieldNumberMap.get(valappWatFilter)];   
                                }
                            }                            
                            //Changes End
                            //FFET-1673: FET 7.1 Warranty Defect Changes
                            if(wrp.cif.FS_What_type_of_Site_Assessment__c!=FSConstants.NULLVALUE && wrp.cif.FS_What_type_of_Site_Assessment__c!=FSConstants.SANOTREQUIRED &&
                              wrp.cif.FS_Platform1__c!=FSConstants.NULLVALUE && siteAssessorDataMap.containsKey(wrp.cif.FS_Platform1__c)){
                                wrp.cif.FS_Site_Assessor__c = siteAssessorDataMap.get(wrp.cif.FS_Platform1__c).Site_Assessor__c;
                            }
                            //FFET-1673: FET 7.1 Warranty Defect Changes
                        }
                    }
                } 

            }
            for(WrpOutlet setBrandSetVal : lstOutlet_wrkbk){

                if(brandsMap.containsKey(setBrandSetVal.brandSetName1)){
                    setBrandSetVal.cif.FS_Brandset1__c = brandsMap.get(setBrandSetVal.brandSetName1).id;
                }
                if(brandsMap.containsKey(setBrandSetVal.brandSetName2)){
                    setBrandSetVal.cif.FS_Brandset2__c = brandsMap.get(setBrandSetVal.brandSetName2).id;
                }
                if(brandsMap.containsKey(setBrandSetVal.brandSetName3)){
                    setBrandSetVal.cif.FS_Brandset3__c = brandsMap.get(setBrandSetVal.brandSetName3).id;
                }
            }
        }
        catch(ListException e){

            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSCustomerInputFormHelper','readCSVFile','lstOutlet_wrkbk',FSconstants.MediumPriority,e,FSConstants.NA);
        }        
        FsCIFworkbookValidation.sendEmailWithAttachment(errorstoCSV,hqRec.FS_ACN__c );
        return lstOutlet_wrkbk;
    }    
}