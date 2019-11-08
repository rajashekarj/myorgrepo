/*********************************************************************************************************
Name         : FS_AddContactsToHQ 
Created By   : Infosys Limited 
Created Date : 16-Sep-2019
Usage        : Ceating 4 contacts on Headquarters based on ACN

***********************************************************************************************************/ 
public class FS_AddContactsToHQ implements database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        Id RECORD_TYPE_HQ=FSUtil.getObjectRecordTypeId(Account.sObjectType,FSConstants.RECORD_TYPE_NAME_HQ);
        list<string> acnList=new list<string>{'0000844777', '0000342793', '0000844696', '0000347884', '0000288501', '0000851536', '0000103781', '0000943555', '0001500871', '0000844769', '0000947326', '0000702358', '0001127926', '0001136372', '0000089669', '0001971734', '0000900260', '0000996985', '0001992187', '0000971728', '0002225727', '0000948543', '0002061075', '0001677496', '0000941021', '0001821824', '0004901490', '0000829158', '0000968277', '0000966873', '0001985726', '0001907731', '0001136143', '0001477226', '0001717372', '0000942146', '0002053388', '0000860161', '0001157116', '0000942570', '0000908385', '0000854748', '0001404696', '0000937126', '0000848667', '0001136038', '0001591656', '0001512866', '0000932051', '0000968956', '0000404217', '0005832085', '0000974574', '0000103578', '0000834950', '0001136364', '0000861184', '0004904465', '0000942230', '0001553601', '0001538457', '0000991244', '0001705600', '0001925965', '0001452467', '0000861605', '0000024835', '0000850506', '0000844718', '0002093283', '0000342742', '0000975308', '0001544143', '0001169048', '0000904155', '0000901593', '0002030910', '0000914177', '0004904392', '0001621374', '0000332208', '0002026252', '0002206480', '0001881603', '0000834968', '0000704601', '0000842112', '0000842163', '0001769402', '0001583160', '0000333603', '0000969711', '0002083507', '0002068240', '0001157612', '0000937822', '0000941519', '0000915700', '0005606204', '0000342891', '0001677694', '0000984804', '0001798694', '0001940757', '0001798076', '0000427811', '0001603038', '0000964578', '0000103454', '0001472461', '0001137581', '0001657652'}; 
            String query = 'select id, FS_ACN__c from account where recordtypeId =:RECORD_TYPE_HQ and FS_ACN__c IN:acnList';     
         //String query = 'select id, FS_ACN__c from account where recordtypeId =:RECORD_TYPE_HQ and fs_acn__c in (\'0001696841PH\',\'0002010939\',\'0002010892\')';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> hqRec)
    {
        list<contact> contactsList=new list<contact>();
        string title='GENERAL CONTRACTOR';
        string role='Site Assessment Contact;Contractor Contact';
        //string conEmail='cttest001@coca-cola.com';
        
        for(account acc:hqRec){
            
            contact con1=new contact(firstname='RAYMOND',lastname='KANJIA',	FS_Title__c=title,Email='Raymond.kanjia@hki.com',Phone='(469) 688-0127',
                                     FS_Execution_Plan_Role__c=role,accountid=acc.id);
            contact con2=new contact(firstname='KYLE',lastname='OWENS',Email='Kyle.owens@hki.com',	FS_Title__c=title,Phone='(214) 244-3515',
                                     FS_Execution_Plan_Role__c=role,accountid=acc.id);
            contact con3=new contact(firstname='ZANE',lastname='BURMEISTER',Email='zburmeister@facilitysolutionsinc.com',FS_Title__c=title,Phone='(586) 741-0048',
                                     FS_Execution_Plan_Role__c=role,accountid=acc.id);
            contact con4=new contact(firstname='Tracy',lastname='Snider',Email='tsnider@facilitysolutionsinc.com',FS_Title__c=title,Phone='(586) 741-0048',
                                     FS_Execution_Plan_Role__c=role,accountid=acc.id);
            contactsList.add(con1);
            contactsList.add(con2);
            contactsList.add(con3);
            contactsList.add(con4);
        }   
        if(!contactsList.ISEMPTY()){
            final List<Database.SaveResult> resList = Database.insert(contactsList,false);
            errorCheckMethod(resList,contactsList,'contactsList','Contact');
        }        
    }
    
    
    /*****************************************************************
Method: errorCheckMethod
Description: errorCheckMethod method is used to create Apex error loger records.
to know the details of failed insert/update records while batch processing
*******************************************************************/
    public void errorCheckMethod(final List<Database.SaveResult> resList,final List<Contact> contactstobeadded,final String listName,final String objectName){
        
        final List<Apex_Error_Log__c> apexErrorList=new List<Apex_Error_Log__c>();
        for(Integer i=0; i < contactstobeadded.size() ; i++){
            final Database.SaveResult res = resList.get(i);
            if(!res.isSuccess()){
                for(Database.Error error : res.getErrors()){
                    apexErrorList.add(new Apex_Error_Log__c(Application_Name__c=FSConstants.FET,Class_Name__c='FS_AddContactsToHQ',Method_Name__c='errorCheckMethod',Object_Name__c=objectName,Error_Severity__c=FSConstants.MediumPriority,Notes__c=listName+FSConstants.HYPHEN+error.getMessage()+FSConstants.HYPHEN+ contactstobeadded[i].accountid+contactstobeadded[i].name));                    
                }
            }            
        }
        if(!apexErrorList.isEmpty()){  insert apexErrorList;    }
    }
    
    
    public void finish(Database.BatchableContext BC) {        
        
    }
}