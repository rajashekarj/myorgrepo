/**************************************************************************************
Apex Class Name     : FSEPInstallationApproval
Version             : 1.0
Function            : This is an Controller class for FSEPInstallationApproval VF, which shows the list of Installations 
					  related to the particular Execution plan record.
to select those Installation and can able to approve/reject.
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkata             01/12/2017          Original Version
*************************************************************************************/

public class FSEPInstallationApproval {    
    
    public static final String CLASSNAME='FSEPInstallationApproval';    
    transient SavePoint savePosition;
    public Set<Id> taskIdIP;
    public PageReference epPage;
    public Id executionPlanId{get;set;}  
    public List<InstallWrapper> installWrapperList{get;set;}   
    public List<FS_Installation__c> installationList {get;set;}      
    public List<FS_Installation__c> updateAppStatus{get;set;}
    public List<Task> instApprovalTasks{get;set;}
    public Boolean conditionCheck {get;set;}
    
    public static Object nullVal() { return null; }
    
    //constructor to get EP Id and list all installations under that EP for approval
    public FSEPInstallationApproval(){
        //getting id of current page
        executionPlanId = ApexPages.currentPage().getParameters().get('Id');       
        //initialize the collections
        installWrapperList = new List<InstallWrapper>();        
        installationList = new List<FS_Installation__c>(); 
        taskIdIP=new Set<Id>();
        conditionCheck=false;
        //retreving List of installations under that Execution plan
        installationList=[Select Id,Name,Type_of_Dispenser_Platform__c,FS_Reason_for_Installation_Rejection__c,FS_Headquarters_ACN__c,
                          FS_Execution_Plan__r.FS_PM__c,FS_Execution_Plan__r.FS_Back_up_COM__c,
                          FS_Execution_Plan__r.FS_Back_up_COM__r.Email,FS_Approval_request_submitted_by__c,FS_Execution_Plan__r.name,
                          RecordType.Name,FS_Outlet__c,FS_Ready_For_PM_Approval__c,FS_Execution_Plan_Final_Approval_PM__c,
                          FS_Execution_Plan_Final_Approval__c,FS_Approval_request_submitted_date_time__c,
                          FS_Execution_Plan__r.FS_PIC__c,FS_Approved_by__c,FS_Approved_by_date_time__c,FS_Overall_Status__c,
                          FS_Execution_Plan__r.FS_Execution_Plan__c,FS_Approval_request_submitted_by__r.Email From FS_Installation__c 
                          Where FS_Execution_Plan__c =: executionPlanId AND FS_Execution_Plan_Final_Approval_PM__c=null 
                          AND FS_Ready_For_PM_Approval__c = true and FS_Overall_Status__c!=:FSConstants.IPCANCELLED ];
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
  Method: approveInstallationPM
  Description: approveInstallationPM method is to update the selected installation status to Approved and update the 
				concern fields related to it.
we are creating/updating tasks related to the Installations
*******************************************************************/

    public PageReference approveInstallationPM() {
        updateAppStatus = new List<FS_Installation__c>();
        instApprovalTasks = new List<Task>();
        Boolean checkPIC =false;	//value to check PC/AC value is there or not for EP
        Boolean selectInstallation = false; // value to check any installation is selected or not
        
        for(InstallWrapper ow : installWrapperList) { 
            if(ow.isChecked){
                selectInstallation=true;
                //if PC/AC value not given for the EP, we are giving warning message
                if(ow.installation.FS_Execution_Plan__r.FS_PIC__c==null && String.isBlank(ow.installation.FS_Execution_Plan__r.FS_PIC__c)){
                    final ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'PC/AC User cannot be blank');
                    ApexPages.addMessage(warningMessage);
                    checkPIC =true; 
                    break;
                }                
                final FS_Installation__c installation=ow.installation;
                installation.FS_Execution_Plan_Final_Approval_PM__c ='Approved';               
                installation.FS_Approved_by__c = UserInfo.getUserId();
                installation.FS_Approved_by_date_time__c = System.now();
                //creating task after approval Installations for PC/AC user of EP
                final Task instTask = new Task(OwnerId=installation.FS_Execution_Plan__r.FS_PIC__c,Subject='IP Ready for Schd',
                                               Status='Not Started',Priority='Normal',FS_Action__c='Schedule Install',
                                               WhatId=installation.Id,IsReminderSet=false);                  
                instApprovalTasks.add(instTask); 
                updateAppStatus.add(installation);
                taskIdIP.add(installation.Id);
            }                       
        }
        //error message for to select atleast one Installation
        if(!selectInstallation){
            final ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,FSConstants.ERRORMESSAGEIPSELECTION);
            ApexPages.addMessage(warningMessage); 
        }
        // checking condtions for updation of Installation and Insertion of task
        try{            
            if(!checkPIC && selectInstallation) { 
                savePosition = Database.setSavePoint();//initializing the save point variable with the current status
                //Updating the Installations with approval values
                if(!updateAppStatus.isEmpty()){
                    update updateAppStatus;
                }
                //updating the tasks to Complete of the approved Installations
                if(!instApprovalTasks.isEmpty()){
                    insert instApprovalTasks;
                } 
                //creating new tasks for the PC/AC user
                if(!taskIdIP.isEmpty()){
                    updateTasks(taskIdIP);
                }  
                epPage=cancel();
            }   
        }
        //catching DML exception and rolling back the changes with  save point status
        catch(DMLException ex){
            Database.rollback(savePosition);            
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,CLASSNAME,'approveInstallationPM','FS_Installation__c',FSConstants.MediumPriority,ex,ex.getMessage());            
        }
        return epPage;
    }
    
    /*****************************************************************
  Method: rejectInstallationPM
  Description: rejectInstallationPM method is to update the selected installation status to Rejected and update the 
				concern fields related to it. we are updating tasks related to the Installations.
*******************************************************************/
    public PageReference rejectInstallationPM() {
        Boolean selectInstallation = false; // value to check any installation is selected or not
        final List<Messaging.SingleEmailMessage> allMail=new List<Messaging.SingleEmailMessage>();            
        updateAppStatus = new List<FS_Installation__c>();      
        Boolean checkReject =true; 
        
        for(InstallWrapper ow : installWrapperList) {
            if(ow.isChecked) {
                selectInstallation=true;
                //message to let them know to enter the reason while rejection
                if(ow.installation.FS_Reason_for_Installation_Rejection__c == '' || ow.installation.FS_Reason_for_Installation_Rejection__c == null){
                    final ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'Please fill the reason for rejection.');
                    ApexPages.addMessage(warningMessage);
                    checkReject =false; 
                    break;
                }                
                else {
                    updateAppStatus.add(ow.installation);
                }
            } 
        }
        //message for to select atleast one installation
        if(!selectInstallation){
            final ApexPages.Message warningMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'please select atleast one installation');
            ApexPages.addMessage(warningMessage); 
        }
        //updating the installation values
        if(checkReject && selectInstallation){
            for(FS_Installation__c installation : updateAppStatus){    
                installation.FS_Execution_Plan_Final_Approval_PM__c ='Rejected'; 
                installation.FS_Ready_For_PM_Approval__c = false;
                installation.FS_Approved_by__c = UserInfo.getUserId();
                installation.FS_Approved_by_date_time__c = System.now();
                taskIdIP.add(installation.Id);
            }
        }
        try{
            //Updating the Installation records
            if(!updateAppStatus.isEmpty() && checkReject){
                savePosition = Database.setSavePoint();//initializing the save point variable with the current status                
                update updateAppStatus;
                //rejection mail for the user who sent installation for approval
                for(FS_Installation__c installMail:updateAppStatus){
                    final Messaging.SingleEmailMessage mail=sendSPEmail(installMail);
                    allMail.add(mail);                    
                }
                //calling Updatetasks Method
                if(!taskIdIP.isEmpty()){
                    updateTasks(taskIdIP);
                }   
                //Sending Email Notification                
                if(!allMail.isEmpty()){                    
                    Messaging.SendEmail(allMail,true);                    
                }
                epPage = cancel();
            }        
        } 
        //Catching DML Exception
        catch(DMLException ex){
            Database.rollback(savePosition); 
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,CLASSNAME,'rejectInstallationPM','FS_Installation__c',FSConstants.MediumPriority,ex,ex.getMessage());           
        }
        catch(EmailException ex){
            Database.rollback(savePosition);             
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,CLASSNAME,'rejectInstallationPM','Messaging',FSConstants.MediumPriority,ex,ex.getMessage());            
        }
        return epPage;      
    } 
    
   /*****************************************************************
  Method: updateTasks
  Description: updateTasks method is to update the tasks created on the selected installations to Complete 
				whenever they are approved/rejected
*******************************************************************/
    public static void updateTasks(final Set<Id> instIdSet){
        //initializing the collection to store task records
        List<Task> taskListUpdate=new List<Task>();
        //soql to get the task records with respective IP ids and the subject "EP APV Requested"
        taskListUpdate=[select id,subject,status,whatId from Task where whatId IN:instIdSet AND subject='EP APV Requested'];
        //Updating the tasks to complete
        for(Task tasks:taskListUpdate){
            tasks.status='Completed';
        }
        //updating the respective tasks
        if(!taskListUpdate.isEmpty()){
            update taskListUpdate;
        }        
    }
    
       /*****************************************************************
  Method: sendSPEmail
  Description: sendSPEmail method is to send the Email Notification to the PC field on the Execution plan
				record for all the Approved Installations.
*******************************************************************/
    private static Messaging.SingleEmailMessage sendSPEmail(final FS_Installation__c installMail){ 
        final String SUBJECT='Your execution plan approval request has been rejected for'+''+installmail.FS_Headquarters_ACN__c;
        
       final  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        final List<String> sendTo = new List<String>();
        
        sendTo.add(installMail.FS_Approval_request_submitted_by__r.Email); 
        mail.setToAddresses(sendTo); 
        mail.setTargetObjectId(installMail.FS_Approval_request_submitted_by__c);
        mail.SetSubject(SUBJECT);
        
        String body=FSConstants.BLANKVALUE;
        body=body+'Click <a href="https://fed.ko.com/freestyle">Freestyle</a>  to open the FET site.'
            +' Then click <a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' +installMail.FS_Execution_Plan__c +'">'
            +installMail.FS_Execution_Plan__r.Name +'</a>'
            +'to be directed to the specific record for reference.'
            +'<br>Reason for PM Installation Rejection :'+installmail.FS_Reason_for_Installation_Rejection__c;
        body=body.replaceAll('null',FSConstants.BLANKVALUE);
        
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);        
        return mail;
    } 
    
     /*****************************************************************
  	Method: cancel
  	Description: cancel method is to get the user back to the Execution Plan record
	*******************************************************************/
    public PageReference cancel(){
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