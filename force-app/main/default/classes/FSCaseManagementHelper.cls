/**************************************************************************************
Apex Class Name     : FSCaseManagementHelper
Function            : This class is created as an helper class for Case and Case Comment triggers.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD            07/25/2017       Updated the class for implementing automatic emails on Case Closure and Case Comment.
*************************************************************************************/
public without sharing class FSCaseManagementHelper { 
    public Map<ID,ID> caseHQMap{get;set;}
    public Map<ID,Case> oldCaseMap{get;set;}
    public Map<ID,Case> newCaseMap{get;set;}
    public Map<ID,String> oldSerialNumber{get;set;}
    public Map<String,String> oldSerialNumberMap{get;set;}
    public Map<ID,ID> oldOutletDispenser{get;set;}
    public Map<ID,ID> newOutletDispenser{get;set;}
    public List<CaseToOutletdispenser__c> deleteList{get;set;}
    public Boolean queryExcep{get;set;}
    public static final String COMPLETED = 'Completed';
    public static final String CLOSED = 'Closed';
    public static final String CONNECTIVITYSOLUTION = 'Connectivity Solution';
    public static final String FACTCASECLOSEDNOTIFICATION = 'Fact_Case_Closed_Notification';
    public static final String FACTCASECOMMENTNOTIFICATION = 'Fact_Case_Comment_Notification';
    public static final String NONNORTHAMERICANCASE = 'Non - North American Case';
    public static final String NORTHAMERICANCASE = 'North American Case';
    public static final String LINKAGEMANAGEMENT = 'Linkage Management';
    public static final String PROJECTNAME = 'Freestyle Support 2017';
    public static final String FSCASEMANAGEMENTHELPER = 'FSCaseManagementHelper';
    public static final String NA = 'NA';
    public static final String MEDIUM = 'Medium';
    public static final String CHECKOPENTASK = 'checkOpenTask';
    public static final String GETALLEMAILROLES = 'getAllEmailRoles';
    public static final String CASEID = 'caseID';
    public static final String HQDETAILS = 'hqDetails';
    public static final String INSERTEMAILROLES = 'insertEmailRoles';
    public static final String CREATECASEHISTORY = 'createCaseHistory';
    public static final String CASEIDMAP = 'caseIdMap';
    public static final String CASEEMAILDETAILS = 'caseEmailDetails';
    public static final String SENDMAIL = 'sendMail';
    public static final String SENDMAILONCASECLOSE = 'sendMailOnCaseClose';
    public static final String SENDMAILONCASECOMMENT = 'sendMailOnCaseComment';
    public static final String CASEIDMAPEMT = 'caseIDMapEMT';
    public static final String CASERELATEDDETAILS = 'caseRelatedDetails';
    public static final String INSERTUPDATEEMTCASES = 'insertUpdateEMTCases';
    public static final String INSERTOUTLETDISPENSER = 'insertOutletDispenser';
    public static final String CASEMAPEMTDETAILS = 'caseMapEMTDetails';
    public static final String UPDATEDELETELIST = 'updateDeleteList';
    public static final String DELETEOLDDISPENSERDATA = 'deleteOldDispenserData';
    public static final String INSERTEMTCASES = 'insertEMTCases';
    public static final String UPDATEOUTLETDISPENSER = 'updateOutletDispenser';
    public static final String CREATEHISTORY = 'CreateHistory';
    public static final String UPDATEHISTORY = 'UpdateHistory';
    public static final String CASEIDDETAILS = 'caseIDDetails';
    public static final String HQLIST = 'hqList';
    public static final String COMPAREHQ = 'compareHQ';
    public static final String DELETENOTIFICATIONUSERS = 'deleteNotificationUsers';
    public static final String DELETECASENOTIFICATION = 'deleteCaseNotification';
    public static final String CASEMAPCREATION = 'caseMapCreation';
    public static final String CASECOMMENTUPDATE = 'caseCommentUpdate';
    public static final String CHECKTASK = 'checkTask';
    public static final String SENDEMAILTOEXTERNAL = 'sendEmailToExternal';
    public static final String POPULATESERIALNUMBERONLMCASE = 'populateSerialNumbersOnLMCase';
    public static final String POPULATECASEFIELDSFROMOD = 'populateCaseFieldsfromOD';
    public static final String POPULATESTATICCASEFIELDS = 'populateStaticCaseFields';
    public static final String FETCHTASK = 'Error while fetching the Open Tasks associated with the Case';
    public static Boolean flag=false;
    public static final String AMOAFROM = 'AMOA From';
    
    
    /*****************************************************************************************
Method : checkOpenTask
Description : Method to get the list of open tasks linked with case.
******************************************************************************************/
    public List<Task> checkOpenTask(Set<ID> caseIDs){
        List<Task> taskList=new List<Task>();
        try
        {   
            queryExcep = false;
            taskList=[Select Id,status,whatId from Task where WhatId in :caseIDs and status!=:COMPLETED];   
        }
        catch(System.QueryException ex)
        { queryExcep = true; ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CHECKOPENTASK,NA,MEDIUM,ex,NA);}
        return taskList;
    }
    
    /*****************************************************************************************
Method : getAllEmailRoles
Description : Method to get the list of Roles for which Email functionality 
has to be enabled
******************************************************************************************/
    public List<String> getAllEmailRoles(Boolean createFlag, Boolean closeFlag, Boolean commentFlag)
    {
        List<String> rolesList = new List<String>();
        try
        {
            List<Fact_EmailRoles__c> emailRoles = Fact_EmailRoles__c.getAll().values();
            for(Fact_EmailRoles__c role : emailRoles)
            {
                if(createFlag == true && role.Case_Create__c == true)
                {
                    rolesList.add(role.Role_Name__c);
                }
                else if(closeFlag == true && role.Case_Close__c == true)
                {
                    rolesList.add(role.Role_Name__c);
                }
                else if(commentFlag == true && role.Case_Comment__c == true)
                {
                    rolesList.add(role.Role_Name__c);
                }
                else if(createFlag == false && closeFlag == false && commentFlag == false)
                {
                    rolesList.add(role.Role_Name__c);
                }
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,GETALLEMAILROLES,NA,MEDIUM,ex,NA);}
        return rolesList;
    }
    
    /*****************************************************************************************
Method : caseID
Description : Method to extract the list of Case ID's for FACT cases
******************************************************************************************/
    public List<ID> caseID(List<Case> caseList)
    {
        List<ID> caseIDList = new List<ID>();
        try
        {
            Id connectivitySolutionRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get(CONNECTIVITYSOLUTION).getRecordTypeId();
            for(Case caseRecord : caseList)
            {
                if(caseRecord.RecordTypeId == connectivitySolutionRecordTypeID)
                {
                    caseIDList.add(caseRecord.ID);
                }
            }
        }
        catch(NullPointerException ex)
        {ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASEID,NA,MEDIUM,ex,NA);}
        return caseIDList;
    }
    
    /*****************************************************************************************
Method : hqDetails
Description : Method to extract the list Head Quarters ID's related to the Cases
******************************************************************************************/
    public List<ID> hqDetails(List<ID> idList)
    {
        List<ID> hqList = new List<ID>();
        try
        {
            List<Case> hqDetails = new List<Case>();
            caseHQMap = new MAP<ID,ID>();
            hqDetails = [select ID,FS_Outlet_Dispenser__r.FS_Outlet__c,FS_Outlet_Dispenser__r.FS_Outlet__r.FS_Headquarters__c
                         from case where Id in :idList];
            if(!hqDetails.isEmpty())
            {
                for(Case c : hqDetails)
                {
                    hqList.add(c.FS_Outlet_Dispenser__r.FS_Outlet__r.FS_Headquarters__c);
                    caseHQMap.put(c.ID,c.FS_Outlet_Dispenser__r.FS_Outlet__r.FS_Headquarters__c);
                }
            }
        }
        catch(System.QueryException ex)
        {ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,HQDETAILS,NA,MEDIUM,ex,NA);}
        return hqList;
    }
    
    /*****************************************************************************************
Method : insertEmailRoles
Description : Method to insert the extracted Account Team Members into 
Case Email notification list for whom the email has to be sent.
******************************************************************************************/
    public void insertEmailRoles(Map<ID,ID> hqCase, Map<ID,List<AccountTeamMember__c>> members)
    {
        try
        {
            List<Email_Details__c> insertValues = new LIst<Email_Details__c>();        
            for(ID c : hqCase.keySet())
            {
                if(members.containsKey(hqCase.get(c)))
                {
                    for(AccountTeamMember__c ac : members.get(hqCase.get(c)))
                    {
                        Email_Details__c emailValue = new Email_Details__c();
                        emailValue.Parent_Case__c = c;
                        emailValue.User_Email__c = ac.UserId__r.email;
                        emailValue.User_Name__c = (ac.UserId__r.firstName != null ? ac.UserId__r.firstName + ' ' : '') + ac.UserId__r.lastName;
                        emailValue.User_Role__c = ac.TeamMemberRole__c;
                        insertValues.add(emailValue);
                    }
                    
                }
            }
            Insert insertValues;
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,INSERTEMAILROLES,NA,MEDIUM,ex,NA); }
        catch(DmlException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,INSERTEMAILROLES,NA,MEDIUM,ex,NA); }
    }
    
    /*****************************************************************************************
Method : createCaseHistory
Description : Method to get the list of Case ID's and map the same with 
Head Quarter ID's and call insertEmailRoles method to insert the
account team members into Case Email Notification object.
******************************************************************************************/
    public void createCaseHistory(List<String> listOfRoles,List<Case> newList)
    {
        try
        {
            List<ID> caseIDDetails = new List<ID>();
            List<ID> hqIDList = new List<ID>();
            List<AccountTeamMember__c> teamMembers = new List<AccountTeamMember__c>();
            Map<ID,List<AccountTeamMember__c>> teamMemberMap = new Map<ID,List<AccountTeamMember__c>>();
            
            if(!newList.isEmpty())
            {
                //Calling a method to get the list of Cases.
                caseIDDetails = caseID(newList);
            }
            if(!caseIDDetails.isEmpty())
            {
                //Calling a method to get the head quarters details corresponding to Case records.
                hqIDList = hqDetails(caseIDDetails);
                
                //Fetching Account Team members associated with head quarters.
                teamMembers = [select Id,Name,UserId__r.email,UserId__r.firstName,UserId__r.lastName,AccountId__c,
                               TeamMemberRole__c from AccountTeamMember__c where AccountId__c IN: hqIDList and
                               TeamMemberRole__c IN: listOfRoles]; 
                
                for(AccountTeamMember__c accountMember : teamMembers)
                {
                    if(teamMemberMap.containsKey(accountMember.AccountId__c))
                    {
                        teamMemberMap.get(accountMember.AccountId__c).add(accountMember);
                    }
                    else
                    {
                        List<AccountTeamMember__c> acMember = new List<AccountTeamMember__c>();
                        acMember.add(accountMember);
                        teamMemberMap.put(accountMember.AccountId__c,acMember);
                    }
                }
                
                //Calling a method to insert the Account Team Members into Case Email Notification object.
                insertEmailRoles(caseHQMap,teamMemberMap);
            }
        }
        catch(DmlException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CREATECASEHISTORY,NA,MEDIUM,ex,NA); }
    }
    
    /*****************************************************************************************
Method : caseIdMap
Description : Method to extract the list of cases recieved as parameter and create 
a map for the same.
******************************************************************************************/
    public Map<ID,Case> caseIdMap(List<Case> caseList)
    {
        Map<ID,Case> caseMap = new Map<ID,Case>();
        try
        {
            Id connectivitySolutionRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get(CONNECTIVITYSOLUTION).getRecordTypeId();
            for(Case caseRecord : caseList)
            {
                if(caseRecord.RecordTypeId == connectivitySolutionRecordTypeID)
                {
                    caseMap.put(caseRecord.Id,caseRecord);
                }
            }
        }
        catch(NullPointerException ex)
        {  ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASEIDMAP,NA,MEDIUM,ex,NA); }
        return caseMap;
    }
    
    /*****************************************************************************************
Method : caseEmailDetails
Description : Method to create a map of Case Email Notification based on the 
selected roles.
******************************************************************************************/
    public Map<ID,List<Email_Details__c>> caseEmailDetails(Map<ID,Case> caseMapDetails,List<String> rolesList)
    {
        Map<ID,List<Email_Details__c>> caseEmailNotificationMap = new Map<ID,List<Email_Details__c>>();
        try
        {
            List<Email_Details__c> caseEmailNotificationList = new List<Email_Details__c>();
            caseEmailNotificationList = [Select Id,Closure_Mail_Flag__c,Send_Email__c,User_Email__c,User_Name__c,
                                         User_Role__c,Parent_Case__c from Email_Details__c where 
                                         Parent_Case__c IN: caseMapDetails.keySet() and User_Role__c IN: rolesList 
                                         and Send_Email__c = true];
            if(!caseEmailNotificationList.isEmpty())
            {
                for(Email_Details__c emailNotification : caseEmailNotificationList)
                {
                    if(caseEmailNotificationMap.containsKey(emailNotification.Parent_Case__c))
                    {
                        caseEmailNotificationMap.get(emailNotification.Parent_Case__c).add(emailNotification);
                    }
                    else
                    {
                        List<Email_Details__c> emailDetailList = new List<Email_Details__c>();
                        emailDetailList.add(emailNotification);
                        caseEmailNotificationMap.put(emailNotification.Parent_Case__c,emailDetailList);
                    }
                }
            }
        }
        catch(System.QueryException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASEEMAILDETAILS,NA,MEDIUM,ex,NA); }
        return caseEmailNotificationMap;
    }
    
    /*****************************************************************************************
Method : sendMail
Description : Method to send mail for the selected users when a case is closed and 
to update Case Email Notification records based on the email sent.
******************************************************************************************/
    public void sendMail(Map<ID,List<Email_Details__c>> caseEmail,Map<ID,Case> caseDetailsMap)
    {
        try
        {
            List<Email_Details__c> userUpdateList = new List<Email_Details__c>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate template = [SELECT Id,HtmlValue,Body,Subject FROM EmailTemplate WHERE 
                                      developername =: FACTCASECLOSEDNOTIFICATION];
            for(ID caseId : caseEmail.keySet())
            {
                List<Email_Details__c> emailUserList = caseEmail.get(caseId);
                for(Email_Details__c userList : emailUserList)
                {
                    if(userList.Closure_Mail_Flag__c != true)
                    {
                        userList.Closure_Mail_Flag__c = true;
                        userUpdateList.add(userList);
                        mailList.add(FS_SendEmail_Helper.replaceMergeFieldValues(userList.User_Name__c,userList.User_Email__c,template,caseDetailsMap.get(caseId),false,null,null,true));
                    }
                }
            }
            if(!mailList.isEmpty())
            {
                Messaging.SendEmail(mailList);
            }
            if(!userUpdateList.isEmpty())
            {
                update userUpdateList;
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,SENDMAIL,NA,MEDIUM,ex,NA); }
        catch(system.EmailException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,SENDMAIL,NA,MEDIUM,ex,NA); }
    }
    
    /*****************************************************************************************
Method : sendMailOnCaseClose
Description : Method called in after update method of case trigger for sending email 
on case closure. This method recieves roles list and case list as 
input parameters.
******************************************************************************************/
    public void sendMailOnCaseClose(List<String> listOfRoles,List<Case> newList)
    {
        try
        {
            Map<ID,Case> caseDetails = new Map<ID,Case>();
            List<Case> listCase = new List<Case>();
            Map<ID,List<Email_Details__c>> caseEmailNotify = new Map<ID,List<Email_Details__c>>();
            if(!newList.isEmpty())
            {
                //Looping to get all the Case records whose status is closed.
                for(Case caseRecord : newList)
                {
                    if(caseRecord.Status == CLOSED)
                    {
                        listCase.add(caseRecord);
                    }
                }
                if(!listCase.isEmpty())
                {
                    //Calling a method to get the Case details in a Map.
                    caseDetails = caseIdMap(listCase);
                }
            }
            if(!caseDetails.isEmpty())
            {
                //Calling a method to get all members for whom email has to be sent.
                caseEmailNotify = caseEmailDetails(caseDetails,listOfRoles);
                
                if(!caseEmailNotify.isEmpty())
                {
                    //Calling a method to send case closure email for selected users.
                    sendMail(caseEmailNotify,caseDetails);
                }
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,SENDMAILONCASECLOSE,NA,MEDIUM,ex,NA);}
    }
    
    /*****************************************************************************************
Method : sendMailOnCaseComment
Description : Method called in after insert method of case comment trigger for 
sending email on adding a case comment. This method recieves roles list,
case list and a map containing the comments as input parameters.
******************************************************************************************/
    public void sendMailOnCaseComment(List<String> listOfRoles,List<Case> newList,Map<Id,caseComment> caseComments,Map<Id,String> creatorName)
    {
        try
        {
            Map<ID,Case> caseDetails = new Map<ID,Case>();
            Map<ID,List<Email_Details__c>> caseEmailNotify = new Map<ID,List<Email_Details__c>>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate template = [SELECT Id,HtmlValue,Body,Subject FROM EmailTemplate WHERE 
                                      developername =: FACTCASECOMMENTNOTIFICATION];
            
            if(!newList.isEmpty())
            {
                //Calling a method to get the Case details in a Map.
                caseDetails = caseIdMap(newList);
            }
            if(!caseDetails.isEmpty())
            {
                //Calling a method to get all members for whom email has to be sent.
                caseEmailNotify = caseEmailDetails(caseDetails,listOfRoles);
                if(!caseEmailNotify.isEmpty())
                {
                    for(ID caseId : caseEmailNotify.keySet())
                    {
                        List<Email_Details__c> emailUserList = caseEmailNotify.get(caseId);
                        for(Email_Details__c userList : emailUserList)
                        {
                            //Calling a method to List the emails that has to be sent.
                            mailList.add(FS_SendEmail_Helper.replaceMergeFieldValues(userList.User_Name__c,userList.User_Email__c,template,caseDetails.get(caseId),true,caseComments.get(caseId).commentBody,creatorName.get(caseId),false));
                        }
                    }
                }
            }
            if(!mailList.isEmpty())
            {  Messaging.SendEmail(mailList); }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,SENDMAILONCASECOMMENT,NA,MEDIUM,ex,NA); }
        catch(system.EmailException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,SENDMAILONCASECOMMENT,NA,MEDIUM,ex,NA);}
    }
    
    /*****************************************************************************************
Method : caseCommentUpdate
Description : Method called when Case Comment is inserted or updated.
******************************************************************************************/
    public void caseCommentUpdate(List<CaseComment> newList)
    {
        try
        {
            Map<Id,caseComment> commentCaseIds = new Map<Id,caseComment>();
            List<Id> caseCommentId = new List<Id>();
            List<Case> caseList = new List<Case>();
            List<String> emailRolesList = new List<String>();
            List<CaseComment> caseCommentCreator = new List<CaseComment>();
            Map<Id,String> commentCreatorName = new Map<Id,String>();
            for(CaseComment comment : newList)
            {
                commentCaseIds.put(comment.ParentId,comment);
                caseCommentId.add(comment.Id);
            }
            
            caseCommentCreator = [select Id,ParentId,CreatedBy.Name from CaseComment where Id IN: caseCommentId];
            for(CaseComment commentRecord : caseCommentCreator)
            {
                commentCreatorName.put(commentRecord.ParentId,commentRecord.CreatedBy.Name);
            }
            
            caseList = [select Id,Status,CaseNumber,FS_Serial_Number__c,Subject,Description,FS_ACN__c,FS_Outlet_Name__c,
                        FS_Address__c,FS_SAP__c,FACT_Case_Type__c,RecordTypeId,FS_Comment_Created_By_Username__c,
                        Dispenser_serial_number__c from case where ID IN: commentCaseIds.keySet()];        
            emailRolesList = getAllEmailRoles(false,false,true);
            
            sendMailOnCaseComment(emailRolesList,caseList,commentCaseIds,commentCreatorName);
        }
        catch(System.QueryException ex)
        {  ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASECOMMENTUPDATE,NA,MEDIUM,ex,NA); }
    }
    
    /*****************************************************************************************
Method : caseIDDetails
Description : Method for fetching FACT Case records and Outlet Dispenser values for those 
cases whose Outlet Dispenser is changed.
******************************************************************************************/
    public Map<Id,Case> caseIDDetails(List<Case> oldCaseList, List<Case> newCaseList)
    {
        Map<Id,Case> caseIdList = new Map<Id,Case>();
        try
        {
            oldOutletDispenser = new Map<ID,ID>();
            newOutletDispenser = new Map<ID,ID>();
            Id connectivitySolutionRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get(CONNECTIVITYSOLUTION).getRecordTypeId();
            for(Case oldRecord : oldCaseList)
            {
                for(Case newRecord : newCaseList)
                {
                    if(oldRecord.Id == newRecord.Id && oldRecord.FS_Outlet_Dispenser__c != newRecord.FS_Outlet_Dispenser__c)
                    {
                        if(newRecord.RecordTypeId == connectivitySolutionRecordTypeID)
                        {
                            caseIdList.put(newRecord.Id,newRecord);
                            oldOutletDispenser.put(oldRecord.Id,oldRecord.FS_Outlet_Dispenser__c);
                            newOutletDispenser.put(newRecord.Id,newRecord.FS_Outlet_Dispenser__c); }
                    }
                }
            }
        }
        catch(NullPointerException ex)
        {  ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASEIDDETAILS,NA,MEDIUM,ex,NA); }
        return caseIdList;
    }
    
    /*****************************************************************************************
Method : hqList
Description : Method for fetching Head Quarter details of selected Case records.
******************************************************************************************/
    public Map<Id,FS_Outlet_Dispenser__c> hqList(Map<Id,Id> outletDispenserRecord)
    {
        Map<Id,FS_Outlet_Dispenser__c> returnOD = new Map<Id,FS_Outlet_Dispenser__c>();
        try
        {
            List<Id> odID = new List<Id>();
            List<FS_Outlet_Dispenser__c> odRecords = new List<FS_Outlet_Dispenser__c>();
            for(Id caseId : outletDispenserRecord.keySet())
            {
                odID.add(outletDispenserRecord.get(caseId));
            }
            if(!odID.isEmpty())
            {
                odRecords = [select Id,FS_Outlet__r.FS_Headquarters__c from FS_Outlet_Dispenser__c where Id IN: odID];
            }
            if(!odRecords.isEmpty())
            {
                for(Id caseId : outletDispenserRecord.keySet())
                {
                    for(FS_Outlet_Dispenser__c od : odRecords)
                    {
                        if(outletDispenserRecord.get(caseId) == od.Id)
                        {
                            returnOD.put(caseId,od);
                        }
                    }
                }
            }
        }
        catch(System.QueryException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,HQLIST,NA,MEDIUM,ex,NA); }
        return returnOD;
    }
    
    /*****************************************************************************************
Method : compareHQ
Description : Method for comparing Head Quarter details of old and updated values of Case record.
******************************************************************************************/
    public List<Id> compareHQ(Map<Id,FS_Outlet_Dispenser__c> oldMap, Map<Id,FS_Outlet_Dispenser__c> newMap)
    {
        List<Id> caseToODDelete = new List<Id>();
        try
        {
            for(Id oldCase : oldMap.keySet())
            {
                for(Id newCase : newMap.keySet())
                {
                    if(oldCase == newCase)
                    {
                        FS_Outlet_Dispenser__c oldOD = oldMap.get(oldCase);
                        FS_Outlet_Dispenser__c newOD = newMap.get(newCase);
                        if(oldOD != null && newOD != null && 
                           oldOD.FS_Outlet__r.FS_Headquarters__c != newOD.FS_Outlet__r.FS_Headquarters__c)
                        {
                            caseToODDelete.add(oldCase);
                        }
                    }
                }
            }
        }
        catch(NullPointerException ex)
        {   ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,COMPAREHQ,NA,MEDIUM,ex,NA);}
        return caseToODDelete;
    }
    
    /*****************************************************************************************
Method : deleteNotificationUsers
Description : Method for deleting old Case Email Notification records and invokes the method 
for creating new Case Email Notification records based on new HeadQuarter detail.
******************************************************************************************/
    public void deleteNotificationUsers(Map<Id,Case> caseIDMap,List<Id> deleteList)
    {
        try
        {
            List<Email_Details__c> deleteNotificationList = new List<Email_Details__c>();
            List<Case> caseList = new List<Case>();
            Set<Id> caseSet = new Set<Id>();
            List<Email_Details__c> emailList = [select Id,Parent_Case__c from Email_Details__c 
                                                where Parent_Case__c IN: deleteList];
            if(!emailList.isEmpty())
            {
                for(Email_Details__c emailDetail : emailList)
                {
                    Case caseRecord = caseIDMap.get(emailDetail.Parent_Case__c);
                    deleteNotificationList.add(emailDetail);
                    if(!caseSet.contains(caseRecord.Id))
                    {
                        caseSet.add(caseRecord.Id);
                        caseList.add(caseRecord);
                    }
                }
            }
            if(!deleteNotificationList.isEmpty())
            {
                
                
                delete deleteNotificationList;
            }
            if(!caseList.isEmpty())
            {
                List<String> emailRolesList = getAllEmailRoles(false,false,false);
                createCaseHistory(emailRolesList,caseList);
            }
        }
        catch(System.QueryException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,DELETENOTIFICATIONUSERS,NA,MEDIUM,ex,NA);}
    }
    
    /*****************************************************************************************
Method : deleteCaseNotification
Description : Method called for deleting Case Email Notification records in after update 
method of Case Trigger.
******************************************************************************************/
    public void deleteCaseNotification(List<Case> oldList, List<Case> newList)
    {
        try
        {
            Map<Id,Case> caseIDList = new Map<Id,Case>();
            Map<Id,FS_Outlet_Dispenser__c> oldODRecords = new Map<Id,FS_Outlet_Dispenser__c>();
            Map<Id,FS_Outlet_Dispenser__c> newODRecords = new Map<Id,FS_Outlet_Dispenser__c>();
            List<Id> deleteCaseList = new List<Id>();
            if(!oldList.isEmpty() && !newList.isEmpty())
            {
                caseIDList = caseIDDetails(oldList,newList);
            }
            if(!oldOutletDispenser.isEmpty())
            {
                oldODRecords = hqList(oldOutletDispenser);
            }
            if(!newOutletDispenser.isEmpty())
            {
                newODRecords = hqList(newOutletDispenser);
            }
            if(!oldODRecords.isEmpty() && !newODRecords.isEmpty())
            {
                deleteCaseList = compareHQ(oldODRecords,newODRecords);
            }
            if(!deleteCaseList.isEmpty() && !caseIDList.isEmpty())
            {
                deleteNotificationUsers(caseIDList,deleteCaseList);
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,DELETECASENOTIFICATION,NA,MEDIUM,ex,NA);}
    }
    
    /*****************************************************************************************
Method : caseIDMapEMT
Description : Method to extract the list of EMT Cases and create a map for the same.
******************************************************************************************/
    public Map<ID,Case> caseIDMapEMT(List<Case> caseRecords)
    {
        Map<ID,Case> caseMap = new Map<ID,Case>();
        try
        {
            //Id nonNorthAmericanRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get(NONNORTHAMERICANCASE).getRecordTypeId();
            //Id northAmericanRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get(NORTHAMERICANCASE).getRecordTypeId();
            for(Case caseRecord : caseRecords)
            {
                //if(caseRecord.RecordTypeId == nonNorthAmericanRecordTypeID || caseRecord.RecordTypeId == northAmericanRecordTypeID)
                //{
                caseMap.put(caseRecord.Id,caseRecord);
                //}
            }
        }
        catch(NullPointerException ex)
        {  ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASEIDMAPEMT,NA,MEDIUM,ex,NA); }
        return caseMap;
    }
    
    /*****************************************************************************************
Method : caseRelatedDetails
Description : Method to query serial number and outlet ID from outlet dispenser record connected to Case record.
******************************************************************************************/
    public Map<ID,Case> caseRelatedDetails(Map<ID,Case> caseMapData)
    {
        Map<ID,Case> caseMap = new Map<ID,Case>();
        try
        {
            List<Case> caseRelatedData = [Select Id,FS_Outlet_Dispenser__r.FS_Outlet__c,
                                          FS_Outlet_Dispenser__r.FS_Serial_Number2__c,FS_Outlet_Dispenser__r.FS_ACN_NBR__c
                                          from Case where ID IN: caseMapData.keySet()];
            for(Case caseRecord : caseRelatedData)
            {
                caseMap.put(caseRecord.Id,caseRecord);
            }
        }
        catch(System.QueryException ex)
        {  ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASERELATEDDETAILS,NA,MEDIUM,ex,NA); }
        return caseMap;
    }
    
    /*****************************************************************************************
Method : insertUpdateEMTCases
Description : Method to insert Case to Outlet Dispenser record and update the case record with dispenser serial number.
******************************************************************************************/
    public void insertUpdateEMTCases(Map<ID,Case> primaryCaseMap, Map<ID,Case> relatedCaseMap)
    {
        Savepoint sp;
        try
        {
            List<CaseToOutletdispenser__c> caseODList = new List<CaseToOutletdispenser__c>();
            List<Case> caseListRecords = new List<Case>();
            String serialNumber;
            for(ID caseId : relatedCaseMap.keySet())
            {
                CaseToOutletdispenser__c caseOutletDispenser = new CaseToOutletdispenser__c();
                Case caseRecord = primaryCaseMap.get(caseId);
                Case caseRelatedRecord = relatedCaseMap.get(caseId);
                caseOutletDispenser.Case__c = caseId;
                caseOutletDispenser.Customer__c = caseRelatedRecord.FS_Outlet_Dispenser__r.FS_Outlet__c;
                caseOutletDispenser.Outlet_Dispenser__c = caseRecord.FS_Outlet_Dispenser__c;
                caseOutletDispenser.Serial_Number_Text__c = caseRelatedRecord.FS_Outlet_Dispenser__r.FS_Serial_Number2__c;
                caseODList.add(caseOutletDispenser);
                caseRelatedRecord.Dispenser_serial_number__c = caseRelatedRecord.FS_Outlet_Dispenser__r.FS_Serial_Number2__c;
                caseListRecords.add(caseRelatedRecord);
            }
            sp = Database.setSavepoint();
            if(!caseODList.isEmpty() || caseODList != null)
            {
                insert caseODList;
            }
            if(!caseListRecords.isEmpty() || caseListRecords != null)
            {
                update caseListRecords;
            }
        }
        catch(DmlException ex)
        {  Database.rollback(sp);  ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,INSERTUPDATEEMTCASES,NA,MEDIUM,ex,NA);
        }
    }
    
    /*****************************************************************************************
Method : insertOutletDispenser
Description : Method called from EMT trigger for inserting case to outlet dispenser reccord for EMT case record.
******************************************************************************************/
    public void insertOutletDispenser(List<Case> caseList)
    {
        try
        {
            Map<ID,Case> caseMapDetails = new Map<ID,Case>();
            Map<ID,Case> caseRelatedMap = new Map<ID,Case>();
            if(!caseList.isEmpty())
            {
                caseMapDetails = caseIDMapEMT(caseList);
            }
            if(!caseMapDetails.isEmpty())
            {
                caseRelatedMap = caseRelatedDetails(caseMapDetails);
                if(!caseRelatedMap.isEmpty())
                {
                    insertUpdateEMTCases(caseMapDetails,caseRelatedMap);
                }
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,INSERTOUTLETDISPENSER,NA,MEDIUM,ex,NA); }
    }
    
    /*****************************************************************************************
Method : caseMapEMTDetails
Description : Method to check if selected outlet dispenser is changed and create maps for old and new case records.
******************************************************************************************/
    public void caseMapEMTDetails(List<Case> oldCaseValues, List<Case> newCaseValues)
    {
        try
        {
            for(Case oldValue : oldCaseValues)
            {
                for(Case newValue : newCaseValues)
                {
                    if(oldValue.ID == newValue.ID && oldValue.FS_Outlet_Dispenser__c != newValue.FS_Outlet_Dispenser__c)
                    {
                        newCaseMap.put(newValue.ID,newValue);
                        oldCaseMap.put(oldValue.ID,oldValue); }
                }
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASEMAPEMTDETAILS,NA,MEDIUM,ex,NA);}
    }
    
    /*****************************************************************************************
Method : updateDeleteList
Description : Method to List the Case To OutletDispenser records that needs to be deleted.
******************************************************************************************/
    public void updateDeleteList(ID caseIDVal,List<CaseToOutletdispenser__c> caseToODVal,Map<ID,Case> caseMapDetails)
    {
        try
        {
            Case caseValue = caseMapDetails.get(caseIDVal);
            for(CaseToOutletdispenser__c caseOD : caseToODVal)
            {
                if(caseValue != null)
                {
                    if(caseOD.Outlet_Dispenser__r.FS_ACN_NBR__c != caseValue.FS_Outlet_Dispenser__r.FS_ACN_NBR__c)
                    {
                        deleteList.add(caseOD);
                    }
                    else
                    {
                        oldSerialNumberMap.put(caseOD.Outlet_Dispenser__r.FS_Serial_Number2__c + 
                                               caseOD.Outlet_Dispenser__r.FS_ACN_NBR__c,
                                               caseOD.Outlet_Dispenser__r.FS_Serial_Number2__c);
                        if(oldSerialNumber.containsKey(caseIDVal))
                        {
                            String serialNumberVal = oldSerialNumber.get(caseIDVal);
                            serialNumberVal = serialNumberVal + ',' + caseOD.Outlet_Dispenser__r.FS_Serial_Number2__c;
                            oldSerialNumber.put(caseIDVal,serialNumberVal);
                        }
                        else
                        {
                            String serialNumberVal = caseOD.Outlet_Dispenser__r.FS_Serial_Number2__c;
                            oldSerialNumber.put(caseIDVal,serialNumberVal);
                        }
                    }
                }
                else
                {
                    deleteList.add(caseOD); }
                
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,UPDATEDELETELIST,NA,MEDIUM,ex,NA);}
    }
    
    /*****************************************************************************************
Method : caseMapCreation
Description : Method to create a Map for holding Case to OutletDispenser records.
******************************************************************************************/
    public Map<ID,List<CaseToOutletdispenser__c>> caseMapCreation(List<CaseToOutletdispenser__c> caseToODValue)
    {
        Map<ID,List<CaseToOutletdispenser__c>> caseMap = new Map<ID,List<CaseToOutletdispenser__c>>();
        try
        {
            for(CaseToOutletdispenser__c caseToODRecord : caseToODValue)
            {
                if(caseMap.containsKey(caseToODRecord.Case__c))
                {
                    caseMap.get(caseToODRecord.Case__c).add(caseToODRecord);
                }
                else
                {
                    List<CaseToOutletdispenser__c> oDRecord = new List<CaseToOutletdispenser__c>();
                    oDRecord.add(caseToODRecord);
                    caseMap.put(caseToODRecord.Case__c,oDRecord);
                }
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CASEMAPCREATION,NA,MEDIUM,ex,NA); }
        return caseMap;
    }
    
    /*****************************************************************************************
Method : deleteOldDispenserData
Description : Method to delete the Case To OutletDispenser records when updating outlet Dispenser value in Case record.
******************************************************************************************/
    public void deleteOldDispenserData(Map<ID,Case> oldValuesCase,Map<ID,Case> caseMap)
    {
        try
        {
            List<CaseToOutletdispenser__c> caseToOD = new List<CaseToOutletdispenser__c>();
            Map<ID,List<CaseToOutletdispenser__c>> caseToODMap = new Map<ID,List<CaseToOutletdispenser__c>>();
            deleteList = new List<CaseToOutletdispenser__c>();
            oldSerialNumber = new Map<ID,String>();
            oldSerialNumberMap = new Map<String,String>();
            caseToOD = [Select ID,Case__c,Outlet_Dispenser__r.FS_Serial_Number2__c,Outlet_Dispenser__r.FS_ACN_NBR__c
                        from CaseToOutletdispenser__c where Case__c IN: oldValuesCase.keySet()];
            if(!caseToOD.isEmpty())
            {
                caseToODMap = caseMapCreation(caseToOD);
            }
            if(!caseToODMap.isEmpty())
            {
                for(ID caseID : caseToODMap.keySet())
                {
                    List<CaseToOutletdispenser__c> caseToODValue = caseToODMap.get(caseID);
                    if(!caseToODValue.isEmpty())
                    {
                        updateDeleteList(caseID,caseToODValue,caseMap);
                    }
                }
            }
            if(!deleteList.isEmpty())
            {  delete deleteList;  }
        }
        catch(DmlException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,DELETEOLDDISPENSERDATA,NA,MEDIUM,ex,NA); }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,DELETEOLDDISPENSERDATA,NA,MEDIUM,ex,NA); }
    }
    /*****************************************************************************************
Method : insertEMTCases
Description : Method to insert Case to Outlet Dispenser record and update the case record with dispenser serial number.
******************************************************************************************/
    public void insertEMTCases(Map<ID,Case> primaryCaseMap, Map<ID,Case> relatedCaseMap)
    {
        try
        {
            List<CaseToOutletdispenser__c> caseODList = new List<CaseToOutletdispenser__c>();
            List<Case> caseListRecords = new List<Case>();
            for(ID caseId : relatedCaseMap.keySet())
            {
                Case caseRelatedRecord = relatedCaseMap.get(caseId);
                Case caseRecord = primaryCaseMap.get(caseId);
                if(!oldSerialNumberMap.containsKey(caseRelatedRecord.FS_Outlet_Dispenser__r.FS_Serial_Number2__c + caseRelatedRecord.FS_Outlet_Dispenser__r.FS_ACN_NBR__c))
                {
                    CaseToOutletdispenser__c caseOutletDispenser = new CaseToOutletdispenser__c();
                    caseOutletDispenser.Case__c = caseId;
                    caseOutletDispenser.Customer__c = caseRelatedRecord.FS_Outlet_Dispenser__r.FS_Outlet__c;
                    caseOutletDispenser.Outlet_Dispenser__c = caseRecord.FS_Outlet_Dispenser__c;
                    caseOutletDispenser.Serial_Number_Text__c = caseRelatedRecord.FS_Outlet_Dispenser__r.FS_Serial_Number2__c;
                    caseODList.add(caseOutletDispenser);                    
                    if(oldSerialNumber.containsKey(caseId))
                    {
                        caseRelatedRecord.Dispenser_serial_number__c = oldSerialNumber.get(caseId) + ',' + caseRelatedRecord.FS_Outlet_Dispenser__r.FS_Serial_Number2__c;
                        caseListRecords.add(caseRelatedRecord);
                    }
                    else
                    {
                        caseRelatedRecord.Dispenser_serial_number__c = caseRelatedRecord.FS_Outlet_Dispenser__r.FS_Serial_Number2__c;
                        caseListRecords.add(caseRelatedRecord);
                    }
                }
            }
            if(!caseODList.isEmpty() || caseODList != null)
            {
                insert caseODList;
            }
            if(!caseListRecords.isEmpty() || caseListRecords != null)
            {
                update caseListRecords;
            }
        }
        catch(DmlException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,INSERTEMTCASES,NA,MEDIUM,ex,NA); }
    }
    
    /*****************************************************************************************
Method : updateOutletDispenser
Description : Method called from EMT trigger for updating case to outlet dispenser reccord for EMT case record.
******************************************************************************************/
    public void updateOutletDispenser(List<Case> oldCaseList, List<Case> newCaseList)
    {
        try
        {
            newCaseMap = new Map<ID,Case>();
            oldCaseMap = new Map<ID,Case>();
            Map<ID,Case> caseRelatedMap = new Map<ID,Case>();
            List<ID> testList = new List<ID>();
            if(!oldCaseList.isEmpty() && !newCaseList.isEmpty())
            {
                caseMapEMTDetails(oldCaseList,newCaseList);
            }
            if(!oldCaseMap.isEmpty() && !newCaseMap.isEmpty())
            {
                caseRelatedMap = caseRelatedDetails(newCaseMap);
                if(!caseRelatedMap.isEmpty())
                {   deleteOldDispenserData(oldCaseMap,caseRelatedMap);
                    insertEMTCases(newCaseMap,caseRelatedMap);  }
            }
        }
        catch(NullPointerException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,UPDATEOUTLETDISPENSER,NA,MEDIUM,ex,NA);}
    }
    
    /*****************************************************************************************
Method : CreateHistory
Description : Method called from EMT trigger for creating casestatushistorydetail records to capture Current case status duration
******************************************************************************************/
    
    Public  void CreateHistory(List<case> insertedCase)
    {
        Try
        {
            Id nonNorthAmericanRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get(NONNORTHAMERICANCASE).getRecordTypeId();
            Id northAmericanRecordTypeID = Schema.SObjectType.case.getRecordTypeInfosByName().get(NORTHAMERICANCASE).getRecordTypeId();
            Id linkageManagementRTID = Schema.SObjectType.case.getRecordTypeInfosByName().get('Linkage Management').getRecordTypeId();
            List<case> emtcaselist =new  List<case>();
            
            for (case emtcase :insertedCase)
            {
                
                if( emtcase.RecordTypeId == nonNorthAmericanRecordTypeID || emtcase.RecordTypeId == northAmericanRecordTypeID || emtcase.RecordTypeId == linkageManagementRTID)
                {
                    emtcaselist.add(emtcase);  }
            }
            List<Case_Status_History_Detail__c> newCasehistorydetailList =new List<Case_Status_History_Detail__c>();
            for(Case newcase :emtcaselist)
            {
                
                Case_Status_History_Detail__c casehistorydetailrecord =new Case_Status_History_Detail__c();
                
                casehistorydetailrecord.Parent_Case__c= newcase.Id;
                casehistorydetailrecord.Status__c=newcase.Status;
                casehistorydetailrecord.Sub_Status__c = newcase.LM_Sub_Status__c;
                newCasehistorydetailList.add(casehistorydetailrecord);
            }
            insert newCasehistorydetailList;
        }
        catch(DmlException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CREATEHISTORY,NA,MEDIUM,ex,NA);}
    }
    
    
    /*****************************************************************************************
Method : UpdateHistory
Description : Method called from EMT trigger for updating Casestatushistorydetail record to capture status duration on change of status
******************************************************************************************/
    Public Void UpdateHistory(List <Case> beforeupdate, List <case> afterUpdate)
    {
        Id devRecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Linkage Management').getRecordTypeId();
        if(flag){
            Try
            { 
                Set<ID> caseIds =new Set<ID>();
                for(Case c :beforeupdate)
                {
                    caseIds.add(c.Id);
                } 
                List<Case_Status_History_Detail__c> existingRecorddetails = [Select Id,Status__c,Status_Start_Time__c,Status_End_Time__c,Parent_Case__c from Case_Status_History_Detail__c where Parent_Case__c IN: caseIDs];
                Map <String,Case_Status_History_Detail__c> historyStatuscasevalues =New  Map<String,Case_Status_History_Detail__c>();
                List<Case_Status_History_Detail__c> upsertCSHD =new List<Case_Status_History_Detail__c>(); 
                if(existingRecorddetails !=null)
                {
                    for(Case_Status_History_Detail__c cshd : existingRecorddetails )
                    {
                        historystatuscasevalues.put(CSHD.Parent_Case__c +CSHD.Status__c,cshd); }
                }                
                for(Case oldvalue:beforeUpdate)
                {
                    for(case newvalue:afterUpdate)
                    {
                        IF((oldvalue.Id == newvalue.Id) && (oldvalue.status!= newvalue.status ||oldvalue.Sub_Status__c!=newvalue.Sub_Status__c ||oldvalue.LM_Sub_Status__c!=newvalue.LM_Sub_Status__c )&& oldvalue.status!=null)
                        { 
                            Case_Status_History_Detail__c updateEndtime = historystatuscasevalues.get(oldvalue.id+oldvalue.Status);
                            if(updateEndtime!=null && updateEndtime.Status_End_Time__c==null)
                            {
                                updateEndtime.Status_End_Time__c =newvalue.Last_Status_Change__c;
                                upsertCSHD.add(updateEndtime);
                                Case_Status_History_Detail__c insertNewcaseHistoryDetailrecordvalue = new Case_Status_History_Detail__c();
                                insertNewcaseHistoryDetailrecordvalue.Parent_Case__c= newvalue.Id;
                                insertNewcaseHistoryDetailrecordvalue.Status__c=newvalue.Status;
                                if(newvalue.Status=='Closed')
                                {
                                    insertNewcaseHistoryDetailrecordvalue.Status_End_Time__c=newvalue.Last_Status_Change__c;   
                                }
                                insertNewcaseHistoryDetailrecordvalue.Status_Start_Time__c=newvalue.Last_Status_Change__c;
                                insertNewcaseHistoryDetailrecordvalue.Sub_Status__c=newvalue.Sub_Status__c;
                                if(newvalue.recordtypeid==devRecordTypeName)
                                {
                                    insertNewcaseHistoryDetailrecordvalue.Sub_Status__c=newvalue.LM_Sub_Status__c;
                                }
                                upsertCSHD.add(insertNewcaseHistoryDetailrecordvalue);                                
                            }
                        }
                    }                    
                }
                upsert(upsertCSHD); 
            }            
            catch(DmlException ex)
            {ApexErrorLogger.addApexErrorLog('FET EMT+FACT 2017','FSCaseManagementHelper','UpdateHistory','NA','Medium',ex,'NA'); }
   }
        else
        {
            flag=!flag;
        }
    }
    
    
    
    /*****************************************************************************************
Method : populateCaseFieldsfromOD
Description : Method to populate static fields on casetoOutletdispenser records. 
******************************************************************************************/
    public void populateCaseFieldsfromOD(Boolean isAfter,Boolean isInsert,Boolean isUpdate,List<CaseToOutletdispenser__c> newCaseODList,Map<ID,CaseToOutletdispenser__c> oldmap)
    {
        try{
            Set<Id> dispIDS = new Set<Id>();
            for(CaseToOutletdispenser__c csValue : newCaseODList)
            {
                CaseToOutletdispenser__c oldCase;
                if(isUpdate)
                {
                    oldCase=(CaseToOutletdispenser__c )oldMap.get(csValue.id);  }   
                if(((isInsert && csValue.Outlet_Dispenser__c!=null) ||( isUpdate && csValue.Outlet_Dispenser__c!=null && oldCase.Outlet_Dispenser__c!=csValue.Outlet_Dispenser__c))){
                    dispIDS.add(csValue.Outlet_Dispenser__c);
                }
            }
            
            if(dispIDS.size()>0){
                Map<Id,FS_Outlet_Dispenser__c> caseDispMap=new Map<Id,FS_Outlet_Dispenser__c>(
                    [Select FS_IsActive__c,FS_ACN_NBR__c,FS_SAP_ID__c,FS_Install_Status__c,FS_Status__c,
                     FS_Last_Seen_Date__c,FS_Last_Pour_Date__c,FS_Build_Id_SW_Version__c,FS_CMS_Version__c,FS_Serial_Number__c,
                     FS_IP_Address__c,FS_Modem_Number__c,FS_Date_Installed2__c,FS_Bundle_Name__c from FS_Outlet_Dispenser__c 
                     where Id IN :dispIDS]);
                
                if(caseDispMap.size()>0){
                    for(CaseToOutletdispenser__c csStatic : newCaseODList){
                        csStatic.FS_Static_CMS_Version__c = String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_CMS_Version__c);
                        csStatic.FS_Static_Build_Id_SW_Version__c = String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Build_Id_SW_Version__c);
                        csStatic.FS_Static_Install_status__c= String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Install_Status__c);
                        csStatic.FS_Static_Dispenser_Status__c= String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Status__c);
                        csStatic.FS_Static_IP_Address__c = String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_IP_Address__c);
                        csStatic.FS_Static_Last_Pour_Date__c = caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Last_Pour_Date__c;
                        csStatic.FS_Static_Last_Seen_Date__c = caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Last_Seen_Date__c;
                        csStatic.FS_Static_Modem_Number__c = String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Modem_Number__c);
                        csStatic.FS_Static_SAP__c = String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_SAP_ID__c);
                        csStatic.FS_Static_ACN__c = String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_ACN_NBR__c);
                        csStatic.FS_Static_Active_Inactive__c = caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_IsActive__c;
                        csStatic.FS_Static_Enrollment_Date__c = caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Date_Installed2__c;
                        csStatic.FS_Static_Bundle_Name__c = String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Bundle_Name__c);
                        /*if(csStatic.Case__r.Dispenser_serial_number__c == null)
{
csStatic.Case__r.Dispenser_serial_number__c = String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Serial_Number__c);

}
if(csStatic.Case__r.Dispenser_serial_number__c == null)    
{
csStatic.Case__r.Dispenser_serial_number__c = ',' + String.valueOf(caseDispMap.get(csStatic.Outlet_Dispenser__c).FS_Serial_Number__c);

}*/                        
                    }
                }
            }
        }
        catch(Exception ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,POPULATECASEFIELDSFROMOD,NA,MEDIUM,ex,NA); }
    }  
    
    /*****************************************************************************************
Method : checkTask
Description : Method to Check and Notify for open tasks linked with cases before closing cases using a custom label.
******************************************************************************************/
    public void checkTask(List<Case> newList)
    {
        try
        {
            Set<ID> caseIDs=new Set<ID>();
            List<Task> taskList=new List<Task>();
            
            for(Case caseRecord : newList)
            {
                if(caseRecord.status == closed)
                {
                    caseIDs.add(caseRecord.Id);
                }
            }
            
            taskList = checkOpenTask(caseIDs);
            
            for(Case caseOpenTask : newList)
            {
                if(queryExcep == true)
                {
                    caseOpenTask.adderror(FETCHTASK);
                }
                else
                {
                    for(Task openTask:taskList)
                    {
                        if(caseOpenTask.id == openTask.WhatId)
                        {   caseOpenTask.adderror(Label.CloseTaskError); }
    
                    }
                }
            }
        }
        catch(ListException ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,CHECKTASK,NA,MEDIUM,ex,NA); }
    }
    
    /*****************************************************************************************
Method : populateStaticCaseFields
Description : Method to populate static fields on case records. 
******************************************************************************************/
    
    public void populateStaticCaseFields(Boolean isInsert,Boolean isUpdate,List<Case> newCaseList,Map<ID,Case> oldmap)
    {
        try{
            List<Case> caseList = new List<Case>();
            Set<Id> dispIDS = new Set<Id>();
            for(Case csValue : newCaseList)
            {
                Case oldCase;
                if(isUpdate)
                {
                    oldCase=oldMap.get(csValue.id);
                }   
                if(((isinsert && csValue.FS_Outlet_Dispenser__c!=null) ||( isUpdate && csValue.FS_Outlet_Dispenser__c!=null && oldCase.FS_Outlet_Dispenser__c!=csValue.FS_Outlet_Dispenser__c))){
                    dispIDS.add(csValue.FS_Outlet_Dispenser__c);
                }
            }
            
            if(dispIDS.size()>0){
                Map<Id,FS_Outlet_Dispenser__c> caseDispMap=new Map<Id,FS_Outlet_Dispenser__c>(
                    [Select FS_IsActive__c,FS_ACN_NBR__c,FS_SAP_ID__c,FS_Install_Status__c,FS_Status__c,
                     FS_Last_Seen_Date__c,FS_Last_Pour_Date__c,FS_Build_Id_SW_Version__c,FS_CMS_Version__c,
                     FS_IP_Address__c,FS_Modem_Number__c,FS_Date_Installed2__c,FS_Bundle_Name__c from FS_Outlet_Dispenser__c 
                     where Id IN :dispIDS]);
                if(caseDispMap.size()>0)
                {
                    for(Case csStatic : newCaseList)
                    {
                        csStatic.FS_Static_ACN__c = String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_ACN_NBR__c);
                        csStatic.FS_Static_Active_Inactive__c = caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_IsActive__c;
                        csStatic.FS_Static_CMS_Version__c = String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_CMS_Version__c);
                        csStatic.FS_Static_Build_Id_SW_Version__c = String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_Build_Id_SW_Version__c);
                        csStatic.FS_Static_Install_status__c= String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_Install_Status__c);
                        csStatic.FS_Static_Dispenser_Status__c= String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_Status__c);
                        csStatic.FS_Static_IP_Address__c = String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_IP_Address__c);
                        csStatic.FS_Static_Last_Pour_Date__c = caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_Last_Pour_Date__c;
                        csStatic.FS_Static_Last_Seen_Date__c = caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_Last_Seen_Date__c;
                        csStatic.FS_Static_Modem_Number__c = String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_Modem_Number__c);
                        csStatic.FS_Static_SAP__c = String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_SAP_ID__c);
                        csStatic.FS_Static_Enrollment_Date__c = caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_Date_Installed2__c;
                        csStatic.FS_Static_Bundle_Name__c = String.valueOf(caseDispMap.get(csStatic.FS_Outlet_Dispenser__c).FS_Bundle_Name__c);
                    }
                } 
            }
        }
        catch(Exception ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,POPULATESTATICCASEFIELDS,NA,MEDIUM,ex,NA); }
    }
    /*****************************************************************************************
Method : sendEmailToExternal
Description : Method to send email to Finanace and JDE AMS Team and add case comments to the case records. 
******************************************************************************************/
    public void sendEmailToExternal(List<Case> newCaseList,List<Case> oldList,Map<ID,Case> oldmap)
    {
        try{
            id caseId;
            string toAddress,ccaddress,cCASTaddress;
            ccaddress =System.Label.SetCCAddress;
            cCASTaddress =System.Label.FS_CCASTEmailId;
            string uSERPOFILEFETADMIN = System.Label.USER_POFILE_FET_ADMIN;  
            string STATUS_ASSIGNED = FSConstants.STATUS_ASSIGNED;
            string FINANCE_ON_HOLD = FSConstants.FINANCE_ON_HOLD; 
            string JDE_INITIATED_AMOA = FSConstants.JDE_INITIATED_AMOA;    
            string ACCOUNT_TEAM_INITIATED_AMOA = FSConstants.ACCOUNT_TEAM_INITIATED_AMOA; 
            string JDE_INSTALL_BASE_NOTIFIED = FSConstants.JDE_INSTALL_BASE_NOTIFIED;   
            String JDE_AMS_ON_HOLD = FSConstants.JDE_AMS_ON_HOLD;
            String JDE_LINKAGE_REQUEST = FSConstants.JDE_LINKAGE_REQUEST;
            String PENDING_INSTALL = FSConstants.PENDING_INSTALL; 
            String EMAIL_TO_RSS = System.Label.EMAIL_TO_RSS;
            String EMAIL_TO_JDE = System.Label.EMAIL_TO_JDE;               
            List<string> emailTosend = new List<string>(); 
            List<CaseComment> cclist=new List<CaseComment>();
            EmailTemplate templateIdEmailToRSS = [Select id, Body, Subject from EmailTemplate where name =:EMAIL_TO_RSS];
            EmailTemplate templateIdEmailToJDE = [Select id from EmailTemplate where name =:EMAIL_TO_JDE];                    
            User con =[select id, name from User where name =: uSERPOFILEFETADMIN limit 1];
            
            for(case cs:newCaseList) 
            {
                if(cs.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get(FSConstants.RECORD_TYPE_NAME_LMCASE).getRecordTypeId())
                {
                    caseId = cs.id;
                    if(cs.Status==STATUS_ASSIGNED && cs.LM_Sub_Status__c==FINANCE_ON_HOLD && cs.LM_Sub_Status__c != oldMap.get(cs.id).LM_Sub_Status__c && (cs.FS_New_Case_Type__c==ACCOUNT_TEAM_INITIATED_AMOA || cs.FS_New_Case_Type__c==JDE_INITIATED_AMOA))
                    {
                        for(FS_EmailAddressForRSSJDE__c toEmail : FS_EmailAddressForRSSJDE__c.getAll().values())
                        {
                            if(toEmail.FS_RSS__c==true) { emailTosend.add(toEmail.FS_Email_Address__c);}                              
                        }                                                  
                        /*List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();                   
                        for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :caseId])
                        {
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            efa.setFileName(a.Name);
                            efa.setBody(a.Body);
                            fileAttachments.add(efa);
                        } */
                        
                        //Added to inlcude Attachments :FNF 1051 
                        List<id> contentDocumentids = new List<id>();
                        for(contentDocumentLink cDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:caseId])
                        {  ContentDocumentids.add(CDLink.ContentDocumentId); }
                        List<ContentVersion> att = [SELECT ContentDocumentId ,FileType, VersionData,Title,FileExtension,CreatedDate FROM ContentVersion where ContentDocumentId IN :ContentDocumentids ORDER BY CreatedDate DESC];
                        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                        for (ContentVersion a : att)
                        {       if(a.Title.Contains(AMOAFROM)){
                                Messaging.Emailfileattachment attachfile = new Messaging.Emailfileattachment();
                                attachfile.setFileName(a.Title+'.'+a.FileExtension);
                                attachfile.setBody(a.VersionData);
                                fileAttachments.add(attachfile);}  } 
                        //End
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setFileAttachments(fileAttachments);
                        mail.setTemplateID(templateIdEmailToRSS.Id); 
                        mail.CcAddresses = new String[] {ccaddress};
                            mail.toAddresses = emailTosend;
                        mail.setTargetObjectId(con.id);
                        mail.setTreatTargetObjectAsRecipient(false); 
                        mail.setSaveAsActivity(false);
                        mail.setWhatId(caseId);
                        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        String caseCommentBody;
                        if(cs.FS_New_Case_Type__c==ACCOUNT_TEAM_INITIATED_AMOA)
                        {
                            caseCommentBody = FSConstants.SF_EMAIL_TO_RSS; 
                        }
                        else
                        {
                            caseCommentBody = FSConstants.SF_EMAIL_TO_RSS_CCAST;  
                        }
                        if (results[0].success) 
                        {                                   
                            CaseComment cc = new CaseComment();
                            cc.ParentID = caseId;  
                            cc.CommentBody = caseCommentBody;
                            //cc.CreatedById = FSUtil.getProfileName();
                            cc.CreatedById = FSUtil.getFreeStyleUserId();
                            cclist.add(cc);
                            //insert cc;
                        } 
                        else 
                        {
                            CaseComment cc = new CaseComment();
                            cc.ParentID = caseId;  
                            cc.CommentBody = 'Exception :'+results[0].errors[0].message;
                            //cc.CreatedById = FSUtil.getProfileName();
                            cc.CreatedById = FSUtil.getFreeStyleUserId();
                            cclist.add(cc);
                            //insert cc;
                        }                                         
                    }
                    else if (cs.Status==STATUS_ASSIGNED && cs.LM_Sub_Status__c==JDE_INSTALL_BASE_NOTIFIED && cs.LM_Sub_Status__c != oldMap.get(cs.id).LM_Sub_Status__c && (cs.FS_New_Case_Type__c==ACCOUNT_TEAM_INITIATED_AMOA || cs.FS_New_Case_Type__c==JDE_INITIATED_AMOA))
                    {
                        for(FS_EmailAddressForRSSJDE__c toEmail : FS_EmailAddressForRSSJDE__c.getAll().values())
                        {
                            if(toEmail.FS_InstallBase__c==true)  { emailTosend.add(toEmail.FS_Email_Address__c);}                       
                        }                  
                        
                        //Added to inlcude Attachments :FNF 1051 
                        List<id> contentDocumentids = new List<id>();
                        for(contentDocumentLink cDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:caseId])
                        { ContentDocumentids.add(CDLink.ContentDocumentId);  }
                        List<ContentVersion> att = [SELECT ContentDocumentId ,FileType, VersionData,Title,FileExtension,CreatedDate FROM ContentVersion where ContentDocumentId IN :ContentDocumentids ORDER BY CreatedDate DESC];
                        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                        for (ContentVersion a : att)
                        {        if(a.Title.Contains(AMOAFROM)){
                                Messaging.Emailfileattachment attachfile = new Messaging.Emailfileattachment();
                                attachfile.setFileName(a.Title+'.'+a.FileExtension);
                                attachfile.setBody(a.VersionData);
                                fileAttachments.add(attachfile); } }
                        //End
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setFileAttachments(fileAttachments);
                        mail.setTemplateID(templateIdEmailToJDE.Id);
                        if(cs.FS_New_Case_Type__c==ACCOUNT_TEAM_INITIATED_AMOA)
                        { mail.CcAddresses = new String[] {ccaddress,cCASTaddress}; }
                        else { mail.CcAddresses = new String[] {ccaddress};
                            }
                        mail.toAddresses = emailTosend;
                        mail.setTargetObjectId(con.id);
                        mail.setTreatTargetObjectAsRecipient(false); 
                        mail.setSaveAsActivity(false);                    
                        mail.setWhatId(caseId);
                        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        if (results[0].success) 
                        {
                            CaseComment cc = new CaseComment();
                            cc.ParentID = caseId; 
                            //cc.CreatedById = FSUtil.getProfileName();
                            cc.CreatedById = FSUtil.getFreeStyleUserId();
                            if(cs.FS_New_Case_Type__c==JDE_INITIATED_AMOA)
                            {
                                cc.CommentBody = FSConstants.SF_EMAIL_TO_JDE_INSTALL_BASE_CREATOR;
                            }
                            else
                            {   cc.CommentBody = FSConstants.SF_EMAIL_TO_JDE_INSTALL_BASE;   }
                               
       
                            cclist.add(cc);
                            //insert cc;
                        } 
                        else 
                        {
                            CaseComment cc = new CaseComment(ParentID = caseId,CreatedById = FSUtil.getFreeStyleUserId(),CommentBody = 'Exception :'+results[0].errors[0].message);
                            cclist.add(cc);
                            //insert cc;
                        }
                    }
                    else if(cs.Status==STATUS_ASSIGNED && cs.LM_Sub_Status__c==JDE_AMS_ON_HOLD && cs.LM_Sub_Status__c != oldMap.get(cs.id).LM_Sub_Status__c && cs.FS_New_Case_Type__c==JDE_LINKAGE_REQUEST)
                    {
                        CaseComment cc = new CaseComment(ParentID = caseId,CommentBody = FSConstants.SF_EMAIL_TO_JDE_AMS,CreatedById = FSUtil.getFreeStyleUserId());
                        cclist.add(cc);
                        //insert cc; 
                    }
                    else if(cs.Status==STATUS_ASSIGNED && cs.LM_Sub_Status__c==PENDING_INSTALL && cs.LM_Sub_Status__c != oldMap.get(cs.id).LM_Sub_Status__c && cs.FS_New_Case_Type__c==JDE_LINKAGE_REQUEST)
                    {
                        CaseComment cc = new CaseComment(ParentID = caseId,CommentBody = FSConstants.SF_EMAIL_TO_CCAST,CreatedById = FSUtil.getFreeStyleUserId());
                        cclist.add(cc);
                        //insert cc;                 
                    }
                    else if(cs.Status==STATUS_ASSIGNED && cs.LM_Sub_Status__c==JDE_AMS_ON_HOLD && cs.LM_Sub_Status__c != oldMap.get(cs.id).LM_Sub_Status__c && cs.FS_New_Case_Type__c==JDE_INITIATED_AMOA)
                    {
                        CaseComment cc = new CaseComment(ParentID = caseId,CommentBody = FSConstants.SF_EMAIL_TO_JDE_AMS,CreatedById = FSUtil.getFreeStyleUserId());
                        cclist.add(cc);
                        //insert cc;
                    }
                    else if(cs.Status==STATUS_ASSIGNED && cs.LM_Sub_Status__c==PENDING_INSTALL && cs.LM_Sub_Status__c != oldMap.get(cs.id).LM_Sub_Status__c && cs.FS_New_Case_Type__c==JDE_INITIATED_AMOA)
                    {
                        CaseComment cc = new CaseComment(ParentID = caseId,CommentBody = FSConstants.SF_EMAIL_TO_JDEAMS_CCAST,CreatedById = FSUtil.getFreeStyleUserId());
                        cclist.add(cc);
                        //insert cc;
                    }
                    else if(cs.Status==STATUS_ASSIGNED && cs.LM_Sub_Status__c==PENDING_INSTALL && cs.LM_Sub_Status__c != oldMap.get(cs.id).LM_Sub_Status__c && cs.FS_New_Case_Type__c==ACCOUNT_TEAM_INITIATED_AMOA)
                    {
                        CaseComment cc = new CaseComment(ParentID = caseId,CommentBody = FSConstants.SF_EMAIL_TO_JDE_AMS,CreatedById = FSUtil.getFreeStyleUserId());
                        cclist.add(cc);
                        //insert cc; 
                    }
                    else if(cs.Status==STATUS_ASSIGNED && cs.LM_Sub_Status__c==FINANCE_ON_HOLD && cs.LM_Sub_Status__c != oldMap.get(cs.id).LM_Sub_Status__c && cs.FS_New_Case_Type__c==ACCOUNT_TEAM_INITIATED_AMOA)
                    {
                        CaseComment cc = new CaseComment(ParentID = caseId,CommentBody = FSConstants.SF_EMAIL_TO_RSS,CreatedById = FSUtil.getFreeStyleUserId());
                        cclist.add(cc);
                        //insert cc; 
                    }                           
                } 
            } 
            insert cclist;
        }
        catch(Exception ex)
        { ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,SENDEMAILTOEXTERNAL,NA,MEDIUM,ex,NA);}    
    } 
    
    /*****************************************************************************************
Method : populateSerialNumbersOnLMCase
Description : Method to populate static fields on casetoOutletdispenser records. 
******************************************************************************************/
    public void populateSerialNumbersOnLMCase(List<CaseToOutletdispenser__c> newCaseODList,List<CaseToOutletdispenser__c> oldCaseODList)
    {
        try
        {
            List<CaseToOutletdispenser__c > caseToODList = (Trigger.isInsert|| Trigger.isUnDelete) ? Trigger.new : Trigger.old;
            Set<Id> caseIDS = new Set<Id>();
            for (CaseToOutletdispenser__c csOD : caseToODList) 
            {
                caseIDS.add(csOD.Case__c);
            }
            List<Case> caseList = [select id,Dispenser_serial_number__c from Case where id in :caseIDS];
            List<CaseToOutletdispenser__c> csODList = [select id,Name,case__c,Outlet_Dispenser__c,FS_Serial_Number__c from CaseToOutletdispenser__c where case__c in :caseList];
            for (Case csRec : caseList) 
            {
                String tempVar='';
                if(csODList.size() > 0)
                {
                    for(CaseToOutletdispenser__c csd : csODList)
                    {
                        if(tempVar == '')
                        {
                            csRec.Dispenser_serial_number__c =csd.FS_Serial_Number__c;
                            tempVar = csd.FS_Serial_Number__c;
                        }
                        else
                        {
                            csRec.Dispenser_serial_number__c = tempVar + '; ' + csd.FS_Serial_Number__c;
                            tempVar = tempVar +'; '+csd.FS_Serial_Number__c;
                        }
                    }
                }
                else
                    csRec.Dispenser_serial_number__c = null;
                
            }
            update caseList;
        }
        catch (Exception ex){ApexErrorLogger.addApexErrorLog(PROJECTNAME,FSCASEMANAGEMENTHELPER,POPULATESERIALNUMBERONLMCASE,NA,MEDIUM,ex,NA);}
    }
    private static boolean run = true;
    public boolean runOnce()
    {
        if(run)
        {
            run=false;
            return true;
        }else
        {
            return run;
        }
        
    }
    /*****************************************************************
Method: validateAMOACaseStatus
Description: validateAMOACaseStatus method is to check status of 'Account Team Initiated AMOA' or 'JDE Initiated AMOA' cases
and to update the 'Asset Tracking Form (AMOA) Status' field on the RO4W in FET to 'Complete'
Added as part of FET 7.0, //Sprint 1 - FNF-366 & FNF-373
*******************************************************************/ 
    public void validateAMOACaseStatus(List<Case> nList, List<Case> oList, Map<Id,Case> oMap){
        Id installationId = FSInstallationValidateAndSet.ipRecTypeRelocationO4W;
        Set<Id> cIdSet = new Set<Id>();
        Map<id,String> caseMap = new Map<id,String>();
        
        for(Case c : nList){
            if(c.status != oMap.get(c.Id).status && (c.FS_New_Case_Type__c == FSConstants.ACCOUNTTEAMINITIATEDAMOA || c.FS_New_Case_Type__c == FSConstants.JDEINITIATEDAMOA)){
                caseMap.put(c.id,c.status);//FNF-373
            }
        }
        try{
            EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE name =: FSConstants.INSTALLFAILEMAIL];
            User fetAdminUser =[SELECT Id, name FROM User 
                                WHERE profile.name =: FSConstants.USER_POFILE_FETADMIN 
                                AND name =: FSConstants.FETADMINNAME LIMIT 1];
            List<FS_Installation__c> finalInstallList = new List<FS_Installation__c>();
            for(FS_Installation__c install : [SELECT Id, FS_related_case_id__c,FS_Asset_Tracking_Form_AMOA_Status__c,Freestyle_Support_Tool_Case_Status__c FROM FS_Installation__c WHERE FS_related_case_id__c IN:caseMap.keyset() AND RecordTypeId =: installationId]){
                install.Freestyle_Support_Tool_Case_Status__c = caseMap.get(install.FS_related_case_id__c);//FNF-373 to update CASE status on RO4W
                if(caseMap.get(install.FS_related_case_id__c) ==  FSConstants.STATUS_CLOSED && install.FS_Asset_Tracking_Form_AMOA_Status__c != FSConstants.STATUS_COMPLETE){
                    install.FS_Asset_Tracking_Form_AMOA_Status__c = FSConstants.STATUS_COMPLETE;
                }
                finalInstallList.add(install);
            }
            //update installation only if change is fields check is true
            if(!finalInstallList.ISEMPTY()){
                FSInstallationUpdation.updateAMOACOMPLETEFromCase = True;
                Database.SaveResult[] srList = Database.update(finalInstallList, false);
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
                for (integer i = 0; i < srList.size(); i++){
                    if (!srList[i].isSuccess()) {
                        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId.Id, fetAdminUser.Id, finalInstallList[i].Id);
                        mail.setBccSender(false);
                        mail.setUseSignature(false);
                        mail.setSaveAsActivity(false);
                        messages.add(mail);
                    }
                }
                if(!messages.ISEMPTY()){
                    Messaging.sendEmail(messages);
                }
            }
        }
        catch(exception e){
            ApexErrorLogger.addApexErrorLog(FSConstants.PROJECTNAME1, FSCASEMANAGEMENTHELPER, FSConstants.VALIDATEAMOACASESTATUS, NA, MEDIUM, e, NA);}
    }
}