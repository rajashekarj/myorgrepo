@isTest
public class FsCIFworkbookValidationTest{
    public static final String SERIES7K='7000';
    
    // String series7k='7000';
    public Static Id recTypeHQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Headquarters');
    public Static Id recTypeOutlet=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Outlet');
    public static string onHold = 'On Hold';
    public static string summarySec = 'Summary Section';
    public static integer valFive = 5;
    public static integer valThree = 3;
    public static integer valTwo = 2;
    public static integer valSixty = 60;
    public static integer valTwenty = 20;
    public static final String FSCOMP ='FS COM_P';
    public static string test123='TEST123';
    public static final String COM ='COM';
    public static final String TESTCONTACTHQ ='TestContactHQ';
    public static final String PHONENO = '123456879';
    public static final String EMAILID = 'test@test.com';
    public static final String NULLVAL=null;
    public static final Date DATENULL=null;
    public static final Boolean TRUEVALUE= true;
    public static final String APPROVEDBYCUST='Approved by Customer';
    public static final String VALID ='id';
    public static final String STAGE2='2.Team Members';
    public static final String STAGE3='3.Site Survey Request';
    public static final String STAGE4='4.Site Survey Results';
    public static final String STAGE5='5.Installation';
    public static final String STAGE6='6.Dispenser/Equipment';
    public static final String STAGE7='7.Ice Makers/Water Filters';
    public static final String STAGE8='8.Product';
    public static final String STAGE9='9.Training';
    public static final String STAGE10='10.Finance';
    public static final String STAGE11='11.Summary';
    public static final String REMODEL='Remodel';
    public static final String PLATFORM1='7000';
    public static final Integer NUMB2=2;
    public static  String inProgress='In Progress';
    public static final String COMPLETED='Completed';
    public static final String CREDIT_CARD='Credit Card';
    public static string siteAssess ='Site Assess + GFE bid proposal (traditional)';
    // private static final String VALUE='Yes'; 
    public static string testNotes= 'Test Notes';
    public static string notStarted='Not Started';
    public static string coFreestyle='Coca-Cola Freestyle Project Team';
    public static string valTen ='< 10%';
    public static string appSoft='Approved Soft';
    public static string contract='Contractor';
    public static string cuno='3M/Cuno';
    public static string koService='KO Service Provider';
    public static string footPrint= 'EcoSure';
    public static string aaaStreet= 'aaa Street';
    public static string backDraft='Bank Draft';
    public static string testVal = 'Test';
    public static string valAm='6:00 AM';
    public static string hoshizaki = 'Hoshizaki';
    public static string cokeSmart= 'CokeSmart';
    public static string moVal = 'MO';
    public static string strTwo = '2';
    //Modified as part of FET-7.1 FNF 1019 
    public static string fieldHeader = 'Workbook,Sales Email,Operations Manager Email,Outlet ACN#,Bill-To Street Address,Bill-To City,Bill-To State,Bill-To ZIP,Bill-To Phone,Mail-To Street Address,Mail-To City,Mail-To State,Mail-To ZIP,Outlet Contact Name ,Outlet Phone Number,Channel,Product Billing Set Up,Estimated Gallons,Site Assessment Requirements,SA Contact Email,Platform 1,Quantity 1,Platform 2,Quantity 2,Platform 3,Quantity 3,Brandset 1,Brandset 2,Brandset 3,Dasani 1,Dasani 2,Dasani 3,Color of 9000,# Top-Mounted Ice Makers (9000),# Top-Mounted Ice Makers (7000),7000/7100 HFCS/Sweetener location,Installation Type,Describe any known construction needs?,Contractor Coordination done by,General Contractor,GC Email,Outlet Construction Contact Email,Pepper Mix,Water Button Option 9000,Water Button Option 8000,Water Button Option 7000,Time to call home,Wired Solutions Required,ValidFill Option,Crew Serve,Portion Control Setting,Customer\'s Ice Fill Policy,Top-Off Feature,size 1,cup name 1,fl oz 1,size 2,cup name 2,fl oz 2,size 3,cup name 3,fl oz 3,size 4,cup name 4,fl oz 4,size 5,cup name 5,fl oz 5,size 6,cup name 6,fl oz 6,Provide On-Boarding Contact Email,On-Boarding Trainer,On-Boarding - Days after Install,Requested training start time,Outlet Open Time,Training Comments,Requested Cartridge Order Method,Admin User Email,Standard User Email,Distributor Name,DistributorCity,Distributor State,Cartridge Payment Method,Program Fee Payment Method,Remove All FTN (Legacy) Serve Dispensers?,Product Comments,Installation Contact Email,Install Period,Install Date,Day or Night Install,Projected Opening,Line Installation,Equipment Install,Projected Fire-Up,DRY ACCOUNT,Is an approved Water Filter installed?,Water Filter Outlet Contact Email,Water Filter Installer Contact Email,Water Filter Manufacturer,Water Filter Model #,Water Filter Installer,Ice Fill Method,Top Mounted Ice Maker Manufacturer,Ice Maker Model,Who will coordinate Ice Maker install?,Ice Maker Installer,Who will provide ice maker,What type of ice is used for Manual Fill?,Ownership of current Fountain Equipment,Disposition of current Fountain Equipment,Disposition of Current BIB Rack,Disposition of Current BIB Pump,Ice maker and water filter comments,Please list any ancillary equipment to remain on-site,Ancillary equipment needed,Dispenser comments';
    public static string contentType = 'text/csv';
    public static string filename = 'CIF WorkBook.csv';
    public static CIF_Header__c cifHead;
    @testSetup
    private static void loadTestData(){
        Integer counter=0;
        
        final List<Account> hqCustList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        final List<Account> outletCustList= FSTestFactory.createTestAccount(false,50,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'));
        // List<Account> chainCustomerList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Chain'));
        for(Account acc:outletCustList){
            acc.FS_Headquarters__c = hqCustList.get(0).id;
            acc.FS_ACN__c = '00001673'+counter;
            acc.FS_Payment_Type__c = 'No';
            acc.Invoice_Customer__c = 'No';
            counter++;
        }
        Insert outletCustList;
       
        //Create cifHead
        cifHead = new CIF_Header__c();
        cifHead.Name =hqCustList[0].name+' V.0';
        cifHead.FS_Version__c = 10.02;
        cifHead.FS_HQ__c=hqCustList[0].id;
        insert cifHead;
        FSTestFactory.createTestDisableTriggerSetting();
    }
    
    
    private static testMethod void testWorkBookUpload(){
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
        system.debug(parentRecord.Id);
        User userID;
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        System.runAs(sysAdmin){
            final Profile prof = FSTestFactory.getProfileId(FSCOMP);
            userID = FSTestFactory.createUser(prof.id);
        }
        final AccountTeamMember__c atmCom=new AccountTeamMember__c();
        atmCom.AccountId__c=parentRecord.id;
        atmCom.TeamMemberRole__c =COM;
        atmCom.UserId__c =userID.id;
        Insert atmCom;
        final AccountTeamMember__c atmSales=new AccountTeamMember__c();
        atmSales.AccountId__c=parentRecord.id;
        atmSales.TeamMemberRole__c ='Sales Team Member';
        atmSales.UserId__c =userID.id;
        Insert atmSales;
        
        Contact cntct = new Contact();
        cntct.AccountId = parentRecord.id;
        cntct.LastName = 'Contact';
        cntct.Phone= '9874563210';
        cntct.FirstName = testVal;
        cntct.Email = 'test@testemail.com';
        insert cntct;
        
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('AccId', parentRecord.Id);
        final ApexPages.StandardController stdCntlr = new ApexPages.StandardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdCntlr);
        controller.onLoad();
        controller.lstOutlet[0].outlet.FS_ACN__c = '0001236547';
        controller.lstOutlet[1].outlet.FS_ACN__c = '0001236549';
        Test.startTest();
        controller.showPopup();
        
        //create parent csv Holder
        final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
        holder.FS_WorkBook_Name__c='CIF WorkBook';
        insert holder;
        
        string uplFile =fieldHeader+'\n'+'CIF workbook upload test,susheng@coca-cola.com,gsteiner@coca-cola.com,167352,Ind,Mysore,GA,234567,nhoj,Ind,Mysore,GA,234567,John,nhoj,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,test@testemail.com,9000,89,8000,21,7000,10,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 05 - Pibb/Hi-C/Rasp,0,0,0,Red,23,32,0,New Construction,Construction 1,Coca-Cola Freestyle Project Team,Wendy\'s International-Tommy Morgan,test@testemail.com,test@testemail.com,> 20%,Hide,Show,0,,0,0,Yes,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,test@testemail.com,Footprint (Standard),3,6:00 AM,6:30 AM,0,VMS,test@testemail.com,test@testemail.com,sa,sa,as,Invoice (Payment Terms),Invoice (Payment Terms),No,0,test@testemail.com,Week of?,2/25/2017,Night - typically 10pm start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,No - approved make/model to be installed,test@testemail.com,test@testemail.com,Ecolab,mo-098,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,Customer ,Approved soft,Bottler,Return to KO warehouse,Return to bottler warehouse,Return to KO warehouse,0,0,0,0'  +'\n';   
        
        //create Attachment
        Attachment file= new Attachment();
        //file.Body=csvFile;
        file.Body= Blob.valueof(uplFile);
        file.ContentType = contentType;
        file.parentId = holder.Id;
        file.Name=fileName; 
        insert file;
        
        controller.cifCsvFileBody= file.body;
        controller.cifCsvFileName = file.name;
        controller.getreadFromFile();
        controller.closePopup();
        controller.actionCopyCustomerInput();
        system.assertEquals(controller.lstOutlet.size(),50);
        
        //start
        uplFile =fieldHeader+'\n'+'CIF workbook upload test,,,00000037,Ind,Mysore,GA,234567,(904) 886-2179,Ind,Mysore,GA,234567,John,(904) 886-2179,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,,9000,89,8000,21,7000,10,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 05 - Pibb/Hi-C/Rasp,0,0,0,Red,23,32,0,New Construction,Construction 1,Coca-Cola Freestyle Project Team,Wendy\'s International-Tommy Morgan,test@testemail.com,test@testemail.com,> 20%,Hide,Show,0,,0,0,Yes,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,Footprint (Standard),3,6:00 AM,6:30 AM,0,VMS,test@testemail.com,test@testemail.com,sa,sa,as,Invoice (Payment Terms),Invoice (Payment Terms),No,0,test@testemail.com,Week of?,2/25/2017,Night - typically 10pm start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,No - approved make/model to be installed,test@testemail.com,test@testemail.com,Ecolab,mo-098,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,Customer ,Approved soft,Bottler,Return to KO warehouse,Return to bottler warehouse,Return to KO warehouse,0,0,0,0'  +'\n';   
        
        //create Attachment
        file= new Attachment();
        //file.Body=csvFile;
        file.Body= Blob.valueof(uplFile);
        file.ContentType = contentType;
        file.parentId = holder.Id;
        file.Name=fileName; 
        insert file;
        
        controller.cifCsvFileBody= file.body;
        controller.cifCsvFileName = file.name;
        controller.getreadFromFile();
        
        
        FSCustomerInputFormNewAndEdit cont = new FSCustomerInputFormNewAndEdit();
        String cifid = cifHead.id;
        cont.getSummaryReport(cifid);
        
        Test.stopTest();
    }
    
    private static testMethod void testWorkBookUploadBlank(){
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
        User userID;
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        System.runAs(sysAdmin){
            final Profile prof = FSTestFactory.getProfileId(FSCOMP);
            userID = FSTestFactory.createUser(prof.id);
        }
        final AccountTeamMember__c atmCom=new AccountTeamMember__c();
        atmCom.AccountId__c=parentRecord.id;
        atmCom.TeamMemberRole__c =COM;
        atmCom.UserId__c =userID.id;
        Insert atmCom;
        final AccountTeamMember__c atmSales=new AccountTeamMember__c();
        atmSales.AccountId__c=parentRecord.id;
        atmSales.TeamMemberRole__c ='Sales Team Member';
        atmSales.UserId__c =userID.id;
        Insert atmSales;
        
        Contact cntct = new Contact();
        cntct.AccountId = parentRecord.id;
        cntct.LastName = 'Contact';
        cntct.Phone= '9874563210';
        cntct.FirstName = testVal;
        cntct.Email = 'test@testemail.com';
        insert cntct;
        
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('AccId', parentRecord.Id);
        final ApexPages.StandardController stdCntlr = new ApexPages.StandardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdCntlr);
        controller.onLoad();
        //controller.lstOutlet[0].outlet.FS_ACN__c = '0001236547';
        //controller.lstOutlet[1].outlet.FS_ACN__c = '0001236549';
        Test.startTest();
        controller.showPopup();
        
        //create parent csv Holder
        final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
        holder.FS_WorkBook_Name__c='CIF WorkBook';
        insert holder;
        
        List<Account> accACN = [select FS_ACN__c,Invoice_Customer__c,FS_Payment_Type__c from Account where  RecordTypeId=:recTypeOutlet and (FS_ACN__c = '0000167329' or FS_ACN__c = '0000167330')];
        accACN[1].Invoice_Customer__c = 'Yes';
        accACN[1].FS_Payment_Type__c = 'Yes';
        update accACN;
        //start
        
        string uplFile = fieldHeader+'\n'+'CIF workbook upload blank,0,0,0000167329,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,,0,,0,,0,,,,,,,,0,0,0,New Construction,0,0,0,0,0,0,,,,,0,0,0,,,,,,,,,,,,,,,,,,,,,,0,0,0,,,0,0,0,0,0,0,0,0,0,0,0,0,0,,0,,,,,0,0,0,0,0,0,0,Manual,0,0,0,0,0,0,0,0,0,0,0,0,0,0';
        //create Attachment
        Attachment file= new Attachment();
        //file.Body=csvFile;
        file.Body= Blob.valueof(uplFile);
        file.ContentType = contentType;
        file.parentId = holder.Id;
        file.Name=fileName; 
        insert file;
        controller.cifCsvFileBody= file.body;
        controller.cifCsvFileName = file.name;
        controller.getreadFromFile();
        system.assertEquals(accACN.get(1).Invoice_Customer__c, 'Yes');   
        uplFile = fieldHeader+'\n'+'CIF workbook upload test,0,0,0000167330,Ind,Mysore,GA,234567,2344,Ind,Mysore,GA,234567,0,0,0,0,0,0,0,,0,,0,,0,,,,,,,,0,0,0,New Construction,0,0,0,0,0,0,,,,,0,0,0,,,,,,,,,,,,,,,,,,,,,,0,0,0,,,0,0,0,0,0,0,0,0,0,0,0,0,0,,0,,,,,0,0,0,0,0,0,0,Manual,0,0,0,0,0,0,0,0,0,0,0,0,0,0'  +'\n';   
        
        //create Attachment
        file= new Attachment();
        //file.Body=csvFile;
        file.Body= Blob.valueof(uplFile);
        file.ContentType = contentType;
        file.parentId = holder.Id;
        file.Name=fileName; 
        insert file;
        controller.cifCsvFileBody= file.body;
        controller.cifCsvFileName = file.name;
        controller.getreadFromFile();
        FSCustomerInputFormNewAndEdit cont = new FSCustomerInputFormNewAndEdit();
        String cifid = cifHead.id;
        cont.getSummaryReport(cifid);
        
        //stop
        
    }
    private static testmethod void cartridgeAndPaymentTest()
    {
        Account accACN = [select FS_ACN__c,Invoice_Customer__c,FS_Payment_Type__c from Account where  RecordTypeId=:recTypeOutlet AND FS_ACN__c = '0000167344' Limit 1];
        
        accACN.Invoice_Customer__c = 'Yes';
        accACN.FS_Payment_Type__c = 'Yes';
        
        update accACN;
        system.assertNotEquals(Null, accACN.id);
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
        User userID;
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        System.runAs(sysAdmin){
            final Profile prof = FSTestFactory.getProfileId(FSCOMP);
            userID = FSTestFactory.createUser(prof.id);
        }
        final AccountTeamMember__c atmCom=new AccountTeamMember__c();
        atmCom.AccountId__c=parentRecord.id;
        atmCom.TeamMemberRole__c =COM;
        atmCom.UserId__c =userID.id;
        Insert atmCom;
        final AccountTeamMember__c atmSales=new AccountTeamMember__c();
        atmSales.AccountId__c=parentRecord.id;
        atmSales.TeamMemberRole__c ='Sales Team Member';
        atmSales.UserId__c =userID.id;
        Insert atmSales;
        
        Contact cntct = new Contact();
        cntct.AccountId = parentRecord.id;
        cntct.LastName = 'Contact';
        cntct.Phone= '9874563210';
        cntct.FirstName = testVal;
        cntct.Email = 'test@testemail.com';
        insert cntct;
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('AccId', parentRecord.Id);
         ApexPages.currentPage().getParameters().put('Id', cifHead.Id);
        //system.debug(parentRecord);
        final ApexPages.StandardController stdCntlr = new ApexPages.StandardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdCntlr);
        controller.onLoad();
        Test.startTest();
        controller.showPopup();
        
        //create parent csv Holder
        final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
        holder.FS_WorkBook_Name__c='CIF WorkBook';
        insert holder;
        
        
        
		      
        string uplFile = fieldHeader+'\n'+'CIF workbook upload12,hashah@coca-cola.com,papandya@coca-cola.com,167343,Ind,Mysore,GA,234567,(904) 886-2179,Ind,Mysore,GA,234567,John,(904) 886-2179,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,dom@dm.com,9000,89,8000,21,7000,15,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 01 - Pepper/Hi-C/Pade,0,0,0,Red,23,32,0,New Construction,0,Coca-Cola Freestyle Project Team,Other,dom@dm.com,dom@dm.com,> 20%,Hide,Show,0,,0,0,Yes,Yes,Full,Yes,7,4,6,4,3,2,1,9,87,7,6,5,4,3,2,1,To Go,13,dom@dm.com,Footprint (Standard),3,6:00 AM,6:30 AM,0,VMS,dom@dm.com,dom@dm.com,sa,sa,as,Invoice (Payment Terms),Invoice (Payment Terms),No,0,dom@dm.com,Week of?,2/25/2017,Night - typically 10pm start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,No - approved make/model to be installed,dom@dm.com,dom@dm.com,Ecolab,0,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,None,Approved soft,0,0,0,0,0,0,0,0'+
            '\n'+'0,hashah@coca-cola.com,papandya@coca-cola.com,'+accACN.FS_ACN__c+',Ind,Mysore,GA,234567,(904) 886-2179,Ind,Mysore,GA,234567,John,(904) 886-2179,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,dom@dm.com,9000,89,8000,21,7000,15,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 01 - Pepper/Hi-C/Pade,0,0,0,Red,23,32,0,New Construction,0,Coca-Cola Freestyle Project Team,Other,dom@dm.com,dom@dm.com,> 20%,Hide,Show,0,,0,0,Yes,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,To Go,13,dom@dm.com,Footprint (Standard),3,6:00 AM,6:30 AM,Test comments,VMS,dom@dm.com,dom@dm.com,sa,sa,as,Invoice (Payment Terms),Invoice (Payment Terms),No,0,dom@dm.com,Specific Date,2/25/2017,Day – typically 8am start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,Yes,dom@dm.com,dom@dm.com,Ecolab,0,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,None,Approved soft,0,0,0,0,0,0,0,0'+
            '\n'+'0,hashah@coca-cola.com,papandya@coca-cola.com,167345,Ind,Mysore,GA,234567,(904) 886-2179,Ind,Mysore,GA,234567,John,(904) 886-2179,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,dom@dm.com,9000,89,8000,21,7000,15,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 01 - Pepper/Hi-C/Pade,0,0,0,Red,23,32,0,New Construction,0,Coca-Cola Freestyle Project Team,Other,dom@dm.com,dom@dm.com,> 20%,Hide,Show,0,,0,0,Yes,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,To Go,13,dom@dm.com,Footprint (Standard),3,6:00 AM,6:30 AM,0,VMS,dom@dm.com,dom@dm.com,sa,sa,as,0,0,No,Product Comments,dom@dm.com,Week of?,2/25/2017,Early AM – typically 5am or 6am start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,No - approved make/model to be installed,dom@dm.com,dom@dm.com,Ecolab,0,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,None,Approved soft,Leave on-site,Leave on-site,Leave on-site,Leave on-site,test,test,test,test';
        
        //create Attachment
        Attachment file= new Attachment();
        //file.Body=csvFile;
        file.Body= Blob.valueof(uplFile);
        file.ContentType = contentType;
        file.parentId = holder.Id;
        file.Name=fileName; 
        insert file;
        controller.cifCsvFileBody= file.body;
        controller.cifCsvFileName = file.name;
        controller.getreadFromFile();
        controller.actionCopyCustomerInput();
        controller.searchOutletButton();
        controller.resetSearchStatus();
        controller.closePopup1();
        controller.showPopup2();
        controller.closePopup3();
        controller.firstPN();
        controller.lastPN();
        controller.getCIFOnNext();
        controller.getCIFOnSave();
        Boolean flag;
        flag = controller.hasNextPN;
        flag = controller.hasFirstPN;
        flag = controller.hasLastPN;
        flag = controller.hasPreviousPN;
        Integer check;
        check = controller.LNumberPN;
        check = controller.UNumberPN;
        check = controller.RecordCountPN;
        check = controller.PageNumberPN;
        check = controller.PageCountPN;
        controller.showPopup1();
        controller.closePopup2();
        controller.showPopup3();
        controller.closePopup4();
        controller.showPopup4();
        controller.closePopup5();
        controller.showPopup5();
        FSCustomerInputFormNewAndEdit cont = new FSCustomerInputFormNewAndEdit();
        String cifid = cifHead.id;
        cont.getSummaryReport(cifid);
        
     }
    
    private static testmethod void cartridgeAndPaymentTest1()
    {
        Account accACN = [select FS_ACN__c,Invoice_Customer__c,FS_Payment_Type__c from Account where  RecordTypeId=:recTypeOutlet AND FS_ACN__c = '0000167344' Limit 1];
        
        accACN.Invoice_Customer__c = 'Yes';
        accACN.FS_Payment_Type__c = 'Yes';
        
        update accACN;
        system.assertNotEquals(Null, accACN.id);
        cifHead = [Select id,Name,FS_Version__c,FS_HQ__c from CIF_Header__c Limit 1];
        //Sets the current PageReference for the controller
        final PageReference pageRef = Page.FSCustomerInputForm;
        Test.setCurrentPage(pageRef);
        final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1];
        User userID;
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        System.runAs(sysAdmin){
            final Profile prof = FSTestFactory.getProfileId(FSCOMP);
            userID = FSTestFactory.createUser(prof.id);
        }
        final AccountTeamMember__c atmCom=new AccountTeamMember__c();
        atmCom.AccountId__c=parentRecord.id;
        atmCom.TeamMemberRole__c =COM;
        atmCom.UserId__c =userID.id;
        Insert atmCom;
        final AccountTeamMember__c atmSales=new AccountTeamMember__c();
        atmSales.AccountId__c=parentRecord.id;
        atmSales.TeamMemberRole__c ='Sales Team Member';
        atmSales.UserId__c =userID.id;
        Insert atmSales;
        
        Contact cntct = new Contact();
        cntct.AccountId = parentRecord.id;
        cntct.LastName = 'Contact';
        cntct.Phone= '9874563210';
        cntct.FirstName = testVal;
        cntct.Email = 'test@testemail.com';
        insert cntct;
        
        //Add parameters to page URL
        ApexPages.currentPage().getParameters().put('AccId', parentRecord.Id);
         ApexPages.currentPage().getParameters().put('Id', cifHead.Id);
        //system.debug(parentRecord);
        final ApexPages.StandardController stdCntlr = new ApexPages.StandardController(cifHead);
        final FSCustomerInputFormController controller = new FSCustomerInputFormController(stdCntlr);
        controller.onLoad();
        Test.startTest();
        controller.showPopup();
        
        //create parent csv Holder
        final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
        holder.FS_WorkBook_Name__c='CIF WorkBook';
        insert holder;
        
        
        
		      
        string uplFile = fieldHeader+'\n'+'CIF workbook upload12,hashah@coca-cola.com,papandya@coca-cola.com,167343,Ind,Mysore,GA,234567,(904) 886-2179,Ind,Mysore,GA,234567,John,(904) 886-2179,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,dom@dm.com,9000,89,8000,21,7000,15,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 01 - Pepper/Hi-C/Pade,0,0,0,Red,23,32,0,New Construction,0,Coca-Cola Freestyle Project Team,Other,dom@dm.com,dom@dm.com,> 20%,Hide,Show,0,,0,0,Yes,Yes,Full,Yes,7,4,6,4,3,2,1,9,87,7,6,5,4,3,2,1,To Go,13,dom@dm.com,Footprint (Standard),3,6:00 AM,6:30 AM,0,VMS,dom@dm.com,dom@dm.com,sa,sa,as,Invoice (Payment Terms),Invoice (Payment Terms),No,0,dom@dm.com,Week of?,2/25/2017,Night - typically 10pm start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,No - approved make/model to be installed,dom@dm.com,dom@dm.com,Ecolab,0,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,None,Approved soft,0,0,0,0,0,0,0,0'+
            '\n'+'0,hashah@coca-cola.com,papandya@coca-cola.com,'+accACN.FS_ACN__c+',Ind,Mysore,GA,234567,(904) 886-2179,Ind,Mysore,GA,234567,John,(904) 886-2179,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,dom@dm.com,9000,89,8000,21,7000,15,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 01 - Pepper/Hi-C/Pade,0,0,0,Red,23,32,0,New Construction,0,Coca-Cola Freestyle Project Team,Other,dom@dm.com,dom@dm.com,> 20%,Hide,Show,0,,0,0,Yes,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,To Go,13,dom@dm.com,Footprint (Standard),3,6:00 AM,6:30 AM,Test comments,VMS,dom@dm.com,dom@dm.com,sa,sa,as,Invoice (Payment Terms),Invoice (Payment Terms),No,0,dom@dm.com,Specific Date,2/25/2017,Day – typically 8am start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,Yes,dom@dm.com,dom@dm.com,Ecolab,0,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,None,Approved soft,0,0,0,0,0,0,0,0'+
            '\n'+'0,hashah@coca-cola.com,papandya@coca-cola.com,167345,Ind,Mysore,GA,234567,(904) 886-2179,Ind,Mysore,GA,234567,John,(904) 886-2179,QSR - Quick Serve Restaurant,Local Market / Bottler,23,Site Assessment Only (survey only) ,dom@dm.com,9000,89,8000,21,7000,15,Brandset C - Pepper/FUZE/No Pade,Brandset C - Pepper/FUZE/No Pade,Brandset 01 - Pepper/Hi-C/Pade,0,0,0,Red,23,32,0,New Construction,0,Coca-Cola Freestyle Project Team,Other,dom@dm.com,dom@dm.com,> 20%,Hide,Show,0,,0,0,Yes,0,,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,To Go,13,dom@dm.com,Footprint (Standard),3,6:00 AM,6:30 AM,0,VMS,dom@dm.com,dom@dm.com,sa,sa,as,0,0,No,Product Comments,dom@dm.com,Week of?,2/25/2017,Early AM – typically 5am or 6am start time,3/21/2017,3/21/2017,3/21/2017,3/21/2017,No,No - approved make/model to be installed,dom@dm.com,dom@dm.com,Ecolab,0,KO service provider,Top Mounted,Hoshizaki,Mo-098,Coca-Cola Freestyle Project Team,Contractor,None,Approved soft,Leave on-site,Leave on-site,Leave on-site,Leave on-site,test,test,test,test';
        
        //create Attachment
        Attachment file= new Attachment();
        //file.Body=csvFile;
        file.Body= Blob.valueof(uplFile);
        file.ContentType = contentType;
        file.parentId = holder.Id;
        file.Name='CIF WorkBook'; 
        insert file;
        controller.cifCsvFileBody= file.body;
        controller.cifCsvFileName = file.name;
        controller.getreadFromFile();
        controller.actionCopyCustomerInput();
        controller.searchOutletButton();
        controller.resetSearchStatus();
        controller.closePopup1();
        controller.showPopup2();
        controller.closePopup3();
        controller.firstPN();
        controller.lastPN();
        controller.getCIFOnNext();
        controller.getCIFOnSave();
        Boolean flag;
        flag = controller.hasNextPN;
        flag = controller.hasFirstPN;
        flag = controller.hasLastPN;
        flag = controller.hasPreviousPN;
        Integer check;
        check = controller.LNumberPN;
        check = controller.UNumberPN;
        check = controller.RecordCountPN;
        check = controller.PageNumberPN;
        check = controller.PageCountPN;
        controller.showPopup1();
        controller.closePopup2();
        controller.showPopup3();
        controller.closePopup4();
        controller.showPopup4();
        controller.closePopup5();
        controller.showPopup5();
        FSCustomerInputFormNewAndEdit cont = new FSCustomerInputFormNewAndEdit();
        String cifid = cifHead.id;
        cont.getSummaryReport(cifid);
        
     }
}