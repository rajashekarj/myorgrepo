/*
* Date         : 20/06/2019
* Developer    : Infosys
* Purpose      : Controller class for VF Component's CaseCommentsOutletDispensers and FS_CaseDetailsForAMS to get 
				 OD details and casecomments.
*=================================================================================================================
*                                 Upate History
*                                 ---------------
*   Date        Developer       Tag   Description
*============+================+=====+=============================================================================
* 20/06/2019 | Infosys |     | Initial Version                                         
*===========+=================+=====+=============================================================================
*/
public without sharing class FS_ODAndCaseCommentsDetails {
    public Id caseRecId {get; set;}
    public Id recId {get; set;}
    public List<FS_Outlet_Dispenser__c> odList {get;set;}
    
    /*****************************************************************
    Method: getDispenserList
    Description: getDispenserList method is to get the Outlet Dispenser linked to Account.
    Added as part of FET 7.0, //Sprint 1 - FNF-459
    *******************************************************************/ 
    public List<FS_Outlet_Dispenser__c> getDispenserList(){
        if(recId != null)
        {   
            Set<Id> odIDSet = new Set<Id>();
            for(CaseToOutletdispenser__c caseOD: [select Case__c,Outlet_Dispenser__c,Outlet_Dispenser__r.FS_Outlet__c from CaseToOutletdispenser__c where Case__c=:caseRecId and Outlet_Dispenser__r.FS_Outlet__c=:recId]){
                odIDSet.add(caseOD.Outlet_Dispenser__c);              
            }
            odList = [select id,Name,FS_Outlet__r.name,FS_IsActive__c,FS_Serial_Number__c,FS_Status__c from FS_Outlet_Dispenser__c where Id IN: odIDSet]; 
        }
        return odList;
    }
    
    /*****************************************************************
    Method: getCaseComments
    Description: getCaseComments method is to get all the casecomments excluding 'Freestyle Administratore'created seprated with ';'.
    Added as part of FET 7.0, //Sprint 1 - FNF-459
    *******************************************************************/ 
    Public String getCaseComments(){
        String caseComments = '';
        List<CaseComment> ccList = new List<CaseComment>();
        ccList = [Select CommentBody from CaseComment where ParentId =: caseRecId and CreatedById !=: FSUtil.getFreeStyleUserId()];
        for(CaseComment ccCm : ccList){
            caseComments = caseComments + ccCm.CommentBody + ';';
        }
        return caseComments;
    }
    
    /*****************************************************************
    Method: getDispenserList
    Description: getDispenserList method is to get the Outlet Dispenser linked to RO4W..
    Added as part of FET 7.0, //Sprint 1 - FNF-459
    *******************************************************************/ 
     public List<FS_Outlet_Dispenser__c> getRO4WDispenserList(){
         if(recId != null)
         {   
             odList = [SELECT id,Name,FS_Outlet__r.name,FS_IsActive__c,FS_Serial_Number__c,FS_Status__c from FS_Outlet_Dispenser__c where FS_Other_PIA_Installation__c =: recId];                   
         }
         return odList;
    }
}