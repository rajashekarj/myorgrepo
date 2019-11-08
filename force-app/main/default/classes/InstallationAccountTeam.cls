/*********************************************************************************
Author       :   Modified by DREED (Appirio)
Created Date :   November 25,2013
Description  :   Controller class for Installation Account Team page

*********************************************************************************/
public class InstallationAccountTeam {
    public Map<Id,String> lastModifiedDateMap{get;set;}
    public Map<Id,String> lastModifiedMap{get;set;}
    
    public FS_Installation__c ins{get;set;}
    public List<AccountTeamMember__c> AccountTeamMembers{get;set;}
    // public String selectedTeam{get;set;}
    
    //constructor
    public InstallationAccountTeam(final ApexPages.StandardController controller){
        ins = (FS_Installation__c)controller.getRecord();
        ins = [SELECT ID,FS_Outlet__c From FS_Installation__c Where Id=:ins.id];
        lastModifiedDateMap=new Map<Id,String>();  
        lastModifiedMap=new Map<Id,String>();  
        prepareTeamList();
    }
    
    
    //preparing list of related Account Team Member
    public void prepareTeamList(){
       
        AccountTeamMembers = new List<AccountTeamMember__c>();
        for(AccountTeamMember__c atm : [Select Id , AccountId__c, TeamMemberRole__c, UserID__r.name, UserID__r.email, UserID__r.phone,LastModifiedBy.Id,LastModifiedBy.Name,LastModifiedDate From AccountTeamMember__c where AccountID__c = :ins.FS_Outlet__c]){
            system.debug('UId'+atm.id);
            lastModifiedDateMap.put(atm.Id, atm.LastModifiedDate.format('M/d/YYYY'));
            lastModifiedMap.put(atm.Id,', '+atm.LastModifiedDate.format());  
            AccountTeamMembers.add(atm);
        }
    }    
}