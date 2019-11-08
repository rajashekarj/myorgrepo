/**************************************************************************************
Apex Class Name     : ReAssignCaseOwnerTriggerHandler
Function            : This is a Case Trigger Handler class for implementing the 
                      functionalities that has to be handled during Case insert or Update.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD            07/25/2017       Updated to insert or update Ouutlet Dispensers in Case to Outlet Dispenser related list.
*************************************************************************************/
public without sharing class ReAssignCaseOwnerTriggerHandler{
 
    /*****************************************************************************************
    Method : insertValues
    Description : This method is to insert caseToOutletDispensers junctions object records to 
				  case records when the dispenser serial number is filled for a case
    ******************************************************************************************/
    public static void insertValues(List<Case> newCaseList,List<Case> oldCaseList,Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap,Boolean isInsert, Boolean isUpdate)
    {
        FSCaseManagementHelper helperClass = new FSCaseManagementHelper();
        helperClass.insertOutletDispenser(newCaseList);
        helperClass.CreateHistory(newCaseList);
    }
    
    /*****************************************************************************************
    Method : updateValues
    Description : This method is to update caseToOutletDispensers junctions object records to case records 
				  when the dispenser serial number is filled for a case
    ******************************************************************************************/
    public static void updateValues(List<Case> newCaseList,List<Case> oldCaseList,Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap,Boolean isInsert, Boolean isUpdate)
    {
        FSCaseManagementHelper helperClass = new FSCaseManagementHelper();
        helperClass.UpdateHistory(oldCaseList,newCaseList);
        helperClass.updateOutletDispenser(oldCaseList,newCaseList);
        
    }  
}