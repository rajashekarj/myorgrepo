/*********************************************************************************************************
Name         : FSDynamicWrapperPaginatorTest
Created By   : Infosys Limited 
Created Date : 5-April-2017
Usage        : Test class for DynamicWrapperPaginator.

***********************************************************************************************************/
@isTest
private class FSDynamicWrapperPaginatorTest{
 
 //test data of Object type
 public static List<Object> wrapperCollection(){
   //create wrapper collection
   List<Object> collectionToPaginate=new List<Object>();
   for(Integer i=0;i<50;i++){
      collectionToPaginate.add(i);
   }
   return collectionToPaginate;
 }
 
 //Method to test on Page load on collection (with records) to paginate
 public static testMethod void testWrapperCollectionPagination1(){
   
     List<Object> collectionAfterPagination=new List<Object>();
     
     FSDynamicWrapperPaginator paginator=new FSDynamicWrapperPaginator(wrapperCollection());
     paginator.pageNum=30;
     final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
     final User adminUser = FSTestFactory.createUser(adminProfile.id);
     insert adminUser;
     system.runAs(adminUser){
         Test.startTest();
         collectionAfterPagination=paginator.populateResults();
         paginator.getDisablePrevious();
         paginator.getDisableNext();
         
         system.assertEquals(50,paginator.getTotalResultsize());
         system.assertEquals(2,paginator.getTotalPages());
         system.assertEquals(1,paginator.getPageNumber());
         Test.stopTest();
     }
 }
 
 //Method to test Previous and Next actions  on collection (with records) to paginate
 public static testMethod void testWrapperCollectionPagination2(){
   
     List<Object> collectionAfterPagination=new List<Object>();
     
     FSDynamicWrapperPaginator paginator=new FSDynamicWrapperPaginator(wrapperCollection());
     paginator.pageNum=30;
     
     final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
     final User adminUser = FSTestFactory.createUser(adminProfile.id);
     insert adminUser;
     system.runAs(adminUser){
         Test.startTest();
         collectionAfterPagination=paginator.populateResults();
         paginator.getDisablePrevious();
         paginator.getDisableNext();
         
         system.assertEquals(50,paginator.getTotalResultsize());
         system.assertEquals(2,paginator.getTotalPages());
         system.assertEquals(1,paginator.getPageNumber());
         
         paginator.Next();
         system.assertEquals(2,paginator.getPageNumber());
         
         paginator.getDisablePrevious();
         paginator.getDisableNext();
         
         paginator.Previous();
         system.assertEquals(1,paginator.getPageNumber());
         
         paginator.getDisablePrevious();
         paginator.getDisableNext();
         
         Test.stopTest();
     }
 }
 
 //Method to test First and Last actions  on collection (with records) to paginate
 public static testMethod void testWrapperCollectionPagination3(){
   
     List<Object> collectionAfterPagination=new List<Object>();
     
     FSDynamicWrapperPaginator paginator=new FSDynamicWrapperPaginator(wrapperCollection());
     paginator.pageNum=30;
     
     final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
     final User adminUser = FSTestFactory.createUser(adminProfile.id);
     insert adminUser;
     system.runAs(adminUser){
         Test.startTest();
         collectionAfterPagination=paginator.populateResults();
         paginator.getDisablePrevious();
         paginator.getDisableNext();
         
         system.assertEquals(50,paginator.getTotalResultsize());
         system.assertEquals(2,paginator.getTotalPages());
         system.assertEquals(1,paginator.getPageNumber());
         
         paginator.Last();
         system.assertEquals(2,paginator.getPageNumber());
         
         paginator.getDisablePrevious();
         paginator.getDisableNext();
         
         paginator.First();
         system.assertEquals(1,paginator.getPageNumber());
         
         paginator.getDisablePrevious();
         paginator.getDisableNext();
         
         Test.stopTest();
     }
 }
 
 //Method to test on page load  on collection (without records) to paginate
 public static testMethod void testWrapperCollectionPagination4(){
   
     List<Object> collectionAfterPagination=new List<Object>();
     
     FSDynamicWrapperPaginator paginator=new FSDynamicWrapperPaginator(new List<Object>());
     paginator.pageNum=30;
     
     final Profile adminProfile = FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
     final User adminUser = FSTestFactory.createUser(adminProfile.id);
     insert adminUser;
     system.runAs(adminUser){
         Test.startTest();
         collectionAfterPagination=paginator.populateResults();
         paginator.getDisablePrevious();
         paginator.getDisableNext();
         
         system.assertEquals(0,paginator.getTotalResultsize());
         system.assertEquals(0,paginator.getTotalPages());
         system.assertEquals(0,paginator.getPageNumber());
         
         
         Test.stopTest();
     }
 }
}