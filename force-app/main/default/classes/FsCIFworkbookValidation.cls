/*****************************************************************************************
Author				: INFOSYS
Apex Class Name	: FsCIFworkbookValidation
Version        	: 1.0
Function			: To Validate the CSV file uploaded to CIF form
Modification Log   :
Developer           		   Date             Description
________________________________________________________________ 
Venkata Dinesh Kondapalli     03rd Apr 2017    Original Version
* ***************************************************************************************/
public class FsCIFworkbookValidation 
{ 
    public Static Integer successRec = 0;
    public Static Integer warningRec = 0;
    public Static Integer erroredRec = 0;
    public Static String ACNfound = 'Yes';
    public static String noVal='No';
    public static String yesVal='Yes';
    public Static String status = '';
    public Static String errDesc = '';
    private Static String  globalStatus='';
    private Static String  globalVoidStatus='0';
    private Static String  commaSign=',';
    private Static String  nextLine='<br/>';
    private Static String nextLineCSV = '\n';
    private Static String recWithWarning = 'Record loaded with warnings';
    private Static String statusNotLoad = 'Record did not load';
    private static string outletACN = 'Outlet ACN#';
    private static string bankDraft = 'Bank Draft';
    private static string creditCard = 'Credit Card';
    private static string distriBilling = 'Distributor billing';
    public static Boolean mapCartOrderMethod = true;    
    
    public static object objNull()
    {return null;} 
    @TestVisible
    private FsCIFworkbookValidation(){
    }
    
    /*********************************************************************************
Method          :           validate
Description     :           Method to validate the ACN Number of the outlet uploaded,
Mandatory fields and contact's email.
**********************************************************************************/
        
    public static List<string> validate(String[] csvRecordData, Map <String, Integer> fieldNumberMap, Map<String,WrpOutlet> outletMap, Map<String,Id> contactBasedOnEmail, 
                                        Map<String,Boolean> contactInfoCheck, List<string> recordEmailList, List<emailWrapper> contactEmailMap, Map<String, FS_CIF_CSVMapping__mdt> CSVValidateDataMap)
    {   
        final String[] csvRecordData3=csvRecordData;
        List<String> errorDet = new List<String>();
        ACNfound = 'Yes';
        status = globalStatus;
        errDesc = globalStatus;
        String recWarning=recWithWarning; 
        String ACNcheck = csvRecordData3[fieldNumberMap.get(outletACN)].trim();           
        ACNcheck = String.valueOf(integer.valueOf(ACNcheck));
        system.debug('csvData:-'+csvRecordData);
        if(outletMap.get(ACNcheck) == objNull()){
            ACNfound = 'No';    
            status = statusNotLoad;
            errDesc += System.Label.fs_outlet_not_found;                
            errorDet.add(ACNcheck);
            errorDet.add(ACNfound);
            errorDet.add(status);
            errorDet.add(errDesc);            
        }else if(outletMap.get(ACNcheck).isActiveCIF){
            ACNfound = 'No';    
            status = statusNotLoad;
            errDesc += System.Label.fs_outlet_has_CIF;                
            errorDet.add(ACNcheck);
            errorDet.add(ACNfound);
            errorDet.add(status);
            errorDet.add(errDesc);            
        }else if(outletMap.get(ACNcheck).disCustDispSA){
            ACNfound = 'No';    
            status = statusNotLoad;
            errDesc += System.Label.fs_cust_disp_cancelled;                
            errorDet.add(ACNcheck);
            errorDet.add(ACNfound);
            errorDet.add(status);
            errorDet.add(errDesc);            
        }else{   
            system.debug('contactEmailMap'+contactEmailMap);
            system.debug('contactInfoCheck'+contactInfoCheck);
            // Validate all the emails  whether they exist as contacts in the system
            for(emailWrapper wrap: contactEmailMap){
                if(string.isEmpty(contactBasedOnEmail.get(wrap.wrpEmail))){    system.debug('blank');                          
                 errDesc += wrap.wrpName +' '+System.Label.fs_contact_not_found_CIF+';';                    
                }else if(!contactInfoCheck.get(wrap.wrpEmail)){   
                    system.debug('not found');
                    errDesc += wrap.wrpName +' '+System.Label.fs_contact_not_found_CIF+';';
                }system.debug('errDesc'+errDesc);
            }
            //Changes Start
            for(String CSVString : CSVValidateDataMap.keyset()){
                if (fieldNumberMap.containskey(CSVString) && (csvRecordData3[fieldNumberMap.get(CSVString)] == globalStatus || csvRecordData3[fieldNumberMap.get(CSVString)] == globalVoidStatus)){
                    errDesc += CSVValidateDataMap.get(CSVString).Error_Message__c + ';';
                }
            }
            if(((csvRecordData3[fieldNumberMap.get('Quantity 1')] == globalStatus || csvRecordData3[fieldNumberMap.get('Quantity 1')] == globalVoidStatus) && (csvRecordData3[fieldNumberMap.get('Platform 1')] != globalStatus && csvRecordData3[fieldNumberMap.get('Platform 1')] != globalVoidStatus)) || 
               ((csvRecordData3[fieldNumberMap.get('Quantity 2')] == globalStatus || csvRecordData3[fieldNumberMap.get('Quantity 2')] == globalVoidStatus) && (csvRecordData3[fieldNumberMap.get('Platform 2')] != globalStatus && csvRecordData3[fieldNumberMap.get('Platform 2')] != globalVoidStatus)) ||
               ((csvRecordData3[fieldNumberMap.get('Quantity 3')] == globalStatus || csvRecordData3[fieldNumberMap.get('Quantity 3')] == globalVoidStatus) && (csvRecordData3[fieldNumberMap.get('Platform 3')] != globalStatus && csvRecordData3[fieldNumberMap.get('Platform 3')] != globalVoidStatus))) {
                errDesc += System.Label.fs_quantity_error+';';
            }
            if(((csvRecordData3[fieldNumberMap.get('Quantity 1')] != globalStatus && csvRecordData3[fieldNumberMap.get('Quantity 1')] != globalVoidStatus) && (csvRecordData3[fieldNumberMap.get('Brandset 1')] == globalStatus || csvRecordData3[fieldNumberMap.get('Brandset 1')] == globalVoidStatus)) || 
               ((csvRecordData3[fieldNumberMap.get('Quantity 2')] != globalStatus && csvRecordData3[fieldNumberMap.get('Quantity 2')] != globalVoidStatus) && (csvRecordData3[fieldNumberMap.get('Brandset 2')] == globalStatus || csvRecordData3[fieldNumberMap.get('Brandset 2')] == globalVoidStatus)) ||
               ((csvRecordData3[fieldNumberMap.get('Quantity 3')] != globalStatus && csvRecordData3[fieldNumberMap.get('Quantity 3')] != globalVoidStatus) && (csvRecordData3[fieldNumberMap.get('Brandset 3')] == globalStatus || csvRecordData3[fieldNumberMap.get('Brandset 3')] == globalVoidStatus))) {
                errDesc += System.Label.fs_brandset_error+';';
            }
            //Added as part of FET 5.0 844 user story
            if((csvRecordData3[fieldNumberMap.get('Platform 1')] == globalStatus || csvRecordData3[fieldNumberMap.get('Platform 1')] == globalVoidStatus) && 
               (csvRecordData3[fieldNumberMap.get('Platform 2')] == globalStatus || csvRecordData3[fieldNumberMap.get('Platform 2')] == globalVoidStatus) &&
               (csvRecordData3[fieldNumberMap.get('Platform 3')] == globalStatus || csvRecordData3[fieldNumberMap.get('Platform 3')] == globalVoidStatus)){
                errDesc += System.Label.fs_platform_error+';';
            }
            if ((csvRecordData3[fieldNumberMap.get('Remove All FTN (Legacy) Serve Dispensers?')] == globalStatus || csvRecordData3[fieldNumberMap.get('Remove All FTN (Legacy) Serve Dispensers?')] == globalVoidStatus) && csvRecordData3[fieldNumberMap.get('DRY ACCOUNT')] == noVal){
                errDesc += System.Label.fs_remove_FTN_error+';' ;
            }
            if (csvRecordData3[fieldNumberMap.get('Is an approved Water Filter installed?')] == globalStatus || csvRecordData3[fieldNumberMap.get('Is an approved Water Filter installed?')] == globalVoidStatus){
                errDesc += System.Label.fs_approved_water_error+';' ;
            }
            if ((csvRecordData3[fieldNumberMap.get('Water Filter Installer')] == globalStatus || csvRecordData3[fieldNumberMap.get('Water Filter Installer')] == globalVoidStatus ) && csvRecordData3[fieldNumberMap.get('Is an approved Water Filter installed?')] != 'Yes - approved water filter is installed') {
                errDesc += System.Label.fs_water_filter_install_error+';' ;
            }
            if (csvRecordData3[fieldNumberMap.get('General Contractor')] == globalStatus || csvRecordData3[fieldNumberMap.get('General Contractor')] == globalVoidStatus){
                errDesc += System.Label.fs_general_cont_error+';' ;
            }
            if (csvRecordData3[fieldNumberMap.get('Install Period')] == globalStatus || csvRecordData3[fieldNumberMap.get('Install Period')] == globalVoidStatus){
                errDesc += System.Label.fs_install_period_error+';' ;
            }
            if (csvRecordData3[fieldNumberMap.get('Day or Night Install')] == globalStatus || csvRecordData3[fieldNumberMap.get('Day or Night Install')] == globalVoidStatus){
                errDesc += System.Label.fs_day_night_error+';' ;
            }
            if (csvRecordData3[fieldNumberMap.get('Requested Cartridge Order Method')] == globalStatus || csvRecordData3[fieldNumberMap.get('Requested Cartridge Order Method')] == globalVoidStatus){
                errDesc += System.Label.fs_request_cart_order_error+';' ;
            }

            
            //Changes End
            if (errDesc != globalStatus){    
                status = recWarning;
            }      
            errorDet.add(ACNcheck);
            errorDet.add(ACNfound);        
            errorDet.add(status);
            errorDet.add(errDesc);
        }    
        return errorDet ;       
    }
    
    /*********************************************************************************
Method          :           buildcontactEmailMap
Description     :           Build an email wrapper list with all the emails and 
corresponding headers.
**********************************************************************************/
    public static List<emailWrapper> buildcontactEmailMap(Map<String,Integer> fieldNumberMap,string[] csvRecordData){                     
        List<EmailWrapper> contactEmailWrap = new  List<emailWrapper>();
        final String[] csvRecordData1=csvRecordData;
        String saContactEmail='SA Contact Email';
        String filterConEmail='Water Filter Installer Contact Email';
        String gcEmail='GC Email';
        String outletConEmail='Outlet Construction Contact Email';
        String onBoardConEmail='Provide On-Boarding Contact Email';
        String adminEmail='Admin User Email';
        String standardEmail='Standard User Email';
        String installConEmail='Installation Contact Email';
        String filterOutConEmail ='Water Filter Outlet Contact Email';
        EmailWrapper emailwrp1 = new EmailWrapper();
        EmailWrapper emailwrp2 = new EmailWrapper();
        EmailWrapper emailwrp3 = new EmailWrapper();
        EmailWrapper emailwrp4 = new EmailWrapper();
        EmailWrapper emailwrp5 = new EmailWrapper();
        EmailWrapper emailwrp6 = new EmailWrapper();
        EmailWrapper emailwrp7 = new EmailWrapper();
        EmailWrapper emailwrp8 = new EmailWrapper();
        EmailWrapper emailwrp9 = new EmailWrapper();
        
        if(csvRecordData1[fieldNumberMap.get(saContactEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(saContactEmail)].trim() != globalVOidStatus)
        {
            emailwrp1.wrpEmail = csvRecordData1[fieldNumberMap.get(saContactEmail)].trim().toUpperCase();     
            emailwrp1.wrpName = saContactEmail;
            contactEmailWrap.add(emailwrp1);             
        }
        if(csvRecordData1[fieldNumberMap.get(filterConEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(filterConEmail)].trim() != globalVoidStatus)
        {
            emailwrp2.wrpEmail = csvRecordData1[fieldNumberMap.get(filterConEmail)].trim().toUpperCase();     
            emailwrp2.wrpName = filterConEmail;
            contactEmailWrap.add(emailwrp2);             
        }
        if(csvRecordData1[fieldNumberMap.get(gcEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(gcEmail)].trim() != globalVoidStatus)
        {
            emailwrp3.wrpEmail = csvRecordData1[fieldNumberMap.get(gcEmail)].trim().toUpperCase();     
            emailwrp3.wrpName = gcEmail;
            contactEmailWrap.add(emailwrp3);            
        }
        if(csvRecordData1[fieldNumberMap.get(outletConEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(outletConEmail)].trim() != globalVoidStatus)
        {
            emailwrp4.wrpEmail = csvRecordData1[fieldNumberMap.get(outletConEmail)].trim().toUpperCase();     
            emailwrp4.wrpName = outletConEmail;
            contactEmailWrap.add(emailwrp4);                      
        }
        if(csvRecordData1[fieldNumberMap.get(onBoardConEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(onBoardConEmail)].trim() != globalVoidStatus)
        {
            emailwrp5.wrpEmail = csvRecordData1[fieldNumberMap.get(onBoardConEmail)].trim().toUpperCase();     
            emailwrp5.wrpName = onBoardConEmail;
            contactEmailWrap.add(emailwrp5);            
        }    
        if(csvRecordData1[fieldNumberMap.get(adminEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(adminEmail)].trim() != globalVoidStatus)
        {
            emailwrp6.wrpEmail = csvRecordData1[fieldNumberMap.get(adminEmail)].trim().toUpperCase();     
            emailwrp6.wrpName = adminEmail;
            contactEmailWrap.add(emailwrp6);            
        }    
        if(csvRecordData1[fieldNumberMap.get(standardEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(standardEmail)].trim() != globalVoidStatus)
        {
            emailwrp7.wrpEmail = csvRecordData1[fieldNumberMap.get(standardEmail)].trim().toUpperCase();     
            emailwrp7.wrpName = standardEmail;
            contactEmailWrap.add(emailwrp7);            
        } 
        if(csvRecordData1[fieldNumberMap.get(installConEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(installConEmail)].trim() != globalVoidStatus)
        {
            emailwrp8.wrpEmail = csvRecordData1[fieldNumberMap.get(installConEmail)].trim().toUpperCase();     
            emailwrp8.wrpName = installConEmail;
            contactEmailWrap.add(emailwrp8);            
        } 
        
        if(csvRecordData1[fieldNumberMap.get(filterOutConEmail)].trim() != globalStatus && csvRecordData1[fieldNumberMap.get(filterOutConEmail)].trim() != globalVoidStatus)
        {
            emailwrp9.wrpEmail = csvRecordData1[fieldNumberMap.get(filterOutConEmail)].trim().toUpperCase();     
            emailwrp9.wrpName = filterOutConEmail;
            contactEmailWrap.add(emailwrp9);            
        } 
        return contactEmailWrap;
    }
    
    /*********************************************************************************
Method          :           buildcontactEmailList
Description     :           Build a list of contactEmails for the current record
**********************************************************************************/
    public static List<String> buildcontactEmailList(Map<String,Integer> fieldNumberMap,string[] csvRecordData)
    {   
        List<String> csvRecordEmails = new List<String>();
        String[] csvRecordData2=csvRecordData; 
        if(csvRecordData2[fieldNumberMap.get('SA Contact Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('SA Contact Email')].trim().toUpperCase());        
        }         
        if(csvRecordData2[fieldNumberMap.get('Water Filter Installer Contact Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('Water Filter Installer Contact Email')].trim().toUpperCase());    
        }  
        if(csvRecordData2[fieldNumberMap.get('GC Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('GC Email')].trim().toUpperCase());    
        }
        if(csvRecordData2[fieldNumberMap.get('Outlet Construction Contact Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('Outlet Construction Contact Email')].trim().toUpperCase());    
        }
        if(csvRecordData2[fieldNumberMap.get('Provide On-Boarding Contact Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('Provide On-Boarding Contact Email')].trim().toUpperCase());    
        } 
        if(csvRecordData2[fieldNumberMap.get('Admin User Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('Admin User Email')].trim().toUpperCase());    
        }  
        if(csvRecordData2[fieldNumberMap.get('Standard User Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('Standard User Email')].trim().toUpperCase());    
        } 
        if(csvRecordData2[fieldNumberMap.get('Installation Contact Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('Installation Contact Email')].trim().toUpperCase());    
        } 
        if(csvRecordData2[fieldNumberMap.get('Water Filter Outlet Contact Email')].trim() != globalStatus)
        {
            csvRecordEmails.add(csvRecordData2[fieldNumberMap.get('Water Filter Outlet Contact Email')].trim().toUpperCase());    
        } 
        return csvRecordEmails;
    } 
    
    /*********************************************************************************
Method          :           getcatPaymentPickListVal
Description     :           collect picklist values of cartridge payment method
**********************************************************************************/
    public static  Set<String> getcatPaymentPickListVal()
    {        
        Schema.DescribeFieldResult fieldResult1 = FS_CIF__c.FS_Cartridge_Payment_Method__c.getDescribe();        
        Set<String> cartrodgePickListValues = new Set<String>();    
        for(Schema.PicklistEntry a: fieldResult1.getPicklistValues()){
            cartrodgePickListValues.add(a.getvalue());
        }
        return cartrodgePickListValues;
    }
    
    /*********************************************************************************
Method          :           getproPaymentPickListVal
Description     :           collect picklist values of program fee payment method
**********************************************************************************/
    public static  Set<String> getproPaymentPickListVal()
    {
        Schema.DescribeFieldResult fieldResult2 = FS_CIF__c.FS_Program_Fee_Payment_Method__c.getDescribe();        
        Set<String> programFeePickListValues = new Set<String>();
        for(Schema.PicklistEntry b: fieldResult2.getPicklistValues()){
            programFeePickListValues.add(b.getvalue());
        } 
        return programFeePickListValues;
    }
    
    /*********************************************************************************
Method          :           validatePaymentval
Description     :           Validate payment picklist values of CSV
**********************************************************************************/
    public static List<string> validatePaymentval(Set<String> cartridgeval, Set<String> programval,string[] csvRecordData, Map <String, Integer> fieldNumberMap,  Map<String,WrpOutlet> otlpaymentMap, List<String> errorDetails)
    {
        String ACNcheck = csvRecordData[fieldNumberMap.get(outletACN)].trim();
        ACNcheck=FSUtil.leftPadWithZeroes(ACNcheck,10);
        string isCat = otlpaymentMap.get(ACNcheck).outlet.Invoice_Customer__c;
        String isPro = otlpaymentMap.get(ACNcheck).outlet.FS_Payment_Type__c;                 
        String paymentCheck = globalStatus;
        String paymentstatus = globalStatus;
        String recWarning1=recWithWarning;        
        String cartPayMethod='Cartridge Payment Method';
        String progPayMethod='Program Fee Payment Method';
        String catPayVal = csvRecordData[fieldNumberMap.get(cartPayMethod)].trim();
        String proPayVal = csvRecordData[fieldNumberMap.get(progPayMethod)].trim();
        if(isCat == yesVal)
        {
            if(csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == globalStatus || catPayVal  == globalVoidStatus) {
                paymentCheck = errorDetails.get(3);
                paymentCheck += 'Cartridge Payment Method is not entered;' ; 
                paymentstatus = recWarning1;                
            }else{
                if(cartridgeval.contains(csvRecordData[fieldNumberMap.get(cartPayMethod)].trim())){
                    paymentCheck = errorDetails.get(3);
                    paymentstatus = errorDetails.get(2);
                }else{
                    paymentCheck = errorDetails.get(3);
                    paymentCheck += 'Cartridge payment method of the type ' + catPayVal +  ' not allowed. Please check the value of the approved for cartridge payment invoicing;' ;
                    paymentstatus = recWarning1;                    
                }
            }
            errorDetails.set(3,paymentCheck);            
            errorDetails.set(2,paymentstatus);                  
        }
        if(isCat == noVal){
            if(csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == globalStatus || catPayVal  == globalVoidStatus){
                paymentCheck = errorDetails.get(3); 
                paymentCheck += 'Cartridge Payment Method is not entered;' ;   
                paymentstatus = recWarning1;
            }else{
                if(csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == bankDraft
                   || csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == creditCard
                   || csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == distriBilling)
                {
                    paymentCheck = errorDetails.get(3); 
                    paymentstatus = errorDetails.get(2);
                }else{
                    paymentCheck = errorDetails.get(3); 
                    paymentCheck += 'Cartridge payment method of the type ' + catPayVal + ' not allowed. Please check the value of the approved for cartridge payment fee invoicing;' ;                   
                    paymentstatus = recWarning1;
                }   
            }
            errorDetails.set(3,paymentCheck);            
            errorDetails.set(2,paymentstatus);
        }
        if(isPro == yesVal){
            if(csvRecordData[fieldNumberMap.get(progPayMethod)].trim() == globalStatus || proPayVal == globalVoidStatus)         
            {
                paymentCheck = errorDetails.get(3);     
                paymentCheck += 'Program Fee Payment Method is not entered;' ;
                paymentstatus = recWarning1;
            }else{
                if(programval.contains(csvRecordData[fieldNumberMap.get(progPayMethod)].trim()))
                {
                    paymentCheck = errorDetails.get(3);
                    paymentstatus = errorDetails.get(2);
                }else{
                    paymentCheck = errorDetails.get(3);
                    paymentCheck += 'Program Fee Payment Method of the type ' + proPayVal + ' is not allowed. Please check the value of the approved for program fee invoicing;' ; 
                    paymentstatus = recWarning1;
                }
            }
            errorDetails.set(2,paymentstatus);
            errorDetails.set(3,paymentCheck);
        }
        if(isPro == noVal)
        {
            if(csvRecordData[fieldNumberMap.get(progPayMethod)].trim() == globalStatus || proPayVal == globalVoidStatus)
            {
                paymentCheck = errorDetails.get(3);
                paymentCheck += 'Program Fee Payment Method is not entered;' ;
                paymentstatus = recWarning1;                
            }else{
                if(csvRecordData[fieldNumberMap.get(progPayMethod)].trim() == bankDraft
                   || csvRecordData[fieldNumberMap.get(progPayMethod)].trim() == creditCard)
                {
                    paymentCheck = errorDetails.get(3);
                    paymentstatus = errorDetails.get(2);
                }else{
                    paymentCheck = errorDetails.get(3);
                    paymentCheck += 'Program Fee Payment Method of the type ' + proPayVal + ' is not allowed. Please check the value of the approved for program fee invoicing;' ; 
                    paymentstatus = recWarning1;                                                            
                }
            }
            errorDetails.set(2,paymentstatus);
            errorDetails.set(3,paymentCheck);                                                       
        }
        return errorDetails ;
    }    
    
    /*********************************************************************************
Method          :           validatePaymentval2
Description     :           Method to validate 'Cartridge Payment Method' value 
uploaded through workbook with respect to 'Approved 
for Cartridge Pymt Invoicing?' in outlet 
**********************************************************************************/
    
    public static boolean validatePaymentval2(Set<String> cartridgeval ,string[] csvRecordData, Map <String, Integer> fieldNumberMap,  Map<String,WrpOutlet> otlpaymentMap)
    {
        String ACNcheck = csvRecordData[fieldNumberMap.get(outletACN)].trim();
        ACNcheck=FSUtil.leftPadWithZeroes(ACNcheck,10);
        string isCat = otlpaymentMap.get(ACNcheck).outlet.Invoice_Customer__c;            
        String cartPayMethod='Cartridge Payment Method';
        String progPayMethod='Program Fee Payment Method';
        Boolean returnVal = false;
        String catPayVal = csvRecordData[fieldNumberMap.get(cartPayMethod)].trim();
        if(isCat == yesVal)
        {
            if(csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == globalStatus || catPayVal  == globalVoidStatus){
                returnVal = false;
              }
            else{
                if(cartridgeval.contains(csvRecordData[fieldNumberMap.get(cartPayMethod)].trim())){         
                    returnVal= true;
                }else{
                    returnVal =  false;  
                }
            }
        }
        if(isCat == noVal){
            if(csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == globalStatus || catPayVal  == globalVoidStatus){
                returnVal =  false;
            }
            else
            {
                if(csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == bankDraft
                   || csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == creditCard
                   || csvRecordData[fieldNumberMap.get(cartPayMethod)].trim() == distriBilling)
                {
                    returnVal = true;
                }
                else
                {
                    returnVal = false;  
                }   
            }
        }
        return returnVal; 
    }   
    
    
    /*********************************************************************************
Method          :           validatePaymentval3
Description     :           Method to validate 'Program Fee Payment Method' value 
uploaded through workbook with respect to 'Approved 
for Program Fee Invoicing?' in outlet 
**********************************************************************************/
    public static Boolean validatePaymentval3( Set<String> programval,string[] csvRecordData, Map <String, Integer> fieldNumberMap,  Map<String,WrpOutlet> otlpaymentMap)
    {
        String ACNcheck = csvRecordData[fieldNumberMap.get(outletACN)].trim();
        ACNcheck=FSUtil.leftPadWithZeroes(ACNcheck,10);
        String isPro = otlpaymentMap.get(ACNcheck).outlet.FS_Payment_Type__c;                 
        Boolean returnVal = false;
        String cartPayMethod='Cartridge Payment Method';
        String progPayMethod='Program Fee Payment Method';
        String proPayVal = csvRecordData[fieldNumberMap.get(progPayMethod)].trim();
        if(isPro == yesVal)
        {
            if(csvRecordData[fieldNumberMap.get(progPayMethod)].trim() == globalStatus || proPayVal == globalVoidStatus)         
            {
                returnVal = false;
            }else{
                if(programval.contains(csvRecordData[fieldNumberMap.get(progPayMethod)].trim()))
                {
                    returnVal = true;
                }else{
                    returnVal = false;
                }
            }
        }
        if(isPro == noVal)
        {
            if(csvRecordData[fieldNumberMap.get(progPayMethod)].trim() == globalStatus || proPayVal == globalVoidStatus)
            {
                returnVal = false;               
            }else {
                if(csvRecordData[fieldNumberMap.get(progPayMethod)].trim() == bankDraft
                   || csvRecordData[fieldNumberMap.get(progPayMethod)].trim() == creditCard)
				   {
                    returnVal = true;
                }else{
                    returnVal = false;                                                           
                }
            }                                         
        }
        return returnVal;
    }
    
    /*********************************************************************************
Method          :           checkTeamMember
Description     :           Method to validate Account team member and operational 
manager emails 
**********************************************************************************/
    public static List<String> checkTeamMember(List<AccountTeamMember__c> salesTeamMember, List<AccountTeamMember__c> comUsers, List<String> errorDetails)
    {        
        
        string checkError =  errorDetails.get(3);
        string memberStatus = errorDetails.get(2);
        String recWarning2=recWithWarning;
        if(salesTeamMember.isEmpty())
        {                
            checkError += 'Sales team member match is not found;' ; 
            memberStatus = recWarning2 ;             
        }        
        if(comUsers.isEmpty())
        {               
            checkError += 'Operations Manager match is not found;' ; 
            memberStatus = recWarning2 ;                         
        }
        errorDetails.set(2,memberStatus);
        errorDetails.set(3,checkError);
        return errorDetails;
    }
    
    //OCR FR_32
    /*********************************************************************************
Method          :           validateOrderAndDeliveryVal
Description     :           Method to validate Cartridge order method and 
Requested Delivery Method
**********************************************************************************/
    public static List<String> validateOrderAndDeliveryVal(string[] csvRecordData, Map <String, Integer> fieldNumberMap,  Map<String,WrpOutlet> otlpaymentMap,List<String> errorDetails)
    {
        String checkError =  errorDetails.get(3);
        String memberStatus = errorDetails.get(2);
        String ACNcheck = csvRecordData[fieldNumberMap.get(outletACN)].trim();
        ACNcheck=FSUtil.leftPadWithZeroes(ACNcheck,10);
        String finalOrder = otlpaymentMap.get(ACNcheck).outlet.FS_Final_Order_Method__c;
        String dinalDelivery = otlpaymentMap.get(ACNcheck).outlet.FS_Final_Delivery_Method__c;
        
        if(csvRecordData[fieldNumberMap.get('Requested Cartridge Order Method')].trim() != '0' && !String.isBlank(finalOrder) && finalOrder != null
           && !String.isBlank(dinalDelivery) && dinalDelivery != null)
        {
            checkError += 'An order and delivery method already exists on this outlet. Please validate if that is correct;';
            memberStatus = recWithWarning;
            mapCartOrderMethod = false;
        }
        errorDetails.set(2,memberStatus);
        errorDetails.set(3,checkError);
        return  errorDetails;
    }
    
    /*********************************************************************************
Method          :           writeCSVline
Description     :           Method to write the details of each record status 
and calculate the respective record status count
**********************************************************************************/
    public static String writeCSVline(List<String> errorDetails, String errorCSV)
    {        
        String successStatus='Record loaded successfully';
        String failStatus=statusNotLoad;
        String recWarning2=recWithWarning;
        String errordesc = errorDetails.get(3);
        String csvstatus = errorDetails.get(2); 
        String newErrorCSV = globalStatus;
        if(errordesc == globalStatus)
        {
            csvstatus = successStatus;
        }          
        newErrorCSV = errorCSV + errorDetails.get(0) + commaSign +errorDetails.get(1)+ commaSign +csvstatus + commaSign + errordesc + nextLineCSV;
        If(csvstatus == successStatus)
        {
            successRec += 1;    
        }
        If(csvstatus == recWarning2)
        {
            warningRec += 1;    
        }
        If(csvstatus == failStatus)
        {
            erroredRec += 1;    
        }  
        return newErrorCSV;
    }    
    
    /*********************************************************************************
Method          :          sendEmailWithAttachment
Description     :          Method to send an email with the record status and 
an attachment with all the record details    
**********************************************************************************/
    public static void sendEmailWithAttachment(string errorOutput, String hqAcn) 
    {   
        String loggedInUser = UserInfo.getUserEmail();               
        string[] toMail = new string[] {loggedInUser} ;
            string subject = 'Error output file of CIF workbook upload to HQ:' +hqAcn;  
        String mailBody = 'Hi ' + UserInfo.getName() + commaSign + nextLine + nextLine + nextLine +
            'Accounts & data values loaded successfully - ' + successRec + nextLine + nextLine +
            'Accounts loaded successfully with potential data field issues - ' + WarningRec + nextLine + nextLine +
            'Accounts not able to be found/loaded - ' + ErroredRec + nextLine + nextLine + nextLine +
            'Please find the attachment for the complete details.';
        string fileName = 'CIF-Upload-Records-Status.csv';
        FsCIF_SendEmail_Helper.sendEmailWithAttachment(errorOutput,fileName,toMail,subject,mailBody);
    }
    
    /*********************************************************************************
Class Name(Wrapper) :          EmailWrapper
Description         :          Create an email wrapper class to store all 
the emails of a record   
**********************************************************************************/
    public class EmailWrapper
    {
        Public String wrpEmail;
        Public String wrpName;
        @TestVisible
        private EmailWrapper()
        {  
        }
    }
}