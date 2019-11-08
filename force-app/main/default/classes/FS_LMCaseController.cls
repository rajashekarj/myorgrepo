/**************************************************************************************
Apex Class Name     : FS_LMCaseController
Function            : This class is created for Handling LM case create, edit and custom buttons.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* sai           9/26/2019          All the LM case functionalities are handled by this apex controller.
Create, edit , delete and custom buttons actions.
*************************************************************************************/

public without sharing class FS_LMCaseController {
    public static final String FACT_CASE_CREATE_NOTIFICATION = 'Fact_Case_Create_Notification';
    public static final String NEW_STRING = 'New';
    public static final String PROJECT_NAME = 'Freestyle Support 2019';
    public static final String FS_LMCASECONTROLLER = 'FS_LMCaseController';
    public static final String NA = 'NA';
    public static final String MEDIUM = 'MEDIUM';
    public static final String STATUS_FINANCE_HOLD = 'Finance on Hold';
    public static final String STATUS_INSTALLBASE_NOTIFIED = 'JDE Install Base Notified';
    public static final String STATUS_ASSIGNED = 'Assigned';
    public static final String CASETYPE_JDE = 'JDE Initiated AMOA';
    public static final String EMAIL_TO_CCAST_TEMPLATE = 'Email to CCAST when JDE AMS escalates case to RSS group';
    public static final String EMAIL_TO_TEMPLATE_INSTALLBASE = 'Email to CCAST for notification purposes when JDE AMS escalates case';
    /*****************************************************************************************
Method : toACNdetails
Description : Method to retrieve LM case 'To Account' account details and returns the list.
******************************************************************************************/   
    @AuraEnabled(cacheable=true)
    public static List<Account> toACNdetails(ID toAccn) 
    {
        List<Account> toAcn = new List<Account>();
        try{
            if(toAccn != null)
            {            
                toACN= [select id, name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Outlet_ACN__c,CCR_Address__c from account where id = :toAccn];            
            }
        }
        
        catch(Exception ex)
        { system.debug('Exception'+ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'toACNdetails',NA,MEDIUM,ex,NA);
        }
        return toACN;
    }  
    /*****************************************************************************************
Method : toACNODdetails
Description : Method to retrieve LM case 'To Account' outlet dispenser details and returns the list.
******************************************************************************************/   
    @AuraEnabled(cacheable=true)
    public static List<FS_Outlet_Dispenser__c> toACNODdetails(ID toAccn) 
    {
        List<FS_Outlet_Dispenser__c> toAcnOD = new List<FS_Outlet_Dispenser__c>();
        try{
            if(toAccn != null)
            {            
                toAcnOD = [SELECT id,Name,FS_Outlet__r.name,FS_IsActive__c,FS_Serial_Number__c,FS_Status__c,FS_Equip_Type__c from FS_Outlet_Dispenser__c where FS_Outlet__c =: toAccn limit 5];            
            }  
        }
        
        catch(Exception ex)
        { system.debug('Exception'+ex.getMessage());  ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'toACNODdetails',NA,MEDIUM,ex,NA);  }
        return toAcnOD;
    }   
    /*****************************************************************************************
Method : fromACNODdetailswrpr
Description : Method to retrieve LM case 'From Account' outlet dispenser details. This method
method will arrange the OD details and boolean 'selected' as wrapper by callign 
'ODwrpr' class. Boolean selected used as checkbox on the LM case create/edit popup.
******************************************************************************************/  
    @AuraEnabled
    public static List<ODwrpr> fromACNODdetailswrpr(ID fromAccn,ID caseId) 
    {
        List<ODwrpr> oDList = new List<ODwrpr>();
        try{
            oDList.clear();
            MAP<ID,ID> case2odMap = new MAP<ID,ID>();
            SET<ID> odId = new SET<ID>();
            String LM_CASE_TYPE = FSConstants.LM_CASE_TYPE;
            if(caseId != Null || caseId != ''){
                List<CaseToOutletdispenser__c> csodList = [SELECT id,Outlet_Dispenser__c from CaseToOutletdispenser__c where Case__c =: caseId and FS_CaseType__c =:LM_CASE_TYPE];
                for(CaseToOutletdispenser__c csod :csodList ){
                    odId.add(csod.Outlet_Dispenser__c);
                }
            }    
            if(fromAccn != null){
                for (FS_Outlet_Dispenser__c c: [SELECT id,Name,FS_Outlet__r.name,FS_IsActive__c,FS_Serial_Number__c,FS_Status__c,FS_Equip_Type__c from FS_Outlet_Dispenser__c where FS_Outlet__c =: fromAccn]) {
                    if(odId.contains(c.id)){
                        oDList.add(new ODwrpr(c,true));
                    }else{
                        oDList.add(new ODwrpr(c,false));
                    }
                }          
            }
            
        }  
        catch(Exception ex)
        {  system.debug('Exception'+ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'fromACNODdetailswrpr',NA,MEDIUM,ex,NA);  }  
        return oDList;
    }
    /*****************************************************************************************
Method : fromAccnDetailsWrap
Description : Method to retrieve LM case 'From Account' account details and returns as a list.
******************************************************************************************/  
    @AuraEnabled(cacheable=true)
    public static list<Account> fromAccnDetailsWrap(ID fromAccn){
        List<Account> fromAcn = New List<Account>();
        try{
            fromACN = [select id, name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Outlet_ACN__c,CCR_Address__c from account where id = :fromAccn];
        }
        catch(Exception ex)
        { system.debug('Exception'+ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'fromAccnDetailsWrap',NA,MEDIUM,ex,NA);   }
        return fromAcn;    
    }
    /*****************************************************************************************
Method : ODwrpr
Description : Wrapper class to arrange 'From Account' outlet dispenser values and boolean 'selected' value
******************************************************************************************/
    public class ODwrpr {
        @AuraEnabled
        public FS_Outlet_Dispenser__c od {get;set;}
        @AuraEnabled
        public Boolean selected {get;set;}
        
        public ODwrpr(FS_Outlet_Dispenser__c o,boolean chkbx) {
            od = o;
            selected = chkbx;
        }
    }
    /*****************************************************************************************
Method : saveCaseOD
Description : Method to link 'From Account' outlet dispensers and respective case. It 
insert records into 'CaseToOutletdispenser__c' to link them. This method will fire assignment
rules after case details successfully submitted from LM case create/edit popup.
******************************************************************************************/
    @AuraEnabled
    Public static void saveCaseOD(Id caseId,List<Id> selectedOdList,List<Id> nonSelectedOdList){
        //Fetching the assignment rules on case
        AssignmentRule aR = new AssignmentRule();
        try{
            aR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= aR.id;
            
            Case caseAssign = new Case() ;
            caseAssign.Id = caseId;
            
            //Setting the DMLOption on Case instance
            caseAssign.setOptions(dmlOpts);
            update caseAssign ; 
            // code for linking selected outlet dispensers with case starts from here
            List<CaseToOutletdispenser__c> case2od = new List<CaseToOutletdispenser__c>();
            String LM_CASE_TYPE = FSConstants.LM_CASE_TYPE;
            SET<ID> selectedOdSet = new SET<ID>();
            SET<ID> nonSelectedOdSet = new SET<ID>();
            SET<ID> odIds = new SET<ID>();
            selectedOdSet.addAll(selectedOdList); 
            nonSelectedOdSet.addAll(nonSelectedOdList); 
            List<CaseToOutletdispenser__c> case2odExistingList = [SELECT id,Outlet_Dispenser__c from CaseToOutletdispenser__c where Case__c =: caseId and FS_CaseType__c = :LM_CASE_TYPE];
            
            if(case2odExistingList.size()>0){
                for(CaseToOutletdispenser__c co : case2odExistingList){
                    odIds.add(co.Outlet_Dispenser__c);
                }
            } 
            if(selectedOdSet != Null){
                for (Id selectedOdId : selectedOdSet) { 
                    CaseToOutletdispenser__c cd = new CaseToOutletdispenser__c();
                    
                    if(odIds.contains(selectedOdId)){
                        system.debug('Dispenser already presented-->'+selectedOdId);
                    }else{
                        cd.Outlet_Dispenser__c = selectedOdId;
                        cd.Case__c = caseId;
                        cd.FS_CaseType__c = LM_CASE_TYPE;
                        case2od.add(cd);
                    }
                }
                
                insert case2od;
                
            }
            if(nonSelectedOdSet != null){
                
                List<CaseToOutletdispenser__c> cs2odListDel = [SELECT id,Outlet_Dispenser__c from CaseToOutletdispenser__c where Outlet_Dispenser__c IN : nonSelectedOdSet and FS_CaseType__c =:LM_CASE_TYPE and Case__c = :caseId];
                
                if(cs2odListDel.size()>0){
                    
                    delete cs2odListDel;
                    
                }
            }
            
        }    
        catch(Exception ex)
        { system.debug('Exception'+ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'saveCaseOD',NA,MEDIUM,ex,NA);  }
    }
    /*****************************************************************************************
Method : getCaseDetails
Description : Method to retrieve case details based on the case id provided from LM case LWC components
******************************************************************************************/
    @AuraEnabled
    public static List<Case> getCaseDetails(Id caseId){
        List<Case> cs = New list<Case>();
        try{
            cs = [select Id,CaseNumber,Issue_Name__c,Status,LM_Sub_Status__c,FS_New_Case_Type__c,To_Account__c,From_Account__c,To_Account__r.Name,From_Account__r.Name,Owner.Name from Case where Id =: caseId];
            
        }
        catch(Exception ex)
        { system.debug('Exception'+ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'getCaseDetails',NA,MEDIUM,ex,NA);  }
        return cs;
    }
    /*****************************************************************************************
Method : updateCaseDetails
Description : Method to update case status/substatus details and fire Assignment rules.
When user clicks on LM case custom buttons this function will invoke
******************************************************************************************/
    @AuraEnabled
    public static Id updateCaseDetails(Case cs){
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
            upsert cs; 
            Case casedetails = [select id,LM_Sub_Status__c,status,FS_New_Case_Type__c from case where id = :cs.id];
            
        }
        
        catch(Exception ex)
        { system.debug('Exception'+ex.getMessage());  ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'updateCaseDetails',NA,MEDIUM,ex,NA);}
        return cs.id;
    }
    /*****************************************************************************************
Method : getFactOutletDispensers
Description : Method to retrieve fact outlet dispensers and returns the details as list
******************************************************************************************/
    @AuraEnabled
    public static List<FS_Outlet_Dispenser__c> getFactOutletDispensers(Id outletId){
        List<FS_Outlet_Dispenser__c> outletDispenserList = New list<FS_Outlet_Dispenser__c>();
        try{
            outletDispenserList= [select FS_Date_Status__c,FS_Name1__c ,FS_Equip_Type__c,FS_Outlet__c ,FS_Status__c ,
                                  FS_Dispenser_Type__c ,Outlet_City__c ,id, name,FS_Serial_Number2__c,FS_IsActive__c from FS_Outlet_Dispenser__c 
                                  where FS_Outlet__c=:outletId];
            
        }
        catch(Exception ex)
        { system.debug('Exception'+ex.getMessage());  ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'getFactOutletDispensers',NA,MEDIUM,ex,NA);  }
        return outletDispenserList;
    }
    /*****************************************************************************************
Method : deleteNonLMCase
Description :Method to Delete Non LM case
******************************************************************************************/
    @AuraEnabled
    public static void deleteLMCase(Id caseId){
        List<Case> deleteCase = New List<Case>();
        deleteCase = [select Id from Case where id=:caseId];
        try{
            Delete deleteCase;
        }
        catch(Exception ex)
        { system.debug('system Exception : ' + ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'deleteLMCase',NA,MEDIUM,ex,NA);}
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
        { system.debug('System Exception : ' + ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'getLoggedinUserDetails',NA,MEDIUM,ex,NA);}
        return userDetails;
    }
    /*****************************************************************
Method: escalateToSalesSupport
Description: escalateToSalesSupport method is to send email and add casecomment on click of Escalate to Sales Support button .
Added as part of FET 7.0, //Sprint 1 - FNF-459
*******************************************************************/ 
    @AuraEnabled
    public static void escalateToSalesSupport(Id caseId){
        try{
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.AssignmentRuleHeader.useDefaultRule = true;
            Id emailTempId = [select id from EmailTemplate where DeveloperName =: FSConstants.SALESSUPPORT_EMAILTMP_JDE].id;
            Case caseRec = [Select Id,Status,LM_Sub_Status__c from Case where id =: caseId Limit 1];
            caseRec.Status = FSConstants.STATUS_ASSIGNED;
            caseRec.LM_Sub_Status__c = FSConstants.ACCOUNT_TEAM_ON_HOLD;
            caseRec.setOptions(dmo);
            update caseRec;
            CaseComment cc = new CaseComment(ParentId = caseId,CommentBody = FSConstants.FS_SALESSUPPORT_CASECOMMENT,CreatedById=FSUtil.getFreeStyleUserId());
            insert cc;
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTempId, null, caseId);
            string[] toMail = new string[] {Label.FSCaseEscalateToSalesSupportToAddress};
                string[] ccMail = new string[] {Label.FSCaseEscalateToSalesSupportCCAddress};
                    email.setToAddresses(toMail);
            email.setCcAddresses(ccMail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch(Exception ex)
        { system.debug('System Exception : ' + ex.getMessage());ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'escalateToSalesSupport',NA,MEDIUM,ex,NA);}
    }
    /*****************************************************************
Method: getLMCaseRecordTypeID
Description: Method to retrieve case record type id based on the record type
name provided from LM case LWC components
*******************************************************************/ 
    @AuraEnabled
    public static List<RecordType> getLMCaseRecordTypeID(String recordTypeName){
        List<RecordType> lmCaseRecordID = New List<RecordType>();
        try{
            lmCaseRecordID = [select Id from RecordType where sObjectType='Case' and Name =:recordTypeName];
        }
        
        catch(Exception ex)
        { system.debug('System Exception : ' + ex.getMessage()); ApexErrorLogger.addApexErrorLog(PROJECT_NAME,FS_LMCASECONTROLLER,'getLMCaseRecordTypeID',NA,MEDIUM,ex,NA);}
        return lmCaseRecordID;
    }
    /*****************************************************************
Method: getLMCaseRecordTypeID
Description: Method to retrieve case record type id based on the record type
name provided from LM case LWC components
*******************************************************************/ 
    @AuraEnabled
    public static boolean isCommunity(){
        
        String  siteType = Site.getSiteType();
        if (siteType != null) {  
            return true;
        }
        return false;
    }
}