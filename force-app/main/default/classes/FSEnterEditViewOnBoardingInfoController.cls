/*********************************************************************************************************
Name         : FSEnterEditViewOnBoardingInfoController
Created By   : Pallavi Sharma (Appiro)
Created Date : 18 - Sep - 2013
Usage        : Controller for Enter/Edit/View On BoardingInfo Page, which is used to edit information about 
Installation Info related to Execution Plan
// 14th Dec, 2014        Modified By: Ashish Goyal        Ref: (T-340032)
// 13th feb,2017	Modified By:Venkata Reg: FET 4.0 Project
// 9th Jan,2019 Modified by: Sai Krishna. Added a new Cancel method for redirection to prev Execution plan record page. Reg: FET 6 Ref:(Jira FNF-115)
***********************************************************************************************************/
public with sharing class FSEnterEditViewOnBoardingInfoController { 
    
    private static final String SELFILLDOWNALL = 'All';
    private static final String TRAINER = 'Trainer';
    private static final String ONBOARDINGCONTACT = 'OnboardingContact';
    private static final String SECONDARYCONTACT = 'SecondaryContact';
    private static final String STARTTIME = 'StartTime';
    private static final String OPENTIME = 'OpenTime';
    private static final String NOOFDAYS = 'NoofDays'; 
    private static final String COMMENTS = 'Comments'; 
    public List<FS_Installation__c> lstInstallation{get;set;}    
    public Id executionPlan{get;set;}
    public string selectedFillDown{get;set;}
    
    //Constructor
    public FSEnterEditViewOnBoardingInfoController(){
        executionPlan = Apexpages.currentPage().getParameters().get('executionplanid');
        lstInstallation = new List<FS_Installation__c>();       
        //Get all Installtions related to Execution Plan
        for(FS_Installation__c installObj : [ Select id,name,FS_Execution_Plan__c, FS_Outlet_Information__c,FS_OB_Comments__c,FS_Trainer__c, 
                                             Onboarding_Training_Contact__c,FS_OB_Secondary_Contact__c, FS_Training_Start_Time__c, Outlet_Open_Time__c,
                                             FS_HowManyDaysAfterInstallOnboarding__c From FS_Installation__c 
                                             Where FS_Execution_Plan__c =: executionPlan]){
            lstInstallation.add(installObj);            
         }        
    }
    
   /*****************************************************************
  	Method: saveInstallation
  	Description: saveInstallation method is to save the respective Installations in the List
				and return back to the Execution plan
	*******************************************************************/
    public PageReference saveInstallation(){        
        PageReference pgRef;
        try{
            //updating the installation records
            if(!lstInstallation.isEmpty()){
                update lstInstallation;
            }            
            pgRef = new PageReference('/'+executionPlan);
        }
        //catching the DML Exceptions
        catch(DMLException ex){  
            apexpages.addMessages(ex);
            ApexErrorLogger.addApexErrorLog(FSConstants.FET,'FSEnterEditViewOnBoardingInfoController','saveInstallation',FSConstants.INSTALLATIONOBJECTNAME,FSConstants.MediumPriority,ex,ex.getMessage());               		           
        }
        return pgRef;
    }
    /*****************************************************************
  	Method: fillDown
  	Description: fillDown method is to fill the same value of the first record to the respective following records		
	*******************************************************************/
    public void fillDown(){      
        if (selectedFillDown == SELFILLDOWNALL){
            for (FS_Installation__c inst :lstInstallation){       
                inst.FS_Trainer__c= lstInstallation[0].FS_Trainer__c ;
                inst.Onboarding_Training_Contact__c = lstInstallation[0].Onboarding_Training_Contact__c ;
                inst.FS_OB_Secondary_Contact__c= lstInstallation[0].FS_OB_Secondary_Contact__c ;
                inst.FS_Training_Start_Time__c = lstInstallation[0].FS_Training_Start_Time__c ;
                inst.Outlet_Open_Time__c = lstInstallation[0].Outlet_Open_Time__c ;
                inst.FS_HowManyDaysAfterInstallOnboarding__c = lstInstallation[0].FS_HowManyDaysAfterInstallOnboarding__c ;
                inst.FS_OB_Comments__c=lstInstallation[0].FS_OB_Comments__c;
            }     
        }
        else if (selectedFillDown == COMMENTS){
            for (FS_Installation__c inst :lstInstallation){       
                inst.FS_OB_Comments__c= lstInstallation[0].FS_OB_Comments__c ;
            }
        }  
        else if (selectedFillDown == TRAINER){
            for (FS_Installation__c inst :lstInstallation){       
                inst.FS_Trainer__c= lstInstallation[0].FS_Trainer__c ;
            }
        }     
        else if (selectedFillDown == ONBOARDINGCONTACT){
            for (FS_Installation__c inst :lstInstallation){       
                inst.Onboarding_Training_Contact__c = lstInstallation[0].Onboarding_Training_Contact__c ;
            }
        }
        else if (selectedFillDown == SECONDARYCONTACT){
            for (FS_Installation__c inst :lstInstallation){       
                inst.FS_OB_Secondary_Contact__c= lstInstallation[0].FS_OB_Secondary_Contact__c ;
            }
        }     
        else if (selectedFillDown == STARTTIME){
            for (FS_Installation__c inst :lstInstallation){       
                inst.FS_Training_Start_Time__c = lstInstallation[0].FS_Training_Start_Time__c ;
            }
        }     
        else if (selectedFillDown == OPENTIME){
            for (FS_Installation__c inst :lstInstallation){       
                inst.Outlet_Open_Time__c = lstInstallation[0].Outlet_Open_Time__c ;
            }
        }  
        else if (selectedFillDown == NOOFDAYS){
            for (FS_Installation__c inst :lstInstallation){       
                inst.FS_HowManyDaysAfterInstallOnboarding__c = lstInstallation[0].FS_HowManyDaysAfterInstallOnboarding__c ;
            }
        }              
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