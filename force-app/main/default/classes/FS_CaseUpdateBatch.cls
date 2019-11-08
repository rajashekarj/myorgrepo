/***************************************************************************************************************************
Apex Class Name     : FS_CaseUpdateBatch
Function            : This is a one time batch class written to update all existing FACT cases with outlet dispenser lookup.
Author              : Infosys
****************************************************************************************************************************/

global class FS_CaseUpdateBatch implements Database.Batchable<sObject>
{
    public static final String Project_Name = 'Freestyle Support 2017';
    public static final String FS_CaseUpdateBatch = 'FS_CaseUpdateBatch';
    public static final String NA = 'NA';
    public static final String Medium = 'Medium';
    public static final String execute = 'execute';
    public static final String start = 'start';
    String query;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Try
        {
           String recordType = 'Connectivity Solution';
            query = 'SELECT Id,FS_Outlet_Dispenser__c,FACT_Dispenser_Serial_Number__c,FACT_ACN__c,';
            query += 'FS_Static_ACN__c,FS_Static_Build_Id_SW_Version__c,FS_Static_Dispenser_Status__c,FS_Static_Install_status__c,';
            query += 'FS_Static_IP_Address__c,FS_Static_Modem_Number__c,FS_Static_SAP__c,FS_Static_Active_Inactive__c,FS_Static_Enrollment_Date__c,';
            query += 'FS_Static_Last_Pour_Date__c,FS_Static_Last_Seen_Date__c,FACT_Last_Seen_Date__c,FACT_Last_Pour_Time__c,FACT_Airwatch_Enrollment_Date__c,';
            query += 'FACT_Active_Inactive_Status__c,FACT_SAP_Ship_to_ID__c,FACT_Modem__c,FACT_IP_Address__c,FACT_JDEInstBase_Status__c,FACT_Airwatch_Dispenser_Status__c,';
            query += 'FACT_Build_ID__c FROM Case where FS_Outlet_Dispenser__c = null and recordtype.name =: recordType'; 
            
        }
        catch(Exception ex)
        {
            system.debug('FS_CaseUpdateBatchException'+ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_CaseUpdateBatch,start,NA,Medium,ex,NA);
        }
        return Database.getQueryLocator(query);  
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope)
    { 
        try
        {
            Map<ID,String> mapSerialNumandACN = new Map<ID,String>();
            Map<String,ID> mapSerialNumandACNOD = new Map<String,ID>();
            List<String> serialNumandACN = new List<String>();
            List<Case> caseListUpdate = new List<Case>(); 
            List<CaseToOutletdispenser__c> caseToODList = new List<CaseToOutletdispenser__c>();
            
            for (Case csObj : scope)
            {
                String serialACN = csObj.FACT_Dispenser_Serial_Number__c+'-'+csObj.FACT_ACN__c;
                mapSerialNumandACN.put(csObj.Id,serialACN);
                serialNumandACN.add(serialACN); 
            }
            List<FS_Outlet_Dispenser__c> odList = [Select Id,FACT_Serial_Number_ACN__c from FS_Outlet_Dispenser__c where FACT_Serial_Number_ACN__c IN :serialNumandACN];
            system.debug(odList+'--odList--');
            for(FS_Outlet_Dispenser__c od : odList)
            {
                mapSerialNumandACNOD.put(od.FACT_Serial_Number_ACN__c,od.Id);
                system.debug(mapSerialNumandACNOD+'--mapSerialNumandACNOD--');
            }
            for(Case upObj: scope )
            {
                CaseToOutletdispenser__c caseToODRecord = new CaseToOutletdispenser__c();
                caseToODRecord.Case__c = upObj.id;
                if(mapSerialNumandACN.get(upObj.Id)!=null)
                {
                    String serialNumber = mapSerialNumandACN.get(upObj.Id);
                    if(mapSerialNumandACNOD.get(serialNumber)!=null){
                        upObj.FS_Outlet_Dispenser__c = mapSerialNumandACNOD.get(serialNumber);
                        caseToODRecord.Outlet_Dispenser__c = mapSerialNumandACNOD.get(serialNumber);
                    }
                }
                
                upObj.FS_Static_ACN__c = upObj.FACT_ACN__c;
                caseToODRecord.FS_Static_ACN__c = upObj.FACT_ACN__c;
                upObj.FS_Static_Build_Id_SW_Version__c = upObj.FACT_Build_ID__c;
                caseToODRecord.FS_Static_Build_Id_SW_Version__c = upObj.FACT_Build_ID__c;
                upObj.FS_Static_Dispenser_Status__c = upObj.FACT_Airwatch_Dispenser_Status__c;
                caseToODRecord.FS_Static_Dispenser_Status__c = upObj.FACT_Airwatch_Dispenser_Status__c;
                upObj.FS_Static_Install_status__c = upObj.FACT_JDEInstBase_Status__c;
                caseToODRecord.FS_Static_Install_status__c = upObj.FACT_JDEInstBase_Status__c;
                upObj.FS_Static_IP_Address__c = upObj.FACT_IP_Address__c;
                caseToODRecord.FS_Static_IP_Address__c = upObj.FACT_IP_Address__c;
                upObj.FS_Static_Modem_Number__c = upObj.FACT_Modem__c;
                caseToODRecord.FS_Static_Modem_Number__c = upObj.FACT_Modem__c;
                upObj.FS_Static_SAP__c = upObj.FACT_SAP_Ship_to_ID__c;
                caseToODRecord.FS_Static_SAP__c = upObj.FACT_SAP_Ship_to_ID__c;
                
                if(upObj.FACT_Active_Inactive_Status__c == 'Active')
                {
                    upObj.FS_Static_Active_Inactive__c = true;
                    caseToODRecord.FS_Static_Active_Inactive__c = true;
                }
                else
                {
                    upObj.FS_Static_Active_Inactive__c = false;
                    caseToODRecord.FS_Static_Active_Inactive__c = false;
                }
                
                if(upObj.FACT_Airwatch_Enrollment_Date__c!=null)
                {
                    DateTime enDT = upObj.FACT_Airwatch_Enrollment_Date__c; 
                    Date enrollmentDate = date.newinstance(enDT.year(), enDT.month(), enDT.day());
                    upObj.FS_Static_Enrollment_Date__c = enrollmentDate;
                    caseToODRecord.FS_Static_Enrollment_Date__c = enrollmentDate;
                }
                
                if(upObj.FACT_Last_Pour_Time__c!=null)
                {
                    DateTime pourDT = upObj.FACT_Last_Pour_Time__c;
                    Date pourDate = date.newinstance(pourDT.year(), pourDT.month(), pourDT.day());
                    upObj.FS_Static_Last_Pour_Date__c = pourDate;
                    caseToODRecord.FS_Static_Last_Pour_Date__c = pourDate;
                }
                
                if(upObj.FACT_Last_Seen_Date__c!=null)
                {
                    DateTime lastDT = upObj.FACT_Last_Seen_Date__c;
                    Date lastDate = date.newinstance(lastDT.year(), lastDT.month(), lastDT.day());
                    upObj.FS_Static_Last_Seen_Date__c = lastDate;
                    caseToODRecord.FS_Static_Last_Seen_Date__c = lastDate;
                }
                caseListUpdate.add(upObj);
                caseToODList.add(caseToODRecord);
            }
            
            if(caseListUpdate.size()>0)
            {
                database.update(caseListUpdate,false);
            }
            if(caseToODList.size()>0)
            {
                database.insert(caseToODList,false);
            }
        }
        catch(Exception ex)
        {
            system.debug('Exception'+ex.getMessage());
            ApexErrorLogger.addApexErrorLog(Project_Name,FS_CaseUpdateBatch,execute,NA,Medium,ex,NA);
        }
    }  
    global void finish(Database.BatchableContext BC)
    {
        
    }
}