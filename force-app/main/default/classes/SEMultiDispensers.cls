/*********************************************************************************************************
Apex Class Name     : SEMultiDispensers
Function            : This is a controller class for Visual force page that allows Add/Delete Multiple dispensers for EMT cases.
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Mahender	          11/17/2016       This class supports the Visualforce page by supplying the list of 
									   Outlet Dispensers filtered by selected Outlet in the page.
* Sunil TD	          08/07/2017       Updated the class for fetching Outlet Dispensers data based on the selected 
									   Outlet Dispenser's Outlet record.
***********************************************************************************************************/

global without sharing class SEMultiDispensers {
    
    public boolean isRender{get;set;}
    public List<DispenserWrapper> selectDispensersWrapper {get;set;}
    public list<FS_Outlet_Dispenser__c> outletDispenserList{get;set;}
    public Id accountID{get;set;}
    public String dispenserId{get;set;}
    public Id caseID {get;set;}
    
    //Using a wrapper class this constructor sends the list of already selected and un selected dispensers list
    public SEMultiDispensers(ApexPages.StandardController controller)
    {
        try
        {
            selectDispensersWrapper =new List<DispenserWrapper>();
            List<CaseToOutletdispenser__c> caseToODRecords = new List<CaseToOutletdispenser__c>();
            Set<String> serialNumberSet = new Set<String>();
            dispenserId= apexpages.currentpage().getparameters().get('dispenserid');
            FS_Outlet_Dispenser__c dis = [SELECT FS_Outlet__c,FS_Serial_Number2__c FROM FS_Outlet_Dispenser__c WHERE name =:dispenserId];
            accountID = dis.FS_Outlet__c;
            caseID = apexpages.currentpage().getparameters().get('id');
            case cas=[select FS_Outlet_Dispenser__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c from case where id=:caseID ];
            isRender=false;
            
            //Select all the Active Outlet Dispensers at outlet level. Assuming that not more than 100 OD's exists in an outlet.
            outletDispenserList= [select FS_Date_Status__c,FS_Name1__c ,FS_Equip_Type__c,FS_Outlet__c ,FS_Status__c ,
                                  FS_Dispenser_Type__c ,Outlet_City__c ,id, name,FS_Serial_Number2__c,FS_IsActive__c from FS_Outlet_Dispenser__c 
                                  where FS_Outlet__c=:accountID /*AND FS_IsActive__c = true*/ ORDER BY FS_Name1__c ASC NULLS FIRST limit 100];
            if(outletDispenserList.size()<1)
            {
                isRender=true;
            }
            
            caseToODRecords = [select Id,FS_Serial_Number__c from CaseToOutletdispenser__c where Case__c =: caseID];
            if(!caseToODRecords.isEmpty())
            {
                for(CaseToOutletdispenser__c record : caseToODRecords)
                {
                    serialNumberSet.add(record.FS_Serial_Number__c);
                }
            }
            
            for (FS_Outlet_Dispenser__c oDispenser: outletDispenserList)
            {
                DispenserWrapper d=new DispenserWrapper ();
                d.dispenser=oDispenser;
                d.checked=false;
                d.disableDispenser = false;
                if(!serialNumberSet.isEmpty() && !string.isEmpty(oDispenser.FS_Serial_Number2__c) &&
                   serialNumberSet.contains(oDispenser.FS_Serial_Number2__c))
                {
                    d.checked =true;
                }
                if(cas.FS_Outlet_Dispenser__r != null && oDispenser.FS_Serial_Number2__c != null &&
                   cas.FS_Outlet_Dispenser__r.FS_Serial_Number2__c == oDispenser.FS_Serial_Number2__c)
                {
                    d.disableDispenser = true; 
                }
                selectDispensersWrapper.add(d);
            }
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
    
    /*****************************************************************************************
    Method : deleteJunctionRecords
    Description : Method to delete records from Case To Outlet Dispensers for particular Case record.
    ******************************************************************************************/
    public static void deleteJunctionRecords(Id caseRecordID)
    {
        try
        {
            list<CaseToOutletdispenser__c> deletionList=new list<CaseToOutletdispenser__c>();
            deletionList=[SELECT Id FROM CaseToOutletdispenser__c WHERE Case__c = :caseRecordID];
            delete deletionList;
        }
        Catch(Exception e)
        {
            system.debug('Error while deleting the junction object records'+e.getMessage());
        }
    }
    
    /*****************************************************************************************
    Method : updateDispenserSerialNumber
    Description : Method to update Dispenser Serial Number in Case record.
    ******************************************************************************************/
    public static Case updateDispenserSerialNumber(Id caseRecordID,String selectedSerialNumber)
    {
        case caseRecord;
        try
        {
            id caseID = caseRecordID;
            caseRecord=[select AccountId,Dispenser_serial_number__c from case where id=:caseID];
            selectedSerialNumber=selectedSerialNumber.removeEnd(',');
            if(selectedSerialNumber.length() > 254)
            {
                selectedSerialNumber = selectedSerialNumber.left(252);
            }
            caseRecord.Dispenser_serial_number__c=selectedSerialNumber;
            update caseRecord;
        }
        catch(Exception e)
        {
            system.debug('Error while updating the case record:'+e.getMessage());
        }
        return caseRecord;
    }
    
    /*****************************************************************************************
    Method : setSerialNumber
    Description : This method is to save the selected dispensers to the case object and 
				  Insert Case To OutletDispensers Junction object as per requirement
    ******************************************************************************************/
    @RemoteAction
    global static void setSerialNumber(Id caseid,String zpls, Id accID) {
        try{
            Case caseValue;
            list<string> selectSerialNumberList = new list<string>();
            list<CaseToOutletdispenser__c> iterationList = new list<CaseToOutletdispenser__c>();
            list<FS_Outlet_Dispenser__c> serialNumberIterationList = new list<FS_Outlet_Dispenser__c>();
            Integer i;
            Integer j;
            
            deleteJunctionRecords(caseid);
            caseValue = updateDispenserSerialNumber(caseid,zpls);
            
            selectSerialNumberList=zpls.split(',');
            
            serialNumberIterationList = [select Id,FS_IsActive__c,FS_Name1__c,FS_Serial_Number2__c from FS_Outlet_Dispenser__c 
                                where FS_Serial_Number2__c IN :selectSerialNumberList AND FS_Outlet__c=:accID
                                         /*AND FS_IsActive__c = true*/ ORDER BY FS_Name1__c ASC NULLS FIRST];
            i = serialNumberIterationList.size();
            j = 0;
            
            //This for loop inserts the junction object records with the individual serial numbers that the case object contains
            for(string s:selectSerialNumberList)
            {
                CaseToOutletdispenser__c caseJunct = new CaseToOutletdispenser__c();
                if(j<i)
                {
                    caseJunct.Case__c = caseid;
                    caseJunct.Customer__c = caseValue.AccountId;
                    caseJunct.Outlet_Dispenser__c = serialNumberIterationList[j].id;
                    caseJunct.Serial_Number_Text__c = serialNumberIterationList[j].FS_Serial_Number2__c;
                    j++;
                }
                iterationList.add(caseJunct);
            }
            Database.insert(iterationList);
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
        }
    }
    
    //This is a child Wrapper class to containt the selected dispensers list along with checkbox              
    public class DispenserWrapper {
        public FS_Outlet_Dispenser__c dispenser{get; set;}
        public Boolean checked {get; set;}
        public Boolean disableDispenser{get;set;}
    }
}