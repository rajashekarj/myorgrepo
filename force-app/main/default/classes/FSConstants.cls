public with sharing class FSConstants {
    
    public static final Map<String, Schema.SObjectType> GLOBAL_MAP = Schema.getGlobalDescribe();
    //FET 7.1
    public static final String SANOTREQUIRED = 'SA Not Required - OSM approval required for local market';
    public static final String RECTYPE_71k='7100';
    //FET 7.1
    public static final String FLAVORHEADOBJECTNAME='FS_Flavor_Change_Head__c';
    public static final String INSTALLATIONOBJECTNAME='FS_Installation__c';
    public static final String ODOBJECTNAME='FS_Outlet_Dispenser__c';
    public static final String CIFLINEOBJECTNAME='FS_CIF__c';
    public static final String EXECUTIONPLANOBJECTNAME='FS_Execution_Plan__c';
    public static final String ERRORMESSAGEIPSELECTION='please select atleast one installation';
    
    public static boolean odtriggercheck=false;
    public static boolean SET_CASEASSIGNMENTRULES=true;
    public static final String SERIES7k='7000 Series'; 
    public static final String RECTYPE_6k='6000';//M-series 
    public static final String RECTYPE_65k='6050';//M-series
    public static final String RECTYPE_7k='7000'; 
    public static final String RECTYPE_8k='8000'; 
    public static final String RECTYPE_9k='9000'; 
    public static final String RECTYPE_91k='9100'; 
    public static final String ACCESS_IS_CREATABLE = 'isCreatable';
    public static final String ACCESS_IS_UPDATEABLE = 'isUpdateable';
    public static final String ACCESS_IS_DELETABLE = 'isDeletable';
    public static final String ACCESS_IS_UNDELETABLE = 'isUndeletable';
    public static final String systemAdmin = 'System Administrator';
    public static final String RECORD_TYPE_NAME_FLAVOR_CHAIN='FS Flavor Change Chain HQ';
    public static final String RECORD_TYPE_NAME_FLAVOR_OUTLET='FS Flavor Change Outlet';
    public static final String RECORD_TYPE_NAME_OUTLET = 'FS Outlet';
    public static final String RECORD_TYPE_NAME_OUTLET1 = Label.INTERNATIONAL_OUTLET_RECORD_TYPE;
    public static final String RECORD_TYPE_NAME_OUTLET_INT = Label.INTERNATIONAL_OUTLET_RECORD_TYPE;
    public static final String RECORD_TYPE_NAME_CHAIN = 'FS Chain';
    public static final String RECORD_TYPE_NAME_HQ = 'FS Headquarters';
    public static final String RECORD_TYPE_NAME_VENDOR = 'FS Vendor';
    public static final String RECORD_TYPE_SERVICE_PROVIDER = 'Service Provider';
    //OCR1requirement
    public static final String RECORD_TYPE_NAME_Distributor= 'FS Distributor';
    public static final String RECORD_TYPE_Name_Bottler = 'FS Bottler';
    public static final String USER_POFILE_SALES = 'FS Sales';
    public static final String USER_POFILE_SALES_P = 'FS Sales_P';//
    public static final String USER_POFILE_COM = 'FS COM_P';
    public static final String USER_POFILE_PM = 'FS PM_P';
    public static final String USER_POFILE_ADMINPM = 'FS Admin PM_P';
    public static final String USER_PROFILE_PC = 'FS PIC_P';
    public static final String USER_POFILE_AC = 'FS AC_P';
    public static final String USER_PROFILE_MDM = 'MDM Read only';
    public static final String USER_PROFILE_OP_ADMIN = 'Ops Admin';
    public static final String USER_PROFILE_OP_ANALYST = 'Ops Analyst';
    public static final String USER_POFILE_FETADMIN = 'FET System Admin';
    public static final String USER_POFILE_SYSADMIN = 'System Administrator';  
    public static final String USER_PROFILE_FETSEMANUFACTURER = 'FET SE Manufacturer Profile';//Added for creating Shipping forms
    public static final String OUTLET_RECORD_TYPE = 'FS Outlet';
    public static final String OUTLET_RECORD_TYPE1 = Label.INTERNATIONAL_OUTLET_RECORD_TYPE;
    public static final String OD_RECORD_TYPE_INT =  Label.INT_OD_RECORD_TYPE;
    public static final String RT_NAME_CCNA_OD = 'CCNA Dispenser';
    public static final String PRIMARY_CONTACT = 'Primary Contact';
    public static final String STATUS_COMPLETE = 'Complete';
    public static final String INITIAL_ORDER_TRANSACTION_DATA='Initial Order Transaction Data';
    
    public static final String x7000SeriesRecType = '7000 Series';
    public static final String x8000SeriesRecType = '8000 Series';
    public static final String x9000SeriesRecType = '9000 Series';
    public static final String x8K9KSeriesRecType = '8000 & 9000 Series';
    //FNF-747 change starts
    public static final String REMOVAL='Removal';    
    //FNF-747 change ends
    public static final String NEWINSTALLATION='New Install';
    public static final String EXECUTIONPLAN='Execution Plan';
    public static final String RELOCATION_7000_SERIES = 'Relocation 7000 Series';
    public static final String RELOCATION_8K9K_SERIES = 'Relocation 8000 OR 9000 Series';
    public static final String RECTYPE_8k_9k= '8000/9000 Series';
    public static final String RECTYPE_SPAlignedZip= 'SP Aligned Zip';
    public static final String Platform_7k='7000'; 
    public static final String Platform_8k='8000';
    public static final String Platform_9k='9000';
    public static final String Platform_91k='9100';  
    public static final String NEWINITIALORDER='New Install';
    public static final String TECHINSTRECTYPE ='Technician Instruction';
    //FET 5.0 Associate Brandset Record Type Names
    public static final String ASSBRANDSET_HQ = 'HQ Association Brandset';
    public static final String ASSBRANDSET_IP = 'IP Association Brandset';
    public static final String ASSBRANDSET_OD = 'OD Association Brandset';
  
    //OCR'17
    public static final Integer ZERO=0;
    
    //FET 5.0 Installation Transaction Status Labels
    public static final String IPCOMPLETE = 'Complete';
    public static final String EQUIPMENTBOOKED = 'Equipment Booked';
    //venkat
    //public static final String replacement='Replacement';
    //public static final String REMOVAL=Label.IP_Removal_Rec_Type;
    public static final String IPCANCELLED='Cancelled';
    //public static final String relocation='Relocation';
    public static final String SAComplete='SA Complete';
    public static final String SAPending='SA Pending';
    public static final String SAschedule='SA Scheduled';
    public static final String x1Approved='1 PP Approved';
    public static final String x1ReadySchedule='Ready for Scheduling';
    public static final String x3PendingSchedu='Pending Reschedule';
    public static final String x4InstallSchedule='Scheduled'; 
    public static final String onHolds='On Hold';
    public static final String initiated='Initiated';
    public static final String reconnectSchedule='Reconnect Scheduled';
    public static final String disconSchedule='Disconnect Scheduled';
    public static final String disconComplete='Disconnect Complete';
    public static final String scheduled='Scheduled';
    //FNF-747 starts
    public static final List<String> TRANSACTION_STATUS=new List<String>{'Scheduled','Pending Reschedule','Complete','Pending to new Outlet','Pending Install/Reconnect'};
     
    //FNF-747 ends

    //PIA Dispenser Desposition Values
    public static final String dispBackatLocation = 'Dispenser back at location and reconnected';
    public static final String removedAndShipped ='Removed and Shipped to New Outlet';
    public static final String removedAndTakenTOSp = 'Removed and taken to SP for Storage';
    public static final String disconnctedAndBackroom = 'Disconnected and placed in Backroom';
    
    
    //PIA Status
    public static final String PIA_COMPLETE = 'Post Install Activity Complete';
    public static final String PIA_CANCELLED = 'Cancelled';
    public static final String PIA_PENDINGTONEWOUTLET ='Pending to New Outlet';
    public static final String PIA_pendingINSTALLRECONNECT ='Pending Install/Reconnect';
    
    public static final String SA_COMPLETE = 'Complete';
    public static final String SA_PENDING ='Pending';
    public static final String SA_STATUSPENDING='**Pending';
    public static final String SA_STATUSSCHED='*Scheduled';
    public static final String SPSURVEY='SP Survey Pending';
    public static final String EP_INPROGRESS='In Progress';
    public static final String EP_ONHOLD='On-Hold';
    public static final String IPEPAPPROVED='Approved';
    //venkat
    // New Constants added by Deepti
    public static final String noStatic2Agitated = '0 Static/2 Agitated';
    public static final String naTo80009000S = 'N/A to 8000/9000 Series';
    public static final String twoStatic1Agitated = '2 Static/1 Agitated';
    public static final String Barqs = 'Barqs';
    public static final String Pibb = 'Pibb';
    //OCR1 bypass validation for bottler
    public static Boolean BypassOrderDelivery =false;
    
    //Defect 3740 fix, May 30,2017
    public static Boolean BypassupdateAccountTeamMember =false;
    
    public static final String twoStaticError = 'Please Select Two Static Brands';
    public static final String onlyTwoStaticError = 'Please Select Only Two Static Brands';
    public static final String na80009000Static = 'Please do not Select N/A to 8000/9000 Series from Static Brands';
    public static final String oneAgitatedError = 'Please Select an Agitated Brand';
    public static final String onlyOneAgitatedError = 'Please Select Only One Agitated Brands';
    public static final String na80009000Agitated = 'Please do not Select N/A to 8000/9000 Series from Agitated Brands';
    public static final String twoAgitatedError = 'Please Select Two Agitated Brands';
    public static final String barqsPibbTogether = 'Please Select Only ' +  Label.Agitated_Brand_1 + ' and ' + Label.Agitated_Brand_2 + ' Together in Agitated Brands';
    public static final String onlyTwoAgitatedError ='Please Select Only two Agitated Brands';
    
    public static final String selectNA80009000Agitated = 'Please Select N/A to 8000/9000 Series from Agitated Brands';
    public static final String selectNA80009000Static ='Please Select N/A to 8000/9000 Series from Static Brands';
    public static final String selectNA80009000BrandOption ='Please Select N/A to 8000/9000 Series from Brand Options Picklist';
    public static final String deselectStatic = 'Please De-Select Static Brands';
    public static final String deselectAgitated = 'Please De-Select Agitated Brands';
    public static final String deselectStaticNo7000 = 'You need to deselect Statics Brands Selections value if not installing a 7000 Dispenser';
    public static final String deselectAgitatedNo7000 = 'You need to deselect Agitated Brands Selections value if not installing a 7000 Dispenser.';
    public static final String X7000_Site_Assessment = 'Service Provider: Site Assessment Only (7000 Series Only)';
    public static final String serviceProvider7000 = 'Service Provider(7000 Only)';
    public static final String onBoardingTrainer7000Error = 'Please select 7000 dispenser quantity for this on-boarding trainer value';
    //commented due to Issue 497
    //public static final String siteAssessment7000Error = '# Planned Freestyle 7000 Dispenser should be more than zero for this Site Assessment';
    public static final String brandOptionNA8K9K= 'Please do not Select N/A to 8000/9000 Series from Brand Option Selection Picklist';
    public static final String trainerPicklistError = 'Please select a valid on-boarding trainer value';
    public static final String saContactName = 'Please Enter Site Assessment Contact Name';
    public static final String saContactPhone = 'Please Enter Site Assessment Contact Phone';
    public static final String saContactEmail = 'Please Enter Site Assessment Contact Email';
    public static final String saAlternateContact = 'Please Enter Site Assessment Alternate Contact';
    public static final String saContactTitle = 'Please Enter Site Assessment Contact Title';
    public static final String selectBrandOption = 'You Must Select a Value in Brand Option Picklist';
    public static final String saFieldSetBaseName = 'Site_Assessment_Information';
    public static final String spicyCherryFieldSetBaseName = 'Spicy_cherry_Hide_show_Conn_Time';
    public static final String cifRecordTypeBase = 'FS_Customer_Input_';
    public static final String equipmentInfoFieldSetBaseName = 'FS_Equipment_Information';
    public static final String selectTemplateTypeError = 'Please Select a template type';
    public static final String noSiteAssessmentReq = 'No Site Assessment Required';
    public static final String selectSiteAssessment = 'Please Select Site Assessment Requirement';
    public static final String defaultOutletName = 'FET International Outlet';
    public static final String businessOwnerRole = 'Business Owner';
    public static final String dispenserOwnerRole = 'Dispenser Owner';
    public static final String dispenserStatusInstalled = 'Installed at Outlet';
    public static final String dispenserStatusAssigned = 'Assigned to Outlet';
    public static final String dispenserCoordinatorProfile = 'FET SE Dispenser Coordinator Profile';
    public static final String sedispenserCoordinatorProfile = 'FET SE Dispenser Coordinator Profile';
    public static final String dispenserManufacturerProfile = 'FET Manufacturer Profile';
    public static final String BusinessUnit = 'Coca-Cola Business Unit';
    public static final String ccfc = 'Coca-Cola Finance Corporation';
    public static final String bottler = 'Bottler';  
    public static final String FSCustomerInputFormController = 'FSCustomerInputFormController';
    public static final String ActivityCommentstoNotesMigrationBatch='ActivityCommentstoNotesMigrationBatch';
    public static final String BatchClass='BatchClass';
    public static final String MediumPriority = 'Medium';
    public static final String FET = 'FET';
    public static final String BLANKVALUE = '';
    public static final String SLASH = '/';
    public static final String COLON = ':';
    public static final String HYPHEN='-';
    public static final String NA='NA';
    public static final Object NULLVALUE=null;
    //Fet-International coca-cola mail id
    public static final String CokeId='cokefreestylesupport@air-watch.com';
    public static final string noICCodeMsg = 'Your profile doesnt have the permission you need to create a shipping form.  The administrator needs to assign the appropriate IC Code';
    public static final Id RECORD_TYPE_CHAIN=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_CHAIN);
    public static final Id RECORD_TYPE_HQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_HQ);
    public static final Id RECORD_TYPE_OUTLET=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_OUTLET);
    public static final Id RECORD_TYPE_OUTLET1=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_OUTLET1);
    public static final Id RECORD_TYPE_OUTLET_INT=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_OUTLET_INT);
    public static final Id RECORD_TYPE_VENDOR=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_VENDOR);
    public static final Id RECORD_TYPE_BOTLLER=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_Name_Bottler);
    public static final Id RECORD_TYPE_ODINT=FsUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Label.INT_OD_RECORD_TYPE);
    public static final Id RECORD_TYPE_CASE=FsUtil.getObjectRecordTypeId(Case.SObjectType,FSConstants.RECORD_TYPE_NAME_LMCASE);
   
    public static final Apexpages.Message PAGE_MSG_ACCESS = new Apexpages.Message(ApexPages.Severity.INFO, 'User don\'t have write access');
    
    //CIF Variables Start
    public static final string SELECTOUTLETS = '1.Select Outlets';
    public static final string SALESREPINFO = '2.Team Members';
    public static final string SITESURVEYREQUEST = '3.Site Survey Request';
    public static final string SITESURVEYRESULTS = '4.Site Survey Results';
    public static final string INSTALLATION = '5.Installation';
    public static final string DISPENSEREQUIPMENT = '6.Dispenser/Equipment';
    public static final string ICEMAKERWATERFILTER = '7.Ice Makers/Water Filters';
    public static final string PRODUCT = '8.Product';
    public static final string TRAINING = '9.Training';
    public static final string FINANCE = '10.Finance';
    public static final string SUMMARY = '11.Summary';
    public static final String SECOUTLET = 'Outlets Section';
    public static final String SECSALESREPINFO = 'Team Members Section';
    public static final String SECSITESURVEYREQUEST = 'Site Survey Request Section';
    public static final String SECSITESURVEYRESULTS = 'Site Survey Results Section';
    public static final String SECINSTALLATION = 'Installation Section';
    public static final String SECDISPENSEREQUIPMENT = 'Dispenser/Equipment Section';
    public static final String SECICEMAKERWATERFILTER = 'IceMaker/WaterFilter Section';
    public static final String SECPRODUCT = 'Product Section';
    public static final String SECTRAINING = 'Training Section';
    public static final String SECFINANCE = 'Finance Section';
    public static final String SECSUMMARY = 'Summary Section';
    public static final String SECCREATEEP = 'Create EP';
    public static final String NOTSTARTED = 'Not Started';
    public static final String INPROGRESS = 'In Progress';
    public static final String COMPLETED = 'Completed';
    public static final String APPROVED='Approved by Customer';
    public static final String REVIEWAW='Pending Site Survey';
    public static final String NOTAPPROVED='Not Approved';
    public static final String ONHOLD='On Hold';
    public static final String CANCELLED='Cancelled';
    public static final String CLCANCELLED='Closed – Cancelled';
    public static final String CLNOTAPPROVED='Closed –Not Approved';
    public static final string DEFAULT_SORT_FIELD = 'FS_ACN__c';
    public static final string FETSYSADM ='FET System Admin';
    public static final String CLOSEDCONVTOEP= 'Closed – Converted to EP';
    public static final String CLOSEDCANNOTAPP= 'Closed – Cancelled or Not Approved';
    public static final String SCNDSSPEN= 'Second Site Survey Pending';
    public static final String AWTCUSTDEC= 'Awaiting Customer Decision';
    public static final String REDFORCOM= 'Ready for COM';
    public static final String CHEVSTATGRN='GREEN';
    public static final String CHEVSTATYLW='YELLOW';
    public static final String CHEVSTATRED='RED';
    
    //International 3
    //New Constants added as part of FET Int R1 2017
  //Fs_AddressValidationExtension constants
    public static final String COMMA =',';
    public static final String SEMICOLON=';';
    public static final String NEWLINE='\n';
    public static final String BLANK =' ';
    public static final String STATUS ='status';
    public static final String STATUS_OK ='OK';
    public static final String LNG_NAME ='long_name';
    public static final String SRT_NAME ='short_name';
    public static final String TYPES_STG ='types';
    public static final String ST_NUM ='street_number';
    public static final String ROUTE ='route';
    public static final String CNTY_POL ='countrypolitical';
    public static final String POSTAL_CODE ='postal_code';
    public static final String ADMIN_L1 ='administrative_area_level_1political';
    public static final String LOCALITY ='localitypolitical';
    public static final String ADMIN_L2 ='administrative_area_level_2political';
    public static final String NGHBR_POL ='neighborhoodpolitical';
    public static final String POSTAL_TOWN_P ='postaltownpolitical';
    public static final String ADMIN_L3 ='administrative_area_level_3political';
    public static final String ADMIN_L4 ='administrative_area_level_4political';
    public static final String POL_SUB_SUBL_L1 = 'politicalsublocalitysublocality_level_1';
    public static final String POSTAL_TOWN ='postal_town';
    public static final Boolean BOOL_VAL =true;
    public static final Integer STATUS_400 =400;
    //FNF 747 Change Starts
    public static final Decimal COUNTZERO = 0.0;
    //FNF 747 Change Ends
    public static final Integer STATUS_200 =200;
    public static final Integer NUM_1 =1;
    public static final Integer NUM_2 =2;
    public static final Integer NUM_3 =3;
    public static final String STATUS_ST_400 ='400';
    public static final String STRING_NULL = null;
    public static final List<Integer> INT_NULL = null;
    public static final string PLUS = '+';
    public static final string NOT_APPLICABLE= 'NA';
    
    //FET 7.0 FNF-462 constants Start.
    public static final String AMOA = 'AMOA';
    public static final String FROMTEXT = 'FROM';
    public static final String TO = 'TO';
    public static final String NO = 'No';
    public static final integer FIVE = 5;
    public static final integer TEN = 10;
    public static final String AMOAREMOVAL = 'Removal Done - AMOA Pending';
    public static final String AMOASUBMIT = 'Submitted';
    public static final String AMOACOMPLETE = 'Complete';
    //FET 7.0 FNF-462 constants End.
    
    //FET 7.0 FNF-364 constants Start
    public static final String FORSTRING = 'For';
    
    //Fs_addressValidationHepler constants.
   
    public static final String HEADER = 'Record Id, Name \n';
    public static final String HEADER1 = 'Record Id, Name \n';
    public static final String CSVNAME= 'FailedOutlets.csv';
    public static final string CSVNAME1= 'SuccessOutlets.csv';
    public static final  String SUBJECT ='Outlets Processed In Batch class';
    public static final  String LAT ='lat';
    public static final  String LON ='lng';
    public static String userId;
    //FsOutletAddressValidationBatch

    public static final String ZERO_RESULTS ='ZERO_RESULTS';
    public static final String OKAY ='OK';
    public static final String LAT_TEXT ='lat';
    public static final String LON_TEXT ='lng';
    //International 3
    //Constants for PMD
    public static final String STR_NULL = null;
    public static final Date DATE_NULL = null;
    public static final DateTime DATETIME_NULL = null;
    public static final Id ID_NULL = null;
    public static final Integer INTG_NULL = null;
    public static final Decimal DECIMALNULL = null;
    public static final boolean BOOL_NULL = null;
    public static final CIF_Header__c CIF_NULL = null;
    public static final List<FS_SelectOutletDispenser.FS_Outlet_DispenserWrapper> OBJ_LIST_NULL = null;
     public static final ApexPages.StandardSetController STD_CTRL_NULL = null;
    //Linkage Management Case Constants FACT R1 2018
    public static final String RECORD_TYPE_NAME_LMCASE = 'Linkage Management';
    public static final String LM_CASE_TYPE = 'LM Case';
    public static final String STATUS_ASSIGNED = 'Assigned';
    public static final String FINANCE_ON_HOLD = 'Finance on Hold';
    public static final String ACCOUNT_TEAM_INITIATED_AMOA = 'Account Team Initiated AMOA';
    public static final String JDE_INITIATED_AMOA = 'JDE Initiated AMOA';
    public static final String JDE_INSTALL_BASE_NOTIFIED = 'JDE Install Base Notified';
    public static final String JDE_AMS_ON_HOLD ='JDE AMS on Hold';
    public static final String JDE_LINKAGE_REQUEST ='JDE Linkage Request';
    public static final String PENDING_INSTALL = 'Pending Install';
    public static final String ACCOUNT_TEAM_ON_HOLD ='Account Team on Hold';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String SF_EMAIL_TO_RSS = 'Salesforce sent an email to RSS';
    public static final String SF_EMAIL_TO_RSS_CCAST ='Salesforce sent an email to RSS and Case Creator';
    public static final String SF_EMAIL_TO_JDE_INSTALL_BASE ='Salesforce sent an email to JDE Install Base and CCAST Group';
    public static final String SF_EMAIL_TO_JDE_INSTALL_BASE_CREATOR = 'Salesforce sent an email to JDE Install Base and Case Creator';
    public static final String SF_EMAIL_TO_JDE_AMS ='Salesforce sent an email to JDE AMS';
    public static final String SF_EMAIL_TO_CCAST = 'Salesforce sent an email to Case Creator';
    public static final String SF_EMAIL_TO_JDEAMS_CCAST = 'Salesforce sent an email to JDE AMS and Case Creator';
    public static final String RSS_RESPONSE = 'RSS responded to System email'; 
    public static final String JDE_RESPONSE = 'JDE Install Base responded to system email';
    public static final String SUB_STATUS_ERROR = 'Please select a valid Sub-status for the selected Case type'; 
    public static final String ACCOUNT_ERROR = 'From Account and To Account must not be the same';
    public static final String ISSUE_ERROR = 'Issue Name is mandatory.';
    
    // Start FET 7.0  FNF-459
    public static final String YES = 'Yes';
    public static final String CASECOMMENT_JDE='Salesforce sent an email to JDE AMS team';
    public static final String FS_SALESSUPPORT_CASECOMMENT='Salesforce sent an email to Sales Support';
    public static final String SALESSUPPORT_EMAILTMP_JDE='Email_JDE_when_Escalate_to_Sales_Support';
    public static final String EMAILTMP_FOR_JDE_RO4W='Email_To_JDE_when_R04W_Pending_to_NewOL';
    public static final String CONTDOC_SHARETYPE = 'V';
    public static final String RO4W_AMOA_GROUP = 'FS RO4W AMOA Receipents';
    //End FET 7.0  FNF-459
    
    //Start FET 7.0 FNF-366
    public static final String FETADMINNAME = 'FET Admin';
    public static final String PROJECTNAME1 = 'FET 7.0';
    public static final String ACCOUNTTEAMINITIATEDAMOA = 'Account Team Initiated AMOA';
    public static final String JDEINITIATEDAMOA = 'JDE Initiated AMOA';
    public static final String INSTALLFAILEMAIL = 'UpdateFailedOnRO4WRecord';
    public static final String VALIDATEAMOACASESTATUS = 'validateAMOACaseStatus';
    //End FET 7.0 FNF-366
    
    //Start FET-7.0 FNF 850
    public static final String emailNotificationOnDeletionOfAMOAForm = 'AMOA Deletion Notification';
    public static final String EmailnotificationonAdditionofAMOAFormToCase = 'AMOA Addition Notification';
    public static final String FS_ContentDocumentLinkTrigger_Handler = 'FS_ContentDocumentLinkTrigger_Handler';
    public static final String sendEmailToAMSOnDeletionOfAMOA = 'sendEmailToAMSOnDeletionOfAMOA';
    //End FET-7.0 FNF 850
    
    //Method to get the local time of user
    public static string getLocalTime()
    {
        String timeZone = UserInfo.getTimeZone().getID();
        Datetime dateGMT=System.now();
        Datetime d1=Datetime.valueOf(dateGMT);
        string s1=d1.format();
        return s1;
    }
    
    public static String getIntegrationUserID() {
        if(userId == null || userId == '' ){        
            for(User user : [SELECT Id, Name FROM User
                             WHERE Name = :Label.Integration_User]) {
                                 userId =  user.Id;
                             }
        }
        return userId;
    }
    
    //Start  NonLMCaseCustomButtons and RecordType Page
   @AuraEnabled
   public final String RT_CONNECTIVITY_SOLUTION = 'Connectivity Solution';
    @AuraEnabled
   public final String RT_NORTH_AMERICAN_CASE = 'North American Case';
    @AuraEnabled
   public final String RT_NON_NORTH_AMERICAN_CASE = 'Non - North American Case'; 
    @AuraEnabled
   public final String RT_LINKAGE_MANAGEMENT = 'Linkage Management'; 
    @AuraEnabled
   public final String OWNER_FREESTYLE_AGENTS_US = 'Freestyle Agents US'; 
   @AuraEnabled
   public final String PROFILE_SERVICE_ESCALATION_AGENT = 'Service Escalation Agent'; 
    @AuraEnabled
   public final String PROFILE_FS_SE = 'FS SE'; 
    @AuraEnabled
   public final String PROFILE_FET_SE = 'FET SE';
    @AuraEnabled
   public final String PERMISSION_SERVICE_ESCALATION_ACCESS = 'Service_Escalation_Access';
    @AuraEnabled
   public final String STATUS_ASSIGNED_A = 'Assigned'; 
    @AuraEnabled
   public final String STATUS_EMT_ON_HOLD = 'EMT On Hold'; 
    @AuraEnabled
   public final String STATUS_ESCALATED = 'Escalated'; 
    @AuraEnabled
   public final String STATUS_GC_ON_HOLD = 'GC on Hold'; 
    @AuraEnabled
   public final String STATUS_FACT_ON_HOLD = 'FACT On Hold'; 
   //End
    
}