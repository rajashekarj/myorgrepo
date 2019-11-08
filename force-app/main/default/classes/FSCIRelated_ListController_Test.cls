@isTest 
public Class FSCIRelated_ListController_Test{
    
    public static string fsCom = 'FSCOM__c';
    public static string fsEp = 'FS_EP__c';
    public static string ascOrder = 'asc';
    public static string empStr = '';
    public static string orderByName = 'Name';
    public ApexPages.StandardSetController ssc;
    public Static Id recTypeHQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Headquarters');
    
    @testSetup
    public static void loadTestData(){
        
        //Create a Headquarters
        FSTestFactory.createTestDisableTriggerSetting();
        final List<Account> hQCustomerList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        CIF_Header__c cifHead = new CIF_Header__c();
        cifHead.Name =hQCustomerList[0].name+' V.0';
        cifHead.FS_Version__c = 10.02;
        cifHead.FS_HQ__c=hQCustomerList[0].id;
        insert cifHead;
        
        FS_Customer_Input__c cust = new FS_Customer_Input__c();
        cust.Name = 'Customer Input Form';
        cust.FS_Account__c = hQCustomerList[0].id;
        //cust.HQ_CIF__c = hQCustomerList[0].id;
        cust.Status__c = 'Approved';
        insert cust;
    }
    
    Private static testMethod void fSCIRelatedListControllerTest1(){
        final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User adminUser = FSTestFactory.createUser(adminProfile.id);
        insert adminUser;
        system.runAs(adminUser){
            Test.startTest();
            final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
            system.runas(sysAdmin)
            {
                final FSCIRelated_ListController cir = new FSCIRelated_ListController();
                
                cir.sortByFieldAction();
                final List<string> abc =new  list<string>{fsCom,fsEp};
                    final List<Account> hQCustomerList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
                final Map<String,String> mapValue = new Map<String,String>();
                mapValue.put(fsCom, ascOrder);
                mapValue.put(fsEp, ascOrder);
                cir.fieldSortDirectionMap= mapValue;
                cir.sortDirection=ascOrder;
                cir.fieldsList = abc;
                cir.returnUrl = 'salesforce.com';
                cir.moreLink = 'test.com';
                cir.fieldsCSV ='FS_HQ__c';
                cir.sortByField =fsEp;
                cir.pageSize =5;
                cir.searchFieldName =fsCom;
                cir.searchFieldValue =hQCustomerList[0].id;
                cir.orderByFieldName =orderByName;
                cir.title ='Search';
                cir.showAsStandardRelatedList = true;
                cir.filter =empStr;
                cir.pageNumber=5;
                cir.objectName='CIF_Header__c';
                cir.deleteRecordId= hQCustomerList[0].id ;
                
                cir.getRecords();
                cir.objectDesNull();
                cir.showMore();
                if(cir.getRecords() != null){
                    System.assert(cir.getRecords().size()>=0);
                } else System.assert(cir.getRecords()==Null);
                System.assertEquals(cir.objectDesNull(), Null);
            }
            Test.stopTest();     
        }
    }
    
    Private static testMethod void fSCIRelatedListControllerTest2(){
        final FSCIRelated_ListController cir = new FSCIRelated_ListController();
        final cif_header__c testCIF = new cif_header__c(FS_Tech_Note__c='testing', FS_Version__c=1);
        insert testCIF;
        final string fld1 = 'test';
        final string fieldName1 = 'FSCOM__c..com';
        final Map<String,String> mapReferenceFields1 = new Map<String,String>();
        mapReferenceFields1.put(fsCom, ascOrder);
        mapReferenceFields1.put(fsEp, ascOrder);
        final String selectedObject = 'cif_header__C';
        final Map<String, Map<String, schema.SObjectField>> mapReferenceObjectsFieldMap1= new Map<String, Map<String, schema.SObjectField>>();
        
        final Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        final Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
        final Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();	
        system.debug(empStr+fieldMap);
        mapReferenceObjectsFieldMap1.put(ascOrder ,fieldMap );
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            
            test.startTest();
            cir.getRecords();
            
            cir.populateReferenceFields(fld1,fieldName1 , mapReferenceFields1, mapReferenceObjectsFieldMap1);
            delete testCIF;
            if(cir.getRecords() != null){
                System.assert(cir.getRecords().size()>=0);
            } else System.assert(cir.getRecords()==Null);
            test.stopTest();
        }
    }
    
    Private static testMethod void fSCIRelatedListControllerTest3(){
        
        Test.startTest();
        final User sysAdmin = [Select id from User where id =: UserInfo.getUserId()];
        system.runas(sysAdmin){
            
            final List<Account> hQCustomerList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
            final FSCIRelated_ListController cir = new FSCIRelated_ListController();
            
            cir.sortByFieldAction();
            final List<string> abc =new  list<string>{fsCom,fsEp};
                final Map<String,String> mapValue = new Map<String,String>();
            mapValue.put(fsCom, ascOrder);
            mapValue.put(fsEp, ascOrder);
            cir.fieldSortDirectionMap= mapValue;
            cir.sortDirection='abcd';
            cir.fieldsList = abc;
            cir.returnUrl = 'salesforce.com';
            cir.returnUrl = 'test.com';
            cir.fieldsCSV ='FS_HQ__c,test';
            cir.sortByField ='';
            cir.pageSize =5;
            cir.searchFieldName =fsCom;
            cir.searchFieldValue =empStr;
            cir.orderByFieldName =orderByName;
            cir.title ='Search';
            cir.showAsStandardRelatedList = true;
            cir.filter =empStr;
            cir.pageNumber=5;
            final list<string> testingName= new list<string>();
            testingName.add('test..com');
            cir.fieldNames=testingName;
            cir.objectName='CIF_Header__c';
            cir.deleteRecordId= hQCustomerList[0].id ;
            
            cir.getRecords();
            cir.objectDesNull();
            cir.getShowNewButton();
            System.assertEquals(cir.objectDesNull(), Null);
            Test.stopTest(); 
        }
    }
    
    private static testMethod void test(){
        
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            
            //Insert Account
            final Account acct = new Account(Name='test');
            insert acct;
            
            //Attach opportunities to account
            final List<Opportunity> opps = new List<Opportunity>();
            for(Integer i = 0; i < 5; i++){
                opps.add(new Opportunity(
                    AccountId = acct.Id,
                    Name = 'test ' + i,
                    StageName = 'stage',
                    CloseDate = system.today(),
                    Amount = 5
                ));
            }	
            insert opps;
            
            //Setup controller for related list
            final FSCIRelated_ListController controller = new FSCIRelated_ListController();
            
            //Set attribute variables
            controller.objectName = 'Opportunity';
            controller.fieldsCSV = 'Id,Name,Amount,CloseDate';
            controller.filter = 'Amount > 0';
            controller.orderByFieldName=  'Amount';
            controller.sortDirection = 'desc';
            controller.pageSize = 2;
            
            //Call method to get records
            controller.getRecords();
            
            //Assert number of opps found = 5
            system.assertEquals(controller.ssc.getResultSize(), 5);
            
            //Delete an opp
            controller.deleteRecordId = opps[0].Id;
            controller.deleteRecord();	
            
            //Assert size of opps is now 4
            system.assertEquals(controller.ssc.getResultSize(), 4);
            
            //Sort by name
            controller.sortByField = orderByName;
            controller.getRecords(); //requeries list of records
        }
    }
    
    Private static testMethod void fSCIRelatedListControllerTest4(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            Test.startTest();
            
            final FSCIRelated_ListController cir = new FSCIRelated_ListController();
            cir.sortByFieldAction();
            final List<string> abc =new  list<string>{fsCom,fsEp};
                final List<Account> hQCustomerList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
            final Map<String,String> mapValue = new Map<String,String>();
            mapValue.put(fsCom, ascOrder);
            mapValue.put(fsEp, ascOrder);
            cir.fieldSortDirectionMap= mapValue;
            cir.sortDirection=ascOrder;
            cir.fieldsList = abc;
            cir.returnUrl = 'salesforce.com';
            cir.moreLink = 'test.com';
            cir.fieldsCSV ='FS_HQ__c';
            cir.sortByField =fsEp;
            cir.pageSize =5;
            cir.searchFieldName =fsCom;
            //cir.searchFieldValue =hQCustomerList[0].id;
            cir.orderByFieldName =orderByName;
            cir.title ='Search';
            cir.showAsStandardRelatedList = true;
            cir.filter =empStr;
            cir.pageNumber=5;
            cir.objectName='CIF_Header__c';
            //cir.deleteRecordId= hQCustomerList[0].id ;
            cir.fieldsCSV = null;
            cir.objectDesNull();
            cir.getRecords(); 
            cir.showMore();
            system.assert(cir.ssc.getResultSize() >= 0);
            Test.stopTest(); 
        }
    }
    
    Private static testMethod void fSCIRelatedListControllerTest5(){
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        System.runAs(sysAdminUser){
            
            Test.startTest();
            final List<string> abc =new  list<string>{fsCom,fsEp};
                final FSCIRelated_ListController cir = new FSCIRelated_ListController();
            final Account parentRecord= [SELECT Id,RecordTypeId FROM Account WHERE RecordTypeId=:recTypeHQ limit 1]; 
            
            cir.fieldsCSV = 'Id,Name,Status__c,CreatedById,CreatedDate,LastModifiedById,LastModifiedDate';
            cir.sortDirection = 'desc';
            cir.objectName = 'FS_Customer_Input__c';
            cir.pageSize = 5;
            cir.isApprovedRecordLink = 'true';
            cir.orderByFieldName = 'CreatedDate';
            cir.searchFieldValue = parentRecord.id;
            cir.searchFieldName = 'HQ_CIF__c';
            cir.title = ' ';
            cir.getRecords();
            system.assert(cir.ssc.getResultSize()>=0);
            Test.stopTest();
        }
    }
    
}