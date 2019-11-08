//
// 17th March 2015   Original   Kirti Agarwal    Ref(T-367311/T-318009)
// Purpose : Update Accounts with Invoice Information
//
global class FSUpdateInvoiceForAccountBatch implements  Database.Batchable<sObject>, Database.Stateful{

   public Set<Id> lstAllChainAccIds = new set<Id>();
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
   public Boolean checkCarFeePaymentUpdate;
   public Boolean checkAppCarPayment;
   //Constructor
   public FSUpdateInvoiceForAccountBatch (Set<Id> lstAllChainAccIds, Set<Id> lstAllHQAccIds, Map<Id, Boolean> mapChangedInvoiceCustomer,
    Map<Id, Boolean> mapChangedProgramFee,Map<Id, Boolean> mapInvoiceDeliveryMethod,Map<Id, Boolean> mapSecondaryEmail1,
    Map<Id, Boolean> mapSecondaryEmail2,Map<Id, Boolean> mapSecondaryEmail3,Map<Id, Boolean> mapSecondaryEmail4,Map<Id, Boolean> mapSecondaryEmail5,
     Boolean checkCarFeePaayment,Boolean checkAppCarPayment  ) {
    
     this.lstAllChainAccIds = lstAllChainAccIds;
     this.lstAllHQAccIds = lstAllHQAccIds;
     
     this.mapChangedInvoiceCustomer = mapChangedInvoiceCustomer;
     this.mapChangedProgramFee = mapChangedProgramFee;
     this.mapInvoiceDeliveryMethod =mapInvoiceDeliveryMethod ;
     this.mapSecondaryEmail1 =mapSecondaryEmail1 ;
     this.mapSecondaryEmail2 =mapSecondaryEmail2 ;
     this.mapSecondaryEmail3 =mapSecondaryEmail3 ;
     this.mapSecondaryEmail4 =mapSecondaryEmail4 ;
     this.mapSecondaryEmail5 =mapSecondaryEmail5 ;
     this.checkCarFeePaymentUpdate=checkCarFeePaayment;
     this.checkAppCarPayment=checkAppCarPayment ;
   }

   /****************************************************************************
    //Start the batch and query
    /***************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
         //Query locator used to get all account type of headquarter
         return Database.getQueryLocator([SELECT Id, FS_Chain__c,
                                                     FS_Chain__r.Invoice_Customer__c,
                                                     FS_Headquarters__r.Invoice_Customer__c,
                                                     FS_Headquarters__c,
                                                     FS_Headquarters__r.FS_Chain__c,
                                                     FS_Headquarters__r.FS_Chain__r.Invoice_Customer__c,
                                                     FS_Chain__r.FS_Payment_Type__c,
                                                     FS_Chain__r.FS_Payment_Method__c,
                                                     FS_Headquarters__r.FS_Chain__r.FS_Payment_Type__c,
                                                     FS_Headquarters__r.FS_Payment_Method__c,
                                                     RecordType.Name
                                                     FROM Account
                                                     WHERE (RecordTypeId =: FSConstants.RECORD_TYPE_HQ
                                                     Or RecordTypeId =: FSConstants.RECORD_TYPE_OUTLET)
                                                     AND (FS_Chain__c IN: lstAllChainAccIds
                                                     OR FS_Headquarters__r.FS_Chain__c IN : lstAllChainAccIds)]);


    }

    /****************************************************************************
    //Process a batch
    /***************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> accountList){
        List<Id> listChainIds = new List<Id>(lstAllChainAccIds);
        List<Id> listHQIds = new List<Id>(lstAllHQAccIds);
        
        if(!listChainIds.isEmpty()){
          AsyncApexJob job= [SELECT Createdby.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
          try {
            
            Messaging.SingleEmailMessage mailNotificationStartBatch = new Messaging.SingleEmailMessage(); 
            Map<Id, Account> mapIdAccount = new  Map<Id, Account>([SELECT Id, Name, FS_ACN__c FROM Account WHERE Id IN :lstAllChainAccIds OR Id IN :lstAllHQAccIds]);
            
            String mailContent ='Dear User, <br><br>';
      
            String mailSubject = 'Change Request Submitted for Inheriting values from Chain to Headquarter, and/or Chain to Headquarter to Outlet';
            
            if(!listChainIds.isEmpty() && listChainIds.size() == 1 ) {
                
                if(mapIdAccount!= null && mapIdAccount.containsKey(listChainIds.get(0))) {
                    mailSubject += ' for Chain '+ mapIdAccount.get(listChainIds.get(0)).Name + ' ACN: '+mapIdAccount.get(listChainIds.get(0)).FS_ACN__c;    
                }
                
                mailContent += 'The Program Fee Invoicing and/or Cartridge Payment changes are submitted for related Headquarters and Outlets. <br>';
                
            } else if(!listHQIds.isEmpty() && listHQIds.size() == 1) {
                
                if(mapIdAccount!= null && mapIdAccount.containsKey(listHQIds.get(0))) {
                    mailSubject += ' for Headquarter '+ mapIdAccount.get(listHQIds.get(0)).Name + ' ACN: '+mapIdAccount.get(listHQIds.get(0)).FS_ACN__c;    
                }
                
                mailContent += 'The changes of Approval Program Fee Invoicing, and/or Approval Cartridge Payment Invoicing, and/or Program Fee Payment Method '
                                +', and/or Invoice Delivery Method'+' are completed for related Outlets <br>';
            
            } else {
            
                mailContent += 'The below changes are submitted for update on related Headquarters and Outlets <br>';
                mailContent += '    1. Approval for Program Fee Invoicing and/or, <br>';
                mailContent += '    2. Approval for Cartridge Payment Invoicing and/or, <br>';
                mailContent += '    3. Program Fee Payment Method  and/or,<br>';
                mailContent += '    4. Invoice Delivery Method  <br><br>';
                
            }
            mailContent += ' You will receive an email notification once the activity is completed. Please do not make further changes till that time.<br><br>';
            mailContent += ' Thank you for your patience. <br><br>';
            
            mailNotificationStartBatch.setSubject(mailSubject);
            mailNotificationStartBatch.setHtmlBody(mailContent); 
            //mailNotificationStartBatch.setTargetObjectId(job.CreatedById);
            mailNotificationStartBatch.saveAsActivity = false;
            mailNotificationStartBatch.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            List<String> listToAddresses = new List<String>();
            listToAddresses.add(job.Createdby.Email);
            
            mailNotificationStartBatch.setToAddresses(listToAddresses);
            
           Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailNotificationStartBatch});
           system.debug('Email Sent Successfull for Finish Step 1?'+result.get(0).isSuccess());
            
            } catch (Exception exp) {
                System.debug('Exception occurred Finish Step 1- '+exp);
            }
        }

        for(Account acc : (List<Account>)accountList){
            
            if(mapChangedInvoiceCustomer.get(acc.FS_Chain__c) != null || mapChangedInvoiceCustomer.get(acc.FS_Headquarters__r.FS_Chain__c) != null){
                //Chain's account have 'Payment Invoice Eligible' field true then Invoice Customer should be Yes,
                //else it should be No
                
                if(acc.RecordType.Name == FSConstants.RECORD_TYPE_NAME_HQ) 
                   acc.Invoice_Customer__c = acc.FS_Chain__r.Invoice_Customer__c;
                
                if(acc.RecordType.Name == FSConstants.RECORD_TYPE_NAME_OUTLET) 
                   acc.Invoice_Customer__c = acc.FS_Headquarters__r.FS_Chain__r.Invoice_Customer__c;
                
            }
            if(mapChangedProgramFee.get(acc.FS_Chain__c) != null || mapChangedProgramFee.get(acc.FS_Headquarters__r.FS_Chain__c) != null){
                if(acc.RecordType.Name == FSConstants.RECORD_TYPE_NAME_HQ){
                   acc.FS_Payment_Type__c = acc.FS_Chain__r.FS_Payment_Type__c;
                   system.debug('inside FSUpdateInvoiceForAccountBatch FS_Payment_Type__c 1: ' + acc.FS_Payment_Type__c);
                   //acc.FS_Payment_Method__c = acc.FS_Chain__r.FS_Payment_Method__c;
                   system.debug('inside FSUpdateInvoiceForAccountBatch FS_Payment_Method__c 2: ' + acc.FS_Payment_Method__c);
                   
                }else if(acc.RecordType.Name == FSConstants.RECORD_TYPE_NAME_OUTLET){
                   acc.FS_Payment_Type__c = acc.FS_Headquarters__r.FS_Chain__r.FS_Payment_Type__c;
                   acc.FS_Payment_Method__c = acc.FS_Headquarters__r.FS_Payment_Method__c;
                   
                }
            }
        }
        if(!accountList.isEmpty()) {
             database.update(accountList,false);
        }
    }

     /****************************************************************************
    //finish the batch
    /***************************************************************************/
    global void finish(Database.BatchableContext BC){
        List<Id> listChainIds = new List<Id>(lstAllChainAccIds);
        List<Id> listHQIds = new List<Id>(lstAllHQAccIds);
            
       if(!listChainIds.isEmpty()){
          AsyncApexJob job= [SELECT Createdby.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
       
        try {
            
            Messaging.SingleEmailMessage mailNotificationStartBatch = new Messaging.SingleEmailMessage(); 
            Map<Id, Account> mapIdAccount = new  Map<Id, Account>([SELECT Id, Name, FS_ACN__c FROM Account WHERE Id IN :lstAllChainAccIds OR Id IN :lstAllHQAccIds]);
            
            String mailContent ='Dear User, <br><br>';
            String mailSubject = 'Change Request Completed for Inheriting values from Chain to Headquarter, and/or Chain to Headquarter to Outlet';
            
            if(!listChainIds.isEmpty() && listChainIds.size() == 1 ) {
                
                if(mapIdAccount!= null && mapIdAccount.containsKey(listChainIds.get(0))) {
                    mailSubject += ' for Chain '+ mapIdAccount.get(listChainIds.get(0)).Name + ' ACN: '+mapIdAccount.get(listChainIds.get(0)).FS_ACN__c;    
                }
                
                mailContent += 'The Program Fee Invoicing and/or Cartridge Payment changes are completed for related Headquarters and Outlets. <br>';
                
            } else if(!listHQIds.isEmpty() && listHQIds.size() == 1) {
                
                if(mapIdAccount!= null && mapIdAccount.containsKey(listHQIds.get(0))) {
                    mailSubject += ' for Headquarter '+ mapIdAccount.get(listHQIds.get(0)).Name + ' ACN: '+mapIdAccount.get(listHQIds.get(0)).FS_ACN__c;    
                }
                
                mailContent += 'The changes of Approval Program Fee Invoicing, and/or Approval Cartridge Payment Invoicing, and/or Program Fee Payment Method '
                                +', and/or Invoice Delivery Method'+' are completed for related Outlets <br>';
            
            } else {
            
                mailContent += 'The below changes are submitted for update on related Headquarters and Outlets <br>';
                mailContent += '    1. Approval for Program Fee Invoicing and/or, <br>';
                mailContent += '    2. Approval for Cartridge Payment Invoicing and/or, <br>';
                mailContent += '    3. Program Fee Payment Method  and/or,<br>';
                mailContent += '    4. Invoice Delivery Method  <br><br>';
                
            }
            
            
            mailNotificationStartBatch.setSubject(mailSubject);
            mailNotificationStartBatch.setHtmlBody(mailContent); 
            //mailNotificationStartBatch.setTargetObjectId(job.CreatedById);
            mailNotificationStartBatch.saveAsActivity = false;
            mailNotificationStartBatch.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            List<String> listToAddresses = new List<String>();
            listToAddresses.add(job.Createdby.Email);
            
            mailNotificationStartBatch.setToAddresses(listToAddresses);
            
           Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailNotificationStartBatch});
           system.debug('Email Sent Successfull for Finish Step 1?'+result.get(0).isSuccess());
            
        } catch (Exception exp) {
            System.debug('Exception occurred Finish Step 1- '+exp);
        }
        }
       
        
        if(!lstAllHQAccIds.isEmpty()) {
            
            Integer batchSize = 2000;
            Database.executeBatch( new FSUpdateInvoiceForOutletAccountBatch(lstAllHQAccIds, mapChangedInvoiceCustomer, mapChangedProgramFee,mapInvoiceDeliveryMethod,
             mapSecondaryEmail1,mapSecondaryEmail2,mapSecondaryEmail3,mapSecondaryEmail4,mapSecondaryEmail5,checkCarFeePaymentUpdate,checkAppCarPayment), batchSize);
        }
    }

}