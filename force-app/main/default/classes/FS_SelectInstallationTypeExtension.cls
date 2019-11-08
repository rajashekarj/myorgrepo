/**************************************************************************************
Apex Class Name     : FS_SelectInstallationTypeExtension
Version             : 1.0
Function            : This is an Extension class for FS_SelectInstallationType VF, which shows a popup message for the user while 
					  Creating "Replacement" Installation record as warning to check for the platform type. 
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata             01/12/2017          Original Version
*************************************************************************************/

public with sharing class FS_SelectInstallationTypeExtension {     
    public String accountId;
    public Schema.DescribeSObjectResult schemaResult;
    public String code;
    public Pagereference pageRef;    
    public boolean displayPopup{get;set;}   
    public Pagereference pageRefInst{get;set;} 
    
    /*****************************************************************
  	Method: closePopup
  	Description: closePopup method is close the popup displayed to the user
	*******************************************************************/
    public void closePopup() { 
        displayPopup = false; 
    }  
    
     /*****************************************************************
  	Method: showPopup
  	Description: showPopup method is show the popup for the user with 
				related message 				
	*******************************************************************/
    public void showPopup() {
        displayPopup = true;  
    }
    
    //constructor
    public FS_SelectInstallationTypeExtension(){        
        accountId=ApexPages.currentPage().getParameters().get('id');                     
        showPopup();
    }    
     /*****************************************************************
  	Method: proceedAction
  	Description: proceedAction method is used to take the user to the "Replacement" installation
				record page with prepopulating some field values
	*******************************************************************/    
    public PageReference proceedAction(){
        closePopup();
        List<Account> accountList=new List<Account>();
		// getting execution plan name from custom setting        
        final Dummy_Execution_Plan_del__c executionPlan=Dummy_Execution_Plan_del__c.getInstance();
        final String planName=executionPlan.ExecutionPlan_Name__c;
 		//getting installation object prefix code
        schemaResult = FS_Installation__c.SObjectType.getDescribe();
        code=schemaResult.getKeyPrefix();
        //fetching the outlet account details
        accountList=[select name from Account where id=:accountId]; 
        if(!accountList.isEmpty()){
            //FNF-190 Removed Default Yes from Favourite Mix field 
        	pageRefInst=new PageReference('/'+code+'/e?RecordType='+FSInstallationValidateAndSet.ipRecTypeReplacement+'&CF00N6100000BpOPa_lkid='+accountId+'&CF00N6100000BpOPa='+accountList[0].Name+'&CF00N6100000BpO5M='+planName);
        }
        else{
            pageRefInst=new PageReference('/'+accountId);
        }
        pageRefInst.getParameters().put('nooverride','1');        
        return pageRefInst;               
    }
    
    /*****************************************************************
  Method: cancelAction
  Description: cancelAction method is to get the user back to the Account record page
*******************************************************************/
    public PageReference cancelAction(){
        closePopup();
        pageRef=new PageReference('/'+accountId);
        return pageRef;
    }    
}