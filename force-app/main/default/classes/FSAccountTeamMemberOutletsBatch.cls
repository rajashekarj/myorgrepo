/***************************************************************************
 Name         : FSAccountTeamMemberOutletsBatch
 Created By   : Infosys
 Description  : Batch class to insert Account Team members of child outlet Accounts when a Team member is added under HQ Account
 Created Date : May 24, 2017 (as part of defect fix)
 
****************************************************************************/

public class FSAccountTeamMemberOutletsBatch  implements Database.batchable<sObject>, Database.Stateful
{
    public List<AccountTeamMember__c> accntTeamMemsToinsert;
    public Set<Id> accountIdSet = new Set<Id>();
    public Set<Id> accountHQForOutletIdSet=new Set<Id>();
    public string valNA ='NA' ;
    public string valFSBatch ='FSAccountTeamMemberOutletsBatch' ;
    public string valFET = 'FET';
    public string valMedium ='Medium'; 
    public Integer zeroVal=0;
    
    public object nullVal(){
        return null;
    }
    
    public FSAccountTeamMemberOutletsBatch( List<AccountTeamMember__c> accntTeamMemsList)
    {
        accntTeamMemsToinsert = accntTeamMemsList ; 
        //create set of AccountId related to ATM
        for(AccountTeamMember__c atm : accntTeamMemsToinsert){
            accountIdSet.add(atm.AccountId__c);
        } 
        Map<Id, Account> hqAccountMap = new Map<Id, Account>([ SELECT Id FROM Account where Id in: accountIdSet and RecordtypeId=:FSConstants.RECORD_TYPE_HQ]);
        accountHQForOutletIdSet = hqAccountMap.keySet();  
    }
    
    
    //Start method of batch job - Fetching the outlets of the HQ for which the Account Team members added
    public  Database.QueryLocator start(Database.BatchableContext bContext )
    {
        String query;    
        Id outletRecTypeId = FSConstants.RECORD_TYPE_OUTLET;
        query = 'SELECT Id FROM Account where FS_Headquarters__c in: accountHQForOutletIdSet and RecordtypeId=:outletRecTypeId';
        
        return Database.getQueryLocator(query); 
    }
   

    public  void  execute(Database.BatchableContext context, List<Account> outletList)
    {
        List<AccountTeamMember__c> insertOutletAccount=new List<AccountTeamMember__c>();
             
        Set<Id> accountOutletIdSet=new Set<Id>();
        
        //populate set 'accountOutletIdSet' with outlet ids
        //if(accountHQForOutletIdSet.size() > zeroVal){
            if(!accountHQForOutletIdSet.isEmpty()){
            for(Account acc: outletList){
                if(acc.Id!=nullVal())
                {
                      accountOutletIdSet.add(acc.Id);
                }
            }
        }
        
        //populate Outlet Team members list
        //if(accountOutletIdSet.size()>zeroVal){
        if(!accountOutletIdSet.isEmpty()){
            for(AccountTeamMember__c atm : (List<AccountTeamMember__c>)accntTeamMemsToinsert) {
                for(Id accOutletId: accountOutletIdSet){
                    AccountTeamMember__c atmCloned = atm.clone();
                    atmCloned.AccountID__c = accOutletId;
                    insertOutletAccount.add(atmCloned);
                }  
            }   
        }
        
        //insert Outlet Team members list
        try{
            //if(insertOutletAccount.size()>zeroVal ){  
            if(!insertOutletAccount.isEmpty() ){           
                insert insertOutletAccount;
            }
        }
        catch(DMLException e){
             ApexErrorLogger.addApexErrorLog(valFET,valFSBatch,'executeBatch','AccountTeamMember',valMedium,e,valNA);
             
        }
    }
    public void finish(Database.BatchableContext context)
    {
    }
}