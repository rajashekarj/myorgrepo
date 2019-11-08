/**************************************************************************************
Apex Class Name     : FSCopytoLower_Cancel_ValidFill_Test
Version             : 1.0
Function            : This is a Test class for FSCopytoLower_Cancel_ValidFill_Extension Apex Class
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkat FNF 6.0         02/12/2019        Original Version
*************************************************************************************/
@isTest
public class FSCopytoLower_Cancel_ValidFill_Test {
    
    
    public static testMethod void copyCancelvalidFillTest(){
        
        //Create HeadQuarters       
        final List<Account> headQuarterList= FSTestFactory.createTestAccount(true,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,FSConstants.RECORD_TYPE_NAME_HQ));
        //creating outlet
        final List<Account> outletLst = FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,FSConstants.RECORD_TYPE_NAME_OUTLET));
        for(Account outlet : outletLst){
            outlet.FS_Headquarters__c =  headQuarterList[0].id;
        }
        insert outletLst;
        FSTestFactory.createTestDisableTriggerSetting();
        final List<FS_Valid_Fill__c> validFillList=new List<FS_Valid_Fill__c>();
        FS_Valid_Fill__c validFill = new FS_Valid_Fill__c();
        validFill =FSTestUtil.createValidFill('7000',false);
        validFill.FS_Outlet__c=outletLst[0].id;      
        validFillList.add(validFill);  
        insert validFillList;
        Test.startTest();
        final PageReference pageRef=Page.FSCopytoLowerValidFill;
        pageRef.getParameters().put('id',outletLst[0].id);   
        //Sets the current PageReference for the controller
        Test.setCurrentPage(pageRef);
        
        final ApexPages.StandardSetController stdcon = new ApexPages.StandardSetController(validFillList);   
        stdcon.setSelected(validFillList);
        stdcon.getSelected();
        final FSCopytoLower_Cancel_ValidFill_Extension controller= new FSCopytoLower_Cancel_ValidFill_Extension(stdcon);
        
        Test.stopTest();   
        
    }
}