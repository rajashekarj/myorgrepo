/*********************************************************************************
Author       :   Modified by DREED (Appirio)
Created Date :   November 25,2013
Description  :   Controller class for Execution Plan Account Team page

*********************************************************************************/
public class ExecutionPlanAccountTeam {
    public Map<Id,String> lastModifiedDateMap{get;set;}
    public Map<Id,String> lastModifiedMap{get;set;}
    public FS_Execution_Plan__c ep{get;set;}
    public List<AccountTeamMember__c> AccountTeamMembers{get;set;}
    public String selectedTeam{get;set;}
    
    //constructor
    public ExecutionPlanAccountTeam(final ApexPages.StandardController controller){
        ep = (FS_Execution_plan__c)controller.getRecord();
        ep = [SELECT ID,FS_Headquarters__c From FS_Execution_Plan__c Where Id=:ep.id];
        lastModifiedDateMap=new Map<Id,String>();
        lastModifiedMap=new Map<Id,String>();
        prepareTeamList();
    }
    
    //preparing list of related Account Team Member
    public void prepareTeamList(){        
        AccountTeamMembers = new List<AccountTeamMember__c>();
        for(AccountTeamMember__c atm : [Select Id , AccountId__c, TeamMemberRole__c, UserID__r.name, UserID__r.email, UserID__r.phone,LastModifiedBy.Id,LastModifiedBy.Name,LastModifiedDate From AccountTeamMember__c where AccountID__c = :ep.FS_Headquarters__c]){
            
            lastModifiedDateMap.put(atm.Id, atm.LastModifiedDate.format('M/d/YYYY'));
            lastModifiedMap.put(atm.Id,', '+atm.LastModifiedDate.format());  
            AccountTeamMembers.add(atm);
        }
    }
    
}