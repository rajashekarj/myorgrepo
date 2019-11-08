/***************************************************************************************
Apex Class Name     : FACT_TestFactory
Version             : 1.0
Function            : This test class contains all the reusable code for the test classes. 
Modification Log    : 
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             			          Original Version 
*					  05/29/2018		  Removed usage of OutboundServiceDetails__c customSetting as part of FOT project
*************************************************************************************/
@isTest
public class FACT_TestFactory{

    public static Blob createCSVBlobForJDEOrderInquiry(){
       String csvFileJDEOrderInquiry = 'SDLOTN,SDAN8,ABAN82,SDDOCO,SDLNID,SDLNTY,SDLTTR,SDNXTR\n';
       csvFileJDEOrderInquiry += 'ZPL000100S,1280355,1327470,531313,2000,RS,891,999\n';
        csvFileJDEOrderInquiry +='zPL0001053,4593561,4593561,563809,14000,793,578\n';
        csvFileJDEOrderInquiry +='zPL0001053,4593561,4593561,563809,3000,860,936\n';
        csvFileJDEOrderInquiry +='zPL0001053,6145027,1317283,535584,2000,860,936\n';
        csvFileJDEOrderInquiry +='zPL0001048,2269783,1327470,531344,2000,860,936\n';
        csvFileJDEOrderInquiry +='zPL000102I,4337986,1327470,531324,2000,860,936\n';
        csvFileJDEOrderInquiry +='zPL000100S,1280355,1327470,531313,2000,860,936\n';
        csvFileJDEOrderInquiry +='zPL000101N,9153772,1327470,531194,2000,860,936\n';
        csvFileJDEOrderInquiry +='zPL0001048,2269783,1327470,451470,5000,860,936\n';
        csvFileJDEOrderInquiry +='zPL000102I,4337986,1327470,451466,6000,860,936\n';
        csvFileJDEOrderInquiry +='zPL000100S,1280355,1327470,451465,7000,860,936\n';
        csvFileJDEOrderInquiry +='zPL0001005,1280355,1327470,451465,5000,860,936\n';
        csvFileJDEOrderInquiry +='zPL000103D,2361264,1327470,451464,4000,860,936\n';
        csvFileJDEOrderInquiry +='zPL000103D,2361264,1327470,451464,2000,860,936\n';
        csvFileJDEOrderInquiry +='zPL000101N,9153772,1327470,451460,5000,860,936\n';
       csvFileJDEOrderInquiry += 'ZPL000110L,3256791,1327470,451465,5000,ES,811,999';
       
       Blob csvBlobJDEOrderInquiry = Blob.valueOf(csvFileJDEOrderInquiry);
       
       return csvBlobJDEOrderInquiry;
    }
    
    
    
    public static Blob createCSVBlobForJDEInstallBase(){
       String csvFileJDEInstallBase = 'FAASID,FAEQST,FALANO,ABAN82\n';
       csvFileJDEInstallBase  += 'ZPL000100S,UB,1280355,1327470\n';
       csvFileJDEInstallBase +='ZPL000100S,IN,7552454,7552454\n';
        csvFileJDEInstallBase+='ZPL000100S,UB,1280355,1327470\n';
        csvFileJDEInstallBase+='ZPL000101N,UB,9153772,1327470\n';
        csvFileJDEInstallBase+='ZPL000102I,UB,4337986,1327470\n';
        csvFileJDEInstallBase+='ZPL000103D,IN,7552454,7552454\n';
        csvFileJDEInstallBase+='ZPL000103D,UB,2361264,1327470\n';
        csvFileJDEInstallBase+='ZPL0001048,UB,2269783,1327470\n';
        csvFileJDEInstallBase+='ZPL0001053,IN,6145027,1317283\n';
        csvFileJDEInstallBase+='ZPL0001053,UB,4593561,4593561\n';
        csvFileJDEInstallBase+='ZPL000106Y,UB,2361272,1327470\n';
        csvFileJDEInstallBase+='ZPL000109J,IN,9336648,1327470\n';
        csvFileJDEInstallBase+='ZPL000110L,IN,3256791,1327470\n';
        csvFileJDEInstallBase+='ZPL000110L,UB,3256791,1327470\n';
        csvFileJDEInstallBase+='ZPL000111G,UB,6746144,1327470\n';
        csvFileJDEInstallBase+='ZPL0001141,UB,8307836,1319782\n';
       csvFileJDEInstallBase += 'ZPL000101N,UB,9153772,1327470';
       Blob csvBlobJDEInstallBase = Blob.valueOf(csvFileJDEInstallBase);
       
       return csvBlobJDEInstallBase ;
    }
    
    
    public static Blob createCSVBlobForNMSAirwatch(){
        String csvFileNmsAirwatch = 'Serial_Number,PlatformType,Dispenser_Status,Registration_Date,Enrolled_Date,Last_Seen,Last_Pour_Time,'
                               +'LastVMSDate,BuildID,OS Ver,SAPShipToID,OutletID,OutletName,OutletStreetAddress,OutletCity,'
                               +'OutletStateProvince,OutletZIPPostCode,OutletCountry,Signal,Avg Sig,Min Sig,Max Sig,Modem Number,'
                               +'Model,IP Address\n';
           csvFileNmsAirwatch  +='ZPL0001005,9000,Registered,7/24/2015 19:52,,,,,,,,,,,,,,,,,,,,,192.168.2.105\n';
           csvFileNmsAirwatch  +='TPL0001035,8000,Registered,7/27/2015 19:51,,,,,,,,,,,,,,,,,,,,,191.167.1.102\n';
           csvFileNmsAirwatch  +=',8000,Registered,7/27/2015 19:51,,,,,,,,,,,,,,,,,,,,,191.167.1.102\n';
           csvFileNmsAirwatch  +='ZSA3001069,7000,Enrolled,10/28/2015 19:17,6/13/2015 17:59,3/3/2016 10:59,2016-03-03T06:48:39-0600,2016-02-23T06:06:58.265Z,,1.0.2.03,6.5.0,10442778,1713908,HANDI STOP,5815 BROADWAY ST,GALVESTON,TX,77551-4304,US,,,,,,,192.168.2.100\n';
           csvFileNmsAirwatch  +='ZSA3001067,7000,Enrolled,10/28/2015 19:17,6/13/2015 17:59,2/30/2016 10:59,2016-03-03T06:48:39-0600,2016-02-23T06:06:58.265Z,,1.0.2.03,6.5.0,10442778,1714908,HANDI STOP,5815 BROADWAY ST,GALVESTON,TX,77551-4304,US,,,,,,,192.168.2.100\n';
           csvFileNmsAirwatch  +='ZSA3001569,7000,Enrolled,10/28/2015 19:17,6/13/2015 17:59,3/3/2016,2016-03-03T06:48:39-0600,2016-02-23T06:06:58.265Z,,1.0.2.03,6.5.0,10442778,1713908,HANDI STOP,5815 BROADWAY ST,GALVESTON,TX,77551-4304,US,,,,,,,192.168.2.100\n';
           csvFileNmsAirwatch += 'ZPL000125P,9000,Registered,7/24/2015 1:27,,,,,,,,1280355,,,,,,,,,,,,,192.168.2.100';
           Blob csvBlobNmsAirwatch = Blob.valueOf(csvFileNmsAirwatch);
       
       return csvBlobNmsAirwatch;
    }
    
    //FACT R1 2018 : Deleted FACT_Connectivity_Attachments_Holder__c object
    /*    
    public static FACT_Connectivity_Attachments_Holder__c createHolderRecord(String sourceSystem,Boolean isInsert){
    
       String todaysDate=String.valueOf(System.today().format());
       FACT_Connectivity_Attachments_Holder__c holder=new FACT_Connectivity_Attachments_Holder__c(); 
       holder.Name=todaysDate;
       holder.FACT_Source_System__c =sourceSystem;
       holder.FACT_Source_And_Date__c=sourceSystem +' : '+todaysDate;
       if(isInsert){
         insert holder;
       }
       return holder;
    }*/
    
    public static Attachment createCSVAttachmentRecord(Id parentId,String fileName,Blob csvBody ,Boolean isInsert){
   
       Attachment attachment=new Attachment (); 
       attachment.parentId= parentId;
       attachment.Name = fileName;       
       attachment.Body =csvBody  ; 
       if(isInsert){
         insert attachment;
       }
       return attachment;
    }
    
    public static void loadCustomSettings(){
    
      List<sObject> customSettingAttachmentHeader= Test.loadData(FACT_Attcahment_Header_Names__c.sObjectType,'FACTAttachmentHeaders');
       System.assert(customSettingAttachmentHeader.size() == 37);
    }
    
    public static List<FS_Outlet_Dispenser__c> createOutletDispensers(Integer noOfRecords,Boolean isInsert){
        Id outletDispRecordTypeId = Schema.SObjectType.FS_Outlet_Dispenser__c.getRecordTypeInfosByName().get('7000').getRecordTypeId();
        List<FS_Outlet_Dispenser__c> outletDispenserList=new List<FS_Outlet_Dispenser__c>();
        for(Integer i=0;i<noOfRecords;i++){
          FS_Outlet_Dispenser__c outletDispenser=new FS_Outlet_Dispenser__c();
          outletDispenser.FS_Serial_Number2__c='ZPL000'+i+'I';
          outletDispenser.FS_IsActive__c=true;
          //outletDispenser.FS_outlet__c=null;
          outletDispenser.FS_Status__c = 'Enrolled';
          outletDispenser.recordtypeId=outletDispRecordTypeId ;
          outletDispenserList.add(outletDispenser);
        }   
        if(isInsert){
           insert outletDispenserList;
        }
        return outletDispenserList;
    }
    
    
     public static List<Case> createFACTCaseRecords(Integer noOfRecords,Boolean isInsert){
         List<Case> caseList=new List<Case>();
         Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Connectivity Solution').getRecordTypeId();
         for(Integer i=0;i<noOfRecords;i++){
           Case caseInstance=new Case();
           caseInstance.Status='New';
           //caseInstance.FACT_Select_Dispenser__c=null; //FACT R1 2018:Deleted Connectivity Summary object
           caseInstance.recordtypeId=caseRecordTypeId;
           caseInstance.Issue_Name__c='Testissue';
           caseList.add(caseInstance); 
         }
         if(isInsert){
           insert caseList;
        }
        return caseList;
     }
    
    
    
    /*public static List<FACT_Dispenser_Connectivity_IssueTracker__c> createConnectivityIssueRecords(Integer noOfRecords,Boolean isInsert){
        Id dispenerIssueRecordTypeId = Schema.SObjectType.FACT_Dispenser_Connectivity_IssueTracker__c.getRecordTypeInfosByName().get('Dispenser Issues').getRecordTypeId();
        List<FACT_Dispenser_Connectivity_IssueTracker__c> dispenseIssueRecords=new  List<FACT_Dispenser_Connectivity_IssueTracker__c>();
        
        for(Integer i=0;i<noOfRecords;i++){
          FACT_Dispenser_Connectivity_IssueTracker__c issueInstance=new FACT_Dispenser_Connectivity_IssueTracker__c ();
          issueInstance.FACT_Dispenser_Serial_Number__c='ZPL000'+i+'I';
          issueInstance.FACT_ACN__c='100000'+i;
          issueInstance.recordtypeId=dispenerIssueRecordTypeId;
          dispenseIssueRecords.add(issueInstance);
        }
        if(isInsert){
           insert dispenseIssueRecords;
        }
        return dispenseIssueRecords;
        
    }*/
    
    public static List<Account> createOutletAccounts(Integer noOfRecords,Boolean isInsert){
        Id outletRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FS Outlet').getRecordTypeId();
        List<Account> outletRecords=new  List<Account>();
        
        for(Integer i=0;i<noOfRecords;i++){
          Account outletAcc=new Account  ();
          outletAcc.Name='outlet Account--'+i;
          outletAcc.FS_ACN__c='100000'+i;
          outletAcc.ShippingCountry='US';
          outletAcc.recordtypeId=outletRecordTypeId ;
          outletRecords.add(outletAcc);
        }
        if(isInsert){
           insert outletRecords;
        }
        return outletRecords;
        
    }  
    
}