public class FS_RedirectInitialRecordController {      
    public Pagereference redirectInitalOrder() {
        Pagereference page;
        String installationId=FSConstants.BLANKVALUE;
        installationId = ApexPages.currentPage().getParameters().get('recordId');
        final FS_Initial_Order_Setting__c settingRec = FS_Initial_Order_Setting__c.getOrgDefaults();
        
        If(installationId != null && installationId != '') {
            for(FS_Installation__c inst : [SELECT Id,Name,RecordType.Name FROM FS_Installation__c WHERE Id =: installationId]) {               
                If(inst.RecordType.Name == FSConstants.NEWINSTALLATION) {                    
                    page = new Pagereference('/'+settingRec.FS_Record_Id__c+'/e?RecordType='+settingRec.FS_New_Install_Record_Type_Id__c
                                             +'&'+settingRec.Installation_Id__c+'='+installationId+'&'+settingRec.Installation_Name__c+'=' + inst.Name);
                }
            }
        }
        else{
            final ApexPages.Message msg = new Apexpages.Message(Apexpages.severity.Error, 'Error occured');
            ApexPages.addMessage(msg);           
        }
        return page;
    }
}