//----------------------------------------------//
//Descripton: To get list of Oulet Dispensers matching with the 
//			  serial number entered by user
//Class Name: ODsearchController
//Created on: 23rd Aug 2017
//Author:Infosys
//-----------------------------------------------//

public class FMODsearchController 
{   
	Static Final Integer ZEROVAL=0;
    @AuraEnabled
    public static List<FS_Outlet_Dispenser__c> searchDisp(Final string serialNum){
        if( serialNum.length() > ZEROVAL ){
            String dispQueryStr='%' + serialNum + '%';
                   
    /* Query the dispensers matching with complete 
            serial number or partial serial number */
            
            List<FS_Outlet_Dispenser__c> dispenserslist=[select id, Name ,FS_Serial_Number2__c, FS_ACN_NBR__c, FS_Equip_Type__c  
                                                         from FS_Outlet_Dispenser__c 
                                                         where FS_Serial_Number2__c like :dispQueryStr];
            
            return dispenserslist;    
        }
        else{
            return null;
        }
    }
    
}