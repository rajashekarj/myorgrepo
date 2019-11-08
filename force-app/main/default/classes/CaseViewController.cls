/**************************************************************************************
Apex Class Name     : CaseViewController
Function            : This class is created for routing to Case Detail Page based on Record Type.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Denit            3/5/2018           LM RecordType will be routed to FS_LM_CaseDetailPage VF 
									  others Will be routed to Standard Layout 	
*************************************************************************************/
public with sharing class CaseViewController 
{
    private ApexPages.StandardController controller = null;   
    public CaseViewController (ApexPages.StandardController controller)
    {
        this.controller = controller;
    }    
    public PageReference redirectDefaultCase()
    {        
        Case c = [Select id, recordtypeid from Case where Id = :ApexPages.currentPage().getParameters().get('id')];        
        if (c.recordtypeid == Schema.SObjectType.Case.getRecordTypeInfosByName().get(FSConstants.RECORD_TYPE_NAME_LMCASE).getRecordTypeId()) 
        {       
        	return new Pagereference('/apex/FS_LM_CaseDetailPage?id='+ c.id);        
        } 
        else 
        {
           return new PageReference ('/' + c.id + '?nooverride=1');
        }
    }
}