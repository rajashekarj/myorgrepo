/**************************************************************************************
Apex Class Name     : FSLM_CreateFACTCaseController
Function            : This class is created for creating FACT Case after selecting an OD.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Denit            03/02/2018         Display the list of OD from Selected To Account and Create FACT Case	
*************************************************************************************/

global without sharing class FSLM_CreateFACTCaseController {
    
    public boolean isRender{get;set;}
    public List<DispenserWrapper> selectDispensersWrapper {get;set;}
    public list<FS_Outlet_Dispenser__c> outletDispenserList{get;set;}
    //public Id accountID{get;set;}
    public String dispenserId{get;set;}
    public Id caseID {get;set;}
    
    public FSLM_CreateFACTCaseController(ApexPages.StandardController controller)
    {
        try
        {
            selectDispensersWrapper =new List<DispenserWrapper>();
            List<CaseToOutletdispenser__c> caseToODRecords = new List<CaseToOutletdispenser__c>();
            Set<String> serialNumberSet = new Set<String>();
            dispenserId= apexpages.currentpage().getparameters().get('fromacnid');
            caseID = apexpages.currentpage().getparameters().get('id');
            case cas=[select FS_Outlet_Dispenser__c,Dispenser_serial_number__c,FS_Outlet_Dispenser__r.FS_Serial_Number2__c from case where id=:caseID ];
            isRender=false;
            
            //Select all the Active Outlet Dispensers at outlet level. Assuming that not more than 100 OD's exists in an outlet.
            outletDispenserList= [select FS_Date_Status__c,FS_Name1__c ,FS_Equip_Type__c,FS_Outlet__c ,FS_Status__c ,
                                  FS_Dispenser_Type__c ,Outlet_City__c ,id, name,FS_Serial_Number2__c,FS_IsActive__c from FS_Outlet_Dispenser__c 
                                  where FS_Outlet__c=:dispenserId];
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
    //This is a child Wrapper class to containt the selected dispensers list along with checkbox              
    public class DispenserWrapper {
        public FS_Outlet_Dispenser__c dispenser{get; set;}
        public Boolean checked {get; set;}
        public Boolean disableDispenser{get;set;}
    }
}