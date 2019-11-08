/********************************************************************************************************* 
Name         : FSInitiateExecutionPlanTest
Created By   : Pallavi Sharma (Appiro)
Created Date : 09 - Sep - 2013
Usage        : This class is used to cover unit test code coverage of  FSInitiateExecutionPlanExtension
***********************************************************************************************************/

@isTest
private class FSInitiateExecutionPlanTest {
    public static final String TESTVALUE='test';
    //------------------------------------------------------------------------------------------------
    // testMethod
    //------------------------------------------------------------------------------------------------
    private static testMethod void  testMethod1(){
        final Profile fetSysAdmin=FSTestFactory.getProfileId(FSConstants.systemAdmin);
        final List<Account> outletList=new List<Account>();
        //Create Headquarter Account
        final Account accHeadQtr =FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,true);
        
        //Create Outlet Account
        final Account accOutlet1 = FSTestUtil.createAccountOutlet(TESTVALUE,FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.Id, false);   
        accOutlet1.FS_ACN__c = TESTVALUE;
        accOutlet1.ShippingCity = TESTVALUE;
        accOutlet1.ShippingState = TESTVALUE;
        outletList.add(accOutlet1);
        
        //Create Outlet Account
        final Account accOutlet2 = FSTestUtil.createAccountOutlet(TESTVALUE,FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.Id, false);   
        accOutlet2.FS_ACN__c = 'test2';
        accOutlet2.ShippingCity = TESTVALUE;
        accOutlet2.ShippingState = TESTVALUE;
        outletList.add(accOutlet2);
        insert outletList;
        
        Test.startTest();
        final Pagereference pageRef = Page.FSInitiateExecutionPlan ;
        Test.setCurrentPage(pageRef);
        //Initialize Page paramteres
        pageRef.getParameters().put('id', accHeadQtr.Id);
        final User fetSysAdminUser=FSTestFactory.createUser(fetSysAdmin.id);
        insert fetSysAdminUser;
        system.runAs(fetSysAdminUser){
            final apexpages.Standardcontroller standCon = new apexpages.Standardcontroller(accHeadQtr);
            final FSInitiateExecutionPlanExtension objController = new FSInitiateExecutionPlanExtension(standCon);
            
            // Search Functionality
            objController.searchOutletName = TESTVALUE;
            objController.searchOutletACN = TESTVALUE;
            objController.searchOutletCity = TESTVALUE;
            objController.searchOutletState = TESTVALUE;
            objController.searchOutlet();
            
            objController.resetSearchStatus();
            
            final Integer totalPages = objController.totalPages;
            final Integer noOfRecords = objController.noOfRecords;
            final Integer pageNumber = objController.pageNumber;
            final Boolean hasPrevious = objController.hasPrevious;
            final Boolean hasNext = objController.hasNext;
            system.assertNotEquals(totalPages,null);
            system.assertNotEquals(noOfRecords,null);
            system.assertNotEquals(pageNumber,null);
            system.assert(!hasPrevious);
            system.assert(!hasNext);
            System.assertEquals(objController.first(), null);
            System.assertEquals(objController.last(), null);
            System.assertEquals(objController.previous(), null);
            System.assertEquals(objController.next(), null);
            objController.sortData();
            
            // Outlet Selection Functinoality
            for(FSInitiateExecutionPlanExtension.OutletWrapper ow : objController.outletList) {
                ow.isChecked = true;
            }
            objController.searchOutlet();       
            //Set of outletIds
            final Set<Id> setOutletId = new Set<Id>();
            for(FSInitiateExecutionPlanExtension.OutletWrapper outAcc : objController.outletList){
                setOutletId.add(outAcc.outlet.Id);
            }       
            objController.Next();
            objController.Previous();        
            system.debug('Page size'+ objController.pageSize);        
            objController.finish();
        }
        Test.stopTest();
    }
}