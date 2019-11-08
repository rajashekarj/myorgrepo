/**************************************************************************************
Apex Class Name     : FS_EmailUserListController
Function            : This is a controller class for FS_VF_EmailUserList visual force page.
					  This class is used to update the user list in Case Email Notification object connected to Case object.
					  Also this class is used for sending case creation email to selected users.
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD	          07/25/2017       Original Version for implementing send email functionality for FACT cases.
*************************************************************************************/

public class FS_EmailUserListController {
    
    public Case caseData{get;set;}
    public Case selectCaseData{get;set;}
    public Id caseID {get;set;}
    public List<userDetails> usersInfo{get;set;}
    public List<Email_Details__c> usersToBeUpdated{get;set;}
    public transient List<Messaging.SingleEmailMessage> mailList;
    public static final String Fact_Case_Create_Notification = 'Fact_Case_Create_Notification';
    public static final String New_String = 'New';
    public static final String Project_Name = 'Freestyle Support 2017';
    public static final String FS_EmailUserListController = 'FS_EmailUserListController';
    public static final String NA = 'NA';
    public static final String Medium = 'Medium';
    public static final String selectCaseDataFetch = 'selectCaseDataFetch';
    public static final String fetchEmailDetails = 'fetchEmailDetails';
    public static final String saveSendEmail = 'saveSendEmail';
    public static final String checkUserPresent = 'checkUserPresent';
    public static final String FS_EmailUserListControllerConst = 'FS_EmailUserListController';
    
    public FS_EmailUserListController(ApexPages.StandardController controller)
    {
        try
        {
            caseID = apexpages.currentpage().getparameters().get('id');
            this.caseData = [Select Id from Case where Id=:caseID];
            selectCaseDataFetch();
            usersInfo = fetchEmailDetails();
        }
        catch(Exception ex)
        {
            system.debug('Exception'+ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_EmailUserListController,FS_EmailUserListControllerConst,NA,Medium,ex,NA);
        }
    }
    
    /*****************************************************************************************
    	Method : selectCaseDataFetch
    	Description : Method for fetching values for the case record.
    ******************************************************************************************/
    public void selectCaseDataFetch()
    {
        try
        {
            selectCaseData = [Select Id,Status,CaseNumber,FS_Serial_Number__c,Subject,Description,FS_ACN__c,FS_SAP__c,
                              FS_Outlet_Name__c,FS_Address__c,FACT_Case_Type__c,Dispenser_serial_number__c 
                              from Case where Id=:caseData.Id];
        }
        catch(System.QueryException ex)
        {
            system.debug('System.QueryException : ' + ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_EmailUserListController,selectCaseDataFetch,NA,Medium,ex,NA);
        }
    }
    
    /*****************************************************************************************
    	Method : fetchEmailDetails
    	Description : Method to fetch the list of users from Case Email Notification object 
					  related to Case object.
    ******************************************************************************************/
    public List<userDetails> fetchEmailDetails()
    {
        List<userDetails> userDetailList = new List<userDetails>();
        try
        {
            List<Email_Details__c> emailDetailList = [Select Id,User_Name__c,User_Role__c,User_Email__c,Send_Email__c,
                                                      Creation_Mail_Flag__c,Closure_Mail_Flag__c from Email_Details__c 
                                                      where Parent_Case__c=:caseData.Id];
            if(!emailDetailList.isEmpty())
            {
                for(Email_Details__c emailList : emailDetailList)
                {
                    userDetails userRecord = new userDetails();
                    userRecord.emailDetail = emailList;
                    userRecord.userName = emailList.User_Name__c;
                    userRecord.userEmailId = emailList.User_Email__c;
                    userRecord.userRole = emailList.User_Role__c;
                    if(emailList.Send_Email__c)
                    {
                        userRecord.userPresent = true;
                    }
                    else
                    {
                        userRecord.userPresent = false;
                    }
                    
                    userDetailList.add(userRecord);
                }
            }
        }
        catch(System.QueryException ex)
        {
            system.debug('System.QueryException : ' + ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_EmailUserListController,fetchEmailDetails,NA,Medium,ex,NA);
        }
        return userDetailList;
    }
    
    /*****************************************************************************************
    	Method : saveSendEmail
    	Description : Method to save the users selected from visual force page and send 
					  case creation email if mail notification has not sent previously.
    ******************************************************************************************/
    public pageReference saveSendEmail()
    {
        try
        {
            usersToBeUpdated = new List<Email_Details__c>();
            mailList = new List<Messaging.SingleEmailMessage>();
            FSCaseManagementHelper helperMethod = new FSCaseManagementHelper();
            List<String> emailRolesList = helperMethod.getAllEmailRoles(true,false,false);
            Set<String> emailRolesSet = new Set<String>();
            EmailTemplate template = [SELECT Id,HtmlValue,Body,Subject FROM EmailTemplate WHERE 
                                      developername =: Fact_Case_Create_Notification];
            emailRolesSet.addAll(emailRolesList);
            
            if(!usersInfo.isEmpty())
            {
                for(userDetails user : usersInfo)
                {
                    checkUserPresent(user,emailRolesSet,template);
                }
            }
            if(!mailList.isEmpty())
            {
                Messaging.SendEmail(mailList);
            }
            if(!usersToBeUpdated.isEmpty())
            {
                update usersToBeUpdated;
            }
        }
        catch(system.EmailException ex)
        {
            system.debug('system.EmailException : ' + ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_EmailUserListController,saveSendEmail,NA,Medium,ex,NA);
        }
        //return new PageReference('javascript:window.opener.location.reload(); window.self.close();');
        return new PageReference('javascript:window.self.close();');
    }
    
    /*****************************************************************************************
    	Method : checkUserPresent
    	Description : Method to check the users for whom case creation mail has to be sent 
					  and call the mail sending method.
    ******************************************************************************************/
    public void checkUserPresent(userDetails user,Set<String> emailRolesSet,EmailTemplate template)
    {
        try
        {
            if(user.userPresent)
            {
                if(selectCaseData.status == New_String && user.emailDetail.Creation_Mail_Flag__c != true)
                {
                    if(!emailRolesSet.isEmpty() && emailRolesSet.contains(user.userRole))
                    {
                        user.emailDetail.Creation_Mail_Flag__c = true;
                        user.emailDetail.Send_Email__c = true;
                        usersToBeUpdated.add(user.emailDetail);
                        mailList.add(FS_SendEmail_Helper.replaceMergeFieldValues(user.userName,user.userEmailId,
                                                                                 template,selectCaseData,false,null,null,false));
                    }
                    else
                    {
                        user.emailDetail.Send_Email__c = true;
                        usersToBeUpdated.add(user.emailDetail);
                    }
                }
                else
                {
                    user.emailDetail.Send_Email__c = true;
                    usersToBeUpdated.add(user.emailDetail);
                }
            }
            else
            {
                user.emailDetail.Send_Email__c = false;
                usersToBeUpdated.add(user.emailDetail);
            }
        }
        catch(NullPointerException ex)
        {
            system.debug('NullPointerException : ' + ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_EmailUserListController,checkUserPresent,NA,Medium,ex,NA);
        }
    }
    
    public class userDetails
    {
        public Email_Details__c emailDetail{get;set;}
        public String userName{get;set;}
        public String userEmailId{get;set;}
        public String userRole{get;set;}
        public Boolean userPresent{get;set;}
    }

}