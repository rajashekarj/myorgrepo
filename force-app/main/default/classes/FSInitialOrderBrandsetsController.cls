public class FSInitialOrderBrandsetsController {
    
   public FS_Initial_Order__c initalOrder{set;get;}
   
    public FSInitialOrderBrandsetsController(final ApexPages.StandardController controller) {
        //Returns the record that is currently in context
        initalOrder=(FS_Initial_Order__c)controller.getRecord();
    }
    
    public List<FS_Association_Brandset__c> getAssosiationBrandsets(){
        return  [SELECT ID,FS_Brandset__c,FS_Brandset__r.name,FS_Platform__c,FS_Brandset__r.FS_SAP_Item_Proposal_Number__c,FS_Brandset__r.FS_Country__c,FS_Brandset_Number__c,FS_Brandset_Desc__c,FS_Commercial_Start_Date__c,FS_NonBranded_Water__c,CreatedByid,LastModifiedById,CreatedDate,	
LastModifiedDate FROM FS_Association_Brandset__c WHERE FS_Installation__c=:initalOrder.FS_Installation__c];
    }

}