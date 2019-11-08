/****************************************************************************************
Apex Class Name     : FSCustomerInputFormController
Version             : 1.0
Function            : This is a Controller class for FSCustomerInputForm which will handle all the functionlity for CIF
Modification Log    :
* Developer         : Anwesh Kalakonda   
* Date              : 5 Oct 2017               
******************************************************************************************/
global class FSCustomerInputFormController {
    public id hqAccountId;
    public Id accId{get; set;}
    public Id hqId{get;set;}
    
    public List<Account> accountLst{get;set;}
    public List<Account> sltdAccs = new List<Account>();
    public List <Account> tempAcc = new List<Account>(); 
    public List<WrpOutlet> setlstOutletPN {get;set;}
    public List<WrpOutlet> setlstOutletEP {get;set;}
    public List<WrpOutlet> lstOutletEP {get;set;}
    public List<WrpOutlet> lstOutlet{get;set;}
    public List<WrpOutlet> lstOutletPN {get;set;}
    public List<String> viewTrackerList1{get;set;} 
    public List<String> viewTrackerList2{get;set;}
    public List<FS_CIF__c> allMandList{get;set;}
    public List<FS_CIF__c> lessMandList{get;set;}
    public List<FS_CIF__c> approveList{get;set;}
    private List<FS_CIF__c> lstCIF;
    public List<FS_CIF__c> CiFs;
    
    public Set<Id> currentSelectedOutletIdsEP{get;set;}
    public Set<Id> sltdAccsIds = new Set<Id>();
    private Set<Id> currentSelectedOutletIds;
    private Set<id> selectedOutletIdsEP;    
    private Set<id> selectedOutletIds;
    private Set<id> unselectedOutletIds;
    
    private static final String OUTLET_RECORD_TYPE = 'FS Outlet';
    private static final string DEFAULT_SORT_FIELD = 'FS_ACN__c';
    public static string fsCustomerInput='FSCustomerInputFormController';
    public static string valFET='FET';
    public static string medium ='Medium';
    public static string valNA='NA';
    public static string valLstOutlet= 'lstOutlet';
    public static string notApplicable = 'NA';
    public static string empStr = '';
    public static string emptyStr = '';
    public static string nullStr = null;
    public string strLstOutlet = 'lstOutlet';    
    public string fetSysAdmin = 'FET System Admin';
    public string sysAdmin = 'System Administrator';
    public string saNotRequired = 'SA Not Required - OSM approval required for local market';
    public string isYes = 'Yes';
    public string isNo = 'No';
    public string isCustomer = 'Customer';
    public string isYesInstalled = 'Yes – approved water filter is installed';
    public String currentURLParm ;
    public String sectionName {get;set;}
    public String currentCIFId {get;set;}
    public String currentStage {get;set;}
    public String previousStage {get;set;}
    public string objectType{get;set;}
    public String[] searchOutletACNLst;
    public String tabWidth1 {get;set;}
    public String tabWidth2 {get;set;}
    public String cifCsvFileName {get;set;}
    public String sortField{set;get;}
    public String cifUpldErr = '';
    public String profileName {get;set;}
    public Profile prof;
    private transient String hqDate {get;set;}
    private transient String hqTime {get;set;}
    
    private Boolean wrkbkUpload;
    private Boolean changeSec;
    public Boolean onLoadCheck; 
    
    public Boolean isAsc{set; get;}
    public Boolean showCnt{get;set;}
    public Boolean isClosed{get;set;}
    public Boolean enblSectn{get;set;}
    public Boolean disableField{get;set;}
    public Boolean cifHeadStatus {get;set;}
    public Boolean checkStatus{get;set;}
    public Boolean finalStatus{get;set;}
    public Boolean notiSize{get;set;}    
    public Boolean displayPopup{get;set;}
    public Boolean displayPopup1{get;set;}
    public Boolean displayPopup2{get;set;}
    public Boolean displayPopup3{get;set;}
    public Boolean displayPopup4{get;set;}
    public Boolean displayPopup5{get;set;} 
    public boolean passCIF = false;
    public Boolean isUpldErr = false;
    
    public Map<String, String> viewStateTrackerList{get;set;}    
    public Map<String, String> viewStateTrackerList1{get;set;}  
    public Map<Id,FS_CIF__c> mapOut{get;set;}
    public static integer valZero=0;
    public integer RecordCount {get;set;}
    public Integer zero = 0;  
    public Integer currentSelSize {get;set;}
    public Integer counterCanCheck;
    public Integer counterNACheck;
    public Integer spancol {get;set;}
    private Integer setStartNumber;
    private Integer setI;
    private Integer count=0;
    public CIF_Header__c cifHead{get;set;} 
    public CIF_Header__c CIFHeader;
    private FSPaginationCustomIterable pageNat;
    private FSPaginationCustomIterable pnEP;
    public FSCustomerInputFormNewAndEdit cifNE;
    public Account hqAccount{get;set;}
    public Transient List<FS_CIF__c> listCif{get;set;}   
    public Blob cifCsvFileBody {get;set;}
    public Static Id ipRecTypeReplacement;
    public Static Id ipNewRecType;
    
    List<FS_Customer_Disp_After_SA__c> custDisSAs{get;set;}  
    Datetime hqDT = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
    
    public Contact crtCnt {
        get {if (crtCnt == objNull()){crtCnt = new Contact();}return crtCnt;}
        set;
    }
    
    public static object objNull()
    {return null;}  
    public static Id idNull()
    {return null;}
    public string strNull()
    {return null;}
    
    /*****************************************************************
Method: searchOutletName()
Description: Set and get the outlet name while searching outlet.
*******************************************************************/
    public String searchOutletName{
        get{
            if(searchOutletName == strNull())
            {return emptyStr;}
            else {return searchOutletName.trim();}
        }
        set;
    }
    
    /******************************************************************
Method: searchOutletACN()
Description: Set and get the outlet ACN while searching outlet.
*******************************************************************/
    public String searchOutletACN{
        get{
            if(searchOutletACN == strNull())
            {return emptyStr;}
            else {return searchOutletACN.trim();}
        }
        set;
    }
    
    /******************************************************************
Method: searchOutletCity()
Description: Set and get the outlet City while searching outlet.
*******************************************************************/
    public String searchOutletCity{
        get{
            if(searchOutletCity == strNull())
            {  return emptyStr;}
            else {return searchOutletCity.trim();}
        }
        set;
    }
    
    /******************************************************************
Method: searchOutletState()
Description: Set and get the outlet State while searching outlet.
*******************************************************************/
    public String searchOutletState{
        get{
            if(searchOutletState == strNull())
            { return emptyStr;}
            else {return searchOutletState.trim();}
        }
        set;
    }
    
    /*****************************************************************
Method: sortString()
Description: Specifies the sorting method ascending or descending.
*******************************************************************/
    public String sortString {
        get{
            if (!String.isBlank(sortField)) {
                String sortOrder = isAsc ? ' ASC ' : ' DESC ';
                return sortField + sortOrder;
            } else {
                return DEFAULT_SORT_FIELD;
            }
        }
    }
    
    /*****************************************************************
Method: updateMap()
Description: Builds the outlet map from selected outlets
*******************************************************************/
    public void updateMap(){
        for(WrpOutlet outAcc : setlstOutletPN){            
            if(mapOut.containskey(outAcc.Outlet.Id) && outAcc.cif !=null){mapOut.put(outAcc.Outlet.Id,outAcc.cif);}
        }
    }
    
    public void getCIFOnNext(){
        if(objectType !='Account' ){
            passCIF = false;    
        }
        actionCopyCustomerInput();
    }
    
    public PageReference getCIFOnSave(){
        passCIF = true;      
        return  actionCopyCustomerInput();
    }
    /*****************************************************************
Method: hasNextPN()
Description: Checks if page has to navigate next.
*******************************************************************/
    public Boolean hasNextPN {
        get{if(sectionName ==FSConstants.SECCREATEEP){return pnEP.hasNext();}
            else{return pageNat.hasNext();}
           }
        set;
    }
    
    /*****************************************************************
Method: hasFirstPN()
Description: Checks if page has to navigate previous.
*******************************************************************/
    public Boolean hasFirstPN {
        get{if(sectionName ==FSConstants.SECCREATEEP){return pnEP.hasPrevious();}
            else{return pageNat.hasPrevious();}
           }
        set;
    }
    
    /*****************************************************************
Method: hasLastPN()
Description: Checks if page has to navigate next.
*******************************************************************/
    public Boolean hasLastPN {
        get{if(sectionName ==FSConstants.SECCREATEEP){return pnEP.hasNext();}
            else{return pageNat.hasNext();}
           }
        set;
    }
    
    /*****************************************************************
Method: hasPreviousPN()
Description: Checks if page has to navigate previous.
*******************************************************************/
    public Boolean hasPreviousPN {
        get{if(sectionName ==FSConstants.SECCREATEEP){return pnEP.hasPrevious();}
            else{return pageNat.hasPrevious();}
           }
        set;
    }
    
    public integer LNumberPN {
        get{return pageNat.LNumber;}
        set;
    }
    
    public integer UNumberPN {
        get{return pageNat.UNumber;}
        set;
    }
    
    public integer RecordCountPN {
        get{return pageNat.RecordCount;}
        set;
    }
    
    public integer PageNumberPN {
        get{return pageNat.PageNumber;}
        set;
    }
    
    public integer PageCountPN {
        get{return pageNat.PageCount;}
        set;
    }
    
    /*****************************************************************
Method: FSCIFController()
Description: Constructor
*******************************************************************/    
    public FSCustomerInputFormController (ApexPages.StandardController controller) {
        ipNewRecType=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,FSConstants.NEWINSTALLATION);
        ipRecTypeReplacement=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,Label.IP_Replacement_Rec_Type);
        string hqAccid = ApexPages.currentPage().getParameters().get('AccId'); //Get the ID from URL.
        string hqid = ApexPages.currentPage().getParameters().get('Id'); //Get the ID from URL.
        Id sId = (Id)hqAccid;
        enblSectn = true;
        // objectType = sId.getSObjectType().getDescribe().getName();            //Get the object for which above ID belongs to.
        if(hqid == null){
            objectType = 'Account';
        }else{
            objectType = 'CIF_Header__c';
        } 
        custDisSAs =  new List<FS_Customer_Disp_After_SA__c>();
        custDisSAs = FS_Customer_Disp_After_SA__c.getall().values();
        cifHead = new CIF_Header__c();
        cifNE = new FSCustomerInputFormNewAndEdit();
        If(objectType == 'Account')  {  // Get the HQ details if the object type is Accout that is Headquarter.
            hqAccount = cifNE.getHQDetails(sId);
        }   
        else{                            // Get the CIF header details if the object type is CIF Header.
            currentCIFId = hqid;
            cifHead = cifNE.getCIFHeaderDetails(hqid);                   
            hqId = cifHead.Id;
        } 
        Id profileId=userinfo.getProfileId();
        try{
            prof = [select id,name from profile where ID=:profileId];
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog(valFET, fsCustomerInput, 'FSCustomerInputFormController', 'Profile', Medium, e, valNA);
        } 
        profileName=prof.Name;
    }
    
    /*****************************************************************
Method: nextPN()
Description: Navigates to the next page
*******************************************************************/
    public void nextPN(){
        if(sectionName ==FSConstants.SECCREATEEP){setlstOutletEP = pnEP.next();}
        else{
            updateMap();
            pageNat.PageNumber++; 
            if (pageNat.PageNumber > pageNat.PageCount) {pageNat.PageNumber = pageNat.PageCount;}
            setlstOutletPN = pageNat.next();
        }
    }
    
    /*****************************************************************
Method: firstPN()
Description: Navigates to the first page
*******************************************************************/
    public void firstPN(){
        if(sectionName ==FSConstants.SECCREATEEP){setlstOutletEP = pnEP.first();}
        else{
            updateMap();
            setlstOutletPN = pageNat.first();
            pageNat.PageNumber = 1;
        }
    }
    
    /*****************************************************************
Method: previousPN()
Description: Navigates to the previous page
*******************************************************************/
    public void previousPN(){
        if(sectionName ==FSConstants.SECCREATEEP){setlstOutletEP = pnEP.previous();}
        else{
            updateMap();
            pageNat.PageNumber--;
            if (pageNat.PageNumber <= zero) {pageNat.PageNumber = 1;}
            setlstOutletPN = pageNat.previous();
        }
    }
    
    /*****************************************************************
Method: lastPN()
Description: Navigates to the last page
*******************************************************************/
    public void lastPN(){
        if(sectionName ==FSConstants.SECCREATEEP){setlstOutletEP = pnEP.last();}
        else{
            updateMap();
            setlstOutletPN = pageNat.last();
            pageNat.PageNumber = pageNat.PageCount;
        }
    }
    //pagination end
    /*****************************************************************
Method: closePopup()
Description: Closes the upload workbook popup.
*******************************************************************/
    public void closePopup() {displayPopup = false;}     
    
    /*****************************************************************
Method: showPopup()
Description: Shows the upload workbook popup.
*******************************************************************/
    public void showPopup() {displayPopup = true;}
    
    /*****************************************************************
Method: closePopup1()
Description: Closes the approved outlets warning message.
*******************************************************************/
    public void closePopup1() {displayPopup1 = false;} 
    
    /*****************************************************************
Method: showPopup1()
Description: Opens the approved outlets warning message.
*******************************************************************/
    public void showPopup1() {displayPopup1 = true;}
    
    /*****************************************************************
Method: closePopup2()
Description: Closes the cancel CIF popup.
*******************************************************************/
    public void closePopup2() { displayPopup2 = false;checkstatus=true;}  
    
    /*****************************************************************
Method: showPopup2()
Description: Shows the cancel CIF popup.
*******************************************************************/
    public void showPopup2() {
        displayPopup2 = true;
        currentStage=cifNE.previousStage;
        sectionName=cifNE.previousSec;
    }
    
    /*****************************************************************
Method: closePopup3()
Description: Closes the save popup with semi filled data.
*******************************************************************/
    public void closePopup3() {
        displayPopup3 = false; 
        currentStage=cifNE.previousStage;
        sectionName=cifNE.previousSec;
    }
    
    /*****************************************************************
Method: showPopup3()
Description: Shows the save popup with semi filled data.
*******************************************************************/
    public void showPopup3() {displayPopup3 = true;}
    
    /*****************************************************************
Method: closePopup4()
Description: Closes popup on savebutton click
*******************************************************************/
    public void closePopup4() {displayPopup4 = false;}  
    
    /*****************************************************************
Method: showPopup4()
Description: Open popup on savebutton click
*******************************************************************/
    public void showPopup4() {displayPopup4 = true;}
    
    /*****************************************************************
Method: closePopup5()
Description: Closes popup for EP creation 
*******************************************************************/
    public void closePopup5() {displayPopup5 = false;}
    
    /*****************************************************************
Method: showPopup5()
Description: Open popup for EP creation 
*******************************************************************/
    public void showPopup5() {displayPopup5 = true;}
    
    
    /*****************************************************************
Method          : resetSearchStatus()
Description     : Reset all the outlet search strings to empty
*******************************************************************/
    public void resetSearchStatus() {
        searchOutletName = emptyStr;
        searchOutletCity = emptyStr;
        searchOutletState = emptyStr;
        searchOutletACN = emptyStr;
    }
    /*****************************************************************
Method          : searchOutletButton()
Description     : Searches outlets based on the entered text
*******************************************************************/
    public void searchOutletButton(){
        if(objectType == 'Account'){    
            for(WrpOutlet wrp: setlstOutletPN){
                if(wrp.isSelected){
                    currentSelectedOutletIds.add(wrp.outlet.id);
                }
            } 
            searchOutlet();
        }
        else{
            List <Account> accountLstfromHQ = new List<Account>();
            try{
                for(WrpOutlet wrp: setlstOutletPN){
                    if(wrp.isSelected){
                        currentSelectedOutletIds.add(wrp.outlet.id);
                    }
                }
                sltdAccs.clear();
                sltdAccsIds.clear();
                accountLst.clear();
                sortField = FSConstants.DEFAULT_SORT_FIELD;                                                         
                isAsc = true;
                wrkbkUpload = false;         
                searchOutletACNLst = new String[]{};
                    cifNE.searchOutletACN=searchOutletACN; cifNE.searchOutletCity=searchOutletCity; cifNE.searchOutletName=searchOutletName; cifNE.searchOutletState=searchOutletState;
                String query = cifNE.buildSearchQuery(OUTLET_RECORD_TYPE,accId,sortString);
                
                searchOutletACNLst = cifNE.searchOutletACNLst;
                accountLstfromHQ = Database.query(query);
                for(Account tmpAcc: accountLstfromHQ){
                    if(!sltdAccsIds.contains(tmpAcc.id)){
                        accountLst.add(tmpAcc);
                    }               
                }     
                updateOutletList();
            }catch(QueryException e){
                ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'searchOutlet',valLstOutlet,medium,e,valNA); 
            }
        }
    }
    
    /*****************************************************************
Method          : getreadFromFile()
Description     : Read the outlet data from uploaded workbook
*******************************************************************/ 
    public PageReference getreadFromFile(){
        try{
            If(cifCsvFileName == null || cifCsvFileName==''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a CSV Sales Workbook file before clicking on Upload'));
                return ApexPages.CurrentPage();
            }
            If(!(cifCsvFileName.endsWith('csv') || cifCsvFileName.endsWith('CSV')))
            {
                cifCsvFileName = null;
                cifCsvFileBody = null;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please upload a file of type CSV'));
                return null;  
            }
            
            FSCustomerInputFormHelper fsCIFHelperObj = new FSCustomerInputFormHelper();
            Integer BlobSize = cifCsvFileBody.size();
            Decimal CSVSizeinKB = Decimal.valueof(BlobSize/1024).setscale(0);
            System.debug('@@ BlobSize::'+ BlobSize);
            if(BlobSize > 470 * 1024){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,Label.FS_CIF_workbook_upload_error+' '+ CSVSizeinKB +' '+Label.CIF_workbook_upload_error_2);
                ApexPages.addMessage(myMsg);
            }else{
			system.debug('called fsCIFHelperObj');
                lstOutlet = fsCIFHelperObj.readCSVFile(cifCsvFileBody.toString(),hqAccount,currentSelectedOutletIds,cifHead);            
                Set<id> lstIds = new Set<id>();
                
                for(Account acc: accountLst){
                    lstIds.add(acc.Id);             
                }       
                for(WrpOutlet wrp: lstOutlet){
                    
                    if(!lstIds.contains(wrp.outlet.Id)){                
                        tempAcc.add(wrp.outlet);
                    }
                }
                if(!tempAcc.isEmpty()){
                    accountLst.addAll(tempAcc);
                } 
                
                setSelectedAccounts();
                wrkbkUpload = true;
                
                for(WrpOutlet wrp: lstOutlet){
                    if(!mapOut.isEmpty()){mapOut.put(wrp.outlet.Id,wrp.cif);}
                    else if(!mapOut.containsKey(wrp.outlet.Id)){mapOut.put(wrp.outlet.Id,wrp.cif);}
                }
                
                cifHead = fsCIFHelperObj.cifHead;
                currentSelectedOutletIds = cifNE.updateSelection(currentSelectedOutletIds,lstOutlet);
                updateOutletList(); 
            }
            
            
        }catch(ListException e){
            ApexErrorLogger.addApexErrorLog('FET','FSCustomerInputFormController','getreadFromFile',valLstOutlet,'Medium',e,'NA');
            wrkbkUpload = false;   
        }
        closePopup();
        return null;
    }
    
    /*****************************************************************
Method: createContact()
Description: createContact method is to create new contact on CIF
*******************************************************************/
    @RemoteAction
    global static void createContact(Contact crtCnt1){
        //try{
        //crtCnt1.AccountID = accID;
        Insert crtCnt1;
        //showCnt = true;
        //crtCnt = new Contact();
        //closePopup4();
        //}catch (DMLException e){ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'createContact','crtCnt',medium,e,valNA);}
        //return null;
    }
    
    /*****************************************************************
Method: onLoad()
Description: onLoad method is to get the outlet's data and display the cheviron.
*******************************************************************/
    public void onLoad(){
        setlstOutletPN=new List<WrpOutlet>();
        setlstOutletEP = new List<WrpOutlet>();
        currentSelectedOutletIds = new Set<id>();
        currentSelectedOutletIdsEP = new Set<id>();
        viewTrackerList1 = new List<String>();
        viewTrackerList2 = new List<String>();
        viewStateTrackerList = new Map<String,String>();
        viewTrackerList1=cifNE.setViewTrackerList1(viewTrackerList1);
        viewTrackerList2=cifNE.setViewTrackerList2(viewTrackerList2);
        viewStateTrackerList=cifNE.setViewStateTracketList(viewStateTrackerList);
        this.tabWidth1 = 'layout:fixed;width: ' + 100/((viewTrackerList1.size()+viewTrackerList2.size())/2) + '%;';
        this.tabWidth2 = 'layout:fixed;width: ' + 100/(viewTrackerList2.size()/2) + '%;';
        
        if(objectType == 'Account') {
            onLoadCreateCIF();
        }
        else {
            onLoadEditCIF();
        }
        
        List<FS_CIF_Closed_Status__c> clsdSts = FS_CIF_Closed_Status__c.getall().values();
        List<FS_CIF_View_Profiles__c> viewProfLis = FS_CIF_View_Profiles__c.getall().values();
        hqAccount = cifNE.getHQDetails(hqAccount.id);
        selectedOutletIdsEP = new Set<id>();
        selectedOutletIds = new Set<id>();
        unselectedOutletIds = new Set<id>();
        mapOut=new Map<Id,FS_CIF__c>();
        notiSize = false;displayPopup1 = false;displayPopup2 = false;displayPopup3 = false;displayPopup4 = false;displayPopup5 = false;showCnt = true;checkStatus= true;finalStatus=true;wrkbkUpload = false;changeSec = false;
        
        if(objectType != 'Account') {
            System.debug('Setting it as complete');
            viewStateTrackerList.put(FSConstants.SELECTOUTLETS, FSConstants.COMPLETED);
            onLoadCheck = true;
            wrkbkUpload=true;
        }
        
        searchOutlet();
        
        if(objectType != 'Account') {
            setStageEditCIF();
        }
        
        for(FS_CIF_Closed_Status__c clsdst :clsdSts)
        {
            if(clsdst.Status__c==cifHead.FS_Status__c){
                isClosed = true;
                break;
            }
        }
        // OCR FR22 Restrict Sales User to create and edit CIF
        for(FS_CIF_View_Profiles__c viewProfi :viewProfLis)
        {
            if(viewProfi.Profile_Name__c == profileName){
                isClosed = true;
                break;
            }
        }
        
        if(objectType != 'Account') {       
            onLoadCheck = false;        
        }      
    }
    
    /*****************************************************************
Method          : searchOutlet()
Description     : searches outlets with the entered text
*******************************************************************/     
    public void searchOutlet(){
        List <Account> accountLstfromHQ = new List<Account>();
        try{
            if(objectType == 'Account'){
                sortField = FSConstants.DEFAULT_SORT_FIELD;
                isAsc = true;
                cifNE.searchOutletACN = searchOutletACN; 
                cifNE.searchOutletCity = searchOutletCity; 
                cifNE.searchOutletName = searchOutletName; 
                cifNE.searchOutletState = searchOutletState;
                String query = cifNE.buildSearchQuery(OUTLET_RECORD_TYPE,accId,sortString);
                System.debug('queryqueryquery:: ' +accId  +'******' + query);
                searchOutletACNLst = cifNE.searchOutletACNLst;
                accountLst = Database.query(query);
                if(accountLst != null && !accountLst.isEmpty())
                {   enblSectn = true;
                 updateOutletList();
                }else{
                    enblSectn = false;
                    System.debug('Its giving warning message');
                    ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'There are no outlets under this Headquarter.');
                    ApexPages.addMessage(warningMessage);               
                }
            } 
            else{
                sltdAccs.clear();
                sltdAccsIds.clear();
                sortField = FSConstants.DEFAULT_SORT_FIELD;                                                         
                isAsc = true;
                System.debug('currentCIFIdcurrentCIFId in search outlet' + currentCIFId);    
                if(currentCIFId != strNull()){
                    if(onloadCheck){
                        lstCIF= cifNE.getCIFLst(currentCIFId);                      
                        for(FS_CIF__c cif: lstCIF){
                            selectedOutletIds.add(cif.FS_Account__c);
                            currentSelectedOutletIds.add(cif.FS_Account__c);
                        }
                    }
                    System.debug('currentSelectedOutletIds' +currentSelectedOutletIds.size());
					//New Set created as part of US FNF-785.
					Set<String> recTypeIdSet = new Set<String>{ipNewRecType,ipRecTypeReplacement};
                    for(Account sAcc : [SELECT Id,FS_ACN__c,ShippingCountry ,Phone,FS_Headquarters__c,FS_Headquarters__r.FS_ACN__c,FS_Headquarters__r.FS_SAP_ID__c,FS_Chain__r.name,FS_Chain_ACN__c,FS_Store_Number__c,FS_Admin_User__c,FS_Payment_Type__c,Invoice_Customer__c, FS_SAP_ID__c,Total_VPO__c,FS_Count_Total_number_of_Dispensaries__c, Name, Bottler_Name__c,FS_Primary_Contact__c,FS_ALL_FS_Equipment_Removed__c,FS_Approved_For_Execution_Plan__c,FS_Revenue_Center__c, ShippingStreet, ShippingState, ShippingCity, ShippingPostalCode, FS_Headquarters__r.Name, Latest_Installation_Status__c,
                                        FS_Site_Assessment_Contact__r.Email,FS_Site_Assessment_Contact__r.Phone,FS_Site_Assessment_Contact__r.Title,FS_Site_Assessment_Contact__r.OtherPhone, BillingStreet, BillingCity, BillingState, BillingPostalCode, Ownership, FS_Requested_Channel__c, FS_Market_ID__c, Bottlers_Name__r.Name, FS_HQ_ACN__c, FS_Site_Assessment_Contact__r.Name,
                                        FS_Distributor__r.Name,FS_Distributor__r.ShippingStreet,FS_Distributor__r.ShippingCity,FS_Distributor__r.ShippingState,FS_Distributor__r.ShippingPostalCode, FS_CS_Bill_To_Address__c,FS_CS_Bill_To_City__c,FS_CS_State__c,FS_CS_Bill_To_Zip__c,Cokesmart_Payment_Method__c,FS_Payment_Method__c,
                                        BillingCountry,FS_VMS_Customer__c,FS_Admin_User_Name__c,FS_Admin_User_Title__c,FS_Admin_User_Email__c,FS_Requested_Order_Method__c ,FS_Admin_User_Phone__c,FS_Standard_User__c,FS_Standard_User_Function__c,FS_Standard_User_Email__c,FS_Standard_User_Phone__c,FS_Concatenated_Address__c,FS_Site_Assessment_Contact__c,FS_Site_Assessment_Contact_Title__c,
                                        FS_Site_Assessment_Contact_Phone__c,FS_Site_Assessment_Contact_Alt_Phone__c,FS_Site_Assessment_Contact_Email__c,FS_Legal_Entity_Name__c, FS_Requested_Delivery_Method__c,FS_Final_Delivery_Method__c,FS_Final_Order_Method__c,
                                        (SELECT Id,RecordType.Name, FS_Overall_Status__c FROM Installations5__r WHERE RecordType.Name = 'Relocation (O4W)' AND FS_Overall_Status__c NOT IN (:FSConstants.IPCOMPLETE ,:FSConstants.IPCANCELLED ,'') AND FS_Overall_Status__c != null LIMIT 1),
                                        (SELECT Id, Name,RecordType.Name,RecordTypeid,FS_Overall_Status__c,	FS_Same_incoming_platform__c, CreatedDate FROM Installations1__r WHERE RecordTypeId IN: recTypeIdSet AND FS_Overall_Status__c NOT IN (:FSConstants.IPCOMPLETE ,:FSConstants.IPCANCELLED ,'') AND FS_Overall_Status__c != null ORDER BY CreatedDate DESC),
                                        (SELECT Id, Name,CIF_Head__c,FS_What_type_of_Site_Assessment__c,FS_Davaco_Order_Entered__c,FS_Customer_s_disposition_after_review__c,FS_CIF_Header__c,FS_Perf_Site_Assessment__c,SA_Status__c,CIF_Head__r.FS_CIF_Number__c from CIF9__r where FS_CIF_Header_Status__c = 'In Progress' and  CIF_Head__c =: cifHead.id ORDER BY CreatedDate DESC) 
                                        FROM Account WHERE RecordType.Name = :OUTLET_RECORD_TYPE AND ID IN :currentSelectedOutletIds]){
                                            sltdAccs.add(sAcc);
                                            sltdAccsIds.add(sAcc.Id);
                                        }
                }           
                if(!sltdAccs.isEmpty()){
                    accountLst.addAll(sltdAccs);
                }           
                searchOutletACNLst = new String[]{};
                    cifNE.searchOutletACN=searchOutletACN; cifNE.searchOutletCity=searchOutletCity; cifNE.searchOutletName=searchOutletName; cifNE.searchOutletState=searchOutletState;
                String query = cifNE.buildSearchQuery(OUTLET_RECORD_TYPE,accId,sortString);
                searchOutletACNLst = cifNE.searchOutletACNLst;
                accountLstfromHQ = Database.query(query);         
                for(Account tmpAcc: accountLstfromHQ){
                    if(!sltdAccsIds.contains(tmpAcc.id)){
                        accountLst.add(tmpAcc);
                    }               
                }
                updateOutletList();
                sltdAccs.clear();
                sltdAccsIds.clear();
            }
        }catch(QueryException e){
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,FSConstants.FSCustomerInputFormController,'searchOutlet',strLstOutlet,FSConstants.MediumPriority,e,notApplicable); 
        }
    }
    
    /*****************************************************************
Method          : updateOutletList()
Description     : Updates the outlets list of the selected headquarter
*******************************************************************/    
    private void updateOutletList(){
        lstOutlet = new List<WrpOutlet>();
        lstOutletPN = new List<WrpOutlet>();
        String instalNumber;
        String isRO4WExist;
		String isReplaceExist;//FET7.0 FNF-795
        FS_CIF__c cifLineItem;
        Boolean isActiveCIF= false;
        Boolean isCustDispAfSA = false;
        Boolean enableSel = false;
        boolean disCustDispSA = false;
        Map<Integer,Account> sortMap = new Map<Integer,Account>();
        List <Account> tempAcc2 = new List<Account>(); 
        
        if(wrkbkUpload){                
            Set<id> lstIds = new Set<id>();
            for(Account acc: accountLst){
                lstIds.add(acc.Id);             
            }       
            for(Account wrp: tempAcc){
                if(!lstIds.contains(wrp.Id)){                
                    tempAcc2.add(wrp);
                }
            }
            if(!tempAcc2.isEmpty()){
                accountLst.addAll(tempAcc2);
            }
        }
        for(Account acc : accountLst){
            sortMap.put(Integer.valueOf(acc.FS_ACN__c),acc);
        }
        List<Integer> keyList = new List<Integer>();
        keyList.addAll(sortMap.keySet());
        keyList.sort();
        accountLst.clear();
        for(Integer key:keyList){
            accountLst.add(sortMap.get(key));
        }
        for(Account acc : accountLst){
            instalNumber=emptyStr;
            cifLineItem = new FS_CIF__c();
            if(acc.Installations1__r != null && !acc.Installations1__r.isEmpty()){
                for(FS_Installation__c inst: acc.Installations1__r){
                    If(inst.RecordtypeId == ipNewRecType){
						instalNumber = inst.Name;
					}
					//FET7.0 FNF-795 Start
					if(inst.RecordtypeId == ipRecTypeReplacement && inst.FS_Same_incoming_platform__c == FSConstants.NO){
						isReplaceExist = FSConstants.YES;
					}
					//FET7.0 FNF-795 End
                }
            }
            //FET7.0 FNF-835 Start
            if(!acc.Installations5__r.isEmpty()){
                isRO4WExist = FSConstants.YES;
            }
            //FET7.0 FNF-835 End
			
            
            if(acc.CIF9__r != null && !acc.CIF9__r.isEmpty()){
                for(FS_CIF__c cif : acc.CIF9__r){
                    cifLineItem = cif;
                }
            }
            
            for(FS_Customer_Disp_After_SA__c custDisSA :custDisSAs){
                if(custDisSA.Status__c==cifLineItem.FS_Customer_s_disposition_after_review__c){
                    isCustDispAfSA = true;
                    break;
                }else{
                    isCustDispAfSA = false;
                }
            }
            
            if(objectType == 'Account'){    
                if((cifLineItem.CIF_Head__c != NUll && cifLineItem.FS_CIF_Header__c != Null && !isCustDispAfSA) || instalNumber != empStr){
                    isActiveCIF = true; 
                }else{
                    isActiveCIF = false; 
                }
				List<FS_Installation__c> installLst = new List<FS_Installation__c>();
				for(FS_Installation__c inst: acc.Installations1__r){
                    If(inst.RecordtypeId == ipNewRecType){
						installLst.add(inst);
					}
                }
                lstOutlet.add(new WrpOutlet(acc,installLst,cifLineItem,acc.CIF9__r,instalNumber,!installLst.isEmpty(),isActiveCIF,currentSelectedOutletIds.contains(acc.Id),isActiveCIF,false,isRO4WExist,isReplaceExist));//FET7.0 FNF-795
                isRO4WExist = FSConstants.BLANKVALUE;
				isReplaceExist = FSConstants.BLANKVALUE;//FET7.0 FNF-795
            } else {
                if(isCustDispAfSA && (profileName == fetSysAdmin || profileName == sysAdmin)){
                    disCustDispSA = false;
                }else if(isCustDispAfSA && (profileName != fetSysAdmin || profileName != sysAdmin)){
                    
                    disCustDispSA = true;   
                }else{
                    
                    disCustDispSA = false;   
                }
                
                if(((cifLineItem.CIF_Head__c == cifHead.id)|| (cifLineItem.CIF_Head__c == Null && cifLineItem.FS_CIF_Header__c == null ) || isCustDispAfSA) && instalNumber == emptyStr){
                    
                    isActiveCIF = false; 
                    
                }else{
                    isActiveCIF = true;
                }
                
                if(!isActiveCIF && cifHead.FS_Status__c=='In Progress' && !isCustDispAfSA && (cifLineItem.FS_Perf_Site_Assessment__c == isYes || cifLineItem.FS_Perf_Site_Assessment__c == isNo) ){                    
                    enableSel = false; 
                }//4288
                else if(cifLineItem.CIF_Head__c == cifHead.id && !isActiveCIF && cifHead.FS_Status__c=='In Progress' && (cifLineItem.FS_Customer_s_disposition_after_review__c == 'Cancelled' || cifLineItem.FS_Customer_s_disposition_after_review__c == 'Not Approved')){                    
                    
                    enableSel = false;
                }else{
                    if(isActiveCIF){ enableSel=false; }
                    else {enableSel =true; }
                }
				List<FS_Installation__c> installLst = new List<FS_Installation__c>();
				for(FS_Installation__c inst: acc.Installations1__r){
                    If(inst.RecordtypeId == ipNewRecType){
						installLst.add(inst);
					}
                }
                lstOutlet.add(new WrpOutlet(acc,installLst,cifLineItem,acc.CIF9__r,instalNumber,!installLst.isEmpty(),isActiveCIF,currentSelectedOutletIds.contains(acc.Id),enableSel,disCustDispSA,isRO4WExist,isReplaceExist));//FET7.0 FNF-795
                system.debug('IS REPLACEMENT ELSE Account lstOutlet'+lstOutlet);
                isRO4WExist = FSConstants.BLANKVALUE;
				isReplaceExist = FSConstants.BLANKVALUE;//FET7.0 FNF-795
            }
        }
        List<WrpOutlet> checkedOutlets = new List<WrpOutlet>();
        List<WrpOutlet> unCheckedOutlets = new List<WrpOutlet>();
        
        for(WrpOutlet wrp: lstOutlet){
            if(wrp.isActiveCIF){
                checkedOutlets.add(wrp); 
            } else{
                unCheckedOutlets.add(wrp);  
            }
        }
        lstOutlet.clear();
        lstOutlet.addAll(unCheckedOutlets);
        lstOutlet.addAll(checkedOutlets);
        if(wrkbkUpload){
            List<WrpOutlet> selOutlet = new List<WrpOutlet>();
            List<WrpOutlet> unselOutlet = new List<WrpOutlet>();
            for(WrpOutlet wrp: lstOutlet){
                if(wrp.isSelected){selOutlet.add(wrp);}
                else{unselOutlet.add(wrp);}
            }
            lstOutlet.clear();
            lstOutlet.addAll(selOutlet);
            lstOutlet.addAll(unselOutlet);                  
        }
        if(objectType != 'Account'){
            if( (!wrkbkUpload || onLoadCheck)){
                for(FS_CIF__c custIn : lstCIF){
                    if(custIn != objNull()){
                        mapOut.put(custIn.FS_Account__c, custIn);
                    }
                }
            }}
        
        if(lstCIF != null){lstCIF.clear();}
        if(!mapout.isempty()){
            lstOutlet = cifNE.getCIFMap(mapout,lstOutlet);
        } 
        RecordCount = lstOutlet.size();
        lstOutletPN = lstOutlet;
        pageNat = new FSPaginationCustomIterable(lstOutletPN);
        pageNat.setPageSize = 20;
        nextPN(); 
    }
    
    /*****************************************************************
Method          : actionCopyCustomerInput()
Description     : Method to Create CIF Header and CIFs for selected outlets
*******************************************************************/
    public PageReference actionCopyCustomerInput(){
        try{    
            if(passCIF)  { 
                setSelectedAccounts();
                currentSelectedOutletIds = cifNE.updateSelection(currentSelectedOutletIds,lstOutlet);    
            }
            currentSelSize = 0;
            currentSelSize = selectedOutletIds.size();
            
            if(currentSelSize != valZero){
                if(objectType == 'Account') {
                    if(currentCIFId==nullStr){
                        cifHead.FS_Status__c = FSConstants.INPROGRESS;
                        cifHead.FS_Version__c = 1;
                        upsert cifHead;
                    }
                    currentCIFId=cifhead.Id;
                    cifHead = cifNE.getCIFHeaderDetails(currentCIFId);
                }
                
                finish();
                sectionName=FSConstants.SECSALESREPINFO;
                currentStage = FSConstants.SALESREPINFO;
                viewStateTrackerList.put(FSConstants.SELECTOUTLETS, FSConstants.COMPLETED);
                onLoadCheck = true;
                
                if(objectType != 'Account' && passCIF) {
                    update cifhead;
                }
                saveData();
                if(objectType != 'Account') {
                    onLoadCheck = false;
                }
                
                if(objectType == 'Account') {
                    if(isUpldErr){
                        isUpldErr = false;
                        ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.ERROR,cifUpldErr );
                        cifUpldErr = empStr;
                        ApexPages.addMessage(errMessage);
                        return null;                
                    }
                    PageReference pageRefHeader  = new PageReference('/apex/FSCustomerInputForm?Id='+cifhead.Id+'&tab='+currentStage);
                    pageRefHeader.setRedirect(true);
                    return pageRefHeader;
                }
                else {
                    return null;
                }
            }   
            else{
                ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'Please select at least one outlet.');
                ApexPages.addMessage(warningMessage);
                updateOutletList();
                return null;
            }
            
        }
        catch(ListException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'actionCopyCustomerInput',valLstOutlet,medium,e,valNA); 
            return null;
        } 
        
    }
    
    /*****************************************************************
Method          : setSelectedAccounts()
Description     : Method to get selected outlets in 'selects 
outlets' section
*******************************************************************/
    private void setSelectedAccounts(){
        for(WrpOutlet item: lstOutlet){
            
            if(item.IsSelected){    
                if(!this.selectedOutletIds.contains(item.outlet.id)){
                    this.selectedOutletIds.add(item.outlet.id);
                    this.unselectedOutletIds.remove(item.outlet.id);
                }
            }else{
                if(this.selectedOutletIds.contains(item.outlet.id)){
                    this.selectedOutletIds.remove(item.outlet.id);
                    this.unselectedOutletIds.add(item.outlet.id);
                }
            }
            
        }
    }
    
    /*****************************************************************
Method          : finish()
Description     : Generates CIF Line data for selected outlets
*******************************************************************/    
    public Pagereference finish(){
        try{
            updateSelectedOutletList();
            List<FS_CIF__c> lstDelCIF = new List<FS_CIF__c>();
            List<FS_CIF__c> lstUpdateCIF = new List<FS_CIF__c>();
            listCif=new List<FS_CIF__c>();
            System.debug('lstOutlet in finish method::' +lstOutlet.size());
            for(WrpOutlet outAcc : lstOutlet){
                FS_CIF__c cifOut=new FS_CIF__c();
                cifOut.FS_Account__c=outAcc.outlet.Id;
                cifOut.CIF_Head__c=currentCIFId;
                cifOut.FS_Headquarters__c = accId;
                cifOut.FS_Payment_Type__c =  outAcc.outlet.FS_Payment_Type__c;
                cifOut.Name = outAcc.outlet.FS_ACN__c;
                if(outAcc.outlet.FS_Payment_Type__c == null)
                {
                    cifOut.FS_Payment_Type__c = 'No';                     
                }
                cifOut.FS_Invoice_Customer__c =  outAcc.outlet.Invoice_Customer__c;
                if(cifOut.FS_Account__r.Invoice_Customer__c == null)
                {
                    cifOut.FS_Invoice_Customer__c = 'No';
                }
                //OCR FR_32
                if(cifOut.FS_Delivery_Method__c == strNull())
                {
                    if(outAcc.outlet.FS_Final_Delivery_Method__c != strNull() && !String.ISBLANK(outAcc.outlet.FS_Final_Delivery_Method__c))
                    {
                        cifOut.FS_Delivery_Method__c = outAcc.outlet.FS_Final_Delivery_Method__c;
                    }
                    else
                    {
                        cifOut.FS_Delivery_Method__c = 'Direct Ship'; 
                    }
                }
                if(cifOut.FS_Cartridge_Order_Method__c == strNull())
                {
                    if(outAcc.outlet.FS_Final_Order_Method__c != strNull() && !String.ISBLANK(outAcc.outlet.FS_Final_Order_Method__c))
                    {
                        cifOut.FS_Cartridge_Order_Method__c = outAcc.outlet.FS_Final_Order_Method__c;
                    }
                    else
                    {
                        cifOut.FS_Cartridge_Order_Method__c = 'CokeSmart'; 
                    }   
                }
                // FET7.0 FNF-835 Start 
                if(outAcc.isRO4WExist == FSConstants.YES){
                    cifOut.Does_Install_Involve_RO4W__c = FSConstants.YES;
                }
                // FET7.0 FNF-835 End
				// FET7.0 FNF-795 Start
                if(outAcc.isReplaceExist == FSConstants.YES){
                    cifOut.FS_Does_Install_Involve_a_Replacement__c = FSConstants.YES;
                }
                // FET7.0 FNF-795 End
                
                //OCR FR_32
                
                if(objectType == 'Account') {
                    cifOut.FS_Invoice_Customer__c = outAcc.outlet.Invoice_Customer__c;
                    if(cifOut.FS_Account__r.Invoice_Customer__c == null)
                    {
                        cifOut.FS_Invoice_Customer__c = 'No';
                    }
                }
                else
                {
                    cifOut.FS_EP_Check__c=false;
                }
                if(mapOut.isEmpty()){
                    mapOut.put(outAcc.outlet.Id,cifOut);
                    listCif.add(cifOut);
                }else if(!mapOut.containsKey(outAcc.outlet.Id)){
                    mapOut.put(outAcc.outlet.Id,cifOut);
                    listCif.add(cifOut);
                }else if(wrkbkUpload && mapOut.containsKey(outAcc.outlet.Id)){
                    cifOut = mapOut.get(outAcc.outlet.Id);
                    cifOut.FS_Account__c=outAcc.outlet.Id;
                    cifOut.CIF_Head__c=currentCIFId;
                    cifOut.FS_Headquarters__c = accId;
                    //OCR FR_32
                    if(cifOut.FS_Delivery_Method__c == strNull())
                    {
                        if(outAcc.outlet.FS_Final_Delivery_Method__c != strNull() && !String.ISBLANK(outAcc.outlet.FS_Final_Delivery_Method__c))
                        {
                            system.debug('FS_Final_Delivery_Method__c'+outAcc.outlet.FS_Final_Delivery_Method__c);
                            cifOut.FS_Delivery_Method__c = outAcc.outlet.FS_Final_Delivery_Method__c;
                        }
                        else
                        {
                            cifOut.FS_Delivery_Method__c = 'Direct Ship'; 
                        }
                    }
                    if(cifOut.FS_Cartridge_Order_Method__c == strNull())
                    {
                        if(outAcc.outlet.FS_Final_Order_Method__c != strNull() && !String.ISBLANK(outAcc.outlet.FS_Final_Order_Method__c))
                        {
                            system.debug('FS_Final_Order_Method__c'+outAcc.outlet.FS_Final_Order_Method__c);
                            cifOut.FS_Cartridge_Order_Method__c = outAcc.outlet.FS_Final_Order_Method__c;
                        }
                        else
                        {
                            cifOut.FS_Cartridge_Order_Method__c = 'CokeSmart'; 
                        }   
                    }
                    //OCR FR_32
                    if(objectType != 'Account')
                    {
                        if(cifOut.FS_DryAccount_curently_no_dispnsd_accnt__c == isYes)
                        {
                            cifOut.FS_Current_Fountain_Equipment_Ownership__c =emptyStr;
                            cifOut.FS_Disposition_of_Current_Equipment__c =emptyStr;
                            cifOut.FS_Disposition_of_Current_BIB_rack__c =emptyStr;
                            cifOut.FS_IndicateDispositionOfCurrentBIBPump__c =emptyStr;
                            cifOut.FS_Ancillary_equipment_to_remain_on_site__c =emptyStr;
                            // cifOut.FS_RemoveAllFTNLegacyServeDispensers__c =emptyStr;
                        }
                        lstUpdateCIF.add(cifOut);
                    }
                    else {
                        listCif.add(cifOut);
                    }
                }
                else if(mapOut.containsKey(outAcc.outlet.Id) && objectType == 'Account'){
                    cifOut = mapOut.get(outAcc.outlet.Id);
                    lstUpdateCIF.add(cifOut);
                }
            }
            if(!listCif.isEmpty() && passCIF){
                upsert listCif;
            }
            if(!lstUpdateCIF.isEmpty() && passCIF){upsert lstUpdateCIF;
                                                  }
            if(!unselectedOutletIds.isEmpty()){
                for(ID delCIF: unselectedOutletIds){
                    FS_CIF__c cifOut=new FS_CIF__c();
                    cifout=mapout.get(delCIF);
                    if(cifout!=null && cifout.id !=null){lstDelCIF.add(cifout);}
                    mapout.remove(delCIF);
                }       
            }
            if(!lstDelCIF.isEmpty()){delete lstDelCIF;}
            System.debug('lstUpdateCIFlstUpdateCIF Finish Method'+ lstUpdateCIF.size());
        }
        catch(DmlException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'finish',valLstOutlet,medium,e,valNA);
        }
        catch(ListException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'finish',valLstOutlet,medium,e,valNA);
        }
        return null;
    }  
    
    /*****************************************************************
Method          : updateSelectedOutletList()
Description     : Method to get only selected outlets CIFs.
*******************************************************************/
    private void updateSelectedOutletList(){
        String isRO4WExist;
		String isReplaceExist;//FET7.0 FNF-795
        if(!wrkbkUpload){
            resetSearchStatus();
            searchOutlet();    
        }
        lstOutlet = new List<WrpOutlet>();
        lstOutletPN = new List<WrpOutlet>();
        String instalNumber;
        //Added on 06/11 as part of Prod defect Fix.
        List<account> FinalAccList = new List<account>();
        ipRecTypeReplacement=FSUtil.getObjectRecordTypeId(FS_Installation__c.sObjectType,Label.IP_Replacement_Rec_Type);
        //FNF-974 defect
        //List to fetch all the records instead of only 100
        String query = cifNE.buildSearchQueryAllRecs(OUTLET_RECORD_TYPE,accId,sortString);
        List<account> accountLstfromHQ = new List<account>();
        List<account> accountLst1 = new List<account>();
                accountLstfromHQ = Database.query(query);
                for(Account tmpAcc: accountLstfromHQ){
                    if(!sltdAccsIds.contains(tmpAcc.id)){
                        accountLst1.add(tmpAcc);
                    }               
                }     
        //End defect FNF-974      
        for(Account acc : accountLst1){
            if(selectedOutletIds.contains(acc.id)){
                //accountLst.add(acc);
                if(acc.Installations1__r != null && !acc.Installations1__r.isEmpty()){
                    for(FS_Installation__c inst: acc.Installations1__r){
                        if(inst.RecordtypeId == ipNewRecType){
                            instalNumber=inst.Name;
                        }
						//FET7.0 FNF-795 Start
                        if(inst.RecordtypeId == ipRecTypeReplacement && inst.FS_Same_incoming_platform__c == FSConstants.NO){
                            isReplaceExist = FSConstants.YES;
                        }
						//FET7.0 FNF-795 End
                    }
                }
                
                 if(acc.Installations5__r != null && !acc.Installations5__r.isEmpty()){
                     system.debug('INSIDE isRO4WExist:: TRUE');
                     isRO4WExist = FSConstants.YES;
                 }
                lstOutlet.add(new WrpOutlet(acc,acc.Installations1__r,instalNumber,!acc.Installations1__r.isEmpty(),currentSelectedOutletIds.contains(acc.Id),isRO4WExist,isReplaceExist));//FET7.0 FNF-795
            	system.debug('IS REPLACEMENT lstOutlet'+lstOutlet);
                isRO4WExist = FSConstants.BLANKVALUE;
				isReplaceExist = FSConstants.BLANKVALUE;//FET7.0 FNF-795
                FinalAccList.add(acc);
            }
        }
        if(mapout!=objNull()){lstOutlet = cifNE.getCIFMap(mapout,lstOutlet);}
        lstOutletPN = lstOutlet;
        pageNat = new FSPaginationCustomIterable(lstOutletPN);
        if(currentStage==FSConstants.SUMMARY){pageNat.setPageSize = 3;}
        else{pageNat.setPageSize = 20;}
        nextPN();
        //Added on 06/11 as part of Prod defect Fix.
        accountlst.clear();
        accountlst.addall(FinalAccList);
    }
    
    /**************************************************************************
Method          : saveData
Description     : Method to perform save on CIF Data
**************************************************************************/
    public PageReference saveData(){
        PageReference pageRefHeader = null; 
        try{
            showCnt=false;
            
            boolean isCustDispAfSA = false;
            boolean disCustDispSA = false;      
            if(displayPopup3){closePopup3();}
            list<FS_CIF__c> listdummy=new list<FS_CIF__c>();
            counterCanCheck=0;
            counterNACheck=0;
            if(pageNat!=null && pageNat.setStartNumber!=0 && pageNat.seti2!=0){
                setStartNumber=pageNat.setStartNumber;
                setI=pageNat.seti2;
            }
            System.debug('lstOutlet 1****' +lstOutlet.size());
            if(!onLoadCheck)
            { 
                updateMap();
            }
            
            lstOutlet = cifNE.getCIFMap(mapout,lstOutlet);
            System.debug('lstOutletlstOutlet *****' + lstOutlet.size());
            viewStateTrackerList=cifNE.chevronStatus(viewStateTrackerList,lstOutlet,cifHead,mapOut,sectionName,onLoadCheck);
            lstOutlet = cifNE.lstOutletUpd;
            List<Id> installListId=new List<Id>();
            
            count = lstOutlet.size();
            if(sectionName==FSConstants.SECSITESURVEYRESULTS && finalStatus){
                for(WrpOutlet outAcc : lstOutlet){
                    if(outAcc.cif.FS_Customer_s_disposition_after_review__c==FSConstants.CANCELLED || outAcc.cif.FS_Customer_s_disposition_after_review__c==FSConstants.NOTAPPROVED){
                        if(outAcc.cif.FS_Customer_s_disposition_after_review__c==FSConstants.CANCELLED){
                            counterCanCheck++;
                        }else if(outAcc.cif.FS_Customer_s_disposition_after_review__c==FSConstants.NOTAPPROVED){
                            counterNACheck++;
                        }
                    }
                    installListId.add(outAcc.cif.FS_RO4W1__c);
                }
                if(counterCanCheck==count){
                    checkstatus=false;
                    showpopup2();                    
                }else if(counterNACheck==count){
                    checkstatus=false;
                    showpopup2();                    
                }else if(counterCanCheck+counterNACheck==count){
                    checkstatus=false;
                    showpopup2();                    
                }else{checkstatus=true;}   
            }
            
            if(checkstatus){
                Map<Id,Account> generlCntrctrName = new Map<Id,Account>([Select Name From Account where FS_Vendor_Type__c = 'General Contractor']);       
                for(WrpOutlet outAcc : lstOutlet){            
                    if(mapOut.containskey(outAcc.Outlet.Id)){
                        FS_CIF__c cif=mapOut.get(outAcc.Outlet.Id);
                        if(sectionName!=FSConstants.SECDISPENSEREQUIPMENT){
                            for(FS_Association_Brandset__c assB:hqAccount.FSHeadquarters__r){
                                if(cif.FS_Brandset1__c==null && cif.FS_Platform1__c == assB.FS_Platform__c){cif.FS_Brandset1__c = assB.FS_Brandset__c;} 
                                else if (cif.FS_Platform1__c == strNull()){cif.FS_Brandset1__c = null;}
                                
                                if(cif.FS_Brandset2__c==null && cif.FS_Platform2__c == assB.FS_Platform__c){cif.FS_Brandset2__c = assB.FS_Brandset__c;}
                                else if (cif.FS_Platform2__c == strNull()){cif.FS_Brandset2__c = null;}
                                
                                if(cif.FS_Brandset3__c==null && cif.FS_Platform3__c == assB.FS_Platform__c){cif.FS_Brandset3__c = assB.FS_Brandset__c;}
                                else if (cif.FS_Platform3__c == strNull()){cif.FS_Brandset3__c = null;}
                                
                            }
                        }
                        if(cif.FS_DryAccount_curently_no_dispnsd_accnt__c == isYes)
                        {
                            system.debug('star star star');
                            cif.FS_Current_Fountain_Equipment_Ownership__c =emptyStr;
                            cif.FS_Disposition_of_Current_Equipment__c =emptyStr;
                            cif.FS_Disposition_of_Current_BIB_rack__c =emptyStr;
                            cif.FS_IndicateDispositionOfCurrentBIBPump__c =emptyStr;
                            cif.FS_Ancillary_equipment_to_remain_on_site__c =emptyStr;
                            //cif.FS_RemoveAllFTNLegacyServeDispensers__c =emptyStr;
                        }
                        if(cif.FS_Any_Crew_Serve_Dispensers__c == isNo)
                        {
                            cif.FS_Portion_Control_Setting__c =emptyStr;
                            cif.FS_Customers_Ice_Fill_Policy__c =emptyStr;
                            cif.FS_Top_Off_Feature__c =emptyStr;
                            cif.FS_Cup_Name_1__c =emptyStr;
                            cif.FS_Cup_Name_2__c =emptyStr;
                            cif.FS_Cup_Name_3__c =emptyStr;
                            cif.FS_Cup_Name_4__c =emptyStr;
                            cif.FS_Cup_Name_5__c =emptyStr;
                            cif.FS_Cup_Name_6__c =emptyStr;
                            cif.FS_Size_1__c =emptyStr;
                            cif.FS_Size_2__c =emptyStr;
                            cif.FS_Size_3__c =emptyStr;
                            cif.FS_Size_4__c =emptyStr;
                            cif.FS_Size_5__c =emptyStr;
                            cif.FS_Size_6__c =emptyStr;
                            cif.FS_Fluid_Ounces_1__c =0;
                            cif.FS_Fluid_Ounces_2__c =0;
                            cif.FS_Fluid_Ounces_3__c =0;
                            cif.FS_Fluid_Ounces_4__c =0;
                            cif.FS_Fluid_Ounces_5__c =0;
                            cif.FS_Fluid_Ounces_6__c =0;
                        }
                        
                        if(cif.FS_What_type_of_Site_Assessment__c ==saNotRequired)
                        {
                            // cif.FS_Perf_Site_Assessment__c = 'No';
                            //cif.FS_JDE_Doc__c = 'N/A';  //commenting out as part of FET-7.0 FNF 722
                            cif.FS_Work_Order_WO__c = 'N/A';
                        } else if(cif.FS_What_type_of_Site_Assessment__c !=saNotRequired 
                                  //&& cif.FS_JDE_Doc__c == 'N/A' //commenting out as part of FET-7.0 FNF 722
                                  && cif.FS_Work_Order_WO__c == 'N/A'){ 
                            //cif.FS_JDE_Doc__c = '';  //commenting out as part of FET-7.0 FNF 722
                            cif.FS_Work_Order_WO__c = '';
                        }
                        
                        if(cif!=objNull())
                        {
                            if(!cif.Is_FET4_0_Migrated_CIF__c){                            
                                Account accContrcat = generlCntrctrName.get(cif.FS_General_Contractor_Name__c);
                                if(accContrcat!=null)
                                {
                                    cif.FS_Contractor_Name__c = accContrcat.Name; 
                                } 
                            }
                        }
                        
                        if(cif.FS_Is_an_approved_Water_Filter_Installed__c == isYesInstalled)
                        {
                            cif.FS_Who_will_install_Water_Filter__c = emptyStr;
                            cif.FS_Water_Filter_Contact_Name__c = null;
                        }
                        if(cif.FS_Contractor_Coordination_to_be_done_by__c == isCustomer)
                        {
                            cif.FS_Contractor_Contact__c = null;
                            
                        }
                        listdummy.add(cif);
                    }
                }
                
                for(WrpOutlet outletCIF : lstOutlet){
                    if(outletCIF.cif.FS_Customer_s_disposition_after_review__c == 'Cancelled' || outletCIF.cif.FS_Customer_s_disposition_after_review__c == 'Not Approved'){
                        isCustDispAfSA = true;
                    }else{
                        isCustDispAfSA = false;
                    }
                    
                    if(isCustDispAfSA && (profileName == fetSysAdmin || profileName == sysAdmin)){
                        disCustDispSA = false;
                    }else if(isCustDispAfSA && (profileName != fetSysAdmin || profileName != sysAdmin)){
                        disCustDispSA = true;   
                    }else{
                        disCustDispSA = false;   
                    }  
                    outletCIF.disCustDispSA = disCustDispSA;  
                }
                
                if(listdummy !=null && !listdummy.isEmpty()){
                    if(!onLoadCheck){
                        update cifHead;  
                        upsert listdummy;
                    }    
                }
                List<FS_CIF__c> cifLst = cifNE.getCIFLst(currentCIFId);
                for(FS_CIF__c custIn : cifLst){
                    if(custIn != objNull()){mapOut.put(custIn.FS_Account__c, custIn);}
                }
                
                cifHead = cifNE.getCIFHeaderDetails(currentCIFId);
                lstOutlet = cifNE.getCIFMap(mapout,lstOutlet); 
                
                if(pageNat!=null && setStartNumber!=0 && setI!=0 && !changeSec){
                    setlstOutletPN = pageNat.goToPage(setStartNumber,setI);
                    setStartNumber=0;
                    setI=0;
                }
                
                if(onLoadCheck){
                    viewStateTrackerList=cifNE.chevronStatus(viewStateTrackerList,lstOutlet,cifHead,mapOut,sectionName,onLoadCheck);
                }
                
                notiSize = cifNE.chevronNotiMessage(viewStateTrackerList,currentStage);
                onLoadCheck=false;changeSec = false;
            }
            pageRefHeader  = new PageReference('/apex/FSCustomerInputForm?Id='+cifhead.Id+'&tab='+currentStage);
            pageRefHeader.setRedirect(true);
        }
        catch(DmlException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'finish',valLstOutlet,medium,e,valNA);
        }
        catch(ListException e){ 
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'saveData',valLstOutlet,medium,e,valNA);
        }
        catch(QueryException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'saveData',valLstOutlet,medium,e,valNA);
        }
        return pageRefHeader;
    }
    /*****************************************************************
Method: goToHQ()
Description: Navigates to HeadQuarter page
*******************************************************************/
    public PageReference goToHQ() {            
        return new PageReference('/' + accId);
    }
    /*****************************************************************
Method: navigateAction()
Description: NavigateAction method is to navigate to respective section on click of Section Name on chevron. 
*******************************************************************/
    public PageReference navigateAction(){
        changeSec = true;
        savingCode();
        initPag();
        if(checkStatus){
            if(currentStage== FSConstants.SELECTOUTLETS){
                sectionName=FSConstants.SECOUTLET;
                resetSearchStatus();
                searchOutlet();
            }
            else if(currentStage== FSConstants.SALESREPINFO){sectionName=FSConstants.SECSALESREPINFO;}
            else if(currentStage== FSConstants.SITESURVEYREQUEST){sectionName=FSConstants.SECSITESURVEYREQUEST;}
            else if(currentStage== FSConstants.SITESURVEYRESULTS){sectionName=FSConstants.SECSITESURVEYRESULTS;}
            else if(currentStage== FSConstants.INSTALLATION){sectionName=FSConstants.SECINSTALLATION;}
            else if(currentStage== FSConstants.DISPENSEREQUIPMENT){sectionName=FSConstants.SECDISPENSEREQUIPMENT;}
            else if(currentStage== FSConstants.ICEMAKERWATERFILTER){sectionName=FSConstants.SECICEMAKERWATERFILTER;}
            else if(currentStage== FSConstants.PRODUCT){sectionName=FSConstants.SECPRODUCT;}
            else if(currentStage== FSConstants.TRAINING){sectionName=FSConstants.SECTRAINING;}
            else if(currentStage== FSConstants.FINANCE){sectionName=FSConstants.SECFINANCE;}
            else if(currentStage== FSConstants.SUMMARY){sectionName=FSConstants.SECSUMMARY;}
        }
        system.debug('currentStage*****' +currentStage);
        system.debug('sectionName*****' +sectionName);
        notiSize = cifNE.chevronNotiMessage(viewStateTrackerList,currentStage);
        return null;
    }
    
    /*****************************************************************
Method: initPag()
Description: This method is to set the Pagination size. 
*******************************************************************/
    private void initPag(){
        if(!mapout.isempty()){lstOutlet = cifNE.getCIFMap(mapout,lstOutlet);}
        lstOutletPN = lstOutlet;
        pageNat = new FSPaginationCustomIterable(lstOutletPN);
        if(currentStage==FSConstants.SUMMARY){pageNat.setPageSize = 3;}
        else{pageNat.setPageSize = 20;}
        nextPN();
    }
    
    /*****************************************************************
Method: cancelCIF()
Description: This method is to cancel the CIF Head 
*******************************************************************/
    public PageReference cancelCIF(){
        PageReference pageRef = ApexPages.currentPage();
        try{
            pageRef = new PageReference('/' + accId);
        }
        catch(DmlException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'cancelCIF',valLstOutlet,medium,e,valNA); 
            pageRef = null;
        } 
        return pageRef;
    }
    /*****************************************************************
Method: summarySec()
Description: This method is to set the pagination sez on  Summary Section. 
*******************************************************************/
    public void summarySec(){
        changeSec = true;
        savingCode();
        if(checkStatus){
            currentStage= FSConstants.SUMMARY;
            sectionName=FSConstants.SECSUMMARY;
        }
        initPag();
        notiSize = cifNE.chevronNotiMessage(viewStateTrackerList,currentStage);
    }
    /*****************************************************************
Method: previousSection()
Description: This method is to navigate to pervious section onclick on pervious Section button.
*******************************************************************/
    public PageReference previousSection(){
        changeSec = true;
        savingCode();
        if(checkStatus){
            if(currentStage== FSConstants.SALESREPINFO){
                sectionName=FSConstants.SECOUTLET;
                currentStage= FSConstants.SELECTOUTLETS;
            }else if(currentStage== FSConstants.SITESURVEYREQUEST){
                sectionName=FSConstants.SECSALESREPINFO;
                currentStage= FSConstants.SALESREPINFO;
            }else if(currentStage== FSConstants.SITESURVEYRESULTS){
                sectionName=FSConstants.SECSITESURVEYREQUEST;
                currentStage= FSConstants.SITESURVEYREQUEST;
            }else if(currentStage== FSConstants.INSTALLATION){
                sectionName=FSConstants.SECSITESURVEYRESULTS;
                currentStage= FSConstants.SITESURVEYRESULTS;
            }else if(currentStage== FSConstants.DISPENSEREQUIPMENT){
                sectionName=FSConstants.SECINSTALLATION;
                currentStage= FSConstants.INSTALLATION;
            }else if(currentStage== FSConstants.ICEMAKERWATERFILTER){
                sectionName=FSConstants.SECDISPENSEREQUIPMENT;
                currentStage= FSConstants.DISPENSEREQUIPMENT;
            }else if(currentStage== FSConstants.PRODUCT){
                sectionName=FSConstants.SECICEMAKERWATERFILTER;
                currentStage= FSConstants.ICEMAKERWATERFILTER;
            }else if(currentStage== FSConstants.TRAINING){
                sectionName=FSConstants.SECPRODUCT;
                currentStage= FSConstants.PRODUCT;
            }else if(currentStage== FSConstants.FINANCE){
                sectionName=FSConstants.SECTRAINING;
                currentStage= FSConstants.TRAINING;
            }else if(currentStage== FSConstants.SUMMARY){
                sectionName=FSConstants.SECFINANCE;
                currentStage= FSConstants.FINANCE;
                initPag();
            }
        }
        notiSize = cifNE.chevronNotiMessage(viewStateTrackerList,currentStage);
        if(currentStage== FSConstants.SELECTOUTLETS){
            searchOutlet();
        }        
        return null;
    }
    
    /*****************************************************************
Method: nextSection()
Description: This method is to navigate to next section onclick on Next Section button.
*******************************************************************/
    public PageReference nextSection(){
        changeSec = true;
        savingCode();
        if(checkStatus){ 
            if(currentStage== FSConstants.SALESREPINFO){
                sectionName=FSConstants.SECSITESURVEYREQUEST;
                currentStage= FSConstants.SITESURVEYREQUEST;
            }else if(currentStage== FSConstants.SITESURVEYREQUEST){
                sectionName=FSConstants.SECSITESURVEYRESULTS;
                currentStage= FSConstants.SITESURVEYRESULTS;
            }else if(currentStage== FSConstants.SITESURVEYRESULTS){
                sectionName=FSConstants.SECINSTALLATION;
                currentStage= FSConstants.INSTALLATION;
            }else if(currentStage== FSConstants.INSTALLATION){
                sectionName=FSConstants.SECDISPENSEREQUIPMENT;
                currentStage= FSConstants.DISPENSEREQUIPMENT;
            }else if(currentStage== FSConstants.DISPENSEREQUIPMENT){
                sectionName=FSConstants.SECICEMAKERWATERFILTER;
                currentStage= FSConstants.ICEMAKERWATERFILTER;
            }else if(currentStage== FSConstants.ICEMAKERWATERFILTER){
                sectionName=FSConstants.SECPRODUCT;
                currentStage= FSConstants.PRODUCT;
            }else if(currentStage== FSConstants.PRODUCT){
                sectionName=FSConstants.SECTRAINING;
                currentStage= FSConstants.TRAINING;
            }else if(currentStage== FSConstants.TRAINING){
                sectionName=FSConstants.SECFINANCE;
                currentStage= FSConstants.FINANCE;
            }else if(currentStage== FSConstants.FINANCE){
                sectionName=FSConstants.SECSUMMARY;
                currentStage= FSConstants.SUMMARY;
            }
        }
        initPag();
        notiSize = cifNE.chevronNotiMessage(viewStateTrackerList,currentStage);                                                                    
        return null;
    }
    
    /*****************************************************************
Method: saveDataPop()
Description: Check for chevron status and calls savedata method
*******************************************************************/
    public void saveDataPop(){
        updateMap();
        lstOutlet = cifNE.getCIFMap(mapout,lstOutlet);
        viewStateTrackerList=cifNE.chevronStatus(viewStateTrackerList,lstOutlet,cifHead,mapOut,sectionName,onLoadCheck);        
        if(sectionName!=FSConstants.SECSUMMARY && cifNE.chevronNotiMessage(viewStateTrackerList,cifNE.previousStage)){showPopup3();}
        else{saveData();}        
    }
    /*****************************************************************
Method: saveClose()
Description: 
*******************************************************************/
    public PageReference saveClose(){
        PageReference pageRef = ApexPages.currentPage();
        try{
            saveData();
            pageRef = new PageReference('/' + cifHead.FS_HQ__c);
        }
        catch(DmlException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'cancelCIF',valLstOutlet,medium,e,valNA); 
            pageRef = null;
        } 
        return pageRef;      
    }
    /*****************************************************************
Method: getselectedaccnamefields()
Description: Get the account when vendor type is General Contractor
*******************************************************************/
    public List<Selectoption> getselectedaccnamefields(){
        List<Selectoption> lstVendorAccount = new List<selectoption>();
        lstVendorAccount.add(new selectOption(emptyStr, '- None -'));
        try{
            for(Account acc : [Select Name From Account where FS_Vendor_Type__c = 'General Contractor' ORDER BY Name]){
            lstVendorAccount.add(new selectoption(acc.id,acc.name));
            }
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog(valFET, fsCustomerInput, 'getselectedaccnamefields', 'Account', Medium, e, valNA);
        } 
        return lstVendorAccount; 
    }
    
    /*****************************************************************
Method: savingCode()
Description: Check the chevron status on click of save button
*******************************************************************/
    public void savingCode(){
        lstOutlet = cifNE.getCIFMap(mapout,lstOutlet);
        viewStateTrackerList=cifNE.chevronStatus(viewStateTrackerList,lstOutlet,cifHead,mapOut,sectionName,onLoadCheck);
        lstOutlet = cifNE.lstOutletUpd;
    }
    
    /*****************************************************************
Method: getHQDetails()
Description: Returns the HeadQuarter details 
*******************************************************************/
    public PageReference getHQDetails(){
        PageReference pageRef = ApexPages.currentPage();
        try{
            pageRef = new PageReference('/' + cifHead.Id);
        }
        catch(DmlException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'cancelCIF',valLstOutlet,medium,e,valNA); 
            pageRef = null;
        } 
        return pageRef;      
    }
    
    /*****************************************************************
Method: createEP()
Description: This method is to create EP when all the CIF's Customer Disposition is Approved.
*******************************************************************/
    public PageReference createEP(){
        List<FS_CIF__c> listCIF = new List<FS_CIF__c>();
        try{
            if(sectionName ==FSConstants.SECSUMMARY){
                lstOutletEP = new List<WrpOutlet>();
                for(WrpOutlet lst:lstOutlet){
                    if(lst.cif.FS_Customer_s_disposition_after_review__c==FSConstants.APPROVED){lst.IsSelected=true;}
                    else{lst.IsSelected=false;}
                    lstOutletEP.add(lst);
                    listCIF.add(lst.cif);  
                }
                if(!listCIF.isEmpty()){
                    update listCIF;
                    update cifHead;
                }
                pnEP = new FSPaginationCustomIterable(lstOutletEP);
                pnEP.setPageSize = 20;                 
                currentStage= FSConstants.SECCREATEEP;          
                sectionName =FSConstants.SECCREATEEP;
                nextPN();     
            }
        }
        catch(ListException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'createEP',valLstOutlet,medium,e,valNA);
        }   
        catch(DMLException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'createEP',valLstOutlet,medium,e,valNA);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
        return null;
    }
    /*****************************************************************
Method: updateReparentEP()
Description: This method is to Cascade Contact CIF data from Reparented CIF to EP.
*******************************************************************/ 
    public PageReference updateReparentEP(){
        PageReference page=null;
        SavePoint savePosition;
        List<FS_CIF__c> listCIF = new List<FS_CIF__c>();
        try{
            if(sectionName ==FSConstants.SECSUMMARY){
                lstOutletEP = new List<WrpOutlet>();
                for(WrpOutlet lst:lstOutlet){
                    //if(lst.cif.FS_Customer_s_disposition_after_review__c==FSConstants.APPROVED){lst.IsSelected=true;}
                    //else{lst.IsSelected=false;}
                    lst.IsSelected=true;
                    lstOutletEP.add(lst);
                    listCIF.add(lst.cif);  
                }
                if(!listCIF.isEmpty()){
                    update listCIF;
                }
            }
            allmandList=new List<FS_CIF__c>();
            lessMandList=new List<FS_CIF__c>();            
            if(cifHead.FS_Sales_Rep_Name__c != idNull() && cifHead.FS_FPS__c != idNull() && cifHead.FSCOM__c != idNull()){
                for(WrpOutlet outAcc : lstOutletEP){                       
                    if((outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c=='Customer' || outAcc.cif.FS_Contractor_Contact__c != null) 
                       && outAcc.cif.FS_General_Contractor_Name__c != null &&  outAcc.cif.FS_Outlet_Contact__c != null &&
                       outAcc.cif.FS_On_Boarding_Contact__c != null &&
                       outAcc.cif.FS_Order_Administrator__c != null && outAcc.cif.FS_Order_Standard_User__c != null &&
                       outAcc.cif.FS_Select_Site_assessment_contact__c != null &&
                       (outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c != 'No - approved make/model to be installed' || (outAcc.cif.FS_Water_Filter_Contact_Name__c != null && outAcc.cif.Water_Filter_Installer_Name__c != null  )) &&
                       outAcc.cif.FS_Customer_s_disposition_after_review__c == FSConstants.APPROVED){
                           allMandList.add(outAcc.cif);
                       }
                    else{
                        lessMandList.add(outAcc.cif);
                    }                    
                }
                if(lessMandList!=null && !lessMandList.isEmpty()){
                    ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'Warning: There are some incomplete mandatory fields for one or more outlets. Please ensure all mandatory values have been provided before proceeding to the next step');
                    ApexPages.addMessage(warningMessage);
                }
                else{
                    savePosition = Database.setSavePoint();
                    FSUpdateExecutionPlan.fetchRecordDetails(cifHead.Id);
                    System.debug('Update Migrated CIF');
                    page=new PageReference('/' + cifHead.FS_EP__c);
                }                
            }else  {
                ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'One or more mandatory fields within the Team Member Info section has missing information.');
                ApexPages.addMessage(warningMessage);                    
            }
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            Database.rollback(savePosition);            
        }
        return page;
    }
    /*****************************************************************
Method: updateMigratedEP()
Description: This method is to Cascade The Migrated CIF data from CIF to EP.
*******************************************************************/ 
    public PageReference updateMigratedEP(){
        PageReference page=null;
        SavePoint savePosition;
        List<FS_CIF__c> listCIF = new List<FS_CIF__c>();
        try{
            if(sectionName ==FSConstants.SECSUMMARY){
                lstOutletEP = new List<WrpOutlet>();
                for(WrpOutlet lst:lstOutlet){
                    //if(lst.cif.FS_Customer_s_disposition_after_review__c==FSConstants.APPROVED){lst.IsSelected=true;}
                    //else{lst.IsSelected=false;}
                    lst.IsSelected=true;
                    lstOutletEP.add(lst);
                    listCIF.add(lst.cif);  
                }
                if(!listCIF.isEmpty()){
                    update listCIF;
                }
            }
            allmandList=new List<FS_CIF__c>();
            lessMandList=new List<FS_CIF__c>();            
            if(cifHead.FS_Sales_Rep_Name__c != idNull() && cifHead.FS_FPS__c != idNull() && cifHead.FSCOM__c != idNull()){
                for(WrpOutlet outAcc : lstOutletEP){ 
                    //FET 7.1 Added Site Assessor Mandate Logic based on What type of Site Assessment
                    if(outAcc.cif.FS_Any_Crew_Serve_Dispensers__c != null  &&  outAcc.cif.FS_Brandset1__c!= null && outAcc.cif.FS_Water1__c!=null &&
                       outAcc.cif.FS_DryAccount_curently_no_dispnsd_accnt__c != null && (outAcc.cif.FS_DryAccount_curently_no_dispnsd_accnt__c==isYes || outAcc.cif.FS_RemoveAllFTNLegacyServeDispensers__c != null ) &&
                       outAcc.cif.FS_Requested_Install_Period__c!= null && outAcc.cif.FS_Requested_Install_Date__c != null && outAcc.cif.FS_Day_AM_or_Night_PM_Installation__c != null && 
                       outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c != null && (outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c=='Customer' || outAcc.cif.FS_Contractor_Contact__c != null) &&
                       outAcc.cif.FS_General_Contractor_Name__c != null &&  outAcc.cif.FS_Outlet_Contact__c != null && outAcc.cif.FS_OB_Trainer__c != null && outAcc.cif.FS_On_Boarding_Days_after_Install__c != null && 
                       outAcc.cif.FS_Select_On_Boarding_Start_Time__c != null && outAcc.cif.FS_On_boarding_time_requested__c != null && outAcc.cif.FS_On_Boarding_Contact__c != null && outAcc.cif.FS_Name_of_Sweetener_Distributor__c != null && 
                       outAcc.cif.FS_Distributor_City__c != null && outAcc.cif.FS_Distributor_State__c != null && outAcc.cif.FS_Distributor_Name_City_ST__c!= null &&
                       outAcc.cif.FS_Order_Administrator__c != null && outAcc.cif.FS_Order_Standard_User__c != null && outAcc.cif.FS_Cartridge_Order_Method__c !=null && outAcc.cif.FS_Delivery_Method__c !=null && 
                       outAcc.cif.FS_What_type_of_outlet_install__c != null && outAcc.cif.FS_Select_Site_assessment_contact__c != null && outAcc.cif.FS_Platform1__c != null && outAcc.cif.FS_Platform1_Qty__c != null && 
                       outAcc.cif.FS_Total_VPO__c != null && outAcc.cif.FS_Kitchen_Ice_Fill_Requirements__c != null && outAcc.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c !=null &&
                       (outAcc.cif.FS_What_type_of_Site_Assessment__c != null && (outAcc.cif.FS_What_type_of_Site_Assessment__c==FSConstants.SANOTREQUIRED || outAcc.cif.FS_Site_Assessor__c!=null) ) &&
                       outAcc.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c !=null && outAcc.cif.FS_Who_will_coordinate_Ice_maker_Install__c != null && outAcc.cif.FS_WhoWillPerformRequiredIceMakerWork__c != null &&                        
                       outAcc.cif.FS_Work_Order_WO__c != null && outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c !=null && ( outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c != 'No - approved make/model to be installed' || (outAcc.cif.FS_Water_Filter_Contact_Name__c != null && outAcc.cif.FS_Who_will_install_Water_Filter__c != null && outAcc.cif.Water_Filter_Installer_Name__c != null )) &&
                       outAcc.cif.FS_Water_Filter_MFG__c != null && ((outAcc.cif.FS_Perf_Site_Assessment__c == 'Yes' && outAcc.cif.FS_Davaco_Order_Entered__c ) || outAcc.cif.FS_Perf_Site_Assessment__c == 'No') && outAcc.cif.FS_Water_Filter_Model_no__c != null && outAcc.cif.FS_Customer_s_disposition_after_review__c == FSConstants.APPROVED  &&
                       outAcc.cif.FS_Cartridge_Payment_Method__c != null && outAcc.cif.FS_Program_Fee_Payment_Method__c != null && 
                       outAcc.cif.Does_Install_Involve_RO4W__c!=null && ((outAcc.cif.Does_Install_Involve_RO4W__c== 'Yes' && outAcc.cif.FS_RO4W1__c!=null) || outAcc.cif.Does_Install_Involve_RO4W__c== 'No') &&
                       outAcc.cif.FS_Does_Install_Involve_a_Replacement__c!=null && ((outAcc.cif.FS_Does_Install_Involve_a_Replacement__c== 'Yes' && outAcc.cif.FS_Replacement_1__c!=null) || outAcc.cif.FS_Does_Install_Involve_a_Replacement__c== 'No')){ //Modified as part of FET-7.0 FNF 795       //Modified as part of FET-7.0 FNF 722(removed FS_JDE_Doc__c as mandatory)                         
                           allMandList.add(outAcc.cif);
                       }
                    else{
                        lessMandList.add(outAcc.cif);
                    }                    
                }
                if(lessMandList!=null && !lessMandList.isEmpty()){
                    ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'Warning: There are some incomplete mandatory fields for one or more outlets. Please ensure all mandatory values have been provided before proceeding to the next step');
                    ApexPages.addMessage(warningMessage);
                }
                else{
                    savePosition = Database.setSavePoint();
                    FSUpdateExecutionPlan.fetchRecordDetails(cifHead.Id);
                    page=new PageReference('/' + cifHead.FS_EP__c);
                }                
            }else  {
                ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'One or more mandatory fields within the Team Member Info section has missing information.');
                ApexPages.addMessage(warningMessage);                    
            }
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            Database.rollback(savePosition);            
        }
        return page;
    }
    
    /*****************************************************************
Method: getSummaryReport()
Description: Generates the CIF summary report for respective CIFs
*******************************************************************/
    public PageReference getSummaryReport()
    {
        return cifNE.getSummaryReport(currentCIFId);
    }
    
    /*****************************************************************
Method: cancelHeader()
Description: cancelHeader method is to set the CIF Status to cancel when all the CIF Line items are canceled
*******************************************************************/
    public PageReference cancelHeader(){
        if(counterCanCheck== lstOutlet.size()){
            cifHead.FS_Status__c=FSConstants.CLCANCELLED;
        }else if(counterNACheck== lstOutlet.size()){
            cifHead.FS_Status__c=FSConstants.CLNOTAPPROVED;
        }else if(counterCanCheck+counterNACheck== lstOutlet.size()){
            cifHead.FS_Status__c=FSConstants.CLOSEDCANNOTAPP;
        }
        try{
            update cifHead;
        }
        catch(Exception e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'cancelHeader','CIF Header',medium,e,valNA);
        }
        finalStatus=false;
        checkStatus=true;
        saveData();      
        return new PageReference('/' + accId); 
    }
    
    /*****************************************************************
Method: mandChecktrue()
Description: Mandatory field warning message for each chevron section
*******************************************************************/
    public void mandChecktrue(){
        if(displayPopup1){closepopup1();} 
        if((lessMandList!=null && !lessMandList.isEmpty()) || cifHead.FS_Sales_Rep_Name__c == null){
            ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'Warning: There are some incomplete mandatory fields for one or more outlets. Please ensure all mandatory values have been provided before proceeding to the next step');
            ApexPages.addMessage(warningMessage);
        }
        else{
            showPopup5();
        }        
    }
    /*****************************************************************
Method: mandChecktrue1()
Description: Mandatory fields check to create EP
*******************************************************************/
    public PageReference mandChecktrue1(){
        PageReference pageRef = ApexPages.currentPage();
        try{            
            closepopup5();
            if(!allMandList.isEmpty()){
                for(FS_CIF__c cifs:allMandList){
                    cifs.FS_EP_Check__c=true;
                }
                update allMandList;             
            }
            if(!approveList.isEmpty()){
                for(FS_CIF__c cifs:approveList){
                    cifs.FS_EP_Check__c=false;
                }
                update approveList; 
            }
            String accountId=hqAccount.Id;
            String cifHeadId=cifHead.Id;
            PageReference page=new PageReference('/apex/FSCreateExecutionPlan?Id='+accountId+'&currentCIFId='+cifHeadId);
            page.setRedirect(true);
            pageRef = page; 
        }
        catch(DmlException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'mandChecktrue','allMandList',medium,e,valNA);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
            pageRef = null;
        }
        return pageRef;        
    }
    
    /*****************************************************************
Method: mandCheck()
Description: This method is to check whether all the mandatory fields on CIF is filled.
*******************************************************************/
    public PageReference mandCheck(){  
        PageReference pageRef = ApexPages.currentPage();
        try{
            allmandList=new List<FS_CIF__c>();
            lessMandList=new List<FS_CIF__c>();
            approveList=new List<FS_CIF__c>();
            
            setSelectedAccountsEP(); 
            currentSelectedOutletIdsEP = cifNE.updateSelection(currentSelectedOutletIdsEP,lstOutletEP);
            if(currentSelectedOutletIdsEP!=null && !currentSelectedOutletIdsEP.isEmpty()){
                if(cifHead.FS_Sales_Rep_Name__c != idNull() && cifHead.FS_FPS__c != idNull() && cifHead.FSCOM__c != idNull()){
                    for(WrpOutlet outAcc : lstOutletEP){
                        if(currentSelectedOutletIdsEP.contains(outAcc.Outlet.Id) && outAcc.cif.FS_Customer_s_disposition_after_review__c==FSConstants.APPROVED){
                            //FET 7.1 Added Site Assessor Mandate Logic based on What type of Site Assessment
                            if(outAcc.cif.FS_Any_Crew_Serve_Dispensers__c != null  && outAcc.cif.FS_Brandset1__c!= null && outAcc.cif.FS_Water1__c!=null &&
                               outAcc.cif.FS_DryAccount_curently_no_dispnsd_accnt__c != null && (outAcc.cif.FS_DryAccount_curently_no_dispnsd_accnt__c==isYes || outAcc.cif.FS_RemoveAllFTNLegacyServeDispensers__c != null ) &&
                               outAcc.cif.FS_Requested_Install_Period__c!= null && outAcc.cif.FS_Requested_Install_Date__c != null && outAcc.cif.FS_Day_AM_or_Night_PM_Installation__c != null && 
                               outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c != null && (outAcc.cif.FS_Contractor_Coordination_to_be_done_by__c=='Customer' || outAcc.cif.FS_Contractor_Contact__c != null) &&
                               outAcc.cif.FS_General_Contractor_Name__c != null &&  outAcc.cif.FS_Outlet_Contact__c != null && outAcc.cif.FS_OB_Trainer__c != null && outAcc.cif.FS_On_Boarding_Days_after_Install__c != null && 
                               outAcc.cif.FS_Select_On_Boarding_Start_Time__c != null && outAcc.cif.FS_On_boarding_time_requested__c != null && outAcc.cif.FS_On_Boarding_Contact__c != null && outAcc.cif.FS_Name_of_Sweetener_Distributor__c != null && 
                               outAcc.cif.FS_Distributor_City__c != null && outAcc.cif.FS_Distributor_State__c != null && outAcc.cif.FS_Distributor_Name_City_ST__c!= null &&
                               outAcc.cif.FS_Order_Administrator__c != null && outAcc.cif.FS_Order_Standard_User__c != null && outAcc.cif.FS_Cartridge_Order_Method__c !=null && outAcc.cif.FS_Delivery_Method__c !=null && 
                               outAcc.cif.FS_What_type_of_outlet_install__c != null && outAcc.cif.FS_Select_Site_assessment_contact__c != null && outAcc.cif.FS_Platform1__c != null && outAcc.cif.FS_Platform1_Qty__c != null && 
                               outAcc.cif.FS_Total_VPO__c != null  & outAcc.cif.FS_Kitchen_Ice_Fill_Requirements__c != null && outAcc.cif.FS_Self_Serve_Top_Mount_Ice_maker_MFG__c !=null &&
                               (outAcc.cif.FS_What_type_of_Site_Assessment__c != null && (outAcc.cif.FS_What_type_of_Site_Assessment__c==FSConstants.SANOTREQUIRED || outAcc.cif.FS_Site_Assessor__c!=null) ) &&
                               outAcc.cif.FS_Self_Srv_Top_Mnt_Ice_maker_Mdl_no__c !=null && outAcc.cif.FS_Who_will_coordinate_Ice_maker_Install__c != null && outAcc.cif.FS_WhoWillPerformRequiredIceMakerWork__c != null && 
                               outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c != null && ( outAcc.cif.FS_Is_an_approved_Water_Filter_Installed__c != 'No - approved make/model to be installed' || (outAcc.cif.FS_Water_Filter_Contact_Name__c != null && outAcc.cif.FS_Who_will_install_Water_Filter__c != null && outAcc.cif.Water_Filter_Installer_Name__c != null )) &&
                               outAcc.cif.FS_Water_Filter_MFG__c != null && outAcc.cif.FS_Water_Filter_Model_no__c != null && outAcc.cif.FS_Customer_s_disposition_after_review__c == FSConstants.APPROVED &&
                               outAcc.cif.FS_Cartridge_Payment_Method__c != null && outAcc.cif.FS_Program_Fee_Payment_Method__c != null && outAcc.cif.FS_Work_Order_WO__c != null && ((outAcc.cif.FS_Perf_Site_Assessment__c == 'Yes' && outAcc.cif.FS_Davaco_Order_Entered__c ) || outAcc.cif.FS_Perf_Site_Assessment__c == 'No') &&
                               outAcc.cif.Does_Install_Involve_RO4W__c!=null && ((outAcc.cif.Does_Install_Involve_RO4W__c== 'Yes' && outAcc.cif.FS_RO4W1__c!=null) || outAcc.cif.Does_Install_Involve_RO4W__c== 'No') && 
                               outAcc.cif.FS_Does_Install_Involve_a_Replacement__c!=null && ((outAcc.cif.FS_Does_Install_Involve_a_Replacement__c== 'Yes' && outAcc.cif.FS_Replacement_1__c!=null) || outAcc.cif.FS_Does_Install_Involve_a_Replacement__c== 'No')){ //Modified as part of FET-7.0 FNF 795        //Modified as part of FET-7.0 FNF 722(removed FS_JDE_Doc__c as mandatory)                              
                                   allMandList.add(outAcc.cif);
                               }else{lessMandList.add(outAcc.cif);}
                        }else{
                            if(outAcc.cif.FS_Customer_s_disposition_after_review__c==FSConstants.APPROVED){approveList.add(outAcc.cif);}                            
                        }                
                    }                
                    if(approveList!=null && !approveList.isEmpty()){
                        showPopup1();
                        pageRef = null;
                    }else{mandChecktrue();
                          pageRef = null;
                         }
                }else  {
                    ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'One or more mandatory fields within the Team Member Info section has missing information.');
                    ApexPages.addMessage(warningMessage);
                    pageRef = null;
                }
            }
            else{
                ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'Please select at least one outlet.');
                ApexPages.addMessage(warningMessage);
                pageRef = null;
            }
        }catch(ListException e){
            ApexErrorLogger.addApexErrorLog(valFET,fsCustomerInput,'mandCheck','lstOutletEP',medium,e,valNA);
        }
        return pageRef;
    }
    
    /*****************************************************************
Method: setSelectedAccountsEP()
Description: Build the selected Ids list to create EP
*******************************************************************/
    private void setSelectedAccountsEP(){
        for(WrpOutlet item: lstOutletEP){
            if(item.IsSelected !=null && item.IsSelected){           
                if(!this.selectedOutletIdsEP.contains(item.outlet.id)){this.selectedOutletIdsEP.add(item.outlet.id);}
            }else{
                if(this.selectedOutletIdsEP.contains(item.outlet.id)){this.selectedOutletIdsEP.remove(item.outlet.id);}
            }
        }  
    }
    
    /*****************************************************************
Method: onLoadCreateCIF()
Description: Check Chevron status for each section when CIF is in create mode
*******************************************************************/
    public void onLoadCreateCIF()
    {
        isClosed = false;
        enblSectn = false;
        if(hqAccount!=objNull()){
            accId = hqAccount.id;
            spancol = 4;count=0;changeSec = false;showCnt = true;
            setStartNumber=0;setI=0;
            Datetime hqDT = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
            hqDate = hqDT.format('YYMMdd'); // formats the date
            hqTime = hqDT.format('HHmm');
            cifHead.FS_HQ__c = hqAccount.id;
            cifHead.Name = hqAccount.Name+'-'+UserInfo.getLastName()+'-'+hqDate+hqTime+'_V.1';
            
            sectionName=FSConstants.SECOUTLET;
            currentStage = FSConstants.SELECTOUTLETS;
        }
    }
    
    /*****************************************************************
Method: onLoadCreateCIF()
Description: Check Chevron status for each section when CIF is in edit mode
*******************************************************************/
    Public void onLoadEditCIF()
    {
        accountLst = new List<Account>();                
        isClosed = false;
        disableField = false;
        accId = cifHead.FS_HQ__c;spancol = 4;count=0;
        setStartNumber=0;setI=0;
        hqAccount = cifNE.getHQDetails(accId);
        cifHead.FS_HQ__c = hqAccount.id;      
        currentURLParm = System.currentPagereference().getParameters().get('tab');        
        if(currentURLParm== FSConstants.SALESREPINFO){  
            sectionName=FSConstants.SECSALESREPINFO;
            currentStage= FSConstants.SALESREPINFO;                      
        }else if(currentURLParm== FSConstants.SITESURVEYREQUEST){
            sectionName=FSConstants.SECSITESURVEYREQUEST;
            currentStage= FSConstants.SITESURVEYREQUEST;                     
        }else if(currentURLParm== FSConstants.SITESURVEYRESULTS){
            sectionName=FSConstants.SECSITESURVEYRESULTS;
            currentStage= FSConstants.SITESURVEYRESULTS;                       
        }else if(currentURLParm== FSConstants.INSTALLATION){
            sectionName=FSConstants.SECINSTALLATION;
            currentStage= FSConstants.INSTALLATION;                        
        }else if(currentURLParm== FSConstants.DISPENSEREQUIPMENT){
            sectionName=FSConstants.SECDISPENSEREQUIPMENT;
            currentStage= FSConstants.DISPENSEREQUIPMENT;            
        }else if(currentURLParm== FSConstants.ICEMAKERWATERFILTER){
            sectionName=FSConstants.SECICEMAKERWATERFILTER;
            currentStage= FSConstants.ICEMAKERWATERFILTER;  
        }else if(currentURLParm== FSConstants.PRODUCT){
            sectionName=FSConstants.SECPRODUCT;
            currentStage= FSConstants.PRODUCT;            
        }else if(currentURLParm== FSConstants.TRAINING){
            sectionName=FSConstants.SECTRAINING;
            currentStage= FSConstants.TRAINING;            
        }else if(currentURLParm== FSConstants.FINANCE){
            sectionName=FSConstants.SECFINANCE;
            currentStage= FSConstants.FINANCE;            
        }else if(currentURLParm== FSConstants.SUMMARY){
            sectionName=FSConstants.SECSUMMARY;
            currentStage= FSConstants.SUMMARY;           
        }else{
            sectionName=FSConstants.SECOUTLET;
            currentStage = FSConstants.SELECTOUTLETS;            
        } 
        
    }
    
    /*****************************************************************
Method: setStageEditCIF()
Description: Set Chevron status and calls methods to save the data
*******************************************************************/
    Public void setStageEditCIF()
    {
        if(currentURLParm != FSConstants.SELECTOUTLETS && currentURLParm != emptyStr && currentURLParm != null){                      
            setSelectedAccounts();
            currentSelectedOutletIds = cifNE.updateSelection(currentSelectedOutletIds,lstOutlet);
            finish(); 
            onLoadCheck = true;
            saveData();
            onLoadCheck = false;
        }else{       
            onLoadCheck = true;
            viewStateTrackerList=cifNE.chevronStatus(viewStateTrackerList,lstOutlet,cifHead,mapOut,sectionName,onLoadCheck);
            notiSize = cifNE.chevronNotiMessage(viewStateTrackerList,currentStage);
        }
        
        cifHeadStatus=true;
        
        if(prof.name =='FS Sales_P'){
            //updateSelectedOutletList();                   
            //cifHeadStatus = false;
            //isClosed = true;
            disableField = true;
        }
        else if(prof.name !=FSConstants.FETSYSADM){
            if(cifHead.FS_Status__c == FSConstants.CLCANCELLED || cifHead.FS_Status__c == FSConstants.CLOSEDCONVTOEP || cifHead.FS_Status__c == FSConstants.CLOSEDCANNOTAPP || cifHead.FS_Status__c == FSConstants.CLNOTAPPROVED){
                updateSelectedOutletList();                   
                cifHeadStatus = false;
                currentStage= FSConstants.SUMMARY;
                sectionName=FSConstants.SECSUMMARY;
                if(currentStage == FSConstants.SUMMARY){
                    finish(); 
                    onLoadCheck = true;
                    saveData();
                    onLoadCheck = false;
                } 
            }
        }
        
        else{
            if(cifHead.FS_Status__c == FSConstants.CLOSEDCONVTOEP){
                updateSelectedOutletList();                              
                cifHeadStatus = false;
                currentStage= FSConstants.SUMMARY;
                sectionName=FSConstants.SECSUMMARY;
                if(currentStage == FSConstants.SUMMARY){
                    finish(); 
                    onLoadCheck = true;
                    saveData();
                    onLoadCheck = false;
                }                
            }
        }
    }    
}