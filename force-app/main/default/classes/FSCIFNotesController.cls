/**************************************************************************************
Apex Class Name     : FSCIFNotesController
Version             : 1.0
Function            : This is a Controller class for FSCIFNotes VF page, which shows the list of Installations and their 
					  related comments fields linked to the particular Execution Plan record
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata             02/02/2017          Original Version
*************************************************************************************/

public class FSCIFNotesController { 
    
    public Id executionPlanId {get;set;}
    public List<FS_Installation__c> lstInstallation {get;set;}
    public Boolean input{get;set;}
    public String isYes{get;set;}
    public static Object nullVal() { return null; }
     /*****************************************************************
  	Controller: FSCIFNotesController  
  	Description: FSCIFNotesController controller lists the installations linked to that particular execution plan  
	*******************************************************************/
    public FSCIFNotesController(){
        input=false;
        isYes='YES';
        //fetching the execution plan Id
        executionPlanId = ApexPages.currentPage().getParameters().get('Id');
        lstInstallation = new List<FS_Installation__c>();
        //retreiving the installation records under the execution plan
        if(executionPlanId!=nullVal()){
            try{
                for(FS_Installation__c installObj : [ Select Id,Name,FS_Ancillary_equipment_to_remain_on_site__c,FS_Outlet_Information__c,
                                                     FS_OB_Comments__c,FS_Product_Information_Comments__c,FS_Ice_maker_and_water_filter_comments__c,
                                                     FS_Describe_Any_Known_Construction_Needs__c,FS_Dispenser_Comments__c,FS_Ancillary_equipment_needed__c,
                                                     Does_Install_Involve_RO4W__c, FS_Does_Install_Involve_a_Replacement__c, FS_Replacement_1__c, FS_Replacement_2__c,
                                                     FS_Replacement_3__c, FS_RO4W1__c,FS_RO4W2__c,FS_RO4W3__c
                                                     From FS_Installation__c Where FS_Execution_Plan__c =: executionPlanId]){//Modified the query as part of FET-7.0 FNF 795
                                                         lstInstallation.add(installObj); 
                                                     }
            }
            Catch(Exception e){
                ApexErrorLogger.addApexErrorLog('FET-7.0', 'FSCIFNotesController', 'FSCIFNotesController', 'Installation', 'Medium', e, 'NA');
            }
            
        }        
    }
    
    /*****************************************************************
  	Method: cancel
  	Description: cancel method helps the user return back to the execution plan record  
	*******************************************************************/
    public PageReference cancel(){
        PageReference pageRef;
        if(executionPlanId!=nullVal()){
            pageRef= new PageReference('/' + executionPlanId);
        }
        return pageRef;        
    } 
	 /*****************************************************************
  	Method: edit
  	Description: edit method helps the user to edit the RO4W fields  
	*******************************************************************/
    public void edit(){
        input=true;
    } 
    /*****************************************************************
  	Method: cancelSave
  	Description: this method helps the user to navigate away from edit mode  
	*******************************************************************/
    public pagereference cancelSave(){
        Id pageId=ApexPages.currentPage().getParameters().get('Id');
        PageReference redirectPage = Page.FSCIFNotes;
        redirectPage.setRedirect(true);
        redirectPage.getParameters().put('id',pageId);
        return redirectPage;
    }
	 /*****************************************************************
  	Method: save
  	Description: save method helps the user to save the RO4W fields  
	*******************************************************************/
    public pagereference save(){
        input=false;
        try{
            update lstInstallation;
        }        
        catch(dmlException dx){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,'Please enter value'));
            input=true;
            return null;
        }
        return null;
    }    
}