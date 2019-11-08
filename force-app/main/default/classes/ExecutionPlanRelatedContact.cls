/*********************************************************************************
 Author       :   Dipika (Appirio Offshore)
 Created Date :   April 9,2013
 Task         :   T-128538
 Description  :   Controller class for OpportunityRelatedContent page
                  
*********************************************************************************/
public class ExecutionPlanRelatedContact {
   
    public FS_Execution_Plan__c ep{get;set;}
    public List<Contact> Contact{get;set;}
    
    //constructor
    public ExecutionPlanRelatedContact(final ApexPages.StandardController controller){
        ep = (FS_Execution_plan__c)controller.getRecord();
        ep = [SELECT ID,FS_Headquarters__c From FS_Execution_Plan__c Where Id=:ep.id];
        prepareContactList();
    }
    
    
    
    //preparing list of related attachment
    public void prepareContactList(){
        Contact = new List<Contact>();
        for(Contact cnt : [Select Id ,AccountID, Name,FS_Title__c, Title, Phone, Email, FS_Alternate_Phone_Cell__c,FS_Execution_Plan_Role__c, FS_Execution_Plan_Contact__c From Contact 
                              where AccountID = :ep.FS_Headquarters__c 
                              and   FS_Execution_Plan_Contact__c!=null ]){
            Contact.add(cnt);
        }
    }
    
}