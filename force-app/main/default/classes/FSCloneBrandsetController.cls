/***************************************************************************
 Name         : FSCloneBrandsetController
 Created By   : Infosys Limited
 Description  : Controller for FSCloneBrandsetPage
 Created Date : Sept 21,2016
 Modified By  : 
**************************************************************************/
public class FSCloneBrandsetController{

    public  FS_brandset__c brandset{get;set;}
    public ID newRecordId {get;set;}
    public  FSCloneBrandsetController(final apexPages.StandardController controller){
        // get record reference
        brandset = (FS_Brandset__c)controller.getRecord();               
    }
    
    
     /*
    * @MethodName - save
    * @Description - To Clone the existing  Brandset  with Brandset Cartridges records
    * @Return - PageReference*/
       
    public pageReference save(){
        final FS_brandset__c brandsetClone=brandset.clone(false,true);
         
        try{
            insert brandsetClone;
            newRecordId = brandsetClone.id;
            final List<FS_Brandsets_Cartridges__c> clonedBrandCarts = new List<FS_Brandsets_Cartridges__c>();
            
            for(FS_Brandsets_Cartridges__c brandCarts : [SELECT Id, FS_Brandset__c,FS_Cartridge__c 
                                                          FROM FS_Brandsets_Cartridges__c 
                                                          WHERE FS_Brandset__c = : brandset.Id]){
                                                 
                final FS_Brandsets_Cartridges__c clonedSObject = brandCarts.clone(false,true);
                clonedSObject.FS_Brandset__c =  brandsetClone.Id;
                clonedBrandCarts.add(clonedSObject);
            }
            insert clonedBrandCarts ;
        }
        
        catch(DMLException ex){
            
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Another Brandset with the same name already exists.Please choose another name.'));
            ApexErrorLogger.addApexErrorLog('FET','FSCloneBrandsetController','save','Insertion','Medium',ex,'NA');
            return null;
        }
        return new PageReference('/'+brandsetClone.id);
    }
    
    
}