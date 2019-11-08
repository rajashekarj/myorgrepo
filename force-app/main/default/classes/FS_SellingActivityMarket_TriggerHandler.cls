public class FS_SellingActivityMarket_TriggerHandler{
    
    public static void afterUpdate(List<Selling_Activity_Market__c> newSellingActivityMarketList,Map<ID,Selling_Activity_Market__c> newSellingActivityMarketmap,Map<ID,Selling_Activity_Market__c> oldSellingActivityMarketmap){
        updateMarketActivationDateForInstallation(newSellingActivityMarketList,newSellingActivityMarketmap,oldSellingActivityMarketmap); 
    }
    
    private static void updateMarketActivationDateForInstallation(List<Selling_Activity_Market__c> newSellingActivityMarketList,Map<ID,Selling_Activity_Market__c> newSellingActivityMarketmap,Map<ID,Selling_Activity_Market__c> oldSellingActivityMarketmap){
       
        String query='';       
        Map<String,Date> SellingActivityMrktMap=new Map<String,Date>();       
        Set<String> MarketNameSet=new Set<String>();
        
        for(Selling_Activity_Market__c sellingMarketActivity:newSellingActivityMarketList) {                  
            if(oldSellingActivityMarketmap.get(sellingMarketActivity.id).Market_Activation_Date__c!=newSellingActivityMarketmap.get(sellingMarketActivity.id).Market_Activation_Date__c){                                                           
                SellingActivityMrktMap.put(sellingMarketActivity.name,sellingMarketActivity.Market_Activation_Date__c);
                MarketNameSet.add(sellingMarketActivity.name);                
            }  
        }
        if(!SellingActivityMrktMap.isEmpty() && !MarketNameSet.isEmpty()){
            query= query= 'SELECT ID,Type_of_Dispenser_Platform__c,FS_Market_Text__c,Overall_Status2__c,FS_Install_Date_Validation_Bypass_Check__c FROM FS_Installation__c where (Overall_Status2__c!=\''+FSConstants.IPCOMPLETE +'\') AND (Overall_Status2__c!=\''+FSConstants.IPCANCELLED +'\')  AND FS_Market_Text__c in:MarketNameSet';
            Database.executeBatch(new FSBatchUpdateActivationDTInstall(query,MarketNameSet,SellingActivityMrktMap));
        }             
    }
}