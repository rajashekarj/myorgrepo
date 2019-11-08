public without sharing class FETIntDefaultAccountController {
    
    private final FS_Outlet_Dispenser__c acct;
    public static final String PARAMETERKEY= 'CF00N6100000BpO5N';
    public static final String PARAMETERKEYID = 'CF00N6100000BpO5N_lkid';
    public FETIntDefaultAccountController(final ApexPages.StandardController controller) {
        this.acct = (FS_Outlet_Dispenser__c)controller.getRecord();
        system.debug('Acct : ' + this.acct);
    }
    
    public PageReference setOutletAccountDefault(){
        PageReference pageRef;        
        //modified query condition by added checkbox field  
        final List<Account> outletAccList = [SELECT id, name,Is_Default_FET_International_Outlet__c FROM Account WHERE Is_Default_FET_International_Outlet__c=true];        
        if(FSUtil.getObjectRecordTypeId(FS_Outlet_Dispenser__c.sObjectType,Label.INT_OD_RECORD_TYPE)== acct.RecordTypeId){
            ApexPages.currentPage().getParameters().remove('sfdc.override');
            ApexPages.currentPage().getParameters().remove('scontrolCaching');
            ApexPages.currentPage().getParameters().remove('save_new');       
            
            pageRef = new PageReference('/a0l/o');
            pageRef.getParameters().putAll(ApexPages.currentPage().getParameters());
            pageRef.getParameters().put('nooverride', '1');
            pageRef.getParameters().put(PARAMETERKEY, outletAccList.get(0).name);
            pageRef.getParameters().put(PARAMETERKEYID, outletAccList.get(0).id);
            
        }else{
            ApexPages.currentPage().getParameters().remove('sfdc.override');
            ApexPages.currentPage().getParameters().remove('scontrolCaching');
            ApexPages.currentPage().getParameters().remove('save_new'); 
            pageRef = new PageReference('/a0e/e');
            pageRef.getParameters().putAll(ApexPages.currentPage().getParameters());
            pageRef.getParameters().put('nooverride', '1');
        }
        return pageRef;
    }
}