/************************************************************************************************************************ 
Name         : FSListHeadquarterAccountsExt
Created By   : Mohit Parnami (Appiro)
Created Date : 18 - Oct - 2013
Usage        : Controller for FSListHeadquarterAccounts page to display all Headquater accounts related to chain account. 
*************************************************************************************************************************/
public with sharing class FSListHeadquarterAccountsExt {
    public Account chainAccount {get;set;}
    public List<Account> lstHeadquarterAccounts {get;set;}
    //--------------------------------------------------------------------------------------
    // Constructor to get chain Account Id from the account where this Inline page is.
    //--------------------------------------------------------------------------------------
    
    public FSListHeadquarterAccountsExt(ApexPages.StandardController stdController){
        chainAccount = (Account)stdController.getRecord();
        init();
    }   
    
    //--------------------------------------------------------------------------------------
    // Method to fetch headquater accounts having Chain Account as chainAccount.Id 
    //--------------------------------------------------------------------------------------
    public void init(){
        lstHeadquarterAccounts = new List<Account>();
        for(Account headQuaterAcc : [select Id, Name, FS_ACN__c, Corporate_VS_Franchise2__c, FS_Payment_Method__c, FS_Payment_Type__c, FS_Installs_Complete__c, FS_Installs_Complete_HQ__c, FS_Revenue_Center__c,FS_Signed_Agreement_Received__c
                                                                    From Account Where FS_Chain__c =: chainAccount.Id And RecordType.Name =: FSConstants.RECORD_TYPE_NAME_HQ ORDER BY Name LIMIT 999]){
            lstHeadquarterAccounts.add(headQuaterAcc);   
        }
    }
}