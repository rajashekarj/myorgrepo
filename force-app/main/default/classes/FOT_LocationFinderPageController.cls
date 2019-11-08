public class FOT_LocationFinderPageController{
    
    public FS_Outlet_Dispenser__c outDisp;

    public FOT_LocationFinderPageController(ApexPages.StandardController controller) {
        this.outDisp = (FS_Outlet_Dispenser__c)controller.getRecord();
        /*if(this.outDisp.FS_isReviewed__c != 'Yes'){
           this.outDisp.FS_Apply_to_all_dispensers_in_Outlet__c = true;
        }*/
		System.debug('outDisp' + outDisp);        
    }

    public PageReference saveDispenserLocation(){
        try{
            outDisp.FS_isReviewed__c = 'Yes';
            outDisp.FS_Loc_Finder_Reviewed_On__c= System.Now();
            outDisp.FS_Loc_Finder_ReviewedBy__c= UserInfo.getName();
            update outDisp;
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
        }
        return null;
    }   
}