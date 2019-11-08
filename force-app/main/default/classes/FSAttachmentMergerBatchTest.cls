/**************************************************************************************
Apex Class Name     : FSAttachmentMergerBatchTest
Version             : 1.0
Function            : This test class is for  FSAttachmentMergerBatch Class code coverage. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             02/24/2017          Original Version 
*                     05/29/2018          Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
private class FSAttachmentMergerBatchTest{
    private static final String SERIES7K = '7000 Series';
      private static final String SERIES8K9K = '8000 & 9000 Series';
      private static final String SERIES8K = '8000 Series';
      private static final String SERIES9K = '9000 Series';
      private static final String EQUIPTYP = 'FS_Equip_Type__c';
      private static final string LIT7K = '7000';
      private static final string LIT8K = '8000';
      private static final string LIT9K = '9000';
      
      private static final String SUCCESSFILENAME='Success Records.csv';
       private static final String FAILUREFILENAME='Failed Records.csv';
       
       private static final String FINALSUCESFILENAM='All Success Records.csv';
       private static final String FINALFAILRFILENAM='All Failed Records.csv';
      
    @testSetup
    public static void loadTestData(){
      
       //custom setting trigger switch
      FSTestFactory.createTestDisableTriggerSetting();
      
      //create Brandset records
      FSTestFactory.createTestBrandset();
      
      //Create Single HeadQuarter
      final List<Account> hqCustList= FSTestFactory.createTestAccount(true,1,
                                                                             FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Headquarters'));
      
    
      //Create Single Outlet
      final List<Account> outletCustList=new List<Account>();
      for(Account acc : FSTestFactory.createTestAccount(false,1,FSUtil.getObjectRecordTypeId(Account.SObjectType,'FS Outlet'))){
        acc.FS_Headquarters__c=hqCustList.get(0).Id;
        outletCustList.add(acc);
      }
      insert outletCustList;
      
      //Create Execution Plan
      //Collection to hold all recordtype names of Execution plan                                                                       
      final Set<String> epRecTypSet=new Set<String>{'Execution Plan'};
      //Collection to hold all recordtype values of Execution plan
      final Map<Id,String> epRecTypMap=new Map<Id,String>();
      
      final List<FS_Execution_Plan__c> executionPlanList=new List<FS_Execution_Plan__c>();
      //Create One executionPlan records for each record type
      for(String epRecType : epRecTypSet){
      
        final Id epRecordTypeId=FSUtil.getObjectRecordTypeId(FS_Execution_Plan__c.SObjectType,epRecType);
        
        epRecTypMap.put(epRecordTypeId,epRecType);
        
        final List<FS_Execution_Plan__c> epList=FSTestFactory.createTestExecutionPlan(hqCustList.get(0).Id,false,1,epRecordTypeId);
        
        executionPlanList.addAll(epList);                                                                     
      }
      //Verify that four Execution Plan got created
      system.assertEquals(1,executionPlanList.size());         
      
      insert executionPlanList;
      
      
      
      //Create Installation
       final Set<String> ipRecTypSet=new Set<String>{FSConstants.NEWINSTALLATION};
       
       final List<FS_Installation__c > ipList=new List<FS_Installation__c >(); 
       
       final Map<Id,String> instRecTypIdNam=FSUtil.getObjectRecordTypeIdAndNAme(FS_Installation__c.SObjectType);
       //Create Installation for each Execution Plan according to recordtype
       FSTestFactory.lstPlatform();
        
        Test.setMock(HttpCalloutMock.class, new FSFETNMSConnectorMock());
       for(String  installationRecordType : ipRecTypSet){
          final Id instRecTypId = FSUtil.getObjectRecordTypeId(FS_Installation__c.SObjectType,installationRecordType); 
          final List<FS_Installation__c > installList =FSTestFactory.createTestInstallationPlan(executionPlanList.get(0).Id,outletCustList.get(0).Id,false,4,instRecTypId);
          ipList.addAll(installList);
       } 
       system.debug('before inserting OD:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
       Test.startTest();
        insert ipList;  
       //Verify that 4  Installation Plan got created
       system.assertEquals(4,ipList.size()); 
       
       
       final List<FS_Outlet_Dispenser__c> outletDispList=new List<FS_Outlet_Dispenser__c>();
       
     
       //Create Outlet Dispensers 
       for(FS_Installation__c installPlan : [SELECT Id,RecordTypeId,FS_Outlet__c FROM FS_Installation__c  limit 100]){
           List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
           Id oDispRecTypId;
           
           if(instRecTypIdNam.get(installPlan.RecordTypeId)==FsConstants.NewInstallation){
              oDispRecTypId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Fsconstants.RT_Name_CCNA_OD);
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,oDispRecTypId,false,1,'A');
              odList[0].put(EQUIPTYP, LIT7K);
              
           }
           if(instRecTypIdNam.get(installPlan.RecordTypeId)==FsConstants.NewInstallation){
              
              oDispRecTypId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Fsconstants.RT_Name_CCNA_OD);
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,oDispRecTypId,false,1,'B');
              odList[0].put(EQUIPTYP, LIT8K);
              
           }
           if(instRecTypIdNam.get(installPlan.RecordTypeId)==FsConstants.NewInstallation){
              
              oDispRecTypId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Fsconstants.RT_Name_CCNA_OD);
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,oDispRecTypId,false,1,'C');
              odList[0].put(EQUIPTYP, LIT8K);
              
           }
           if(instRecTypIdNam.get(installPlan.RecordTypeId)==FsConstants.NewInstallation){
              
              oDispRecTypId=FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.SObjectType,Fsconstants.RT_Name_CCNA_OD);
              odList=FSTestFactory.createTestOutletDispenser(installPlan.Id,installPlan.FS_Outlet__c,oDispRecTypId,false,1,'D');
              odList[0].put(EQUIPTYP, LIT9K);
              
           }
           outletDispList.addAll(odList);
           
       }  
        Test.stopTest();
         system.assert(outletDispList.size()==4);
         insert outletDispList;
         
        //}
    }
    
    private static testMethod void testMergeFile(){
       
        
       final List<FS_Outlet_Dispenser__c> createdDispensers=[SELECT Id,FS_Equip_Type__c,FS_Serial_Number2__c,FS_IsActive__c,FS_ACN_NBR__c FROM FS_Outlet_Dispenser__c LIMIT 100];
       final Blob csvFileSuccess=FSTestFactory.createSuccessCSVBlob(createdDispensers); 
       final Blob csvFileFailure=FSTestFactory.createFailureCSVBlob(createdDispensers); 
       
       //create parent csv Holder
       final FS_WorkBook_Holder__c holder=new FS_WorkBook_Holder__c();
       holder.FS_WorkBook_Name__c='Dispenser WorkBook';
       insert holder;
       //final Id parentId=holder.Id;
       
       final List<Attachment> attachmentList=new List<Attachment> ();
       
       //create Attachment
       final Attachment file1= new Attachment();
           file1.Body=csvFileSuccess;
           file1.parentId = holder.Id;
           file1.Name=SUCCESSFILENAME; 
       attachmentList.add(file1);    
       final Attachment file2= new Attachment();
           file2.Body=csvFileSuccess;
           file2.parentId = holder.Id;
           file2.Name=SUCCESSFILENAME; 
       attachmentList.add(file2);
       
       final Attachment file3= new Attachment();
           file3.Body=csvFileFailure;
           file3.parentId = holder.Id;
           file3.Name=FAILUREFILENAME;
       attachmentList.add(file3); 
           
       final Attachment file4= new Attachment();
           file4.Body=csvFileFailure;
           file4.parentId = holder.Id;
           file4.Name=FAILUREFILENAME;
       attachmentList.add(file4);    
       
       insert attachmentList;
       final Profile sysAdmin=FSTestFactory.getProfileId(FSConstants.USER_POFILE_SYSADMIN);
        final User sysAdminUser=FSTestFactory.createUser(sysAdmin.id);
     
        System.runAs(sysAdminUser){

       Test.startTest();
          
          //Process success file
          List<String> fileNames =new List<String>{SUCCESSFILENAME};
          String attachmentQuery='SELECT Id,Body,Name from Attachment where parentId=:parentId';
                 attachmentQuery +=' AND Name IN: fileNames ';
          Database.executeBatch(new FSAttachmentMergerBatch(holder.Id,fileNames,attachmentQuery,FINALSUCESFILENAM));
         
          //Process failure file
          fileNames =new List<String>{FAILUREFILENAME};
          Database.executeBatch(new FSAttachmentMergerBatch(holder.Id,fileNames,attachmentQuery,FINALFAILRFILENAM));
          
          //When merge happens Update Holder records  
          /*This tests FSSendEmailWhenFileProcessingIsComplete class 
          which is called from Process Builder*/
            holder.FS_Total_Batches__c=2;
            holder.FS_Total_Number_of_Records__c=16;
            holder.FS_Total_Number_of_Success_Records__c=10;
            holder.FS_Total_Number_of_Failed_Records__c=6;
            update holder;
       Test.stopTest();
        }
       
       //verify file merge happened
        system.assertEquals(2,[SELECT COUNT() from Attachment where parentId=:holder.Id AND Name IN (:FINALSUCESFILENAM,:FINALFAILRFILENAM)]);
       
     }
     
}