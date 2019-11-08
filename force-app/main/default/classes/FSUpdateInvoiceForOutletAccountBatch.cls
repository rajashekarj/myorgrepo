//
// 17th March 2015   Original   Kirti Agarwal    Ref(T-367311/T-318009)
// Purpose : Update Accounts with Invoice Information
//
global class FSUpdateInvoiceForOutletAccountBatch implements  Database.Batchable<sObject>, Database.Stateful{

   public Set<Id> lstAllHQAccIds = new set<Id>();

   public Map<Id, Boolean> mapChangedInvoiceCustomer = new Map<Id, Boolean>();
   public Map<Id, Boolean> mapChangedProgramFee = new Map<Id, Boolean>();
   public Map<Id, Boolean> mapInvoiceDeliveryMethod = new Map<Id, Boolean>(); 
   public Map<Id, Boolean> mapSecondaryEmail1 = new Map<Id, Boolean>(); 
   public Map<Id, Boolean> mapSecondaryEmail2 = new Map<Id, Boolean>(); 
   public Map<Id, Boolean> mapSecondaryEmail3 = new Map<Id, Boolean>(); 
   public Map<Id, Boolean> mapSecondaryEmail4 = new Map<Id, Boolean>(); 
   public Map<Id, Boolean> mapSecondaryEmail5 = new Map<Id, Boolean>();
   public String OrgWideEmailAddressId=Label.OWEmailAddressId;
   public Boolean checkForCarPaymetMethod ;
   public boolean checkAppCartridgePay;
   //Constructor
   public FSUpdateInvoiceForOutletAccountBatch (final Set<Id> lstAllHQAccIds, final Map<Id, Boolean> mapChangedInvoiceCustomer,
    final Map<Id, Boolean> mapChangedProgramFee,final Map<Id, Boolean> mapInvoiceDeliveryMethod,final Map<Id, Boolean> mapSecondaryEmail1,
    final Map<Id, Boolean> mapSecondaryEmail2,final Map<Id, Boolean> mapSecondaryEmail3,final Map<Id, Boolean> mapSecondaryEmail4,final Map<Id, Boolean> mapSecondaryEmail5,
    Boolean checkCarFeePayment,Boolean checkAppCarPayment  ) {
     this.lstAllHQAccIds = lstAllHQAccIds;
     
     this.mapChangedInvoiceCustomer = mapChangedInvoiceCustomer;
     this.mapChangedProgramFee = mapChangedProgramFee;
     this.mapInvoiceDeliveryMethod =mapInvoiceDeliveryMethod ;
     this.mapSecondaryEmail1 =mapSecondaryEmail1 ;
     this.mapSecondaryEmail2 =mapSecondaryEmail2 ;
     this.mapSecondaryEmail3 =mapSecondaryEmail3 ;
     this.mapSecondaryEmail4 =mapSecondaryEmail4 ;
     this.mapSecondaryEmail5 =mapSecondaryEmail5 ;
     this.checkForCarPaymetMethod=checkCarFeePayment;
     this.checkAppCartridgePay=checkAppCarPayment;
   }

   /****************************************************************************
    //Start the batch and query
    /***************************************************************************/
    global Database.QueryLocator start(final Database.BatchableContext BC){

         
         //Query locator used to get all account type of outlet
         return Database.getQueryLocator([SELECT Id,FS_Headquarters__r.Invoice_Customer__c,
                                                     FS_Headquarters__r.Cokesmart_Payment_Method__c,
                                                     FS_Headquarters__r.FS_Payment_Type__c,
                                                     FS_Headquarters__r.FS_Payment_Method__c,
                                                     FS_Headquarters__r.Invoice_Delivery_Method__c,
                                                     FS_Headquarters__r.Secondary_Email_1__c,
                                                     FS_Headquarters__r.Secondary_Email_2__c,
                                                     FS_Headquarters__r.Secondary_Email_3__c,
                                                     FS_Headquarters__r.Secondary_Email_4__c,
                                                     FS_Headquarters__r.Secondary_Email_5__c
                                                     FROM Account
                                                     WHERE RecordTypeId = :FSConstants.RECORD_TYPE_OUTLET
                                                     AND FS_Headquarters__c IN :lstAllHQAccIds]);


    }

    /****************************************************************************
    //Process a batch
    /***************************************************************************/
    global void execute(final Database.BatchableContext BC, final List<sObject> accountList){
       try {
            final AsyncApexJob job= [SELECT Createdby.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            final List<Id> listHQIds = new List<Id>(lstAllHQAccIds);
            
            final Messaging.SingleEmailMessage mailNotificationStartBatch = new Messaging.SingleEmailMessage(); 
            final Map<Id, Account> mapIdAccount = new  Map<Id, Account>([SELECT Id, Name, FS_ACN__c FROM Account WHERE Id IN :lstAllHQAccIds]);
            
            String mailContent ='Dear User, <br><br>';
            String mailSubject = 'Change Request Submitted for Inheriting values from Headquarter to Outlet';
            
            if(!listHQIds.isEmpty() && listHQIds.size() == 1) {
                
                if(mapIdAccount!= null && mapIdAccount.containsKey(listHQIds.get(0))) {
                    mailSubject += ' for Headquarter '+ mapIdAccount.get(listHQIds.get(0)).Name + ' ACN: '+mapIdAccount.get(listHQIds.get(0)).FS_ACN__c;    
                }
                
                mailContent += 'The changes of Approval Program Fee Invoicing, and/or Approval Cartridge Payment Invoicing, and/or Program Fee Payment Method '
                                +', and/or Invoice Delivery Method'+ ' are submitted for related Outlets <br>';
            
            } else {
            
                mailContent += 'The below changes are submitted for update on related Outlets <br>';
                mailContent += '    1. Approval for Program Fee Invoicing and/or, <br>';
                mailContent += '    2. Approval for Cartridge Payment Invoicing and/or, <br>';
                mailContent += '    3. Program Fee Payment Method  and/or,<br>';
                mailContent += '    4. Invoice Delivery Method  <br><br>';
                
            }
            mailContent += ' You will receive an email notification once the activity is completed. Please do not make further changes till that time.<br><br>';
            mailContent += ' Thank you for your patience. <br><br>';
            
            
            mailNotificationStartBatch.setSubject(mailSubject);
            mailNotificationStartBatch.setHtmlBody(mailContent); 
            mailNotificationStartBatch.saveAsActivity = false;
            mailNotificationStartBatch.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            final List<String> listToAddresses = new List<String>();
            listToAddresses.add(job.Createdby.Email);
            mailNotificationStartBatch.setToAddresses(listToAddresses);
            
           final Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailNotificationStartBatch});

            
        } catch (Exception exp) {
            System.debug('Exception occurred Start Step 2- '+exp);
        }
        
        
       for(Account acc : (List<Account>)accountList){
            if(mapChangedInvoiceCustomer.get(acc.FS_Headquarters__c) != null){ 
                    if(checkAppCartridgePay){
                    acc.Invoice_Customer__c =acc.FS_Headquarters__r.Invoice_Customer__c;
                }
                // Fet 4.0 Change  
                //Updating cartridge fee payment method in outlet when the corresponding field changes in Headquarters
                system.debug('Inside outlet:::'+acc.FS_Headquarters__r.Cokesmart_Payment_Method__c);  
                //Check weather cartridge fee payment method is updated at HQ level
                if(checkForCarPaymetMethod){
                    acc.Cokesmart_Payment_Method__c = acc.FS_Headquarters__r.Cokesmart_Payment_Method__c;
                }
              }
            if(mapChangedProgramFee.get(acc.FS_Headquarters__c) != null){
                acc.FS_Payment_Type__c = acc.FS_Headquarters__r.FS_Payment_Type__c;
                acc.FS_Payment_Method__c = acc.FS_Headquarters__r.FS_Payment_Method__c;
            }
            if(mapInvoiceDeliveryMethod.get(acc.FS_Headquarters__c) != null){
                  acc.Invoice_Delivery_Method__c=acc.FS_Headquarters__r.Invoice_Delivery_Method__c;
            }
            if(mapSecondaryEmail1.get(acc.FS_Headquarters__c) != null){
                  acc.Secondary_Email_1__c=acc.FS_Headquarters__r.Secondary_Email_1__c;
            }
            if(mapSecondaryEmail2.get(acc.FS_Headquarters__c) != null){
                  acc.Secondary_Email_2__c=acc.FS_Headquarters__r.Secondary_Email_2__c;
            }
            if(mapSecondaryEmail3.get(acc.FS_Headquarters__c) != null){
                  acc.Secondary_Email_3__c=acc.FS_Headquarters__r.Secondary_Email_3__c;
            }
            if(mapSecondaryEmail4.get(acc.FS_Headquarters__c) != null){
                  acc.Secondary_Email_4__c=acc.FS_Headquarters__r.Secondary_Email_4__c;
            }
            if(mapSecondaryEmail5.get(acc.FS_Headquarters__c) != null){
                  acc.Secondary_Email_5__c=acc.FS_Headquarters__r.Secondary_Email_5__c;
            }
        }
        if(!accountList.isEmpty()) {
              database.update(accountList,false);
        }
    }

     /****************************************************************************
    //finish the batch
    /***************************************************************************/
    global void finish(final Database.BatchableContext BC){
         final AsyncApexJob job= [SELECT Createdby.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
         
      try {
            
            final List<Id> listHQIds = new List<Id>(lstAllHQAccIds);
            
            final Messaging.SingleEmailMessage mailNotificationStartBatch = new Messaging.SingleEmailMessage(); 
            final Map<Id, Account> mapIdAccount = new  Map<Id, Account>([SELECT Id, Name, FS_ACN__c FROM Account WHERE Id IN :lstAllHQAccIds]);
            
            String mailContent ='Dear User, <br><br>';
            String mailSubject = 'Change Request Completed for Inheriting values from Headquarter to Outlet';
            
            if(!listHQIds.isEmpty() && listHQIds.size() == 1) {
                
                if(mapIdAccount!= null && mapIdAccount.containsKey(listHQIds.get(0))) {
                    mailSubject += ' for Headquarter '+ mapIdAccount.get(listHQIds.get(0)).Name + ' ACN: '+mapIdAccount.get(listHQIds.get(0)).FS_ACN__c;    
                }
                
                mailContent += 'The changes of Approval Program Fee Invoicing, and/or Approval Cartridge Payment Invoicing, and/or Program Fee Payment Method '
                                +', and/or Invoice Delivery Method'+ ' are completed for related Outlets <br>';
            
            } else {
            
                mailContent += 'The below changes are completed for update on related Outlets <br>';
                mailContent += '    1. Approval for Program Fee Invoicing and/or, <br>';
                mailContent += '    2. Approval for Cartridge Payment Invoicing and/or, <br>';
                mailContent += '    3. Program Fee Payment Method  and/or,<br>';
                mailContent += '    4. Invoice Delivery Method  <br><br>';
                
            }
            mailNotificationStartBatch.setSubject(mailSubject);
            mailNotificationStartBatch.setHtmlBody(mailContent); 
            mailNotificationStartBatch.saveAsActivity = false;
            mailNotificationStartBatch.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            final List<String> listToAddresses = new List<String>();
            listToAddresses.add(job.CreatedBy.Email);
            
            mailNotificationStartBatch.setToAddresses(listToAddresses);
            
            final Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailNotificationStartBatch});
        } 
            catch (Exception exp) {
            System.debug('Exception occurred Finish Step 2- '+exp);
        }
    }

}