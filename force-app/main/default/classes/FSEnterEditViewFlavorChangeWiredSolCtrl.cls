/*********************************************************************************************************
Name         : FSEnterEditViewFlavorChangeWiredSolCtrl
Created By   : Pallavi Sharma (Appiro)
Created Date : 17 - Sep - 2013
Usage        : Controller for Enter/Edit/View Flavor Change/Wired Sol Page, which is used to edit information about
Installation related to Execution Plan
Modified By  : Harshita Khandelwal 17-12-2014 Ref:T-341592
Modified By : Venkata 13-02-2017	reg FET 4.0 Project for adding extra columns [Brandset,water,dasani]
9th Jan,2019 Modified by: Sai Krishna. Added a new Cancel method for redirection to prev Execution plan record page. Reg: FET 6 Ref:(Jira FNF-115)
***********************************************************************************************************/

public class FSEnterEditViewFlavorChangeWiredSolCtrl {
    
    public  Map<Id,Id> oldBrandsets;
    public  Map<Id,FS_Association_Brandset__c> newAssBrands;
    public  Map<Id,String> ipStatus;
    public List<FS_Installation__c> lstInstallation{get;set;}
    public Id executionPlan{get;set;}      
    public List<String> errorList{get;set;}
    
    
    //Constructor
    //Changes Made as part of FET 4.0 added some fields in the Query
    public FSEnterEditViewFlavorChangeWiredSolCtrl(){
        executionPlan = Apexpages.currentPage().getParameters().get('executionplanid');
        lstInstallation = new List<FS_Installation__c>();        
        oldBrandsets=new  Map<Id,Id>();
        newAssBrands=new  Map<Id,FS_Association_Brandset__c>();
        ipStatus=new Map<Id,String>();
        
        //Get all Installtions related to Execution Plan
        lstInstallation = [Select Id,Name,Overall_Status2__c,FS_Execution_Plan__c, FS_BrandStatus__c, FS_Outlet_Information__c,
                           Type_of_Dispenser_Platform__c,(select id,name,FS_Brandset__c,FS_Installation__c,
                                                          FS_NonBranded_Water__c,FS_Platforms__c,FS_Platform__c from Account_Brandsets__r order by FS_Platforms__c)
                           From FS_Installation__c Where FS_Execution_Plan__c =: executionPlan];
        
        //store old brandsets
        for (FS_Installation__c ip:lstInstallation) {
            for (FS_Association_Brandset__c assBrand : ip.Account_Brandsets__r) {
                oldBrandsets.put(assBrand.id, assBrand.FS_Brandset__c);
            }
            //capture the status of installations
            ipStatus.put(ip.id, ip.Overall_Status2__c);
        }
        
    }
    
    /*****************************************************************
Method: saveInstallation
Description: saveInstallation method is to save the Installation records and return back to the Execution Plan record
Changes Made as part of FET 4.0
*******************************************************************/
    public PageReference saveInstallation(){
        PageReference page;
        final String allPlatforms=Platform_Type_ctrl__c.getAll().get('all_Platform').Platforms__c;
            
        final Map<Id,Id> odMap=new Map<Id,Id>();       
        try{            
            //FET 5.0 logic changed for mulitplatform Installation
            
            // restrict user to change brandset- Production Defect-start
            //Store ODs
            final List<FS_Outlet_Dispenser__c> oDList=[SELECT Id,Installation__c,FS_Equip_Type__c FROM FS_Outlet_Dispenser__c WHERE Installation__c IN:lstInstallation];
            for(FS_Outlet_Dispenser__c od:oDList){
                if (allPlatforms!=null && allPlatforms.contains(od.FS_Equip_Type__c) ) {
                    odMap.put(od.Installation__c,od.Id);
                }                    
            }                
            //store all new association brandsets
            for (FS_Installation__c ip : lstInstallation){
                for (FS_Association_Brandset__c assBrand : ip.Account_Brandsets__r) {
                    newAssBrands.put(assBrand.id, assBrand);
                }
            }
            //check each association brandset for brandset value changed
            for (FS_Association_Brandset__c newAssBrand : newAssBrands.values()){
                final ID installID  = newAssBrand.FS_Installation__c;
                //and Intallation Status is 4 installed scheduled
                if (oldBrandsets.get(newAssBrand.id) != newAssBrand.FS_Brandset__c && ipStatus.get(installID)==FSConstants.x4InstallSchedule && 
                    allPlatforms!=null && allPlatforms.contains(newAssBrand.FS_Platform__c) && odMap.containsKey(installID) && odMap.get(installID)!=null){                                
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.FlavourChangeERRMessage));
                    }                  
            }
            
            
            // restrict user to change brandset- Production Defect-close
            
            //FET 5.0
            //Upsert the related Associate Brandset
            final List<FS_Association_Brandset__c> assBrandsetsUpsert = new List<FS_Association_Brandset__c>();
            
            for (FS_Installation__c install : lstInstallation){
                assBrandsetsUpsert.addAll(install.Account_Brandsets__r);
            }
            
            Boolean isError = false;
            final List<Database.SaveResult> resList = Database.update(assBrandsetsUpsert,false);
            errorList = new List<String>();
            for(Database.SaveResult res : resList){
                if(!res.isSuccess()){
                    for(Database.Error error : res.getErrors()){ errorList.add(error.getMessage());    }
                    isError = true;  
                    break;
                }
            }            
            if(!isError){
                page = new PageReference('/' + executionPlan);
            }                       
        }catch(DMLException e) {    
            apexpages.addMessages(e);
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSEnterEditViewFlavorChangeWiredSolCtrl','saveInstallation',FSConstants.INSTALLATIONOBJECTNAME,FSConstants.MediumPriority,e,e.getMessage());
        }  
        return page;
    }
    /*****************************************************************
  	Method: cancel
  	Description: cancel method helps the user return back to the execution plan record  
	*******************************************************************/
    public PageReference cancel(){
        PageReference pageRef;
        if(executionPlan!= Null){
            pageRef= new PageReference('/' + executionPlan);
        }
        return pageRef;        
    } 
}