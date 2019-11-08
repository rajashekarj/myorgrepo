/*******************************************************************************
Name         : FSExecutionPlanStatusIndicatorExtension
Created By   : Sonal Shrivastava (Appiro JDC)
Created Date : 08-Nov-2013
Usage        : Extension for FSExecutionPlanStatusIndicator Page , which is used
for StatusIndicator on Execution Plan Page
*******************************************************************************/
public without sharing class FSExecutionPlanStatusIndicatorExtension {
    public static final String GRAY='gray';
    public static final String BLUE='blue';
    public static final String YELLOW='yellow';
    public static final String REDC='red';
    public static final String GREEN='green';
    public static final Integer TWENTY=20;
    public static final Integer ZERO=0;
    public static final String COMPLETE='Complete';
    public static final String FIVECOMPLETE=FSConstants.IPCOMPLETE ;
    public static final String XPENDING='**Pending';
    public static final String XSCHEDULED='*Scheduled';
    public FS_Execution_Plan__c execPlan {get; set;}
    public String colorSAPending {get; set;}
    public String colorSAScheduled {get; set;}
    public String colorSAComplete {get; set;}
    public String colorEPApproved {get; set;}
    public String colorScheduled {get; set;}
    public String colorInstallComplete {get; set;}
    public String colorOnboardingComplete {get; set;}
	public static Object nullVal() { return null; }    
    //---------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------- 
    public FSExecutionPlanStatusIndicatorExtension(final Apexpages.Standardcontroller standCont){
        final String execPlanId = standCont.getId();
        init();
        for(FS_Execution_Plan__c ep : [SELECT Id, FS_of_Installations__c,FS_Execution_Plan_Final_Approval_PMCheck__c, FS_Execution_Age__c, FS_Execution_Plan_Final_Approval_PM__c, 
                                       (SELECT Id, FS_Davaco_SA_Status__c, Overall_Status2__c, FS_OB_Info_Status__c, FS_Scheduled_Install_Date__c 
                                        FROM Outlet_Info_Summary__r)
                                       FROM FS_Execution_Plan__c 
                                       WHERE Id = :execPlanId]){
                                           execPlan = ep;
                                       }
        populateColors();
    }
    
    //---------------------------------------------------------------------------
    // Method to initialize public variables
    //---------------------------------------------------------------------------
    private void init(){
        execPlan = new FS_Execution_Plan__c();
        colorSAPending = GRAY;
        colorSAScheduled = GRAY;
        colorSAComplete = GRAY;
        colorEPApproved = GRAY;
        colorScheduled = GRAY;
        colorInstallComplete = GRAY;
        colorOnboardingComplete = GRAY;
    }
    
    //---------------------------------------------------------------------------
    // Method to populate all color variables
    //---------------------------------------------------------------------------
    private void populateColors(){
        if(execPlan.Id != nullVal()){
            
            Boolean allNotPending = true;
            Boolean allNotNotReadyPending = true;
            Boolean allScheduled = true;
            Boolean allComplete = true;            
            Boolean allInstallDateNotBlank = true;
            Boolean allOverallStatusNot5InstComp = true;
            Boolean allOverallStatus5InstComp = true;
            Boolean allOBInfoStatusNotComp = true;
            Boolean allOBInfoStatusComp = true;
            
            if(execPlan.FS_Execution_Age__c >= ZERO){
                colorSAPending = GREEN;
            }
            
            for(FS_Installation__c inst : execPlan.Outlet_Info_Summary__r ){
                
                if(inst.FS_Davaco_SA_Status__c == XPENDING){
                    allNotPending = false;
                }
                if(inst.FS_Davaco_SA_Status__c == '***Not Ready' || inst.FS_Davaco_SA_Status__c == XPENDING){
                    allNotNotReadyPending = false;
                }
                if(inst.FS_Davaco_SA_Status__c != XSCHEDULED){
                    allScheduled = false;
                }
                if(inst.FS_Davaco_SA_Status__c != COMPLETE){
                    allComplete = false;
                }
                if(inst.FS_Scheduled_Install_Date__c == nullVal()){
                    allInstallDateNotBlank = false;
                }
                if(inst.Overall_Status2__c == FIVECOMPLETE){
                    allOverallStatusNot5InstComp = FALSE;
                }
                if(inst.Overall_Status2__c != FIVECOMPLETE){
                    allOverallStatus5InstComp = false;
                }
                if(inst.FS_OB_Info_Status__c == COMPLETE){
                    allOBInfoStatusNotComp = false;
                }
                if(inst.FS_OB_Info_Status__c != COMPLETE){
                    allOBInfoStatusComp = false;
                }
            }
            findSAScheduledColor(allNotNotReadyPending);
            findSACompleteColor(allNotPending, allScheduled, allComplete);
            findEPApprovedColor(allComplete);
            findScheduledColor(allInstallDateNotBlank);
            findInstallCompleteColor(allOverallStatusNot5InstComp, allOverallStatus5InstComp, allInstallDateNotBlank);
            findOnboardingCompleteColor(allOBInfoStatusNotComp, allOBInfoStatusComp, allOverallStatus5InstComp);
        }
    }
    
    //---------------------------------------------------------------------------
    // Method to find SA Scheduled Color
    //---------------------------------------------------------------------------
    private void findSAScheduledColor(final Boolean allNotNotReadyPending){
        if(execPlan.FS_of_Installations__c < TWENTY ){
            if(!allNotNotReadyPending  && execPlan.FS_Execution_Age__c < 2){
                colorSAScheduled = BLUE;
            }
            else if(!allNotNotReadyPending  && execPlan.FS_Execution_Age__c >= 2 && execPlan.FS_Execution_Age__c <= 3){
                colorSAScheduled = YELLOW;
            }
            else if(!allNotNotReadyPending && execPlan.FS_Execution_Age__c > 3){
                colorSAScheduled = REDC;
            }
            else if(allNotNotReadyPending){
                colorSAScheduled = GREEN;
            }
        }
        else{
            if(!allNotNotReadyPending && execPlan.FS_Execution_Age__c < 3){
                colorSAScheduled = BLUE;
            }
            else if(!allNotNotReadyPending && execPlan.FS_Execution_Age__c >= 3 && execPlan.FS_Execution_Age__c <= 4){
                colorSAScheduled = YELLOW;
            }
            else if(!allNotNotReadyPending && execPlan.FS_Execution_Age__c > 4){
                colorSAScheduled = REDC;
            }
            else if(allNotNotReadyPending){
                colorSAScheduled = GREEN;
            }
        }
    }
    
    //----------------------------------------------------------------------------
    // Method to find SA Complete Color
    //---------------------------------------------------------------------------- 
    private void findSACompleteColor(final Boolean allNotPending,final  Boolean allScheduled,final  Boolean allComplete){   
        if(execPlan.FS_of_Installations__c < TWENTY ){
            if(execPlan.FS_Execution_Age__c < 4 && allNotPending && !allScheduled){
                colorSAComplete = GRAY;
            }
            else if(!allComplete && execPlan.FS_Execution_Age__c < 8 && allScheduled){
                colorSAComplete = BLUE;
            }
            else if(!allComplete && execPlan.FS_Execution_Age__c >= 8 && execPlan.FS_Execution_Age__c <= 10 && allScheduled ){
                colorSAComplete = YELLOW;
            }
            else if(!allComplete && execPlan.FS_Execution_Age__c > 10 && allScheduled){
                colorSAComplete = REDC;
            }
            else if(allComplete){
                colorSAComplete = GREEN;
            }
        } 
        else{
            if(execPlan.FS_Execution_Age__c < 5 && allNotPending){
                colorSAComplete = GRAY;
            }
            else if(!allComplete && execPlan.FS_Execution_Age__c < 17){
                colorSAComplete = BLUE;
            }
            else if(!allComplete && execPlan.FS_Execution_Age__c >= 17 && execPlan.FS_Execution_Age__c <= 19 ){
                colorSAComplete = YELLOW;
            }
            else if(!allComplete && execPlan.FS_Execution_Age__c > 19 ){
                colorSAComplete = REDC;
            }
            else if(allComplete){
                colorSAComplete = GREEN;
            }
        }
    }
    
    //----------------------------------------------------------------------------
    // Method to find EP Approved Color
    //---------------------------------------------------------------------------- 
    private void findEPApprovedColor(final Boolean allComplete){   
        if(execPlan.FS_of_Installations__c < TWENTY ){
            if(execPlan.FS_Execution_Age__c < 11 && allComplete){
                colorEPApproved = GRAY;
            }
            else if(!execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c && execPlan.FS_Execution_Age__c < 18 && allComplete){
                colorEPApproved = BLUE;
            }
            else if(!execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c && execPlan.FS_Execution_Age__c >= 18 && execPlan.FS_Execution_Age__c <= TWENTY && allComplete){
                colorEPApproved = YELLOW;
            }
            else if(!execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c && execPlan.FS_Execution_Age__c > TWENTY && allComplete){
                colorEPApproved = REDC;
            }
            else if(execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorEPApproved = GREEN;
            }
        } 
        else{
            if(execPlan.FS_Execution_Age__c < TWENTY && allComplete){
                colorEPApproved = GRAY;
            }
            else if(!execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c && execPlan.FS_Execution_Age__c < 24 && allComplete){
                colorEPApproved = BLUE;
            }
            else if(!execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c && execPlan.FS_Execution_Age__c >= 24 && execPlan.FS_Execution_Age__c <= 25 && allComplete){
                colorEPApproved = YELLOW;
            }
            else if(!execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c && execPlan.FS_Execution_Age__c > 25 && allComplete){
                colorEPApproved = REDC;
            }
            else if(execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorEPApproved = GREEN;
            }
        }
    }
    
    //----------------------------------------------------------------------------
    // Method to find Scheduled Color
    //---------------------------------------------------------------------------- 
    private void findScheduledColor(final Boolean allInstallDateNotBlank){   
        if(execPlan.FS_of_Installations__c < TWENTY ){
            if(execPlan.FS_Execution_Age__c < 21 && execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorScheduled = GRAY;
            }
            else if(!allInstallDateNotBlank && execPlan.FS_Execution_Age__c < 23 && execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorScheduled = BLUE;
            }
            else if(!allInstallDateNotBlank && execPlan.FS_Execution_Age__c >= 23 && execPlan.FS_Execution_Age__c <= 24 && execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorScheduled = YELLOW;
            }
            else if(!allInstallDateNotBlank && execPlan.FS_Execution_Age__c > 24 && execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorScheduled = REDC;
            }
            else if(allInstallDateNotBlank){
                colorScheduled = GREEN;
            }
        } 
        else{
            if(execPlan.FS_Execution_Age__c < 26 && execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorScheduled = GRAY;
            }
            else if(!allInstallDateNotBlank  && execPlan.FS_Execution_Age__c < 28 && execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorScheduled = BLUE;
            }
            else if(!allInstallDateNotBlank  && execPlan.FS_Execution_Age__c >= 28 && execPlan.FS_Execution_Age__c <= 29 && execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorScheduled = YELLOW;
            }
            else if(!allInstallDateNotBlank  && execPlan.FS_Execution_Age__c > 29 && execPlan.FS_Execution_Plan_Final_Approval_PMCheck__c){
                colorScheduled = REDC;
            }
            else if(allInstallDateNotBlank){
                colorScheduled = GREEN;
            }
        }
    }
    
    //----------------------------------------------------------------------------
    // Method to find Install Complete Color
    //---------------------------------------------------------------------------- 
    private void findInstallCompleteColor(final Boolean allOverallStatusNot5InstComp,final  Boolean allOverallStatus5InstComp,final  Boolean allInstallDateNotBlank){   
        if(execPlan.FS_of_Installations__c < TWENTY ){
            if(execPlan.FS_Execution_Age__c < 25 && allInstallDateNotBlank){
                colorInstallComplete = GRAY;
            }
            else if(!allOverallStatus5InstComp && execPlan.FS_Execution_Age__c < 37 && allInstallDateNotBlank){
                colorInstallComplete = BLUE;
            }
            else if(!allOverallStatus5InstComp && execPlan.FS_Execution_Age__c >= 37 && execPlan.FS_Execution_Age__c <= 40 && allInstallDateNotBlank){
                colorInstallComplete = YELLOW;
            }
            else if(!allOverallStatus5InstComp && execPlan.FS_Execution_Age__c > 40 && allInstallDateNotBlank){
                colorInstallComplete = REDC;
            }
            else if(allOverallStatus5InstComp){
                colorInstallComplete = GREEN;
            }
        } 
        else{
            if(execPlan.FS_Execution_Age__c < 30 && allInstallDateNotBlank){
                colorInstallComplete = GRAY;
            }
            else if(allOverallStatusNot5InstComp && execPlan.FS_Execution_Age__c < 42 && allInstallDateNotBlank){
                colorInstallComplete = BLUE;
            }
            else if(allOverallStatusNot5InstComp && execPlan.FS_Execution_Age__c >= 43 && execPlan.FS_Execution_Age__c <= 45 && allInstallDateNotBlank){
                colorInstallComplete = YELLOW;
            }
            else if(allOverallStatusNot5InstComp && execPlan.FS_Execution_Age__c > 45 && allInstallDateNotBlank){
                colorInstallComplete = REDC;
            }
            else if(allOverallStatus5InstComp){
                colorInstallComplete = GREEN;
            }
        }
    }
    
    //----------------------------------------------------------------------------
    // Method to find Onboarding Complete Color
    //---------------------------------------------------------------------------- 
    private void findOnboardingCompleteColor(final Boolean allOBInfoStatusNotComp,final  Boolean allOBInfoStatusComp,final  Boolean allOverallStatus5InstComp){   
        if(execPlan.FS_of_Installations__c < TWENTY ){
            if(execPlan.FS_Execution_Age__c < 41 && allOverallStatus5InstComp){
                colorOnboardingComplete = GRAY;
            }
            else if(allOBInfoStatusNotComp && execPlan.FS_Execution_Age__c == 41 && allOverallStatus5InstComp){
                colorOnboardingComplete = BLUE;
            }
            else if(allOBInfoStatusNotComp && execPlan.FS_Execution_Age__c > 41 && allOverallStatus5InstComp){
                colorOnboardingComplete = REDC;
            }
            else if(allOBInfoStatusComp){
                colorOnboardingComplete = GREEN;
            }
        } 
        else{
            if(execPlan.FS_Execution_Age__c < 46 && allOverallStatus5InstComp){
                colorOnboardingComplete = GRAY;
            }
            else if(allOBInfoStatusNotComp && execPlan.FS_Execution_Age__c == 46 && allOverallStatus5InstComp){
                colorOnboardingComplete = BLUE;
            }
            else if(allOBInfoStatusNotComp && execPlan.FS_Execution_Age__c > 46 && allOverallStatus5InstComp){
                colorOnboardingComplete = REDC;
            }
            else if(allOBInfoStatusComp){
                colorOnboardingComplete = GREEN;
            }
        }
    }
    
}