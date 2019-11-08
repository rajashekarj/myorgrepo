/**
 * Class containing tests for AllTabsnObjects
 */
@isTest(seeAllData=false)
private class AllTabsnObjectsTest
{

 private static testMethod void AllTabsnObjectsTest()
{

Test.startTest();
AllTabsnObjects  allto = new AllTabsnObjects();
Map<String, Map<String,Map<String,String>>>  map1 = new Map<String, Map<String,Map<String,String>>>();
PageReference page1 = allto.Export();
map1 = allto.myMap; 
Test.stopTest();

}
}