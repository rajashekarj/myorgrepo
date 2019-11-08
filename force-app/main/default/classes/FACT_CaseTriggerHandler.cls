/**************************************************************************************
Apex Class Name     : FACT_CaseTriggerHandler
Function            : This is a Case Trigger Handler class for implementing the 
                      functionalities that has to be handled during Case inserting or Updating.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD            07/25/2017       Updated to inserting Account Team Members in Case Email Notification 
                                       object and to send Email for case closure.
* Vishnu M            07/28/2017       Display an error message to users who try to close the Case with open task. 
* Reshma              07/28/2017       Created a method populateCaseFieldsfromOD to populate static fields on case object
                                       Commented method 'populatesCaseFieldsfromIssuetracker' as DCIT linkage for FACT cases is discarded. 
*************************************************************************************/

public class FACT_CaseTriggerHandler extends TriggerClass{
 
    /*****************************************************************************************
    Method : beforeInsertUpdateProcess
    Description : Method called for After Insert and update records.
    ******************************************************************************************/
    
    public static void beforeInsertUpdateProcess(List<Case> newList,List<Case> oldList,Map<Id,Case> newMap,Map<Id,Case> oldMap, Boolean isInsert, Boolean isUpdate) 
    {
        FSCaseManagementHelper helperMethod = new FSCaseManagementHelper();
        helperMethod.populateStaticCaseFields(isInsert,isUpdate,newList,oldMap);
    }
    
    /*****************************************************************************************
    Method : afterInsertProcess
    Description : Method called for After Insert records.
    ******************************************************************************************/
    public static void afterInsertProcess(List<Case> newList,List<Case> oldList,Map<Id,Case> newMap,Map<Id,Case> oldMap, Boolean isInsert, Boolean isUpdate) 
    {
        System.debug('Check case assignment rules');
      	FSCaseManagementHelper helperMethod = new FSCaseManagementHelper();
        List<String> emailRolesList = helperMethod.getAllEmailRoles(false,false,false);
        helperMethod.createCaseHistory(emailRolesList,newList);
        Set<Id> caseIdSet = new Set<Id>();
        for(Case c : newList){
           caseIdSet.add(c.Id); 
        }
        List<Case> caseList = new List<Case>();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        for(Case c : [SELECT Id FROM Case WHERE Id IN: caseIdSet]) {
            c.setOptions(dmo);
            caseList.add(c);
        }
        FSConstants.SET_CASEASSIGNMENTRULES = false;
        update caseList;  
        
    }
    
    /*****************************************************************************************
    Method : beforeUpdateProcess
    Description : Method called for Before Update records.
    ******************************************************************************************/
    public static void beforeUpdateProcess(List<Case> newList,List<Case> oldList,Map<Id,Case> newMap,Map<Id,Case> oldMap, Boolean isInsert, Boolean isUpdate) 
    {
        FSCaseManagementHelper helperMethod = new FSCaseManagementHelper();
        helperMethod.checkTask(newList);
    }
    
    /*****************************************************************************************
    Method : afterUpdateProcess
    Description : Method called for After Update records.
    ******************************************************************************************/
    public static void afterUpdateProcess(List<Case> newList,List<Case> oldList,Map<Id,Case> newMap,Map<Id,Case> oldMap, Boolean isInsert, Boolean isUpdate) 
    {
        FSCaseManagementHelper helperMethod = new FSCaseManagementHelper();
        List<String> emailRolesList = helperMethod.getAllEmailRoles(false,true,false);
        helperMethod.sendMailOnCaseClose(emailRolesList,newList);
        helperMethod.deleteCaseNotification(oldList,newList);
        
    } 
    
    /*****************************************************************************************
    Method : updateLMcase
    Description : Method called for After Update records.
    ******************************************************************************************/
    //FACT 2018 R1 Enhancements 
     public static void updateLMcase(List<Case> newList,List<Case> oldList,Map<Id,Case> oldMap) 
    {
        FSCaseManagementHelper helperMethod = new FSCaseManagementHelper();
        if(helperMethod.runOnce())
        {
        helperMethod.sendEmailToExternal(newList,oldList,oldmap);
        helperMethod.validateAMOACaseStatus(newList, oldList, oldMap);//Added as part of FET-7.0 FNF-366
        }
        //helperMethod.UpdateHistory(oldList,newList);
    }
    
    
          
} //end of class