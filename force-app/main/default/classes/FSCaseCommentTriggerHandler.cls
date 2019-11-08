/**************************************************************************************
Apex Class Name     : FSCaseCommentTriggerHandler
Function            : This is a Case Comment Trigger Handler class which inturn 
					  calls a method from helper class to send mail on case comment added.
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD	          07/26/2017       Original Version for implementing a FET FACT+EMT FR7 requirement.
*************************************************************************************/

public class FSCaseCommentTriggerHandler extends TriggerClass{
    
    /*****************************************************************************************
    Method : afterInsertProcess
    Description : Method called for After Insert records.
    ******************************************************************************************/
    public static void afterInsertProcess(List<CaseComment> newList,List<CaseComment> oldList,Map<Id,CaseComment> newMap,Map<Id,CaseComment> oldMap, Boolean isInsert, Boolean isUpdate) 
    {
        FSCaseManagementHelper helper = new FSCaseManagementHelper();
        helper.caseCommentUpdate(newList);
    }
}