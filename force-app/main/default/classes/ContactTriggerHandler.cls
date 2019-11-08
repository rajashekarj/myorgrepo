/*************************************************************************************************** 
Created By   : Pallavi Sharmar (Appiro JDC)
Date         : Oct 31, 2013
Usage        : Trigger Handler for Contact 
***************************************************************************************************/
public class ContactTriggerHandler{
    
    //------------------------------------------------------------------------------------------------
  // Update Multi-Select Picklist field --No longer   used
  //------------------------------------------------------------------------------------------------
    
    
    public static void checkForDuplicateServiceProviderContacts(final List<Contact> lstContacts) {
        final ID RecordtypeServiceProvider=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(FSConstants.RECORD_TYPE_SERVICE_PROVIDER).getRecordTypeId();
        for(contact c :lstContacts){
            if(c.RecordtypeId==RecordtypeServiceProvider){
                c.FS_SP_Code_text__c = c.FS_SP_Code__c;
            }
        }
        
        
   
    }
    
    //------------------------------------------------------------------------------------------------
  // Insert new record in junction object "Outlet Contact" when new contact is created.  
  //------------------------------------------------------------------------------------------------
  public static void insertNewRecordOutletContac(final Map<Id, Contact> mapContacts) {
    
    //Prepare map for contactId vs accountId
    final Map<Id, Id> mapContactId_AccountId = new Map<Id, Id>();
    final Map<Id, Id> mapContactId_HqId = new Map<Id, Id>();    
    for(Contact con :[SELECT Id, AccountId, Account.RecordType.Name, Account.FS_Headquarters__c FROM Contact WHERE Id IN :mapContacts.keySet()]){
        if(con.Account.RecordType.Name == FSConstants.RECORD_TYPE_NAME_OUTLET){
          mapContactId_AccountId.put(con.Id, con.AccountId);
          mapContactId_HqId.put(con.Id,con.Account.FS_Headquarters__c);
      }
    }
    
    final List<FS_Execution_Plan_Contact__c> lstOutletContacts = new List<FS_Execution_Plan_Contact__c>();
    for(Id contactId :mapContactId_AccountId.keySet()){
        final FS_Execution_Plan_Contact__c contactOutlet = new FS_Execution_Plan_Contact__c();
        contactOutlet.FS_Execution_Plan_Contact__c = contactId;
      contactOutlet.Outlet__c = mapContactId_AccountId.get(contactId);
      contactOutlet.FS_Headquarters__c = mapContactId_HqId.get(contactId);
      lstOutletContacts.add(contactOutlet);
    }
    insert lstOutletContacts;
  }
}