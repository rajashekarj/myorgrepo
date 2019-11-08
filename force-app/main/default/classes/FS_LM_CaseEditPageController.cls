/**************************************************************************************
Apex Class Name     : FS_LM_CaseEditPageController
Function            : This class is created for Editing Linkage Managed Record Type case.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sreenivasulu Binkam       2/16/2018     LM Case RecordType Case will be edited and Displayed using this class     
*************************************************************************************/
public class FS_LM_CaseEditPageController 
{
    public Case cs{get;set;}
    public List<CaseComment> cscm{get;set;}
    public List<EmailMessage> emailmsg{get;set;}
    public List<FS_Outlet_Dispenser__c> ToAcnOD {get;set;}
    public List<FS_Outlet_Dispenser__c> FromAcnOD {get;set;}
    public Account ToACN{get;set;}
    public Account FromACN{get;set;}
    public Id recId{get;set;}
    public String CaseOwner{get;set;}
    public String Casenumber{get;set;}
    public boolean Csnum{get;set;}
    public boolean Newcs{get;set;} 
    public boolean Editcs{get;set;}
    public List<ODwrpr> ODList {get;set;}
    public boolean showInline{get;set;}
    private Case oldcase;
    public FS_LM_CaseEditPageController(ApexPages.StandardController stdCtrl) 
    {
        showInline = true;
        newcs = false;
        editcs= false;
        cs = new case();
        cscm = new List<CaseComment>();
        emailmsg = new List<EmailMessage>();
        ODList = new List<ODwrpr>();
        recId = ApexPages.currentPage().getParameters().get('id');
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        cs.setOptions(dmlOpts);
        if(recId != null)
        {
            cs = [SELECT id,CaseNumber,ownerid,owner.name,FS_New_Case_Type__c,recordTypeId,RecordType.Name,Issue_Name__c,Case_Age_Days__c,
                  Priority,Status,LM_Sub_Status__c,To_Account__c,From_Account__c,createdbyID,CreatedDate,LastModifiedByID,
                  To_Account__r.FS_ACN__c,To_Account__r.FS_Concatenated_Address__c,To_Account__r.Name,LastModifiedDate,
                  From_Account__r.Name,From_Account__r.FS_ACN__c,From_Account__r.FS_Concatenated_Address__c,From_Account__r.FS_Revenue_Center__c from Case where id= :recId LIMIT 1 ];
            CaseOwner = cs.owner.Name;
            casenumber = cs.CaseNumber;
            csnum = true;
            editcs = true;
            cscm =[select id,IsPublished,commentBody,CreatedById,Createddate from caseComment where parentid = :recId ORDER BY CreatedDate DESC];
            emailmsg = [select id,Subject,status,HasAttachment,FromAddress,MessageDate from EmailMessage where parentid = :recId ORDER BY CreatedDate DESC];
            if(cs.To_Account__c != null){             
                toACNODdetails();
            }
            if(cs.From_Account__c != null){
                fromACNODdetailswrpr();
            }
            oldcase=cs.clone(false,false,false,false);
        }else{        
            CaseOwner = UserInfo.getName();
            csnum = false;
            newcs = true;
        }
        
    }
    public PageReference saveNew() {
        try { 
            insert cs; 
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }   
        
        return (new ApexPages.StandardController(new Case())).edit();                
    }   
    public pagereference getdetails(){
        return null;        
    }
    public pagereference toACNODdetails() 
    {
        ToAcnOD = new List<FS_Outlet_Dispenser__c>();
        if(cs.To_Account__c != null)
        {            
            ToACN= [select id, name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Outlet_ACN__c,CCR_Address__c from account where id = :cs.To_Account__c];            
            ToAcnOD = [SELECT id,Name,FS_Outlet__r.name,FS_IsActive__c,FS_Serial_Number__c,FS_Status__c from FS_Outlet_Dispenser__c where FS_Outlet__c =: cs.To_Account__c limit 5];            
        }
        return null;
    }   
    
    public PageReference fromACNODdetailswrpr() 
    {
        ODList.clear();
        MAP<ID,ID> case2odMap = new MAP<ID,ID>();
        SET<ID> odId = new SET<ID>();
        String LM_CASE_TYPE = FSConstants.LM_CASE_TYPE;
        List<CaseToOutletdispenser__c> csodList = [SELECT id,Outlet_Dispenser__c from CaseToOutletdispenser__c where Case__c =: cs.id and FS_CaseType__c =:LM_CASE_TYPE];
        
        for(CaseToOutletdispenser__c csod :csodList ){
            case2odMap.put(csod.Outlet_Dispenser__c,csod.Outlet_Dispenser__c);
            odId.add(csod.Outlet_Dispenser__c);
        }
        if(cs.From_Account__c != null){
            FromACN = [select id, name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Outlet_ACN__c,CCR_Address__c from account where id = :cs.From_Account__c];
            
            for (FS_Outlet_Dispenser__c c: [SELECT id,Name,FS_Outlet__r.name,FS_IsActive__c,FS_Serial_Number__c,FS_Status__c from FS_Outlet_Dispenser__c where FS_Outlet__c =: cs.From_Account__c]) {
                if(odId.contains(c.id)){
                    ODList.add(new ODwrpr(c,true));
                }else{
                    ODList.add(new ODwrpr(c,false));
                }
            }          
        }
        return null;
    }
    
    public class ODwrpr {
        public FS_Outlet_Dispenser__c od {get;set;}
        public Boolean selected {get;set;}
        
        public ODwrpr(FS_Outlet_Dispenser__c o,boolean chkbx) {
            od = o;
            selected = chkbx;
        }
    }
    public PageReference saveCase(){
        List<CaseToOutletdispenser__c> case2od = new List<CaseToOutletdispenser__c>();        
        List <FS_Outlet_Dispenser__c> selectedOds = new List <FS_Outlet_Dispenser__c> ();
        List <FS_Outlet_Dispenser__c> unselectedOds = new List <FS_Outlet_Dispenser__c> ();
        String LM_CASE_TYPE = FSConstants.LM_CASE_TYPE;
        string RECORD_TYPE_NAME_LMCASE = FSConstants.RECORD_TYPE_NAME_LMCASE; 
        string STATUS_ASSIGNED = FSConstants.STATUS_ASSIGNED;
        string FINANCE_ON_HOLD = FSConstants.FINANCE_ON_HOLD; 
        string JDE_INITIATED_AMOA = FSConstants.JDE_INITIATED_AMOA;    
        string ACCOUNT_TEAM_INITIATED_AMOA = FSConstants.ACCOUNT_TEAM_INITIATED_AMOA; 
        string JDE_INSTALL_BASE_NOTIFIED = FSConstants.JDE_INSTALL_BASE_NOTIFIED;   
        String JDE_AMS_ON_HOLD = FSConstants.JDE_AMS_ON_HOLD;
        String JDE_LINKAGE_REQUEST = FSConstants.JDE_LINKAGE_REQUEST;
        String PENDING_INSTALL = FSConstants.PENDING_INSTALL; 
        String ACCOUNT_TEAM_ON_HOLD = FSConstants.ACCOUNT_TEAM_ON_HOLD;
   
        List<CaseToOutletdispenser__c> cs2odList = [SELECT id,Outlet_Dispenser__c from CaseToOutletdispenser__c where Case__c =: cs.id and FS_CaseType__c = :LM_CASE_TYPE];
        SET<ID> odIds = new SET<ID>();
        SET<ID> unselODs = new SET<ID>();
        if(cs.Status==STATUS_ASSIGNED && cs.FS_New_Case_Type__c==JDE_LINKAGE_REQUEST && (cs.LM_Sub_Status__c==ACCOUNT_TEAM_ON_HOLD || cs.LM_Sub_Status__c==FINANCE_ON_HOLD || cs.LM_Sub_Status__c==JDE_INSTALL_BASE_NOTIFIED) )
         {
          cs.LM_Sub_Status__c=oldcase.LM_Sub_Status__c;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,FSConstants.SUB_STATUS_ERROR));
          showInline = true;
          return null;
          }
        if(cs.Status==STATUS_ASSIGNED && cs.FS_New_Case_Type__c==ACCOUNT_TEAM_INITIATED_AMOA && (cs.LM_Sub_Status__c==JDE_AMS_ON_HOLD || cs.LM_Sub_Status__c==ACCOUNT_TEAM_ON_HOLD))
         {
          cs.LM_Sub_Status__c=oldcase.LM_Sub_Status__c;
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,FSConstants.SUB_STATUS_ERROR));
          showInline = true;
          return null;
         }
        if(cs.From_Account__c!= null & cs.To_Account__c!= null & cs.From_Account__c == cs.To_Account__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,FSConstants.ACCOUNT_ERROR));
            return null;
        }else{
            if(cs.Issue_Name__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,FSConstants.ISSUE_ERROR));
                showInline = true;
            return null;
            }else{
            try{ 
                cs.recordtypeId = [Select id,name from recordtype where name =:RECORD_TYPE_NAME_LMCASE].id;
                upsert cs;        
            }catch(System.DMLException e){
                system.debug('Inserted CS Exception-->'+e);
                  
            }              
            if(ODList.size()>0){
                for (ODwrpr cacc: ODList) {
                    if (cacc.selected == true) {
                        selectedOds.add(cacc.od);             
                    }else{
                        unselectedOds.add(cacc.od);
                    }
                }
            }
            if(cs2odList.size()>0){
                for(CaseToOutletdispenser__c co : cs2odList){
                    odIds.add(co.Outlet_Dispenser__c);
                }
            }                
            for (FS_Outlet_Dispenser__c sOD: selectedOds) {
                
                CaseToOutletdispenser__c cd = new CaseToOutletdispenser__c();
                cd.Outlet_Dispenser__c = sOD.id;
                cd.Case__c = cs.id;
                cd.FS_CaseType__c = LM_CASE_TYPE;
                if(odIds.contains(cd.Outlet_Dispenser__c)){
                    system.debug('Dispenser already presented-->'+cd.Outlet_Dispenser__c);
                }else{
                    case2od.add(cd);
                }
            }
            try{
                insert case2od;
            }catch(System.DMLException ex){
                system.debug('Excpetion-->'+ex);
            }
            
            for (FS_Outlet_Dispenser__c UnsOD: unselectedOds) {
                unselODs.add(UnsOD.id);
            }
            
            if(unselODs != null){
                
                List<CaseToOutletdispenser__c> cs2odListDel = [SELECT id,Outlet_Dispenser__c from CaseToOutletdispenser__c where Outlet_Dispenser__c IN : unselODs and FS_CaseType__c =:LM_CASE_TYPE and Case__c = :cs.id];
                
                if(cs2odListDel.size()>0){
                    try{
                        delete cs2odListDel;
                    }catch(System.DMLException exc){
                        system.debug('Excpetion-->'+exc);
                    }
                }
            }
            PageReference casedetailpg = new PageReference('/apex/FS_LM_CaseDetailPage?id='+cs.id);
            casedetailpg.setRedirect(true);
            return casedetailpg ;
         }   
       }          
    }
    public pagereference editCase(){
        PageReference caseEditpg = new PageReference('/apex/FS_LM_CaseEditPage?id='+cs.id);
        caseEditpg.setRedirect(true);
       return caseEditpg;    
    }
    
     public pagereference dpcancel(){
        PageReference dpcancelpg = new PageReference('/apex/FS_LM_CaseDetailPage?id='+cs.id);
        dpcancelpg.setRedirect(true);
       return dpcancelpg;    
    }
    
     public pagereference deleteCase(){
        try{
            delete cs;
        }catch(System.DMLException excep){
            system.debug('Expetion -->'+excep);
        }
        PageReference caselistpg = new PageReference('/500/o');
        caselistpg.setRedirect(true);
        return caselistpg;     
    }
    public PageReference NewComment()
    {
        PageReference pr = new PageReference('/00a/e?parent_id='+cs.ID+'&retURL=%2F' +cs.id);
        pr.setRedirect(true);
        return pr;
    }
    public PageReference deleteComment()
    {
    Id commentId = ApexPages.currentPage().getParameters().get('CommentId_d');   
    for(CaseComment Comment : [Select id from CaseComment where id=:commentId])
    {
    if(Comment.Id == commentId)
    {   
    delete Comment; 
    break;
    }
    }    
    PageReference pg = new PageReference('/' + cs.Id);
    pg.setRedirect(true);
    return pg;
    }    
    /*****************************************************************
    Method: escalateToSalesSupport
    Description: escalateToSalesSupport method is to send email and add casecomment on click of Escalate to Sales Support button .
    Added as part of FET 7.0, //Sprint 1 - FNF-459
    *******************************************************************/ 
    public PageReference escalateToSalesSupport(){
        try{
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.AssignmentRuleHeader.useDefaultRule = true;
            Id emailTempId = [select id from EmailTemplate where DeveloperName =: FSConstants.SALESSUPPORT_EMAILTMP_JDE].id;
            Case caseRec = [Select Id,Status,LM_Sub_Status__c from Case where id =: cs.id Limit 1];
            caseRec.Status = FSConstants.STATUS_ASSIGNED;
            caseRec.LM_Sub_Status__c = FSConstants.ACCOUNT_TEAM_ON_HOLD;
            caseRec.setOptions(dmo);
            update caseRec;
            CaseComment cc = new CaseComment(ParentId = cs.Id,CommentBody = FSConstants.FS_SALESSUPPORT_CASECOMMENT,CreatedById=FSUtil.getFreeStyleUserId());
            insert cc;
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTempId, null, cs.Id);
            string[] toMail = new string[] {Label.FSCaseEscalateToSalesSupportToAddress};
            string[] ccMail = new string[] {Label.FSCaseEscalateToSalesSupportCCAddress};
            email.setToAddresses(toMail);
            email.setCcAddresses(ccMail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            PageReference caseDetailpg = new PageReference('/'+cs.id);
            caseDetailpg.setRedirect(true);
            return caseDetailpg; 
        }catch(exception e){
            System.debug('Exception');
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        } 
        return null;
    }
}