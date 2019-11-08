/*************************************************************************************************** 
Created By   : Pallavi Sharmar (Appiro JDC)
Date         : Oct 31, 2013
Usage        : Trigger Handler for Contact 
History      : Modified by capgemini to add the logic to call CCR related Class for Coca-Cola Contact Sharing   
: Modified by Infosys to add the logic to create community users and contacts  
***************************************************************************************************/
trigger ContactTrigger on Contact(before insert, before update, after insert) {
    
    static final string PROFILE_NAME='Service Escalation Community'; 
    //FET 7.0 FNF-823
    Boolean isAnyMigrationInProgress = false;
    //Whenever data migration is happening then make this value off in Disable trigger custom setting    
    Disable_Trigger__c disableTriggerSetting = Disable_Trigger__c.getInstance('FSContactTriggerHandler');
    
    if(disableTriggerSetting != null && !disableTriggerSetting.IsActive__c ){
        isAnyMigrationInProgress = true;
    }
    if(!isAnyMigrationInProgress){
        //FET 7.0 FNF-823        
        //Get the profile Name of the logged in user-Service Escalation Phase-2
        String profileName=FSUtil.getProfileName();  
        
        // Updating Multi-Select Picklist field        
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            //ContactTriggerHandler.updateMSelectPickField(Trigger.new);
            ContactTriggerHandler.checkForDuplicateServiceProviderContacts(Trigger.new);
            //Below code is added as part of Service Escalation phase-2
            if( Trigger.isInsert == TRUE && profileName.contains(PROFILE_NAME))
                SECommunityTriggerHandler.insertContacts(trigger.new);
            //CCR Related Class to be called from here.
            /*if(Trigger.isInsert ){
					CCRContactShareHandler contactobj= new CCRContactShareHandler();
					contactobj.contactShareMethod(Trigger.new);
			}*/            
        }
        
        
        // Inserting new record in junction object "Outlet Contact" when new contact is created.       
        if(Trigger.isInsert && Trigger.isAfter){
            ContactTriggerHandler.insertNewRecordOutletContac(Trigger.newMap);
            //Added this code as part of Service Escalation Phase-2
            if( profileName.contains(PROFILE_NAME))
                SECommunityTriggerHandler.createCommUsers(trigger.new);
        }
    }
}