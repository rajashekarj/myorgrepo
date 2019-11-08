global class FSMarketingFieldCopyToAccountBatch implements Database.batchable <sobject> {
    public Date today;
    
    public FSMarketingFieldCopyToAccountBatch(final Date today){
        this.today=today;
    }
    
    global Database.QueryLocator start(final Database.BatchableContext batchCon){
        
        return Database.getQueryLocator('select id,FS_Cncl_Post_Install_Marketting_fields__c,FS_Enable_Consumer_Engagement__c,FS_Enable_CE_Effective_Date__c,FS_LTO__c,FS_LTO_Effective_Date__c,FS_Promo_Enabled__c,FS_Promo_Enabled_Effective_Date__c,FS_Account__r.id,FS_Account__r.FS_CE_Enabled__c,FS_Account__r.FS_LTO__c,FS_Account__r.FS_Promo_Enabled__c from FS_Post_Install_Marketing__c where FS_Enable_CE_Effective_Date__c=:today or FS_LTO_Effective_Date__c=:today or FS_Promo_Enabled_Effective_Date__c=:today'  );       
        
    }
    
    global void execute(final Database.BatchableContext batchCon, final List<sObject> scope){
        List<Account> updateAccountList =new List<Account>();
        Map<id,Account> accMaptoUpdate=new Map<id,account>();
        List<FS_Post_Install_Marketing__c> allPIM = (List<FS_Post_Install_Marketing__c>)scope;
        Account relatedAcc;
        
        for(FS_Post_Install_Marketing__c pim:allPIM){
            if(pim.FS_Account__r.id!=null && !pim.FS_Cncl_Post_Install_Marketting_fields__c){
                Boolean check1=false;
                
                relatedAcc = new Account(id=pim.FS_Account__r.id,FS_CE_Enabled__c=pim.FS_Account__r.FS_CE_Enabled__c,FS_LTO__c=pim.FS_Account__r.FS_LTO__c,FS_Promo_Enabled__c=pim.FS_Account__r.FS_Promo_Enabled__c);
                
                if(accMaptoUpdate.containskey(relatedAcc.id)){
                    relatedAcc=accMaptoUpdate.get(relatedAcc.id);
                }
                
                
                if(pim.FS_Enable_CE_Effective_Date__c == today && pim.FS_Enable_Consumer_Engagement__c!=relatedAcc.FS_CE_Enabled__c){
                    relatedAcc.FS_CE_Enabled__c=pim.FS_Enable_Consumer_Engagement__c;
                    check1=true;
                }
                if(pim.FS_LTO_Effective_Date__c == today && pim.FS_LTO__c!=relatedAcc.FS_LTO__c){
                    relatedAcc.FS_LTO__c=pim.FS_LTO__c;
                    check1=true;
                }
                if(pim.FS_Promo_Enabled_Effective_Date__c == today && pim.FS_Promo_Enabled__c!=relatedAcc.FS_Promo_Enabled__c){
                    relatedAcc.FS_Promo_Enabled__c=pim.FS_Promo_Enabled__c;
                    check1=true;
                }
                
                if(check1==true){
                    accMaptoUpdate.put(relatedAcc.id,relatedAcc);
                }
                
            }
        }
        //Update Account
        if(!accMaptoUpdate.isEmpty()){
            Database.update(accMaptoUpdate.values(),false);
        }
    }
    
    
    global void finish(final Database.BatchableContext info){   
        system.debug('info'+info);
    }
    
    
}