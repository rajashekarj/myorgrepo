//
// (c) 2014 Appirio, Inc.
//
// Handler Class for trigger FSSellingActivity
//
// January 7th, 2015   Sidhant Agarwal     Ref No. I-144960
//
public with sharing class FSSellingActivityHandler {
    // @description: Popping up an error if no ICV record found with status Published
    // @param: Map of Old Values of Selling Activity records
    // @param: Map of New Values of Selling Activity records
    // @return: Inserts the created date & created by values
    public static  void createdDateAndBy(Map<Id,Selling_Activity__c> oldSellingActivityMap , Map<Id,Selling_Activity__c> newSellingActivityMap){
    List<Selling_Activity__c> listofSellingActivity = new  List<Selling_Activity__c> ();
    for(String oldVersionId : oldSellingActivityMap.keySet()){
        if( oldSellingActivityMap.get(oldVersionId).FS_Of_Outlets_For_Launch__c != newSellingActivityMap.get(oldVersionId).FS_Of_Outlets_For_Launch__c 
                   || oldSellingActivityMap.get(oldVersionId).Disp_Configuration__c != newSellingActivityMap.get(oldVersionId).Disp_Configuration__c
                   || oldSellingActivityMap.get(oldVersionId).Selling_Status__c != newSellingActivityMap.get(oldVersionId).Selling_Status__c
                   || oldSellingActivityMap.get(oldVersionId).Average_Dispenser__c != newSellingActivityMap.get(oldVersionId).Average_Dispenser__c) {
            
            newSellingActivityMap.get(oldVersionId).Changed_On__c = system.today();
            system.debug('Changed On Date'+newSellingActivityMap.get(oldVersionId).Changed_On__c);
            system.debug('Changed On Datesystem.today()'+ System.now());
            newSellingActivityMap.get(oldVersionId).Changed_By__c = UserInfo.getUserId();
            system.debug('Changed By user'+newSellingActivityMap.get(oldVersionId).Changed_By__c);
            system.debug('Changed By userUserInfo.getUserId()'+UserInfo.getUserId());
        }
    }
  }
}