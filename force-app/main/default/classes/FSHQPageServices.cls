/********************************************************************************************************* 
Name         : FSHQPageServices
Created By   : Pallavi Sharma (Appiro)
Created Date : 23 - Sep - 2013
Usage        : Global Class for executing conditions CreateCustomerInput, InitiateExecutionPlan and CreateExecutionPlan button on HQ
***********************************************************************************************************/
global class FSHQPageServices {
  
  /*
  // Create Customer Input Changes for T-205448 
  webservice static String createCustomerInput(String hqId){
    List<Contact> lstCon = [Select Id 
                            From Contact 
                            Where FS_Execution_Plan_Role__c Includes ('Primary Contact') 
                             And FS_Contact_Info_Complete__c = true  
                             And AccountId = :hqId ];
    if(lstCon == null || lstCon.size() == 0){
        return 'You must first add Primary Contact';
    }
    
    List<Account> lstHQAcc = [Select Id, FS_HQ_Revenue_Center__c , FS_Chain__c ,FS_Chain__r.FS_FSM_Review__c 
                              From Account
                              Where Id =: hqId];
    Account accHQ = lstHQAcc.get(0);
    if(accHQ.FS_HQ_Revenue_Center__c != null && !accHQ.FS_HQ_Revenue_Center__c.contains('Region')){
        if(accHQ.FS_Chain__c != null && accHQ.FS_Chain__r.FS_FSM_Review__c == 'Reviewed'){
             return 'success';
        }
        else{
            return 'Headquarters needs to be related to Approved Chain';
        }
    }
    
    return 'success';
    
  }*/
  
  // Create Customer Input Changes for T-213757
  webservice static String createCustomerInput(String hqId){
    List<Contact> lstCon = [Select Id 
                            From Contact 
                            Where FS_Execution_Plan_Role__c Includes ('Primary Contact') 
                            And AccountId = :hqId ];
    if(lstCon == null || lstCon.size() == 0){
        return 'You must first add Primary Contact on HQ';
    }
    return 'success';
  }
  
  // Create Customer Input Changes for T-213757
  webservice static String initiateExecutionPlan(String hqId){
    Account account = [Select FS_FSM_Review__c, FS_Chain__r.FS_FSM_Review__c, FS_Chain__c From Account Where Id = : hqId];
    if(account.FS_Chain__c != null && account.FS_Chain__r.FS_FSM_Review__c == 'Reviewed'){
      return 'success';
    }
    else if(account.FS_FSM_Review__c == 'Reviewed' ){
      return 'success';
    }
    return 'Headquarters must be FSM approved before Intitating an Execution Plan'; 
  }
  
  
  webservice static String copyToOutlets(String hqId){
    List<FS_Customer_Input__c> lstCI = [Select FS_Site_Assessment_Required__c, FS_Site_Assessment_Contact_name__c From FS_Customer_Input__c Where FS_Account__c = : hqId  ];
    if(lstCI == null || lstCI.size() == 0 ){
        return 'There is no Customer Input associated with this HQ';
    }
    else{
      FS_Customer_Input__c cutomerInput =  lstCI.get(0);
      if(cutomerInput.FS_Site_Assessment_Required__c == 'No Site Assessment Required' || 
         cutomerInput.FS_Site_Assessment_Contact_name__c != null){
            
         }
        else{
            return 'Site Assessment Information Required';
        }
    }
    return 'success';
  }
  
  // Create Execution Plan Changes for T-205448
  webservice static String createExecutionPlan(String hqId){
    //Prepare Set for Outlets:
    Set<Id> outletIds = new Set<Id>();
    for(Account acc : [SELECT Id, (SELECT Id FROM Customer_Inputs__r)
                        FROM Account WHERE FS_Headquarters__c = :hqId  
                        AND RecordType.Name = 'FS Outlet']){
        
      if(acc.Customer_Inputs__r != null && acc.Customer_Inputs__r.size() > 0 ){
        outletIds.add(acc.Id);
      }  
    }    
    
    
    //Fetch Customer Input forms for all outlets and HQ as well.
    String qryCI = getCIQuery(getRequiredFieldMap()) + ' Where FS_Account__c IN: outletIds OR FS_Account__c = :hqId';
    
    FS_Customer_Input__c hqCI;
    List<FS_Customer_Input__c> lstOutletsCI = new List<FS_Customer_Input__c>();
    for(FS_Customer_Input__c CI :(List<FS_Customer_Input__c>)database.query(qryCI)){
      if(CI.FS_Account__c == hqId){
        hqCI = Ci;
      }
      else{
        lstOutletsCI.add(CI);
      } 
    }
    
    
    if(hqCI == null ){
      return 'There is no Customer Input associated with this HQ';
    }
    
    Boolean flagNoSA = true;
    for(FS_Customer_Input__c CI :lstOutletsCI){
      if(CI.FS_Site_Assessment_Required__c != 'No Site Assessment Required'){
        flagNoSA = false;   
      }
    }
    
    // If No site assessment required we don't need to check other things.
    if(flagNoSA == true){
      return 'success';
    }
    
    for(FS_Customer_Input__c CI :lstOutletsCI){
        if(checkPlannedDispensersIsNotNull(CI) == false){
        return 'You must enter planned dispensers and Top Mount Ice Makers before creating an Execution Plan';   
      }
    }
    
    if(checkStandaredConactHasRole_SA(hqId) == true){
        return 'success';
    }
    
    for(FS_Customer_Input__c CI :lstOutletsCI){
      if(checkSAContactInformationIsNotNull(CI) == false && CI.FS_Site_Assessment_Required__c != 'No Site Assessment Required'){
        return 'You must first Enter or Select a Site Assessment Contact before creating Execution Plan';   
      }
    }
    return 'success';
  }
  
  
  private static Boolean checkPlannedDispensersIsNotNull(FS_Customer_Input__c ci){
    if(String.isBlank(ci.FS_Number_self_serve_units__c) ||
       (String.isBlank(ci.FS_Number_crew_serve_unit__c)) ||
       (String.isBlank(ci.FS_Self_Serve_Top_Mnt_Ice_Maker_Instld__c))){
      return false;
    }
    return true;
  }
  
  private static Boolean checkSAContactInformationIsNotNull(FS_Customer_Input__c ci){
    if(String.isBlank(ci.FS_Site_Assessment_Contact_name__c) ||
       (String.isBlank(ci.FS_Site_Assessment_Contact_Phone__c)) ||
       (String.isBlank(ci.FS_Site_Assessment_contact_email__c))){
      return false;
    }
    return true;
  }
  
  private static Boolean checkStandaredConactHasRole_SA(Id hqId){
     List<Contact> lstCon = [SELECT Id FROM Contact WHERE FS_Execution_Plan_Role__c Includes ('Site Assessment Contact') 
                             AND FS_Contact_Info_Complete__c = TRUE  
                             AND AccountId = :hqId ];
    if(lstCon != null && lstCon.size() > 0){
        return true;
    }
    return false;
  }
  
  
  
  
  
  
  private static String checkRequiredFields(FS_Customer_Input__c cutomerInput, Map<String,String> requiredFields){
    for(String reqFields : requiredFields.keySet()){
        if(cutomerInput.get(reqFields) == null ){
            return 'Required Field Missing - ' + requiredFields.get(reqFields);
        }
    }
    return 'success';
  }
  
  private static Map<String,String> getRequiredFieldMap(){
    Map<String,String> requiredFields = new Map<String,String>();  
    List<FS_CI_Required_Fields_Region__c> lstRequireFields = FS_CI_Required_Fields_Region__c.getall().values();
    
    for(FS_CI_Required_Fields_Region__c reqF : lstRequireFields){
        requiredFields.put(reqF.Field_API__c, reqF.Field_Lable__c);
    }   
    return requiredFields;
  }
  
  private static String getCIQuery(Map<String,String> requiredFields){
    String csv = ' ';
    for(String reqFields : requiredFields.keySet()){
      csv += reqFields + ',';
    }
    csv = csv.substring(0, csv.lastIndexOf(','));
    return 'Select ' + csv + ' , FS_Account__c From FS_Customer_Input__c  ';
  }
  
}