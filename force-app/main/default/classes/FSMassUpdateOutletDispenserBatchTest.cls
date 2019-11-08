/**************************************************************************************
Apex Class Name     : FSMassUpdateOutletDispenserBatchTest
Version             : 1.0
Function            : This test class is for  FSMassUpdateOutletDispenserBatch Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSMassUpdateOutletDispenserBatchTest{
    private static final String SERIES7000 ='7000 Series';   
    private static final String SERIES8000 ='8000 Series'; 
    private static final String SERIES9000 ='9000 Series';  
    private static final String SERIES8000N9000 ='8000 & 9000 Series';
    
    
    private static final String NUM7000 ='7000'; 
    private static final String NUM8000 ='8000';
    private static final String NUM9000 ='9000'; 
    
    private static final String CUSTOMFIELDEQUIPTYPE ='FS_Equip_Type__c';
    private static final String HEADQUARTERACCOUNTTYPE ='FS Headquarters';
    private static final String OUTLETACCOUNTTYPE ='FS Outlet';
    private static final String EXECUTIONPLANTYPE ='Execution Plan';
    
    private static final String UPLOADEDFILENAME='Dispenser WorkBook.csv';
    public static Platform_Type_ctrl__c platformTypes,platformTypes1,platformTypes2,platformTypes3,platformTypes4,platformTypes5; 
    
    @testSetup
    private static void loadTestData(){
        
        //custom setting trigger switch
        FSTestFactory.createTestDisableTriggerSetting();
        
        //create Brandset records
        FSTestFactory.createTestBrandset();
        
        //Create Single HeadQuarter
        final List<Account> headQuarterCustomerList= FSTestFactory.createTestAccount(true,1,
                                                                                     FSUtil.getObjectRecordTypeId(Account.SObjectType,HEADQUARTERACCOUNTTYPE));
        
        
        //Create Single Outlet
        final List<Account> outletCustomerList=new List<Account>();
        for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,OUTLETACCOUNTTYPE))){
            acc.FS_Headquarters__c=headQuarterCustomerList.get(0).Id;
            outletCustomerList.add(acc);
        }
        insert outletCustomerList;
        
        //Create Execution Plan
        //Collection to hold all recordtype names of Execution plan                                                                       
        final Set<String> executionPlanRecordTypesSet=new Set<String>{EXECUTIONPLANTYPE};
            //Collection to hold all recordtype values of Execution plan
            final Map<Id,String> executionPlanRecordTypesMap=new Map<Id,String>();
        
        final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
        //Create One executionPlan records for each record type
        for(String epRecType : executionPlanRecordTypesSet){
            
            final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,epRecType);
            
            executionPlanRecordTypesMap.put(epRecordTypeId,epRecType);
            
            final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(headQuarterCustomerList.get(0).Id,false,1,epRecordTypeId);
            
            executionPlanList.addAll(epList);                                                                     
        }
        //Verify that four Execution Plan got created
        system.assertEquals(1,executionPlanList.size());         
        Test.startTest();
        insert executionPlanList;

        //create platform type custom settings
        FSTestUtil.insertPlatformTypeCustomSettings();
        //set Mock callout
      	Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        
        //Create Installation
        final Set<String> installationPlanRecordTypesSet=new Set<String>{fsconstants.NEWINSTALLATION};
            
            final List<FS_Installation__c > installationPlanList=new List<FS_Installation__c >(); 
        
        final Map<Id,String> installationRecordTypeIdAndName=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
        //Create Installation for each Execution Plan according to recordtype
        
        for(String  installationRecordType : installationPlanRecordTypesSet){
            final Id intallationRecordTypeId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,fsconstants.NEWINSTALLATION); 
            final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustomerList.get(0).Id,false,1,intallationRecordTypeId);
            installationPlanList.addAll(installList);
        } 
        
        insert installationPlanList;  
        //Verify that 4 (1 * 4) Installation Plan got created
        system.assertEquals(1,installationPlanList.size()); 
        
        final List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        
        
        //Create Outlet Dispensers 
        for(FS_Installation__c installPlan : [SELECT Id,Type_of_Dispenser_Platform__c,RecordTypeId,FS_Outlet__c FROM FS_Installation__c  limit 100]){
            List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
            Id outletDispenserRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,FsConstants.RT_NAME_CCNA_OD);
           
            if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM7000)){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'A');
                odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM7000 );
            }
            if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM8000)){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'B');
                odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM8000 );
            }
            
            if(installPlan.Type_of_Dispenser_Platform__c.contains(NUM9000) ){
                odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,outletDispenserRecordTypeId,false,1,'D');
                odList[0].put(CUSTOMFIELDEQUIPTYPE, NUM9000 );
            }
            
            outletDispenserList.addAll(odList);
            
        }   
        system.assert(outletDispenserList.size()==1);
        Test.stopTest();
        
        insert outletDispenserList;

    }
    
    private static testMethod void testReadValidDocument(){
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
        final List<FS_Outlet_Dispenser__c> createdDispensers=[SELECT Id,FS_Outlet__c,FS_Equip_Type__c,FS_Dispenser_Type2__c,FS_Serial_Number2__c,FS_IsActive__c,Installation__r.Name FROM FS_Outlet_Dispenser__c LIMIT 100];
        
        final Blob csvFile=FSTestFactory.createValidCSVBlobForPostInstallAttributes(createdDispensers); 
        final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
        insert sysAdminUser;
        
        system.runAs(sysAdminUser){
        //create parent csv Holder
        final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
        holder.FS_WorkBook_Name__c=UPLOADEDFILENAME;
        insert holder;
        
        //create Attachment
        final Attachment file= new Attachment();
        file.Body=csvFile;
        file.parentId = holder.Id;
        file.Name=UPLOADEDFILENAME; 
        insert file;
        
        //Before state of dispenser record
        final Integer countOfRecordsBeforeupdate=[SELECT COUNT() FROM FS_Outlet_Dispenser__c WHERE FS_CE_Enabled_New__c!=null and FS_CE_Enabled_Effective_Date__c !=null];
            
        //Verify no values on dispenser record
        system.assert(countOfRecordsBeforeupdate==0 );
        
            Test.startTest();
            Database.executeBatch(new FSMassUpdateOutletDispenserBatch(holder.Id));
            Test.stopTest();
        }
        
        //After state of dispenser record
        final Integer countOfRecordsAfterUpdate=[SELECT COUNT() FROM FS_Outlet_Dispenser__c WHERE FS_CE_Enabled_New__c!=null and FS_CE_Enabled_Effective_Date__c !=null];
    }
    
}