/**************************************************************************************
Apex Class Name     : FSSPPlannerEmailHelperController
Version             : 1.0
Function            : Controller for FsGetOutDispSerialNo VF Component 
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Infosys             27/06/2019          Original Version
***************************************************************************************/

public without sharing class FSSPPlannerEmailHelperController {
    public String platform {get; set;}
    public String installationId {get; set;}
    public String recordType {get; set;}
    public static final String FSSPPlANNEREMAILHELPERCONTROLLER = 'FSSPPlannerEmailHelperController';
    public static final String NA = 'NA';
    public static final String MEDIUM = 'Medium';
    
    /*****************************************************************
Method: getODSerialNo
Description: Fetch list of outlet dispesners for PIAs for same Platform and Return comma separated serial no of OD.
Added as part of FET 7.0, //Sprint 1 - FNF-788
*******************************************************************/
    
    public String getODSerialNo(){
        String result = '';
        List<FS_Outlet_Dispenser__c> odList=new List<FS_Outlet_Dispenser__c>();
        try{
            //If installation is RI4W then query on OD with Relocated_Installation__c look up field.
            //For all other PIA query for  FS_Other_PIA_Installation__c field.
            if(recordType == Label.IP_Relocation_I4W_Rec_Type){
                odList= [SELECT Id, FS_Equip_Type__c, FS_Serial_Number2__c 
                         FROM FS_Outlet_Dispenser__c 
                         WHERE Relocated_Installation__c =:installationId AND FS_Equip_Type__c =: platform];
            }
            else{
                odList=[SELECT Id, FS_Equip_Type__c, FS_Serial_Number2__c 
                        FROM FS_Outlet_Dispenser__c 
                        WHERE FS_Other_PIA_Installation__c =:installationId AND FS_Equip_Type__c =: platform];
            }
            if(odList != null){
                //Prepare comma separated list for all OD serial number
                for(FS_Outlet_Dispenser__c od : odList){
                    result = result + od.FS_Serial_Number2__c+FSConstants.COMMA+ ' ';
                }
            }  
        }catch(exception exp){ApexErrorLogger.addApexErrorLog(FSConstants.PROJECTNAME1, FSSPPlANNEREMAILHELPERCONTROLLER , FSConstants.VALIDATEAMOACASESTATUS, NA, MEDIUM, exp, NA);}
        //Remove Last ' , ' before return
        return result.removeEnd(FSConstants.COMMA+ ' ');
    }
}