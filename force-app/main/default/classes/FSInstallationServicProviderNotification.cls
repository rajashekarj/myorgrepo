/**************************
Name         : FSInstallationServiceProviderNotification
Created By   : Infosys 
Created Date : 
Usage        : This class holds the business logic of the
               sending service provider Email Notification
******************************/
public class FSInstallationServicProviderNotification{
    
    private static final Object NULL_VAL = null;
    private static final Messaging.SingleEmailMessage NULL_OBJ = null;
    private static final String COMMA = ',';
    
    /**@desc: Frame the Email to be Sent to Service Provider Contacts
              and SME Users
      *@param FS_Installation__c installation,
              List<FS_IP_Technician_Instructions__c> IPTechInstructionList,
      *       Map<ID,Account> installationOutletMap,
              Map<ID,Account> installationRelatedVendorMap,
      *       FS_IP_Equipment_Package__c ipEqipPckg,Map<ID,user> installationSMEUserMap
      *@return Messaging.SingleEmailMessage
      * Modified as part of FET 5.0	
    */
    public static Messaging.SingleEmailMessage frameServiceProviderEmail(final FS_Installation__c installationInsatnce,
                                                                         final List<FS_IP_Technician_Instructions__c> techInstructInstructionList,
                                                                        final Map<ID,List<Contact>> mapOfServiceProviderAndContacts,
                                                                        final Map<ID,Account> installationOutletMap,
                                                                         final Map<ID,Account> installationRelatedVendorMap,
                                                                        final FS_IP_Equipment_Package__c equipmentPackageInstance,final Map<Id,user> installationSMEUserMap,Map<Id,user> regularInstallUsersMap){//OCR
                                                                            
                                                                        
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          if(installationInsatnce.FS_SP__c==null ||
             (installationInsatnce.FS_SP__c!=null && mapOfServiceProviderAndContacts.get(installationInsatnce.FS_SP__c)==null) ){     
                 mail = NULL_OBJ;
          }
          else{
              final Set<String> recepientEmails=new Set<String>();
              //Send to Service Provider Contact
              for(Contact serviceProvider : mapOfServiceProviderAndContacts.get(installationInsatnce.FS_SP__c)){                  
                  if(serviceProvider.Email!=NULL_VAL){
                      recepientEmails.add(serviceProvider.Email);
                  }
              }
              //Send to SME Users
              for(User smeUser: installationSMEUserMap.values()){ 
                  if(smeUser.Email!=NULL_VAL){
                     recepientEmails.add(installationSMEUserMap.get(smeUser.Id).Email);
                  }
              }   
              if(!recepientEmails.isEmpty()){
                  system.debug('$$$$$step7'); 
                  system.debug('recepientEmails:-'+recepientEmails);
				  //workaround to populate merge fields in the vf template
                  Id id1=[select id from EmailTemplate where DeveloperName='SpPlannerNotification'].id;
                  Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(id1,null,installationInsatnce.id);
                  
                  /** Pick a dummy Contact
                  Contact c = [select id, Email from Contact where email <> null limit 1];       
                  Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                  Set the template ID to the visualforce email template
                  msg.setTemplateId( [select id from EmailTemplate where DeveloperName='SpPlannerNotification'].id );
                  msg.setWhatId(installationInsatnce.id );
                  msg.setTargetObjectId(c.id);
                  To send the emails to service providers and SME users
                  msg.setToAddresses(new List<String>(recepientEmails));
                    
                  // Send the emails in a transaction, then roll it back
                  //This is a workaround for using email template without using setTargetObjectId
                  Savepoint sp = Database.setSavepoint();
                  Messaging.sendEmail(new Messaging.singleEmailMessage[] { msg });
                  Database.rollback(sp);
                  Once the email is populated after using the send email messgae, the contents of the dynamic email template will 
                  be available. assign it to another mail variable and return it.**/
                  
                  //assigning values to mail instance
                  mail.setToAddresses(new List<String>(recepientEmails));
                  mail.setPlainTextBody(email.getPlainTextBody());
                  mail.setHTMLBody(email.getHTMLBody());
                  mail.setSubject(email.getSubject());
              }
              else{
                  return NULL_OBJ;
              }
          }
          return mail;  
    }
    
     //FET 5.0
     public static Messaging.SingleEmailMessage frameServiceProviderEmailPIA(final FS_Installation__c installationInsatnce,                                                                         
                                                                         final Map<ID,List<Contact>> mapOfServiceProviderAndContacts,
                                                                        final Map<ID,Account> installationOutletMap,
                                                                          final List<FS_IP_Equipment_Package__c> equipmentPackageInstance,final Map<String,String> usersMap){ 
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      final Set<String> recepientEmails=new Set<String>();
      system.debug('$$$$$installation sp'+installationInsatnce.FS_SP__c);
      system.debug('$$$$$map install'+mapOfServiceProviderAndContacts.get(installationInsatnce.FS_SP__c));
      if(installationInsatnce.FS_SP__c==null ||
         (installationInsatnce.FS_SP__c!=null && mapOfServiceProviderAndContacts.get(installationInsatnce.FS_SP__c)==null) ){     
             mail = NULL_OBJ;
             system.debug('$$$$$mail:-'+mail);
       }
       else{
           //Send to Service Provider Contact
           for(Contact serviceProvider : mapOfServiceProviderAndContacts.get(installationInsatnce.FS_SP__c)){               
                 if(serviceProvider.Email!=NULL_VAL){
                    recepientEmails.add(serviceProvider.Email);
                 }
           } 
        system.debug('$$$$$recepientEmails:-'+recepientEmails);   
       if(!recepientEmails.isEmpty()){
                  system.debug('recepientEmails:-'+recepientEmails);
                  // Pick a dummy Contact
                  Contact c = [select id, Email from Contact where email <> null limit 1];       
                  Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                  //Set the template ID to the visualforce email template
                  msg.setTemplateId( [select id from EmailTemplate where DeveloperName='SpPlannerNotification'].id );
                  msg.setWhatId(installationInsatnce.id );
                  msg.setTargetObjectId(c.id);
                  //To send the emails to service providers and SME users
                  msg.setToAddresses(new List<String>(recepientEmails));
                    
                  // Send the emails in a transaction, then roll it back
                  // This is a workaround for using email template without using setTargetObjectId
                  Savepoint sp = Database.setSavepoint();
                  Messaging.sendEmail(new Messaging.singleEmailMessage[] { msg });
                  Database.rollback(sp);
                  //Once the email is populated after using the send email messgae, the contents of the dynamic email template will 
                  //be available. assign it to another mail variable and return it.
                  mail.setToAddresses(msg.getToAddresses());
                  mail.setPlainTextBody(msg.getPlainTextBody());
                  mail.setHTMLBody(msg.getHTMLBody());
                  mail.setSubject(msg.getSubject());
              }
              else{
                  return NULL_OBJ;
              }
       	}
        return mail;   
       }
}