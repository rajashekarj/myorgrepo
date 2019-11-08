/**************************************************************************************
Apex Class Name     : FS_NonLMCaseController
Function            : This class is created for managing Non LM case custom buttons.
Author              : Infosys

Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sai            8/26/2019          This class is created for managing Non LM case custom buttons.
*************************************************************************************/

public without sharing class FS_NonLMCaseController {
    public static List<Email_Details__c> usersToBeUpdated{get;set;}
    public static transient List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
    public static final String FACT_CASE_CREATE_NOTIFICATION = 'Fact_Case_Create_Notification';
    public static final String NEW_STRING = 'New';
    public static final String PROJECT_NAME = 'Freestyle Support 2019';
    public static final String FS_NONLMCASECONTROLLER = 'FS_NonLMCaseController';
    public static final String NA = 'NA';
    public static final String MEDIUM = 'MEDIUM';
   
     /*****************************************************************************************
    	Method : getCaseDetails
    	Description : Method for fetching case record details.
    ******************************************************************************************/
    @AuraEnabled
    public static List<Case> getCaseDetails(Id caseId){
        system.debug('record Id'+caseId);
        List<Case> cs = New List<Case>();
        try{
            cs = [select Id,CaseNumber,RecordType.Name,FS_Outlet_Dispenser__r.Name,Escalate_to_Global_Center__c,Global_Center_Esca__c,Issue_Name__c,Status,LM_Sub_Status__c,FS_New_Case_Type__c,To_Account__c,Owner.Name from Case where Id =: caseId];
        }
         catch(Exception ex)
        {
            system.debug('Exception'+ex.getMessage());
            ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'getCaseDetails',NA,MEDIUM,ex,NA);
        }
        return cs;
    }
    /*****************************************************************************************
    	Method : getCaseDetails
    	Description : Method for fetching case record details.
    ******************************************************************************************/
    @AuraEnabled
    public static List<Case> getCaseDetailsAfterUpdate(Id caseId){
        List<Case> cs = New List<Case>();
        try{
            cs = [select Id,CaseNumber,RecordType.Name,FS_Outlet_Dispenser__r.Name,Escalate_to_Global_Center__c,Issue_Name__c,Status,LM_Sub_Status__c,FS_New_Case_Type__c,To_Account__c,Owner.Name from Case where Id =: caseId];
      		
        }
         catch(Exception ex)
        {
            system.debug('Exception'+ex.getMessage());
            ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'getCaseDetailsAfterUpdate',NA,MEDIUM,ex,NA);
        }
        return cs;
    }
     /*****************************************************************************************
    	Method : updateCaseDetails
    	Description : Method for updating case record details and fire case assignment rules.
    ******************************************************************************************/
    @AuraEnabled
    public static void updateCaseDetails(Case cs){
        //Fetching the assignment rules on case
        AssignmentRule ar = new AssignmentRule();
        try {
        ar = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= ar.id;
        dmlOpts.EmailHeader.triggerUserEmail = true;
        //Setting the DMLOption on Case instance
        cs.setOptions(dmlOpts);          
            update cs;  
        }
         catch(Exception ex)
        {
            system.debug('Exception'+ex.getMessage());
            ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'updateCaseDetails',NA,MEDIUM,ex,NA);
        }    
    }
    /*****************************************************************************************
    	Method : getAccountTeamMembersList
    	Description : Method to retrieve account team members list from Email_Details__c object.
    ******************************************************************************************/
     @AuraEnabled
     public static List<userDetails> getAccountTeamMembersList(Id caseId)
    {
         List<userDetails> usersInfo = New List<userDetails>();
         selectCaseDataFetch(caseId);
         usersInfo = fetchEmailDetails(caseId);
         return usersInfo;
    }
    /*****************************************************************************************
    	Method : selectCaseDataFetch
    	Description : Method for fetching values for the case record.
    ******************************************************************************************/
    public static void selectCaseDataFetch(Id caseId)
    {
        Case selectCaseData = New Case();
        try
        {
            selectCaseData = [Select Id,Status,CaseNumber,FS_Serial_Number__c,Subject,Description,FS_ACN__c,FS_SAP__c,
                              FS_Outlet_Name__c,FS_Address__c,FACT_Case_Type__c,Dispenser_serial_number__c 
                              from Case where Id=:caseId];
        }
        catch(Exception ex)
        { system.debug('System Exception : ' + ex.getMessage());   ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'selectCaseDataFetch',NA,MEDIUM,ex,NA); }
    }
    
    /*****************************************************************************************
    	Method : fetchEmailDetails
    	Description : Method to fetch the list of users from Case Email Notification object 
					  related to Case object.
    ******************************************************************************************/
    public static List<userDetails> fetchEmailDetails(Id caseId)
    {
        List<userDetails> userDetailList = new List<userDetails>();
        try
        {
            List<Email_Details__c> emailDetailList = [Select Id,User_Name__c,User_Role__c,User_Email__c,Send_Email__c,
                                                      Creation_Mail_Flag__c,Closure_Mail_Flag__c from Email_Details__c 
                                                      where Parent_Case__c=:caseId];
            if(!emailDetailList.isEmpty())
            {
                for(Email_Details__c emailList : emailDetailList)
                {
                    userDetails userRecord = new userDetails();
                    userRecord.emailDetail = emailList;
                    userRecord.userName = emailList.User_Name__c;
                    userRecord.userEmailId = emailList.User_Email__c;
                    userRecord.userRole = emailList.User_Role__c;
                    userRecord.Id = emailList.Id;
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
        catch(Exception ex)
        { system.debug('System Exception : ' + ex.getMessage());  ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'fetchEmailDetails',NA,MEDIUM,ex,NA); }
        return userDetailList;
    }
     /*****************************************************************************************
    	Method : saveAccountTeamMembersAndSendEmail
    	Description :Method to update the Account Team Members and send email to the selected 
		team members
    ******************************************************************************************/
    @AuraEnabled
    public static void saveAccountTeamMembersAndSendEmail(List<userDetails> atMembersFullList,List<id> selectedATMembers,Id caseId)
    {
        Case selectCaseData = New Case(); 
        List<userDetails> usersInfoObj=new List<userDetails>();
        try
        {
           selectCaseData = [Select Id,Status,CaseNumber,FS_Serial_Number__c,Subject,Description,FS_ACN__c,FS_SAP__c,
                                  FS_Outlet_Name__c,FS_Address__c,FACT_Case_Type__c,Dispenser_serial_number__c 
                                  from Case where Id=:caseId];
			
			Map<id,userDetails> userDetailMap = new Map <id,userDetails>();	
            //Arranging the account team members details in a Map
			for(userDetails ud:atMembersFullList){
				userDetailMap.put(ud.id,ud);	
			}
            for(Id userDetailMapID: userDetailMap.keyset()){
                //Mapping Non Selected Account Team Member details
                if(!selectedATMembers.contains(userDetailMapID)){ 
                    userDetails userDetailObj=userDetailMap.get(userDetailMapID);
                	userDetailObj.userPresent=false;
                	usersInfoObj.add(userDetailObj);
                }else{     //Mapping Selected Account Team Member details
                    userDetails userDetailObj=userDetailMap.get(userDetailMapID);
                	userDetailObj.userPresent=true;
                	usersInfoObj.add(userDetailObj);
                }
            }
			usersToBeUpdated = new List<Email_Details__c>();
            FSCaseManagementHelper helperMethod = new FSCaseManagementHelper();
            List<String> emailRolesList = helperMethod.getAllEmailRoles(true,false,false);
            Set<String> emailRolesSet = new Set<String>();
            EmailTemplate template = [SELECT Id,HtmlValue,Body,Subject FROM EmailTemplate WHERE 
                                      developername =: FACT_CASE_CREATE_NOTIFICATION];
            emailRolesSet.addAll(emailRolesList);
            
            if(!usersInfoObj.isEmpty())
            {
                for(userDetails user : usersInfoObj)
                {
                  checkUserPresent(user,emailRolesSet,template,selectCaseData);
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
        catch(Exception ex)
        {  system.debug('system Exception : ' + ex.getMessage());  ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'saveAccountTeamMembersAndSendEmail',NA,MEDIUM,ex,NA);  }
        
    } 
    /*****************************************************************************************
    	Method : deleteNonLMCase
    	Description :Method to Delete Non LM case
    ******************************************************************************************/
    @AuraEnabled
    public static void deleteNonLMCase(Id caseId){
        List<Case> deleteCase = New List<Case>();
        deleteCase = [select Id from Case where id=:caseId];
        try{
            Delete deleteCase;
        }
         catch(Exception ex)
        { system.debug('system Exception : ' + ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'deleteNonLMCase',NA,MEDIUM,ex,NA); }
    }
    /*****************************************************************************************
    	Method : checkUserPresent
    	Description : Method to check the users for whom case creation mail has to be sent 
					  and call the mail sending method.
    ******************************************************************************************/
    public static void checkUserPresent(userDetails user,Set<String> emailRolesSet,EmailTemplate template,case selectCaseData)
    {
        List<Messaging.SingleEmailMessage> mailList1 = new List<Messaging.SingleEmailMessage>();
        try
        {
            
            if(user.userPresent)
            {
				                        
                if(selectCaseData.status == NEW_STRING && user.emailDetail.Creation_Mail_Flag__c != true)
                {
                    if(!emailRolesSet.isEmpty() && emailRolesSet.contains(user.userRole))
                    {
                        user.emailDetail.Creation_Mail_Flag__c = true;
                        user.emailDetail.Send_Email__c = true;
                        usersToBeUpdated.add(user.emailDetail);
                        Messaging.SingleEmailMessage newMail= FS_SendEmail_Helper.replaceMergeFieldValues(user.userName,user.userEmailId,
                                                                                 template,selectCaseData,false,null,null,false);
                        List<string> dummy = new List<string>();
                        mailList.add(newMail);
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
        catch(Exception ex)
        { system.debug('System Exception : ' + ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'checkUserPresent',NA,MEDIUM,ex,NA);}
    }
    /*****************************************************************************************
    	Method : getLoggedinUserDetails
    	Description : Method to get current logged in user details.
    ******************************************************************************************/
    @AuraEnabled
    Public static User getLoggedinUserDetails(){
        Id loggedInUserId = userInfo.getUserId();
        User userDetails = New User();
        try{
           userDetails = [select Id,Profile.Name,Related_Permission_Set__c from User where id =:loggedInUserId ];
        }
		 catch(Exception ex)
        { system.debug('System Exception : ' + ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_NONLMCASECONTROLLER,'getLoggedinUserDetails',NA,MEDIUM,ex,NA);}
        return userDetails;
    }
     /*****************************************************************************************
    	Method : checkCommunity
    	Description : Method to return site id in case of communities
    ******************************************************************************************/
    @AuraEnabled
    public static String checkCommunity(){
        String  siteId = Site.getSiteType();
        return siteId;
    }
    /*****************************************************************************************
    	Wrapper Class : userDetails
    	Description : Wrapper class to bind checkbox and user details.
    ******************************************************************************************/
    public class userDetails
    {
        @AuraEnabled
        public Email_Details__c emailDetail{get;set;}
        @AuraEnabled
        public String userName{get;set;}
        @AuraEnabled
        public String userEmailId{get;set;}
        @AuraEnabled
        public String userRole{get;set;}
        @AuraEnabled
        public Boolean userPresent{get;set;}
        @AuraEnabled
        Public ID Id{get;set;}
    } 
    
}