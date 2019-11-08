/**************************************************************************************
Apex Class Name     : FSEPSendPMApprovalController
Version             : 1.0
Function            : This is an Controller class for FSEPSendPMApproval VF, which shows the list of Installations 
					  related to the particular Execution plan record.
to select those Installation and can able Send for PM Approval.
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata            06/19/2017        Original Version
*************************************************************************************/

public class FSEPSendPMApprovalController  {
    public List<FS_Installation__c> updateAppStatus;   
    public List<Task> instApprovalTasks;
    public Id executionPlanId {get;set;}
    public List<FS_Installation__c> installationList{get;set;}
    public List<InstallWrapper> installWrapperList{get;set;}   
    public Boolean conditionCheck {get;set;}
    
    public static Object nullVal(){ return null; }
    public static String nullString(){ return null;}
    
    //constructor to get EP Id and list all installations under that EP for approval
    public FSEPSendPMApprovalController(){
        //getting Id of the current page
        executionPlanId=ApexPages.currentPage().getParameters().get('Id'); 
        //initialize the collections
        installationList=new List<FS_Installation__c>();
        installWrapperList=new List<InstallWrapper>();
        conditionCheck=false;
        //retreving List of installations under that Execution plan        
        installationList=[select Id,Name,FS_Execution_Plan__c,Type_of_Dispenser_Platform__c,Recordtype.Name,
                          FS_Ready_For_PM_Approval__c,FS_Reason_for_Installation_Rejection__c,FS_Execution_Plan_Final_Approval_PM__c,
                          FS_Outlet__c,FS_Approval_request_submitted_by__c,FS_Approval_request_submitted_date_time__c,
                          FS_Execution_Plan__r.FS_PM__c,FS_Overall_Status__c from FS_Installation__c 
                          where FS_Execution_Plan__c=:executionPlanId and FS_Execution_Plan_Final_Approval_PM__c!='Approved'  
                          and FS_Overall_Status__c!=:FSConstants.IPCANCELLED];
        
        //iterating installation records into wrapper list
        if(!installationList.isEmpty()){
            for(FS_Installation__c a : installationList ) {             
                installWrapperList.add(new InstallWrapper(a,false));                
            }
        }else{
            conditionCheck=true; //Boolean variable to check list empty condtion in VF           
        }       
    } 
    
    /*****************************************************************
  Method: sendForApproval
  Description: sendForApproval method is to update the selected Installation records for the approval submitter fields.
				and create task for the PM user to aprrove/reject it
*******************************************************************/
    //method to check PM value of EP and send selected Installations for PM approval with some field updations and task creations
    public pageReference sendForApproval() {
        Boolean sendForPMApproval = true; //value to check PM value is there or not for EP
        Boolean selectInstallation = false; // value to check any installation is selected or not
        PageReference epPage;
        updateAppStatus = new List<FS_Installation__c>(); //updated installation list
        instApprovalTasks = new List<Task>();		//task list 
        SavePoint savePosition;   //Save Point Variable
        
        for(InstallWrapper ow : installWrapperList){
            //checking PM value of EP record, if true show error message
            if(ow.isChecked)  {
                selectInstallation=true;
                if(ow.installation.FS_Execution_Plan__r.FS_PM__c==nullVal()){
                    final ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'PM User cannot be blank.');
                    ApexPages.addMessage(warningMessage); 
                    sendForPMApproval=false;                    
                    break;
                }               
                ow.installation.FS_Ready_For_PM_Approval__c = true;
                ow.installation.FS_Approval_request_submitted_by__c = UserInfo.getUserId();
                ow.installation.FS_Approval_request_submitted_date_time__c = System.now();
                ow.installation.FS_Execution_Plan_Final_Approval_PM__c=nullString();                 
                
                //creating task for approval Installations for PM user of EP
                final Task instTask = new Task(OwnerId=ow.installation.FS_Execution_Plan__r.FS_PM__c,Subject='EP APV Requested',
                                               Status='Not Started',Priority='Normal',FS_Action__c='Approve/Reject',
                                               WhatId=ow.installation.Id,IsReminderSet=false);                    
                instApprovalTasks.add(instTask);                
                updateAppStatus.add(ow.installation);   
            }            
        }
        if(!selectInstallation){
            final ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,FSConstants.ERRORMESSAGEIPSELECTION);
            ApexPages.addMessage(warningMessage); 
        }
        // checking conditions for updation of Installation and Insertion of task
        try{            
            if(sendForPMApproval && selectInstallation){ 
                savePosition = Database.setSavePoint();
                if(!updateAppStatus.isEmpty()){
                    update updateAppStatus;                    
                }
                if(!instApprovalTasks.isEmpty()){
                    insert instApprovalTasks;                    
                }
                epPage =  cancel();
            }            
        }
        //catching DML exceptions and rolling back the changes
        catch(DMLException ex){
            Database.rollback(savePosition);			           
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSEPSendPMApprovalController','sendForApproval',FSConstants.INSTALLATIONOBJECTNAME,FSConstants.MediumPriority,ex,ex.getMessage());            
        }
        return epPage;
    }
    
    /*****************************************************************
  	Method: cancel
  	Description: cancel method is to get the user back to the Execution Plan record
	*******************************************************************/
    public pageReference cancel(){
        PageReference pageRef;
        if(executionPlanId!=nullVal()){
            pageRef= new PageReference('/' + executionPlanId);
        }
        return pageRef;   
    } 
    
    //wrapper class being used for to store the checkbox selection status of the records.
    public class InstallWrapper{
        public Boolean isChecked{get;set;}
        public FS_Installation__c installation{get;set;}
        
        public InstallWrapper(final FS_Installation__c installation,final Boolean flag){
            this.installation = installation;
            this.isChecked = flag;
        }
    } 
}