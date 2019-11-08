/******************************
Name         : EmailTriggerHelper
Created By   : Lavanya & Team
Description  : Email Helper class
Created Date : July 19, 2016

******************************/

public with sharing class EmailTriggerHelper{
    public static void sendEmailContact(List<Id> oDId){
        try{
                String response='';
                                
                //Find od
                 List<FS_Outlet_Dispenser__c> oDList = [Select isDefaultOutlet__c, Outlet_Zip_Code__c,Outlet_Country__c, Warehouse_Name_formula__c,
                                                        Warehouse_Country_formula__c,FS_Outlet__r.ShippingPostalCode, FS_Serial_Number2__c,
                                                        FS_Outlet__r.shippingCountry, FS_Outlet__r.Bottlers_Name__c ,FS_Equip_Type__c,
                                                        Warehouse_Country_New__c From FS_Outlet_Dispenser__c
                                                        WHERE ID =: oDId];
                                                        
                system.debug('In email trigger helper');  
                          
                Set<String> botAccount = new Set<String>(); 
                Set<String> outCountry = new Set<String>(); 
                for(FS_Outlet_Dispenser__c temp : oDList){
                    botAccount.add( temp.FS_Outlet__r.bottlers_name__c);
                    outCountry.add(temp.Outlet_Country__c);
                }
                //getting contact of bottler
                List<Contact> contactList= [Select id,Email,MailingCountry,Warehouse_Country__c,MailingPostalCode ,account.name from Contact where accountid in :botAccount];
                List<String> sendTo = new List<String>();
                String[] ccEmail;
                String equipmentType;                
                for(FS_Outlet_Dispenser__c od:oDList){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                equipmentType=od.FS_Equip_Type__c;
                        for(Contact c:contactList){
                            if(c.Warehouse_Country__c==od.FS_Outlet__r.shippingCountry){
                                sendTo.add(c.Email);
                                ccEmail=new String[]{UserInfo.getUserEmail()};
                             }
                       }        
                                //Recipients
                                mail.setToAddresses(sendTo);
                                mail.setCcAddresses(ccEmail);
                                mail.setSenderDisplayName('Coca-Cola');
                                //Subject
                                mail.setSubject('FET International Dispenser Delivered' );
                                //Body
                                //system.debug('In for loop'+c.email);
                                String body= Label.Email_Subject;
                                       body=body+'<br>Dispenser with serial number '+od.FS_Serial_Number2__c;
                                       body=body+' a Series '+equipmentType
                                            +' dispenser has been delivered to '+ od.Warehouse_Name_formula__c
                                            +' in '+od.Warehouse_Country_formula__c
                                            +'<br><br><b>This dispenser is available for Assignment to an Outlet. </b><br>';      
                                mail.setHtmlBody(body);                               

                                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                    if(resultMail[0].isSuccess()){ response = 'email sent successfully';  }
                                    else{response = resultMail[0].getErrors().get(0).getMessage();}
                                
                           }
                      
             } catch(exception e){
                System.debug('Exception in last try catch(): ' + e.getMessage());
                ApexErrorLogger.addApexErrorLog('FET','EmailTriggerHelper','sendEmailContact','NA','Medium',e,'NA');
             }
      }
}