@isTest
public class FsCIFReParentTriggerHelperTest {
    public static CIF_Header__c cifHead;
    private static Account chainAcc,accHeadQtr,accOutlet1,accOutlet2,accOutlet3;
    public static  string valTest = 'test';
    public static final string NO9000 = '9000';
    public static final string NO8000 = '8000';
    public static final string NO7000 = '7000';
    public static final string CUSTAPPROVED = 'Approved by Customer'; 
    
    
    private static testmethod void cifCreation(){
        
        Disable_Trigger__c disableTriggerSetting = new Disable_Trigger__c();
        disableTriggerSetting.name='FSCOMNotifications';
        disableTriggerSetting.IsActive__c=true;
        disableTriggerSetting.Trigger_Name__c='FSCOMNotifications' ; 
        insert disableTriggerSetting;  
        
        Disable_Trigger__c disableTriggerSetting2 = new Disable_Trigger__c();
        disableTriggerSetting2.name='FSCIFHeaderTrigger';
        disableTriggerSetting2.IsActive__c=true;
        disableTriggerSetting2.Trigger_Name__c='FSCIFHeaderTrigger' ; 
        insert disableTriggerSetting2;  
        
        final List<Account> hqCustList= FSTestFactory.createTestAccount(true,2,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
        //Creating cifHead
        cifHead = new CIF_Header__c();
        cifHead.Name =hqCustList[0].name+' V.0';
        cifHead.FS_Version__c = 10.02;
        cifHead.FS_HQ__c=hqCustList[0].id;
        insert cifHead;
        
        chainAcc=FSTestUtil.createTestAccount('Test Chain 1',FSConstants.RECORD_TYPE_CHAIN,true);  
        accHeadQtr = FSTestUtil.createTestAccount('Test Headquarters',FSConstants.RECORD_TYPE_HQ,false);
        
        accHeadQtr.FS_Chain__c=chainAcc.Id;
        insert accHeadQtr;  
        //Create Outlet Account  
        accOutlet1 = FSTestUtil.createAccountOutlet(valTest,FSConstants.RECORD_TYPE_OUTLET,accHeadQtr.Id, false);
        accOutlet1.Name = valTest;
        accOutlet1.FS_ACN__c = 'test1';
        accOutlet1.ShippingCity = valTest;
        accOutlet1.ShippingState = valTest;
        accoutlet1.RecordTypeId=FSUtil.getObjectRecordTypeId(Account.sObjectType,'FS Outlet');
        insert accOutlet1;
        
        final FS_CIF__c cif1=new FS_CIF__c();
        cif1.FS_Account__c=accOutlet1.Id;
        cif1.CIF_Head__c=cifHead.Id;
        ID headID=cifHead.Id;
        //cif1.FS_Select_Site_assessment_contact__c=contact1.Id;
        cif1.FS_Platform1__c=NO9000;
        cif1.FS_Platform2__c=NO8000;
        cif1.FS_Platform3__c=NO7000;
        cif1.FS_EP_Check__c=true;
        cif1.FS_Customer_s_disposition_after_review__c=CUSTAPPROVED;
        insert cif1;
      
        cifHead.FS_HQ__c=hqCustList[1].id;
        update cifhead;
  
    }
    
}