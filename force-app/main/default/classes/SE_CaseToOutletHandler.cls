/*********************************************************************************************************
Name         : SE_CaseToODHandler
Created By   : Mahender(Infosys)
Created Date : 17 - Nov - 2016
Usage        : Handler class for CaseToOutlet Dispenser trigger.
This class deletes the serial number on the case object to which it is associated with and updates the case list

Name          : SE_CaseToODHandler
Modified By   : Reshma(Infosys)
Modified Date : 30 - Jul - 2017
Usage         : Handler class for CaseToOutlet Dispenser trigger.
Added a method 'populateCaseFieldsfromOD' in this class to populate sttaic fields on CasetoOutletDispenser object 

Name          : SE_CaseToODHandler
Modified By   : Reshma(Infosys)
Modified Date : 28 - Feb - 2018
Usage         : Handler class for CaseToOutlet Dispenser trigger.
Added a method 'populateSerialNumbersOnLMCase' in this class to populate serialnumbers on Case object 

***********************************************************************************************************/

public without sharing class SE_CaseToOutletHandler
{
    /*****************************************************************************************
    Method : beforeInsertProcess
    Description : Method called for Before Insert records.
    ******************************************************************************************/
     public static void beforeInsertProcess(Boolean IsAfter,Boolean IsInsert,Boolean IsUpdate,List<CaseToOutletdispenser__c> newCaseODList,Map<ID,CaseToOutletdispenser__c> oldmap)
     {
         FSCaseManagementHelper helper = new FSCaseManagementHelper();
         helper.populateCaseFieldsfromOD(IsAfter,IsInsert,IsUpdate,newCaseODList,oldmap);
     }
     
     /*****************************************************************************************
    Method : aftertProcess
    Description : Method called for after Insert/Update/Delete of CaseToOD records.
    ******************************************************************************************/
    
     public static void afterProcess(List<CaseToOutletdispenser__c> newCaseODList,List<CaseToOutletdispenser__c> oldCaseODList)
     {
         FSCaseManagementHelper helper = new FSCaseManagementHelper();
         helper.populateSerialNumbersOnLMCase(newCaseODList,oldCaseODList);
     }
}