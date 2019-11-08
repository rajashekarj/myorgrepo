@isTest
private class FSCreateSellingActivityExtension_Test{    
    
    static testMethod void testPageControllerFunctionality(){
        Account accHeadQtr1 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        String soql = 'SELECT Id, Name FROM Selling_Activity_Market__c WHERE Name != null';
        Selling_Activity_Market__c marketActivityObject = new Selling_Activity_Market__c();
        marketActivityObject.Name='test';
        marketActivityObject.Dispenser_Model__c='7000';
        marketActivityObject.Market_Activation_Date__c = System.today().addDays(4);
        insert marketActivityObject;
        Selling_Activity__c activityObject=new Selling_Activity__c();
        activityObject.Market_Name__c = marketActivityObject.Id;
        activityObject.FS_Of_Outlets_For_Launch__c=10;
        activityObject.Disp_Configuration__c='Extended Splash plate no legs';
        activityObject.Average_Dispenser__c = 10;
        activityObject.FS_Headquarter__c=accHeadQtr1.Id;
        activityObject.Selling_Status__c='Pre-sold';
        activityObject.Requested_Accelerated_Market_Activation__c=System.today().addDays(2);
        insert activityObject;
        List<SelectOption> myList=new List<SelectOption>();
        myList.add(new SelectOption(activityObject.Market_Name__c, marketActivityObject.Name));
        Test.startTest();
        Apexpages.Standardcontroller stdCntrl = new Apexpages.Standardcontroller(activityObject);
        Apexpages.currentPage().getParameters().put('CF00Ne0000001CjE5_lkid', accHeadQtr1.Id);
        Apexpages.currentPage().getParameters().put(Label.FS_Selling_Acitvitys_Account_ID, accHeadQtr1.Id);
        
        Apexpages.currentPage().getParameters().put('firstname',marketActivityObject.Name);
        
        FSCreateSellingActivityExtension controller = new FSCreateSellingActivityExtension(stdCntrl);
        controller.dispenserVal='7000';
		controller.marketVal=marketActivityObject.Id;
        controller.populateMarket();
        controller.selectedFields=myList;
        controller.addMarket();
        controller.saveRecord();
        PageReference pr=controller.saveCloseRecord();
        //System.assert(pr!=null);
        
        controller.recordIndex='0.';
       controller.deleteRecord();
        pr=controller.cancelRecord();
        System.assert(pr!=null);

        Test.stopTest();
    }
    
    static testMethod void testCreateSellingActivity(){
        Account accHeadQtr1 = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        String soql = 'SELECT Id, Name FROM Selling_Activity_Market__c WHERE Name != null';
        Selling_Activity_Market__c marketActivityObject = new Selling_Activity_Market__c();
        marketActivityObject.Name='test';
        marketActivityObject.Dispenser_Model__c='7000';
        marketActivityObject.Market_Activation_Date__c = System.today().addDays(4);
        insert marketActivityObject;
        Selling_Activity__c activityObject=new Selling_Activity__c();
        activityObject.Market_Name__c = marketActivityObject.Id;
        activityObject.FS_Of_Outlets_For_Launch__c=10;
        activityObject.Disp_Configuration__c='Extended Splash plate no legs';
        activityObject.Average_Dispenser__c = null;
        activityObject.FS_Headquarter__c=accHeadQtr1.Id;
        activityObject.Selling_Status__c='Pre-sold';
        activityObject.Requested_Accelerated_Market_Activation__c=System.today().addDays(2);
        insert activityObject;
        List<SelectOption> myList=new List<SelectOption>();
        myList.add(new SelectOption(activityObject.Market_Name__c, marketActivityObject.Name));
        Test.startTest();
        Apexpages.Standardcontroller stdCntrl = new Apexpages.Standardcontroller(activityObject);
        Apexpages.currentPage().getParameters().put('CF00Ne0000001CjE5_lkid', accHeadQtr1.Id);
        Apexpages.currentPage().getParameters().put(Label.FS_Selling_Acitvitys_Account_ID, accHeadQtr1.Id);
        
        Apexpages.currentPage().getParameters().put('firstname',marketActivityObject.Name);
        
        FSCreateSellingActivityExtension controller = new FSCreateSellingActivityExtension(stdCntrl);
        controller.dispenserVal='7000';
        controller.marketVal=marketActivityObject.Id;

        Boolean isValid = controller.validateSellingActivity();
        
        activityObject.Disp_Configuration__c=null;
        activityObject.Average_Dispenser__c = 10;
        
        update activityObject;
        stdCntrl = new Apexpages.Standardcontroller(activityObject);
        
        controller = new FSCreateSellingActivityExtension(stdCntrl);
        controller.dispenserVal='7000';
        controller.marketVal=marketActivityObject.Id;
        
        isValid = controller.validateSellingActivity();
        
        activityObject.Selling_Status__c=null;
        activityObject.Disp_Configuration__c='Extended Splash plate no legs';
        
        update activityObject;
        stdCntrl = new Apexpages.Standardcontroller(activityObject);
        
        controller = new FSCreateSellingActivityExtension(stdCntrl);
        controller.dispenserVal='7000';
        controller.marketVal=marketActivityObject.Id;
        
        isValid = controller.validateSellingActivity();        
        
        controller.runQuery(soql);
        System.assertNotEquals(controller.marketOptions.size(),0);
        System.assertNotEquals(controller.allFields.size(),0);
        System.assertNotEquals(controller.avaliableFields.size(),0);
        
        Pagereference pr = controller.runSearch();
        System.assertEquals(null, pr);
        
        
        
        Test.stopTest();
    }
}