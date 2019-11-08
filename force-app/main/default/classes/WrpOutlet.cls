/**************************************************************************************
Apex Class Name     : WrpOutlet
Version             : 1.0
Function            : Wrapper Class for FSCustomerInputFormController,FSExportCIFPDFController,FSPaginationCustomIterable classes
Modification Log    :
* Developer         : Deepak Jetty   
* Date              : 15 Jan 2017               
*************************************************************************************/
public class WrpOutlet{
    public Boolean isSelected{get;set;}
    public Boolean isInstallationExist{get;set;}
    public Boolean isActiveCIF{get;set;}
    public Boolean enableSel{get;set;}
    public Account outlet{get;set;}
    public FS_CIF__c cif{get;set;}
    public CIF_Header__c cifHead{get;set;}
    public String installationNumber{get;set;}
    public List<FS_Installation__c> lstInstallation{get;set;}
    public List<FS_CIF__c> lstCIFs{get;set;}
    public Map<String,String> chevStatusMap{get;set;}
    public Boolean isMandCheck{get;set;}
    public string brandSetName1 {get;set;}
    public string brandSetName2 {get;set;}
    public string isRO4WExist{get;set;} // FET7.0 FNF-835
    public string isReplaceExist{get;set;} //Added as part of FET-7.0 FNF 795
    public string brandSetName3 {get;set;}
    public boolean disCustDispSA {get;set;}
    public boolean enabPerfSa {get;set;}
    public WrpOutlet(Account outAccount,List<FS_Installation__c> lstInst,FS_CIF__c cifLineItem,List<FS_CIF__c> lstCIFs,String instNumber, Boolean isInstallExist,Boolean isActiveCIF,Boolean isSelected,Boolean enableSel,boolean disCustDispSA,String isRO4WExist, String isReplaceExist){//Modified as part of FET-7.0 FNF 795
        outlet = new Account();
        cif = new FS_CIF__c();
        lstInstallation = new List<FS_Installation__c>();
        this.lstCIFs = lstCIFs;
        this.outlet = outAccount;
        this.lstInstallation=lstInst;
        isInstallationExist = isInstallExist;
        if(!isActiveCIF && isSelected){
            this.isSelected = true;    
        }else{
           this.isSelected = isSelected;
        }
        installationNumber = instNumber;
        this.isActiveCIF = isActiveCIF;
        this.enableSel = enableSel;
        cif = cifLineItem;
        this.isRO4WExist = isRO4WExist; // FET7.0 FNF-835
        this.isReplaceExist = isReplaceExist; //Added as part of FET-7.0 FNF 795
        chevStatusMap = new Map<String,String>();
        this.disCustDispSA = disCustDispSA;
    }
 
    public WrpOutlet(Account outAccount,List<FS_Installation__c> lstInst,String instNumber, Boolean isInstallExist, Boolean isSelected,String isRO4WExist, String isReplaceExist){
        outlet = new Account();
        cif = new FS_CIF__c();
        lstInstallation = new List<FS_Installation__c>();
        this.outlet = outAccount;
        this.lstInstallation=lstInst;
        this.isSelected = isSelected;
        isInstallationExist = isInstallExist;
        installationNumber = instNumber;
        this.isRO4WExist = isRO4WExist; // FET7.0 FNF-835
        this.isReplaceExist = isReplaceExist; //Added as part of FET-7.0 FNF 795
        chevStatusMap = new Map<String,String>();
    }
}