/**
 * Created By   : Satyanarayan Choudhary(JDC Developer)
 * Related Task : T-217390
 * Decscription :   A handler class for FSExecutionPlanContactTrigger to Copy Execution Plan Contacts to Outlet Lookup Fields 
 */
public with sharing class FSExecutionPlanContactTriggerHandler {
    
    public static void afterInsertAndUpdate(){
        Set<Id> ePContactSet = new Set<Id>();
        final List<FS_Execution_Plan_Contact__c> lstEPContact = Trigger.new;
        final Map<Id,FS_Execution_Plan_Contact__c> oldMap = (Map<Id,FS_Execution_Plan_Contact__c>)Trigger.oldMap;
        if(Trigger.isInsert){
            ePContactSet = Trigger.newMap.keySet(); 
        }   
        if(Trigger.isUpdate){            
            for(FS_Execution_Plan_Contact__c cObjEPContact : lstEPContact){
                if(cObjEPContact.FS_Execution_Plan_Contact__c != null && cObjEPContact.FS_Execution_Plan_Contact__c != oldMap.get(cObjEPContact.Id).FS_Execution_Plan_Contact__c){                   
                        ePContactSet.add(cObjEPContact.Id);
                }   
            } 
        }
        if(ePContactSet.size() > 0)
        copyExecutionPlanContactsToOutlet(ePContactSet);    
    }
    
    /**
     * A Method which Copy Execution Plan Contacts to Outlet Lookup Fields
     */
    private static void copyExecutionPlanContactsToOutlet(final Set<Id> ePContactSet){
        final Map<Id,Account> accMap = new Map<Id,Account>();
        Account sObjAcc;
        Boolean isUpdated = false;
        for(FS_Execution_Plan_Contact__c cObjEPContact : [SELECT Id, FS_Execution_Plan_Contact__c, 
                                                                     FS_Execution_Plan_Contact__r.FS_Execution_Plan_Role__c, 
                                                                     FS_Execution_Plan_Contact__r.Name,
                                                                     FS_Execution_Plan_Contact__r.Phone,
                                                                     FS_Execution_Plan_Contact__r.FS_Alternate_Phone_Cell__c,
                                                                     FS_Execution_Plan_Contact__r.Email,
                                                                     FS_Execution_Plan_Contact__r.Title,
                                                                     Outlet__c 
                                                          FROM FS_Execution_Plan_Contact__c WHERE Id in :ePContactSet]){
            if(cObjEPContact.Outlet__c != null && cObjEPContact.FS_Execution_Plan_Contact__r.FS_Execution_Plan_Role__c != null){
                sObjAcc = new Account(Id = cObjEPContact.Outlet__c);
                
                //Added in OCR1 Req to bypass Bottler by srinivas
                FSConstants.BypassOrderDelivery =true;
                // FS_Execution_Plan_Role__c can cantains multiple values so we are cheking for all
                if(cObjEPContact.FS_Execution_Plan_Contact__r.FS_Execution_Plan_Role__c.contains('Site Assessment Contact')){
                    sObjAcc.FS_Site_Assessment_Contact__c = cObjEPContact.FS_Execution_Plan_Contact__c;
                    sObjAcc.FS_Site_Assessment_Contact_Name__c = cObjEPContact.FS_Execution_Plan_Contact__r.Name;
                    sObjAcc.FS_Site_Assessment_Contact_Phone__c = cObjEPContact.FS_Execution_Plan_Contact__r.Phone;
                    sObjAcc.FS_Site_Assessment_Contact_Alt_Phone__c = cObjEPContact.FS_Execution_Plan_Contact__r.FS_Alternate_Phone_Cell__c; 
                    sObjAcc.FS_Site_Assessment_Contact_Email__c = cObjEPContact.FS_Execution_Plan_Contact__r.Email;
                    sObjAcc.FS_Site_Assessment_Contact_Title__c = cObjEPContact.FS_Execution_Plan_Contact__r.Title;
                    isUpdated = true;   
                }
                if(cObjEPContact.FS_Execution_Plan_Contact__r.FS_Execution_Plan_Role__c.contains('Coke Smart Admin User')){
                    sObjAcc.FS_Admin_User__c = cObjEPContact.FS_Execution_Plan_Contact__c;
                    sObjAcc.FS_Admin_User_Name__c = cObjEPContact.FS_Execution_Plan_Contact__r.Name;
                    sObjAcc.FS_Admin_User_Phone__c = cObjEPContact.FS_Execution_Plan_Contact__r.Phone;
                    sObjAcc.FS_Admin_User_Alt_Phone__c = cObjEPContact.FS_Execution_Plan_Contact__r.FS_Alternate_Phone_Cell__c;
                    sObjAcc.FS_Admin_User_Email__c = cObjEPContact.FS_Execution_Plan_Contact__r.Email;
                    sObjAcc.FS_Admin_User_Title__c = cObjEPContact.FS_Execution_Plan_Contact__r.Title;
                    isUpdated = true;   
                }
                if(cObjEPContact.FS_Execution_Plan_Contact__r.FS_Execution_Plan_Role__c.contains('Installation Contact')){
                    sObjAcc.FS_Installation_Contact__c = cObjEPContact.FS_Execution_Plan_Contact__c;
                    sObjAcc.FS_Installation_Contact_Name__c = cObjEPContact.FS_Execution_Plan_Contact__r.Name;
                    sObjAcc.FS_Installation_Contact_Phone__c = cObjEPContact.FS_Execution_Plan_Contact__r.Phone;
                    sObjAcc.FS_Installation_Contact_Alt_Phone__c = cObjEPContact.FS_Execution_Plan_Contact__r.FS_Alternate_Phone_Cell__c;
                    sObjAcc.FS_Installation_Contact_Email__c = cObjEPContact.FS_Execution_Plan_Contact__r.Email;
                    sObjAcc.FS_Installation_Contact_Title__c = cObjEPContact.FS_Execution_Plan_Contact__r.Title;
                    isUpdated = true;   
                }
                
                // check if any of one field of account updated
                if(isUpdated)
                accMap.put(sObjAcc.Id,sObjAcc);
                isUpdated = false;
            }
        }
        
        if(accMap.size() > 0)
        update accMap.values();         
    }    
    
}