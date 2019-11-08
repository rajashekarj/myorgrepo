//-------------------------------------------//
//Descripton: To get barcode matchig Oulet Dispensers
//Class Name: FetchODList
//Created on: 23rd Aug 2017
//Author:Infosys
//-------------------------------------------//

public class FMFetchODList {
	Static Final String NULLSTR='NULL';
    Static Final Integer ZEROVAL=0;
    @AuraEnabled public String errString {get;set;}
    @AuraEnabled public List<FS_Outlet_Dispenser__c> listOutlets{get;set;}
    
    @AuraEnabled
    public static FMFetchODList barcodeMatchODList(Final String barCode) {
        FMFetchODList obj = new FMFetchODList();
        
        
        try{            
            // Query the dispensers matching with barcode
            obj.listOutlets  = [select id,Name,FS_ACN_NBR__c,FS_Serial_Number2__c,FS_Equip_Type__c  from FS_Outlet_Dispenser__c where FS_Serial_Number2__c LIKE :barCode];
            }
        catch(Exception e ){
            system.debug('from catch');
        }
        
        // Set warning message based on barcode value. 
        if(barCode == NULLSTR) // when barcode is 'NULL'
        {            
            obj.errString=Label.UnableToReadBarcode;
        }
        else if( obj.listOutlets.size() == ZEROVAL ) // when barcode doesn't have any matching records
        {         
            obj.errString=Label.NoMatchingDispensers;
        }
        
        return obj;        
    }    
}