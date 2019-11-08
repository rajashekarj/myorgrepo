/**************************************************************************************
Apex Class Name     : FSCopytoLower_Cancel_ValidFill_Extension
Version             : 1.0
Function            : This is an Extension class for FSCopytoLowerValidFill and FSCancelValidFill VF, which will Provide info on 
					  How many records been selected for Copydown/Cancel
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkat FNF 6.0         02/12/2019        Original Version
*************************************************************************************/

public class FSCopytoLower_Cancel_ValidFill_Extension {
    public String validFillId {get; set;}
    public String accId {get; set;}
    public Integer validFillCount {get; set;}        
    
    public FSCopytoLower_Cancel_ValidFill_Extension(ApexPages.StandardSetController controller){        
        
        List<FS_Valid_Fill__c> listValidFill = (List<FS_Valid_Fill__c>)controller.getSelected();
        validFillCount=listValidFill.size();
        
        for(FS_Valid_Fill__c validFill:listValidFill){
            validFillId=validFill.id;            
        }
        for(FS_Valid_Fill__c vf:[select id,FS_outlet__c from FS_Valid_Fill__c where id=:validFillId]){
            accId=vf.FS_Outlet__c;
        }              
    }  
}