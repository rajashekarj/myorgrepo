/*********************************************************************************

                  
*********************************************************************************/
public class InstallationRelatedContact {
   
    public FS_Installation__c ep{get;set;}
    public List<FS_Execution_Plan_Contact__c> Con  {get;set;}
    //public String selectedContact{get;set;}
    
    //constructor
    public InstallationRelatedContact(ApexPages.StandardController controller){
        ep = (FS_Installation__c)controller.getRecord();
        ep = [SELECT ID,FS_Outlet__c From FS_Installation__c Where Id=:ep.id];
        prepareContactList();
    }
    
    
    
    //preparing list of related attachment
    public void prepareContactList(){
        con  = new List<FS_Execution_Plan_Contact__c>();
        for(FS_Execution_Plan_Contact__c cnt : [Select Id ,Outlet__c, Name, FS_Execution_Plan_Contact__c,FS_Phone__c,FS_Email__c,FS_Execution_Plan_Role__c,FS_Contact_Name__c From FS_Execution_Plan_Contact__c 
                              where Outlet__c = :ep.FS_Outlet__c]){
            Con.add(cnt);
        }
    }
    
}