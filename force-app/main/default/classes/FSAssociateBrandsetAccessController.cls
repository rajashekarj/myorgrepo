public class FSAssociateBrandsetAccessController {
	FS_Association_Brandset__c assBrandset;
    
    public FSAssociateBrandsetAccessController(ApexPages.StandardController controller){
        assBrandset= (FS_Association_Brandset__c) controller.getRecord();
    }
    
    public Pagereference deleteAssBrandset(){
        delete assBrandset;
        String returnURL = '/'+assBrandset.FS_Headquarters__c;
        return new Pagereference(returnURL);
    }
}