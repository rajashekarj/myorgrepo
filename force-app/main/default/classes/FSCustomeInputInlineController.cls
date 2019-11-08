/******************************* 
//Created By   : Vandana Kumari (Appiro JDC)
Date         : Oct 08th, 2014
Modified By  : Vandana Kumari 20th October, 2014 Ref - T-326930 :Should not be able to create CIF at the HQ level without entering a Primary contact
*************************/


public with sharing class FSCustomeInputInlineController {
  
 public Account account;
  public String PageUrl{get;set;}
  
  public FSCustomeInputInlineController(final ApexPages.StandardController controller){
    account = (Account)controller.getRecord();
    PageUrl = FSConstants.STR_NULL;
  }
  
  public pagereference createNewCustomerInput(){
    //Start T-326930     
       final List<Contact> lstCon = [Select Id 
                        From Contact 
                        Where FS_Execution_Plan_Role__c Includes ('Primary Contact') 
                        And AccountId = :account.ID ];
    if(lstCon == null || lstCon.isempty()){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You must first add Primary Contact on HQ'));
        PageUrl = FSConstants.STR_NULL;
    }
    else {
          PageUrl = '/apex/FSCustomerInputFieldSelection?id=' + account.id;
    }
      return null;
      //End  T-326930 
  }
}