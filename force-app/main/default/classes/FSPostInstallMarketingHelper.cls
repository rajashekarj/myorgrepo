public with Sharing class FSPostInstallMarketingHelper {
    
    public static void updateAccountonToday(){
        Map<id,Account> accToUpdate = new Map<id,Account>();
        Set<id> accIDSet=new Set<id>();
        
        for(FS_Post_Install_Marketing__c pim:(List<FS_Post_Install_Marketing__c>)Trigger.New){
            if(pim.FS_Account__c!=null && (pim.FS_Enable_CE_Effective_Date__c==System.today() || pim.FS_LTO_Effective_Date__c==system.today() || pim.FS_Promo_Enabled_Effective_Date__c==system.today())){
                   accIDSet.add(pim.FS_Account__c);             
            }
        }
        
        Map<id,Account>  relatedAccountsMap=new Map<id,Account>([select id,FS_CE_Enabled__c,FS_LTO__c,FS_Promo_Enabled__c from Account where id IN :accIDSet]);
        system.debug('Related ACc'+ relatedAccountsMap);
        Account relatedAcc;
        for(FS_Post_Install_Marketing__c pim:(List<FS_Post_Install_Marketing__c>)Trigger.New){
            Boolean check1=false;
            if(pim.FS_Account__c!=null && relatedAccountsMap.containsKey(pim.FS_Account__c)){
               	
                relatedAcc = relatedAccountsMap.get(pim.FS_Account__c);
                
                if(accToUpdate.containskey(relatedAcc.id)){
                    relatedAcc=accToUpdate.get(relatedAcc.id);
                }
                
                if(pim.FS_Enable_CE_Effective_Date__c == system.today() && pim.FS_Enable_Consumer_Engagement__c!=relatedAcc.FS_CE_Enabled__c){
                    relatedAcc.FS_CE_Enabled__c=pim.FS_Enable_Consumer_Engagement__c;
                    check1=true;
                }
                
                if(pim.FS_LTO_Effective_Date__c == system.today() && pim.FS_LTO__c!=relatedAcc.FS_LTO__c){
                    relatedAcc.FS_LTO__c=pim.FS_LTO__c;
                    check1=true;
                }
                
                if(pim.FS_Promo_Enabled_Effective_Date__c == system.today() && pim.FS_Promo_Enabled__c!=relatedAcc.FS_Promo_Enabled__c){
                    relatedAcc.FS_Promo_Enabled__c=pim.FS_Promo_Enabled__c;
                    check1=true;
                }
                
                if(check1=true){
                    
                    accToUpdate.put(relatedAcc.id,relatedAcc);
                    
                }
            }
        }
        
        update(accToUpdate.Values());
        
    }
    
}