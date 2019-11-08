public with sharing class FSCreateSellingActivityExtension {

    public String accountId;
    public List<SellingActivityWrapper> sellingActivityList {get; set;}
    public List<SelectOption> dispenserOptions { get; set; }
    public List<SelectOption> marketOptions { get; set; }
    public String dispenserVal {get; set;}
    public String marketVal {get; set;}
    public String header1 {get; set;}
    Public String Dispenservalue{get;set;}
    public String recordIndex {get; set;}
    public List<SelectOption> selectedFields { get; set; }
    public List<SelectOption> avaliableFields { get; set; }
    public List<SelectOption> allFields { get; set; }
    public List<Selling_Activity__c> recordListToDelete;
    Boolean isEdit;
    public String searchStr{get;set;}
    public String debugSoql{get;set;}
    public TotalCountOfFieldsValue totalValue {get; set;}
    //I-144945,I-144987
    public static final String MOVE_MSG = 'Please move atleast one available market in the selected markets box';
    public static final String Query_Limit_MSG = 'There are more than 1000 records. Please refine your search. ';

    public FSCreateSellingActivityExtension(Apexpages.Standardcontroller stndCntrl){
        debugSoql = '';
        accountId = Apexpages.currentPage().getParameters().get(Label.FS_Selling_Acitvitys_Account_ID);
        sellingActivityList = new List<SellingActivityWrapper>();
        recordListToDelete = new List<Selling_Activity__c>();
        dispenserOptions = new List<SelectOption>{new SelectOption('','--None--')};
        marketOptions = new List<SelectOption>{new SelectOption('','--None--')};
        isEdit = false;
        init();

        Schema.sObjectType objType2 = Selling_Activity_Market__c.getSObjectType();
        Schema.DescribeSObjectResult objDescribe2 = objType2.getDescribe();
        map<String, Schema.SObjectField> fieldMap2 = objDescribe2.fields.getMap();
        dispenserOptions.addAll(getPicklistValues(fieldMap2,'Dispenser_Model__c'));
        if(accountId != null && accountId != '') {
            fetchData();
        }

        setTotal();
        if(sellingActivityList.size() > 0){
            isEdit = true;
        }
    }

    private void fetchData(){
        for(Selling_Activity__c sellingActObj : [SELECT Market_Name__c, Market_Name__r.Market_Activation_Date__c, FS_Of_Outlets_For_Launch__c,
                                                        Disp_Configuration__c, Average_Dispenser__c, FS_Headquarter__c, Selling_Status__c,
                                                        Requested_Accelerated_Market_Activation__c, Comment__c, Id, Market_Name__r.Name ,
                                                        Created_On__c, Created_By__c, Changed_On__c, Changed_By__c, FS_Of_Dispensers_Sub_Total_Per_Market__c
                                                        FROM Selling_Activity__c
                                                        WHERE FS_Headquarter__c =: accountId]){
                // selectedFields.add(new SelectOption(Market_Name__c, Market_Name__r.Name));
                SellingActivityWrapper sellingActWrapper = new SellingActivityWrapper(sellingActObj);
                sellingActWrapper.marketActDate = sellingActObj.Market_Name__r.Market_Activation_Date__c;
                if(sellingActWrapper.sellingActivity.Selling_Status__c == 'Activity moved to Installation Process'){
                    sellingActWrapper.isLocked = true;
                }
                sellingActWrapper.isUpdate = true;
                sellingActivityList.add(sellingActWrapper);
            }
    }
    
    private void init(){
        totalValue = new TotalCountOfFieldsValue();
        setTotal();
        selectedFields = new List<SelectOption>();
        allFields = new List<SelectOption>();
        avaliableFields = new List<SelectOption>();
    }


    public void populateMarket(){
        allFields.clear();
        avaliableFields.clear();
        selectedFields.clear();
        for(Selling_Activity_Market__c sellingMarket : [SELECT Id, Name from Selling_Activity_Market__c
                                                            WHERE Name != null AND Dispenser_Model__c =:dispenserVal]){
            marketOptions.add(new SelectOption(sellingMarket.Id, sellingMarket.Name));
            allFields.add(new SelectOption(sellingMarket.Id, sellingMarket.Name));
            avaliableFields.add(new SelectOption(sellingMarket.Id, sellingMarket.Name));
        }
    }


  // runs the actual query
  public void runQuery(String soql) {
    //I-144945 - modifications
    if(dispenserVal != '' && dispenserVal != null) {
        soql = soql+' AND Dispenser_Model__c = :dispenserVal ';
    }
    //I-144945 - end
    debugSoql = soql;
    try {
        List<Selling_Activity_Market__c> sellingActMarket = new List<Selling_Activity_Market__c>();
        if(dispenserVal != null || searchStr != '') {
            sellingActMarket = Database.query(soql );
            //I-144987 - Added If loop
            if(sellingActMarket.size() > 999){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info , Query_Limit_MSG);
                ApexPages.addMessage(msg);
            }
        }
       for(Selling_Activity_Market__c sellingMarket : sellingActMarket){
            marketOptions.add(new SelectOption(sellingMarket.Id, sellingMarket.Name));
            allFields.add(new SelectOption(sellingMarket.Id, sellingMarket.Name));
            avaliableFields.add(new SelectOption(sellingMarket.Id, sellingMarket.Name));
        }
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
    }

  }

    // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
    allFields.clear();
    avaliableFields.clear();
    //selectedFields.clear();
    String firstName = Apexpages.currentPage().getParameters().get('firstname');
    searchStr = firstName;
    String soql = 'SELECT Id, Name FROM Selling_Activity_Market__c WHERE Name != null';
    if (firstName != null && !firstName.equals('') && firstName.length() >= 2) {
         // soql += ' and firstname LIKE ''+String.escapeSingleQuotes(firstName)+'%'';
         soql += ' and Name LIKE \''+String.escapeSingleQuotes(firstName)+'%\'';
        // run the query again
    }
    runQuery(soql);

    return null;
  }

    public Pagereference addMarket(){
    
        if(dispenserVal == null){
        ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR , 'Please select the Dispenser Model value');
          ApexPages.addMessage(msg1);
            
        }
        
        //I-144945 - Added If loop
        
        else if(selectedFields.size() <= 0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , MOVE_MSG);
            ApexPages.addMessage(msg);
            return null;
        }
        if(marketVal != null && marketVal != ''){
            Selling_Activity_Market__c sellingMarketObj;
            for(Selling_Activity_Market__c sellingMarket : [SELECT Id, Name, Market_Activation_Date__c from Selling_Activity_Market__c
                                                            WHERE Id =:marketVal]){
                sellingMarketObj = sellingMarket;
            }
            SellingActivityWrapper sellingActWrapper = new SellingActivityWrapper(new Selling_Activity__c(FS_Headquarter__c = accountId));
            sellingActWrapper.sellingActivity.Market_Name__c = marketVal;
            sellingActWrapper.marketActDate = sellingMarketObj.Market_Activation_Date__c;
            sellingActivityList.add(sellingActWrapper);
        }
        if(selectedFields.size() > 0){
            Set<Id> marketIdSet = new Set<Id>();
            for(SelectOption selectedOpt : selectedFields){
                marketIdSet.add(selectedOpt.getValue());
            }
            for(Selling_Activity_Market__c sellingMarket : [SELECT Id, Name, Market_Activation_Date__c from Selling_Activity_Market__c
                                                            WHERE Id IN: marketIdSet])
            {
                SellingActivityWrapper sellingActWrapper = new SellingActivityWrapper(new Selling_Activity__c(FS_Headquarter__c = accountId));
                sellingActWrapper.sellingActivity.Market_Name__c = sellingMarket.Id;
                sellingActWrapper.marketActDate = sellingMarket.Market_Activation_Date__c;
                sellingActivityList.add(sellingActWrapper);
            }
            isEdit = false;
        }
        return null;
    }


    private static list<SelectOption> getPicklistValues(map<String, Schema.SObjectField> fieldMap,String fld){
        List<SelectOption> options = new List<SelectOption>();
       // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =
          fieldMap.get(fld).getDescribe().getPickListValues();
       // Add these values to the selectoption list.

        for (Schema.PicklistEntry a : values){
            options.add(new SelectOption(a.getLabel(), a.getLabel()));
        }
        return options;
    }


    public void saveRecord(){
        Boolean isSuccess = validateSellingActivity();
        if(isSuccess) {
            accountId = Apexpages.currentPage().getParameters().get(Label.FS_Selling_Acitvitys_Account_ID);
            sellingActivityList = new List<SellingActivityWrapper>();
            
            if(accountId != null && accountId != '') {
                fetchData();
            }
        }
    }

    public Boolean validateSellingActivity() {
        setTotal();
        if(dispenserVal == null && !isEdit){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,
                                        'Please select the Dispenser Model value'));
            return false;
        }
        /*if(marketVal == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,
                                        'Please select the Available Market'));
            return null;
        }*/
        List<Selling_Activity__c> sellingActivityRecordToInsert = new List<Selling_Activity__c>();
        
         for(SellingActivityWrapper sellingActWrapper : sellingActivityList){
        for(Selling_Activity_Market__c sam:[Select Dispenser_Model__c from Selling_Activity_Market__c Where id=:sellingActWrapper.sellingActivity.Market_Name__c])
        {
        Dispenservalue =sam.Dispenser_Model__c;
        }
        }
    
        for(SellingActivityWrapper sellingActWrapper : sellingActivityList){
            sellingActWrapper.sellingActivity.FS_Headquarter__c = accountId;
            if(sellingActWrapper.sellingActivity.Market_Name__c != null && (dispenserVal != null || isEdit)){
                if(sellingActWrapper.sellingActivity.FS_Of_Outlets_For_Launch__c != null &&
                    sellingActWrapper.sellingActivity.Average_Dispenser__c != null &&
                    sellingActWrapper.sellingActivity.Disp_Configuration__c != null &&
                    sellingActWrapper.sellingActivity.Selling_Status__c != null )
                {
                    if(sellingActWrapper.sellingActivity.Created_On__c == null && Dispenservalue != null){
                        sellingActWrapper.sellingActivity.Dispenser_Model__c = Dispenservalue;
                        sellingActWrapper.sellingActivity.Created_On__c = system.today();
                        sellingActWrapper.sellingActivity.Created_By__c =  UserInfo.getUserId() ;
                    }/*I-144960;
                    else{
                        sellingActWrapper.sellingActivity.Changed_On__c = system.today();
                        sellingActWrapper.sellingActivity.Changed_By__c = UserInfo.getUserId() ;
                    }*/
                    sellingActivityRecordToInsert.add(sellingActWrapper.sellingActivity);
                }else {
                    if(sellingActWrapper.sellingActivity.FS_Of_Outlets_For_Launch__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,
                            'Please enter data for # of Outlet for launch field where market have been selected'));
                        return false;
                    }
                    if(sellingActWrapper.sellingActivity.Average_Dispenser__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,
                            'Please enter data for Average Dispenser field where market have been selected'));
                        return false;
                    }
                    if(sellingActWrapper.sellingActivity.Disp_Configuration__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,
                            'Please enter data for Disp Configuration field where market have been selected'));
                        return false;
                    }
                    if(sellingActWrapper.sellingActivity.Selling_Status__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR ,
                             'Please enter data for Selling Status field where market have been selected'));
                        return false;
                    }
                }
            }
        }
        if(sellingActivityRecordToInsert.size() > 0 ){
            try{
                upsert sellingActivityRecordToInsert;
                System.debug('===sellingActivityRecordToInser===' + sellingActivityRecordToInsert);
            }catch(Exception ex){
               return false;
            }
        }
        if(recordListToDelete.size() > 0 ){
            delete recordListToDelete;
            recordListToDelete.clear();
        }
        return true;
    }

    public PageReference saveCloseRecord(){
        Boolean isSuccess = validateSellingActivity();
        if(isSuccess){
            return new PageReference('/'+accountId);
        }else{
            return null;
        }
    }


    public void deleteRecord(){
        Integer tempIndex = Integer.valueOf(recordIndex.substring(0, recordIndex.indexOf('.')));
        SellingActivityWrapper sellingActObjToDel = sellingActivityList.remove(tempIndex);
        if(sellingActObjToDel.sellingActivity.Id != null){
            //delete sellingActObjToDel.sellingActivity;
            recordListToDelete.add(sellingActObjToDel.sellingActivity);
        }
    }


    public PageReference cancelRecord(){
        return new PageReference('/'+accountId);
    }


    public void setTotal(){
        totalValue.totalLaunch = 0.0;
        totalValue.totalDispenser = 0.0;
        totalValue.totalMarket = 0.0;
        if(sellingActivityList.size() != null){
                totalValue.totalMarket += sellingActivityList.size();
        }
        for(SellingActivityWrapper sellingActObj : sellingActivityList){
            if(sellingActObj.sellingActivity.FS_Of_Outlets_For_Launch__c != null){
                totalValue.totalLaunch += sellingActObj.sellingActivity.FS_Of_Outlets_For_Launch__c;
            }
            if(sellingActObj.sellingActivity.FS_Of_Dispensers_Sub_Total_Per_Market__c != null){
                totalValue.totalDispenser += sellingActObj.sellingActivity.FS_Of_Dispensers_Sub_Total_Per_Market__c;
            }
        }
        system.debug('totalValue.totalLaunch'+totalValue.totalLaunch);
        system.debug('totalValue.totalDispenser'+totalValue.totalDispenser);
        system.debug('totalValue.totalMarket'+totalValue.totalMarket);
    }


    public class SellingActivityWrapper {
        public Selling_Activity__c sellingActivity {get; set;}
        public boolean isLocked {get; set;}
        public Date marketActDate {get; set;}
        public Boolean isUpdate {get; set;}

        public SellingActivityWrapper(Selling_Activity__c sellingActivityObj){
            sellingActivity = sellingActivityObj;
            isLocked = false;
            isUpdate = false;
        }
    }


    public class TotalCountOfFieldsValue {
        public Decimal totalLaunch {get; set;}
        public Decimal totalDispenser {get; set;}
        public Decimal totalMarket {get; set;}
    }
}